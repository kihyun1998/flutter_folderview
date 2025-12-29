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

  List<Node<String>> _generateMockData() {
    // Deep nesting example - Company > Department > Team > Projects > Tasks

    // Engineering Department
    final engineeringTask1 = Node<String>(
      id: 'eng_task_1',
      label:
          'Implement New Authentication System with OAuth 2.0 and JWT Tokens',
      type: NodeType.child,
    );
    final engineeringTask2 = Node<String>(
      id: 'eng_task_2',
      label: 'Refactor Legacy Database Schema for Better Performance',
      type: NodeType.child,
    );
    final engineeringTask3 = Node<String>(
      id: 'eng_task_3',
      label: 'Code Review and Optimization Analysis',
      type: NodeType.child,
    );

    final backendProject = Node<String>(
      id: 'backend_proj',
      label: 'Backend API Development - Q4 2024 Milestone',
      type: NodeType.parent,
      children: [engineeringTask1, engineeringTask2, engineeringTask3],
    );

    final frontendTask1 = Node<String>(
      id: 'frontend_task_1',
      label:
          'Responsive Dashboard with Real-time Analytics and Data Visualization',
      type: NodeType.child,
    );
    final frontendTask2 = Node<String>(
      id: 'frontend_task_2',
      label: 'Mobile-First Design Implementation',
      type: NodeType.child,
    );

    final frontendProject = Node<String>(
      id: 'frontend_proj',
      label: 'Frontend User Interface Modernization Project',
      type: NodeType.parent,
      children: [frontendTask1, frontendTask2],
    );

    final engineeringFolder = Node<String>(
      id: 'engineering_folder',
      label: 'Engineering Department - Software Development Division',
      type: NodeType.folder,
      children: [backendProject, frontendProject],
    );

    // Marketing Department
    final marketingTask1 = Node<String>(
      id: 'marketing_task_1',
      label: 'Q4 Social Media Campaign Strategy and Content Calendar Planning',
      type: NodeType.child,
    );
    final marketingTask2 = Node<String>(
      id: 'marketing_task_2',
      label: 'Customer Engagement Analytics Report',
      type: NodeType.child,
    );
    final marketingTask3 = Node<String>(
      id: 'marketing_task_3',
      label: 'Brand Identity Redesign Proposal',
      type: NodeType.child,
    );
    final marketingTask4 = Node<String>(
      id: 'marketing_task_4',
      label: 'Email Marketing Automation Setup',
      type: NodeType.child,
    );

    final digitalMarketingParent = Node<String>(
      id: 'digital_marketing',
      label: 'Digital Marketing Initiatives and Online Presence Enhancement',
      type: NodeType.parent,
      children: [
        marketingTask1,
        marketingTask2,
        marketingTask3,
        marketingTask4,
      ],
    );

    final marketingFolder = Node<String>(
      id: 'marketing_folder',
      label: 'Marketing & Communications Department - Strategic Planning',
      type: NodeType.folder,
      children: [digitalMarketingParent],
    );

    // HR Department
    final hrTask1 = Node<String>(
      id: 'hr_task_1',
      label: 'Employee Onboarding Process Documentation and Training Materials',
      type: NodeType.child,
    );
    final hrTask2 = Node<String>(
      id: 'hr_task_2',
      label: 'Annual Performance Review Schedule',
      type: NodeType.child,
    );
    final hrTask3 = Node<String>(
      id: 'hr_task_3',
      label: 'Benefits Package Comparison Analysis',
      type: NodeType.child,
    );

    final recruitmentParent = Node<String>(
      id: 'recruitment',
      label: 'Talent Acquisition and Recruitment Pipeline Management',
      type: NodeType.parent,
      children: [hrTask1, hrTask2, hrTask3],
    );

    // Standalone Projects (no folder parent)
    final standaloneChild1 = Node<String>(
      id: 'standalone_1',
      label:
          'Infrastructure Modernization Initiative - Cloud Migration Phase 2',
      type: NodeType.child,
    );
    final standaloneChild2 = Node<String>(
      id: 'standalone_2',
      label: 'Security Audit and Compliance Report',
      type: NodeType.child,
    );

    final standaloneParent = Node<String>(
      id: 'standalone_parent',
      label: 'Cross-Departmental IT Infrastructure Projects and Initiatives',
      type: NodeType.parent,
      children: [standaloneChild1, standaloneChild2],
    );

    return [
      engineeringFolder,
      marketingFolder,
      Node<String>(
        id: 'hr_folder',
        label: 'Human Resources - People Operations and Culture',
        type: NodeType.folder,
        children: [recruitmentParent],
      ),
      standaloneParent,
    ];
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
