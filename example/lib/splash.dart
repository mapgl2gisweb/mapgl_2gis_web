//example/lib/splash.dart

import 'package:web/web.dart' as web;

/// Removes the splash screen from the DOM, if present.
///
/// Idempotent: calling it twice is a no-op. When [fadeOut] is `true`, the
/// splash element is faded out first and removed after [delay] — the default
/// matches the CSS transition defined in `index.html`.
void hideSplash({
  bool fadeOut = true,
  Duration delay = const Duration(milliseconds: 300),
}) {
  final splash =
  web.document.getElementById('splash-screen') as web.HTMLElement?;
  if (splash == null) return;

  if (!fadeOut) {
    splash.remove();
    return;
  }

  splash.style.opacity = '0';
  Future.delayed(delay, () {
    web.document.getElementById('splash-screen')?.remove();
  });
}