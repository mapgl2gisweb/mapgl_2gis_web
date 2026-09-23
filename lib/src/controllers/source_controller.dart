// src/controllers/source_controller.dart

import 'dart:async';

import '../../mapgl_2gis_web.dart';


/// Manages the lifecycle of GeoJSON sources on the map.
///
/// This controller is intentionally unaware of style layers — it mirrors
/// [LayerController], which in turn knows nothing about sources. Keeping the
/// two independent makes it easy to reason about who owns what.
///
/// Like [LayerController], every mutating operation is serialized through an
/// internal queue, so the relative order of `add` / `update` / `remove`
/// calls is preserved regardless of how long each one waits for the map.
class SourceController {
  SourceController(this._access);

  final MapControllerAccess _access;
  final Map<String, GeoJsonSource> _sources = {};

  Future<void> _queue = Future<void>.value();

  Future<void> _enqueue(Future<void> Function() action) {
    final result = _queue.then((_) => action());
    _queue = result.catchError((_) {});
    return result;
  }

  /// Registers a new GeoJSON source under [id], waiting for the map to be
  /// ready before touching the JS side.
  Future<void> addGeoJsonSource(String id, GeoJsonSourceOptions options) {
    return _enqueue(() async {
      await _access.whenReady;
      _sources[id] = GeoJsonSourceDartApi.fromOptions(_access.map, options);
    });
  }

  /// Replaces the data of an existing source. No-op if the source is unknown.
  Future<void> updateData(String id, Map<String, Object?> data) {
    return _enqueue(() async {
      final source = _sources[id];
      if (source == null) return;
      await source.setDataFromMap(data);
    });
  }

  GeoJsonSource? get(String id) => _sources[id];

  /// Removes the source with the given [id]. No-op if it does not exist.
  Future<void> remove(String id) {
    return _enqueue(() async {
      _sources.remove(id)?.destroy();
    });
  }

  /// Removes every source registered through this controller.
  Future<void> clear() {
    return _enqueue(() async {
      for (final id in _sources.keys.toList()) {
        _sources.remove(id)?.destroy();
      }
    });
  }
}
