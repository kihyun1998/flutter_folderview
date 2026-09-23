import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';

import '../data/theme_demo_data.dart';

/// The "Every setting" destination's state: the nodes and the caller-owned
/// Expanded Set and Selected Set the stage renders.
class EverySettingDemo extends ChangeNotifier {
  final List<Node<String>> nodes = getThemeDemoData();

  Set<String> _expandedIds = {'1', '1-1', '2', '2-1', '2-2', '3'};
  Set<String> get expandedIds => _expandedIds;

  final Set<String> selectedIds = const {};

  void toggleExpansion(Node<String> node) {
    if (node.type == NodeType.child) return;
    final next = Set<String>.of(_expandedIds);
    if (!next.remove(node.id)) next.add(node.id);
    _expandedIds = next;
    notifyListeners();
  }
}

/// The "Every setting" stage: a `FolderView` over [EverySettingDemo].
class EverySettingStage extends StatelessWidget {
  const EverySettingStage({super.key, required this.demo});

  final EverySettingDemo demo;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: demo,
      builder: (context, _) => FolderView<String>(
        data: demo.nodes,
        mode: ViewMode.folder,
        expandedNodeIds: demo.expandedIds,
        selectedNodeIds: demo.selectedIds,
        onNodeTap: demo.toggleExpansion,
      ),
    );
  }
}
