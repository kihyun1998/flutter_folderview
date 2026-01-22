import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'folder_provider.g.dart';

@riverpod
class FolderState extends _$FolderState {
  @override
  FolderViewModel build() {
    return FolderViewModel(
      mode: ViewMode.folder,
      // nodes: _generateMockData(),
      nodes: _generateLargeDataset(), // 대용량 테스트용 500개 데이터
      selectedIds: {},
      lineStyle: LineStyle.connector,
    );
  }

  void toggleMode() {
    state = state.copyWith(
      mode: state.mode == ViewMode.folder ? ViewMode.tree : ViewMode.folder,
    );
  }

  void toggleNode(String nodeId) {
    final newNodes = _toggleNodeRecursive(state.nodes, nodeId);
    state = state.copyWith(nodes: newNodes);
  }

  void selectNode(String nodeId, bool isMultiSelect) {
    final currentSelected = Set<String>.from(state.selectedIds);

    if (isMultiSelect) {
      if (currentSelected.contains(nodeId)) {
        currentSelected.remove(nodeId);
      } else {
        currentSelected.add(nodeId);
      }
    } else {
      currentSelected.clear();
      currentSelected.add(nodeId);
    }

    state = state.copyWith(selectedIds: currentSelected);
  }

  void setLineStyle(LineStyle lineStyle) {
    state = state.copyWith(lineStyle: lineStyle);
  }

  void expandAll() {
    final newNodes = _setAllNodesExpanded(state.nodes, true);
    state = state.copyWith(nodes: newNodes);
  }

  void collapseAll() {
    final newNodes = _setAllNodesExpanded(state.nodes, false);
    state = state.copyWith(nodes: newNodes);
  }

  List<Node<String>> _setAllNodesExpanded(
    List<Node<String>> nodes,
    bool isExpanded,
  ) {
    return nodes.map((node) {
      return Node<String>(
        id: node.id,
        label: node.label,
        type: node.type,
        data: node.data,
        children: node.children.isNotEmpty
            ? _setAllNodesExpanded(node.children, isExpanded)
            : node.children,
        isExpanded: isExpanded,
      );
    }).toList();
  }

  List<Node<String>> _toggleNodeRecursive(
    List<Node<String>> nodes,
    String targetId,
  ) {
    return nodes.map((node) {
      if (node.id == targetId) {
        return Node<String>(
          id: node.id,
          label: node.label,
          type: node.type,
          data: node.data,
          children: node.children,
          isExpanded: !node.isExpanded,
        );
      } else if (node.children.isNotEmpty) {
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

  /// 대용량 테스트용 데이터 생성 (약 500개 노드)
  /// - 10개 Folder
  /// - 각 Folder당 5개 Parent (총 50개)
  /// - 각 Parent당 10개 Child (총 500개)
  List<Node<String>> _generateLargeDataset() {
    final folders = <Node<String>>[];

    for (int folderIdx = 1; folderIdx <= 10; folderIdx++) {
      final parents = <Node<String>>[];

      for (int parentIdx = 1; parentIdx <= 5; parentIdx++) {
        final children = <Node<String>>[];

        for (int childIdx = 1; childIdx <= 10; childIdx++) {
          children.add(
            Node<String>(
              id: 'folder_${folderIdx}_parent_${parentIdx}_child_$childIdx',
              label:
                  'Item $childIdx - Document $folderIdx$parentIdx$childIdx.pdf',
              type: NodeType.child,
              data: 'Data for F$folderIdx-P$parentIdx-C$childIdx',
            ),
          );
        }

        parents.add(
          Node<String>(
            id: 'folder_${folderIdx}_parent_$parentIdx',
            label: 'Category $parentIdx - Project Group $folderIdx$parentIdx',
            type: NodeType.parent,
            children: children,
          ),
        );
      }

      folders.add(
        Node<String>(
          id: 'folder_$folderIdx',
          label: 'Department $folderIdx - Main Folder',
          type: NodeType.folder,
          children: parents,
        ),
      );
    }

    return folders;
  }
}

class FolderViewModel {
  final ViewMode mode;
  final List<Node<String>> nodes;
  final Set<String> selectedIds;
  final LineStyle lineStyle;

  FolderViewModel({
    required this.mode,
    required this.nodes,
    this.selectedIds = const {},
    required this.lineStyle,
  });

  FolderViewModel copyWith({
    ViewMode? mode,
    List<Node<String>>? nodes,
    Set<String>? selectedIds,
    LineStyle? lineStyle,
  }) {
    return FolderViewModel(
      mode: mode ?? this.mode,
      nodes: nodes ?? this.nodes,
      selectedIds: selectedIds ?? this.selectedIds,
      lineStyle: lineStyle ?? this.lineStyle,
    );
  }
}
