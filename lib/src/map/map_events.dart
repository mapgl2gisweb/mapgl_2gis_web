// src/map/map_events.dart

import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Events emitted by the MapGL map.
///
/// Mirrors `MapEventTable` from `events.d.ts`. Every event name is spelled
/// exactly as in the JS contract, so the enum value can be passed straight
/// to `on` / `off`.
///
/// Not every event carries the same payload:
///
///  * pointer events (`click`, `mousemove`, …) deliver a [MapPointerEvent];
///  * lifecycle events (`move`, `zoom`, `idle`, `resize`, …) deliver a
///    [MapEvent] with an `isUser` flag;
///  * specialized events (`floorplanshow`, `styleload`, …) carry their own
///    shapes and are currently only accessible through the raw `on` / `off`
///    API on the binding.
enum MapEventType {
  // Camera / view transitions.
  move('move'),
  movestart('movestart'),
  moveend('moveend'),
  center('center'),
  centerstart('centerstart'),
  centerend('centerend'),
  zoom('zoom'),
  zoomstart('zoomstart'),
  zoomend('zoomend'),
  rotation('rotation'),
  rotationstart('rotationstart'),
  rotationend('rotationend'),
  pitch('pitch'),
  pitchstart('pitchstart'),
  pitchend('pitchend'),

  // Pointer events.
  click('click'),
  contextmenu('contextmenu'),
  mousemove('mousemove'),
  mouseover('mouseover'),
  mouseout('mouseout'),
  mousedown('mousedown'),
  mouseup('mouseup'),
  touchstart('touchstart'),
  touchend('touchend'),
  touchmove('touchmove'),

  // Lifecycle.
  idle('idle'),
  resize('resize'),

  // Traffic.
  trafficshow('trafficshow'),
  traffichide('traffichide'),
  trafficscore('trafficscore'),

  // Floor plans.
  floorplanshow('floorplanshow'),
  floorplanhide('floorplanhide'),
  floorlevelchange('floorlevelchange'),

  // Style.
  styleload('styleload'),
  styleloaderror('styleloaderror'),

  // Misc.
  changeLanguage('changeLanguage'),
  destroy('destroy'),
  error('error'),
  graphicspresetchange('graphicspresetchange');

  final String value;

  const MapEventType(this.value);
}

/// Base event payload carried by non-pointer map events.
///
/// Mirrors `MapEvent` from `events.d.ts`.
@JS()
extension type MapEvent._(JSObject _) implements JSObject {
  /// `true` when the event was triggered by a user interaction.
  external bool get isUser;
}

/// Payload of a pointer-related map event.
///
/// Mirrors `MapPointerEvent` from `events.d.ts`.
///
/// Only the pieces that are useful from Dart are exposed: the original DOM
/// event, the geographic and screen coordinates, and the optional target
/// data. `targetData` is a union in the JS contract and is kept as a raw
/// [JSObject] — callers can inspect it via `dartify()` or dedicated
/// accessors.
@JS()
extension type MapPointerEvent._(JSObject _) implements JSObject {
  external web.Event get originalEvent;

  external JSArray<JSNumber> get lngLat;

  external JSArray<JSNumber> get point;

  external JSObject? get target;

  external JSObject? get targetData;

  List<double> get lngLatList => lngLat.toDart.map((e) => e.toDartDouble).toList();

  List<double> get pointList => point.toDart.map((e) => e.toDartDouble).toList();
}
