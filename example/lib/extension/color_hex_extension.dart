//example/lib/extension/color_hex_extension.dart

import 'package:flutter/material.dart';

/// HEX string conversion for [Color] — used wherever MapGL expects a color
/// as a string: `color` / `strokeColor` for `Polygon` / `Polyline`, inline
/// SVG icons, `labelColor` for cluster styles, and so on.
extension ColorHex on Color {
  /// Returns the color as `#RRGGBB`, without the alpha channel — the format
  /// MapGL expects for `color`, `strokeColor`, and similar fields.
  ///
  /// Example:
  ///   `Colors.red.toHex()` → `'#f44336'`
  String toHex({bool includeHashSign = true, bool uppercase = false}) {
    final hex = (0xFFFFFF & _toArgbInt()).toRadixString(16).padLeft(6, '0');
    final result = uppercase ? hex.toUpperCase() : hex;
    return includeHashSign ? '#$result' : result;
  }

  /// Returns the color as `#RRGGBBAA`, with the alpha channel appended.
  ///
  /// Used for MapGL fields that accept `RRGGBB[AA]`, such as polygon fills
  /// and strokes with transparency.
  ///
  /// Example:
  ///   `Colors.red.withValues(alpha: 0.5).toHexWithAlpha()`
  ///   → `'#f4433680'`
  String toHexWithAlpha({bool includeHashSign = true, bool uppercase = false}) {
    final argb = _toArgbInt();
    final rgb = (argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0');
    final alpha = ((argb >> 24) & 0xFF).toRadixString(16).padLeft(2, '0');
    final result = '$rgb$alpha';
    final formatted = uppercase ? result.toUpperCase() : result;
    return includeHashSign ? '#$formatted' : formatted;
  }

  /// Internal helper: the ARGB value as an `int`, independent of the
  /// Flutter version. Newer Flutter marks `Color.value` as deprecated in
  /// favour of the `r` / `g` / `b` / `a` components.
  int _toArgbInt() {
    final a = (this.a * 255.0).round() & 0xFF;
    final r = (this.r * 255.0).round() & 0xFF;
    final g = (this.g * 255.0).round() & 0xFF;
    final b = (this.b * 255.0).round() & 0xFF;
    return (a << 24) | (r << 16) | (g << 8) | b;
  }
}
