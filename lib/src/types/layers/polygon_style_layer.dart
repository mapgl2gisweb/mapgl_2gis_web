// src/types/layers/polygon_style_layer.dart

part of 'style_layer_base.dart';

/// Mirrors `PolygonStyleLayer` from `styles.d.ts`.
///
/// The JS variant fixes `type: 'polygon'` and pairs it with the
/// [PolygonStyleProps] shape.
class PolygonStyleLayer extends StyleLayer<PolygonStyleProps>
    with LayerJsonMixin<PolygonStyleProps> {
  const PolygonStyleLayer({
    required super.id,
    super.filter,
    super.minzoom,
    super.maxzoom,
    super.style,
  }) : super(type: 'polygon');
}

/// Style properties for a polygon layer.
///
/// Mirrors the `style` shape of `PolygonStyleLayer` from `styles.d.ts`.
/// Every field is optional; omitted fields are not serialized and the JS
/// library applies its own defaults.
class PolygonStyleProps implements LayerStyleProps {
  /// Fill color, `#rrggbb` or `#rrggbbaa`, or an expression.
  final StyleValue<String>? color;

  /// Stroke color, `#rrggbb` or `#rrggbbaa`, or an expression.
  final StyleValue<String>? strokeColor;

  /// Stroke width in pixels, or an expression.
  final StyleValue<double>? strokeWidth;

  /// Whether the layer objects are displayed on the map.
  final LayerVisibility? visibility;

  const PolygonStyleProps({
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.visibility,
  });

  @override
  Map<String, Object?> toJsMap() => {
    if (color != null) 'color': color!.toJsValue(),
    if (strokeColor != null) 'strokeColor': strokeColor!.toJsValue(),
    if (strokeWidth != null) 'strokeWidth': strokeWidth!.toJsValue(),
    if (visibility != null) 'visibility': visibility!.value,
  };
}