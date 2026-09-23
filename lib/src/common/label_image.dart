// src/common/label_image.dart

/// Image configuration used by label styles.
///
/// Mirrors the corresponding shape in the MapGL type definitions. Only
/// [url] and [size] are required; the rest control how the image is
/// stretched, scaled, and padded when rendered as a label.
class LabelImage {
  final String url;

  /// `[width, height]` — image size in logical pixels.
  final List<double> size;

  final List<List<double>>? stretchX;
  final List<List<double>>? stretchY;
  final double? pixelRatio;

  /// `[top, right, bottom, left]`, same order as in CSS.
  /// Defaults to `[0, 0, 0, 0]`.
  final List<double>? padding;

  LabelImage({
    required this.url,
    required this.size,
    this.stretchX,
    this.stretchY,
    this.pixelRatio,
    this.padding,
  }) : assert(size.length == 2, 'LabelImage.size must be [width, height]'),
        assert(
        padding == null || padding.length == 4,
        'LabelImage.padding must be [top, right, bottom, left]',
        );

  Map<String, Object?> toJsMap() => {
    'url': url,
    'size': size,
    if (stretchX != null) 'stretchX': stretchX,
    if (stretchY != null) 'stretchY': stretchY,
    if (pixelRatio != null) 'pixelRatio': pixelRatio,
    if (padding != null) 'padding': padding,
  };
}