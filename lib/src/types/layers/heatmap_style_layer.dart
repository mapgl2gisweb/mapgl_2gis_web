// src/types/layers/heatmap_style_layer.dart

part of 'style_layer_base.dart';

/// Mirrors `HeatmapStyleLayer` from `styles.d.ts`.
///
/// Fixes `type: 'heatmap'` and pairs it with [HeatmapStyleProps].
class HeatmapStyleLayer extends StyleLayer<HeatmapStyleProps> with LayerJsonMixin<HeatmapStyleProps> {
  const HeatmapStyleLayer({required super.id, super.filter, super.minzoom, super.maxzoom, super.style})
    : super(type: 'heatmap');
}

/// Style properties for a heatmap layer.
///
/// Mirrors the `style` shape of `HeatmapStyleLayer` from `styles.d.ts`.
///
/// Note: in the JS contract, `color` is always an [Expression] — there is
/// no literal alternative, unlike the other style properties.
class HeatmapStyleProps implements LayerStyleProps {
  /// Color of each pixel depending on the intensity value.
  final Expression? color;

  /// Radius of heatmap points in pixels.
  final StyleValue<double>? radius;

  /// Opacity of the entire heatmap layer.
  final StyleValue<double>? opacity;

  /// Heatmap kernel multiplier.
  final StyleValue<double>? intensity;

  /// How much a single point contributes to the heatmap.
  final StyleValue<double>? weight;

  /// Heatmap texture divider. Higher values yield lower quality and faster
  /// rendering.
  final double? downscale;

  /// Whether the layer objects are displayed on the map.
  final LayerVisibility? visibility;

  const HeatmapStyleProps({
    this.color,
    this.radius,
    this.opacity,
    this.intensity,
    this.weight,
    this.downscale,
    this.visibility,
  });

  @override
  Map<String, Object?> toJsMap() => {
    if (color != null) 'color': color,
    if (radius != null) 'radius': radius!.toJsValue(),
    if (opacity != null) 'opacity': opacity!.toJsValue(),
    if (intensity != null) 'intensity': intensity!.toJsValue(),
    if (weight != null) 'weight': weight!.toJsValue(),
    if (downscale != null) 'downscale': downscale,
    if (visibility != null) 'visibility': visibility!.value,
  };
}
