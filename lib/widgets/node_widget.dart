import 'package:flutter/material.dart';
import '../models/node.dart';

class NodeWidget<T> extends StatefulWidget {
  final Node<T> node;
  final ViewMode mode;
  final Function(Node<T>)? onTap;
  final int level;

  const NodeWidget({
    Key? key,
    required this.node,
    required this.mode,
    this.onTap,
    this.level = 0,
  }) : super(key: key);

  @override
  _NodeWidgetState<T> createState() => _NodeWidgetState<T>();
}

class _NodeWidgetState<T> extends State<NodeWidget<T>> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNodeTile(),
        if (widget.node.isExpanded) _buildChildren(),
      ],
    );
  }

  Widget _buildNodeTile() {
    // Indentation
    double indent = widget.level * 20.0;

    IconData icon;
    if (widget.node.type == NodeType.folder) {
      icon = widget.node.isExpanded ? Icons.folder_open : Icons.folder;
    } else if (widget.node.type == NodeType.parent) {
      icon = widget.mode == ViewMode.tree ? Icons.account_tree : Icons.description; // Example icons
    } else {
      icon = Icons.insert_drive_file;
    }

    return InkWell(
      onTap: () {
        if (widget.node.canExpand) {
          setState(() {
            widget.node.isExpanded = !widget.node.isExpanded;
          });
        }
        widget.onTap?.call(widget.node);
      },
      child: Padding(
        padding: EdgeInsets.only(left: indent, top: 8, bottom: 8, right: 8),
        child: Row(
          children: [
            if (widget.node.canExpand)
              Icon(
                widget.node.isExpanded ? Icons.expand_more : Icons.chevron_right,
                size: 20,
              )
            else
              const SizedBox(width: 20),
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(widget.node.label),
          ],
        ),
      ),
    );
  }

  Widget _buildChildren() {
    // Filter children based on mode if necessary
    // For now, assume children are correctly structured for the node type
    return Column(
      children: widget.node.children.map((child) {
        return NodeWidget<T>(
          node: child,
          mode: widget.mode,
          onTap: widget.onTap,
          level: widget.level + 1,
        );
      }).toList(),
    );
  }
}
