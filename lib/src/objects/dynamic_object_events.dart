// src/objects/dynamic_object_events.dart

import 'dart:js_interop';

import 'package:web/web.dart' as web;


/// Events shared by dynamic objects ([Polyline], [Polygon], [Marker], …).
///
/// Mirrors the `DynamicObjectEventTable` shape from `events.d.ts`. The
/// string values are DOM-style event names, matching the clusterer's event
/// naming convention.
enum DynamicObjectEventType {
  click('click'),
  mousemove('mousemove'),
  mouseover('mouseover'),
  mouseout('mouseout'),
  mousedown('mousedown'),
  mouseup('mouseup'),
  touchstart('touchstart'),
  touchend('touchend'),
  touchmove('touchmove');

  final String value;

  const DynamicObjectEventType(this.value);
}

/// Payload of a pointer-related dynamic-object event.
///
/// Mirrors `DynamicObjectPointerEvent<T>` from `events.d.ts`. The generic
/// parameter [T] is the JS-side object that emitted the event (for example
/// a `Polygon`, `Polyline`, or `Marker` extension type). It is exposed
/// through [targetData].
///
/// [T] is bound to [JSObject] because Dart requires external members to use
/// a type that erases to a valid JS type. Every dynamic-object extension
/// type in this package implements [JSObject], so `Polygon`, `Polyline`,
/// `Marker`, and future additions all satisfy the bound.
@JS()
extension type DynamicObjectPointerEvent<T extends JSObject>._(JSObject _) implements JSObject {
  external web.Event get originalEvent;

  external JSArray<JSNumber> get lngLat;

  external JSArray<JSNumber> get point;

  /// The object that emitted the event.
  external T get targetData;

  List<double> get lngLatList => lngLat.toDart.map((e) => e.toDartDouble).toList();

  List<double> get pointList => point.toDart.map((e) => e.toDartDouble).toList();
}
