// src/core/js_interop_helpers.dart

import 'dart:js_interop';

/// Converts a Dart [List<double>] into a [JSArray] of JS numbers.
extension DoubleListToJS on List<double> {
  JSArray<JSNumber> toJSArray() => map((e) => e.toJS).toList().toJS;
}

/// Converts a Dart [List<int>] into a [JSArray] of JS numbers.
extension IntListToJS on List<int> {
  JSArray<JSNumber> toJSArray() => map((e) => e.toJS).toList().toJS;
}

/// Converts a [JSArray] of JS numbers back into a Dart list.
extension JSNumberArrayToDart on JSArray<JSNumber> {
  List<double> toDoubleList() => toDart.map((e) => e.toDartDouble).toList();
  List<int> toIntList() => toDart.map((e) => e.toDartInt).toList();
}

/// Converts a Dart [List<String>] into a [JSArray] of JS strings.
extension StringListToJS on List<String> {
  JSArray<JSString> toJSArray() => map((e) => e.toJS).toList().toJS;
}

/// Converts a Dart `List<List<double>>` into a nested [JSArray].
///
/// Useful for MapGL options that expect arrays of coordinate pairs, e.g.
/// `stretchX` / `stretchY` in image configurations.
extension NestedDoubleListToJS on List<List<double>> {
  JSArray<JSArray<JSNumber>> toNestedJSArray() =>
      map((inner) => inner.toJSArray()).toList().toJS;
}