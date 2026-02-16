import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_folderview/widgets/custom_ink_well.dart';
import 'package:just_tooltip/just_tooltip.dart';

import '../models/flat_node.dart';
import '../models/node.dart';
import '../themes/flutter_folder_view_theme.dart';
import '../themes/folder_view_line_theme.dart';
import '../themes/node_tooltip_theme.dart';

/// A single-row widget for a flattened tree node.
///
/// This widget renders one row in a virtualized flat ListView.
/// It does NOT contain children — children are separate rows in the list.
class NodeWidget<T> extends StatelessWidget {
  final FlatNode<T> flatNode;
  final ViewMode mode;
  final Function(Node<T>)? onTap;
  final Function(Node<T>)? onDoubleTap;
  final Function(Node<T>, TapDownDetails)? onSecondaryTap;
  final Set<String>? selectedNodeIds;
  final bool isExpanded;
  final FlutterFolderViewTheme<T> theme;

  const NodeWidget({
    super.key,
    required this.flatNode,
    required this.mode,
    this.onTap,
    this.onDoubleTap,
    this.onSecondaryTap,
    this.selectedNodeIds,
    required this.isExpanded,
    required this.theme,
  });

  Node<T> get node => flatNode.node;

  @override
  Widget build(BuildContext context) {
    final lineWidth = theme.expandIconTheme.width +
        theme.expandIconTheme.padding.horizontal +
        theme.expandIconTheme.margin.horizontal;

    return SizedBox(
      height: theme.rowHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Tree lines for this node
          if (!flatNode.isRoot) _buildTreeLines(lineWidth),

          // 2. Ancestor continuation lines
          for (int d = 0; d < flatNode.ancestorIsLastFlags.length; d++)
            if (!flatNode.ancestorIsLastFlags[d])
              _buildContinuationLine(d, lineWidth),

          // 3. Content row
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Indent spacer
              SizedBox(width: flatNode.depth * lineWidth),

              // Clickable content
              Expanded(
                child: node.type == NodeType.child
                    ? _buildChildNodeContent(context)
                    : _buildFolderParentNodeContent(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Draws the connector line for this node (vertical + horizontal)
  Widget _buildTreeLines(double lineWidth) {
    return Positioned(
      left: (flatNode.depth - 1) * lineWidth,
      top: 0,
      bottom: 0,
      width: lineWidth,
      child: CustomPaint(
        painter: _LinePainter(
          isLast: flatNode.isLast,
          isRoot: flatNode.isRoot,
          lineTheme: theme.lineTheme,
          rowHeight: theme.rowHeight,
        ),
      ),
    );
  }

  /// Draws a vertical continuation line for a non-last ancestor at the given depth.
  Widget _buildContinuationLine(int ancestorDepth, double lineWidth) {
    return Positioned(
      left: ancestorDepth * lineWidth,
      top: 0,
      bottom: 0,
      width: lineWidth,
      child: CustomPaint(
        painter: _ContinuationLinePainter(
          lineTheme: theme.lineTheme,
        ),
      ),
    );
  }

  /// Build expand/collapse icon widget
  Widget _buildExpandIcon() {
    final expandTheme = theme.expandIconTheme;

    if (expandTheme.widget == null) {
      return SizedBox(
        width: expandTheme.width +
            expandTheme.padding.horizontal +
            expandTheme.margin.horizontal,
      );
    }

    return Container(
      margin: expandTheme.margin,
      padding: expandTheme.padding,
      child: SizedBox(
        width: expandTheme.width,
        height: expandTheme.height,
        child: expandTheme.widget,
      ),
    );
  }

  /// Build node icon widget based on node type
  Widget _buildNodeIcon() {
    Widget? iconWidget;
    Widget? resolvedWidget;
    double width;
    double height;
    EdgeInsets padding;
    EdgeInsets margin;

    switch (node.type) {
      case NodeType.folder:
        final folderTheme = theme.folderTheme;
        if (isExpanded) {
          resolvedWidget = folderTheme.openWidgetResolver?.call(node);
          iconWidget =
              resolvedWidget ?? folderTheme.openWidget ?? folderTheme.widget;
        } else {
          resolvedWidget = folderTheme.widgetResolver?.call(node);
          iconWidget = resolvedWidget ?? folderTheme.widget;
        }
        width = folderTheme.width;
        height = folderTheme.height;
        padding = folderTheme.padding;
        margin = folderTheme.margin;
        break;
      case NodeType.parent:
        final parentTheme = theme.parentTheme;
        if (mode == ViewMode.tree) {
          if (isExpanded) {
            resolvedWidget = parentTheme.openWidgetResolver?.call(node);
            iconWidget =
                resolvedWidget ?? parentTheme.openWidget ?? parentTheme.widget;
          } else {
            resolvedWidget = parentTheme.widgetResolver?.call(node);
            iconWidget = resolvedWidget ?? parentTheme.widget;
          }
        } else {
          resolvedWidget = parentTheme.widgetResolver?.call(node);
          iconWidget = resolvedWidget ?? parentTheme.widget;
        }
        width = parentTheme.width;
        height = parentTheme.height;
        padding = parentTheme.padding;
        margin = parentTheme.margin;
        break;
      case NodeType.child:
        final childTheme = theme.childTheme;
        resolvedWidget = childTheme.widgetResolver?.call(node);
        iconWidget = resolvedWidget ?? childTheme.widget;
        width = childTheme.width;
        height = childTheme.height;
        padding = childTheme.padding;
        margin = childTheme.margin;
        break;
    }

    if (iconWidget == null) {
      return SizedBox(
        width: width + padding.horizontal + margin.horizontal,
      );
    }

    return Container(
      margin: margin,
      padding: padding,
      child: SizedBox(
        width: width,
        height: height,
        child: iconWidget,
      ),
    );
  }

  /// Wraps a widget with tooltip based on node type theme
  Widget _wrapWithTooltip(Widget child) {
    NodeTooltipTheme<T>? tooltipTheme;

    switch (node.type) {
      case NodeType.folder:
        tooltipTheme = theme.folderTheme.tooltipTheme;
        break;
      case NodeType.parent:
        tooltipTheme = theme.parentTheme.tooltipTheme;
        break;
      case NodeType.child:
        tooltipTheme = theme.childTheme.tooltipTheme;
        break;
    }

    if (tooltipTheme == null || !tooltipTheme.useTooltip) {
      return child;
    }

    // Resolve tooltip content: tooltipBuilderResolver > tooltipBuilder > message
    WidgetBuilder? resolvedBuilder;
    if (tooltipTheme.tooltipBuilderResolver != null) {
      resolvedBuilder = tooltipTheme.tooltipBuilderResolver?.call(node);
    }
    resolvedBuilder ??= tooltipTheme.tooltipBuilder;

    final String? message = tooltipTheme.message;

    if (resolvedBuilder == null && (message == null || message.isEmpty)) {
      return child;
    }

    return JustTooltip(
      direction: tooltipTheme.direction,
      alignment: tooltipTheme.alignment,
      offset: tooltipTheme.offset,
      crossAxisOffset: tooltipTheme.crossAxisOffset,
      screenMargin: tooltipTheme.screenMargin ?? 8.0,
      theme: JustTooltipTheme(
        textStyle: tooltipTheme.textStyle,
        backgroundColor:
            tooltipTheme.backgroundColor ?? const Color(0xFF616161),
        borderRadius: tooltipTheme.borderRadius ??
            const BorderRadius.all(Radius.circular(6)),
        padding: tooltipTheme.padding ??
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        elevation: tooltipTheme.elevation ?? 4.0,
        boxShadow: tooltipTheme.boxShadow,
        borderColor: tooltipTheme.borderColor,
        borderWidth: tooltipTheme.borderWidth ?? 0.0,
        showArrow: tooltipTheme.showArrow ?? false,
        arrowBaseWidth: tooltipTheme.arrowBaseWidth ?? 12.0,
        arrowLength: tooltipTheme.arrowLength ?? 6.0,
        arrowPositionRatio: tooltipTheme.arrowPositionRatio ?? 0.25,
      ),
      controller: tooltipTheme.controller,
      enableTap: tooltipTheme.enableTap ?? false,
      enableHover: tooltipTheme.enableHover ?? true,
      animation: tooltipTheme.animation ?? TooltipAnimation.fade,
      animationCurve: tooltipTheme.animationCurve,
      fadeBegin: tooltipTheme.fadeBegin ?? 0.0,
      scaleBegin: tooltipTheme.scaleBegin ?? 0.0,
      slideOffset: tooltipTheme.slideOffset ?? 0.3,
      rotationBegin: tooltipTheme.rotationBegin ?? -0.05,
      animationDuration:
          tooltipTheme.animationDuration ?? const Duration(milliseconds: 150),
      onShow: tooltipTheme.onShow,
      onHide: tooltipTheme.onHide,
      interactive: tooltipTheme.interactive ?? false,
      waitDuration: tooltipTheme.waitDuration,
      showDuration: tooltipTheme.showDuration,
      message: resolvedBuilder == null ? message : null,
      tooltipBuilder: resolvedBuilder,
      child: child,
    );
  }

  /// Build content for child nodes (leaf nodes) with CustomInkWell
  Widget _buildChildNodeContent(BuildContext context) {
    final isSelected = selectedNodeIds?.contains(node.id) ?? false;
    final childTheme = theme.childTheme;

    return CustomInkWell(
      clickInterval: childTheme.clickInterval,
      borderRadius: theme.nodeStyleTheme.borderRadius,
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
          ? (details) => onSecondaryTap?.call(node, details)
          : null,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: _wrapWithTooltip(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNodeIcon(),
              Flexible(
                child: Text(
                  _getLabel(),
                  style: _getTextStyle(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build content for folder/parent nodes with CustomInkWell
  Widget _buildFolderParentNodeContent(BuildContext context) {
    final isSelected = selectedNodeIds?.contains(node.id) ?? false;
    final expandTheme = theme.expandIconTheme;

    return CustomInkWell(
      clickInterval: 0,
      borderRadius: theme.nodeStyleTheme.borderRadius,
      isSelected: isSelected,
      backgroundColor: Colors.transparent,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      hoverColor: (node.type == NodeType.folder
              ? theme.folderTheme.hoverColor
              : theme.parentTheme.hoverColor) ??
          Theme.of(context).colorScheme.surfaceContainerHighest,
      splashColor: (node.type == NodeType.folder
              ? theme.folderTheme.splashColor
              : theme.parentTheme.splashColor) ??
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
      highlightColor: (node.type == NodeType.folder
              ? theme.folderTheme.highlightColor
              : theme.parentTheme.highlightColor) ??
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      onTap: () => onTap?.call(node),
      onDoubleTap: null,
      child: Row(
        children: [
          // Expand/Collapse Icon
          if (node.canExpand)
            Transform.rotate(
              angle: isExpanded ? math.pi / 2 : 0,
              child: IconTheme(
                data: IconThemeData(
                  color: isExpanded
                      ? (expandTheme.expandedColor ?? expandTheme.color)
                      : expandTheme.color,
                ),
                child: _buildExpandIcon(),
              ),
            )
          else
            IconTheme(
              data: IconThemeData(
                color: expandTheme.color,
              ),
              child: _buildExpandIcon(),
            ),

          // Node Icon + Label with tooltip
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: _wrapWithTooltip(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildNodeIcon(),
                    Flexible(
                      child: Text(
                        _getLabel(),
                        style: _getTextStyle(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLabel() {
    String? resolvedLabel;

    switch (node.type) {
      case NodeType.folder:
        resolvedLabel = theme.folderTheme.labelResolver?.call(node);
        break;
      case NodeType.parent:
        resolvedLabel = theme.parentTheme.labelResolver?.call(node);
        break;
      case NodeType.child:
        resolvedLabel = theme.childTheme.labelResolver?.call(node);
        break;
    }

    return resolvedLabel ?? node.label;
  }

  TextStyle? _getTextStyle() {
    final isSelected = selectedNodeIds?.contains(node.id) ?? false;
    TextStyle? style;
    TextStyle? resolvedStyle;

    switch (node.type) {
      case NodeType.folder:
        final folderTheme = theme.folderTheme;
        resolvedStyle = folderTheme.textStyleResolver?.call(node);
        style = resolvedStyle ?? folderTheme.textStyle;
        break;
      case NodeType.parent:
        final parentTheme = theme.parentTheme;
        resolvedStyle = parentTheme.textStyleResolver?.call(node);
        style = resolvedStyle ?? parentTheme.textStyle;
        break;
      case NodeType.child:
        final childTheme = theme.childTheme;
        resolvedStyle = childTheme.textStyleResolver?.call(node);
        style = resolvedStyle ?? childTheme.textStyle;

        if (isSelected) {
          TextStyle? selectedStyle;
          final resolvedSelectedStyle =
              childTheme.selectedTextStyleResolver?.call(node);
          selectedStyle = resolvedSelectedStyle ?? childTheme.selectedTextStyle;
          style = style?.merge(selectedStyle) ?? selectedStyle;
        }
        break;
    }

    return style;
  }
}

/// Paints the connector line for a node (vertical line + horizontal connector)
class _LinePainter extends CustomPainter {
  final bool isLast;
  final bool isRoot;
  final FolderViewLineTheme lineTheme;
  final double rowHeight;

  _LinePainter({
    required this.isLast,
    required this.isRoot,
    required this.lineTheme,
    required this.rowHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (isRoot || lineTheme.lineStyle == LineStyle.none) {
      return;
    }

    final paint = Paint()
      ..color = lineTheme.lineColor
      ..strokeWidth = lineTheme.lineWidth
      ..strokeCap = lineTheme.strokeCap
      ..style = PaintingStyle.stroke;

    final double centerX = size.width / 2;

    switch (lineTheme.lineStyle) {
      case LineStyle.connector:
        // Vertical line: from top to middle (if last) or full height
        canvas.drawLine(
          Offset(centerX, 0),
          Offset(centerX, isLast ? rowHeight / 2 : size.height),
          paint,
        );

        // Horizontal connector
        double connectorY = rowHeight / 2;
        canvas.drawLine(
          Offset(centerX, connectorY),
          Offset(size.width, connectorY),
          paint,
        );
        break;

      case LineStyle.scope:
        canvas.drawLine(
          Offset(centerX, 0),
          Offset(centerX, size.height),
          paint,
        );
        break;

      case LineStyle.none:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) {
    return oldDelegate.isLast != isLast ||
        oldDelegate.isRoot != isRoot ||
        oldDelegate.lineTheme != lineTheme ||
        oldDelegate.rowHeight != rowHeight;
  }
}

/// Paints a vertical continuation line for a non-last ancestor.
class _ContinuationLinePainter extends CustomPainter {
  final FolderViewLineTheme lineTheme;

  _ContinuationLinePainter({required this.lineTheme});

  @override
  void paint(Canvas canvas, Size size) {
    if (lineTheme.lineStyle == LineStyle.none) return;

    final paint = Paint()
      ..color = lineTheme.lineColor
      ..strokeWidth = lineTheme.lineWidth
      ..strokeCap = lineTheme.strokeCap
      ..style = PaintingStyle.stroke;

    final double centerX = size.width / 2;
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ContinuationLinePainter oldDelegate) {
    return oldDelegate.lineTheme != lineTheme;
  }
}
