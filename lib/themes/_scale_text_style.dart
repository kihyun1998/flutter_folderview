import 'package:flutter/widgets.dart';

/// Returns a scaled copy of [style], resolving a null `fontSize` against
/// [defaultFontSize] before multiplying.
///
/// Library-private — used by Theme `scale` methods that own a non-nullable
/// `TextStyle` slot. Not exported from `lib/flutter_folderview.dart`.
TextStyle scaleTextStyle(
  TextStyle? style,
  double factor,
  double defaultFontSize,
) {
  final base = style ?? TextStyle(fontSize: defaultFontSize);
  return base.copyWith(
    fontSize: (base.fontSize ?? defaultFontSize) * factor,
    letterSpacing:
        base.letterSpacing != null ? base.letterSpacing! * factor : null,
  );
}

/// Like [scaleTextStyle] but preserves null: if [style] is null, returns null
/// without materializing a [TextStyle] from [defaultFontSize]. Used for
/// opt-in styles such as `ChildNodeTheme.selectedTextStyle` and
/// `NodeTooltipTheme.textStyle`.
TextStyle? scaleOptionalTextStyle(
  TextStyle? style,
  double factor,
  double defaultFontSize,
) {
  if (style == null) return null;
  return style.copyWith(
    fontSize: style.fontSize != null ? style.fontSize! * factor : null,
    letterSpacing:
        style.letterSpacing != null ? style.letterSpacing! * factor : null,
  );
}
