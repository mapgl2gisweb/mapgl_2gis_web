// mapgl_2gis_web.dart

/// A high-performance Flutter Web wrapper for the 2GIS MapGL JS API.
///
/// Built on Dart 3 JS interop with `extension type`s, and compatible with
/// both the JS and WASM compilation targets.
library;

export 'src/core/mapgl_logging.dart';
export 'src/widgets/mapgl_widget.dart';
export 'src/map/map_events.dart';
export 'src/clusterer/clusterer.dart';
export 'src/map/mapgl_map_bindings.dart';
export 'src/types/types.dart';
export 'src/types/layers/layers.dart';
export 'src/controllers/controllers.dart';
export 'src/sources/geojson_source_options.dart';
export 'src/sources/geojson_source_extensions.dart';
export 'src/objects/objects.dart';
export 'src/common/label_options.dart';