// src/types/layers/expression.dart

/// Mirrors `export type Expression = [ExpressionName, ...any[]]` from
/// `mapgl-types/types/styles.d.ts`.
///
/// `ExpressionName` is a large string-literal union (`'match'`, `'get'`,
/// `'interpolate'`, `'step'`, `'sourceAttr'`, and many others). It is not
/// modelled as a separate type here: expressions are passed through as raw
/// arrays, and the first element is expected by convention to be one of the
/// known expression names.
typedef Expression = List<Object?>;