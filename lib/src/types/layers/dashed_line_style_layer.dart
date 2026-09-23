// src/types/layers/dashed_line_style_layer.dart

part of 'style_layer_base.dart';

/// Mirrors `DashedLineStyleLayer` from `styles.d.ts`.
///
/// Fixes `type: 'dashedLine'` and pairs it with [DashedLineStyleProps].
class DashedLineStyleLayer extends StyleLayer<DashedLineStyleProps> with LayerJsonMixin<DashedLineStyleProps> {
  const DashedLineStyleLayer({required super.id, super.filter, super.minzoom, super.maxzoom, super.style})
    : super(type: 'dashedLine');
}

/// Style properties for a dashed line layer.
///
/// Mirrors the `style` shape of `DashedLineStyleLayer` from `styles.d.ts`.
class DashedLineStyleProps implements LayerStyleProps {
  /// Color of line dashes.
  final StyleValue<String>? color;

  /// Line width in pixels.
  final StyleValue<double>? width;

  /// Dash length in pixels.
  final StyleValue<double>? dashLength;

  /// Gap length in pixels.
  final StyleValue<double>? gapLength;

  /// Color of line gaps.
  final StyleValue<String>? gapColor;

  /// Whether the layer objects are displayed on the map.
  final LayerVisibility? visibility;

  const DashedLineStyleProps({this.color, this.width, this.dashLength, this.gapLength, this.gapColor, this.visibility});

  @override
  Map<String, Object?> toJsMap() => {
    if (color != null) 'color': color!.toJsValue(),
    if (width != null) 'width': width!.toJsValue(),
    if (dashLength != null) 'dashLength': dashLength!.toJsValue(),
    if (gapLength != null) 'gapLength': gapLength!.toJsValue(),
    if (gapColor != null) 'gapColor': gapColor!.toJsValue(),
    if (visibility != null) 'visibility': visibility!.value,
  };
}
