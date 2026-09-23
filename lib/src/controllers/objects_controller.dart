// src/controllers/objects_controller.dart

import '../objects/polyline.dart';
import '../objects/polygon.dart';
import 'map_controller_access.dart';

/// Manages the lifecycle of dynamic objects ([Polyline], [Polygon]).
///
/// Mirrors [LayerController], but for imperatively rendered objects rather
/// than declarative style layers. The controller tracks every object it has
/// created, so [clear] can safely tear them all down.
class ObjectsController {
  ObjectsController(this._access);

  final MapControllerAccess _access;
  final List<Polyline> _polylines = [];
  final List<Polygon> _polygons = [];

  /// Creates a new [Polyline] and registers it with this controller.
  Polyline addPolyline(PolylineOptions options) {
    final polyline = Polyline(_access.map, options);
    _polylines.add(polyline);
    return polyline;
  }

  /// Creates a new [Polygon] and registers it with this controller.
  Polygon addPolygon(PolygonOptions options) {
    final polygon = Polygon(_access.map, options);
    _polygons.add(polygon);
    return polygon;
  }

  /// Destroys every object created through this controller.
  void clear() {
    for (final p in _polylines) {
      p.destroy();
    }
    _polylines.clear();

    for (final p in _polygons) {
      p.destroy();
    }
    _polygons.clear();
  }
}