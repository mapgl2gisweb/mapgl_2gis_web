// src/clusterer/clusterer_options.dart

import 'dart:js_interop';

import 'cluster_style.dart';
import 'clusterer_target.dart';

/// Container for a clusterer style: either a fixed style shared by all
/// clusters, or a per-cluster builder that receives the point count and the
/// target descriptor.
sealed class ClustererStyleContainer<T> {
  const ClustererStyleContainer();

  const factory ClustererStyleContainer.fixed(ClusterStyle style) =
  _FixedClustererStyle<T>;

  const factory ClustererStyleContainer.dynamic(
      ClusterStyle Function(int pointsCount, ClustererTarget<T> target) builder,
      ) = _DynamicClustererStyle<T>;

  /// Returns a JS value ready to be assigned to the `clusterStyle` option.
  JSAny toJsValue();
}

class _FixedClustererStyle<T> extends ClustererStyleContainer<T> {
  final ClusterStyle style;
  const _FixedClustererStyle(this.style);

  @override
  JSAny toJsValue() => style.toJsMap().jsify()!;
}

class _DynamicClustererStyle<T> extends ClustererStyleContainer<T> {
  final ClusterStyle Function(int pointsCount, ClustererTarget<T> target) builder;
  const _DynamicClustererStyle(this.builder);

  @override
  JSAny toJsValue() => buildClusterStyleFunction<T>(builder);
}

/// Options accepted by the MapGL Clusterer.
///
/// Mirrors the corresponding JS option object; omitted fields are not
/// serialized, and the library applies its own defaults.
class ClustererOptions<T> {
  /// Clustering radius in pixels.
  final double? radius;

  /// Style applied to every cluster, or a function that builds it per-cluster.
  final ClustererStyleContainer<T>? clusterStyle;

  /// Zoom level at or above which clustering is disabled and markers are
  /// rendered individually.
  final double? disableClusteringAtZoom;

  const ClustererOptions({
    this.radius,
    this.clusterStyle,
    this.disableClusteringAtZoom,
  });

  Map<String, Object?> toJsMap() => {
    if (radius != null) 'radius': radius,
    if (clusterStyle != null) 'clusterStyle': clusterStyle!.toJsValue(),
    if (disableClusteringAtZoom != null)
      'disableClusteringAtZoom': disableClusteringAtZoom,
  };
}