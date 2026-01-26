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

  /// Spacing between icon and text
  final double iconToTextSpacing;

  /// Text style for folder nodes
  final TextStyle? textStyle;

  /// Resolver function to dynamically determine the text style based on node data
  /// If returns null, falls back to [textStyle]
  final TextStyle? Function(Node<T> node)? textStyleResolver;

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
    this.iconToTextSpacing = 8.0,
    this.textStyle,
    this.textStyleResolver,
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
    double? iconToTextSpacing,
    TextStyle? textStyle,
    TextStyle? Function(Node<T> node)? textStyleResolver,
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
      iconToTextSpacing: iconToTextSpacing ?? this.iconToTextSpacing,
      textStyle: textStyle ?? this.textStyle,
      textStyleResolver: textStyleResolver ?? this.textStyleResolver,
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
      iconToTextSpacing:
          lerpDouble(a.iconToTextSpacing, b.iconToTextSpacing, t) ?? 8.0,
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t),
      textStyleResolver: t < 0.5 ? a.textStyleResolver : b.textStyleResolver,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is FolderNodeTheme<T> &&
        other.widget == widget &&
        other.openWidget == openWidget &&
        other.width == width &&
        other.height == height &&
        other.padding == padding &&
        other.margin == margin &&
        other.iconToTextSpacing == iconToTextSpacing &&
        other.textStyle == textStyle;
    // Note: resolver functions are not compared as they cannot be reliably compared
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
        // Note: resolver functions are not included in hashCode
      );

  @override
  String toString() {
    return 'FolderNodeTheme<$T>('
        'widget: $widget, '
        'widgetResolver: ${widgetResolver != null ? 'provided' : 'null'}, '
        'openWidget: $openWidget, '
        'openWidgetResolver: ${openWidgetResolver != null ? 'provided' : 'null'}, '
        'width: $width, '
        'height: $height, '
        'padding: $padding, '
        'margin: $margin, '
        'iconToTextSpacing: $iconToTextSpacing, '
        'textStyle: $textStyle, '
        'textStyleResolver: ${textStyleResolver != null ? 'provided' : 'null'}'
        ')';
  }
}
