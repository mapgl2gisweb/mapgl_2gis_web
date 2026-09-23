//example/lib/features/random_cluster_points.dart

import 'dart:math';

import 'package:mapgl_2gis_web/mapgl_2gis_web.dart';

/// Generates random points inside a map rectangle (bounds), guaranteeing a
/// minimum distance between any two points.
///
/// Uses the haversine formula for real distances in meters — a convenient
/// proxy for visual spread: the map bounds already reflect the current
/// zoom (the closer the view, the smaller the bbox in degrees), so a fixed
/// `minDistanceMeters` yields a reasonable density without converting to
/// pixel coordinates via `map.project()` / `map.unproject()`.
class RandomClusterPointsGenerator {
  final Random _random;

  /// [seed] makes the generated set reproducible between runs — useful for
  /// demos where the same coordinates should appear on every restart.
  RandomClusterPointsGenerator({int? seed}) : _random = seed != null ? Random(seed) : Random();

  /// Generates up to [count] points inside the rectangle defined by
  /// `[west, south]`–`[east, north]`, with at least [minDistanceMeters]
  /// between any two points.
  ///
  /// If the area is too small for the requested density, some points are
  /// skipped — after [maxAttemptsPerPoint] failed attempts per point — and
  /// a warning with the final count is printed to the console.
  List<LngLat> generate({
    required double west,
    required double south,
    required double east,
    required double north,
    required int count,
    double minDistanceMeters = 50,
    int maxAttemptsPerPoint = 200,
    double edgePaddingFraction = 0.1, // 10% per side — keep away from edges
  }) {
    if (west >= east || south >= north) {
      throw ArgumentError('Invalid bounds: west < east and south < north are required');
    }

    // Shrink the rectangle on all sides by `edgePaddingFraction` so points
    // never land exactly at the edge of the visible map area.
    final lngPadding = (east - west) * edgePaddingFraction;
    final latPadding = (north - south) * edgePaddingFraction;

    final effectiveWest = west + lngPadding;
    final effectiveEast = east - lngPadding;
    final effectiveSouth = south + latPadding;
    final effectiveNorth = north - latPadding;

    final points = <LngLat>[];
    var skipped = 0;

    for (var i = 0; i < count; i++) {
      LngLat? candidate;
      for (var attempt = 0; attempt < maxAttemptsPerPoint; attempt++) {
        final lng = effectiveWest + _random.nextDouble() * (effectiveEast - effectiveWest);
        final lat = effectiveSouth + _random.nextDouble() * (effectiveNorth - effectiveSouth);
        final p = LngLat(lng, lat);

        final farEnough = points.every((existing) => _haversineDistanceMeters(existing, p) >= minDistanceMeters);

        if (farEnough) {
          candidate = p;
          break;
        }
      }

      if (candidate != null) {
        points.add(candidate);
      } else {
        skipped++;
      }
    }

    if (skipped > 0) {
      // ignore: avoid_print
      print(
        '[RandomClusterPointsGenerator] Generated ${points.length} of $count. '
        'Skipped $skipped points — the area is too small for '
        'minDistanceMeters=$minDistanceMeters at this count. '
        'Reduce minDistanceMeters or count.',
      );
    }

    return points;
  }

  /// Haversine formula — accurate distance between two lng/lat points on
  /// the sphere (Earth), in meters.
  double _haversineDistanceMeters(LngLat a, LngLat b) {
    const earthRadiusMeters = 6371000.0;

    final dLat = _degToRad(b.lat - a.lat);
    final dLng = _degToRad(b.lng - a.lng);
    final lat1 = _degToRad(a.lat);
    final lat2 = _degToRad(b.lat);

    final h = sin(dLat / 2) * sin(dLat / 2) + cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(h), sqrt(1 - h));

    return earthRadiusMeters * c;
  }

  double _degToRad(double deg) => deg * pi / 180;
}
