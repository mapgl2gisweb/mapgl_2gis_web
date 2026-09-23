// src/controllers/clusterer_controller.dart

import '../clusterer/clusterer.dart';
import 'map_controller_access.dart';

/// Thin wrapper around [MapglClustererNew].
///
/// The controller owns no marker data: the caller passes a fresh list to
/// [load] every time, because the underlying JS API supports only full
/// reloads, not incremental updates.
class ClustererController<T> {
  ClustererController(
      this._access, {
        this.options,
        ClustererScriptLoader? scriptLoader,
      }) : _scriptLoader = scriptLoader ?? DefaultClustererScriptLoader.shared;

  final MapControllerAccess _access;
  final ClustererOptions<T>? options;
  final ClustererScriptLoader _scriptLoader;

  MapglClustererNew<T>? _clusterer;

  /// The underlying JS clusterer instance.
  ///
  /// Throws a [StateError] if called before [load].
  MapglClustererNew<T> get raw {
    final clusterer = _clusterer;
    if (clusterer == null) {
      throw StateError(
        'Clusterer is not initialized yet — call load() first.',
      );
    }
    return clusterer;
  }

  bool get isInitialized => _clusterer != null;

  /// Loads the clusterer script (once, lazily) and (re)loads the marker set.
  ///
  /// Safe to call repeatedly: the script is fetched only on the first call,
  /// and each subsequent invocation replaces the marker set entirely.
  Future<void> load(List<InputMarker<T>> markers) async {
    await _access.whenReady;
    await _scriptLoader.ensureLoaded();
    _clusterer ??= MapglClustererNew<T>(_access.map, options);
    _clusterer!.load(markers);
  }

  /// Destroys the underlying JS clusterer and resets the controller state.
  void dispose() {
    _clusterer?.destroy();
    _clusterer = null;
  }
}