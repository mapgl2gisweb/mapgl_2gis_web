// src/objects/polyline.dart

import 'dart:js_interop';

import '../map/mapgl_map_bindings.dart';
import '../types/layers/style_value.dart';
import 'dynamic_object_events.dart';

/// Caches JS handlers per Dart callback, keyed by the event type.
final Expando<Map<DynamicObjectEventType, JSFunction>> _polylineEventHandlers =
    Expando<Map<DynamicObjectEventType, JSFunction>>('polyline.eventHandlers');

/// Defines the polyline rendering mode.
///
/// - `mode3d` uses the depth buffer.
/// - `mode2d` draws the line without depth.
enum PolylineRenderingMode {
  mode2d('2d'),
  mode3d('3d');

  final String value;

  const PolylineRenderingMode(this.value);
}

/// Mirrors `PolylineOptions` from the MapGL type definitions.
///
/// Deprecated fields (`zIndex2`/`zIndex3`, `width2`/`width3`,
/// `color2`/`color3`) are intentionally omitted — they are marked for
/// removal in the next major release.
///
/// `TierOption` is an empty marker interface in the `.d.ts` — it adds no
/// fields, so it is intentionally not modelled here.
class PolylineOptions {
  /// Coordinates of the polyline: `[firstPoint, secondPoint, ...]`.
  /// Each point is a `[longitude, latitude]` pair.
  final List<List<double>> coordinates;

  /// Draw order of the first line.
  final int? zIndex;

  /// Line width in pixels.
  final StyleValue<double>? width;

  /// Line color in `#rrggbb` or `#rrggbbaa` format.
  final String? color;

  /// Length of the gap in pixels. Defaults to the dash length when omitted.
  final StyleValue<double>? gapLength;

  /// Gap color in `#rrggbb` or `#rrggbbaa` format.
  final String? gapColor;

  /// Length of the dash in pixels. When omitted, a solid line is drawn.
  final StyleValue<double>? dashLength;

  final double? minZoom;
  final double? maxZoom;
  final bool? interactive;
  final Object? userData;

  /// Rendering mode. Defaults to `mode2d`.
  final PolylineRenderingMode? renderingMode;

  /// Color of a line section hidden by other objects in `mode3d`.
  final String? hiddenPartColor;

  /// Gap color of a line section hidden by other objects in `mode3d`.
  final String? hiddenPartGapColor;

  const PolylineOptions({
    required this.coordinates,
    this.zIndex,
    this.width,
    this.color,
    this.gapLength,
    this.gapColor,
    this.dashLength,
    this.minZoom,
    this.maxZoom,
    this.interactive,
    this.userData,
    this.renderingMode,
    this.hiddenPartColor,
    this.hiddenPartGapColor,
  });

  Map<String, Object?> toJsMap() => {
    'coordinates': coordinates,
    if (zIndex != null) 'zIndex': zIndex,
    if (width != null) 'width': width!.toJsValue(),
    if (color != null) 'color': color,
    if (gapLength != null) 'gapLength': gapLength!.toJsValue(),
    if (gapColor != null) 'gapColor': gapColor,
    if (dashLength != null) 'dashLength': dashLength!.toJsValue(),
    if (minZoom != null) 'minZoom': minZoom,
    if (maxZoom != null) 'maxZoom': maxZoom,
    if (interactive != null) 'interactive': interactive,
    if (userData != null) 'userData': userData,
    if (renderingMode != null) 'renderingMode': renderingMode!.value,
    if (hiddenPartColor != null) 'hiddenPartColor': hiddenPartColor,
    if (hiddenPartGapColor != null) 'hiddenPartGapColor': hiddenPartGapColor,
  };
}

/// Raw binding for the `mapgl.Polyline` class.
///
/// `Polyline` extends `Evented<DynamicObjectEventTable<Polyline>>` on the JS
/// side; only the constructor, `destroy`, and the event plumbing are
/// mirrored here.
/// Raw binding for the `mapgl.Polyline` class.
@JS('mapgl.Polyline')
extension type Polyline._(JSObject _) implements JSObject {
  external factory Polyline._internal(MapglMapNew map, JSObject options);

  factory Polyline(MapglMapNew map, PolylineOptions options) =>
      Polyline._internal(map, options.toJsMap().jsify() as JSObject);

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
  void onEvent(DynamicObjectEventType type, void Function(DynamicObjectPointerEvent<Polyline> event) callback) {
    final jsHandler = ((DynamicObjectPointerEvent<Polyline> ev) => callback(ev)).toJS;
    (_polylineEventHandlers[callback] ??= <DynamicObjectEventType, JSFunction>{})[type] = jsHandler;
    _on(type.value.toJS, jsHandler);
  }

  /// Detaches the handler previously registered by [onEvent] for the same
  /// [callback] and [type]. No-op if no matching listener exists.
  void offEvent(DynamicObjectEventType type, void Function(DynamicObjectPointerEvent<Polyline> event) callback) {
    final jsHandler = _polylineEventHandlers[callback]?[type];
    if (jsHandler == null) return;
    _off(type.value.toJS, jsHandler);
  }
}
