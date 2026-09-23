// src/sources/geojson_source_options.dart

/// Mirrors `SourceAttributes` from the MapGL type definitions:
/// `{ [key: string]: number | string | boolean }`.
///
/// The value type is expressed as `Object` at the Dart level; the
/// number/string/boolean restriction is enforced by convention, not by the
/// compiler. Callers are expected to pass only JSON-safe primitives.
typedef SourceAttributes = Map<String, Object>;

/// Mirrors `GeoJsonSourceOptions` from the MapGL type definitions.
///
/// Every field except [data] is optional; omitted fields are not serialized
/// and the JS library applies its own defaults.
class GeoJsonSourceOptions {
  /// A GeoJSON `FeatureCollection` or `Feature`, represented as a plain
  /// Dart map. Dedicated GeoJSON types are intentionally not modelled here —
  /// the JS API accepts arbitrary JSON-like data.
  final Map<String, Object?> data;

  final SourceAttributes? attributes;
  final double? maxZoom;
  final int? dimensions;
  final String? modelsPath;
  final String? promoteId;
  final String? idScope;
  final double? tolerance;

  const GeoJsonSourceOptions({
    required this.data,
    this.attributes,
    this.maxZoom,
    this.dimensions,
    this.modelsPath,
    this.promoteId,
    this.idScope,
    this.tolerance,
  });

  Map<String, Object?> toJsMap() => {
    'data': data,
    if (attributes != null) 'attributes': attributes,
    if (maxZoom != null) 'maxZoom': maxZoom,
    if (dimensions != null) 'dimensions': dimensions,
    if (modelsPath != null) 'modelsPath': modelsPath,
    if (promoteId != null) 'promoteId': promoteId,
    if (idScope != null) 'idScope': idScope,
    if (tolerance != null) 'tolerance': tolerance,
  };
}