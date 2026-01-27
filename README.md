# Flutter FolderView

A customizable Flutter widget for displaying hierarchical data in tree and folder views.

## Installation

```yaml
dependencies:
  flutter_folderview: ^0.5.0
```

## Basic Usage

```dart
import 'package:flutter_folderview/flutter_folderview.dart';

class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final Set<String> _expandedIds = {};

  @override
  Widget build(BuildContext context) {
    return FolderView(
      data: [
        Node(
          id: '1',
          label: 'Documents',
          type: NodeType.folder,
          children: [
            Node(
              id: '2',
              label: 'Work',
              type: NodeType.parent,
              children: [
                Node(id: '3', label: 'Report.pdf', type: NodeType.child),
              ],
            ),
          ],
        ),
      ],
      expandedNodeIds: _expandedIds,
      mode: ViewMode.folder,
      onNodeTap: (node) {
        if (node.type != NodeType.child) {
          setState(() {
            if (_expandedIds.contains(node.id)) {
              _expandedIds.remove(node.id);
            } else {
              _expandedIds.add(node.id);
            }
          });
        }
      },
    );
  }
}
```

## Node Types

- `NodeType.folder`: Top-level container nodes
- `NodeType.parent`: Mid-level nodes that can have children
- `NodeType.child`: Leaf nodes

## View Modes

- `ViewMode.folder`: Hierarchical folder structure (folder → parent → child)
- `ViewMode.tree`: Flattened tree structure (parent → child)

## Line Styles

```dart
theme: FlutterFolderViewTheme(
  lineTheme: FolderViewLineTheme(
    lineStyle: LineStyle.connector, // ├─ └─ connectors
    // lineStyle: LineStyle.scope,   // Vertical scope lines
    // lineStyle: LineStyle.none,    // No lines
  ),
)
```

## Theming

```dart
FolderView(
  data: nodes,
  expandedNodeIds: expandedIds,
  theme: FlutterFolderViewTheme(
    folderTheme: FolderNodeTheme(
      widget: Icon(Icons.folder),
      openWidget: Icon(Icons.folder_open),
      textStyle: TextStyle(fontSize: 14),
    ),
    parentTheme: ParentNodeTheme(
      widget: Icon(Icons.description),
      textStyle: TextStyle(fontSize: 14),
    ),
    childTheme: ChildNodeTheme(
      widget: Icon(Icons.insert_drive_file),
      textStyle: TextStyle(fontSize: 14),
      selectedTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    ),
  ),
)
```

## Example

See [example/](example/) for complete examples including:
- Theme customization
- Dynamic styling with resolver functions
- Large dataset handling

```bash
cd example
flutter run
```
