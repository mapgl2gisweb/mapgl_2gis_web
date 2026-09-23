//example/lib/screens/clasterer_screen.dart

import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:mapgl_2gis_web/mapgl_2gis_web.dart';
import 'package:mapgl_2gis_web_example/config.dart';
import 'package:mapgl_2gis_web_example/features/random_cluster_points.dart';

import '../extension/color_hex_extension.dart';

enum _ClusterStyleMode { default_, fixed, dynamic }

enum _ClusterStyleKind { webgl, html }

enum _ClusterClickMode { standard, expand }

class ClastererScreen extends StatefulWidget {
  const ClastererScreen({super.key});

  @override
  State<ClastererScreen> createState() => _ClastererScreenState();
}

/// Per-cluster visual parameters derived from a tier or from the point count.
class _ClusterVisual {
  const _ClusterVisual({
    required this.color,
    required this.diameter,
    this.hoverColor,
    this.labelFontSize,
    this.labelHaloColor,
    this.labelHaloRadius,
    this.zIndex,
  });

  final String color;
  final double diameter;

  /// Hover color — WebGL only. `HtmlClusterStyle` has no hover fields.
  final String? hoverColor;

  final double? labelFontSize;
  final String? labelHaloColor;
  final double? labelHaloRadius;

  /// Draw order — larger clusters render above smaller ones when tiers
  /// overlap.
  final int? zIndex;
}

final _fixedVisual = _ClusterVisual(
  color: Colors.green.toHex(),
  diameter: 40,
  hoverColor: Colors.green.shade700.toHex(),
  labelFontSize: 14,
  labelHaloColor: Colors.black.toHex(),
  labelHaloRadius: 1,
  zIndex: 1,
);

_ClusterVisual _dynamicVisualForCount(int count) {
  if (count <= 5) {
    return _ClusterVisual(
      color: Colors.blue.toHex(),
      diameter: 32,
      hoverColor: Colors.blue.shade700.toHex(),
      labelFontSize: 12,
      labelHaloColor: Colors.black.toHex(),
      labelHaloRadius: 1,
      zIndex: 1,
    );
  }
  if (count <= 10) {
    return _ClusterVisual(
      color: Colors.blueGrey.toHex(),
      diameter: 40,
      hoverColor: Colors.blueGrey.shade700.toHex(),
      labelFontSize: 13,
      labelHaloColor: Colors.black.toHex(),
      labelHaloRadius: 1,
      zIndex: 2,
    );
  }
  if (count <= 20) {
    return _ClusterVisual(
      color: Colors.lightBlue.toHex(),
      diameter: 48,
      hoverColor: Colors.lightBlue.shade700.toHex(),
      labelFontSize: 14,
      labelHaloColor: Colors.black.toHex(),
      labelHaloRadius: 1.5,
      zIndex: 3,
    );
  }
  if (count <= 30) {
    return _ClusterVisual(
      color: Colors.lightBlueAccent.toHex(),
      diameter: 56,
      hoverColor: Colors.lightBlueAccent.shade700.toHex(),
      labelFontSize: 15,
      labelHaloColor: Colors.black.toHex(),
      labelHaloRadius: 1.5,
      zIndex: 4,
    );
  }

  return _ClusterVisual(
    color: Colors.blueAccent.toHex(),
    diameter: 64,
    hoverColor: Colors.blueAccent.shade700.toHex(),
    labelFontSize: 16,
    labelHaloColor: Colors.black.toHex(),
    labelHaloRadius: 2,
    zIndex: 5,
  );
}

/// Builds an inline SVG circle as a data URI — no external icon assets
/// needed.
String _circleSvgDataUri(String hexColor, double diameter) {
  final size = diameter.round();
  final svg =
      '<svg xmlns="http://www.w3.org/2000/svg" '
      'width="$size" height="$size" viewBox="0 0 $size $size">'
      '<circle cx="${size / 2}" cy="${size / 2}" r="${size / 2}" '
      'fill="$hexColor"/></svg>';
  return 'data:image/svg+xml;base64,${base64Encode(utf8.encode(svg))}';
}

class _ClastererScreenState extends State<ClastererScreen> {
  MapController? _mapController;
  ClustererController<LngLat>? _clustererController;

  List<LngLat> _points = [];
  int _loadedCount = 0;
  bool _isLoading = false;

  _ClusterStyleMode _styleMode = _ClusterStyleMode.default_;
  _ClusterStyleKind _styleKind = _ClusterStyleKind.webgl;
  _ClusterClickMode _clickMode = _ClusterClickMode.standard;

  /// Distinct color for individual (non-clustered) markers, kept separate
  /// from the cluster palette so the two are visually unambiguous on the
  /// map.
  String get _markerColor => Theme.of(context).colorScheme.primary.toHex();
  static const _markerDiameter = 32.0;

  // --- Cluster style building ---

  /// `pointsCount` is null for the fixed (non-count-dependent) style.
  ClusterStyle _styleFor(_ClusterVisual visual, {int? pointsCount}) {
    switch (_styleKind) {
      case _ClusterStyleKind.webgl:
        return ClusterStyle.webgl(
          icon: _circleSvgDataUri(visual.color, visual.diameter),
          size: [visual.diameter, visual.diameter],
          hoverIcon: visual.hoverColor != null ? _circleSvgDataUri(visual.hoverColor!, visual.diameter) : null,
          hoverSize: visual.hoverColor != null ? [visual.diameter * 1.1, visual.diameter * 1.1] : null,
          labelColor: Colors.white.toHex(),
          labelFontSize: visual.labelFontSize,
          labelHaloColor: visual.labelHaloColor,
          labelHaloRadius: visual.labelHaloRadius,
          zIndex: visual.zIndex,
          // `labelText` is intentionally omitted — the SDK renders the
          // point count automatically for WebGL clusters by default.
        );
      case _ClusterStyleKind.html:
        final label = pointsCount != null ? '$pointsCount' : '';
        final d = visual.diameter.round();
        return ClusterStyle.html(
          html:
              '<div style="background:${visual.color};color:#fff;border-radius:50%;'
              'width:${d}px;height:${d}px;display:flex;align-items:center;'
              'justify-content:center;font-family:sans-serif;">$label</div>',
          zIndex: visual.zIndex,
        );
    }
  }

  ClustererOptions<LngLat> _buildOptions() {
    ClustererStyleContainer<LngLat>? container;
    switch (_styleMode) {
      case _ClusterStyleMode.default_:
        container = null; // let the SDK use its own default icon
      case _ClusterStyleMode.fixed:
        container = ClustererStyleContainer<LngLat>.fixed(_styleFor(_fixedVisual));
      case _ClusterStyleMode.dynamic:
        container = ClustererStyleContainer<LngLat>.dynamic((pointsCount, target) {
          final visual = _dynamicVisualForCount(pointsCount);
          return _styleFor(visual, pointsCount: pointsCount);
        });
    }
    return ClustererOptions<LngLat>(radius: 60, clusterStyle: container);
  }

  // --- Marker building ---

  /// When [_styleMode] is not `default`, individual (non-clustered) markers
  /// also get a custom icon — otherwise the SDK's default pin would look
  /// inconsistent next to custom-styled clusters.
  InputMarker<LngLat> _buildMarker(LngLat p) {
    if (_styleMode == _ClusterStyleMode.default_) {
      return InputMarker<LngLat>.webgl(coordinates: [p.lng, p.lat], userData: p);
    }

    switch (_styleKind) {
      case _ClusterStyleKind.webgl:
        return InputMarker<LngLat>.webgl(
          coordinates: [p.lng, p.lat],
          icon: _circleSvgDataUri(_markerColor, _markerDiameter),
          size: [_markerDiameter, _markerDiameter],
          userData: p,
        );
      case _ClusterStyleKind.html:
        final d = _markerDiameter.round();
        return InputMarker<LngLat>.html(
          coordinates: [p.lng, p.lat],
          html:
              '<div style="background:$_markerColor;border-radius:50%;'
              'width:${d}px;height:${d}px;"></div>',
          userData: p,
        );
    }
  }

  // --- Clusterer lifecycle ---

  Future<void> _loadRandomClusters() async {
    final mapController = _mapController;
    if (mapController == null) return;

    setState(() => _isLoading = true);

    final bounds = mapController.getBounds();
    final generator = RandomClusterPointsGenerator();
    _points = generator.generate(
      west: bounds.southWest[0],
      south: bounds.southWest[1],
      east: bounds.northEast[0],
      north: bounds.northEast[1],
      count: 100,
      minDistanceMeters: 50,
    );

    await _rebuildClusterer(mapController);

    if (!mounted) return;
    setState(() {
      _loadedCount = _points.length;
      _isLoading = false;
    });
  }

  /// Applies the current style configuration to the existing points without
  /// regenerating them.
  ///
  /// `ClustererOptions` are only read once, at construction time, by the JS
  /// SDK — changing them requires a full dispose + recreate cycle.
  Future<void> _applyStyleConfig() async {
    final mapController = _mapController;
    if (mapController == null || _points.isEmpty) return;

    setState(() => _isLoading = true);
    await _rebuildClusterer(mapController);
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _rebuildClusterer(MapController mapController) async {
    _clustererController?.dispose();

    final controller = ClustererController<LngLat>(mapController, options: _buildOptions());
    _clustererController = controller;

    final markers = _points.map(_buildMarker).toList();

    await controller.load(markers);
    _attachClickHandler(controller, mapController);
  }

  void _attachClickHandler(ClustererController<LngLat> controller, MapController mapController) {
    controller.raw.onEvent(ClustererEventType.click, (event) {
      final target = event.target;
      switch (target.targetType) {
        case ClustererTargetType.marker:
          _showSnack('Marker: ${target.markerUserData}');

        case ClustererTargetType.cluster:
          // `_clickMode` is read at click time, not at subscription time —
          // toggling it does not require rebuilding the clusterer.
          if (_clickMode == _ClusterClickMode.standard) {
            final points = target.clusterUsersData;
            _showSnack('Cluster of ${points?.length ?? 0} points');
          } else {
            final clusterId = target.id!.toDartInt;
            final expansionZoom = controller.raw.getClusterExpansionZoom(clusterId);
            final targetLngLat = event.lngLatList;
            try {
              mapController.setCenter(targetLngLat);
              mapController.setZoom(expansionZoom.toDouble());
            } catch (e, st) {
              logMapgl('cluster expand failed: $e\n$st');
            }
          }

        case ClustererTargetType.unknown:
          break;
      }
    });
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _clustererController?.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapGlWidget(
            apiKey: ExampleConfig.apiKey,
            initialCenter: ExampleConfig.defaultCenter,
            onMapCreated: (controller) => _mapController = controller,
            onMapReady: _loadRandomClusters,
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FilledButton.tonal(
                      onPressed: _isLoading ? null : _loadRandomClusters,
                      child: Text(_isLoading ? 'Loading...' : 'Reload random points'),
                    ),
                    Text('Loaded: $_loadedCount'),
                    SegmentedButton<_ClusterStyleMode>(
                      segments: const [
                        ButtonSegment(value: _ClusterStyleMode.default_, label: Text('Default')),
                        ButtonSegment(value: _ClusterStyleMode.fixed, label: Text('Fixed')),
                        ButtonSegment(value: _ClusterStyleMode.dynamic, label: Text('Dynamic')),
                      ],
                      selected: {_styleMode},
                      onSelectionChanged: _isLoading
                          ? null
                          : (selection) {
                              setState(() => _styleMode = selection.first);
                              _applyStyleConfig();
                            },
                    ),
                    IgnorePointer(
                      ignoring: _styleMode == _ClusterStyleMode.default_ || _isLoading,
                      child: Opacity(
                        opacity: _styleMode == _ClusterStyleMode.default_ ? 0.4 : 1,
                        child: SegmentedButton<_ClusterStyleKind>(
                          segments: const [
                            ButtonSegment(value: _ClusterStyleKind.webgl, label: Text('WebGL')),
                            ButtonSegment(value: _ClusterStyleKind.html, label: Text('HTML')),
                          ],
                          selected: {_styleKind},
                          onSelectionChanged: (selection) {
                            setState(() => _styleKind = selection.first);
                            _applyStyleConfig();
                          },
                        ),
                      ),
                    ),
                    SegmentedButton<_ClusterClickMode>(
                      segments: const [
                        ButtonSegment(value: _ClusterClickMode.standard, label: Text('Info on click')),
                        ButtonSegment(value: _ClusterClickMode.expand, label: Text('Expand on click')),
                      ],
                      selected: {_clickMode},
                      onSelectionChanged: (selection) {
                        setState(() => _clickMode = selection.first);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
