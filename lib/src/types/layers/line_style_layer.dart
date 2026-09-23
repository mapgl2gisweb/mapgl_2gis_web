// src/types/layers/line_style_layer.dart

part of 'style_layer_base.dart';

/// Mirrors `LineStyleLayer` from `styles.d.ts`.
///
/// The JS variant fixes `type: 'line'` and pairs it with the
/// [LineStyleProps] shape.
class LineStyleLayer extends StyleLayer<LineStyleProps> with LayerJsonMixin<LineStyleProps> {
  const LineStyleLayer({required super.id, super.filter, super.minzoom, super.maxzoom, super.style})
    : super(type: 'line');
}

/// Style properties for a line layer.
///
/// Mirrors the `style` shape of `LineStyleLayer` from `styles.d.ts`.
class LineStyleProps implements LayerStyleProps {
  /// Line color, `#rrggbb` or `#rrggbbaa`, or an expression.
  final StyleValue<String>? color;

  /// Line width in pixels, or an expression.
  final StyleValue<double>? width;

  /// Line pattern. In the JS contract this is always an [Expression] — there
  /// is no literal alternative, unlike `color` and `width`.
  final Expression? pattern;

  /// Whether the layer objects are displayed on the map.
  final LayerVisibility? visibility;

  const LineStyleProps({this.color, this.width, this.pattern, this.visibility});

  @override
  Map<String, Object?> toJsMap() => {
    if (color != null) 'color': color!.toJsValue(),
    if (width != null) 'width': width!.toJsValue(),
    if (pattern != null) 'pattern': pattern,
    if (visibility != null) 'visibility': visibility!.value,
  };
}
