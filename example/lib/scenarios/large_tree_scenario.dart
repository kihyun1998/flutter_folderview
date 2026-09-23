import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';

import '../app/tree_generator.dart';

/// The large-tree scenario's state: a generated tree of 100 × 10 × 100
/// nodes and its caller-owned Expanded Set, which starts with everything open.
class LargeTreeDemo extends ChangeNotifier {
  LargeTreeDemo()
    : nodes = generateTree(
        folders: 100,
        parentsPerFolder: 10,
        childrenPerParent: 100,
      ) {
    _expandedIds = {
      for (final folder in nodes) ...[
        folder.id,
        for (final parent in folder.children) parent.id,
      ],
    };
  }

  final List<Node<String>> nodes;

  late Set<String> _expandedIds;
  Set<String> get expandedIds => _expandedIds;

  void toggleExpansion(Node<String> node) {
    if (node.type == NodeType.child) return;
    final next = Set<String>.of(_expandedIds);
    if (!next.remove(node.id)) next.add(node.id);
    _expandedIds = next;
    notifyListeners();
  }
}

/// The large-tree scenario's stage.
class LargeTreeStage extends StatelessWidget {
  const LargeTreeStage({super.key, required this.demo});

  final LargeTreeDemo demo;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: demo,
      builder: (context, _) => FolderView<String>(
        data: demo.nodes,
        mode: ViewMode.folder,
        expandedNodeIds: demo.expandedIds,
        onNodeTap: demo.toggleExpansion,
      ),
    );
  }
}
