// src/types/layers/style_layer_base.dart

import 'expression.dart';
import 'layer_visibility.dart';
import 'style_value.dart';

part 'polygon_style_layer.dart';

part 'line_style_layer.dart';

part 'dashed_line_style_layer.dart';

part 'point_style_layer.dart';

part 'raster_style_layer.dart';

part 'heatmap_style_layer.dart';

/// Contract implemented by every style-properties object.
///
/// Each concrete style layer defines its own `StyleProps` type that knows how
/// to serialize itself into a plain Dart map, ready to be passed to
/// `jsify()`.
abstract interface class LayerStyleProps {
  Map<String, Object?> toJsMap();
}

/// Mirrors `StyleLayerBase` from `styles.d.ts`.
///
/// The JS union `Layer` has many concrete variants, each adding a distinct
/// `type` and a specific `style` shape. The sealed class captures the fields
/// shared by every variant; the concrete Dart subclasses ([PolygonStyleLayer],
/// [LineStyleLayer], and future additions) close the hierarchy.
sealed class StyleLayer<S extends LayerStyleProps> {
  /// Layer identifier. Must be unique across the map.
  final String id;

  /// Layer type — matches the JS `type` discriminator exactly
  /// (`'polygon'`, `'line'`, …).
  final String type;

  /// Filter that selects which objects the layer applies to. Mirrors
  /// `filter?: boolean | Expression` in the JS contract.
  final StyleValue<bool>? filter;

  /// Minimum map zoom level at which the layer is rendered.
  final double? minzoom;

  /// Maximum map zoom level at which the layer is rendered.
  final double? maxzoom;

  /// Layer-type-specific style properties.
  final S? style;

  const StyleLayer({required this.id, required this.type, this.filter, this.minzoom, this.maxzoom, this.style});

  /// Serialization contract, implemented through [LayerJsonMixin] in every
  /// concrete variant ([PolygonStyleLayer], [LineStyleLayer], …).
  Map<String, Object?> toJsMap();
}

/// Shared JSON serialization for any `StyleLayer<S>`.
///
/// Keeping this in a mixin avoids repeating the same map-building code in
/// every concrete layer type.
mixin LayerJsonMixin<S extends LayerStyleProps> on StyleLayer<S> {
  @override
  Map<String, Object?> toJsMap() => {
    'id': id,
    'type': type,
    if (filter != null) 'filter': filter!.toJsValue(),
    if (minzoom != null) 'minzoom': minzoom,
    if (maxzoom != null) 'maxzoom': maxzoom,
    if (style != null) 'style': style!.toJsMap(),
  };
}
