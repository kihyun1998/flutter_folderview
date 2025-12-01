import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_folderview/flutter_folderview.dart';

part 'folder_provider.g.dart';

@riverpod
class FolderState extends _$FolderState {
  @override
  FolderViewModel build() {
    return FolderViewModel(
      mode: ViewMode.folder,
      nodes: _generateMockData(),
    );
  }

  void toggleMode() {
    state = state.copyWith(
      mode: state.mode == ViewMode.folder ? ViewMode.tree : ViewMode.folder,
    );
  }

  void toggleNode(String nodeId) {
    // Deep copy and toggle
    final newNodes = _toggleNodeRecursive(state.nodes, nodeId);
    state = state.copyWith(nodes: newNodes);
  }

  List<Node<String>> _toggleNodeRecursive(List<Node<String>> nodes, String targetId) {
    return nodes.map((node) {
      if (node.id == targetId) {
        // Return a new node with toggled state
        return Node<String>(
          id: node.id,
          label: node.label,
          type: node.type,
          data: node.data,
          children: node.children, // Children reference is fine if not modifying them
          isExpanded: !node.isExpanded,
        );
      } else if (node.children.isNotEmpty) {
        // Recursively check children
        return Node<String>(
          id: node.id,
          label: node.label,
          type: node.type,
          data: node.data,
          children: _toggleNodeRecursive(node.children, targetId),
          isExpanded: node.isExpanded,
        );
      }
      return node;
    }).toList();
  }

  List<Node<String>> _generateMockData() {
    final child1_1 = Node<String>(id: 'c1.1', label: 'Child 1.1', type: NodeType.child);
    final child1_2 = Node<String>(id: 'c1.2', label: 'Child 1.2', type: NodeType.child);
    
    final parent1 = Node<String>(
      id: 'p1', 
      label: 'Parent 1', 
      type: NodeType.parent, 
      children: [child1_1, child1_2]
    );

    final child2_1 = Node<String>(id: 'c2.1', label: 'Child 2.1', type: NodeType.child);
    final parent2 = Node<String>(
      id: 'p2', 
      label: 'Parent 2', 
      type: NodeType.parent, 
      children: [child2_1]
    );

    final folderB = Node<String>(
      id: 'fB', 
      label: 'Folder B', 
      type: NodeType.folder, 
      children: [parent2]
    );

    final folderA = Node<String>(
      id: 'fA', 
      label: 'Folder A', 
      type: NodeType.folder, 
      children: [parent1, folderB]
    );

    final child3_1 = Node<String>(id: 'c3.1', label: 'Child 3.1', type: NodeType.child);
    final parent3 = Node<String>(
      id: 'p3', 
      label: 'Parent 3', 
      type: NodeType.parent, 
      children: [child3_1]
    );
    
    return [folderA, parent3];
  }
}

class FolderViewModel {
  final ViewMode mode;
  final List<Node<String>> nodes;

  FolderViewModel({required this.mode, required this.nodes});

  FolderViewModel copyWith({ViewMode? mode, List<Node<String>>? nodes}) {
    return FolderViewModel(
      mode: mode ?? this.mode,
      nodes: nodes ?? this.nodes,
    );
  }
}
