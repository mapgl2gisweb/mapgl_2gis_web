// src/clusterer/input_marker.dart

import 'dart:js_interop';

import '../common/label_options.dart';

/// Alias preserved for backwards compatibility.
///
/// The label configuration is now modelled once in [LabelOptions], since
/// `mapgl.Marker` and the clusterer share the exact same JS shape.
@Deprecated('Use LabelOptions from package:mapgl_2gis_web instead')
typedef InputMarkerLabelOptions = LabelOptions;

/// Sealed base class for markers accepted by the MapGL Clusterer.
///
/// Two concrete variants exist: [WebglInputMarker] and [HtmlInputMarker].
/// Every field except [coordinates] is optional; unset fields are omitted
/// from the resulting JS object.
sealed class InputMarker<T> {
  final String type;
  final List<double> coordinates;
  final int? zIndex;
  final T? userData;
  final Map<String, Object?>? additionalData;

  const InputMarker({required this.type, required this.coordinates, this.zIndex, this.userData, this.additionalData});

  /// Factory for a WebGL marker.
  factory InputMarker.webgl({
    required List<double> coordinates,
    String? icon,
    List<double>? size,
    List<double>? anchor,
    String? hoverIcon,
    List<double>? hoverSize,
    List<double>? hoverAnchor,
    LabelOptions? label,
    int? zIndex,
    T? userData,
    Map<String, Object?>? additionalData,
  }) {
    return WebglInputMarker<T>(
      coordinates: coordinates,
      icon: icon,
      size: size,
      anchor: anchor,
      hoverIcon: hoverIcon,
      hoverSize: hoverSize,
      hoverAnchor: hoverAnchor,
      label: label,
      zIndex: zIndex,
      userData: userData,
      additionalData: additionalData,
    );
  }

  /// Factory for an HTML marker.
  factory InputMarker.html({
    required List<double> coordinates,
    required String html,
    List<double>? anchor,
    double? minZoom,
    double? maxZoom,
    int? zIndex,
    bool? preventMapInteractions,
    T? userData,
    Map<String, Object?>? additionalData,
  }) {
    return HtmlInputMarker<T>(
      coordinates: coordinates,
      html: html,
      anchor: anchor,
      minZoom: minZoom,
      maxZoom: maxZoom,
      zIndex: zIndex,
      preventMapInteractions: preventMapInteractions,
      userData: userData,
      additionalData: additionalData,
    );
  }

  /// Converts [userData] into a JS-friendly value.
  ///
  /// Primitives and `Map` instances are converted directly; anything else
  /// falls back to its `toString()` representation. Returns `null` when
  /// [userData] is `null`.
  JSAny? _jsifyUserData() {
    if (userData == null) return null;
    if (userData is JSAny) return userData as JSAny;
    if (userData is Map) return (userData as Map).jsify();
    if (userData is String || userData is num || userData is bool) {
      return userData.jsify();
    }
    return userData.toString().toJS;
  }

  Map<String, Object?> toJsMap();
}

/// WebGL marker implementation.
class WebglInputMarker<T> extends InputMarker<T> {
  final String? icon;
  final List<double>? size;
  final List<double>? anchor;
  final String? hoverIcon;
  final List<double>? hoverSize;
  final List<double>? hoverAnchor;
  final LabelOptions? label;

  const WebglInputMarker({
    required super.coordinates,
    this.icon,
    this.size,
    this.anchor,
    this.hoverIcon,
    this.hoverSize,
    this.hoverAnchor,
    this.label,
    super.zIndex,
    super.userData,
    super.additionalData,
  }) : super(type: 'webgl');

  @override
  Map<String, Object?> toJsMap() => {
    'type': type,
    'coordinates': coordinates,
    if (icon != null) 'icon': icon,
    if (size != null) 'size': size,
    if (anchor != null) 'anchor': anchor,
    if (hoverIcon != null) 'hoverIcon': hoverIcon,
    if (hoverSize != null) 'hoverSize': hoverSize,
    if (hoverAnchor != null) 'hoverAnchor': hoverAnchor,
    if (label != null) 'label': label!.toJsMap(),
    if (zIndex != null) 'zIndex': zIndex,
    if (userData != null) 'userData': _jsifyUserData(),
    ...?additionalData,
  };
}

/// HTML marker implementation.
class HtmlInputMarker<T> extends InputMarker<T> {
  final String html;
  final List<double>? anchor;
  final double? minZoom;
  final double? maxZoom;
  final bool? preventMapInteractions;

  const HtmlInputMarker({
    required super.coordinates,
    required this.html,
    this.anchor,
    this.minZoom,
    this.maxZoom,
    super.zIndex,
    this.preventMapInteractions,
    super.userData,
    super.additionalData,
  }) : super(type: 'html');

  @override
  Map<String, Object?> toJsMap() => {
    'type': type,
    'coordinates': coordinates,
    'html': html,
    if (anchor != null) 'anchor': anchor,
    if (minZoom != null) 'minZoom': minZoom,
    if (maxZoom != null) 'maxZoom': maxZoom,
    if (zIndex != null) 'zIndex': zIndex,
    if (preventMapInteractions != null) 'preventMapInteractions': preventMapInteractions,
    if (userData != null) 'userData': _jsifyUserData(),
    ...?additionalData,
  };
}
