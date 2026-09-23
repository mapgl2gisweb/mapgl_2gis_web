// src/clusterer/cluster_style.dart

import 'dart:js_interop';

import '../common/label_image.dart';
import 'clusterer_bindings.dart';

/// Typed Dart representation of `WebglClusterStyle` and `HtmlClusterStyle`
/// from `@2gis/mapgl-clusterer`.
///
/// This is a faithful mirror of the library's JS contract, not an
/// application-specific design decision. Verified against
/// `types/types.d.ts` of `@2gis/mapgl-clusterer` 2.5.2.
///
/// Every field is optional: fields that are not set are omitted from the
/// resulting JS object, and the library falls back to its own defaults.
sealed class ClusterStyle {
  final String type;
  final int? zIndex;
  final List<double>? anchor;

  const ClusterStyle({required this.type, this.zIndex, this.anchor});

  /// Factory for a WebGL-style cluster.
  factory ClusterStyle.webgl({
    String? icon,
    List<double>? size,
    List<double>? anchor,
    String? hoverIcon,
    List<double>? hoverSize,
    List<double>? hoverAnchor,
    String? labelText,
    LabelImage? labelImage,
    String? labelColor,
    double? labelFontSize,
    double? labelHaloRadius,
    String? labelHaloColor,
    double? labelLetterSpacing,
    List<double>? labelOffset,
    List<double>? labelRelativeAnchor,
    int? zIndex,
  }) {
    return _WebglClusterStyle(
      icon: icon,
      size: size,
      anchor: anchor,
      hoverIcon: hoverIcon,
      hoverSize: hoverSize,
      hoverAnchor: hoverAnchor,
      labelText: labelText,
      labelImage: labelImage,
      labelColor: labelColor,
      labelFontSize: labelFontSize,
      labelHaloRadius: labelHaloRadius,
      labelHaloColor: labelHaloColor,
      labelLetterSpacing: labelLetterSpacing,
      labelOffset: labelOffset,
      labelRelativeAnchor: labelRelativeAnchor,
      zIndex: zIndex,
    );
  }

  /// Factory for an HTML-style cluster.
  factory ClusterStyle.html({
    required String html,
    List<double>? anchor,
    double? minZoom,
    double? maxZoom,
    int? zIndex,
    bool? preventMapInteractions,
  }) {
    return _HtmlClusterStyle(
      html: html,
      anchor: anchor,
      minZoom: minZoom,
      maxZoom: maxZoom,
      zIndex: zIndex,
      preventMapInteractions: preventMapInteractions,
    );
  }

  /// Serializes this style into a plain map, ready to be passed to `jsify()`.
  Map<String, Object?> toJsMap();
}

/// WebGL-style cluster implementation.
class _WebglClusterStyle extends ClusterStyle {
  final String? icon;
  final List<double>? size;
  final String? hoverIcon;
  final List<double>? hoverSize;
  final List<double>? hoverAnchor;
  final String? labelText;
  final LabelImage? labelImage;
  final String? labelColor;
  final double? labelFontSize;
  final double? labelHaloRadius;
  final String? labelHaloColor;
  final double? labelLetterSpacing;
  final List<double>? labelOffset;
  final List<double>? labelRelativeAnchor;

  const _WebglClusterStyle({
    this.icon,
    this.size,
    List<double>? anchor,
    this.hoverIcon,
    this.hoverSize,
    this.hoverAnchor,
    this.labelText,
    this.labelImage,
    this.labelColor,
    this.labelFontSize,
    this.labelHaloRadius,
    this.labelHaloColor,
    this.labelLetterSpacing,
    this.labelOffset,
    this.labelRelativeAnchor,
    int? zIndex,
  }) : super(type: 'webgl', zIndex: zIndex, anchor: anchor);

  @override
  Map<String, Object?> toJsMap() => {
    'type': type,
    if (icon != null) 'icon': icon,
    if (size != null) 'size': size,
    if (anchor != null) 'anchor': anchor,
    if (hoverIcon != null) 'hoverIcon': hoverIcon,
    if (hoverSize != null) 'hoverSize': hoverSize,
    if (hoverAnchor != null) 'hoverAnchor': hoverAnchor,
    if (labelText != null) 'labelText': labelText,
    if (labelImage != null) 'labelImage': labelImage!.toJsMap(),
    if (labelColor != null) 'labelColor': labelColor,
    if (labelFontSize != null) 'labelFontSize': labelFontSize,
    if (labelHaloRadius != null) 'labelHaloRadius': labelHaloRadius,
    if (labelHaloColor != null) 'labelHaloColor': labelHaloColor,
    if (labelLetterSpacing != null) 'labelLetterSpacing': labelLetterSpacing,
    if (labelOffset != null) 'labelOffset': labelOffset,
    if (labelRelativeAnchor != null) 'labelRelativeAnchor': labelRelativeAnchor,
    if (zIndex != null) 'zIndex': zIndex,
  };
}

/// HTML-style cluster implementation.
class _HtmlClusterStyle extends ClusterStyle {
  final String html;
  final double? minZoom;
  final double? maxZoom;
  final bool? preventMapInteractions;

  const _HtmlClusterStyle({
    required this.html,
    List<double>? anchor,
    this.minZoom,
    this.maxZoom,
    int? zIndex,
    this.preventMapInteractions,
  }) : super(type: 'html', zIndex: zIndex, anchor: anchor);

  @override
  Map<String, Object?> toJsMap() => {
    'type': type,
    'html': html,
    if (anchor != null) 'anchor': anchor,
    if (minZoom != null) 'minZoom': minZoom,
    if (maxZoom != null) 'maxZoom': maxZoom,
    if (zIndex != null) 'zIndex': zIndex,
    if (preventMapInteractions != null) 'preventMapInteractions': preventMapInteractions,
  };
}

/// Wraps a Dart `(pointCount, target) => ClusterStyle` builder into a JS
/// function of the shape `(pointCount, target) => styleObject`, which is
/// exactly what the MapGL Clusterer expects for its `clusterStyle` option.
JSFunction buildClusterStyleFunction<T>(
  ClusterStyle Function(int pointsCount, ClustererTarget<T> target) styleBuilder,
) {
  return ((JSNumber pointsCount, JSObject target) {
    final count = pointsCount.toDartInt;
    final typedTarget = target as ClustererTarget<T>;
    return styleBuilder(count, typedTarget).toJsMap().jsify();
  }).toJS;
}
