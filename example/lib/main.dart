import 'package:flutter/material.dart';
import 'package:mapgl_2gis_web/mapgl_2gis_web.dart';

import 'mapgl_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2GIS MapGL Web Example',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapglController? _mapController;

  // Извлекаем ключ напрямую из параметров компиляции
  static const String _apiKey = String.fromEnvironment('DGIS_API_KEY');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('2GIS MapGL Web Demo')),
      body: _apiKey.isEmpty
          ? const Center(
              child: Text(
                'Ошибка: Запустите проект с флагом:\n'
                '--dart-define=DGIS_API_KEY=ваш_ключ',
                textAlign: TextAlign.center,
              ),
            )
          : MapGlView(
              apiKey: _apiKey,
              backgroundColor: 'transparent',
              initialCenter: const [38.975313, 45.035470],
              initialZoom: 12.0,
              onMapCreated: (controller) {
                setState(() => _mapController = controller);
              },
            ),
    );
  }
}
