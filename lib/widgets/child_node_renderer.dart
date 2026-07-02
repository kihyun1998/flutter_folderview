import 'package:flutter/material.dart';

import '../models/flat_node.dart';
import '../models/node.dart';
import '../services/row_metrics.dart';
import 'custom_ink_well.dart';
import 'node_render_parts.dart';

/// Renders a Child (leaf) row. The only renderer aware of Selection (ADR-0003).
class ChildNodeRenderer<T> extends StatelessWidget {
  final FlatNode<T> flatNode;
  final RowMetrics<T> metrics;
  final Set<String>? selectedNodeIds;
  final Function(Node<T>)? onTap;
  final Function(Node<T>)? onDoubleTap;
  final Function(Node<T>, TapDownDetails)? onSecondaryTap;
  final double scale;

  const ChildNodeRenderer({
    super.key,
    required this.flatNode,
    required this.metrics,
    required this.selectedNodeIds,
    required this.onTap,
    required this.onDoubleTap,
    required this.onSecondaryTap,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final node = flatNode.node;
    final childTheme = metrics.theme.childTheme;
    final isSelected = selectedNodeIds?.contains(node.id) ?? false;

    var style = metrics.effectiveTextStyle(node);
    if (isSelected) {
      final resolvedSelected = childTheme.selectedTextStyleResolver?.call(node);
      final selectedStyle = resolvedSelected ?? childTheme.selectedTextStyle;
      style = style?.merge(selectedStyle) ?? selectedStyle;
    }

    final label = childTheme.labelResolver?.call(node) ?? node.label;
    final iconWidget = childTheme.widgetResolver?.call(node) ?? childTheme.widget;

    final iconBox = NodeIconBox(
      iconWidget: iconWidget,
      width: childTheme.width,
      height: childTheme.height,
      padding: childTheme.padding,
      margin: childTheme.margin,
      emptyWidth: metrics.iconBoxWidth(NodeType.child),
      scale: scale,
    );

    return CustomInkWell(
      clickInterval: childTheme.clickInterval,
      borderRadius: metrics.theme.nodeStyleTheme.borderRadius,
      isSelected: isSelected,
      backgroundColor: Colors.transparent,
      selectedColor: childTheme.selectedBackgroundColor ??
          Theme.of(context).colorScheme.primaryContainer,
      hoverColor: childTheme.hoverColor ??
          Theme.of(context).colorScheme.surfaceContainerHighest,
      splashColor: childTheme.splashColor ??
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
      highlightColor: childTheme.highlightColor ??
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      onTap: () => onTap?.call(node),
      onDoubleTap: () => onDoubleTap?.call(node),
      onSecondaryTapDown: onSecondaryTap != null
          ? (details) => onSecondaryTap!(node, details)
          : null,
      child: NodeLabel<T>(
        iconBox: iconBox,
        label: label,
        style: style,
        tooltipTheme: childTheme.tooltipTheme,
        node: node,
      ),
    );
  }
}
