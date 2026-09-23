// src/types/layers/point_style_layer.dart

part of 'style_layer_base.dart';

/// Mirrors `PointStyleLayer` from `styles.d.ts`.
///
/// Fixes `type: 'point'` and pairs it with [PointStyleProps].
class PointStyleLayer extends StyleLayer<PointStyleProps> with LayerJsonMixin<PointStyleProps> {
  const PointStyleLayer({required super.id, super.filter, super.minzoom, super.maxzoom, super.style})
    : super(type: 'point');
}

/// Style properties for a point layer.
///
/// Mirrors the `style` shape of `PointStyleLayer` from `styles.d.ts`.
///
/// Note: `iconAnchor`, `iconOffset`, and `textOffset` are typed as bare
/// [Expression] in the JS contract — no literal variant exists. The same
/// applies to `textPlacement`.
class PointStyleProps implements LayerStyleProps {
  // --- Icon ---

  /// Icon name. When omitted, the icon is not displayed.
  final StyleValue<String>? iconImage;

  /// Icon width in pixels.
  final StyleValue<double>? iconWidth;

  /// Icon anchor position.
  final Expression? iconAnchor;

  /// Offset of the `iconAnchor` point.
  final Expression? iconOffset;

  // --- Text ---

  /// Label text.
  final StyleValue<String>? textField;

  /// Label font. When omitted, the label is not displayed.
  final StyleValue<String>? textFont;

  /// Label color.
  final StyleValue<String>? textColor;

  /// Label font size in pixels.
  final StyleValue<double>? textFontSize;

  /// Label line spacing in relative units (`em`).
  final double? textLineHeight;

  /// Label letter spacing in relative units (`em`).
  final double? textLetterSpacing;

  /// Label placement relative to the icon. Used only when an icon is
  /// present.
  final StyleValue<String>? textPlacement;

  /// Label offset from the icon in pixels.
  final StyleValue<double>? textOffset;

  /// Label outline color.
  final StyleValue<String>? textHaloColor;

  /// Label outline width in pixels.
  final double? textHaloWidth;

  /// Word-wrap length in characters. When exceeded, the next word is
  /// wrapped to the next line.
  final int? textMaxLengthPerLine;

  // --- Labeling ---

  /// When `true`, the object is not part of any labeling group and is
  /// always displayed.
  final bool? allowOverlap;

  /// Labeling group for the icon.
  final String? iconLabelingGroup;

  /// Extra icon margins in a labeling group.
  final LabelingMargin? iconLabelingMargin;

  /// Icon priority in a labeling group. Higher values win.
  final StyleValue<double>? iconPriority;

  /// Labeling group for the label.
  final String? textLabelingGroup;

  /// Extra label margins in a labeling group.
  final LabelingMargin? textLabelingMargin;

  /// Label priority in a labeling group. Higher values win, but must not
  /// exceed `iconPriority`.
  final StyleValue<double>? textPriority;

  // --- Misc ---

  /// Meta icon image name. Resolved to a full URL in events.
  final StyleValue<String>? iconMetaphorImage;

  /// Whether the layer objects are displayed on the map.
  final LayerVisibility? visibility;

  const PointStyleProps({
    this.iconImage,
    this.iconWidth,
    this.iconAnchor,
    this.iconOffset,
    this.textField,
    this.textFont,
    this.textColor,
    this.textFontSize,
    this.textLineHeight,
    this.textLetterSpacing,
    this.textPlacement,
    this.textOffset,
    this.textHaloColor,
    this.textHaloWidth,
    this.textMaxLengthPerLine,
    this.allowOverlap,
    this.iconLabelingGroup,
    this.iconLabelingMargin,
    this.iconPriority,
    this.textLabelingGroup,
    this.textLabelingMargin,
    this.textPriority,
    this.iconMetaphorImage,
    this.visibility,
  });

  @override
  Map<String, Object?> toJsMap() => {
    if (iconImage != null) 'iconImage': iconImage!.toJsValue(),
    if (iconWidth != null) 'iconWidth': iconWidth!.toJsValue(),
    if (iconAnchor != null) 'iconAnchor': iconAnchor,
    if (iconOffset != null) 'iconOffset': iconOffset,
    if (textField != null) 'textField': textField!.toJsValue(),
    if (textFont != null) 'textFont': textFont!.toJsValue(),
    if (textColor != null) 'textColor': textColor!.toJsValue(),
    if (textFontSize != null) 'textFontSize': textFontSize!.toJsValue(),
    if (textLineHeight != null) 'textLineHeight': textLineHeight,
    if (textLetterSpacing != null) 'textLetterSpacing': textLetterSpacing,
    if (textPlacement != null) 'textPlacement': textPlacement!.toJsValue(),
    if (textOffset != null) 'textOffset': textOffset!.toJsValue(),
    if (textHaloColor != null) 'textHaloColor': textHaloColor!.toJsValue(),
    if (textHaloWidth != null) 'textHaloWidth': textHaloWidth,
    if (textMaxLengthPerLine != null) 'textMaxLengthPerLine': textMaxLengthPerLine,
    if (allowOverlap != null) 'allowOverlap': allowOverlap,
    if (iconLabelingGroup != null) 'iconLabelingGroup': iconLabelingGroup,
    if (iconLabelingMargin != null) 'iconLabelingMargin': iconLabelingMargin!.toJsMap(),
    if (iconPriority != null) 'iconPriority': iconPriority!.toJsValue(),
    if (textLabelingGroup != null) 'textLabelingGroup': textLabelingGroup,
    if (textLabelingMargin != null) 'textLabelingMargin': textLabelingMargin!.toJsMap(),
    if (textPriority != null) 'textPriority': textPriority!.toJsValue(),
    if (iconMetaphorImage != null) 'iconMetaphorImage': iconMetaphorImage!.toJsValue(),
    if (visibility != null) 'visibility': visibility!.value,
  };
}

/// Extra margins for an object inside a labeling group.
///
/// Mirrors `LabelingMargin` from `styles.d.ts`.
class LabelingMargin {
  /// Top and bottom margin in pixels.
  final double? topBottom;

  /// Left and right margin in pixels.
  final double? leftRight;

  const LabelingMargin({this.topBottom, this.leftRight});

  Map<String, Object?> toJsMap() => {
    if (topBottom != null) 'topBottom': topBottom,
    if (leftRight != null) 'leftRight': leftRight,
  };
}
