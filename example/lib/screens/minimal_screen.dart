//example/lib/screens/minimal_screen.dart

import 'package:flutter/material.dart';
import 'package:mapgl_2gis_web/mapgl_2gis_web.dart';

import '../config.dart';

/// Smallest possible demo: a full-screen map with no overlays, no markers,
/// no controls — only the API key and the initial camera.
///
/// Useful as a smoke test for the core widget: if this screen renders a map,
/// the script loader, platform-view registration, and controller lifecycle
/// are all working.
class MinimalScreen extends StatelessWidget {
  const MinimalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapGlWidget(
        apiKey: ExampleConfig.apiKey,
        initialCenter: ExampleConfig.defaultCenter,
        initialZoom: ExampleConfig.defaultZoom,
        onMapLoadFailed: (error, stackTrace) {
          debugPrint('[MapGL] load failed: $error\n$stackTrace');
        },
      ),
    );
  }
}
