// src/sources/geojson_source_extensions.dart

import 'dart:js_interop';

import '../map/mapgl_map_bindings.dart';
import 'geojson_source_options.dart';

/// Dart-friendly layer on top of the raw [GeoJsonSource] binding.
///
/// Provides:
///  * a factory that accepts a typed [GeoJsonSourceOptions];
///  * `Map`-based convenience wrappers for `setData` / `setAttributes`,
///    hiding the manual `jsify()` step.
///
/// The binding itself stays in `mapgl_map_bindings.dart` — this file only
/// adds ergonomics, never a second extension type for the same JS class.
extension GeoJsonSourceDartApi on GeoJsonSource {
  /// Creates a [GeoJsonSource] from a typed [GeoJsonSourceOptions].
  static GeoJsonSource fromOptions(
      MapglMapNew map,
      GeoJsonSourceOptions options,
      ) {
    final jsOptions = options.toJsMap().jsify();
    if (jsOptions is! JSObject) {
      throw StateError(
        'GeoJsonSourceOptions.toJsMap() produced an unexpected JS value: '
            'expected a JS object, got ${jsOptions.runtimeType}',
      );
    }
    return GeoJsonSource(map, jsOptions);
  }

  /// Replaces the source data with a plain Dart [Map], awaiting the
  /// JS-side promise.
  Future<void> setDataFromMap(Map<String, Object?> data) async {
    final jsData = data.jsify();
    if (jsData is! JSObject) {
      throw StateError(
        'setDataFromMap expected a JSON-like Map, got ${jsData.runtimeType}',
      );
    }
    await setData(jsData).toDart;
  }

  /// Returns the source attributes as a typed Dart map.
  SourceAttributes getAttributesMap() =>
      (getAttributes().dartify() as Map).cast<String, Object>();

  /// Replaces the source attributes with a typed Dart map.
  GeoJsonSource setAttributesFromMap(SourceAttributes attributes) {
    final jsAttributes = attributes.jsify();
    if (jsAttributes is! JSObject) {
      throw StateError(
        'setAttributesFromMap expected a JSON-like Map, got ${jsAttributes.runtimeType}',
      );
    }
    return setAttributes(jsAttributes);
  }
}