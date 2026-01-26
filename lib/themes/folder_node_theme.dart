import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';

import '../models/node.dart';

/// Theme data for folder node styling in FolderView
@immutable
class FolderNodeTheme<T> {
  /// Widget to display for folder icon (collapsed state)
  final Widget? widget;

  /// Resolver function to dynamically determine the widget based on node data
  /// If returns null, falls back to [widget]
  final Widget? Function(Node<T> node)? widgetResolver;

  /// Widget to display for folder icon (expanded state)
  final Widget? openWidget;

  /// Resolver function to dynamically determine the open widget based on node data
  /// If returns null, falls back to [openWidget]
  final Widget? Function(Node<T> node)? openWidgetResolver;

  /// Width of the icon widget
  final double width;

  /// Height of the icon widget
  final double height;

  /// Padding around the icon widget
  final EdgeInsets padding;

  /// Margin around the icon widget
  final EdgeInsets margin;

  /// Text style for folder nodes
  final TextStyle? textStyle;

  /// Resolver function to dynamically determine the text style based on node data
  /// If returns null, falls back to [textStyle]
  final TextStyle? Function(Node<T> node)? textStyleResolver;

  /// Hover color when mouse hovers over the node
  final Color? hoverColor;

  /// Splash color for tap animations
  final Color? splashColor;

  /// Highlight color for tap feedback
  final Color? highlightColor;

  /// Creates a [FolderNodeTheme]
  const FolderNodeTheme({
    this.widget,
    this.widgetResolver,
    this.openWidget,
    this.openWidgetResolver,
    this.width = 20.0,
    this.height = 20.0,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.textStyle,
    this.textStyleResolver,
    this.hoverColor,
    this.splashColor,
    this.highlightColor,
  });

  /// Creates a copy of this theme with the given fields replaced with new values
  FolderNodeTheme<T> copyWith({
    Widget? widget,
    Widget? Function(Node<T> node)? widgetResolver,
    Widget? openWidget,
    Widget? Function(Node<T> node)? openWidgetResolver,
    double? width,
    double? height,
    EdgeInsets? padding,
    EdgeInsets? margin,
    TextStyle? textStyle,
    TextStyle? Function(Node<T> node)? textStyleResolver,
    Color? hoverColor,
    Color? splashColor,
    Color? highlightColor,
  }) {
    return FolderNodeTheme<T>(
      widget: widget ?? this.widget,
      widgetResolver: widgetResolver ?? this.widgetResolver,
      openWidget: openWidget ?? this.openWidget,
      openWidgetResolver: openWidgetResolver ?? this.openWidgetResolver,
      width: width ?? this.width,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      textStyle: textStyle ?? this.textStyle,
      textStyleResolver: textStyleResolver ?? this.textStyleResolver,
      hoverColor: hoverColor ?? this.hoverColor,
      splashColor: splashColor ?? this.splashColor,
      highlightColor: highlightColor ?? this.highlightColor,
    );
  }

  /// Linearly interpolate between two [FolderNodeTheme]s
  static FolderNodeTheme<T> lerp<T>(
    FolderNodeTheme<T>? a,
    FolderNodeTheme<T>? b,
    double t,
  ) {
    if (a == null && b == null) {
      return const FolderNodeTheme();
    }
    if (a == null) return b!;
    if (b == null) return a;

    return FolderNodeTheme<T>(
      widget: t < 0.5 ? a.widget : b.widget,
      widgetResolver: t < 0.5 ? a.widgetResolver : b.widgetResolver,
      openWidget: t < 0.5 ? a.openWidget : b.openWidget,
      openWidgetResolver: t < 0.5 ? a.openWidgetResolver : b.openWidgetResolver,
      width: lerpDouble(a.width, b.width, t) ?? 20.0,
      height: lerpDouble(a.height, b.height, t) ?? 20.0,
      padding: EdgeInsets.lerp(a.padding, b.padding, t) ?? EdgeInsets.zero,
      margin: EdgeInsets.lerp(a.margin, b.margin, t) ?? EdgeInsets.zero,
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t),
      textStyleResolver: t < 0.5 ? a.textStyleResolver : b.textStyleResolver,
      hoverColor: Color.lerp(a.hoverColor, b.hoverColor, t),
      splashColor: Color.lerp(a.splashColor, b.splashColor, t),
      highlightColor: Color.lerp(a.highlightColor, b.highlightColor, t),
    );
  }
}
