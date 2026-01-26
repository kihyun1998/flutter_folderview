import 'dart:ui' show lerpDouble;
import 'package:flutter/widgets.dart';

/// Theme data for expand/collapse icon in FolderView
@immutable
class ExpandIconTheme {
  /// Widget to display for expand/collapse icon
  /// This widget will be rotated during expand/collapse animation
  final Widget? widget;

  /// Width of the icon widget
  final double width;

  /// Height of the icon widget
  final double height;

  /// Padding around the icon widget
  final EdgeInsets padding;

  /// Margin around the icon widget
  final EdgeInsets margin;

  /// Creates an [ExpandIconTheme]
  const ExpandIconTheme({
    this.widget,
    this.width = 20.0,
    this.height = 20.0,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
  });

  /// Creates a copy of this theme with the given fields replaced with new values
  ExpandIconTheme copyWith({
    Widget? widget,
    double? width,
    double? height,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return ExpandIconTheme(
      widget: widget ?? this.widget,
      width: width ?? this.width,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
    );
  }

  /// Linearly interpolate between two [ExpandIconTheme]s
  static ExpandIconTheme lerp(
    ExpandIconTheme? a,
    ExpandIconTheme? b,
    double t,
  ) {
    if (a == null && b == null) {
      return const ExpandIconTheme();
    }
    if (a == null) return b!;
    if (b == null) return a;

    return ExpandIconTheme(
      widget: t < 0.5 ? a.widget : b.widget,
      width: lerpDouble(a.width, b.width, t) ?? 20.0,
      height: lerpDouble(a.height, b.height, t) ?? 20.0,
      padding: EdgeInsets.lerp(a.padding, b.padding, t) ?? EdgeInsets.zero,
      margin: EdgeInsets.lerp(a.margin, b.margin, t) ?? EdgeInsets.zero,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is ExpandIconTheme &&
        other.widget == widget &&
        other.width == width &&
        other.height == height &&
        other.padding == padding &&
        other.margin == margin;
  }

  @override
  int get hashCode => Object.hash(
        widget,
        width,
        height,
        padding,
        margin,
      );

  @override
  String toString() {
    return 'ExpandIconTheme('
        'widget: $widget, '
        'width: $width, '
        'height: $height, '
        'padding: $padding, '
        'margin: $margin'
        ')';
  }
}
