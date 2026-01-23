# Flutter FolderView

A customizable Flutter widget for displaying hierarchical data in tree and folder views.

## Features

- 🌲 Dual view modes (Tree / Folder)
- 📁 Three node types (Folder / Parent / Child)
- 🎨 Customizable themes (icons, text, lines, colors)
- 🎯 Interactive (tap, double-tap, right-click handlers)
- ✨ Multiple line styles (Connector / Scope / None)

## Installation

```yaml
dependencies:
  flutter_folderview: ^0.1.2
```

## Usage

```dart
import 'package:flutter_folderview/flutter_folderview.dart';

FolderView(
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
  mode: ViewMode.folder, // or ViewMode.tree
  onNodeTap: (node) => print('Tapped: ${node.label}'),
)
```

### View Modes

- `ViewMode.folder`: Shows folders at root with parent-child hierarchy
- `ViewMode.tree`: Shows parent nodes at root (folders flattened)

### Line Styles

```dart
theme: FlutterFolderViewTheme(
  lineTheme: FolderViewLineTheme(
    lineStyle: LineStyle.connector, // ├─ └─ style
    // lineStyle: LineStyle.scope,   // VS Code style
    // lineStyle: LineStyle.none,    // No lines
  ),
)
```

## Example

Run the example app for more demos:

```bash
cd example
flutter run
```

See [example/](example/) for complete examples with custom themes and different data structures.
