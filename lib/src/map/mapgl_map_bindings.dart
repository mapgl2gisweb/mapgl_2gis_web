// src/map/mapgl_map_bindings.dart

import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../core/js_interop_helpers.dart';
import '../types/lng_lat_bounds_class.dart';
import '../types/style_icon_config.dart';
import 'map_events.dart';

@JS()
extension type DefaultSource._(JSObject _) implements JSObject {}

@JS()
extension type WebGLContext._(JSObject _) implements JSObject {}

/// Raw binding for the MapGL `Map` class.
///
/// This extension type mirrors the public JS contract of `mapgl.Map` as
/// documented by 2GIS MapGL. It carries no application-level logic — every
/// method delegates directly to the underlying JS object.

/// Caches JS handlers per Dart callback, keyed by the event type, so that
/// [MapglMapNew.offPointerEvent] / [MapglMapNew.offMapEvent] can find the
/// exact JS function that was previously attached.
final Expando<Map<MapEventType, JSFunction>> _mapEventHandlers = Expando<Map<MapEventType, JSFunction>>(
  'map.eventHandlers',
);

@JS('mapgl.Map')
extension type MapglMapNew._(JSObject _) implements JSObject {
  /// Creates a new map inside the given container (a DOM element id string
  /// or an HTMLElement) with the supplied options:
  /// `mapgl.Map('map-container-id', options)`.
  external factory MapglMapNew(JSAny container, JSObject options);

  // --- CAMERA, ZOOM AND TRAFFIC ---

  @JS('setCenter')
  external MapglMapNew _setCenter(JSArray<JSNumber> center, [JSObject? options]);

  MapglMapNew setCenter(List<double> center, [JSObject? options]) =>
      _setCenter(center.map((e) => e.toJS).toList().toJS, options ?? JSObject());

  @JS('getCenter')
  external JSArray<JSNumber> _getCenter();

  List<double> getCenter() => _getCenter().toDoubleList();

  @JS('setZoom')
  external MapglMapNew _setZoom(JSNumber zoom, [JSObject? options]);

  MapglMapNew setZoom(double zoom, [JSObject? options]) => _setZoom(zoom.toJS, options ?? JSObject());

  @JS('getZoom')
  external JSNumber _getZoom();

  /// Returns the current map zoom level.
  double getZoom() => _getZoom().toDartDouble;

  @JS('getStyleZoom')
  external JSNumber _getStyleZoom();

  double getStyleZoom() => _getStyleZoom().toDartDouble;

  @JS('setStyleZoom')
  external MapglMapNew _setStyleZoom(JSNumber styleZoom, [JSObject? options]);

  MapglMapNew setStyleZoom(double styleZoom, [JSObject? options]) => _setStyleZoom(styleZoom.toJS, options);

  @JS('setRotation')
  external MapglMapNew _setRotation(JSNumber rotation, [JSObject? options]);

  /// Sets the map rotation angle in degrees.
  MapglMapNew setRotation(double rotation, [JSObject? options]) => _setRotation(rotation.toJS, options ?? JSObject());

  @JS('getRotation')
  external JSNumber _getRotation();

  double getRotation() => _getRotation().toDartDouble;

  @JS('setPitch')
  external MapglMapNew _setPitch(JSNumber pitch, [JSObject? options]);

  /// Sets the map pitch angle in degrees.
  MapglMapNew setPitch(double pitch, [JSObject? options]) => _setPitch(pitch.toJS, options ?? JSObject());

  @JS('getPitch')
  external JSNumber _getPitch();

  double getPitch() => _getPitch().toDartDouble;

  @JS('setMinZoom')
  external MapglMapNew _setMinZoom(JSNumber zoom, [JSObject? options]);

  MapglMapNew setMinZoom(double zoom, [JSObject? options]) => _setMinZoom(zoom.toJS, options ?? JSObject());

  @JS('getMinZoom')
  external JSNumber _getMinZoom();

  double getMinZoom() => _getMinZoom().toDartDouble;

  @JS('getMaxZoom')
  external JSNumber _getMaxZoom();

  double getMaxZoom() => _getMaxZoom().toDartDouble;

  @JS('setMaxZoom')
  external MapglMapNew _setMaxZoom(JSNumber zoom, [JSObject? options]);

  MapglMapNew setMaxZoom(double zoom, [JSObject? options]) => _setMaxZoom(zoom.toJS, options ?? JSObject());

  @JS('setMinPitch')
  external MapglMapNew _setMinPitch(JSNumber pitch, [JSObject? options]);

  MapglMapNew setMinPitch(double pitch, [JSObject? options]) => _setMinPitch(pitch.toJS, options ?? JSObject());

  @JS('setMaxPitch')
  external MapglMapNew _setMaxPitch(JSNumber pitch, [JSObject? options]);

  MapglMapNew setMaxPitch(double pitch, [JSObject? options]) => _setMaxPitch(pitch.toJS, options ?? JSObject());

  @JS('setLowZoomMaxPitch')
  external MapglMapNew _setLowZoomMaxPitch(JSNumber pitch, [JSObject? options]);

  MapglMapNew setLowZoomMaxPitch(double pitch, [JSObject? options]) =>
      _setLowZoomMaxPitch(pitch.toJS, options ?? JSObject());

  @JS('getSize')
  external JSArray<JSNumber> _getSize();

  List<int> getSize() => _getSize().toIntList();

  external bool isIdle();

  @JS('getBounds')
  external LngLatBoundsClass? _getBounds([JSObject? options]);

  /// Returns the geographic bounds of the currently visible map area.
  ///
  /// Throws a [StateError] if the map is not ready yet — for example, when
  /// called before the `idle` event has fired.
  LngLatBoundsClass getBounds([JSObject? options]) {
    final bounds = _getBounds(options);
    if (bounds == null) {
      throw StateError('Map bounds are not available yet. Call getBounds() after the map is idle.');
    }
    return bounds;
  }

  @JS('project')
  external JSArray<JSNumber> _project(JSArray<JSNumber> lngLat);

  List<double> project(List<double> lngLat) => _project(lngLat.toJSArray()).toDoubleList();

  @JS('unproject')
  external JSArray<JSNumber> _unproject(JSArray<JSNumber> point);

  List<double> unproject(List<double> point) => _unproject(point.toJSArray()).toDoubleList();

  @JS('getWebGLContext')
  external WebGLContext? _getWebGLContext();

  /// Returns the map's WebGL context.
  ///
  /// Throws a [StateError] if the context has not been created yet — for
  /// example, when called too early in the map lifecycle.
  WebGLContext getWebGLContext() {
    final ctx = _getWebGLContext();
    if (ctx == null) {
      throw StateError('WebGL context is not available yet. Call getWebGLContext() after the map is idle.');
    }
    return ctx;
  }

  external web.HTMLCanvasElement getCanvas();

  external web.HTMLElement getContainer();

  external MapglMapNew invalidateSize();

  external MapglMapNew showTraffic();

  external MapglMapNew hideTraffic();

  external bool isTrafficOn();

  @JS('setSelectedObjects')
  external MapglMapNew _setSelectedObjects([JSArray<JSString>? ids, JSString? scope]);

  MapglMapNew setSelectedObjects({List<String>? ids, String? scope}) =>
      _setSelectedObjects(ids?.map((e) => e.toJS).toList().toJS, scope?.toJS);

  @JS('setStyleById')
  external JSPromise<JSString> _setStyleById(JSString styleId);

  Future<String> setStyleById(String styleId) async {
    final result = await _setStyleById(styleId.toJS).toDart;
    return result.toDart;
  }

  @JS('setStyleFromUrl')
  external JSPromise<JSString> _setStyleFromUrl(JSString styleUrl, JSObject options);

  Future<String> setStyleFromUrl(String styleUrl, JSObject options) async {
    final result = await _setStyleFromUrl(styleUrl.toJS, options).toDart;
    return result.toDart;
  }

  @JS('setLanguage')
  external MapglMapNew _setLanguage(JSString lang);

  MapglMapNew setLanguage(String lang) => _setLanguage(lang.toJS);

  @JS('getLanguage')
  external JSString _getLanguage();

  String getLanguage() => _getLanguage().toDart;

  @JS('setFloorPlanLevel')
  external void _setFloorPlanLevel(JSString floorPlanId, JSNumber floorLevelIndex);

  void setFloorPlanLevel(String floorPlanId, int floorLevelIndex) =>
      _setFloorPlanLevel(floorPlanId.toJS, floorLevelIndex.toJS);

  external MapglMapNew setMaxBounds(LngLatBoundsClass bounds);

  /// Returns the current padding.
  external JSObject getPadding();

  @JS('getDefaultSource')
  external DefaultSource? _getDefaultSource();

  /// Returns the default data source.
  ///
  /// Throws a [StateError] if the source has not been initialized yet — for
  /// example, when called before the map is idle.
  DefaultSource getDefaultSource() {
    final source = _getDefaultSource();
    if (source == null) {
      throw StateError('Default source is not available yet. Call getDefaultSource() after the map is idle.');
    }
    return source;
  }

  @JS('setPadding')
  external MapglMapNew _setPadding(JSObject padding, [JSObject? options]);

  MapglMapNew setPadding(JSObject padding, [JSObject? options]) => _setPadding(padding, options ?? JSObject());

  @JS('hasLayer')
  external bool _hasLayer(JSString layerId);

  bool hasLayer(String layerId) => _hasLayer(layerId.toJS);

  @JS('addLayer')
  external MapglMapNew _addLayer(JSObject layer, [JSString? beforeId]);

  MapglMapNew addLayer(JSObject layer, [String? beforeId]) => _addLayer(layer, beforeId?.toJS);

  @JS('addIcon')
  external MapglMapNew _addIcon(JSString name, StyleIconConfig config);

  MapglMapNew addIcon(String name, StyleIconConfig config) => _addIcon(name.toJS, config);

  @JS('removeIcon')
  external MapglMapNew _removeIcon(JSString name);

  MapglMapNew removeIcon(String name) => _removeIcon(name.toJS);

  @JS('removeLayer')
  external MapglMapNew _removeLayer(JSString layerId);

  MapglMapNew removeLayer(String layerId) => _removeLayer(layerId.toJS);

  external MapglMapNew fitBounds(LngLatBoundsClass bounds, [JSObject? options]);

  external MapglMapNew setStyleState(JSObject styleState);

  external JSObject getStyleState();

  @JS('getIconUrl')
  external JSString? _getIconUrl(JSString iconName);

  String? getIconUrl(String iconName) => _getIconUrl(iconName.toJS)?.toDart;

  external MapglMapNew setStyleOptions(JSObject options);

  @JS('setOption')
  external MapglMapNew _setOption(JSString option, JSAny value);

  MapglMapNew setOption(String option, JSAny value) => _setOption(option.toJS, value);

  @JS('getOption')
  external JSAny? _getOption(JSString option);

  JSAny? getOption(String option) => _getOption(option.toJS);

  external MapglMapNew patchStyleState(JSObject styleState);

  external void destroy();

  external void triggerRerender();

  external void setControlsLayoutPadding(JSObject padding);

  external JSObject getControlsLayoutPadding();

  external MapglMapNew hideLayers(JSObject params);

  external MapglMapNew showLayers(JSObject params);

  external JSObject getGraphicsPreset();

  external void blockInteraction();

  external void unblockInteraction();

  external MapglMapNew on(JSString event, JSFunction handler);

  external MapglMapNew off(JSString event, JSFunction handler);

  external MapglMapNew once(JSString event, JSFunction handler);

  /// Registers a typed handler for a pointer-related [eventType].
  ///
  /// Valid with [MapEventType.click], [MapEventType.mousemove],
  /// [MapEventType.touchstart], and the other pointer events. Registering a
  /// non-pointer event here is a contract violation — the payload will not
  /// match [MapPointerEvent].
  ///
  /// The JS-side wrapper is cached against [callback], so a subsequent
  /// [offPointerEvent] with the same callback will detach exactly this
  /// listener.
  void onPointerEvent(MapEventType eventType, void Function(MapPointerEvent event) callback) {
    final jsHandler = ((MapPointerEvent ev) => callback(ev)).toJS;
    (_mapEventHandlers[callback] ??= <MapEventType, JSFunction>{})[eventType] = jsHandler;
    on(eventType.value.toJS, jsHandler);
  }

  /// Detaches the handler previously registered by [onPointerEvent] for the
  /// same [callback] and [eventType]. No-op if no matching listener exists.
  void offPointerEvent(MapEventType eventType, void Function(MapPointerEvent event) callback) {
    final jsHandler = _mapEventHandlers[callback]?[eventType];
    if (jsHandler == null) return;
    off(eventType.value.toJS, jsHandler);
  }

  /// Registers a typed handler for a non-pointer [eventType].
  ///
  /// Valid for lifecycle events such as [MapEventType.move],
  /// [MapEventType.zoom], [MapEventType.idle], and [MapEventType.resize].
  void onMapEvent(MapEventType eventType, void Function(MapEvent event) callback) {
    final jsHandler = ((MapEvent ev) => callback(ev)).toJS;
    (_mapEventHandlers[callback] ??= <MapEventType, JSFunction>{})[eventType] = jsHandler;
    on(eventType.value.toJS, jsHandler);
  }

  /// Detaches the handler previously registered by [onMapEvent] for the same
  /// [callback] and [eventType]. No-op if no matching listener exists.
  void offMapEvent(MapEventType eventType, void Function(MapEvent event) callback) {
    final jsHandler = _mapEventHandlers[callback]?[eventType];
    if (jsHandler == null) return;
    off(eventType.value.toJS, jsHandler);
  }
}

/// Raw binding for a style layer object.
@JS()
extension type Layer._(JSObject _) implements JSObject {
  external factory Layer({
    required String id,
    required String type,
    JSAny? filter,
    JSAny? paint,
    JSAny? layout,
    double? minzoom,
    double? maxzoom,
  });

  @JS('id')
  external JSString get _id;

  String get id => _id.toDart;

  @JS('type')
  external JSString get _type;

  String get type => _type.toDart;

  @JS('minzoom')
  external JSNumber? get _minzoom;

  double? get minzoom => _minzoom?.toDartDouble;

  @JS('maxzoom')
  external JSNumber? get _maxzoom;

  double? get maxzoom => _maxzoom?.toDartDouble;
}

/// Raw binding for the `mapgl.GeoJsonSource` class.
///
/// This is the single source of truth for the `GeoJsonSource` JS contract.
/// Dart-friendly helpers (options-based factory, `Map`-based `setData`,
/// typed attribute access) live in `geojson_source_extensions.dart` as
/// extensions on this type, so that the binding layer stays free of
/// application-level models.
@JS('mapgl.GeoJsonSource')
extension type GeoJsonSource._(JSObject _) implements JSObject {
  /// Creates a GeoJSON source attached to [map] with the given raw options.
  external factory GeoJsonSource(MapglMapNew map, JSObject options);

  /// Replaces the source data. The JS API returns a promise that resolves
  /// when the new data has been applied.
  @JS('setData')
  external JSPromise<JSAny?> setData(JSObject data);

  /// Returns the source attributes as a raw JS object.
  @JS('getAttributes')
  external JSObject getAttributes();

  /// Replaces the source attributes.
  @JS('setAttributes')
  external GeoJsonSource setAttributes(JSObject attributes);

  external void destroy();
}
