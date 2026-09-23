//example/lib/main.dart

import 'package:flutter/material.dart';
import 'package:mapgl_2gis_web/mapgl_2gis_web.dart';

import 'screens/clasterer_screen.dart';
import 'screens/minimal_screen.dart';
import 'splash.dart';

void main() {
  mapglDebugLoggingEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();

  warmUpMapgl().catchError((Object e, StackTrace st) {
    debugPrint('[MapGL] warmUp failed (non-fatal, widget will retry): $e');
  });

  hideSplash();

  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MapGL 2GIS — Demos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple), useMaterial3: true),
      home: const _DemoShell(),
    );
  }
}

/// Two-tab shell for switching between the minimal demo and the clusterer
/// demo. As more demos are added, this is the natural place to grow into a
/// `NavigationRail` or a list-based home page.
class _DemoShell extends StatefulWidget {
  const _DemoShell();

  @override
  State<_DemoShell> createState() => _DemoShellState();
}

class _DemoShellState extends State<_DemoShell> {
  int _index = 0;

  static const _screens = [MinimalScreen(), ClastererScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Minimal'),
          NavigationDestination(
            icon: Icon(Icons.scatter_plot_outlined),
            selectedIcon: Icon(Icons.scatter_plot),
            label: 'Clusters',
          ),
        ],
      ),
    );
  }
}
