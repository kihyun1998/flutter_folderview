import 'dart:math';

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

  /// 대용량 테스트용 데이터 생성
  /// - 랜덤 깊이의 중첩 폴더 구조
  /// - 긴 이름을 가진 노드 포함
  List<Node<String>> _generateLargeDataset() {
    final rng = Random(42);
    int idCounter = 0;

    final longNames = [
      'This is a very long folder name that should definitely cause text overflow and ellipsis in the UI',
      'Another extremely long directory name - Project Alpha Release Candidate 2024 Final Review Documentation',
      'Deep nested folder with ridiculously long name for testing horizontal scroll behavior and text truncation',
      'Super_Long_File_Name_With_Underscores_Instead_Of_Spaces_Configuration_Settings_Backup_2024_Final_v2.json',
      'quarterly-financial-report-department-of-engineering-infrastructure-and-cloud-operations-2024-Q4.xlsx',
    ];

    Node<String> generateChild(String prefix) {
      final id = '${prefix}_child_${++idCounter}';
      final useLong = rng.nextDouble() < 0.15;
      final label = useLong
          ? longNames[rng.nextInt(longNames.length)]
          : 'Item $idCounter - Document.pdf';
      return Node<String>(
        id: id,
        label: label,
        type: NodeType.child,
        data: 'Data for $id',
      );
    }

    List<Node<String>> generateLevel(
      String prefix,
      int currentDepth,
      int maxDepth,
    ) {
      final nodes = <Node<String>>[];
      final subFolderCount = rng.nextInt(4) + 1; // 1~4 sub-folders
      final childCount = rng.nextInt(6) + 1; // 1~6 children

      for (int i = 1; i <= subFolderCount; i++) {
        final id = '${prefix}_folder_${++idCounter}';
        final useLong = rng.nextDouble() < 0.2;
        final label = useLong
            ? longNames[rng.nextInt(longNames.length)]
            : 'Folder $idCounter - Depth $currentDepth';

        List<Node<String>> children;
        if (currentDepth < maxDepth) {
          children = generateLevel(id, currentDepth + 1, maxDepth);
        } else {
          children = List.generate(childCount, (_) => generateChild(id));
        }

        nodes.add(
          Node<String>(
            id: id,
            label: label,
            type: NodeType.folder,
            children: children,
          ),
        );
      }

      // Add some direct children at this level too
      for (int i = 0; i < rng.nextInt(4); i++) {
        nodes.add(generateChild(prefix));
      }

      return nodes;
    }

    final roots = <Node<String>>[];
    for (int i = 1; i <= 20; i++) {
      final id = 'root_$i';
      final maxDepth = rng.nextInt(5) + 2; // depth 2~6
      final useLong = rng.nextDouble() < 0.2;
      final label = useLong
          ? longNames[rng.nextInt(longNames.length)]
          : 'Department $i - Main Folder';

      roots.add(
        Node<String>(
          id: id,
          label: label,
          type: NodeType.folder,
          children: generateLevel(id, 1, maxDepth),
        ),
      );
    }

    return roots;
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
