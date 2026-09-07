// mapgl_clusterer_bindings.dart

import 'dart:js_interop';
import 'mapgl_bindings.dart' show MapglMap;

@JS('mapgl.Clusterer')
extension type MapglClusterer._(JSObject _) implements JSObject {
  /// options — необязательный объект { radius, clusterStyle, disableClusteringAtZoom }
  external factory MapglClusterer(MapglMap map, [JSAny? options]);

  /// ЕДИНСТВЕННЫЙ способ задать/обновить набор маркеров — целиком.
  /// Каждый элемент массива — объект вида:
  ///   { coordinates: [lng, lat], icon: '...', userData: {...} }
  /// либо HTML-вариант: { type: 'html', coordinates: [...], html: '...' }
  external void load(JSArray<JSAny?> input);

  external void destroy();

  /// Изменить стиль конкретного кластера по его id (из события клика).
  external void setClusterStyle(JSNumber clusterId, JSAny clusterStyleOrFn);
  external void resetClusterStyle(JSNumber clusterId);

  /// Zoom, при котором конкретный кластер "распадается" на отдельные маркеры.
  external JSNumber getClusterExpansionZoom(JSNumber clusterId);

  /// От базового Evented<ClustererEventTable>:
  /// click, mousemove, mouseover, mouseout, mousedown, mouseup,
  /// touchstart, touchend — общие для маркеров и кластеров внутри.
  /// В обработчике e.target.type различает 'marker' | 'cluster'.
  external void on(JSString event, JSFunction handler);
  external void off(JSString event, JSFunction handler);
  external void once(JSString event, JSFunction handler);

  /// От Evented — ручной вызов обработчиков события. Редко нужен
  /// потребителю API напрямую (обычно события эмитит сама
  /// библиотека), но формально публичный метод — добавлен для
  /// полноты.
  external void emit(JSString event, [JSAny? data]);
}

/// Читает поля события ClustererPointerEvent (click/mouseover/mouseout
/// и т.д.) — point (пиксельные координаты в контейнере карты),
/// target.type ('marker' | 'cluster'), target.userData.
@JS()
extension type ClustererPointerEventJS._(JSObject _) implements JSObject {
  external JSArray<JSNumber> get point;
  external JSArray<JSNumber> get lngLat;
  external ClustererEventTargetJS get target;
}

@JS()
extension type ClustererEventTargetJS._(JSObject _) implements JSObject {
  external JSString get type; // 'marker' | 'cluster'

  /// Есть только у ClusterTarget (type == 'cluster'), у MarkerTarget
  /// отсутствует — для маркеров не читайте это поле.
  external JSNumber? get id;

  /// ВАЖНО: несмотря на то что официальные .d.ts объявляют отдельное
  /// поле `target.userData`, по факту (проверено по скомпилированному
  /// dist/clustering.js версии 2.5.2) такого поля в рантайме НЕТ.
  /// Реально `target.data` — это весь исходный объект маркера,
  /// который вы передали в load(), включая userData внутри него:
  /// target.data.userData, а не target.userData напрямую.
  ///
  /// Для marker: data — один объект (тот самый inputMarker).
  /// Для cluster: data — массив объектов (все inputMarker внутри
  /// кластера).
  external JSAny? get data;
}