import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'folder_provider.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter FolderView Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  // Helper to extract all parents for Tree Mode from the hierarchical data
  List<Node<String>> _getAllParents(List<Node<String>> nodes) {
    List<Node<String>> parents = [];
    for (var node in nodes) {
      if (node.type == NodeType.parent) {
        parents.add(node);
      }
      if (node.children.isNotEmpty) {
        parents.addAll(_getAllParents(node.children));
      }
    }
    return parents;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folderState = ref.watch(folderStateProvider);

    // Prepare data for the view
    List<Node<String>> viewData;
    if (folderState.mode == ViewMode.tree) {
      viewData = _getAllParents(folderState.nodes);
    } else {
      viewData = folderState.nodes;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter FolderView'),
        actions: [
          IconButton(
            icon: Icon(
              folderState.mode == ViewMode.folder
                  ? Icons.folder
                  : Icons.account_tree,
            ),
            onPressed: () {
              ref.read(folderStateProvider.notifier).toggleMode();
            },
            tooltip:
                'Switch to ${folderState.mode == ViewMode.folder ? 'Tree' : 'Folder'} Mode',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Current Mode: ${folderState.mode.toString().split('.').last.toUpperCase()}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FolderView<String>(
              data: viewData,
              mode: folderState.mode,
              selectedNodeIds: folderState.selectedIds,
              onNodeTap: (node) {
                print('Tapped: ${node.label} (${node.type})');

                // Check for Control Key
                final isMultiSelect =
                    HardwareKeyboard.instance.isControlPressed ||
                    HardwareKeyboard
                        .instance
                        .isMetaPressed; // Command key on Mac

                // If tapping a folder/parent, we might want to toggle expansion AND select?
                // Or just select? Usually file explorers select on tap, double tap to expand/open.
                // Here we have a separate expand icon.
                // So tapping the label/row (excluding icon) should select.
                // Our NodeWidget handles expansion internally if the expand icon is clicked?
                // Wait, NodeWidget's InkWell wraps the whole row (except pipeline).
                // And it calls onTap.
                // It ALSO handles expansion if canExpand is true.
                // If we want to separate selection from expansion, we might need to adjust NodeWidget.
                // Currently NodeWidget toggles expansion AND calls onTap.
                // Let's assume we want to select on tap.

                // Only allow selection for Child nodes
                if (node.type == NodeType.child) {
                  ref
                      .read(folderStateProvider.notifier)
                      .selectNode(node.id, isMultiSelect);
                } else {
                  // For Folder/Parent nodes, toggle expansion
                  ref.read(folderStateProvider.notifier).toggleNode(node.id);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
