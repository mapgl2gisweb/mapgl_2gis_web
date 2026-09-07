// mapgl_controller.dart

import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:web/web.dart' as web;
import 'mapgl_bindings.dart';
import 'mapgl_clusterer_bindings.dart';

/// Скрипт клюстерера — отдельный от core MapGL, грузим лениво, только
/// когда кластеризация реально понадобилась (не при каждом старте
/// карты — многим экранам она вообще не нужна).
bool _clustererScriptInjected = false;
Future<void>? _clustererScriptLoadFuture;

Future<void> _ensureClustererLoaded() {
  if (_clustererScriptLoadFuture != null) return _clustererScriptLoadFuture!;
  if (_clustererScriptInjected) return Future.value();
  _clustererScriptInjected = true;

  final completer = Completer<void>();
  final script = web.HTMLScriptElement()
    ..src = 'https://unpkg.com/@2gis/mapgl-clusterer@^2/dist/clustering.js'
    ..type = 'text/javascript';

  script.addEventListener(
    'load',
    (web.Event _) {
      if (!completer.isCompleted) completer.complete();
    }.toJS,
  );
  script.addEventListener(
    'error',
    (web.Event _) {
      if (!completer.isCompleted) {
        completer.completeError('clusterer script load failed');
      }
    }.toJS,
  );

  web.document.head!.append(script);
  _clustererScriptLoadFuture = completer.future;
  return _clustererScriptLoadFuture!;
}

class MapglController {
  MapglController._(this._map);

  final MapglMap _map;

  /// Живые объекты, которые контроллер создал сам — нужно для
  /// корректной очистки в dispose(), чтобы не плодить утечки при
  /// пересоздании карты (hot reload, смена вкладки и т.п.).
  final List<MapglMarker> _markers = [];
  final List<MapglHtmlMarker> _htmlMarkers = [];
  final List<MapglPolygon> _polygons = [];
  final List<MapglPolyline> _polylines = [];
  MapglClusterer? _clusterer;

  /// Прямой доступ к "сырому" объекту карты — на случай, если
  /// понадобится метод, для которого пока нет удобной обёртки в
  /// контроллере.
  MapglMap get raw => _map;

  // ---------------- Камера ----------------

  void setCenter(List<double> center, {bool animate = false, int durationMs = 300}) {
    _map.setCenter(center.map((v) => v.toJS).toList().toJS, animate ? {'duration': durationMs}.jsify() : null);
  }

  List<double> getCenter() => _map.getCenter().toDart.map((v) => v.toDartDouble).toList();

  void setZoom(double zoom, {bool animate = false, int durationMs = 300}) {
    _map.setZoom(zoom.toJS, animate ? {'duration': durationMs}.jsify() : null);
  }

  double getZoom() => _map.getZoom().toDartDouble;

  /// Просит MapGL заново измерить размер своего контейнера и
  /// перерисоваться. Нужно вызывать вручную при ресайзе окна —
  /// внутри Flutter Web (Shadow DOM платформенных view) встроенный
  /// в MapGL ResizeObserver не всегда ловит изменение размера
  /// контейнера сам по себе.
  void invalidateSize() => _map.invalidateSize();

  // ---------------- Маркеры ----------------

  /// Обычный (WebGL) маркер — производительнее HtmlMarker, но
  /// внешний вид ограничен иконкой/лейблом.
  MapglMarker addMarker({
    required List<double> coordinates,
    String? icon,
    List<double>? size,
    Map<String, dynamic>? userData,
    void Function()? onClick,
  }) {
    final options = {
      'coordinates': coordinates.map((v) => v.toJS).toList().jsify(),
      if (icon != null) 'icon': icon,
      if (size != null) 'size': size.map((v) => v.toJS).toList().jsify(),
      if (userData != null) 'userData': userData.jsify(),
    }.jsify()!;

    final marker = MapglMarker(_map, options);
    if (onClick != null) {
      marker.on('click'.toJS, ((JSAny? _) => onClick()).toJS);
    }
    _markers.add(marker);
    return marker;
  }

  void removeMarker(MapglMarker marker) {
    marker.destroy();
    _markers.remove(marker);
  }

  /// HTML-маркер — свободная кастомная вёрстка (например, круглая
  /// плашка с числом свободных мест), но чуть менее производителен
  /// при больших количествах.
  MapglHtmlMarker addHtmlMarker({required List<double> coordinates, required String html, List<double>? anchor}) {
    final options = {
      'coordinates': coordinates.map((v) => v.toJS).toList().jsify(),
      'html': html,
      if (anchor != null) 'anchor': anchor.map((v) => v.toJS).toList().jsify(),
    }.jsify()!;

    final marker = MapglHtmlMarker(_map, options);
    _htmlMarkers.add(marker);
    return marker;
  }

  void removeHtmlMarker(MapglHtmlMarker marker) {
    marker.destroy();
    _htmlMarkers.remove(marker);
  }

  // ---------------- Попап (всплывающая подсказка) ----------------
  //
  // У MapGL нет отдельного класса Popup (проверено по реальным .d.ts —
  // такого API не существует, хотя раньше я сам ошибочно его
  // упоминал). Реализуем через HtmlMarker: произвольная HTML-вёрстка,
  // привязанная к географическим координатам — сама следует за картой
  // при панорамировании/зуме, ничего вручную пересчитывать не нужно.

  MapglHtmlMarker? _activePopup;
  JSFunction? _mapClickCloseHandler;

  /// Показывает попап в заданных координатах. Предыдущий открытый
  /// попап (если был) автоматически закрывается — на карте
  /// одновременно виден только один.
  ///
  /// Как рекомендует официальная документация 2ГИС
  /// (docs.2gis.com/mapgl/objects/popups, раздел "Взаимодействие с
  /// другими компонентами) — клик по самой карте (не по маркеру)
  /// закрывает попап автоматически.
  void showPopup({
    required List<double> coordinates,
    required String html,
    List<double> anchor = const [0.5, 1.15], // по умолчанию чуть выше точки
  }) {
    hidePopup();
    _activePopup = addHtmlMarker(coordinates: coordinates, html: html, anchor: anchor);

    // Подписываемся на клик по карте только пока попап открыт —
    // отписываемся сразу при закрытии, чтобы не плодить "мёртвые"
    // обработчики при многократном открытии/закрытии.
    _mapClickCloseHandler = ((JSAny? _) => hidePopup()).toJS;
    _map.on('click'.toJS, _mapClickCloseHandler!);
  }

  void hidePopup() {
    if (_mapClickCloseHandler != null) {
      _map.off('click'.toJS, _mapClickCloseHandler!);
      _mapClickCloseHandler = null;
    }
    if (_activePopup != null) {
      removeHtmlMarker(_activePopup!);
      _activePopup = null;
    }
  }

  bool get isPopupOpen => _activePopup != null;

  // ---------------- Клик по карте ----------------

  JSFunction? _mapClickHandler;

  /// Простой клик по самой карте — координаты клика плюс, если попали
  /// по встроенному объекту базовой карты (здание, POI), его данные.
  /// НЕ путать с onClustererClick — это разные механизмы: там клик по
  /// ВАШИМ маркерам/кластерам, здесь — по самой карте в любой точке
  /// (в т.ч. по пустому месту, тогда targetId/targetType будут null).
  ///
  /// ВАЖНО: если у вас уже открыт попап (showPopup), он тоже слушает
  /// клик по карте для автозакрытия — оба обработчика сработают
  /// независимо, JS EventEmitter поддерживает несколько подписчиков
  /// на одно событие без конфликта.
  void onMapClick(
    void Function(
      List<double> lngLat,
      List<double> point, {
      String? targetId,
      String? targetType, // 'default' | 'geojson', null если клик по пустому месту
      String? floorId,
    })
    onClick,
  ) {
    _mapClickHandler = ((JSAny? e) {
      final event = e as MapPointerEventJS;
      final lngLat = event.lngLat.toDart.map((v) => v.toDartDouble).toList();
      final point = event.point.toDart.map((v) => v.toDartDouble).toList();

      onClick(
        lngLat,
        point,
        targetId: event.targetData?.id?.toDart ?? event.target?.id.toDart,
        targetType: event.targetData?.type.toDart,
        floorId: event.targetData?.floorId?.toDart,
      );
    }).toJS;

    _map.on('click'.toJS, _mapClickHandler!);
  }

  /// Отписка — вызывайте, если подписывались через onMapClick и
  /// больше не нужно слушать клики (например, при переключении
  /// режима экрана). dispose() тоже снимет это автоматически.
  void offMapClick() {
    if (_mapClickHandler != null) {
      _map.off('click'.toJS, _mapClickHandler!);
      _mapClickHandler = null;
    }
  }

  // ---------------- Кластеризация ----------------

  /// Создаёт (или пересоздаёт) кластерер и загружает в него маркеры.
  /// Единственный способ обновить состав — вызвать снова с новым
  /// списком (у Clusterer нет поштучных add/remove — так устроен
  /// сам JS API).
  ///
  /// Скрипт @2gis/mapgl-clusterer грузится лениво при первом вызове —
  /// а не заранее для каждой карты, даже если кластеризация ей не
  /// нужна.
  ///
  /// [clusterIconBuilder], если задан, вызывается ДЛЯ КАЖДОГО
  /// кластера отдельно с числом точек внутри него — так цвет/размер
  /// "шарика" можно менять в зависимости от того, сколько парковок
  /// сгруппировано (например, 2-5 — зелёный, 20+ — красный). Если не
  /// задан — используется дефолтная зелёная точка самого MapGL.
  ///
  /// ВАЖНО (проверено по скомпилированному dist/clustering.js, не
  /// только по .d.ts): цвет "шарика" — это не отдельное свойство, а
  /// часть SVG/PNG-иконки в icon. labelColor красит только текст
  /// числа внутри, не фон.
  Future<void> setClusteredMarkers(
    List<Map<String, dynamic>> markers, {
    double radius = 60,
    String Function(int pointCount)? clusterIconBuilder,
    String labelColor = '#ffffff',
  }) async {
    await _ensureClustererLoaded();

    final clusterStyleOptions = clusterIconBuilder != null
        ? _buildDynamicClusterStyleFunction(clusterIconBuilder, labelColor)
        : null;

    _clusterer ??= MapglClusterer(
      _map,
      {'radius': radius, if (clusterStyleOptions != null) 'clusterStyle': clusterStyleOptions}.jsify(),
    );
    _clusterer!.load(markers.map((m) => m.jsify()).toList().toJS);
  }

  /// clusterStyle как JS-функция (pointCount, target) => styleObject —
  /// именно так, как ожидает сам MapGL для динамического стиля.
  JSFunction _buildDynamicClusterStyleFunction(String Function(int pointCount) iconBuilder, String labelColor) {
    return ((JSNumber pointCount, JSAny? _) {
      final count = pointCount.toDartInt;
      return {'icon': iconBuilder(count), 'labelColor': labelColor}.jsify();
    }).toJS;
  }

  void clearClusterer() {
    _clusterer?.destroy();
    _clusterer = null;
  }

  /// Общий разбор ClustererPointerEvent — используется и для hover,
  /// и для click. Возвращает (type, userData, point, lngLat);
  /// userData пуст для type == 'cluster' (там data — массив, не один
  /// объект). lngLat — географические координаты клика, доступны
  /// всегда (и для marker, и для cluster) — удобно для showPopup,
  /// не нужно отдельно тащить координаты через userData.
  ({String type, Map<String, dynamic> userData, List<double> point, List<double> lngLat}) _parseClustererEvent(
    JSAny? e,
  ) {
    final event = e as ClustererPointerEventJS;
    final targetType = event.target.type.toDart;
    final point = event.point.toDart.map((v) => v.toDartDouble).toList();
    final lngLat = event.lngLat.toDart.map((v) => v.toDartDouble).toList();

    Map<String, dynamic> userData = {};
    final rawData = event.target.data;
    if (rawData != null && targetType == 'marker') {
      final dataMap = rawData.dartify();
      if (dataMap is Map) {
        final rawUserData = dataMap['userData'];
        if (rawUserData is Map) {
          userData = Map<String, dynamic>.from(rawUserData);
        }
      }
    }

    return (type: targetType, userData: userData, point: point, lngLat: lngLat);
  }

  /// Подписка на hover по маркерам/кластерам ВНУТРИ Clusterer.
  /// Так как отдельные Marker-объекты внутри Clusterer недоступны
  /// напрямую (вы передаёте обычные Map, а не MapglMarker), tooltip
  /// на кластеризованных маркерах делается именно так — через
  /// mouseover/mouseout самого Clusterer, а не marker.on(...).
  ///
  /// [onEnter] получает userData (то же, что вы положили в
  /// 'userData' при setClusteredMarkers) и point — пиксельные
  /// координаты события ВНУТРИ контейнера карты (те же единицы, что
  /// размер самого MapWidget — можно использовать напрямую в
  /// Positioned).
  ///
  /// [onlyIndividualMarkers] — если true (по умолчанию), событие
  /// игнорируется для кластеров (target.type == 'cluster'), тултип
  /// сработает только на одиночных, ещё не сгруппированных
  /// маркерах. Установите false, если хотите tooltip и на кластерах
  /// тоже (например, "5 парковок поблизости").
  ///
  /// ВАЖНО: требует, чтобы setClusteredMarkers уже был вызван хотя
  /// бы раз (иначе _clusterer ещё null) — вызывайте после него.
  void onClustererHover({
    required void Function(Map<String, dynamic> userData, List<double> point) onEnter,
    required void Function() onLeave,
    bool onlyIndividualMarkers = true,
  }) {
    final clusterer = _clusterer;
    if (clusterer == null) {
      throw StateError('onClustererHover вызван до setClusteredMarkers — кластерер ещё не создан.');
    }

    clusterer.on(
      'mouseover'.toJS,
      ((JSAny? e) {
        final parsed = _parseClustererEvent(e);
        if (onlyIndividualMarkers && parsed.type != 'marker') return;
        onEnter(parsed.userData, parsed.point);
      }).toJS,
    );

    clusterer.on('mouseout'.toJS, ((JSAny? _) => onLeave()).toJS);
  }

  Timer? _clustererClickDebounce;

  /// Клик по маркеру/кластеру ВНУТРИ Clusterer — то, чего не хватало
  /// для попапа/действия по нажатию на кластеризованные маркеры
  /// (addMarker(onClick:...) сюда не относится — это разные объекты).
  ///
  /// [onMarkerClick] — клик по отдельному (ещё не сгруппированному)
  /// маркеру, получает тот же userData, что и в setClusteredMarkers,
  /// плюс координаты клика [lng, lat] — удобно сразу передать в
  /// showPopup, не тащить координаты отдельно через userData.
  ///
  /// [onClusterClick] — клик по объединённому кластеру. Если не
  /// задан — по умолчанию карта зумится внутрь кластера
  /// (getClusterExpansionZoom), центрируясь на его координатах —
  /// стандартное ожидаемое поведение "клик по кластеру = приблизить".
  ///
  /// ВАЖНО: у MapGL нет опции отключить встроенный zoom по двойному
  /// клику (проверено — такой опции нет ни в setOption, ни в
  /// MapOptions). Значит быстрый двойной клик по маркеру/кластеру
  /// одновременно даст: (а) два срабатывания click здесь и (б)
  /// нативный zoom-по-двойному-клику самой карты — может выглядеть
  /// как "дёрганое" поведение. Debounce ниже (250мс) откладывает
  /// срабатывание одиночного клика: если за это время пришёл второй
  /// клик — трактуем это как двойной клик и НЕ вызываем колбэки
  /// вообще, отдавая происходящее целиком нативному zoom карты.
  void onClustererClick({
    void Function(Map<String, dynamic> userData, List<double> lngLat)? onMarkerClick,
    void Function(int clusterId, List<double> coordinates)? onClusterClick,
    Duration doubleClickThreshold = const Duration(milliseconds: 250),

    /// Длительность анимации камеры (pan+zoom) при дефолтном
    /// поведении "клик по кластеру = приблизить" (когда onClusterClick
    /// не задан). По умолчанию 300мс — можно увеличить, если хочется
    /// визуально сгладить разрыв между окончанием движения камеры и
    /// моментом, когда Clusterer покажет раздельные маркеры (это
    /// отдельная, независимая стадия — см. onClustererClick doc выше).
    Duration clusterZoomDuration = const Duration(milliseconds: 300),
  }) {
    final clusterer = _clusterer;
    if (clusterer == null) {
      throw StateError('onClustererClick вызван до setClusteredMarkers — кластерер ещё не создан.');
    }

    clusterer.on(
      'click'.toJS,
      ((JSAny? e) {
        debugPrint('[MapGL] raw click event received from Clusterer');

        // Если в течение doubleClickThreshold пришёл второй клик —
        // это был двойной клик: отменяем отложенную обработку
        // первого и НЕ считаем это одиночным кликом вообще.
        if (_clustererClickDebounce != null) {
          _clustererClickDebounce!.cancel();
          _clustererClickDebounce = null;
          return;
        }

        _clustererClickDebounce = Timer(doubleClickThreshold, () {
          _clustererClickDebounce = null;
          _handleClustererClick(e, onMarkerClick, onClusterClick, clusterZoomDuration);
        });
      }).toJS,
    );
  }

  void _handleClustererClick(
    JSAny? e,
    void Function(Map<String, dynamic> userData, List<double> lngLat)? onMarkerClick,
    void Function(int clusterId, List<double> coordinates)? onClusterClick,
    Duration clusterZoomDuration,
  ) {
    try {
      final event = e as ClustererPointerEventJS;
      final parsed = _parseClustererEvent(e);
      final clusterer = _clusterer!;

      debugPrint('[MapGL] clusterer click: type=${parsed.type}');

      if (parsed.type == 'marker') {
        onMarkerClick?.call(parsed.userData, parsed.lngLat);
        return;
      }

      final clusterId = event.target.id;
      debugPrint('[MapGL] cluster click: id=$clusterId');

      if (clusterId == null) {
        debugPrint('[MapGL] cluster click: target.id отсутствует — событие не распознано как кластер');
        return;
      }

      final lngLat = event.lngLat.toDart.map((v) => v.toDartDouble).toList();

      if (onClusterClick != null) {
        onClusterClick(clusterId.toDartInt, lngLat);
      } else {
        final expansionZoom = clusterer.getClusterExpansionZoom(clusterId).toDartInt;
        final durationMs = clusterZoomDuration.inMilliseconds;
        debugPrint('[MapGL] expanding cluster to zoom=$expansionZoom at $lngLat, duration=${durationMs}ms');
        setCenter(lngLat, animate: true, durationMs: durationMs);
        setZoom(expansionZoom.toDouble(), animate: true, durationMs: durationMs);
      }
    } catch (err, st) {
      // Раньше исключение здесь (например, из getClusterExpansionZoom)
      // просто терялось — Timer-колбэк асинхронный, необработанная
      // ошибка в нём не ломает видимо ничего, а тихо уходит в
      // консоль/теряется, создавая впечатление "клик ничего не даёт".
      debugPrint('[MapGL] Ошибка обработки клика по кластеру: $err\n$st');
    }
  }

  // ---------------- Полигоны / линии ----------------

  MapglPolygon addPolygon({required List<List<List<double>>> rings, String? color, String? strokeColor}) {
    final options = {
      'coordinates': rings
          .map((ring) => ring.map((p) => p.map((v) => v.toJS).toList().jsify()).toList().jsify())
          .toList()
          .jsify(),
      if (color != null) 'color': color,
      if (strokeColor != null) 'strokeColor': strokeColor,
    }.jsify()!;

    final polygon = MapglPolygon(_map, options);
    _polygons.add(polygon);
    return polygon;
  }

  MapglPolyline addPolyline({required List<List<double>> coordinates, String? color, double? width}) {
    final options = {
      'coordinates': coordinates.map((p) => p.map((v) => v.toJS).toList().jsify()).toList().jsify(),
      if (color != null) 'color': color,
      if (width != null) 'width': width,
    }.jsify()!;

    final polyline = MapglPolyline(_map, options);
    _polylines.add(polyline);
    return polyline;
  }

  /// Рисует набор отдельных отрезков (например, itudes парковки) как
  /// несколько Polyline одним вызовом. Возвращает список созданных
  /// объектов — сохраните его, если нужно будет убрать именно эти
  /// сегменты позже (removeMarker-подобного метода для Polyline нет,
  /// вызывайте .destroy() на каждом из списка вручную и уберите его
  /// из результата этой функции самостоятельно, либо используйте
  /// dispose() всего контроллера, который уберёт все сразу).
  List<MapglPolyline> addBoundarySegments(List<List<List<double>>> segments, {String? color, double? width}) {
    return segments.map((segment) => addPolyline(coordinates: segment, color: color, width: width)).toList();
  }

  // ---------------- Жизненный цикл ----------------

  /// Уничтожает карту и всё, что контроллер создал сам.
  /// Обязательно вызывайте в dispose() владеющего State.
  void dispose() {
    hidePopup(); // снимет обработчик клика по карте, если попап был открыт
    offMapClick();
    _clustererClickDebounce?.cancel();
    for (final m in _markers) {
      m.destroy();
    }
    for (final m in _htmlMarkers) {
      m.destroy();
    }
    for (final p in _polygons) {
      p.destroy();
    }
    for (final p in _polylines) {
      p.destroy();
    }
    _clusterer?.destroy();
    _map.destroy();
  }

  /// Фабрика — вызывается изнутри MapWidget после успешной
  /// инициализации карты. Не предназначена для прямого вызова из
  /// пользовательского кода.
  static MapglController internalCreate(MapglMap map) => MapglController._(map);
}
