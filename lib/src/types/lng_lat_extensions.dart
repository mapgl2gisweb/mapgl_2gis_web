// src/types/lng_lat_extensions.dart

import 'lng_lat.dart';
import 'lng_lat_bounds_class.dart';

/// Converts a raw `[lng, lat]` list — as returned by `getCenter`,
/// `unproject`, and similar methods — into a [LngLat].
extension LngLatFromList on List<double> {
  LngLat toLngLat() => LngLat.fromList(this);
}

/// Dart-friendly view of [LngLatBoundsClass]: `southWest` / `northEast` are
/// exposed as [LngLat] values instead of raw lists.
extension LngLatBoundsView on LngLatBoundsClass {
  LngLat get southWestLngLat => southWest.toLngLat();
  LngLat get northEastLngLat => northEast.toLngLat();
}