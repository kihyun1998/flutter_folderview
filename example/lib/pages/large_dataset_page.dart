import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../folder_provider.dart';

class LargeDatasetPage extends ConsumerWidget {
  const LargeDatasetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(folderStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Large Dataset Test (500 nodes)'),
        centerTitle: true,
        actions: [
          // Tree <-> Folder 모드 전환
          IconButton(
            icon: Icon(
              viewModel.mode == ViewMode.folder
                  ? Icons.account_tree_outlined
                  : Icons.folder_outlined,
            ),
            tooltip: viewModel.mode == ViewMode.folder
                ? 'Switch to Tree Mode'
                : 'Switch to Folder Mode',
            onPressed: () {
              ref.read(folderStateProvider.notifier).toggleMode();
            },
          ),
          const SizedBox(width: 8),
          // 전체 펼치기
          IconButton(
            icon: const Icon(Icons.unfold_more),
            tooltip: 'Expand All',
            onPressed: () {
              ref.read(folderStateProvider.notifier).expandAll();
            },
          ),
          // 전체 닫기
          IconButton(
            icon: const Icon(Icons.unfold_less),
            tooltip: 'Collapse All',
            onPressed: () {
              ref.read(folderStateProvider.notifier).collapseAll();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 정보 표시
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dataset: 10 Folders × 5 Parents × 10 Children = 500 nodes',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Mode: ${viewModel.mode == ViewMode.folder ? "Folder Mode (Folder > Parent > Child)" : "Tree Mode (Parent > Child)"}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // FolderView
            Expanded(
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FolderView<String>(
                    data: viewModel.nodes,
                    mode: viewModel.mode,
                    onNodeTap: (node) {
                      if (node.type == NodeType.child) {
                        ref
                            .read(folderStateProvider.notifier)
                            .selectNode(node.id, false);
                      } else {
                        ref
                            .read(folderStateProvider.notifier)
                            .toggleNode(node.id);
                      }
                    },
                    onDoubleNodeTap: (node) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Double tap: ${node.label} (${node.type.name})'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    onSecondaryNodeTap: (node, details) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Right click: ${node.label} (${node.type.name})'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    selectedNodeIds: viewModel.selectedIds,
                    theme: (Theme.of(context).brightness == Brightness.dark
                            ? FlutterFolderViewTheme.dark()
                            : FlutterFolderViewTheme.light())
                        .copyWith(
                      lineTheme: FolderViewLineTheme(
                        lineColor: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF757575)
                            : const Color(0xFF9E9E9E),
                        lineWidth: 1.5,
                        lineStyle: viewModel.lineStyle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
