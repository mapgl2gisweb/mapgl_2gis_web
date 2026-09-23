// src/clusterer/clusterer_script_loader.dart

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import '../core/mapgl_logging.dart';
import '../core/script_loader.dart';

const String _kClustererScriptUrl = 'https://unpkg.com/@2gis/mapgl-clusterer@^2/dist/clustering.js';
const Duration _kScriptLoadTimeout = Duration(seconds: 20);

/// Loads the `@2gis/mapgl-clusterer` script.
///
/// Depends on `window.mapgl` already being available — call this only after
/// the main MapGL script has loaded.
abstract interface class ClustererScriptLoader {
  Future<void> ensureLoaded();
}

// Default implementation of [ClustererScriptLoader].
///
/// Delegates to [ScriptLoaderBase], which handles injection, readiness
/// polling, and timeout handling. The specific readiness probe checks that
/// `window.mapgl.Clusterer` exists.
class DefaultClustererScriptLoader extends ScriptLoaderBase implements ClustererScriptLoader {
  DefaultClustererScriptLoader() : super(scriptUrl: _kClustererScriptUrl, label: 'clusterer');

  /// Process-wide singleton, used unless a caller provides its own loader.
  static final DefaultClustererScriptLoader shared = DefaultClustererScriptLoader();

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
      logMapgl('clusterer already available');
      return;
    }

    final existing = web.document.querySelector('script[src="$_kClustererScriptUrl"]');
    if (existing != null) {
      logMapgl('clusterer <script> already in DOM — waiting for mapgl.Clusterer');
      await _waitForGlobal();
      return;
    }

    logMapgl('injecting clusterer <script>');
    await _injectScript();
    await _waitForGlobal();
  }

  Future<void> _injectScript() {
    final completer = Completer<void>();
    final script = web.HTMLScriptElement()
      ..src = _kClustererScriptUrl
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
          completer.completeError(StateError('Clusterer script load failed'));
        }
      }.toJS,
    );

    web.document.head!.append(script);

    return completer.future.timeout(
      _kScriptLoadTimeout,
      onTimeout: () {
        cleanup();
        throw TimeoutException('Clusterer script load timeout');
      },
    );
  }

  /// Polls until `window.mapgl.Clusterer` becomes available, or the timeout
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
      completer.completeError(TimeoutException('mapgl.Clusterer did not appear in time'));
    });

    return completer.future;
  }

  bool _isReady() {
    if (!web.window.hasProperty('mapgl'.toJS).toDart) return false;
    final mapgl = web.window.getProperty('mapgl'.toJS);
    if (!mapgl.isA<JSObject>()) return false;
    return (mapgl as JSObject).hasProperty('Clusterer'.toJS).toDart;
  }

  @override
  bool isReady() {
    final mapgl = getWindowObject('mapgl');
    return mapgl != null && mapgl.hasProperty('Clusterer'.toJS).toDart;
  }
}
