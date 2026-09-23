// src/types/style_icon_config.dart

import 'dart:js_interop';

/*
final simple = StyleIconConfigDartFactory.simple(
  url: 'https://example.com/pin.svg',
);

final stretchable = StyleIconConfigDartFactory.stretchable(
  url: 'https://example.com/pin.svg',
  width: 32,
  height: 32,
  stretchX: [
    [10, 20],
  ],
  stretchY: [
    [5, 15],
  ],
);

map.addIcon('my-icon', simple);
map.addIcon('my-stretchable', stretchable);
 */

/// Raw binding for `mapgl.StyleIconConfig`.
///
/// In the JS contract, `StyleIconConfig` is a union of two variants:
///
///   * `StyleSimpleIconConfig`     — `{ url }`
///   * `StyleStretchableIconConfig` — `{ url, width, height, stretchX, stretchY }`
///
/// Both variants are represented by a single extension type; two Dart
/// factories ([StyleIconConfigDartFactory.simple] and
/// [StyleIconConfigDartFactory.stretchable]) produce the correct JS shape.
///
/// Note: `size`, `pixelRatio`, and `padding` are **not** part of this
/// contract — they belong to `LabelImage`, which is a different interface
/// used for label backgrounds.
@JS()
extension type StyleIconConfig._(JSObject _) implements JSObject {
  @JS('url')
  external JSString get _url;

  /// Icon URL. Common to both variants.
  String get url => _url.toDart;
}

/// Dart-friendly factories for [StyleIconConfig].
extension StyleIconConfigDartFactory on StyleIconConfig {
  /// Creates a config for a simple, non-stretchable icon.
  ///
  /// Only [url] is serialized. Corresponds to `StyleSimpleIconConfig`.
  static StyleIconConfig simple({required String url}) {
    final jsified = {'url': url}.jsify();
    return jsified as StyleIconConfig;
  }

  /// Creates a config for a stretchable icon.
  ///
  /// The icon stretches to fit its content (e.g. text) while keeping the
  /// edges — such as rounded corners — fixed.
  ///
  /// [width] and [height] are the source icon dimensions in pixels;
  /// [stretchX] and [stretchY] are pairs of pixel ranges along each axis
  /// that may be stretched. Corresponds to `StyleStretchableIconConfig`.
  static StyleIconConfig stretchable({
    required String url,
    required double width,
    required double height,
    required List<List<double>> stretchX,
    required List<List<double>> stretchY,
  }) {
    final jsified = {'url': url, 'width': width, 'height': height, 'stretchX': stretchX, 'stretchY': stretchY}.jsify();
    return jsified as StyleIconConfig;
  }
}
