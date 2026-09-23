// src/clusterer/clusterer_bindings.dart

import 'dart:js_interop';

import '../map/mapgl_map_bindings.dart';
import 'clusterer_options.dart';
import 'clusterer_target.dart';
import 'input_marker.dart';

export 'clusterer_target.dart';

/// Pointer event types emitted by the MapGL Clusterer.
///
/// The string values match the underlying JS event names exactly.
enum ClustererEventType {
  click('click'),
  mousemove('mousemove'),
  mouseover('mouseover'),
  mouseout('mouseout'),
  mousedown('mousedown'),
  mouseup('mouseup'),
  touchstart('touchstart'),
  touchend('touchend');

  final String value;

  const ClustererEventType(this.value);
}

/// Caches the JS handler that was registered for each Dart callback, so that
/// [MapglClustererNew.offEvent] can find the exact JS function that was
/// previously attached.
///
/// The cache is keyed by the Dart callback and holds a weak reference to it:
/// if the callback is garbage-collected, the cached JS handler becomes
/// collectable as well, so there is no leak for listeners that are never
/// explicitly detached.
///
/// Note: a single Dart callback should not be shared between multiple
/// clusterer instances — the cache keeps only one JS handler per callback.
final Expando<JSFunction> _clustererEventHandlers = Expando<JSFunction>('clusterer.eventHandlers');

/// Raw binding for the `mapgl.Clusterer` class.
///
/// Thin wrapper over the JS API — all business logic (marker payloads,
/// styles) lives in the accompanying Dart models.
@JS('mapgl.Clusterer')
extension type MapglClustererNew<T>._(JSObject _) implements JSObject {
  @JS()
  external factory MapglClustererNew._internal(MapglMapNew map, [JSObject? options]);

  factory MapglClustererNew(MapglMapNew map, [ClustererOptions<T>? options]) {
    JSObject? jsOptions;
    if (options != null) {
      final jsified = options.toJsMap().jsify();
      if (jsified is! JSObject) {
        throw StateError(
          'ClustererOptions.toJsMap() produced an unexpected JS value: '
          'expected a JS object, got ${jsified.runtimeType}',
        );
      }
      jsOptions = jsified;
    }
    return MapglClustererNew._internal(map, jsOptions);
  }

  @JS('load')
  external void _load(JSArray<JSObject> input);

  /// Loads (or replaces) the marker set. The underlying JS API has no
  /// incremental update — every call is a full reload.
  void load(List<InputMarker<T>> input) {
    final jsList = input.map((m) => m.toJsMap().jsify() as JSObject).toList().toJS;
    _load(jsList);
  }

  external void destroy();

  @JS('setClusterStyle')
  external void _setClusterStyle(JSNumber clusterId, JSAny clusterStyleOrFn);

  @JS('resetClusterStyle')
  external void _resetClusterStyle(JSNumber clusterId);

  /// Overrides the style of a single cluster. [style] may be either a fixed
  /// style or a per-cluster builder — see [ClustererStyleContainer].
  void setClusterStyle(int clusterId, ClustererStyleContainer<T> style) {
    _setClusterStyle(clusterId.toJS, style.toJsValue());
  }

  /// Restores the default style for a cluster previously overridden with
  /// [setClusterStyle].
  void resetClusterStyle(int clusterId) {
    _resetClusterStyle(clusterId.toJS);
  }

  @JS('getClusterExpansionZoom')
  external JSNumber _getClusterExpansionZoom(JSNumber clusterId);

  /// Returns the zoom level at which the given cluster would fully expand
  /// into its children.
  int getClusterExpansionZoom(int clusterId) {
    return _getClusterExpansionZoom(clusterId.toJS).toDartInt;
  }

  external void on(JSString event, JSFunction handler);

  external void off(JSString event, JSFunction handler);

  external void once(JSString event, JSFunction handler);

  external void emit(JSString event, [JSObject? data]);

  /// Registers a typed handler for the given [eventType].
  ///
  /// The JS-side wrapper is cached against [callback], so a subsequent call
  /// to [offEvent] with the same callback will detach exactly this listener.
  void onEvent(ClustererEventType eventType, void Function(ClustererPointerEvent<T> event) callback) {
    final jsHandler = ((ClustererPointerEvent<T> ev) => callback(ev)).toJS;
    _clustererEventHandlers[callback] = jsHandler;
    on(eventType.value.toJS, jsHandler);
  }

  /// Detaches the handler previously registered by [onEvent] for the same
  /// [callback]. No-op if no matching listener was found.
  void offEvent(ClustererEventType eventType, void Function(ClustererPointerEvent<T> event) callback) {
    final jsHandler = _clustererEventHandlers[callback];
    if (jsHandler == null) return;
    off(eventType.value.toJS, jsHandler);
  }
}
