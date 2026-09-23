// src/controllers/map_controller_lng_lat_extensions.dart

import '../types/lng_lat.dart';
import '../types/lng_lat_bounds_class.dart';
import '../types/lng_lat_extensions.dart';
import 'map_controller.dart';

/// [LngLat]-based convenience API layered on top of [MapController]'s
/// `List<double>`-based methods.
///
/// Both styles are fully supported — use whichever reads better at the call
/// site. These extensions add no behaviour beyond the coordinate conversion.
extension MapControllerLngLatExtensions on MapController {
  void setCenterLngLat(LngLat center) => setCenter(center.toList());

  LngLat getCenterLngLat() => getCenter().toLngLat();

  LngLat unProjectLngLat(List<double> point) => unproject(point).toLngLat();

  void fitBoundsLngLat(LngLat southWest, LngLat northEast) {
    fitBounds(
      LngLatBoundsDartFactory.fromDart(
        southWest: southWest.toList(),
        northEast: northEast.toList(),
      ),
    );
  }
}