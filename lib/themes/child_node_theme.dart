import 'dart:ui' show lerpDouble;
import 'package:flutter/widgets.dart';

import '../models/node.dart';

/// Theme data for child node styling in FolderView
@immutable
class ChildNodeTheme<T> {
  /// Widget to display for child icon
  final Widget? widget;

  /// Resolver function to dynamically determine the widget based on node data
  /// If returns null, falls back to [widget]
  final Widget? Function(Node<T> node)? widgetResolver;

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

  /// Resolver function to dynamically determine the text style based on node data
  /// If returns null, falls back to [textStyle]
  final TextStyle? Function(Node<T> node)? textStyleResolver;

  /// Text style for selected child nodes
  final TextStyle? selectedTextStyle;

  /// Resolver function to dynamically determine the selected text style based on node data
  /// If returns null, falls back to [selectedTextStyle]
  final TextStyle? Function(Node<T> node)? selectedTextStyleResolver;

  /// Background color for selected child nodes
  final Color? selectedBackgroundColor;

  /// Hover color when mouse hovers over the node
  final Color? hoverColor;

  /// Splash color for tap animations
  final Color? splashColor;

  /// Highlight color for tap feedback
  final Color? highlightColor;

  /// Click interval in milliseconds for distinguishing single click from double click
  /// Only applies to child nodes (leaf nodes)
  final int clickInterval;

  /// Creates a [ChildNodeTheme]
  const ChildNodeTheme({
    this.widget,
    this.widgetResolver,
    this.width = 20.0,
    this.height = 20.0,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.iconToTextSpacing = 8.0,
    this.textStyle,
    this.textStyleResolver,
    this.selectedTextStyle,
    this.selectedTextStyleResolver,
    this.selectedBackgroundColor,
    this.hoverColor,
    this.splashColor,
    this.highlightColor,
    this.clickInterval = 300,
  });

  /// Creates a copy of this theme with the given fields replaced with new values
  ChildNodeTheme<T> copyWith({
    Widget? widget,
    Widget? Function(Node<T> node)? widgetResolver,
    double? width,
    double? height,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? iconToTextSpacing,
    TextStyle? textStyle,
    TextStyle? Function(Node<T> node)? textStyleResolver,
    TextStyle? selectedTextStyle,
    TextStyle? Function(Node<T> node)? selectedTextStyleResolver,
    Color? selectedBackgroundColor,
    Color? hoverColor,
    Color? splashColor,
    Color? highlightColor,
    int? clickInterval,
  }) {
    return ChildNodeTheme<T>(
      widget: widget ?? this.widget,
      widgetResolver: widgetResolver ?? this.widgetResolver,
      width: width ?? this.width,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      iconToTextSpacing: iconToTextSpacing ?? this.iconToTextSpacing,
      textStyle: textStyle ?? this.textStyle,
      textStyleResolver: textStyleResolver ?? this.textStyleResolver,
      selectedTextStyle: selectedTextStyle ?? this.selectedTextStyle,
      selectedTextStyleResolver:
          selectedTextStyleResolver ?? this.selectedTextStyleResolver,
      selectedBackgroundColor:
          selectedBackgroundColor ?? this.selectedBackgroundColor,
      hoverColor: hoverColor ?? this.hoverColor,
      splashColor: splashColor ?? this.splashColor,
      highlightColor: highlightColor ?? this.highlightColor,
      clickInterval: clickInterval ?? this.clickInterval,
    );
  }

  /// Linearly interpolate between two [ChildNodeTheme]s
  static ChildNodeTheme<T> lerp<T>(
    ChildNodeTheme<T>? a,
    ChildNodeTheme<T>? b,
    double t,
  ) {
    if (a == null && b == null) {
      return const ChildNodeTheme();
    }
    if (a == null) return b!;
    if (b == null) return a;

    return ChildNodeTheme<T>(
      widget: t < 0.5 ? a.widget : b.widget,
      widgetResolver: t < 0.5 ? a.widgetResolver : b.widgetResolver,
      width: lerpDouble(a.width, b.width, t) ?? 20.0,
      height: lerpDouble(a.height, b.height, t) ?? 20.0,
      padding: EdgeInsets.lerp(a.padding, b.padding, t) ?? EdgeInsets.zero,
      margin: EdgeInsets.lerp(a.margin, b.margin, t) ?? EdgeInsets.zero,
      iconToTextSpacing:
          lerpDouble(a.iconToTextSpacing, b.iconToTextSpacing, t) ?? 8.0,
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t),
      textStyleResolver: t < 0.5 ? a.textStyleResolver : b.textStyleResolver,
      selectedTextStyle:
          TextStyle.lerp(a.selectedTextStyle, b.selectedTextStyle, t),
      selectedTextStyleResolver:
          t < 0.5 ? a.selectedTextStyleResolver : b.selectedTextStyleResolver,
      selectedBackgroundColor:
          Color.lerp(a.selectedBackgroundColor, b.selectedBackgroundColor, t),
      hoverColor: Color.lerp(a.hoverColor, b.hoverColor, t),
      splashColor: Color.lerp(a.splashColor, b.splashColor, t),
      highlightColor: Color.lerp(a.highlightColor, b.highlightColor, t),
      clickInterval: (lerpDouble(
                  a.clickInterval.toDouble(), b.clickInterval.toDouble(), t) ??
              300)
          .round(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is ChildNodeTheme<T> &&
        other.widget == widget &&
        other.width == width &&
        other.height == height &&
        other.padding == padding &&
        other.margin == margin &&
        other.iconToTextSpacing == iconToTextSpacing &&
        other.textStyle == textStyle &&
        other.selectedTextStyle == selectedTextStyle &&
        other.selectedBackgroundColor == selectedBackgroundColor &&
        other.hoverColor == hoverColor &&
        other.splashColor == splashColor &&
        other.highlightColor == highlightColor &&
        other.clickInterval == clickInterval;
    // Note: resolver functions are not compared as they cannot be reliably compared
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
        hoverColor,
        splashColor,
        highlightColor,
        clickInterval,
        // Note: resolver functions are not included in hashCode
      );

  @override
  String toString() {
    return 'ChildNodeTheme<$T>('
        'widget: $widget, '
        'widgetResolver: ${widgetResolver != null ? 'provided' : 'null'}, '
        'width: $width, '
        'height: $height, '
        'padding: $padding, '
        'margin: $margin, '
        'iconToTextSpacing: $iconToTextSpacing, '
        'textStyle: $textStyle, '
        'textStyleResolver: ${textStyleResolver != null ? 'provided' : 'null'}, '
        'selectedTextStyle: $selectedTextStyle, '
        'selectedTextStyleResolver: ${selectedTextStyleResolver != null ? 'provided' : 'null'}, '
        'selectedBackgroundColor: $selectedBackgroundColor, '
        'hoverColor: $hoverColor, '
        'splashColor: $splashColor, '
        'highlightColor: $highlightColor, '
        'clickInterval: $clickInterval'
        ')';
  }
}
