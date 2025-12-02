import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import '../models/card_config.dart';

class FolderCard extends StatefulWidget {
  final CardConfig initialConfig;

  const FolderCard({
    super.key,
    required this.initialConfig,
  });

  @override
  State<FolderCard> createState() => _FolderCardState();
}

class _FolderCardState extends State<FolderCard> {
  late CardConfig config;
  Set<String> selectedNodeIds = {};

  @override
  void initState() {
    super.initState();
    config = widget.initialConfig;
  }

  void _handleNodeTap(Node<String> node) {
    setState(() {
      if (node.type == NodeType.child) {
        selectedNodeIds = {node.id};
      } else {
        // Toggle expansion for folders/parents
        config = config.copyWith(
          data: _toggleNodeRecursive(config.data, node.id),
        );
      }
    });
  }

  List<Node<String>> _toggleNodeRecursive(
      List<Node<String>> nodes, String targetId) {
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

  List<Node<String>> _getDisplayNodes() {
    if (config.mode == ViewMode.tree) {
      return _getAllParents(config.data);
    } else {
      return config.data
          .where((n) => n.type == NodeType.folder || n.type == NodeType.parent)
          .toList();
    }
  }

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
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: config.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  config.mode == ViewMode.folder
                      ? Icons.folder_outlined
                      : Icons.account_tree_outlined,
                  color: config.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    config.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: config.primaryColor,
                    ),
                  ),
                ),
                // Line Style Menu
                PopupMenuButton<LineStyle>(
                  icon: Icon(Icons.more_vert, size: 18, color: Colors.grey[600]),
                  tooltip: 'Line Style',
                  onSelected: (lineStyle) {
                    setState(() {
                      config = config.copyWith(lineStyle: lineStyle);
                    });
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: LineStyle.connector,
                      child: Text('Connector', style: TextStyle(fontSize: 13)),
                    ),
                    PopupMenuItem(
                      value: LineStyle.scope,
                      child: Text('Scope', style: TextStyle(fontSize: 13)),
                    ),
                    PopupMenuItem(
                      value: LineStyle.none,
                      child: Text('None', style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Theme(
              data: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: config.primaryColor,
                  brightness: Theme.of(context).brightness,
                ),
              ),
              child: FolderView<String>(
                data: _getDisplayNodes(),
                mode: config.mode,
                onNodeTap: _handleNodeTap,
                selectedNodeIds: selectedNodeIds,
                lineStyle: config.lineStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
