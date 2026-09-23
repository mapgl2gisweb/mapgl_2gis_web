// src/common/label_options.dart

import 'label_image.dart';

/// Common label configuration used by markers and other label-bearing
/// objects.
///
/// Mirrors the `MarkerLabelOptions` shape from the MapGL type definitions.
/// The JS contract is shared between `mapgl.Marker` and the clusterer's
/// input markers, so this Dart type is shared as well.
///
/// Note: `color` and `haloColor` in the JS contract are `string | Expression`.
/// This wrapper currently models them as plain strings; expression support
/// can be added if the need arises.
class LabelOptions {
  /// Label text.
  final String text;

  /// Background image for the label.
  final LabelImage? image;

  /// Minimum display styleZoom of the label.
  final double? minZoom;

  /// Maximum display styleZoom of the label.
  final double? maxZoom;

  /// Text color in `#rrggbb` or `#rrggbbaa` format.
  final String? color;

  /// Font family used to render the label text. When omitted, the JS
  /// library applies its own default font.
  final String? font;

  /// Text size.
  final double? fontSize;

  /// Adds a background behind each letter.
  final double? haloRadius;

  /// Background color of letters (used with [haloRadius]).
  final String? haloColor;

  /// Space between each letter.
  final double? letterSpacing;

  /// Line height for multiline labels.
  final double? lineHeight;

  /// Offset of the text box from its [relativeAnchor]. Positive values
  /// indicate right and down; negative values indicate left and up.
  final List<double>? offset;

  /// Coordinates (from 0 to 1 in each dimension) of the text box "tip"
  /// relative to its top-left corner. `[0, 0]` is the top-left corner,
  /// `[0.5, 0.5]` is the center, `[1, 1]` is the bottom-right corner.
  final List<double>? relativeAnchor;

  /// Draw order.
  final int? zIndex;

  const LabelOptions({
    required this.text,
    this.image,
    this.minZoom,
    this.maxZoom,
    this.color,
    this.font,
    this.fontSize,
    this.haloRadius,
    this.haloColor,
    this.letterSpacing,
    this.lineHeight,
    this.offset,
    this.relativeAnchor,
    this.zIndex,
  });

  Map<String, Object?> toJsMap() => {
    'text': text,
    if (image != null) 'image': image!.toJsMap(),
    if (minZoom != null) 'minZoom': minZoom,
    if (maxZoom != null) 'maxZoom': maxZoom,
    if (color != null) 'color': color,
    if (font != null) 'font': font,
    if (fontSize != null) 'fontSize': fontSize,
    if (haloRadius != null) 'haloRadius': haloRadius,
    if (haloColor != null) 'haloColor': haloColor,
    if (letterSpacing != null) 'letterSpacing': letterSpacing,
    if (lineHeight != null) 'lineHeight': lineHeight,
    if (offset != null) 'offset': offset,
    if (relativeAnchor != null) 'relativeAnchor': relativeAnchor,
    if (zIndex != null) 'zIndex': zIndex,
  };
}
