// src/types/lng_lat_bounds_class.dart

import 'dart:js_interop';

import '../core/js_interop_helpers.dart';

/// Raw binding for `mapgl.LngLatBoundsClass`.
///
/// The JS class implements the `LngLatBounds` interface (two points —
/// `southWest` and `northEast`) and adds a handful of helper methods. Every
/// method from the JS contract is mirrored here.
///
/// Since extension types do not support method overloading, the raw
/// `JSArray`-based externals are hidden behind small Dart wrappers that
/// accept and return `List<double>`.
@JS()
extension type LngLatBoundsClass._(JSObject _) implements JSObject {
  /// Creates a new bounds object from two points.
  ///
  /// Both points are `[lng, lat]` pairs, matching the JS contract.
  external factory LngLatBoundsClass({required JSArray<JSNumber> northEast, required JSArray<JSNumber> southWest});

  // --- Raw fields ---

  @JS('northEast')
  external JSArray<JSNumber> get _northEast;

  List<double> get northEast => _northEast.toDoubleList();

  @JS('southWest')
  external JSArray<JSNumber> get _southWest;

  List<double> get southWest => _southWest.toDoubleList();

  // --- extend ---

  @JS('extend')
  external LngLatBoundsClass _extend(JSArray<JSNumber> point);

  /// Extends the bounds to include the given `[lng, lat]` point.
  LngLatBoundsClass extend(List<double> point) => _extend(point.toJSArray());

  // --- getCenter ---

  @JS('getCenter')
  external JSArray<JSNumber> _getCenter();

  /// Returns the center of the bounds as a `[lng, lat]` pair.
  List<double> getCenter() => _getCenter().toDoubleList();

  // --- containsPoint ---

  @JS('containsPoint')
  external bool _containsPoint(JSArray<JSNumber> point);

  /// Returns `true` if the bounds contain the given `[lng, lat]` point.
  bool containsPoint(List<double> point) => _containsPoint(point.toJSArray());

  // --- containsBounds ---

  @JS('containsBounds')
  external bool containsBounds(LngLatBoundsClass bounds);

  // --- intersects ---

  @JS('intersects')
  external bool intersects(LngLatBoundsClass bounds);
}

/// Dart-friendly factory layered on top of the [LngLatBoundsClass]
/// extension type.
extension LngLatBoundsDartFactory on LngLatBoundsClass {
  /// Creates a bounds instance from two Dart lists.
  static LngLatBoundsClass fromDart({required List<double> northEast, required List<double> southWest}) {
    return LngLatBoundsClass(northEast: northEast.toJSArray(), southWest: southWest.toJSArray());
  }
}
