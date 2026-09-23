// src/types/layers/layer_visibility.dart

/// Mirrors `visibility?: string` from the MapGL style type definitions,
/// restricted to the two values documented by the JS API:
///
/// - [visible] — layer objects are displayed on the map;
/// - [none] — layer objects are not displayed.
enum LayerVisibility {
  visible('visible'),
  none('none');

  final String value;
  const LayerVisibility(this.value);
}