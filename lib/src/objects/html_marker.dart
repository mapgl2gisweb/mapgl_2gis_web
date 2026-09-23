// src/objects/html_marker.dart

import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../core/js_interop_helpers.dart';
import '../map/mapgl_map_bindings.dart';

/// Mirrors `HtmlMarkerOptions` from the MapGL type definitions.
///
/// The `labeling` option is a complex union in the JS contract and is
/// intentionally not modelled here — it can be added later if the need
/// arises. The `floorId` field is marked hidden in the `.d.ts` and is
/// likewise omitted.
class HtmlMarkerOptions {
  /// Coordinates `[longitude, latitude, altitude?]`. Altitude is optional
  /// and expressed in meters.
  final List<double> coordinates;

  /// HTML content. May be either a string or an [web.HTMLElement].
  final Object html;

  /// Position of the "tip" of the HTML marker relative to its top-left
  /// corner.
  final List<double>? anchor;

  final double? minZoom;
  final double? maxZoom;

  /// Draw order.
  final int? zIndex;

  /// When `true`, the marker captures pointer events; otherwise events are
  /// passed through to the map. `true` by default.
  final bool? preventMapInteractions;

  /// When `true`, the marker can be a pointer-event target
  /// (`pointer-events: auto`); otherwise it is transparent to pointer events.
  final bool? interactive;

  /// When `true`, the marker coordinates are not rounded. `false` by default.
  final bool? disableRounding;

  /// User-specific payload.
  final Object? userData;

  const HtmlMarkerOptions({
    required this.coordinates,
    required this.html,
    this.anchor,
    this.minZoom,
    this.maxZoom,
    this.zIndex,
    this.preventMapInteractions,
    this.interactive,
    this.disableRounding,
    this.userData,
  });

  Map<String, Object?> toJsMap() {
    final htmlValue = html;
    final jsHtml = htmlValue is String ? htmlValue : (htmlValue as web.HTMLElement);
    return {
      'coordinates': coordinates,
      'html': jsHtml,
      if (anchor != null) 'anchor': anchor,
      if (minZoom != null) 'minZoom': minZoom,
      if (maxZoom != null) 'maxZoom': maxZoom,
      if (zIndex != null) 'zIndex': zIndex,
      if (preventMapInteractions != null) 'preventMapInteractions': preventMapInteractions,
      if (interactive != null) 'interactive': interactive,
      if (disableRounding != null) 'disableRounding': disableRounding,
      if (userData != null) 'userData': userData,
    };
  }
}

/// Raw binding for the `mapgl.HtmlMarker` class.
///
/// Unlike [Marker], `HtmlMarker` does not extend `Evented`, so no event
/// registration API is exposed.
@JS('mapgl.HtmlMarker')
extension type HtmlMarker._(JSObject _) implements JSObject {
  external factory HtmlMarker._internal(MapglMapNew map, JSObject options);

  factory HtmlMarker(MapglMapNew map, HtmlMarkerOptions options) =>
      HtmlMarker._internal(map, options.toJsMap().jsify() as JSObject);

  external void destroy();

  // --- Position ---

  @JS('setCoordinates')
  external HtmlMarker _setCoordinates(JSArray<JSNumber> coordinates);

  /// Sets the marker coordinates `[lng, lat]`.
  HtmlMarker setCoordinates(List<double> coordinates) => _setCoordinates(coordinates.toJSArray());

  @JS('getCoordinates')
  external JSArray<JSNumber> _getCoordinates();

  /// Returns the marker coordinates as a `[lng, lat]` pair.
  List<double> getCoordinates() => _getCoordinates().toDoubleList();

  // --- Anchor ---

  @JS('setAnchor')
  external HtmlMarker _setAnchor(JSArray<JSNumber> anchor);

  /// Sets the anchor relative to the top-left corner of the marker.
  HtmlMarker setAnchor(List<double> anchor) => _setAnchor(anchor.toJSArray());

  @JS('getAnchor')
  external JSArray<JSNumber> _getAnchor();

  /// Returns the current anchor in pixels.
  List<double> getAnchor() => _getAnchor().toDoubleList();

  // --- Content ---

  @JS('setContent')
  external HtmlMarker _setContentString(JSString html);

  @JS('setContent')
  external HtmlMarker _setContentElement(web.HTMLElement element);

  /// Replaces the content with an HTML string.
  HtmlMarker setHtml(String html) => _setContentString(html.toJS);

  /// Replaces the content with an [web.HTMLElement].
  HtmlMarker setElement(web.HTMLElement element) => _setContentElement(element);

  @JS('getContent')
  external web.HTMLElement getContent();

  // --- Z-index ---

  @JS('setZIndex')
  external HtmlMarker _setZIndex(JSNumber zIndex);

  /// Sets the CSS `z-index` of the marker's root DOM element.
  HtmlMarker setZIndex(int zIndex) => _setZIndex(zIndex.toJS);

  @JS('getZIndex')
  external JSNumber _getZIndex();

  /// Returns the CSS `z-index` of the marker's root DOM element.
  int getZIndex() => _getZIndex().toDartInt;
}
