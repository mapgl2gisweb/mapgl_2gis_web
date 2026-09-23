// src/widgets/mapgl_widget.dart

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:math' as math;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../controllers/map_controller.dart';
import '../core/mapgl_logging.dart';
import '../core/script_loader.dart';

/// Called once the map controller has been created.
typedef MapCreatedCallback = void Function(MapController controller);

/// Called when the map has finished its initial load and is idle.
typedef MapReadyCallback = void Function();

/// Called when the map failed to load — either the JS script could not be
/// fetched, or the map itself failed to initialise.
typedef MapLoadFailedCallback = void Function(Object error, StackTrace stackTrace);

const String _kMapglScriptUrl = 'https://mapgl.2gis.com/api/js/v1';
const Duration _kScriptLoadTimeout = Duration(seconds: 20);
const Duration _kGlobalWaitTimeout = Duration(seconds: 30);
const Duration _kResizeDebounce = Duration(milliseconds: 50);

/// Loads the MapGL JS script.
///
/// The default implementation is idempotent and safe to call from multiple
/// widgets concurrently.
abstract interface class MapglScriptLoader {
  Future<void> ensureLoaded();
}

/// Default implementation of [MapglScriptLoader].
///
/// Concurrent calls share a single in-flight future; a failed attempt is
/// retried on the next call.
class DefaultMapglScriptLoader extends ScriptLoaderBase implements MapglScriptLoader {
  DefaultMapglScriptLoader() : super(scriptUrl: _kMapglScriptUrl, label: 'MapGL');

  /// Process-wide singleton, used unless a caller provides its own loader.
  static final DefaultMapglScriptLoader shared = DefaultMapglScriptLoader();

  Future<void>? _pending;

  @override
  Future<void> ensureLoaded() {
    final existing = _pending;
    if (existing != null) return existing;

    final future = _load().catchError((Object e, StackTrace st) {
      // Allow a retry on the next call.
      _pending = null;
      throw e;
    });

    _pending = future;
    return future;
  }

  Future<void> _load() async {
    if (_isReady()) {
      logMapgl('window.mapgl already available');
      return;
    }

    final existing = web.document.querySelector('script[src="$_kMapglScriptUrl"]');
    if (existing != null) {
      logMapgl('<script> already in DOM — waiting for mapgl');
      await _waitForGlobal();
      return;
    }

    logMapgl('injecting <script>');
    await _injectScript();
    await _waitForGlobal();
  }

  Future<void> _injectScript() {
    final completer = Completer<void>();
    final script = web.HTMLScriptElement()
      ..src = _kMapglScriptUrl
      ..type = 'text/javascript';

    void cleanup() {
      try {
        script.remove();
      } catch (_) {
        // Ignore: the script may already be detached.
      }
    }

    script.addEventListener(
      'load',
      (web.Event _) {
        if (!completer.isCompleted) completer.complete();
      }.toJS,
    );
    script.addEventListener(
      'error',
      (web.Event _) {
        cleanup();
        if (!completer.isCompleted) {
          completer.completeError(StateError('MapGL script load failed'));
        }
      }.toJS,
    );

    web.document.head!.append(script);

    return completer.future.timeout(
      _kScriptLoadTimeout,
      onTimeout: () {
        cleanup();
        throw TimeoutException('MapGL script load timeout');
      },
    );
  }

  /// Polls until `window.mapgl.Map` becomes available, or the timeout
  /// elapses.
  Future<void> _waitForGlobal() {
    if (_isReady()) return Future.value();

    final completer = Completer<void>();
    late final Timer poll;
    late final Timer timeout;

    poll = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (completer.isCompleted) return;
      if (_isReady()) {
        poll.cancel();
        timeout.cancel();
        completer.complete();
      }
    });

    timeout = Timer(_kScriptLoadTimeout, () {
      if (completer.isCompleted) return;
      poll.cancel();
      completer.completeError(TimeoutException('window.mapgl did not appear in time'));
    });

    return completer.future;
  }

  bool _isReady() {
    if (!web.window.hasProperty('mapgl'.toJS).toDart) return false;
    final mapgl = web.window.getProperty('mapgl'.toJS);
    if (!mapgl.isA<JSObject>()) return false;
    return (mapgl as JSObject).hasProperty('Map'.toJS).toDart;
  }

  @override
  bool isReady() {
    final mapgl = getWindowObject('mapgl');
    return mapgl != null && mapgl.hasProperty('Map'.toJS).toDart;
  }
}

/// Preloads the MapGL script.
///
/// Errors are only logged — the widget retries loading on its own, so call
/// sites do not need to await this.
Future<void> warmUpMapgl({MapglScriptLoader? loader}) =>
    (loader ?? DefaultMapglScriptLoader.shared).ensureLoaded().catchError((Object e, StackTrace st) {
      logMapgl('warmUp failed (non-fatal, widget will retry): $e');
    });

/// A Flutter Web widget that hosts a MapGL map.
///
/// The widget owns the platform view, injects the MapGL script on first use,
/// creates a [MapController] once the underlying DOM container is mounted,
/// and forwards lifecycle callbacks back to the host application.
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
    this.onMapLoadFailed,
    this.scriptLoader,
  });

  /// MapGL API key.
  final String apiKey;

  /// Optional style id; when omitted the default 2GIS style is used.
  final String? styleId;

  /// Initial center in `[lng, lat]` order.
  final List<double> initialCenter;

  /// Initial zoom level.
  final double initialZoom;

  /// Optional background color shown while the style is loading.
  final String? backgroundColor;

  /// Called once the [MapController] has been created.
  final MapCreatedCallback? onMapCreated;

  /// Called once the map has finished its initial load.
  final MapReadyCallback? onMapReady;

  /// Called if loading the script or initialising the map fails.
  final MapLoadFailedCallback? onMapLoadFailed;

  /// Optional override of the script loader (e.g. for tests).
  final MapglScriptLoader? scriptLoader;

  @override
  State<MapGlWidget> createState() => _MapGlWidgetState();
}

class _MapGlWidgetState extends State<MapGlWidget> {
  static const String _hostBaseClass = 'mapgl-host';

  late final String _viewType;
  late final String _hostUniqueClass;
  late final MapglScriptLoader _scriptLoader;
  late final Zone _flutterZone;

  final Completer<web.HTMLDivElement> _divCompleter = Completer();

  MapController? _controller;
  web.ResizeObserver? _resizeObserver;
  Timer? _resizeDebounce;
  bool _createMapRequested = false;

  @override
  void initState() {
    super.initState();
    logMapgl('initState()');

    _flutterZone = Zone.current;
    _scriptLoader = widget.scriptLoader ?? DefaultMapglScriptLoader.shared;

    // Generate a unique view type and host class so multiple MapGlWidget
    // instances can coexist without colliding on the platform-view registry
    // or on the DOM.
    final salt = '${DateTime.now().microsecondsSinceEpoch}-${math.Random().nextInt(1 << 30)}';
    _viewType = 'mapgl-view-$salt';
    _hostUniqueClass = '$_hostBaseClass-$salt';

    ui_web.platformViewRegistry.registerViewFactory(_viewType, _onCreateDiv);

    _scriptLoader
        .ensureLoaded()
        .then((_) {
          if (!mounted) return;
          WidgetsBinding.instance.scheduleFrame();
          _scheduleCreateMap();
        })
        .catchError((Object e, StackTrace st) {
          logMapgl('script load failed: $e');
          _emitLoadFailed(e, st);
        });
  }

  web.HTMLDivElement _onCreateDiv(int viewId) {
    logMapgl('factory called, viewId=$viewId');

    final div = web.HTMLDivElement()
      ..className = '$_hostBaseClass $_hostUniqueClass'
      ..style.width = '100%'
      ..style.height = '100%';

    if (!_divCompleter.isCompleted) {
      _divCompleter.complete(div);
    }
    return div;
  }

  void _scheduleCreateMap() {
    if (_createMapRequested) return;

    _divCompleter.future
        .timeout(
          _kGlobalWaitTimeout,
          onTimeout: () => throw TimeoutException(
            'Flutter did not call registerViewFactory within '
            '${_kGlobalWaitTimeout.inSeconds}s (HtmlElementView never mounted?)',
          ),
        )
        .then((div) {
          if (!mounted || _createMapRequested) return;
          _createMapRequested = true;
          _attachResizeObserver(div);
          _createMap(div);
        })
        .catchError((Object e, StackTrace st) {
          if (!mounted) return;
          logMapgl('_scheduleCreateMap failed: $e');
          _emitLoadFailed(e, st);
        });
  }

  void _createMap(web.HTMLDivElement container) {
    final r = container.getBoundingClientRect();
    logMapgl('_createMap(): div ${r.width}×${r.height}, connected=${container.isConnected}');

    final controller = MapController.create(container: container as JSAny, options: _buildOptions());

    controller.whenReady
        .then((_) {
          if (!mounted) return;
          _flutterZone.run(() {
            widget.onMapReady?.call();
          });
        })
        .catchError((Object e, StackTrace st) {
          logMapgl('whenReady failed: $e');
          _emitLoadFailed(e, st);
        });

    _flutterZone.run(() {
      setState(() => _controller = controller);
      widget.onMapCreated?.call(controller);
    });
  }

  JSObject _buildOptions() {
    return {
          'center': widget.initialCenter.map((v) => v.toJS).toList().jsify(),
          'zoom': widget.initialZoom,
          'key': widget.apiKey,
          if (widget.styleId != null) 'style': widget.styleId,
          if (widget.backgroundColor != null) 'defaultBackgroundColor': widget.backgroundColor,
        }.jsify()!
        as JSObject;
  }

  void _attachResizeObserver(web.HTMLDivElement container) {
    _resizeObserver = web.ResizeObserver(
      ((JSArray<JSObject> _, JSObject __) {
        _scheduleInvalidateSize();
      }).toJS,
    );
    _resizeObserver!.observe(container);
  }

  void _scheduleInvalidateSize() {
    _resizeDebounce?.cancel();
    _resizeDebounce = Timer(_kResizeDebounce, () {
      if (!mounted) return;
      final controller = _controller;
      if (controller == null) return;
      try {
        controller.invalidateSize();
      } catch (e) {
        logMapgl('invalidateSize after dispose ignored: $e');
      }
    });
  }

  void _emitLoadFailed(Object error, StackTrace stackTrace) {
    _flutterZone.run(() {
      widget.onMapLoadFailed?.call(error, stackTrace);
    });
  }

  @override
  void dispose() {
    logMapgl('dispose()');
    _resizeDebounce?.cancel();
    _resizeObserver?.disconnect();
    _resizeObserver = null;

    if (!_divCompleter.isCompleted) {
      _divCompleter.completeError(StateError('MapGlWidget disposed before factory called'));
    }

    _controller?.dispose();

    web.document.querySelector('.$_hostUniqueClass')?.remove();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(key: ValueKey(_viewType), viewType: _viewType);
  }
}
