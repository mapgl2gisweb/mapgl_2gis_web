// src/objects/marker.dart

import 'dart:js_interop';

import '../common/label_options.dart';
import '../core/js_interop_helpers.dart';
import '../map/mapgl_map_bindings.dart';
import '../types/layers/style_value.dart';
import 'dynamic_object_events.dart';

/// Caches JS handlers per Dart callback, keyed by event type, so that
/// [Marker.offEvent] can find the exact JS function previously attached.
final Expando<Map<DynamicObjectEventType, JSFunction>> _markerEventHandlers =
Expando<Map<DynamicObjectEventType, JSFunction>>('marker.eventHandlers');

/// Mirrors `MarkerOptions` from the MapGL type definitions.
class MarkerOptions {
  /// Coordinates `[longitude, latitude, altitude?]`. Altitude is optional
  /// and expressed in meters.
  final List<double> coordinates;

  /// Marker icon URL.
  final String? icon;

  /// Marker icon size `[width, height]` in pixels.
  final List<double>? size;

  /// Position of the icon "tip" relative to its top-left corner, in pixels.
  final List<double>? anchor;

  /// Marker icon opacity, or an expression.
  final StyleValue<double>? opacity;

  /// Clockwise rotation of the icon in the screen plane, in degrees.
  final double? rotation;

  /// Marker icon URL in the hovered state.
  final String? hoverIcon;

  /// Icon size in the hovered state.
  final List<double>? hoverSize;

  /// Icon anchor in the hovered state.
  final List<double>? hoverAnchor;

  /// Icon opacity in the hovered state.
  final StyleValue<double>? hoverOpacity;

  /// Draw order.
  final int? zIndex;

  /// Minimum display styleZoom of the marker.
  final double? minZoom;

  /// Maximum display styleZoom of the marker.
  final double? maxZoom;

  /// Allows the marker to emit events. `true` by default.
  final bool? interactive;

  /// Initial label configuration.
  final LabelOptions? label;

  /// User-specific payload.
  final Object? userData;

  const MarkerOptions({
    required this.coordinates,
    this.icon,
    this.size,
    this.anchor,
    this.opacity,
    this.rotation,
    this.hoverIcon,
    this.hoverSize,
    this.hoverAnchor,
    this.hoverOpacity,
    this.zIndex,
    this.minZoom,
    this.maxZoom,
    this.interactive,
    this.label,
    this.userData,
  });

  Map<String, Object?> toJsMap() => {
    'coordinates': coordinates,
    if (icon != null) 'icon': icon,
    if (size != null) 'size': size,
    if (anchor != null) 'anchor': anchor,
    if (opacity != null) 'opacity': opacity!.toJsValue(),
    if (rotation != null) 'rotation': rotation,
    if (hoverIcon != null) 'hoverIcon': hoverIcon,
    if (hoverSize != null) 'hoverSize': hoverSize,
    if (hoverAnchor != null) 'hoverAnchor': hoverAnchor,
    if (hoverOpacity != null) 'hoverOpacity': hoverOpacity!.toJsValue(),
    if (zIndex != null) 'zIndex': zIndex,
    if (minZoom != null) 'minZoom': minZoom,
    if (maxZoom != null) 'maxZoom': maxZoom,
    if (interactive != null) 'interactive': interactive,
    if (label != null) 'label': label!.toJsMap(),
    if (userData != null) 'userData': userData,
  };
}

/// Raw binding for the `mapgl.Marker` class.
///
/// `Marker` extends `Evented<DynamicObjectEventTable<Marker>>` on the JS
/// side, so pointer events are typed with [DynamicObjectPointerEvent].
@JS('mapgl.Marker')
extension type Marker._(JSObject _) implements JSObject {
  external factory Marker._internal(MapglMapNew map, JSObject options);

  factory Marker(MapglMapNew map, MarkerOptions options) =>
      Marker._internal(map, options.toJsMap().jsify() as JSObject);

  // --- Icons ---

  @JS('setIcon')
  external Marker _setIcon(JSObject options);

  /// Replaces the marker icon.
  Marker setIcon({
    required String icon,
    List<double>? anchor,
    List<double>? size,
    StyleValue<double>? opacity,
  }) {
    final opts = {
      'icon': icon,
      if (anchor != null) 'anchor': anchor,
      if (size != null) 'size': size,
      if (opacity != null) 'opacity': opacity.toJsValue(),
    }.jsify() as JSObject;
    return _setIcon(opts);
  }

  @JS('setHoverIcon')
  external Marker _setHoverIcon([JSObject? options]);

  /// Sets the hover icon. Use [clearHoverIcon] to remove the hover state.
  Marker setHoverIcon({
    required String icon,
    List<double>? anchor,
    List<double>? size,
    StyleValue<double>? opacity,
  }) {
    final opts = {
      'icon': icon,
      if (anchor != null) 'anchor': anchor,
      if (size != null) 'size': size,
      if (opacity != null) 'opacity': opacity.toJsValue(),
    }.jsify() as JSObject;
    return _setHoverIcon(opts);
  }

  /// Removes the previously configured hover icon.
  Marker clearHoverIcon() => _setHoverIcon();

  @JS('setRotation')
  external Marker _setRotation(JSNumber angle);

  /// Sets the clockwise rotation of the icon, in degrees.
  Marker setRotation(double angle) => _setRotation(angle.toJS);

  @JS('getRotation')
  external JSNumber _getRotation();

  /// Returns the clockwise rotation of the marker icon, in degrees.
  double getRotation() => _getRotation().toDartDouble;

  // --- Label ---

  @JS('setLabel')
  external Marker _setLabel([JSObject? options]);

  /// Sets the label of the marker.
  Marker setLabel(LabelOptions label) =>
      _setLabel(label.toJsMap().jsify() as JSObject);

  /// Removes the label.
  Marker clearLabel() => _setLabel();

  // --- Position ---

  @JS('setCoordinates')
  external Marker _setCoordinates(JSArray<JSNumber> coordinates);

  /// Sets the marker coordinates `[lng, lat]`.
  Marker setCoordinates(List<double> coordinates) =>
      _setCoordinates(coordinates.toJSArray());

  @JS('getCoordinates')
  external JSArray<JSNumber> _getCoordinates();

  /// Returns the marker coordinates as a `[lng, lat]` pair.
  List<double> getCoordinates() => _getCoordinates().toDoubleList();

  // --- Visibility ---

  /// Makes the marker visible.
  external Marker show();

  /// Hides the marker.
  external Marker hide();

  // --- Lifecycle ---

  external void destroy();

  // --- Events ---

  @JS('on')
  external void _on(JSString event, JSFunction handler);

  @JS('off')
  external void _off(JSString event, JSFunction handler);

  /// Registers a typed handler for a dynamic-object [type].
  ///
  /// The JS wrapper is cached against [callback], so a matching [offEvent]
  /// call detaches exactly this listener.
  void onEvent(
      DynamicObjectEventType type,
      void Function(DynamicObjectPointerEvent<Marker> event) callback,
      ) {
    final jsHandler =
        ((DynamicObjectPointerEvent<Marker> ev) => callback(ev)).toJS;
    (_markerEventHandlers[callback] ??= <DynamicObjectEventType, JSFunction>{})[type] =
        jsHandler;
    _on(type.value.toJS, jsHandler);
  }

  /// Detaches the handler previously registered by [onEvent] for the same
  /// [callback] and [type]. No-op if no matching listener exists.
  void offEvent(
      DynamicObjectEventType type,
      void Function(DynamicObjectPointerEvent<Marker> event) callback,
      ) {
    final jsHandler = _markerEventHandlers[callback]?[type];
    if (jsHandler == null) return;
    _off(type.value.toJS, jsHandler);
  }
}