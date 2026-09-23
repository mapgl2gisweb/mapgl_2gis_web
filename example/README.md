# mapgl_2gis_web — example

A small Flutter Web application that demonstrates the public API of
[`mapgl_2gis_web`](../README.md). It is intentionally organized as a set of
independent demo screens, so each feature of the package can be explored in
isolation.

## Running

The example needs a valid 2GIS MapGL API key. The key is read from the
`MAPGL_API_KEY` compile-time environment variable, so it never has to be
committed to the repository:

    flutter run -d chrome --dart-define=MAPGL_API_KEY=your_key_here

Get a key at <https://dev.2gis.com>.

The app runs in a browser only — the underlying MapGL library is a
JavaScript API, and the wrapper depends on `dart:js_interop`.

## What is inside

| Screen   | File                              | Demonstrates                                                                                                                                                                                              |
| -------- | --------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Minimal  | `lib/screens/minimal_screen.dart` | The smallest possible usage: a full-screen map with no overlays, markers, or controls. Useful as a smoke test — if this screen renders a map, the script loader, platform-view registration, and controller lifecycle are all working. |
| Clusters | `lib/screens/clasterer_screen.dart` | The clusterer API: `ClustererController`, `ClustererOptions`, typed cluster styles (WebGL and HTML), fixed vs. dynamic styles, and click handling with `ClustererEventType`.                              |

`main.dart` wires the screens into a two-tab shell. The minimal demo is the
first tab on purpose: when something breaks, it is the fastest way to tell
whether the problem is in the core package or in a specific feature.

## Structure

    lib/
      main.dart                      entry point, two-tab shell
      config.dart                    shared settings (API key, default camera)
      splash.dart                    removes the HTML splash once Flutter starts
      screens/
        minimal_screen.dart          the smallest possible demo
        clasterer_screen.dart        clusterer demo
      features/
        random_cluster_points.dart   generates random points inside map bounds
      style/
        cluster_icon_theme.dart      example cluster theme (tiers, palette)
      widgets/
        mapgl_view.dart              map with a static preview and loading overlay
      extension/
        color_hex_extension.dart     Color → '#RRGGBB[AA]' helpers
      utils/
        icons.dart                   loads SVG assets as data URIs

The folders are deliberately flat: `screens/` holds one demo per feature,
`widgets/` holds reusable UI, and `features/` / `style/` / `utils/` hold
supporting code that is not part of a specific screen. Nothing here belongs
to the library itself — the `example/` directory is free to make its own
choices about visuals, defaults, and structure.

## Notes

- **Debug logging.** `main.dart` enables `mapglDebugLoggingEnabled` before
  `runApp`, so the console shows lifecycle messages from `MapGlWidget` and
  `MapController`. Flip it off to see what the app looks like without the
  noise.
- **Script loading.** `main()` calls `warmUpMapgl()` before `runApp` so the
  MapGL script starts downloading while Flutter is still booting. The first
  `MapGlWidget` on screen then finds `window.mapgl` already available.
- **Static preview.** `MapGlView` (used by the clusterer demo) shows a
  desaturated static 2GIS image while the interactive map initializes, then
  cross-fades to the live map. This is a UX choice of the example, not part
  of the library.
- **HTML splash.** `web/index.html` renders a gradient splash screen and
  `splash.dart` fades it out after Flutter is ready. This keeps the initial
  paint instant while the Flutter bundle loads.

## Adding a new demo

1. Create a new screen under `lib/screens/`, for example
   `polyline_screen.dart`.
2. Register it in `_DemoShell` in `main.dart` by appending to the `_screens`
   list and adding a matching `NavigationDestination`.
3. Keep the screen self-contained: it should not import another demo's
   widgets. Shared helpers belong in `widgets/`, `features/`, or `utils/`.