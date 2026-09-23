# mapgl_2gis_web

A modern, high-performance Flutter Web wrapper for the **2GIS MapGL JS API** (
`@2gis/mapgl`). Fully built using the latest Dart 3 `dart:js_interop` and
`package:web`, ensuring compatibility with **WASM** and canvaskit renderers.

---

> ⚠️ **PROJECT UNDER ACTIVE DEVELOPMENT / ПРОЕКТ В РАЗРАБОТКЕ**  
> **EN:** This package is currently under active development. The API is subject
> to change. Do not use in production yet.  
> **RU:** Пакет находится в процессе активной разработки и шлифовки кода.
> Интерфейсы могут меняться. Использовать в продакшене пока не рекомендуется.

---

## Features

* **Zero-Bridge Performance:** Uses Dart 3 `extension types` over JS objects for
  zero runtime overhead.
* **Shadow DOM Ready:** Designed specifically for Flutter Web's platform views
  architecture, avoiding common container identification bugs.
* **Smart Resize Handling:** Built-in debounced containment scaling to prevent
  map freezing on window resize.
* **UX Optimized:** Native support for loading overlays and static image
  previews while the heavy WebGL map instance boots up.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  mapgl_2gis_web: ^0.0.1
```

## Initial Setup

To get a massive boost in map loading speed and responsiveness, update your
`web/index.html` file. Add these `preconnect` and `preload` tags inside the
`<head>` block **before** the main Flutter scripts:

```html
<!-- Preconnect to 2GIS API and Tile servers to eliminate connection overhead -->
<link rel="preconnect" href="https://mapgl.2gis.com" crossorigin>
<link rel="preconnect" href="https://tile0-sdk.maps.2gis.com" crossorigin>
<link rel="preconnect" href="https://tile1-sdk.maps.2gis.com" crossorigin>
<link rel="preconnect" href="https://styles.api.2gis.com" crossorigin>
<link rel="preconnect" href="https://keys.api.2gis.com" crossorigin>

<!-- Preload the MapGL core script with high priority -->
<link rel="preload" href="https://2gis.com" as="script">
```

## Basic Usage

*A complete, polished usage guide and documentation will be available with the
stable `1.0.0` release.*

```dart
// Stay tuned for the upcoming API preview!
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file
for details.

## Contact

For questions, bug reports, or feature requests, please open an issue on the [GitHub repository](https://github.com/mapgl2gisweb/mapgl_2gis_web/issues).

You can also reach out via email at: **mapgl.2gis.web@gmail.com**
