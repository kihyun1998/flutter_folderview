import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/flat_node.dart';
import '../models/node.dart';
import '../services/row_metrics.dart';
import '../themes/expandable_node_theme_view.dart';
import 'custom_ink_well.dart';
import 'node_render_parts.dart';

/// Renders an expandable-container row (Folder or Parent). Consumes an
/// [ExpandableNodeThemeView] so one renderer serves both tiers without
/// switching on type. Never handles Selection (ADR-0003).
class ExpandableNodeRenderer<T> extends StatelessWidget {
  final FlatNode<T> flatNode;
  final RowMetrics<T> metrics;
  final ExpandableNodeThemeView<T> themeView;

  /// Whether this tier uses expanded/collapsed icons. Folders always do;
  /// Parents only do in tree View Mode.
  final bool useOpenState;
  final bool isExpanded;
  final Function(Node<T>)? onTap;
  final double scale;

  const ExpandableNodeRenderer({
    super.key,
    required this.flatNode,
    required this.metrics,
    required this.themeView,
    required this.useOpenState,
    required this.isExpanded,
    required this.onTap,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final node = flatNode.node;
    final expandTheme = metrics.theme.expandIconTheme;
    final style = metrics.effectiveTextStyle(node);
    final label = themeView.labelResolver?.call(node) ?? node.label;

    // Icon resolution: open-state icon only when this tier uses it and the node
    // is expanded; otherwise the collapsed widget.
    final Widget? iconWidget;
    if (useOpenState && isExpanded) {
      iconWidget = themeView.openWidgetResolver?.call(node) ??
          themeView.openWidget ??
          themeView.widget;
    } else {
      iconWidget = themeView.widgetResolver?.call(node) ?? themeView.widget;
    }

    final iconBox = NodeIconBox(
      iconWidget: iconWidget,
      width: themeView.width,
      height: themeView.height,
      padding: themeView.padding,
      margin: themeView.margin,
      emptyWidth: metrics.iconBoxWidth(node.type),
      scale: scale,
    );

    final expandBox = NodeIconBox(
      iconWidget: expandTheme.widget,
      width: expandTheme.width,
      height: expandTheme.height,
      padding: expandTheme.padding,
      margin: expandTheme.margin,
      emptyWidth: metrics.expandStripWidth,
      scale: scale,
    );

    final Widget chevron = node.canExpand
        ? Transform.rotate(
            angle: isExpanded ? math.pi / 2 : 0,
            child: IconTheme(
              data: IconThemeData(
                color: isExpanded
                    ? (expandTheme.expandedColor ?? expandTheme.color)
                    : expandTheme.color,
              ),
              child: expandBox,
            ),
          )
        : IconTheme(
            data: IconThemeData(color: expandTheme.color),
            child: expandBox,
          );

    return CustomInkWell(
      clickInterval: 0,
      borderRadius: metrics.theme.nodeStyleTheme.borderRadius,
      backgroundColor: Colors.transparent,
      hoverColor: themeView.hoverColor ??
          Theme.of(context).colorScheme.surfaceContainerHighest,
      splashColor: themeView.splashColor ??
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
      highlightColor: themeView.highlightColor ??
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      onTap: () => onTap?.call(node),
      onDoubleTap: null,
      child: Row(
        children: [
          chevron,
          Expanded(
            child: NodeLabel<T>(
              iconBox: iconBox,
              label: label,
              style: style,
              tooltipTheme: themeView.tooltipTheme,
              node: node,
            ),
          ),
        ],
      ),
    );
  }
}
