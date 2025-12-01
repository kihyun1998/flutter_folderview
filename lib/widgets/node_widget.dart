import 'package:flutter/material.dart';

import '../models/node.dart';

class NodeWidget<T> extends StatefulWidget {
  final Node<T> node;
  final ViewMode mode;
  final Function(Node<T>)? onTap;
  final bool isLast;
  final bool isRoot;

  const NodeWidget({
    super.key,
    required this.node,
    required this.mode,
    this.onTap,
    this.isLast = false,
    this.isRoot = false,
  });

  @override
  _NodeWidgetState<T> createState() => _NodeWidgetState<T>();
}

class _NodeWidgetState<T> extends State<NodeWidget<T>> {
  static const double _indentWidth = 24.0;
  static const double _iconSize = 20.0;
  static const double _rowHeight = 40.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Vertical Line (Pipeline)
        // Drawn for the full height of this widget if not last.
        // If last, drawn only to the center of the header.
        Positioned(
          left: 0,
          top: 0,
          bottom: widget.isLast ? null : 0, // Full height if not last
          height: widget.isLast ? _rowHeight / 2 : null, // Half height if last
          width: _indentWidth,
          child: CustomPaint(
            painter: _LinePainter(isLast: widget.isLast, isRoot: widget.isRoot),
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
                  const SizedBox(width: _indentWidth),

                  // Clickable Content
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (widget.node.canExpand) {
                          setState(() {
                            widget.node.isExpanded = !widget.node.isExpanded;
                          });
                        }
                        widget.onTap?.call(widget.node);
                      },
                      child: Row(
                        children: [
                          // Expand/Collapse Icon
                          if (widget.node.canExpand)
                            Icon(
                              widget.node.isExpanded
                                  ? Icons.expand_more
                                  : Icons.chevron_right,
                              size: _iconSize,
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
                ],
              ),
            ),

            // Children
            if (widget.node.isExpanded)
              Padding(
                padding: const EdgeInsets.only(left: _indentWidth),
                child: Column(
                  children: widget.node.children.asMap().entries.map((entry) {
                    return NodeWidget<T>(
                      node: entry.value,
                      mode: widget.mode,
                      onTap: widget.onTap,
                      isLast: entry.key == widget.node.children.length - 1,
                      isRoot: false,
                    );
                  }).toList(),
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

  _LinePainter({required this.isLast, required this.isRoot});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final double centerX = size.width / 2;

    // Vertical Line
    // If not last, we draw full height (handled by Container size, but here we draw to size.height).
    // If last, we draw to size.height (which is passed as half row height).
    canvas.drawLine(Offset(centerX, 0), Offset(centerX, size.height), paint);

    // Horizontal Connector (├ or └)
    // Drawn from center to right
    // Only if we are NOT a root node that is just floating?
    // Actually, even roots usually have connectors if they are in a list.
    // But if it's the very first root?
    // Let's assume standard tree behavior.

    // The connector should be at 20px (half row height) from top.
    // If isLast is true, size.height IS 20px. So we draw at bottom.
    // If isLast is false, size.height is large. We draw at 20px.

    double connectorY = isLast ? size.height : 20.0;

    canvas.drawLine(
      Offset(centerX, connectorY),
      Offset(size.width, connectorY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) {
    return oldDelegate.isLast != isLast || oldDelegate.isRoot != isRoot;
  }
}
