# Flutter FolderView

A customizable Flutter widget for displaying hierarchical data in tree and folder views.

## Installation

```yaml
dependencies:
  flutter_folderview: ^0.6.2
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

## Tooltip

Each node type supports tooltip via `NodeTooltipTheme`:

```dart
FolderView(
  data: nodes,
  expandedNodeIds: expandedIds,
  theme: FlutterFolderViewTheme(
    folderTheme: FolderNodeTheme(
      tooltipTheme: NodeTooltipTheme(
        useTooltip: true,
        message: 'Folder node',
        direction: TooltipDirection.top,
        alignment: TooltipAlignment.center,
        interactive: true,
        waitDuration: Duration(milliseconds: 500),
        showDuration: Duration(seconds: 3),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
    ),
  ),
)
```

| Property | Type | Description |
|---|---|---|
| `useTooltip` | `bool` | Enable tooltip (default: `false`) |
| `message` | `String?` | Static tooltip text |
| `tooltipBuilder` | `WidgetBuilder?` | Custom tooltip widget |
| `tooltipBuilderResolver` | `Function?` | Node-specific tooltip widget resolver |
| `direction` | `TooltipDirection` | Position: `top`, `bottom`, `left`, `right` |
| `alignment` | `TooltipAlignment` | Alignment: `start`, `center`, `end` |
| `offset` | `double` | Distance from widget (default: `8.0`) |
| `crossAxisOffset` | `double` | Cross-axis offset (default: `0.0`) |
| `backgroundColor` | `Color?` | Background color |
| `elevation` | `double?` | Shadow depth |
| `boxShadow` | `List<BoxShadow>?` | Custom shadow (overrides elevation) |
| `borderRadius` | `BorderRadius?` | Corner rounding |
| `padding` | `EdgeInsets?` | Inner padding |
| `enableTap` | `bool?` | Tap to show (default: `false`) |
| `enableHover` | `bool?` | Hover to show (default: `true`) |
| `interactive` | `bool?` | Keep visible on tooltip hover |
| `waitDuration` | `Duration?` | Delay before showing on hover |
| `showDuration` | `Duration?` | Auto-hide after duration (resets on re-enter) |
| `animationDuration` | `Duration?` | Show/hide animation duration |
| `controller` | `JustTooltipController?` | Programmatic show/hide control |
| `onShow` | `VoidCallback?` | Callback when shown |
| `onHide` | `VoidCallback?` | Callback when hidden |

## Example

See [example/](example/) for complete examples including:
- Theme customization
- Dynamic styling with resolver functions
- Data generation for testing

```bash
cd example
flutter run
```
