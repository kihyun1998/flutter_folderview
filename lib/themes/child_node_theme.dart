import 'dart:ui' show lerpDouble;
import 'package:flutter/widgets.dart';

/// Theme data for child node styling in FolderView
@immutable
class ChildNodeTheme {
  /// Widget to display for child icon
  final Widget? widget;

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

  /// Text style for child nodes
  final TextStyle? textStyle;

  /// Text style for selected child nodes
  final TextStyle? selectedTextStyle;

  /// Background color for selected child nodes
  final Color? selectedBackgroundColor;

  /// Click interval in milliseconds for distinguishing single click from double click
  /// Only applies to child nodes (leaf nodes)
  final int clickInterval;

  /// Creates a [ChildNodeTheme]
  const ChildNodeTheme({
    this.widget,
    this.width = 20.0,
    this.height = 20.0,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.iconToTextSpacing = 8.0,
    this.textStyle,
    this.selectedTextStyle,
    this.selectedBackgroundColor,
    this.clickInterval = 300,
  });

  /// Creates a copy of this theme with the given fields replaced with new values
  ChildNodeTheme copyWith({
    Widget? widget,
    double? width,
    double? height,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? iconToTextSpacing,
    TextStyle? textStyle,
    TextStyle? selectedTextStyle,
    Color? selectedBackgroundColor,
    int? clickInterval,
  }) {
    return ChildNodeTheme(
      widget: widget ?? this.widget,
      width: width ?? this.width,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      iconToTextSpacing: iconToTextSpacing ?? this.iconToTextSpacing,
      textStyle: textStyle ?? this.textStyle,
      selectedTextStyle: selectedTextStyle ?? this.selectedTextStyle,
      selectedBackgroundColor:
          selectedBackgroundColor ?? this.selectedBackgroundColor,
      clickInterval: clickInterval ?? this.clickInterval,
    );
  }

  /// Linearly interpolate between two [ChildNodeTheme]s
  static ChildNodeTheme lerp(
    ChildNodeTheme? a,
    ChildNodeTheme? b,
    double t,
  ) {
    if (a == null && b == null) {
      return const ChildNodeTheme();
    }
    if (a == null) return b!;
    if (b == null) return a;

    return ChildNodeTheme(
      widget: t < 0.5 ? a.widget : b.widget,
      width: lerpDouble(a.width, b.width, t) ?? 20.0,
      height: lerpDouble(a.height, b.height, t) ?? 20.0,
      padding: EdgeInsets.lerp(a.padding, b.padding, t) ?? EdgeInsets.zero,
      margin: EdgeInsets.lerp(a.margin, b.margin, t) ?? EdgeInsets.zero,
      iconToTextSpacing:
          lerpDouble(a.iconToTextSpacing, b.iconToTextSpacing, t) ?? 8.0,
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t),
      selectedTextStyle:
          TextStyle.lerp(a.selectedTextStyle, b.selectedTextStyle, t),
      selectedBackgroundColor: Color.lerp(
          a.selectedBackgroundColor, b.selectedBackgroundColor, t),
      clickInterval: (lerpDouble(a.clickInterval.toDouble(), b.clickInterval.toDouble(), t) ?? 300).round(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is ChildNodeTheme &&
        other.widget == widget &&
        other.width == width &&
        other.height == height &&
        other.padding == padding &&
        other.margin == margin &&
        other.iconToTextSpacing == iconToTextSpacing &&
        other.textStyle == textStyle &&
        other.selectedTextStyle == selectedTextStyle &&
        other.selectedBackgroundColor == selectedBackgroundColor &&
        other.clickInterval == clickInterval;
  }

  @override
  int get hashCode => Object.hash(
        widget,
        width,
        height,
        padding,
        margin,
        iconToTextSpacing,
        textStyle,
        selectedTextStyle,
        selectedBackgroundColor,
        clickInterval,
      );

  @override
  String toString() {
    return 'ChildNodeTheme('
        'widget: $widget, '
        'width: $width, '
        'height: $height, '
        'padding: $padding, '
        'margin: $margin, '
        'iconToTextSpacing: $iconToTextSpacing, '
        'textStyle: $textStyle, '
        'selectedTextStyle: $selectedTextStyle, '
        'selectedBackgroundColor: $selectedBackgroundColor, '
        'clickInterval: $clickInterval'
        ')';
  }
}
