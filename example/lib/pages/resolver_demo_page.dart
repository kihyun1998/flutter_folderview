import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';

/// Example demonstrating theme resolver functions
///
/// This example shows how to use resolver functions to dynamically change
/// the appearance of nodes based on their data property.
class ResolverDemoPage extends StatefulWidget {
  const ResolverDemoPage({super.key});

  @override
  State<ResolverDemoPage> createState() => _ResolverDemoPageState();
}

class _ResolverDemoPageState extends State<ResolverDemoPage> {
  late List<Node<FileData>> _data;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _data = _createDemoData();
  }

  void _handleTap(Node<FileData> node) {
    setState(() {
      if (node.type == NodeType.child) {
        _selectedIds.contains(node.id)
            ? _selectedIds.remove(node.id)
            : _selectedIds.add(node.id);
      } else if (node.canExpand) {
        _data = _toggle(_data, node.id);
      }
    });
  }

  List<Node<FileData>> _toggle(List<Node<FileData>> nodes, String id) {
    return nodes.map((n) {
      if (n.id == id) {
        return Node<FileData>(
          id: n.id,
          label: n.label,
          type: n.type,
          data: n.data,
          children: n.children,
          isExpanded: !n.isExpanded,
        );
      } else if (n.children.isNotEmpty) {
        return Node<FileData>(
          id: n.id,
          label: n.label,
          type: n.type,
          data: n.data,
          children: _toggle(n.children, id),
          isExpanded: n.isExpanded,
        );
      }
      return n;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Create theme with resolver functions
    final theme = FlutterFolderViewTheme<FileData>(
      lineTheme: FolderViewLineTheme(
        lineColor: Colors.grey.shade400,
        lineWidth: 1.5,
        lineStyle: LineStyle.connector,
      ),
      scrollbarTheme: FolderViewScrollbarTheme(
        thumbColor: Colors.grey.shade600,
        trackColor: Colors.grey.shade200,
      ),
      folderTheme: const FolderNodeTheme<FileData>(
        widget: Icon(Icons.folder, color: Colors.grey, size: 20),
        openWidget: Icon(Icons.folder_open, color: Colors.grey, size: 20),
        textStyle: TextStyle(color: Colors.black87, fontSize: 14),
      ),
      parentTheme: const ParentNodeTheme<FileData>(
        widget: Icon(Icons.account_tree, color: Colors.grey, size: 20),
        textStyle: TextStyle(color: Colors.black87, fontSize: 14),
      ),
      childTheme: ChildNodeTheme<FileData>(
        widget: const Icon(
          Icons.insert_drive_file,
          color: Colors.grey,
          size: 20,
        ),
        // Widget resolver: Change icon based on data.enabled
        widgetResolver: (node) {
          if (node.data?.enabled == false) {
            return const Icon(Icons.block, color: Colors.red, size: 20);
          }
          if (node.data?.isImportant == true) {
            return const Icon(Icons.star, color: Colors.amber, size: 20);
          }
          return null; // Use default widget
        },
        textStyle: const TextStyle(color: Colors.black87, fontSize: 14),
        // Text style resolver: Change style based on data.enabled
        textStyleResolver: (node) {
          if (node.data?.enabled == false) {
            return const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              decoration: TextDecoration.lineThrough,
            );
          }
          if (node.data?.isImportant == true) {
            return const TextStyle(
              color: Colors.blue,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            );
          }
          return null; // Use default textStyle
        },
        selectedTextStyle: const TextStyle(fontWeight: FontWeight.bold),
        selectedBackgroundColor: Colors.blue.shade50,
      ),
      expandIconTheme: const ExpandIconTheme(
        widget: Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      ),
      nodeStyleTheme: const FolderViewNodeStyleTheme(borderRadius: 8.0),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Resolver Demo'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Column(
        children: [
          // Info card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resolver Functions Demo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This example demonstrates theme resolver functions:\n'
                  '• Red 🚫 icon = Disabled file (data.enabled = false)\n'
                  '• Yellow ⭐ icon = Important file (data.isImportant = true)\n'
                  '• Grey icon = Normal file\n\n'
                  'Text styles also change based on node data.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          // FolderView
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FolderView<FileData>(
                data: _data,
                mode: ViewMode.folder,
                onNodeTap: _handleTap,
                selectedNodeIds: _selectedIds,
                theme: theme,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<Node<FileData>> _createDemoData() {
    return [
      Node<FileData>(
        id: 'folder1',
        label: 'Project Files',
        type: NodeType.folder,
        isExpanded: true,
        children: [
          Node<FileData>(
            id: 'parent1',
            label: 'src',
            type: NodeType.parent,
            isExpanded: true,
            children: [
              Node<FileData>(
                id: 'child1',
                label: 'main.dart',
                type: NodeType.child,
                data: FileData(enabled: true, isImportant: true),
              ),
              Node<FileData>(
                id: 'child2',
                label: 'config.dart',
                type: NodeType.child,
                data: FileData(enabled: true, isImportant: false),
              ),
              Node<FileData>(
                id: 'child3',
                label: 'deprecated.dart',
                type: NodeType.child,
                data: FileData(enabled: false, isImportant: false),
              ),
            ],
          ),
          Node<FileData>(
            id: 'parent2',
            label: 'test',
            type: NodeType.parent,
            isExpanded: false,
            children: [
              Node<FileData>(
                id: 'child4',
                label: 'widget_test.dart',
                type: NodeType.child,
                data: FileData(enabled: true, isImportant: false),
              ),
              Node<FileData>(
                id: 'child5',
                label: 'old_test.dart',
                type: NodeType.child,
                data: FileData(enabled: false, isImportant: false),
              ),
            ],
          ),
        ],
      ),
      Node<FileData>(
        id: 'folder2',
        label: 'Documentation',
        type: NodeType.folder,
        isExpanded: true,
        children: [
          Node<FileData>(
            id: 'parent3',
            label: 'docs',
            type: NodeType.parent,
            isExpanded: true,
            children: [
              Node<FileData>(
                id: 'child6',
                label: 'README.md',
                type: NodeType.child,
                data: FileData(enabled: true, isImportant: true),
              ),
              Node<FileData>(
                id: 'child7',
                label: 'API.md',
                type: NodeType.child,
                data: FileData(enabled: true, isImportant: false),
              ),
            ],
          ),
        ],
      ),
    ];
  }
}

/// Custom data class for demonstrating resolver functions
class FileData {
  final bool enabled;
  final bool isImportant;

  FileData({required this.enabled, required this.isImportant});
}
