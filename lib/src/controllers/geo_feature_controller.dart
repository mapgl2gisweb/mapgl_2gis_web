// src/controllers/geo_feature_controller.dart

import '../types/layers/layers.dart';
import '../sources/geojson_source_options.dart';
import 'layer_controller.dart';
import 'source_controller.dart';
import 'map_controller_access.dart';

/// Combines a GeoJSON source and a style layer into a single "feature".
///
/// Convenience layer for the common pattern: draw a geometry, filter it by a
/// unique attribute. All heavy lifting is delegated to [SourceController]
/// and [LayerController] — this controller does not track source or layer
/// ids on its own.
///
/// Because both underlying controllers serialize their operations, the order
/// of `add` / `remove` calls on this controller is preserved end to end.
class GeoFeatureController {
  GeoFeatureController(MapControllerAccess access)
    : _sources = SourceController(access),
      _layers = LayerController(access);

  final SourceController _sources;
  final LayerController _layers;

  int _counter = 0;

  Future<String> _addFeature({
    required Map<String, Object?> geometry,
    required StyleLayer Function(String id) buildLayer,
  }) async {
    final id = 'feature-${_counter++}';

    await _sources.addGeoJsonSource(
      id,
      GeoJsonSourceOptions(
        data: {
          'type': 'FeatureCollection',
          'features': [
            {'type': 'Feature', 'properties': {}, 'geometry': geometry},
          ],
        },
        attributes: {'featureId': id},
      ),
    );

    await _layers.addLayer(buildLayer(id));
    return id;
  }

  /// Adds a polygon feature and returns its generated id.
  Future<String> addPolygon({required List<List<double>> ring, required PolygonStyleProps style}) => _addFeature(
    geometry: {
      'type': 'Polygon',
      'coordinates': [ring],
    },
    buildLayer: (id) => PolygonStyleLayer(
      id: 'layer-$id',
      filter: StyleValue.expression([
        'match',
        ['sourceAttr', 'featureId'],
        [id],
        true,
        false,
      ]),
      style: style,
    ),
  );

  /// Adds a line feature and returns its generated id.
  Future<String> addLine({required List<List<double>> points, required LineStyleProps style}) => _addFeature(
    geometry: {'type': 'LineString', 'coordinates': points},
    buildLayer: (id) => LineStyleLayer(
      id: 'layer-$id',
      filter: StyleValue.expression([
        'match',
        ['sourceAttr', 'featureId'],
        [id],
        true,
        false,
      ]),
      style: style,
    ),
  );

  /// Removes the feature with the given [id], along with its layer and
  /// source. No-op if the id is unknown.
  Future<void> remove(String id) async {
    await _layers.removeLayer('layer-$id');
    await _sources.remove(id);
  }

  /// Removes every feature managed by this controller.
  Future<void> clear() async {
    await _layers.clear();
    await _sources.clear();
  }
}
