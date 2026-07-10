# flutter_folderview example

## Minimal usage

`FolderView` is controlled: it renders the expansion and selection you hand it, and tells you when the user asks for a change. You own the state.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';

class FileTree extends StatefulWidget {
  const FileTree({super.key});

  @override
  State<FileTree> createState() => _FileTreeState();
}

class _FileTreeState extends State<FileTree> {
  final Set<String> _expanded = {};
  final Set<String> _selected = {};

  static final _data = [
    Node<String>(
      id: 'docs',
      label: 'Documents',
      type: NodeType.folder,
      children: [
        Node<String>(
          id: 'work',
          label: 'Work',
          type: NodeType.parent,
          children: [
            Node<String>(id: 'report', label: 'Report.pdf', type: NodeType.child),
            Node<String>(id: 'notes', label: 'Notes.md', type: NodeType.child),
          ],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return FolderView<String>(
      data: _data,
      mode: ViewMode.folder,
      expandedNodeIds: _expanded,
      selectedNodeIds: _selected,
      onNodeTap: (node) => setState(() {
        if (node.type == NodeType.child) {
          _selected
            ..clear()
            ..add(node.id);
        } else if (_expanded.contains(node.id)) {
          _expanded.remove(node.id);
        } else {
          _expanded.add(node.id);
        }
      }),
    );
  }
}
```

A node occupies one of three tiers — `folder`, `parent`, `child` — and `ViewMode` chooses how they project onto the rendered list. `ViewMode.folder` shows all three; `ViewMode.tree` hides folders and lifts their parents to the root.

## Two tooltips, both at once

A **label tooltip** attaches to a node's glyphs and explains the text. A **row tooltip** attaches to the rest of the row and explains the node. Only the innermost one under the pointer is ever visible, so they divide the row between them — enable both.

```dart
FolderView<String>(
  data: _data,
  mode: ViewMode.folder,
  expandedNodeIds: _expanded,

  // Hover the label's glyphs.
  theme: FlutterFolderViewTheme<String>(
    lineTheme: const FolderViewLineTheme(lineColor: Colors.black26),
    scrollbarTheme: const FolderViewScrollbarTheme(
      thumbColor: Colors.black26,
      trackColor: Colors.black12,
    ),
    childTheme: ChildNodeTheme<String>(
      tooltipTheme: NodeTooltipTheme<String>(
        useTooltip: true,
        // Beside the cursor, not at the centre of a label that fills the row.
        anchor: TooltipAnchor.pointer,
        tooltipBuilderResolver: (node) => (context) => Text(node.label),
      ),
    ),
  ),

  // Hover anywhere else: the indent, the icon, the chevron, the space beside
  // a short label.
  rowTooltipBuilder: (context, node) => node.type == NodeType.folder
      ? null
      : Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text('${node.label} — ${node.children.length} children'),
          ),
        ),
  rowTooltipTheme: const RowTooltipTheme(
    // Without a wait, sweeping the mouse pops a card on every row it crosses.
    waitDuration: Duration(milliseconds: 300),
  ),
)
```

The card draws its own surface, so the tooltip around it draws none — give it a `Card`, not a bare `Text`. If your builder returns unadorned content, set `RowTooltipTheme.surface` and let the tooltip draw the box instead.

## Running this app

```bash
cd example
flutter run -d windows   # or macos, linux, chrome
```

Both tooltips are hover-driven, so use a desktop or web target; on a touch target only tap-triggered tooltips appear.

The right-hand panel exposes every theme knob — line style, per-tier icons and colours, node spacing, scrollbars, the Ctrl/Cmd + wheel scale gesture, and both tooltips. Open the **Tooltip** section and switch **Row Tooltip (card)** on: hovering a label's text still raises the label tooltip, and hovering anywhere else on the row raises the card.

See the [package documentation](https://pub.dev/packages/flutter_folderview) for the full API.
