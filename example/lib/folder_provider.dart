import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'folder_provider.g.dart';

@riverpod
class FolderState extends _$FolderState {
  @override
  FolderViewModel build() {
    return FolderViewModel(
      mode: ViewMode.folder,
      nodes: _generateLargeDataset(),
      selectedIds: {},
      expandedIds: {},
      lineStyle: LineStyle.connector,
    );
  }

  void toggleMode() {
    state = state.copyWith(
      mode: state.mode == ViewMode.folder ? ViewMode.tree : ViewMode.folder,
    );
  }

  void toggleNode(String nodeId) {
    final newExpanded = Set<String>.from(state.expandedIds);
    if (newExpanded.contains(nodeId)) {
      newExpanded.remove(nodeId);
    } else {
      newExpanded.add(nodeId);
    }
    state = state.copyWith(expandedIds: newExpanded);
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
    final allIds = <String>{};
    _collectExpandableIds(state.nodes, allIds);
    state = state.copyWith(expandedIds: allIds);
  }

  void collapseAll() {
    state = state.copyWith(expandedIds: {});
  }

  void _collectExpandableIds(List<Node<String>> nodes, Set<String> ids) {
    for (final node in nodes) {
      if (node.children.isNotEmpty) {
        ids.add(node.id);
        _collectExpandableIds(node.children, ids);
      }
    }
  }

  /// 대용량 테스트용 데이터 생성 (약 500개 노드)
  /// - 10개 Folder
  /// - 각 Folder당 5개 Parent (총 50개)
  /// - 각 Parent당 10개 Child (총 500개)
  List<Node<String>> _generateLargeDataset() {
    final folders = <Node<String>>[];

    for (int folderIdx = 1; folderIdx <= 100; folderIdx++) {
      final parents = <Node<String>>[];

      for (int parentIdx = 1; parentIdx <= 100; parentIdx++) {
        final children = <Node<String>>[];

        for (int childIdx = 1; childIdx <= 100; childIdx++) {
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
  final Set<String> expandedIds;
  final LineStyle lineStyle;

  FolderViewModel({
    required this.mode,
    required this.nodes,
    this.selectedIds = const {},
    this.expandedIds = const {},
    required this.lineStyle,
  });

  FolderViewModel copyWith({
    ViewMode? mode,
    List<Node<String>>? nodes,
    Set<String>? selectedIds,
    Set<String>? expandedIds,
    LineStyle? lineStyle,
  }) {
    return FolderViewModel(
      mode: mode ?? this.mode,
      nodes: nodes ?? this.nodes,
      selectedIds: selectedIds ?? this.selectedIds,
      expandedIds: expandedIds ?? this.expandedIds,
      lineStyle: lineStyle ?? this.lineStyle,
    );
  }
}
