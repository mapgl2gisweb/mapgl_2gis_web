## 0.0.3 - 2026-09-23

### Breaking changes

* `LayerController.removeLayer` and `clear` now return `Future<void>`. Mutating operations are serialized through an internal queue, so the relative order of `add` / `remove` calls is preserved regardless of how long each one waits for the map to be ready.
* `SourceController.remove` and `clear` now return `Future<void>` for the same reason.
* `GeoFeatureController.remove` and `clear` now return `Future<void>`.
* `Polygon.onEvent` / `offEvent` and `Polyline.onEvent` / `offEvent` now take a typed `void Function(DynamicObjectPointerEvent<T>)` callback instead of a raw `JSFunction`.
* `StyleIconConfig` now matches the JS contract in `styles.d.ts` — a union of `{url}` (simple) and `{url, width, height, stretchX, stretchY}` (stretchable). The previous shape incorrectly exposed `size`, `pixelRatio`, and `padding`, which belong to `LabelImage`.
* Removed `src/sources/geojson_source_bindings.dart`. Its raw binding now lives in `mapgl_map_bindings.dart`, and the Dart-friendly helpers moved to `src/sources/geojson_source_extensions.dart` as `GeoJsonSourceDartApi`.
* Renamed `src/types/style_Icon_config.dart` to `src/types/style_icon_config.dart`.

### Added

* `Marker` — wrapper around `mapgl.Marker` with full lifecycle (icons, hover icon, rotation, label, coordinates, visibility) and typed pointer events.
* `HtmlMarker` — wrapper around `mapgl.HtmlMarker` (coordinates, anchor, content, z-index). No events: `HtmlMarker` does not extend `Evented` in the JS contract.
* `LabelOptions` in `src/common/` — shared label configuration for `Marker` and the clusterer's `InputMarker`, including `font`, mirroring `font?: string` from the JS contract. Replaces the previous `InputMarkerLabelOptions`.
* `MapEventType`, `MapEvent`, and `MapPointerEvent`, plus `onPointerEvent` / `offPointerEvent` / `onMapEvent` / `offMapEvent` on `MapController` and `MapglMapNew`.
* `DynamicObjectPointerEvent<T>` — typed pointer events for `Polygon`, `Polyline`, and `Marker`. `DynamicObjectEventType` gained `touchmove`.
* `ScriptLoaderBase` in `src/core/` — shared implementation behind `DefaultMapglScriptLoader` and `DefaultClustererScriptLoader`.
* New style layer types: `DashedLineStyleLayer`, `PointStyleLayer` (with `LabelingMargin`), `RasterStyleLayer`, `HeatmapStyleLayer`.
* `LngLatBoundsClass` methods: `extend`, `getCenter`, `containsPoint`, `containsBounds`, `intersects`.
* `GeoJsonSourceDartApi` extension with `fromOptions`, `setDataFromMap`, `getAttributesMap`, `setAttributesFromMap`.

### Fixed

* `MapglClustererNew.offEvent` (and therefore `ClustererController`) silently failed to detach listeners — the JS handler wrapper is now cached per Dart callback via `Expando`.
* Removed the duplicated `GeoJsonSource` binding (`mapgl_map_bindings.dart` vs `geojson_source_bindings.dart`) that had diverged in `setData` signature.
* Removed the circular import of `mapgl_2gis_web.dart` from `mapgl_map_bindings.dart`.

### Changed

* All source and API comments translated to English and rewritten in a more formal style.
* `TierOption` documented as an empty marker interface and intentionally not modelled.

### Deprecated

* `InputMarkerLabelOptions` — use `LabelOptions` instead. Kept as a `typedef` alias for source compatibility.