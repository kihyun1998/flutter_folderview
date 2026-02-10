import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';
import 'package:just_tooltip/just_tooltip.dart';

import '../models/node.dart';

/// Theme data for tooltip styling in FolderView nodes
@immutable
class NodeTooltipTheme<T> {
  /// Whether to use tooltip for this node type
  final bool useTooltip;

  /// Direction of the tooltip (top, bottom, left, right)
  final TooltipDirection direction;

  /// Alignment of the tooltip relative to the anchor (start, center, end)
  final TooltipAlignment alignment;

  /// Offset from the widget
  final double offset;

  /// Additional offset along the cross-axis of [direction]
  final double crossAxisOffset;

  /// Static tooltip message
  final String? message;

  /// Text style for tooltip message
  final TextStyle? textStyle;

  /// Custom widget builder for tooltip content
  final WidgetBuilder? tooltipBuilder;

  /// Resolver function to dynamically determine tooltip widget based on node data
  /// If returns null, falls back to [tooltipBuilder]
  final WidgetBuilder? Function(Node<T> node)? tooltipBuilderResolver;

  /// Background color for tooltip
  final Color? backgroundColor;

  /// Elevation (shadow depth) for tooltip
  final double? elevation;

  /// Border radius for tooltip
  final BorderRadius? borderRadius;

  /// Padding inside the tooltip
  final EdgeInsets? padding;

  /// Controller for programmatic tooltip control
  final JustTooltipController? controller;

  /// Whether tap triggers the tooltip
  final bool? enableTap;

  /// Whether hover triggers the tooltip
  final bool? enableHover;

  /// Animation duration for tooltip show/hide
  final Duration? animationDuration;

  /// Callback when tooltip is shown
  final VoidCallback? onShow;

  /// Callback when tooltip is hidden
  final VoidCallback? onHide;

  /// Creates a [NodeTooltipTheme]
  const NodeTooltipTheme({
    this.useTooltip = false,
    this.direction = TooltipDirection.top,
    this.alignment = TooltipAlignment.center,
    this.offset = 8.0,
    this.crossAxisOffset = 0.0,
    this.message,
    this.textStyle,
    this.tooltipBuilder,
    this.tooltipBuilderResolver,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.padding,
    this.controller,
    this.enableTap,
    this.enableHover,
    this.animationDuration,
    this.onShow,
    this.onHide,
  });

  /// Creates a copy of this theme with the given fields replaced with new values
  NodeTooltipTheme<T> copyWith({
    bool? useTooltip,
    TooltipDirection? direction,
    TooltipAlignment? alignment,
    double? offset,
    double? crossAxisOffset,
    String? message,
    TextStyle? textStyle,
    WidgetBuilder? tooltipBuilder,
    WidgetBuilder? Function(Node<T> node)? tooltipBuilderResolver,
    Color? backgroundColor,
    double? elevation,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    JustTooltipController? controller,
    bool? enableTap,
    bool? enableHover,
    Duration? animationDuration,
    VoidCallback? onShow,
    VoidCallback? onHide,
  }) {
    return NodeTooltipTheme<T>(
      useTooltip: useTooltip ?? this.useTooltip,
      direction: direction ?? this.direction,
      alignment: alignment ?? this.alignment,
      offset: offset ?? this.offset,
      crossAxisOffset: crossAxisOffset ?? this.crossAxisOffset,
      message: message ?? this.message,
      textStyle: textStyle ?? this.textStyle,
      tooltipBuilder: tooltipBuilder ?? this.tooltipBuilder,
      tooltipBuilderResolver:
          tooltipBuilderResolver ?? this.tooltipBuilderResolver,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      elevation: elevation ?? this.elevation,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      controller: controller ?? this.controller,
      enableTap: enableTap ?? this.enableTap,
      enableHover: enableHover ?? this.enableHover,
      animationDuration: animationDuration ?? this.animationDuration,
      onShow: onShow ?? this.onShow,
      onHide: onHide ?? this.onHide,
    );
  }

  /// Linearly interpolate between two [NodeTooltipTheme]s
  static NodeTooltipTheme<T> lerp<T>(
    NodeTooltipTheme<T>? a,
    NodeTooltipTheme<T>? b,
    double t,
  ) {
    if (a == null && b == null) {
      return const NodeTooltipTheme();
    }
    if (a == null) return b!;
    if (b == null) return a;

    return NodeTooltipTheme<T>(
      useTooltip: t < 0.5 ? a.useTooltip : b.useTooltip,
      direction: t < 0.5 ? a.direction : b.direction,
      alignment: t < 0.5 ? a.alignment : b.alignment,
      offset: lerpDouble(a.offset, b.offset, t) ?? 8.0,
      crossAxisOffset:
          lerpDouble(a.crossAxisOffset, b.crossAxisOffset, t) ?? 0.0,
      message: t < 0.5 ? a.message : b.message,
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t),
      tooltipBuilder: t < 0.5 ? a.tooltipBuilder : b.tooltipBuilder,
      tooltipBuilderResolver:
          t < 0.5 ? a.tooltipBuilderResolver : b.tooltipBuilderResolver,
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      elevation: lerpDouble(a.elevation, b.elevation, t),
      borderRadius: BorderRadius.lerp(a.borderRadius, b.borderRadius, t),
      padding: EdgeInsets.lerp(a.padding, b.padding, t),
      controller: t < 0.5 ? a.controller : b.controller,
      enableTap: t < 0.5 ? a.enableTap : b.enableTap,
      enableHover: t < 0.5 ? a.enableHover : b.enableHover,
      animationDuration: t < 0.5 ? a.animationDuration : b.animationDuration,
      onShow: t < 0.5 ? a.onShow : b.onShow,
      onHide: t < 0.5 ? a.onHide : b.onHide,
    );
  }
}
