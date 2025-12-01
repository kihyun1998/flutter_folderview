import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';

void main() {
  runApp(const MyApp());
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ViewMode _currentMode = ViewMode.folder;
  late List<Node<String>> _data;

  @override
  void initState() {
    super.initState();
    _data = _generateMockData();
  }

  List<Node<String>> _generateMockData() {
    // Structure:
    // Folder A
    //   - Parent 1
    //     - Child 1.1
    //     - Child 1.2
    //   - Folder B
    //     - Parent 2
    //       - Child 2.1
    // Parent 3 (Root level parent, visible in Tree Mode as root, and Folder Mode as root)
    //   - Child 3.1

    final child1_1 = Node<String>(
      id: 'c1.1',
      label: 'Child 1.1',
      type: NodeType.child,
    );
    final child1_2 = Node<String>(
      id: 'c1.2',
      label: 'Child 1.2',
      type: NodeType.child,
    );

    final parent1 = Node<String>(
      id: 'p1',
      label: 'Parent 1',
      type: NodeType.parent,
      children: [child1_1, child1_2],
    );

    final child2_1 = Node<String>(
      id: 'c2.1',
      label: 'Child 2.1',
      type: NodeType.child,
    );
    final parent2 = Node<String>(
      id: 'p2',
      label: 'Parent 2',
      type: NodeType.parent,
      children: [child2_1],
    );

    final folderB = Node<String>(
      id: 'fB',
      label: 'Folder B',
      type: NodeType.folder,
      children: [parent2],
    );

    final folderA = Node<String>(
      id: 'fA',
      label: 'Folder A',
      type: NodeType.folder,
      children: [parent1, folderB],
    );

    final child3_1 = Node<String>(
      id: 'c3.1',
      label: 'Child 3.1',
      type: NodeType.child,
    );
    final parent3 = Node<String>(
      id: 'p3',
      label: 'Parent 3',
      type: NodeType.parent,
      children: [child3_1],
    );

    // In a real scenario, you might have a flat list or a tree.
    // Here we return the top-level nodes for Folder Mode.
    // For Tree Mode, we might need to flatten or traverse to find all Parents if they are nested in folders.
    // However, the requirement says:
    // Tree Mode: Parent > Child. Parent of Parent is none.
    // Folder Mode: Folder > ... > Parent > Child.

    // If we pass this list to FolderView, the FolderView logic needs to handle the display.
    // But wait, if 'Parent 1' is inside 'Folder A', it shouldn't be a root in Tree Mode if we just pass [Folder A, Parent 3].
    // We need a way to get ALL parents for Tree Mode.

    return [folderA, parent3];
  }

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
  Widget build(BuildContext context) {
    // Prepare data for the view
    List<Node<String>> viewData;
    if (_currentMode == ViewMode.tree) {
      // In Tree Mode, we want all Parents to be at the root level.
      // So we flatten the hierarchy to find all parents.
      viewData = _getAllParents(_data);
    } else {
      // In Folder Mode, we use the hierarchy as is.
      viewData = _data;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter FolderView'),
        actions: [
          IconButton(
            icon: Icon(
              _currentMode == ViewMode.folder
                  ? Icons.folder
                  : Icons.account_tree,
            ),
            onPressed: () {
              setState(() {
                _currentMode = _currentMode == ViewMode.folder
                    ? ViewMode.tree
                    : ViewMode.folder;
              });
            },
            tooltip:
                'Switch to ${_currentMode == ViewMode.folder ? 'Tree' : 'Folder'} Mode',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Current Mode: ${_currentMode.toString().split('.').last.toUpperCase()}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FolderView<String>(
              data: viewData,
              mode: _currentMode,
              onNodeTap: (node) {
                print('Tapped: ${node.label} (${node.type})');
              },
            ),
          ),
        ],
      ),
    );
  }
}
