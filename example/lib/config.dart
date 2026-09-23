//example/lib/config.dart

/// Shared settings for every demo in the example app.
///
/// Does not belong to the library itself — this is example-only configuration.
abstract final class ExampleConfig {
  /// 2GIS API key. Replace with a real key before running.
  ///
  /// Alternatively, pass it via `--dart-define=MAPGL_API_KEY=...` so the real
  /// key never lives in the repository:
  ///
  /// ```
  /// flutter run -d chrome --dart-define=MAPGL_API_KEY=your_key
  /// ```
  static const String apiKey = String.fromEnvironment('MAPGL_API_KEY', defaultValue: 'YOUR_API_KEY');

  /// Default map center shared by all demos, as `[lng, lat]`.
  ///
  /// Defaults to Volgograd — adjust to your own region as needed.
  static const List<double> defaultCenter = [38.975313, 45.035470];

  /// Default zoom level.
  static const double defaultZoom = 13;

  /// Convenience check that a real API key was provided. Useful for
  /// surfacing a warning in the UI when the developer forgot to substitute
  /// their own key.
  static bool get hasValidApiKey => apiKey != 'YOUR_API_KEY' && apiKey.isNotEmpty;
}
