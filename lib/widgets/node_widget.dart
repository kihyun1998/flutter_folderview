import 'package:flutter/material.dart';

import '../models/node.dart';
import '../themes/folder_view_line_theme.dart';

class NodeWidget<T> extends StatefulWidget {
  final Node<T> node;
  final ViewMode mode;
  final Function(Node<T>)? onTap;
  final bool isLast;
  final bool isRoot;
  final Set<String>? selectedNodeIds;
  final FolderViewLineTheme lineTheme;

  const NodeWidget({
    super.key,
    required this.node,
    required this.mode,
    this.onTap,
    this.isLast = false,
    this.isRoot = false,
    this.selectedNodeIds,
    required this.lineTheme,
  });

  @override
  State<NodeWidget<T>> createState() => _NodeWidgetState<T>();
}

class _NodeWidgetState<T> extends State<NodeWidget<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconTurns;
  late Animation<double> _heightFactor;

  static const double _iconSize = 20.0;
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
          left: 0,
          top: 0,
          bottom: widget.isLast ? null : 0,
          height: widget.isLast ? _rowHeight / 2 : null,
          width: _iconSize,
          child: CustomPaint(
            painter: _LinePainter(
              isLast: widget.isLast,
              isRoot: widget.isRoot,
              lineTheme: widget.lineTheme,
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
                  // // Spacer for the connector line (Non-clickable)
                  const SizedBox(width: _iconSize),

                  // Clickable Content
                  Expanded(
                    child: InkWell(
                      onTap: () => widget.onTap?.call(widget.node),
                      child: Container(
                        color:
                            (widget.selectedNodeIds?.contains(widget.node.id) ??
                                false)
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                        child: Row(
                          children: [
                            // Expand/Collapse Icon
                            if (widget.node.canExpand)
                              RotationTransition(
                                turns: _iconTurns,
                                child: Icon(
                                  Icons.chevron_right,
                                  size: _iconSize,
                                ),
                              )
                            else
                              const SizedBox(width: _iconSize),

                            // Node Icon
                            Icon(_getNodeIcon(), size: _iconSize),
                            const SizedBox(width: 8),

                            // Label
                            Expanded(child: Text(widget.node.label)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Children
            ClipRect(
              child: SizeTransition(
                sizeFactor: _heightFactor,
                axisAlignment: -1.0, // Expand from top
                child: Padding(
                  padding: const EdgeInsets.only(left: _iconSize),
                  child: Column(
                    children: widget.node.children.asMap().entries.map((entry) {
                      return NodeWidget<T>(
                        node: entry.value,
                        mode: widget.mode,
                        onTap: widget.onTap,
                        isLast: entry.key == widget.node.children.length - 1,
                        isRoot: false,
                        selectedNodeIds: widget.selectedNodeIds,
                        lineTheme: widget.lineTheme,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getNodeIcon() {
    if (widget.node.type == NodeType.folder) {
      return widget.node.isExpanded ? Icons.folder_open : Icons.folder;
    } else if (widget.node.type == NodeType.parent) {
      return widget.mode == ViewMode.tree
          ? Icons.account_tree
          : Icons.description;
    } else {
      return Icons.insert_drive_file;
    }
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
