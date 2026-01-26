import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';

import '../models/node.dart';

/// Position for tooltip display
enum TooltipPosition {
  top,
  bottom,
}

/// Theme data for tooltip styling in FolderView nodes
@immutable
class NodeTooltipTheme<T> {
  /// Whether to use tooltip for this node type
  final bool useTooltip;

  /// Position of the tooltip (top or bottom)
  final TooltipPosition position;

  /// Margin around the tooltip
  final EdgeInsetsGeometry? margin;

  /// Vertical offset from the widget
  final double verticalOffset;

  /// Wait duration before showing tooltip
  final Duration? waitDuration;

  /// Static tooltip message
  final String? message;

  /// Text style for tooltip message
  final TextStyle? textStyle;

  /// Rich message with formatting
  final InlineSpan? richMessage;

  /// Resolver function to dynamically determine rich message based on node data
  /// If returns null, falls back to [richMessage]
  final InlineSpan? Function(Node<T> node)? richMessageResolver;

  /// Background color for tooltip
  final Color? backgroundColor;

  /// Box shadow for tooltip decoration
  final List<BoxShadow>? boxShadow;

  /// Creates a [NodeTooltipTheme]
  const NodeTooltipTheme({
    this.useTooltip = false,
    this.position = TooltipPosition.top,
    this.margin,
    this.verticalOffset = 20.0,
    this.waitDuration,
    this.message,
    this.textStyle,
    this.richMessage,
    this.richMessageResolver,
    this.backgroundColor,
    this.boxShadow,
  });

  /// Creates a copy of this theme with the given fields replaced with new values
  NodeTooltipTheme<T> copyWith({
    bool? useTooltip,
    TooltipPosition? position,
    EdgeInsetsGeometry? margin,
    double? verticalOffset,
    Duration? waitDuration,
    String? message,
    TextStyle? textStyle,
    InlineSpan? richMessage,
    InlineSpan? Function(Node<T> node)? richMessageResolver,
    Color? backgroundColor,
    List<BoxShadow>? boxShadow,
  }) {
    return NodeTooltipTheme<T>(
      useTooltip: useTooltip ?? this.useTooltip,
      position: position ?? this.position,
      margin: margin ?? this.margin,
      verticalOffset: verticalOffset ?? this.verticalOffset,
      waitDuration: waitDuration ?? this.waitDuration,
      message: message ?? this.message,
      textStyle: textStyle ?? this.textStyle,
      richMessage: richMessage ?? this.richMessage,
      richMessageResolver: richMessageResolver ?? this.richMessageResolver,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      boxShadow: boxShadow ?? this.boxShadow,
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
      position: t < 0.5 ? a.position : b.position,
      margin: t < 0.5 ? a.margin : b.margin,
      verticalOffset: lerpDouble(a.verticalOffset, b.verticalOffset, t) ?? 20.0,
      waitDuration: t < 0.5 ? a.waitDuration : b.waitDuration,
      message: t < 0.5 ? a.message : b.message,
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t),
      richMessage: t < 0.5 ? a.richMessage : b.richMessage,
      richMessageResolver:
          t < 0.5 ? a.richMessageResolver : b.richMessageResolver,
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      boxShadow: t < 0.5 ? a.boxShadow : b.boxShadow,
    );
  }
}
