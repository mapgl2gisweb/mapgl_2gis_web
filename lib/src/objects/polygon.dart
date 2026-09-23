// src/objects/polygon.dart

import 'dart:js_interop';

import '../map/mapgl_map_bindings.dart';
import 'dynamic_object_events.dart';

/// Caches JS handlers per Dart callback, keyed by the event type, so that
/// [Polygon.offEvent] can find the exact JS function that was previously
/// attached.
final Expando<Map<DynamicObjectEventType, JSFunction>> _polygonEventHandlers =
    Expando<Map<DynamicObjectEventType, JSFunction>>('polygon.eventHandlers');

/// Mirrors `PolygonOptions` from the MapGL type definitions.
///
/// `TierOption` is an empty marker interface in the `.d.ts` — it adds no
/// fields, so it is intentionally not modelled here.
class PolygonOptions {
  /// `[outerEdges, cropEdges1, cropEdges2, ...]` — each ring is closed
  /// (the last point equals the first). The first ring is mandatory.
  ///
  /// Ring order matches the JS contract: the outer boundary first, then any
  /// number of holes to crop out of it. `outerEdges` and every `cropEdgesN`
  /// must not touch or intersect each other.
  final List<List<List<double>>> coordinates;

  final int? zIndex;
  final double? minZoom;
  final double? maxZoom;
  final String? color;
  final String? strokeColor;
  final double? strokeWidth;
  final bool? interactive;
  final Object? userData;

  const PolygonOptions({
    required this.coordinates,
    this.zIndex,
    this.minZoom,
    this.maxZoom,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.interactive,
    this.userData,
  });

  Map<String, Object?> toJsMap() => {
    'coordinates': coordinates,
    if (zIndex != null) 'zIndex': zIndex,
    if (minZoom != null) 'minZoom': minZoom,
    if (maxZoom != null) 'maxZoom': maxZoom,
    if (color != null) 'color': color,
    if (strokeColor != null) 'strokeColor': strokeColor,
    if (strokeWidth != null) 'strokeWidth': strokeWidth,
    if (interactive != null) 'interactive': interactive,
    if (userData != null) 'userData': userData,
  };
}

/// Raw binding for the `mapgl.Polygon` class.
///
/// `Polygon` extends `Evented<DynamicObjectEventTable<Polygon>>` on the JS
/// side; only the constructor, `destroy`, and the event plumbing are
/// mirrored here. The `userData` field of the underlying JS object is
/// populated from [PolygonOptions.userData].
@JS('mapgl.Polygon')
extension type Polygon._(JSObject _) implements JSObject {
  external factory Polygon._internal(MapglMapNew map, JSObject options);

  factory Polygon(MapglMapNew map, PolygonOptions options) =>
      Polygon._internal(map, options.toJsMap().jsify() as JSObject);

  @JS('destroy')
  external void destroy();

  @JS('on')
  external void _on(JSString event, JSFunction handler);

  @JS('off')
  external void _off(JSString event, JSFunction handler);

  /// Registers a typed handler for a dynamic-object [type].
  ///
  /// The JS wrapper is cached against [callback], so a matching [offEvent]
  /// call detaches exactly this listener.
  void onEvent(DynamicObjectEventType type, void Function(DynamicObjectPointerEvent<Polygon> event) callback) {
    final jsHandler = ((DynamicObjectPointerEvent<Polygon> ev) => callback(ev)).toJS;
    (_polygonEventHandlers[callback] ??= <DynamicObjectEventType, JSFunction>{})[type] = jsHandler;
    _on(type.value.toJS, jsHandler);
  }

  /// Detaches the handler previously registered by [onEvent] for the same
  /// [callback] and [type]. No-op if no matching listener exists.
  void offEvent(DynamicObjectEventType type, void Function(DynamicObjectPointerEvent<Polygon> event) callback) {
    final jsHandler = _polygonEventHandlers[callback]?[type];
    if (jsHandler == null) return;
    _off(type.value.toJS, jsHandler);
  }
}
