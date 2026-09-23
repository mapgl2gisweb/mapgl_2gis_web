// src/types/lng_lat.dart

import 'package:flutter/foundation.dart' show immutable;

/// A geographic coordinate pair, in the JS API's `[lng, lat]` order.
///
/// Mirrors the ergonomics of Flutter's `Size`: immutable, value-comparable,
/// and convertible to/from the raw `List<double>` format used throughout
/// the MapGL bindings.
@immutable
class LngLat {
  final double lng;
  final double lat;

  const LngLat(this.lng, this.lat);

  /// Creates a [LngLat] from a `[lng, lat]` list, as used by the JS bindings.
  factory LngLat.fromList(List<double> coordinates) {
    assert(
    coordinates.length == 2,
    'Expected a [lng, lat] pair, got ${coordinates.length} elements',
    );
    return LngLat(coordinates[0], coordinates[1]);
  }

  /// Converts back to the `[lng, lat]` list format expected by the JS
  /// bindings.
  List<double> toList() => [lng, lat];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is LngLat && other.lng == lng && other.lat == lat);

  @override
  int get hashCode => Object.hash(lng, lat);

  @override
  String toString() => 'LngLat($lng, $lat)';
}