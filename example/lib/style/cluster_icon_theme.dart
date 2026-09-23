//example/lib/style/cluster_icon_theme.dart

import 'package:mapgl_2gis_web/mapgl_2gis_web.dart';

/// A single visual "tier" of a cluster — icon size, base and hover colors,
/// draw order. Grows with the density of points inside the cluster.
///
/// This is example code (`example/`), not part of the library — the actual
/// colors and thresholds are decided by the host application; the library
/// imposes none of them.
class ClusterSizeTier {
  final int maxPoints;
  final double iconSize;
  final String color;
  final String? hoverColor;
  final int zIndex;

  const ClusterSizeTier({
    required this.maxPoints,
    required this.iconSize,
    required this.color,
    this.hoverColor,
    this.zIndex = 0,
  });
}

/// Example cluster visual theme, built on top of the typed [ClusterStyle]
/// from the library.
///
/// Lives under `example/` — it demonstrates one possible approach, not the
/// single correct design.
class ClusterIconTheme {
  final List<ClusterSizeTier> tiers;
  final String strokeColor;
  final double strokeWidth;
  final double opacity;

  final String labelColor;
  final String labelHaloColor;
  final double labelHaloRadius;
  final double labelLetterSpacing;
  final double hoverScale;

  const ClusterIconTheme({
    this.tiers = const [
      ClusterSizeTier(maxPoints: 10, iconSize: 40, color: '#1587c8', zIndex: 1),
      ClusterSizeTier(maxPoints: 50, iconSize: 48, color: '#1587c8', zIndex: 2),
      ClusterSizeTier(maxPoints: 200, iconSize: 56, color: '#1587c8', zIndex: 3),
      ClusterSizeTier(maxPoints: 1 << 30, iconSize: 64, color: '#1587c8', zIndex: 4),
    ],
    this.strokeColor = '#ffffff',
    this.strokeWidth = 2,
    this.opacity = 0.92,
    this.labelColor = '#ffffff',
    this.labelHaloColor = '#00000055',
    this.labelHaloRadius = 1,
    this.labelLetterSpacing = 0,
    this.hoverScale = 1.12,
  });

  ClusterSizeTier _tierFor(int count) {
    for (final tier in tiers) {
      if (count < tier.maxPoints) return tier;
    }
    return tiers.last;
  }

  String _circleSvg({required double size, required String color}) {
    final radius = size / 2 - strokeWidth;
    final svg =
        '''
<svg xmlns="http://www.w3.org/2000/svg" width="$size" height="$size" viewBox="0 0 $size $size">
  <circle cx="${size / 2}" cy="${size / 2}" r="$radius" fill="$color" stroke="$strokeColor" stroke-width="$strokeWidth" opacity="$opacity"/>
</svg>
''';
    return 'data:image/svg+xml,${Uri.encodeComponent(svg.trim())}';
  }

  /// Builds a typed [ClusterStyle] for the given cluster point count,
  /// according to the theme's current thresholds.
  ClusterStyle buildStyle(int count) {
    final tier = _tierFor(count);
    final hoverSize = (tier.iconSize * hoverScale);

    return ClusterStyle.webgl(
      icon: _circleSvg(size: tier.iconSize, color: tier.color),
      size: [tier.iconSize, tier.iconSize],
      hoverIcon: _circleSvg(size: hoverSize, color: tier.hoverColor ?? tier.color),
      hoverSize: [hoverSize, hoverSize],
      labelColor: labelColor,
      labelHaloColor: labelHaloColor,
      labelHaloRadius: labelHaloRadius,
      labelFontSize: (tier.iconSize * 0.35).roundToDouble(),
      labelLetterSpacing: labelLetterSpacing,
      zIndex: tier.zIndex,
    );
  }
}
