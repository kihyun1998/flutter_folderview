import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';

/// A `FolderView` over a hand-built tree of `Node`s: one of each tier, with a
/// payload on every Child. Tapping a Folder or Parent toggles it; tapping a
/// Child shows its payload.
class BuildingATreeRecipe extends StatefulWidget {
  const BuildingATreeRecipe({super.key, this.mode = ViewMode.folder});

  /// Which projection of the tree to render.
  final ViewMode mode;

  @override
  State<BuildingATreeRecipe> createState() => _BuildingATreeRecipeState();
}

class _BuildingATreeRecipeState extends State<BuildingATreeRecipe> {
  static const _tree = [
    Node<String>(
      id: 'docs',
      label: 'Documents',
      type: NodeType.folder,
      children: [
        Node<String>(
          id: 'docs/reports',
          label: 'Reports',
          type: NodeType.parent,
          children: [
            Node<String>(
              id: 'docs/reports/q1',
              label: 'q1.pdf',
              type: NodeType.child,
              data: 'First-quarter report, 12 pages',
            ),
            Node<String>(
              id: 'docs/reports/q2',
              label: 'q2.pdf',
              type: NodeType.child,
              data: 'Second-quarter report, 9 pages',
            ),
          ],
        ),
        Node<String>(
          id: 'docs/notes',
          label: 'Notes',
          type: NodeType.parent,
          children: [
            Node<String>(
              id: 'docs/notes/todo',
              label: 'todo.md',
              type: NodeType.child,
              data: 'Three open items',
            ),
          ],
        ),
      ],
    ),
  ];

  Set<String> _expanded = {'docs', 'docs/reports'};
  String? _payload;

  void _onTap(Node<String> node) {
    setState(() {
      if (node.type == NodeType.child) {
        _payload = node.data;
      } else {
        _expanded = {..._expanded};
        if (!_expanded.remove(node.id)) _expanded.add(node.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: FolderView<String>(
            data: _tree,
            mode: widget.mode,
            expandedNodeIds: _expanded,
            onNodeTap: _onTap,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(_payload ?? 'Tap a file to see its data'),
        ),
      ],
    );
  }
}
