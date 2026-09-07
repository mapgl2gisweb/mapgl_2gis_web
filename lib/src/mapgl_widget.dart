// mapgl_widget.dart

import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;
import 'mapgl_bindings.dart';
import 'mapgl_controller.dart';

typedef MapCreatedCallback = void Function(MapglController controller);
typedef MapReadyCallback = void Function();

/// Базовый виджет карты. Создаёт HTML-элемент, загружает скрипт MapGL,
/// управляет жизненным циклом карты и контроллера.
class MapGlWidget extends StatefulWidget {
  const MapGlWidget({
    super.key,
    required this.apiKey,
    this.styleId,
    required this.initialCenter,
    this.initialZoom = 13,
    this.backgroundColor,
    this.onMapCreated,
    this.onMapReady,
  });

  /// Ключ API 2ГИС (обязательный).
  final String apiKey;

  /// Идентификатор стиля карты (опционально, если нужен нестандартный стиль).
  final String? styleId;

  /// Начальный центр карты [lng, lat].
  final List<double> initialCenter;

  /// Начальный зум (дробное число допустимо).
  final double initialZoom;

  /// Цвет фона, пока грузятся тайлы (defaultBackgroundColor у MapGL).
  final String? backgroundColor;

  /// Вызывается сразу после создания карты и контроллера.
  /// Контроллер можно сохранить и использовать для управления картой.
  final MapCreatedCallback? onMapCreated;

  /// Вызывается, когда карта полностью отрисована (событие 'idle').
  /// Полезно для скрытия собственных индикаторов загрузки.
  final MapReadyCallback? onMapReady;

  @override
  State<MapGlWidget> createState() => _MapGlWidgetState();
}

// Глобальные переменные для загрузки скрипта (общие для всех экземпляров)
bool _scriptInjected = false;
Future<void>? _scriptLoadFuture;

Future<void> _ensureMapglLoaded() {
  if (_scriptLoadFuture != null) return _scriptLoadFuture!;
  if (_scriptInjected) return Future.value();
  _scriptInjected = true;

  final completer = Completer<void>();
  final script = web.HTMLScriptElement()
    ..src = 'https://mapgl.2gis.com/api/js/v1'
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
      if (!completer.isCompleted) completer.completeError('mapgl load failed');
    }.toJS,
  );

  web.document.head!.append(script);
  _scriptLoadFuture = completer.future;
  return _scriptLoadFuture!;
}

/// Прогрев скрипта MapGL: можно вызвать заранее, чтобы ускорить первый показ.
void warmUpMapgl() => _ensureMapglLoaded();

class _MapGlWidgetState extends State<MapGlWidget> {
  late final String _viewType;
  late final web.HTMLDivElement _mapDiv;
  MapglController? _controller;
  late final Zone _flutterZone;
  Size? _lastSize;
  Timer? _resizeDebounce;

  @override
  void initState() {
    super.initState();
    _flutterZone = Zone.current;
    _viewType = 'mapgl-view-${identityHashCode(this)}';
    _mapDiv = web.HTMLDivElement()
      ..style.width = '100%'
      ..style.height = '100%';

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _mapDiv,
    );

    _ensureMapglLoaded().then((_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _createMap();
      });
    }).catchError((Object e) {
      debugPrint('Ошибка загрузки MapGL: $e');
    });
  }

  void _createMap() {
    final options = {
      'center': widget.initialCenter.map((v) => v.toJS).toList().jsify(),
      'zoom': widget.initialZoom,
      'key': widget.apiKey,
      if (widget.styleId != null) 'style': widget.styleId,
      if (widget.backgroundColor != null) 'defaultBackgroundColor': widget.backgroundColor,
    }.jsify()!;

    final map = MapglMap(_mapDiv as JSAny, options);

    // Обработка события idle (карта готова)
    late final JSFunction handler;
    handler = (JSAny? _) {
      _flutterZone.run(() {
        if (mounted) {
          widget.onMapReady?.call();
          WidgetsBinding.instance.scheduleFrame();
        }
      });
      map.off('idle'.toJS, handler);
    }.toJS;
    map.on('idle'.toJS, handler);

    final controller = MapglController.internalCreate(map);
    _flutterZone.run(() {
      setState(() => _controller = controller);
      widget.onMapCreated?.call(controller);
    });
  }

  @override
  void dispose() {
    _resizeDebounce?.cancel();
    _mapDiv.remove(); // явно удаляем DOM-элемент
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite ? constraints.maxWidth.round() : 800;
        final height = constraints.maxHeight.isFinite ? constraints.maxHeight.round() : 600;

        final newSize = Size(width.toDouble(), height.toDouble());
        if (_lastSize != null && _lastSize != newSize && _controller != null) {
          _resizeDebounce?.cancel();
          _resizeDebounce = Timer(const Duration(milliseconds: 150), () {
            _controller?.invalidateSize();
          });
        }
        _lastSize = newSize;

        return RepaintBoundary(
          child: HtmlElementView(viewType: _viewType),
        );
      },
    );
  }
}
