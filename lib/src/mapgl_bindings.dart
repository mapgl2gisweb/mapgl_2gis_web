// mapgl_bindings.dart

import 'dart:js_interop';

/// ---------------------------------------------------------------
/// Map — основной класс карты (types/map.d.ts)
/// ---------------------------------------------------------------
@JS('mapgl.Map')
extension type MapglMap._(JSObject _) implements JSObject {
  /// container — HTMLElement или id div-а (строка).
  /// ВАЖНО для Flutter Web: передавайте HTMLElement, а не id — см.
  /// комментарий про Shadow DOM в предыдущих файлах проекта.
  external factory MapglMap(JSAny container, JSAny options);

  external MapglMap setCenter(JSArray<JSNumber> center, [JSAny? options]);

  external JSArray<JSNumber> getCenter();

  external MapglMap setZoom(JSNumber zoom, [JSAny? options]);

  external JSNumber getZoom();

  external MapglMap setRotation(JSNumber rotation, [JSAny? options]);

  external JSNumber getRotation();

  external MapglMap setPitch(JSNumber pitch, [JSAny? options]);

  external JSNumber getPitch();

  external MapglMap setMinZoom(JSNumber zoom, [JSAny? options]);

  external JSNumber getMinZoom();

  external MapglMap setMaxZoom(JSNumber zoom, [JSAny? options]);

  external JSNumber getMaxZoom();

  external MapglMap fitBounds(JSAny bounds, [JSAny? options]);

  external MapglMap invalidateSize();

  external void destroy();

  external void on(JSString event, JSFunction handler);

  external void off(JSString event, JSFunction handler);
}

/// Событие клика/наведения по САМОЙ карте (map.on('click', ...)) —
/// отдельный тип от ClustererPointerEvent. Даёт координаты клика и,
/// если попали по встроенному объекту базовой карты (здание, POI),
/// данные об этом объекте.
@JS()
extension type MapPointerEventJS._(JSObject _) implements JSObject {
  external JSArray<JSNumber> get lngLat;

  external JSArray<JSNumber> get point;

  /// Есть, только если клик попал по объекту базовой карты (не по
  /// пустому месту) — здание, POI, часть плана этажа и т.п.
  external MapEventTargetJS? get target;

  external MapEventTargetDataJS? get targetData;
}

@JS()
extension type MapEventTargetJS._(JSObject _) implements JSObject {
  external JSString get id;
}

/// targetData.type различает 'default' (обычный объект базовой
/// карты — здание/POI) и 'geojson' (объект из вашего GeoJsonSource,
/// если используете). Здесь — поля для 'default', самый частый
/// случай для клика по встроенным зданиям/POI.
@JS()
extension type MapEventTargetDataJS._(JSObject _) implements JSObject {
  external JSString get type; // 'default' | 'geojson'
  external JSString? get id;

  external JSString? get floorId; // если это часть плана этажа здания
  external JSString? get layerId;
}

/// ---------------------------------------------------------------
/// Marker — types/objects/marker.d.ts
/// ---------------------------------------------------------------
@JS('mapgl.Marker')
extension type MapglMarker._(JSObject _) implements JSObject {
  external factory MapglMarker(MapglMap map, JSAny options);

  external MapglMarker setIcon(JSAny iconOptions);

  external MapglMarker setHoverIcon([JSAny? iconOptions]);

  external MapglMarker setRotation(JSNumber angle);

  external JSNumber getRotation();

  external MapglMarker setLabel([JSAny? labelOptions]);

  /// Есть, вопреки тому, что я утверждал ранее по документации —
  /// сверено с исходным .d.ts.
  external MapglMarker setCoordinates(JSArray<JSNumber> coordinates);

  external JSArray<JSNumber> getCoordinates();

  external MapglMarker show();

  external MapglMarker hide();

  external void destroy();

  external void on(JSString event, JSFunction handler);

  external void off(JSString event, JSFunction handler);

  /// userData — произвольные данные, которые вы сами кладёте при
  /// создании маркера (например, весь объект парковки), доступны
  /// потом в обработчике клика через marker.userData.
  external JSAny? get userData;

  external set userData(JSAny? value);
}

/// ---------------------------------------------------------------
/// HtmlMarker — types/objects/htmlMarker.d.ts
/// Внимание: HtmlMarker НЕ наследует Evented — у него нет on()/off()
/// в этой версии типов. Клики обрабатываются через обычные DOM-события
/// на элементе, который возвращает getContent().
/// ---------------------------------------------------------------
@JS('mapgl.HtmlMarker')
extension type MapglHtmlMarker._(JSObject _) implements JSObject {
  external factory MapglHtmlMarker(MapglMap map, JSAny options);

  external void destroy();

  external MapglHtmlMarker setCoordinates(JSArray<JSNumber> coordinates);

  external MapglHtmlMarker setAnchor(JSArray<JSNumber> anchor);

  external MapglHtmlMarker setContent(JSAny html); // HTMLElement | string
  external MapglHtmlMarker setZIndex(JSNumber zIndex);

  external JSArray<JSNumber> getCoordinates();

  external JSArray<JSNumber> getAnchor();

  external JSAny getContent(); // HTMLElement
  external JSNumber getZIndex();

  external JSAny? get userData;

  external set userData(JSAny? value);
}

/// ---------------------------------------------------------------
/// Polygon — types/objects/polygon.d.ts
/// Внимание: НЕТ setCoordinates — геометрию после создания не
/// поменять, нужно destroy() и создать заново.
/// ---------------------------------------------------------------
@JS('mapgl.Polygon')
extension type MapglPolygon._(JSObject _) implements JSObject {
  external factory MapglPolygon(MapglMap map, JSAny options);

  external void destroy();

  external void on(JSString event, JSFunction handler);

  external void off(JSString event, JSFunction handler);

  external JSAny? get userData;

  external set userData(JSAny? value);
}

/// ---------------------------------------------------------------
/// Polyline — types/objects/polyline.d.ts
/// Тоже без setCoordinates, аналогично Polygon.
/// ---------------------------------------------------------------
@JS('mapgl.Polyline')
extension type MapglPolyline._(JSObject _) implements JSObject {
  external factory MapglPolyline(MapglMap map, JSAny options);

  external void destroy();

  external void on(JSString event, JSFunction handler);

  external void off(JSString event, JSFunction handler);

  external JSAny? get userData;

  external set userData(JSAny? value);
}

/// ---------------------------------------------------------------
/// LngLatBoundsClass — types/objects/lngLatBounds.d.ts
/// Удобно для fitBounds().
/// ---------------------------------------------------------------
@JS('mapgl.LngLatBoundsClass')
extension type MapglLngLatBounds._(JSObject _) implements JSObject {
  external factory MapglLngLatBounds(JSAny options); // { southWest, northEast }
}
