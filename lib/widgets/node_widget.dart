import 'package:flutter/material.dart' hide TooltipTheme;
import 'package:flutter_folderview/widgets/custom_ink_well.dart';

import '../models/node.dart';
import '../themes/flutter_folder_view_theme.dart';
import '../themes/folder_view_line_theme.dart';
import '../themes/node_tooltip_theme.dart';

class NodeWidget<T> extends StatefulWidget {
  final Node<T> node;
  final ViewMode mode;
  final Function(Node<T>)? onTap;
  final Function(Node<T>)? onDoubleTap;
  final Function(Node<T>, TapDownDetails)? onSecondaryTap;
  final bool isLast;
  final bool isFirst;
  final bool isRoot;
  final int depth;
  final Set<String>? selectedNodeIds;
  final Set<String>? expandedNodeIds;
  final FlutterFolderViewTheme<T> theme;

  const NodeWidget({
    super.key,
    required this.node,
    required this.mode,
    this.onTap,
    this.onDoubleTap,
    this.onSecondaryTap,
    this.isLast = false,
    this.isFirst = false,
    this.isRoot = false,
    this.depth = 0,
    this.selectedNodeIds,
    this.expandedNodeIds,
    required this.theme,
  });

  @override
  State<NodeWidget<T>> createState() => _NodeWidgetState<T>();
}

class _NodeWidgetState<T> extends State<NodeWidget<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconTurns;
  late Animation<double> _heightFactor;

  bool get _isExpanded =>
      widget.expandedNodeIds?.contains(widget.node.id) ?? false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.theme.animationDuration),
      vsync: this,
    );
    _iconTurns = Tween<double>(
      begin: 0.0,
      end: 0.25,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _heightFactor = _controller.view;

    // Initialize state
    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(NodeWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animation duration if theme changed
    if (oldWidget.theme.animationDuration != widget.theme.animationDuration) {
      _controller.duration =
          Duration(milliseconds: widget.theme.animationDuration);
    }

    final wasExpanded =
        oldWidget.expandedNodeIds?.contains(widget.node.id) ?? false;
    if (_isExpanded != wasExpanded) {
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate line width based on expand icon size
    final lineWidth = widget.theme.expandIconTheme.width +
        widget.theme.expandIconTheme.padding.horizontal +
        widget.theme.expandIconTheme.margin.horizontal;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 1. Vertical Line (Pipeline)
        Positioned(
          left: widget.isRoot ? 0 : (widget.depth - 1) * lineWidth,
          top: widget.isFirst || widget.isRoot ? 0 : -widget.theme.rowSpacing,
          bottom: widget.isLast ? null : 0,
          height: widget.isLast ? widget.theme.rowHeight / 2 : null,
          width: lineWidth,
          child: CustomPaint(
            painter: _LinePainter(
              isLast: widget.isLast,
              isRoot: widget.isRoot,
              lineTheme: widget.theme.lineTheme,
              rowHeight: widget.theme.rowHeight,
            ),
          ),
        ),

        // 2. Content
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            SizedBox(
              height: widget.theme.rowHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Spacer for the connector line (Non-clickable)
                  // Indent based on depth
                  SizedBox(
                    width: widget.depth * lineWidth,
                  ),

                  // Clickable Content
                  Expanded(
                    child: widget.node.type == NodeType.child
                        ? _buildChildNodeContent()
                        : _buildFolderParentNodeContent(),
                  ),
                ],
              ),
            ),
            // Children
            ClipRect(
              child: SizeTransition(
                sizeFactor: _heightFactor,
                axisAlignment: -1.0, // Expand from top
                child: Column(
                  children: [
                    // Spacing between tile and first child
                    if (widget.theme.rowSpacing > 0 &&
                        widget.node.children.isNotEmpty)
                      SizedBox(height: widget.theme.rowSpacing),

                    // Children with spacing between them
                    for (int i = 0; i < widget.node.children.length; i++) ...[
                      NodeWidget<T>(
                        node: widget.node.children[i],
                        mode: widget.mode,
                        onTap: widget.onTap,
                        onDoubleTap: widget.onDoubleTap,
                        onSecondaryTap: widget.onSecondaryTap,
                        isLast: i == widget.node.children.length - 1,
                        isFirst: i == 0,
                        isRoot: false,
                        depth: widget.depth + 1,
                        selectedNodeIds: widget.selectedNodeIds,
                        expandedNodeIds: widget.expandedNodeIds,
                        theme: widget.theme,
                      ),
                      if (i < widget.node.children.length - 1 &&
                          widget.theme.rowSpacing > 0)
                        SizedBox(height: widget.theme.rowSpacing),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build expand/collapse icon widget
  Widget _buildExpandIcon() {
    final expandTheme = widget.theme.expandIconTheme;

    // For child nodes, always return empty space
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

    switch (widget.node.type) {
      case NodeType.folder:
        final folderTheme = widget.theme.folderTheme;
        // Try resolver first
        if (_isExpanded) {
          resolvedWidget = folderTheme.openWidgetResolver?.call(widget.node);
          iconWidget =
              resolvedWidget ?? folderTheme.openWidget ?? folderTheme.widget;
        } else {
          resolvedWidget = folderTheme.widgetResolver?.call(widget.node);
          iconWidget = resolvedWidget ?? folderTheme.widget;
        }
        width = folderTheme.width;
        height = folderTheme.height;
        padding = folderTheme.padding;
        margin = folderTheme.margin;
        break;
      case NodeType.parent:
        final parentTheme = widget.theme.parentTheme;
        if (widget.mode == ViewMode.tree) {
          if (_isExpanded) {
            resolvedWidget = parentTheme.openWidgetResolver?.call(widget.node);
            iconWidget =
                resolvedWidget ?? parentTheme.openWidget ?? parentTheme.widget;
          } else {
            resolvedWidget = parentTheme.widgetResolver?.call(widget.node);
            iconWidget = resolvedWidget ?? parentTheme.widget;
          }
        } else {
          resolvedWidget = parentTheme.widgetResolver?.call(widget.node);
          iconWidget = resolvedWidget ?? parentTheme.widget;
        }
        width = parentTheme.width;
        height = parentTheme.height;
        padding = parentTheme.padding;
        margin = parentTheme.margin;
        break;
      case NodeType.child:
        final childTheme = widget.theme.childTheme;
        // Try resolver first
        resolvedWidget = childTheme.widgetResolver?.call(widget.node);
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

    // Get tooltip theme based on node type
    switch (widget.node.type) {
      case NodeType.folder:
        tooltipTheme = widget.theme.folderTheme.tooltipTheme;
        break;
      case NodeType.parent:
        tooltipTheme = widget.theme.parentTheme.tooltipTheme;
        break;
      case NodeType.child:
        tooltipTheme = widget.theme.childTheme.tooltipTheme;
        break;
    }

    // If tooltip is not enabled or theme is null, return child as-is
    if (tooltipTheme == null || !tooltipTheme.useTooltip) {
      return child;
    }

    // Resolve rich message
    InlineSpan? richMessage;
    if (tooltipTheme.richMessageResolver != null) {
      richMessage = tooltipTheme.richMessageResolver?.call(widget.node);
    }
    richMessage ??= tooltipTheme.richMessage;

    // Resolve message
    String? message = tooltipTheme.message;

    // If no message and no rich message, return child as-is
    if ((message == null || message.isEmpty) && richMessage == null) {
      return child;
    }

    // Wrap with tooltip
    return Tooltip(
      margin: tooltipTheme.margin ?? const EdgeInsets.symmetric(horizontal: 30),
      textStyle:
          richMessage == null ? tooltipTheme.textStyle : tooltipTheme.textStyle,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      preferBelow: tooltipTheme.position == TooltipPosition.bottom,
      verticalOffset: tooltipTheme.verticalOffset,
      decoration: BoxDecoration(
        color: tooltipTheme.backgroundColor ?? Colors.grey[800],
        borderRadius: BorderRadius.circular(5),
        boxShadow: tooltipTheme.boxShadow ??
            [
              BoxShadow(
                blurRadius: 3,
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ],
      ),
      waitDuration:
          tooltipTheme.waitDuration ?? const Duration(milliseconds: 300),
      exitDuration: Duration.zero,
      showDuration: Duration.zero,
      message: message,
      richMessage: richMessage,
      child: child,
    );
  }

  /// Build content for child nodes (leaf nodes) with CustomInkWell
  Widget _buildChildNodeContent() {
    final isSelected =
        widget.selectedNodeIds?.contains(widget.node.id) ?? false;
    final childTheme = widget.theme.childTheme;

    return CustomInkWell(
      clickInterval: childTheme.clickInterval,
      borderRadius: widget.theme.nodeStyleTheme.borderRadius,
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
      onTap: () => widget.onTap?.call(widget.node),
      onDoubleTap: () => widget.onDoubleTap?.call(widget.node),
      onSecondaryTapDown: widget.onSecondaryTap != null
          ? (details) => widget.onSecondaryTap?.call(widget.node, details)
          : null,
      child: Row(
        children: [
          // Node Icon
          _buildNodeIcon(),

          // Label with tooltip
          Flexible(
            child: _wrapWithTooltip(
              Text(
                _getLabel(),
                style: _getTextStyle(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build content for folder/parent nodes with CustomInkWell
  Widget _buildFolderParentNodeContent() {
    final isSelected =
        widget.selectedNodeIds?.contains(widget.node.id) ?? false;
    final expandTheme = widget.theme.expandIconTheme;

    return CustomInkWell(
      clickInterval: 0, // Not used for folder/parent nodes (no double tap)
      borderRadius: widget.theme.nodeStyleTheme.borderRadius,
      isSelected: isSelected,
      backgroundColor: Colors.transparent,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      hoverColor: (widget.node.type == NodeType.folder
              ? widget.theme.folderTheme.hoverColor
              : widget.theme.parentTheme.hoverColor) ??
          Theme.of(context).colorScheme.surfaceContainerHighest,
      splashColor: (widget.node.type == NodeType.folder
              ? widget.theme.folderTheme.splashColor
              : widget.theme.parentTheme.splashColor) ??
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
      highlightColor: (widget.node.type == NodeType.folder
              ? widget.theme.folderTheme.highlightColor
              : widget.theme.parentTheme.highlightColor) ??
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      onTap: () => widget.onTap?.call(widget.node),
      onDoubleTap: null, // Folder/Parent nodes don't use double tap
      child: Row(
        children: [
          // Expand/Collapse Icon
          if (widget.node.canExpand)
            RotationTransition(
              turns: _iconTurns,
              child: IconTheme(
                data: IconThemeData(
                  color: _isExpanded
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

          // Node Icon
          _buildNodeIcon(),

          // Label with tooltip
          Flexible(
            child: _wrapWithTooltip(
              Text(
                _getLabel(),
                style: _getTextStyle(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLabel() {
    String? resolvedLabel;

    switch (widget.node.type) {
      case NodeType.folder:
        final folderTheme = widget.theme.folderTheme;
        // Try resolver first
        resolvedLabel = folderTheme.labelResolver?.call(widget.node);
        break;
      case NodeType.parent:
        final parentTheme = widget.theme.parentTheme;
        // Try resolver first
        resolvedLabel = parentTheme.labelResolver?.call(widget.node);
        break;
      case NodeType.child:
        final childTheme = widget.theme.childTheme;
        // Try resolver first
        resolvedLabel = childTheme.labelResolver?.call(widget.node);
        break;
    }

    return resolvedLabel ?? widget.node.label;
  }

  TextStyle? _getTextStyle() {
    final isSelected =
        widget.selectedNodeIds?.contains(widget.node.id) ?? false;
    TextStyle? style;
    TextStyle? resolvedStyle;

    switch (widget.node.type) {
      case NodeType.folder:
        final folderTheme = widget.theme.folderTheme;
        // Try resolver first
        resolvedStyle = folderTheme.textStyleResolver?.call(widget.node);
        style = resolvedStyle ?? folderTheme.textStyle;
        break;
      case NodeType.parent:
        final parentTheme = widget.theme.parentTheme;
        // Try resolver first
        resolvedStyle = parentTheme.textStyleResolver?.call(widget.node);
        style = resolvedStyle ?? parentTheme.textStyle;
        break;
      case NodeType.child:
        final childTheme = widget.theme.childTheme;
        // Try resolver first
        resolvedStyle = childTheme.textStyleResolver?.call(widget.node);
        style = resolvedStyle ?? childTheme.textStyle;

        // Apply selected style only for child nodes
        if (isSelected) {
          TextStyle? selectedStyle;
          final resolvedSelectedStyle =
              childTheme.selectedTextStyleResolver?.call(widget.node);
          selectedStyle = resolvedSelectedStyle ?? childTheme.selectedTextStyle;

          style = style?.merge(selectedStyle) ?? selectedStyle;
        }
        break;
    }

    return style;
  }
}

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
    // Don't draw any lines for root nodes or when lineStyle is none
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
        // Traditional tree lines with ├─ and └─
        // Vertical Line
        canvas.drawLine(
          Offset(centerX, 0),
          Offset(centerX, size.height),
          paint,
        );

        // Horizontal Connector
        double connectorY = isLast ? size.height : rowHeight / 2;
        canvas.drawLine(
          Offset(centerX, connectorY),
          Offset(size.width, connectorY),
          paint,
        );
        break;

      case LineStyle.scope:
        // Vertical indent guide line only (like VS Code)
        // Draw vertical line for the full height to show scope
        canvas.drawLine(
          Offset(centerX, 0),
          Offset(centerX, size.height),
          paint,
        );
        break;

      case LineStyle.none:
        // Already handled above (early return)
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
