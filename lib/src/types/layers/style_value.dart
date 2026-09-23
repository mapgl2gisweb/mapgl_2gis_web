// src/types/layers/style_value.dart

import 'expression.dart';

/// The `T | Expression` pattern used by most style properties in
/// `styles.d.ts` — for example `color?: string | Expression` and
/// `width?: number | Expression`.
///
/// A style value is therefore either a plain literal of type [T], or a
/// MapGL expression. Both cases are represented by a dedicated subtype,
/// so callers cannot accidentally pass a value of the wrong shape.
sealed class StyleValue<T> {
  const StyleValue();

  const factory StyleValue.literal(T value) = LiteralStyleValue<T>;

  const factory StyleValue.expression(Expression expr) = ExpressionStyleValue<T>;

  /// Returns a value ready to be passed to `jsify()` — either the raw
  /// literal of type [T] or the expression list.
  Object? toJsValue();
}

/// A plain literal value of type [T].
class LiteralStyleValue<T> extends StyleValue<T> {
  final T value;

  const LiteralStyleValue(this.value);

  @override
  Object? toJsValue() => value;
}

/// A MapGL expression used in place of a literal.
class ExpressionStyleValue<T> extends StyleValue<T> {
  final Expression expression;

  const ExpressionStyleValue(this.expression);

  @override
  Object? toJsValue() => expression;
}