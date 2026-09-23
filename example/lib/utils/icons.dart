//example/lib/utils/icons.dart

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Loads an SVG asset from the bundle and returns it as a base64-encoded
/// `data:` URI, ready to be passed to MapGL wherever an icon URL is expected.
Future<String> assetIcon(String assetName) async {
  final icon = await rootBundle.loadString(assetName);
  final base64 = base64Encode(utf8.encode(icon));
  return 'data:image/svg+xml;base64,$base64';
}