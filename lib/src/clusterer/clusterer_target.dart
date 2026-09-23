// src/clusterer/clusterer_target.dart

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

/// Identifies what a clusterer pointer event is targeting.
enum ClustererTargetType {
  marker('marker'),
  cluster('cluster'),
  unknown('unknown');

  final String value;

  const ClustererTargetType(this.value);

  static ClustererTargetType fromString(String? val) {
    if (val == null) return ClustererTargetType.unknown;
    return ClustererTargetType.values.firstWhere(
          (e) => e.value == val,
      orElse: () => ClustererTargetType.unknown,
    );
  }
}

/// Raw binding for a clusterer pointer event.
///
/// The generic parameter [T] mirrors the marker payload type used when the
/// marker set was loaded.
@JS()
extension type ClustererPointerEvent<T>._(JSObject _) implements JSObject {
  external web.Event get originalEvent;

  external JSArray<JSNumber> get point;

  external JSArray<JSNumber> get lngLat;

  external ClustererTarget<T> get target;

  List<double> get lngLatList =>
      lngLat.toDart.map((e) => e.toDartDouble).toList();

  List<double> get pointList =>
      point.toDart.map((e) => e.toDartDouble).toList();
}

/// Describes the target of a pointer event: either a single marker or an
/// aggregated cluster.
///
/// The JS contract puts the marker's `userData` (or an array of them, for
/// clusters) on [data]; the getters below unwrap it into the Dart type [T].
@JS()
extension type ClustererTarget<T>._(JSObject _) implements JSObject {
  external JSString get type;

  external JSNumber? get id;

  external JSAny? get data;

  ClustererTargetType get targetType {
    final typeStr = type.toDart;
    if (typeStr == 'cluster') return ClustererTargetType.cluster;
    if (typeStr == 'marker') return ClustererTargetType.marker;
    return ClustererTargetType.unknown;
  }

  /// Returns the `userData` attached to the underlying marker, or `null` if
  /// the target is not a marker or the marker has no payload.
  T? get markerUserData {
    if (targetType != ClustererTargetType.marker || data == null) return null;
    final markerJs = data! as JSObject;
    if (!markerJs.hasProperty('userData'.toJS).toDart) return null;
    final rawUserData = markerJs.getProperty('userData'.toJS);
    if (rawUserData == null) return null;
    return _castUserData(rawUserData);
  }

  /// Returns the `userData` payloads of all markers aggregated into this
  /// cluster, or `null` if the target is not a cluster.
  ///
  /// Individual entries are `null` when the corresponding marker has no
  /// payload.
  List<T?>? get clusterUsersData {
    if (targetType != ClustererTargetType.cluster || data == null) return null;
    final jsArray = data! as JSArray<JSObject>;
    final dartList = jsArray.toDart;
    return List<T?>.generate(dartList.length, (index) {
      final markerJs = dartList[index];
      if (!markerJs.hasProperty('userData'.toJS).toDart) return null;
      final rawUserData = markerJs.getProperty('userData'.toJS);
      if (rawUserData == null) return null;
      return _castUserData(rawUserData);
    });
  }

  /// Best-effort conversion of a raw JS value to the caller-declared type [T].
  ///
  /// Handles the common primitive cases (`JSObject`, `num`, `String`, `bool`)
  /// explicitly; anything else falls back to a direct cast, returning `null`
  /// on failure rather than throwing.
  T? _castUserData(JSAny raw) {
    if (raw.isA<JSObject>() && raw is T) return raw as T;

    if (raw.isA<JSNumber>()) {
      final numValue = raw as JSNumber;
      if (T == int) return numValue.toDartInt as T;
      if (T == double) return numValue.toDartDouble as T;
    }
    if (raw.isA<JSString>()) {
      if (T == String) return (raw as JSString).toDart as T;
    }
    if (raw.isA<JSBoolean>()) {
      if (T == bool) return (raw as JSBoolean).toDart as T;
    }
    try {
      return raw as T;
    } catch (_) {
      return null;
    }
  }
}