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
    return Stack(
      children: [
        // 1. Vertical Line (Pipeline)
        Positioned(
          left: widget.isRoot ? 0 : (widget.depth - 1) * widget.theme.iconTheme.iconSize,
          top: 0,
          bottom: widget.isLast ? null : 0,
          height: widget.isLast ? _rowHeight / 2 : null,
          width: widget.theme.iconTheme.iconSize,
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
                    width: widget.depth * widget.theme.iconTheme.iconSize,
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

  /// Build content for child nodes (leaf nodes) with CustomInkWell
  Widget _buildChildNodeContent() {
    final isSelected =
        widget.selectedNodeIds?.contains(widget.node.id) ?? false;

    return CustomInkWell(
      clickInterval: 300,
      borderRadius: widget.theme.nodeStyleTheme.borderRadius,
      isSelected: isSelected,
      backgroundColor: Colors.transparent,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      hoverColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
      highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      onTap: () => widget.onTap?.call(widget.node),
      onDoubleTap: () => widget.onDoubleTap?.call(widget.node),
      onSecondaryTapDown: widget.onSecondaryTap != null
          ? (details) => widget.onSecondaryTap?.call(widget.node, details)
          : null,
      child: Row(
        children: [
          // No expand icon for leaf nodes
          SizedBox(width: widget.theme.iconTheme.iconSize),

          // Node Icon
          Icon(
            _getNodeIcon(),
            size: widget.theme.iconTheme.iconSize,
            color: _getIconColor(),
          ),
          const SizedBox(width: 8),

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
      splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
      highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      onTap: () => widget.onTap?.call(widget.node),
      onDoubleTap: null, // Folder/Parent nodes don't use double tap
      child: Row(
        children: [
          // Expand/Collapse Icon
          if (widget.node.canExpand)
            RotationTransition(
              turns: _iconTurns,
              child: Icon(
                widget.theme.iconTheme.expandIcon ?? Icons.chevron_right,
                size: widget.theme.iconTheme.iconSize,
                color: _getIconColor(),
              ),
            )
          else
            SizedBox(width: widget.theme.iconTheme.iconSize),

          // Node Icon
          Icon(
            _getNodeIcon(),
            size: widget.theme.iconTheme.iconSize,
            color: _getIconColor(),
          ),
          const SizedBox(width: 8),

          // Label
          Expanded(child: Text(widget.node.label, style: _getTextStyle())),
        ],
      ),
    );
  }

  IconData _getNodeIcon() {
    final iconTheme = widget.theme.iconTheme;

    switch (widget.node.type) {
      case NodeType.folder:
        return widget.node.isExpanded
            ? (iconTheme.folderOpenIcon ?? Icons.folder_open)
            : (iconTheme.folderIcon ?? Icons.folder);
      case NodeType.parent:
        if (widget.mode == ViewMode.tree) {
          return widget.node.isExpanded
              ? (iconTheme.parentOpenIcon ??
                    iconTheme.parentIcon ??
                    Icons.account_tree)
              : (iconTheme.parentIcon ?? Icons.account_tree);
        } else {
          return iconTheme.parentIcon ?? Icons.description;
        }
      case NodeType.child:
        return iconTheme.childIcon ?? Icons.insert_drive_file;
    }
  }

  Color? _getIconColor() {
    final iconTheme = widget.theme.iconTheme;

    if (widget.selectedNodeIds?.contains(widget.node.id) ?? false) {
      return iconTheme.selectedIconColor;
    }

    return iconTheme.iconColor;
  }

  TextStyle? _getTextStyle() {
    TextStyle? style = widget.theme.textTheme.textStyle;

    if (widget.selectedNodeIds?.contains(widget.node.id) ?? false) {
      style =
          style?.merge(widget.theme.textTheme.selectedTextStyle) ??
          widget.theme.textTheme.selectedTextStyle;
    }

    switch (widget.node.type) {
      case NodeType.folder:
        style =
            style?.merge(widget.theme.textTheme.folderTextStyle) ??
            widget.theme.textTheme.folderTextStyle;
        break;
      case NodeType.parent:
        style =
            style?.merge(widget.theme.textTheme.parentTextStyle) ??
            widget.theme.textTheme.parentTextStyle;
        break;
      case NodeType.child:
        style =
            style?.merge(widget.theme.textTheme.childTextStyle) ??
            widget.theme.textTheme.childTextStyle;
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
