import 'package:flutter/material.dart';
import 'package:flutter_folderview/widgets/custom_ink_well.dart';

import '../models/node.dart';
import '../themes/flutter_folder_view_theme.dart';
import '../themes/folder_view_line_theme.dart';

class NodeWidget<T> extends StatefulWidget {
  final Node<T> node;
  final ViewMode mode;
  final Function(Node<T>)? onTap;
  final Function(Node<T>)? onDoubleTap;
  final Function(Node<T>, TapDownDetails)? onSecondaryTap;
  final bool isLast;
  final bool isRoot;
  final int depth;
  final Set<String>? selectedNodeIds;
  final FlutterFolderViewTheme theme;

  const NodeWidget({
    super.key,
    required this.node,
    required this.mode,
    this.onTap,
    this.onDoubleTap,
    this.onSecondaryTap,
    this.isLast = false,
    this.isRoot = false,
    this.depth = 0,
    this.selectedNodeIds,
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

  static const double _rowHeight = 40.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconTurns = Tween<double>(
      begin: 0.0,
      end: 0.25,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _heightFactor = _controller.view;

    // Initialize state
    if (widget.node.isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(NodeWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.node.isExpanded != oldWidget.node.isExpanded) {
      if (widget.node.isExpanded) {
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
      children: [
        // 1. Vertical Line (Pipeline)
        Positioned(
          left: widget.isRoot ? 0 : (widget.depth - 1) * lineWidth,
          top: 0,
          bottom: widget.isLast ? null : 0,
          height: widget.isLast ? _rowHeight / 2 : null,
          width: lineWidth,
          child: CustomPaint(
            painter: _LinePainter(
              isLast: widget.isLast,
              isRoot: widget.isRoot,
              lineTheme: widget.theme.lineTheme,
            ),
          ),
        ),

        // 2. Content
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            SizedBox(
              height: _rowHeight,
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
                  children: widget.node.children.asMap().entries.map((entry) {
                    return NodeWidget<T>(
                      node: entry.value,
                      mode: widget.mode,
                      onTap: widget.onTap,
                      onDoubleTap: widget.onDoubleTap,
                      onSecondaryTap: widget.onSecondaryTap,
                      isLast: entry.key == widget.node.children.length - 1,
                      isRoot: false,
                      depth: widget.depth + 1,
                      selectedNodeIds: widget.selectedNodeIds,
                      theme: widget.theme,
                    );
                  }).toList(),
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
    double width;
    double height;
    EdgeInsets padding;
    EdgeInsets margin;

    switch (widget.node.type) {
      case NodeType.folder:
        final folderTheme = widget.theme.folderTheme;
        iconWidget = widget.node.isExpanded
            ? folderTheme.openWidget ?? folderTheme.widget
            : folderTheme.widget;
        width = folderTheme.width;
        height = folderTheme.height;
        padding = folderTheme.padding;
        margin = folderTheme.margin;
        break;
      case NodeType.parent:
        final parentTheme = widget.theme.parentTheme;
        if (widget.mode == ViewMode.tree) {
          iconWidget = widget.node.isExpanded
              ? parentTheme.openWidget ?? parentTheme.widget
              : parentTheme.widget;
        } else {
          iconWidget = parentTheme.widget;
        }
        width = parentTheme.width;
        height = parentTheme.height;
        padding = parentTheme.padding;
        margin = parentTheme.margin;
        break;
      case NodeType.child:
        final childTheme = widget.theme.childTheme;
        iconWidget = childTheme.widget;
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

  /// Build content for child nodes (leaf nodes) with CustomInkWell
  Widget _buildChildNodeContent() {
    final isSelected =
        widget.selectedNodeIds?.contains(widget.node.id) ?? false;
    final childTheme = widget.theme.childTheme;

    return CustomInkWell(
      clickInterval: 300,
      borderRadius: widget.theme.nodeStyleTheme.borderRadius,
      isSelected: isSelected,
      backgroundColor: Colors.transparent,
      selectedColor: childTheme.selectedBackgroundColor ??
          Theme.of(context).colorScheme.primaryContainer,
      hoverColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      splashColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
      highlightColor:
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      onTap: () => widget.onTap?.call(widget.node),
      onDoubleTap: () => widget.onDoubleTap?.call(widget.node),
      onSecondaryTapDown: widget.onSecondaryTap != null
          ? (details) => widget.onSecondaryTap?.call(widget.node, details)
          : null,
      child: Row(
        children: [
          // No expand icon for leaf nodes - just empty space
          _buildExpandIcon(),

          // Node Icon
          _buildNodeIcon(),
          SizedBox(width: childTheme.iconToTextSpacing),

          // Label
          Expanded(child: Text(widget.node.label, style: _getTextStyle())),
        ],
      ),
    );
  }

  /// Build content for folder/parent nodes with CustomInkWell
  Widget _buildFolderParentNodeContent() {
    final isSelected =
        widget.selectedNodeIds?.contains(widget.node.id) ?? false;

    return CustomInkWell(
      clickInterval: 300,
      borderRadius: widget.theme.nodeStyleTheme.borderRadius,
      isSelected: isSelected,
      backgroundColor: Colors.transparent,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      hoverColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      splashColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
      highlightColor:
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      onTap: () => widget.onTap?.call(widget.node),
      onDoubleTap: null, // Folder/Parent nodes don't use double tap
      child: Row(
        children: [
          // Expand/Collapse Icon
          if (widget.node.canExpand)
            RotationTransition(
              turns: _iconTurns,
              child: _buildExpandIcon(),
            )
          else
            _buildExpandIcon(),

          // Node Icon
          _buildNodeIcon(),
          SizedBox(
              width: widget.node.type == NodeType.folder
                  ? widget.theme.folderTheme.iconToTextSpacing
                  : widget.theme.parentTheme.iconToTextSpacing),

          // Label
          Expanded(child: Text(widget.node.label, style: _getTextStyle())),
        ],
      ),
    );
  }

  TextStyle? _getTextStyle() {
    final isSelected =
        widget.selectedNodeIds?.contains(widget.node.id) ?? false;
    TextStyle? style;

    switch (widget.node.type) {
      case NodeType.folder:
        style = widget.theme.folderTheme.textStyle;
        break;
      case NodeType.parent:
        style = widget.theme.parentTheme.textStyle;
        break;
      case NodeType.child:
        style = widget.theme.childTheme.textStyle;
        // Apply selected style only for child nodes
        if (isSelected) {
          style = style?.merge(widget.theme.childTheme.selectedTextStyle) ??
              widget.theme.childTheme.selectedTextStyle;
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

  _LinePainter({
    required this.isLast,
    required this.isRoot,
    required this.lineTheme,
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
        double connectorY = isLast ? size.height : 20.0;
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
        oldDelegate.lineTheme != lineTheme;
  }
}
