// src/types/layers/raster_style_layer.dart

part of 'style_layer_base.dart';

/// Mirrors `RasterStyleLayer` from `styles.d.ts`.
///
/// Fixes `type: 'raster'` and pairs it with [RasterStyleProps].
class RasterStyleLayer extends StyleLayer<RasterStyleProps> with LayerJsonMixin<RasterStyleProps> {
  const RasterStyleLayer({required super.id, super.filter, super.minzoom, super.maxzoom, super.style})
    : super(type: 'raster');
}

/// Style properties for a raster layer.
///
/// Mirrors the `style` shape of `RasterStyleLayer` from `styles.d.ts`.
class RasterStyleProps implements LayerStyleProps {
  /// Image opacity. `0` means fully transparent, `1` means fully filled.
  final StyleValue<double>? opacity;

  /// Whether the layer objects are displayed on the map.
  final LayerVisibility? visibility;

  const RasterStyleProps({this.opacity, this.visibility});

  @override
  Map<String, Object?> toJsMap() => {
    if (opacity != null) 'opacity': opacity!.toJsValue(),
    if (visibility != null) 'visibility': visibility!.value,
  };
}
