// src/core/mapgl_logging.dart

import 'package:flutter/foundation.dart' show debugPrint;

/// Enables verbose `MapController` / `MapGlWidget` logging via [debugPrint].
///
/// Off by default — flip to `true` when diagnosing script loading, Hot
/// Restart, or lifecycle issues.
bool mapglDebugLoggingEnabled = false;

/// Writes [message] to the Flutter debug console, prefixed with `[MapGL]`.
///
/// Logging is a no-op unless [mapglDebugLoggingEnabled] is `true`.
void logMapgl(String message) {
  if (mapglDebugLoggingEnabled) debugPrint('[MapGL] $message');
}