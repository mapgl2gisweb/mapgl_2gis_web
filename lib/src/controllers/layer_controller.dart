// src/controllers/layer_controller.dart

import 'dart:async';
import 'dart:js_interop';

import '../../mapgl_2gis_web.dart';

/// Manages style layers on top of the map.
///
/// The controller owns no data — it only translates a [StyleLayer] into the
/// corresponding map call and tracks which layer ids have already been added,
/// so that [removeLayer] and [hasLayer] stay safe to call.
///
/// All mutating operations are serialized through an internal queue: calls
/// are executed strictly in the order they were issued, even if some of them
/// have to wait for the map to become ready. This removes the race between a
/// fast `addLayer` followed by a `removeLayer` and a slow `whenReady`.
class LayerController {
  LayerController(this._access);

  final MapControllerAccess _access;
  final Set<String> _addedLayerIds = {};

  /// Tail of the operation queue. Every public mutator appends itself here.
  Future<void> _queue = Future<void>.value();

  /// Serializes [action] behind every previously enqueued operation.
  ///
  /// Errors are swallowed at the queue level so that one failed operation
  /// cannot poison the whole chain; callers awaiting the returned future
  /// still receive the original error.
  Future<void> _enqueue(Future<void> Function() action) {
    final result = _queue.then((_) => action());
    _queue = result.catchError((_) {
      // Keep the queue alive; individual callers observe the error through
      // the returned future.
    });
    return result;
  }

  /// Adds [layer] to the map, optionally before [beforeId].
  ///
  /// Waits for the map to be ready before touching the JS side. The call is
  /// enqueued behind any pending operations on this controller.
  Future<void> addLayer(StyleLayer layer, {String? beforeId}) {
    return _enqueue(() async {
      await _access.whenReady;
      final jsLayer = layer.toJsMap().jsify() as JSObject;
      _access.map.addLayer(jsLayer, beforeId);
      _addedLayerIds.add(layer.id);
    });
  }

  /// Removes the layer with the given [layerId]. No-op if it was never added.
  Future<void> removeLayer(String layerId) {
    return _enqueue(() async {
      await _access.whenReady;
      if (!_addedLayerIds.contains(layerId)) return;
      _access.map.removeLayer(layerId);
      _addedLayerIds.remove(layerId);
    });
  }

  /// Returns `true` if a layer with [layerId] has been added and not yet
  /// removed through this controller.
  bool hasLayer(String layerId) => _addedLayerIds.contains(layerId);

  /// Removes every layer previously added through this controller.
  Future<void> clear() {
    return _enqueue(() async {
      await _access.whenReady;
      for (final id in _addedLayerIds.toList()) {
        _access.map.removeLayer(id);
      }
      _addedLayerIds.clear();
    });
  }
}