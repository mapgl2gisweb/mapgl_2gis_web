// src/core/script_loader.dart

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import 'mapgl_logging.dart';

/// Common base for lazy, idempotent loaders of external JS scripts.
///
/// Subclasses provide the script URL, the readiness probe, and a human
/// readable label used in log messages. This class implements the shared
/// lifecycle: inject the `<script>` once, wait for the global to appear,
/// time out after a configurable interval, and allow a retry on failure.
///
/// Concrete subclasses are expected to expose their own singleton
/// (e.g. `DefaultMapglScriptLoader.shared`) and simply call [ensureLoaded].
abstract class ScriptLoaderBase {
  ScriptLoaderBase({
    required this.scriptUrl,
    required this.label,
    this.timeout = const Duration(seconds: 20),
    this.pollInterval = const Duration(milliseconds: 50),
  });

  /// Absolute URL of the script to inject.
  final String scriptUrl;

  /// Human-readable name used in log messages, e.g. `"MapGL"` or
  /// `"clusterer"`.
  final String label;

  /// Maximum time to wait for the script to load and the global to appear.
  final Duration timeout;

  /// Interval between readiness polls while waiting for the global.
  final Duration pollInterval;

  Future<void>? _pending;

  /// Resolves once the script is loaded and the global is available.
  ///
  /// Idempotent: concurrent calls share a single in-flight future. A failed
  /// attempt clears the cache so that the next call retries.
  Future<void> ensureLoaded() {
    final existing = _pending;
    if (existing != null) return existing;

    final future = _load().catchError((Object e, StackTrace st) {
      _pending = null;
      throw e;
    });

    _pending = future;
    return future;
  }

  /// Returns `true` when the target global is fully available. Subclasses
  /// implement the specific probe — e.g. `window.mapgl.Map` for MapGL, or
  /// `window.mapgl.Clusterer` for the clusterer.
  bool isReady();

  Future<void> _load() async {
    if (isReady()) {
      logMapgl('$label already available');
      return;
    }

    final existing = web.document.querySelector('script[src="$scriptUrl"]');
    if (existing != null) {
      logMapgl('$label <script> already in DOM — waiting for global');
      await _waitForGlobal();
      return;
    }

    logMapgl('injecting $label <script>');
    await _injectScript();
    await _waitForGlobal();
  }

  Future<void> _injectScript() {
    final completer = Completer<void>();
    final script = web.HTMLScriptElement()
      ..src = scriptUrl
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
          completer.completeError(StateError('$label script load failed'));
        }
      }.toJS,
    );

    web.document.head!.append(script);

    return completer.future.timeout(
      timeout,
      onTimeout: () {
        cleanup();
        throw TimeoutException('$label script load timeout');
      },
    );
  }

  Future<void> _waitForGlobal() {
    if (isReady()) return Future.value();

    final completer = Completer<void>();
    late final Timer poll;
    late final Timer timeoutTimer;

    poll = Timer.periodic(pollInterval, (_) {
      if (completer.isCompleted) return;
      if (isReady()) {
        poll.cancel();
        timeoutTimer.cancel();
        completer.complete();
      }
    });

    timeoutTimer = Timer(timeout, () {
      if (completer.isCompleted) return;
      poll.cancel();
      completer.completeError(TimeoutException('$label global did not appear in time'));
    });

    return completer.future;
  }

  /// Helper for subclasses: returns the JS value of `window[name]`, or
  /// `null` if the property is absent or not a [JSObject].
  @protected
  JSObject? getWindowObject(String name) {
    if (!web.window.hasProperty(name.toJS).toDart) return null;
    final value = web.window.getProperty(name.toJS);
    if (!value.isA<JSObject>()) return null;
    return value as JSObject;
  }
}
