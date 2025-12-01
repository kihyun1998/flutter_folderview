import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
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
              onNodeTap: (node) {
                print('Tapped: ${node.label} (${node.type})');
                ref.read(folderStateProvider.notifier).toggleNode(node.id);
              },
            ),
          ),
        ],
      ),
    );
  }
}
