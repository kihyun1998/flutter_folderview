import 'package:flutter/material.dart';

import '../models/node.dart';
import 'node_widget.dart';

class FolderView<T> extends StatefulWidget {
  final List<Node<T>> data;
  final ViewMode mode;
  final Function(Node<T>)? onNodeTap;

  const FolderView({
    super.key,
    required this.data,
    required this.mode,
    this.onNodeTap,
  });

  @override
  _FolderViewState<T> createState() => _FolderViewState<T>();
}

class _FolderViewState<T> extends State<FolderView<T>> {
  @override
  Widget build(BuildContext context) {
    // Filter data based on mode
    List<Node<T>> displayNodes = _getDisplayNodes();

    return ListView.builder(
      itemCount: displayNodes.length,
      itemBuilder: (context, index) {
        return NodeWidget<T>(
          node: displayNodes[index],
          mode: widget.mode,
          onTap: widget.onNodeTap,
          isLast: index == displayNodes.length - 1,
          isRoot: true,
        );
      },
    );
  }

  List<Node<T>> _getDisplayNodes() {
    if (widget.mode == ViewMode.tree) {
      // In Tree Mode, we only show Parent nodes at the root level (and their children when expanded)
      // Assuming the input 'data' contains all root nodes.
      // If the input data is mixed, we might need to filter.
      // Based on requirements: "Tree mode: Parent > Child only. No Parent of Parent."
      // So we expect the root list to contain Parent nodes.
      return widget.data.where((n) => n.type == NodeType.parent).toList();
    } else {
      // In Folder Mode, we show Folders and Parents at the root level.
      // "Folder mode: Folder > Parent > Child. Parent of Parent is Folder."
      return widget.data
          .where((n) => n.type == NodeType.folder || n.type == NodeType.parent)
          .toList();
    }
  }
}
