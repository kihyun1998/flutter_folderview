import 'dart:ui' show lerpDouble;
import 'package:flutter/widgets.dart';

/// Theme data for parent node styling in FolderView
@immutable
class ParentNodeTheme {
  /// Widget to display for parent icon (collapsed state)
  final Widget? widget;

  /// Widget to display for parent icon (expanded state)
  final Widget? openWidget;

  /// Width of the icon widget
  final double width;

  /// Height of the icon widget
  final double height;

  /// Padding around the icon widget
  final EdgeInsets padding;

  /// Margin around the icon widget
  final EdgeInsets margin;

  /// Spacing between icon and text
  final double iconToTextSpacing;

  /// Text style for parent nodes
  final TextStyle? textStyle;

  /// Creates a [ParentNodeTheme]
  const ParentNodeTheme({
    this.widget,
    this.openWidget,
    this.width = 20.0,
    this.height = 20.0,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.iconToTextSpacing = 8.0,
    this.textStyle,
  });

  /// Creates a copy of this theme with the given fields replaced with new values
  ParentNodeTheme copyWith({
    Widget? widget,
    Widget? openWidget,
    double? width,
    double? height,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? iconToTextSpacing,
    TextStyle? textStyle,
  }) {
    return ParentNodeTheme(
      widget: widget ?? this.widget,
      openWidget: openWidget ?? this.openWidget,
      width: width ?? this.width,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      iconToTextSpacing: iconToTextSpacing ?? this.iconToTextSpacing,
      textStyle: textStyle ?? this.textStyle,
    );
  }

  /// Linearly interpolate between two [ParentNodeTheme]s
  static ParentNodeTheme lerp(
    ParentNodeTheme? a,
    ParentNodeTheme? b,
    double t,
  ) {
    if (a == null && b == null) {
      return const ParentNodeTheme();
    }
    if (a == null) return b!;
    if (b == null) return a;

    return ParentNodeTheme(
      widget: t < 0.5 ? a.widget : b.widget,
      openWidget: t < 0.5 ? a.openWidget : b.openWidget,
      width: lerpDouble(a.width, b.width, t) ?? 20.0,
      height: lerpDouble(a.height, b.height, t) ?? 20.0,
      padding: EdgeInsets.lerp(a.padding, b.padding, t) ?? EdgeInsets.zero,
      margin: EdgeInsets.lerp(a.margin, b.margin, t) ?? EdgeInsets.zero,
      iconToTextSpacing:
          lerpDouble(a.iconToTextSpacing, b.iconToTextSpacing, t) ?? 8.0,
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is ParentNodeTheme &&
        other.widget == widget &&
        other.openWidget == openWidget &&
        other.width == width &&
        other.height == height &&
        other.padding == padding &&
        other.margin == margin &&
        other.iconToTextSpacing == iconToTextSpacing &&
        other.textStyle == textStyle;
  }

  @override
  int get hashCode => Object.hash(
        widget,
        openWidget,
        width,
        height,
        padding,
        margin,
        iconToTextSpacing,
        textStyle,
      );

  @override
  String toString() {
    return 'ParentNodeTheme('
        'widget: $widget, '
        'openWidget: $openWidget, '
        'width: $width, '
        'height: $height, '
        'padding: $padding, '
        'margin: $margin, '
        'iconToTextSpacing: $iconToTextSpacing, '
        'textStyle: $textStyle'
        ')';
  }
}
