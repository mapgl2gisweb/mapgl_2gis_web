// src/controllers/map_controller_access.dart

import '../map/mapgl_map_bindings.dart';

/// Minimal contract required by specialised controllers
/// ([LayerController], [SourceController], [ClustererController], ...) to
/// interact with the map.
///
/// Deliberately narrower than the full [MapController]: it exposes only what
/// these controllers actually need, so alternative implementations (e.g.
/// test doubles) can be supplied without pulling in the entire public API.
abstract interface class MapControllerAccess {
  /// The raw map binding.
  ///
  /// Accessing this before the map is ready is a usage error.
  MapglMapNew get map;

  /// Whether the map is currently ready.
  bool get isReady;

  /// Resolves once, when the map becomes ready for layers and data.
  Future<void> get whenReady;
}