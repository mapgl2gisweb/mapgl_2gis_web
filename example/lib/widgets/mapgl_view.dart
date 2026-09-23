//example/lib/widgets/mapgl_view.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mapgl_2gis_web/mapgl_2gis_web.dart';

/// Map widget with a complete UX: an optional static preview, a loading
/// indicator, and a smooth transition to the interactive map.
class MapGlView extends StatefulWidget {
  const MapGlView({
    super.key,
    required this.apiKey,
    this.styleId,
    this.initialCenter = const [39.7257, 43.5855],
    this.initialZoom = 13,
    this.showStaticPreview = true,
    this.backgroundColor,
    this.loadingBuilder,
    this.onMapCreated,
    this.onMapReady,
  });

  final String apiKey;
  final String? styleId;
  final List<double> initialCenter;
  final double initialZoom;
  final bool showStaticPreview;
  final String? backgroundColor;
  final MapLoadingBuilder? loadingBuilder;
  final MapCreatedCallback? onMapCreated;
  final MapReadyCallback? onMapReady;

  @override
  State<MapGlView> createState() => _MapGlViewState();
}

typedef MapLoadingBuilder = Widget Function(BuildContext context);

class _MapGlViewState extends State<MapGlView> {
  bool _mapReady = false;

  String _staticPreviewUrl(int widthPx, int heightPx) {
    final lat = widget.initialCenter[1];
    final lng = widget.initialCenter[0];
    final z = widget.initialZoom.floor();
    return 'https://static.maps.2gis.com/2.0'
        '?s=${widthPx}x$heightPx'
        '&c=$lat,$lng'
        '&z=$z'
        '&key=${widget.apiKey}';
  }

  /// Desaturation matrix applied to the static preview while the interactive
  /// map is loading — keeps the underlying image from competing visually
  /// with the map controls.
  List<double> matrix = [
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite ? constraints.maxWidth.round() : 800;
        final height = constraints.maxHeight.isFinite ? constraints.maxHeight.round() : 600;
        final staticPreviewUrl = _staticPreviewUrl(width, height);
        return Stack(
          fit: StackFit.expand,
          children: [
            widget.showStaticPreview
                ? ColorFiltered(
                    colorFilter: ColorFilter.matrix(matrix),
                    child: Image.network(
                      staticPreviewUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      loadingBuilder: (context, child, progress) => progress == null ? child : const SizedBox.shrink(),
                    ),
                  )
                : widget.loadingBuilder != null
                ? widget.loadingBuilder!.call(context)
                : SizedBox.shrink(),
            MapGlWidget(
              apiKey: widget.apiKey,
              styleId: widget.styleId,
              initialCenter: widget.initialCenter,
              initialZoom: widget.initialZoom,
              backgroundColor: widget.backgroundColor,
              onMapCreated: widget.onMapCreated,
              onMapReady: () {
                if (mounted) setState(() => _mapReady = true);
                widget.onMapReady?.call();
              },
            ),
            if (!_mapReady) const _MapLoadingOverlay(),
          ],
        );
      },
    );
  }
}

/// Compact loading indicator shown in the bottom-right corner while the map
/// is initialising. After a few seconds it also shows a short "loading" hint
/// so the user knows the process is still running.
class _MapLoadingOverlay extends StatefulWidget {
  const _MapLoadingOverlay();

  @override
  State<_MapLoadingOverlay> createState() => _MapLoadingOverlayState();
}

class _MapLoadingOverlayState extends State<_MapLoadingOverlay> {
  bool _showSlowHint = false;
  Timer? _slowTimer;

  @override
  void initState() {
    super.initState();
    _slowTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showSlowHint = true);
    });
  }

  @override
  void dispose() {
    _slowTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black26)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            if (_showSlowHint) ...[
              const SizedBox(width: 8),
              Text('Loading map…', style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
