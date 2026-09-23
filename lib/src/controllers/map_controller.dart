// src/controllers/map_controller.dart

import 'dart:async';
import 'dart:js_interop';

import '../core/mapgl_logging.dart';
import '../map/mapgl_map_bindings.dart';
import '../types/lng_lat_bounds_class.dart';
import 'map_controller_access.dart';
import '../map/map_events.dart';

/// Controls direct map actions: camera, options, and lifecycle.
///
/// The controller is intentionally unaware of layers, markers, or any other
/// content placed on top of the map — those are handled by specialised
/// controllers operating on [MapControllerAccess].
class MapController implements MapControllerAccess {
  MapController._(this._map);

  final MapglMapNew _map;

  final Completer<void> _readyCompleter = Completer<void>();
  bool _isReady = false;
  bool _isDisposed = false;

  /// Reference to the JS `idle` handler, kept so it can be detached in
  /// [dispose]. Without it, a late `idle` event could attempt to complete an
  /// already-finished completer and throw.
  JSFunction? _idleHandler;

  factory MapController.create({required JSAny container, required JSObject options}) {
    final map = MapglMapNew(container, options);
    final controller = MapController._(map);
    controller._bindReadySignal();
    return controller;
  }

  void _bindReadySignal() {
    logMapgl('MapController: attaching once("idle")');

    final handler = (() {
      logMapgl('MapController: "idle" fired');
      if (_isDisposed) return;
      _isReady = true;
      if (!_readyCompleter.isCompleted) {
        _readyCompleter.complete();
      }
    }).toJS;

    _idleHandler = handler;
    _map.once('idle'.toJS, handler);
  }

  /// Throws if the controller has already been disposed.
  ///
  /// Uses [StateError] rather than `assert`, since asserts are stripped in
  /// release builds.
  void _assertAlive() {
    if (_isDisposed) {
      throw StateError('MapController used after dispose()');
    }
  }

  @override
  MapglMapNew get map {
    _assertAlive();
    return _map;
  }

  @override
  bool get isReady => _isReady && !_isDisposed;

  @override
  Future<void> get whenReady => _readyCompleter.future;

  // --- Camera ---

  void invalidateSize() {
    _assertAlive();
    _map.invalidateSize();
  }

  void setCenter(List<double> center) {
    _assertAlive();
    _map.setCenter(center);
  }

  List<double> getCenter() {
    _assertAlive();
    return _map.getCenter();
  }

  void setZoom(double zoom) {
    _assertAlive();
    _map.setZoom(zoom);
  }

  double getZoom() {
    _assertAlive();
    return _map.getZoom();
  }

  void setRotation(double rotation) {
    _assertAlive();
    _map.setRotation(rotation);
  }

  void setPitch(double pitch) {
    _assertAlive();
    _map.setPitch(pitch);
  }

  void fitBounds(LngLatBoundsClass bounds, [JSObject? options]) {
    _assertAlive();
    _map.fitBounds(bounds, options);
  }

  LngLatBoundsClass getBounds([JSObject? options]) {
    _assertAlive();
    return _map.getBounds(options);
  }

  List<double> unproject(List<double> point) {
    _assertAlive();
    return _map.unproject(point);
  }

  // --- Map options ---

  void setLanguage(String lang) {
    _assertAlive();
    _map.setLanguage(lang);
  }

  void showTraffic() {
    _assertAlive();
    _map.showTraffic();
  }

  void hideTraffic() {
    _assertAlive();
    _map.hideTraffic();
  }

  bool isTrafficOn() {
    _assertAlive();
    return _map.isTrafficOn();
  }

  Future<String> setStyleById(String styleId) {
    _assertAlive();
    return _map.setStyleById(styleId);
  }

  // --- Events ---

  /// Registers a typed handler for a pointer-related map event.
  void onPointerEvent(MapEventType eventType, void Function(MapPointerEvent event) callback) {
    _assertAlive();
    _map.onPointerEvent(eventType, callback);
  }

  void offPointerEvent(MapEventType eventType, void Function(MapPointerEvent event) callback) {
    _assertAlive();
    _map.offPointerEvent(eventType, callback);
  }

  /// Registers a typed handler for a non-pointer map event.
  void onMapEvent(MapEventType eventType, void Function(MapEvent event) callback) {
    _assertAlive();
    _map.onMapEvent(eventType, callback);
  }

  void offMapEvent(MapEventType eventType, void Function(MapEvent event) callback) {
    _assertAlive();
    _map.offMapEvent(eventType, callback);
  }

  // --- Lifecycle ---

  /// Destroys the underlying map and releases resources.
  ///
  /// Safe to call more than once; subsequent calls are no-ops. If the map
  /// was never ready, [whenReady] completes with a [StateError].
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    if (!_isReady && _idleHandler != null) {
      try {
        _map.off('idle'.toJS, _idleHandler!);
      } catch (e) {
        logMapgl('off("idle") failed: $e');
      }
      _idleHandler = null;
    }

    if (!_readyCompleter.isCompleted) {
      _readyCompleter.completeError(StateError('MapController disposed before ready'), StackTrace.current);
    }

    _map.destroy();
  }
}
