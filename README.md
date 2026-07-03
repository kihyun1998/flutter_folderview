# Flutter FolderView

A customizable Flutter widget for displaying hierarchical data in tree and folder views.

## Installation

```yaml
dependencies:
  flutter_folderview: ^0.10.0
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

## Scale

Scale all content proportionally. **Scrollbars** and **tooltips** are not affected — they are treated as chrome (interactive overlays sized for input devices, not for content density).

```dart
FolderView(
  data: nodes,
  mode: ViewMode.folder,
  scale: 1.5, // default 1.0
  expandedNodeIds: expandedIds,
)
```

| Scaled | Not Scaled |
|---|---|
| Row height, row spacing | Scrollbar thickness, track width |
| Icon sizes, padding, margin | Scrollbar colors |
| Text fontSize, letterSpacing | Tooltip dimensions (padding, arrow, offset, text) |
| Line width, indentation | Animation durations, click intervals |
| Content padding, border radius | Colors |

Each theme class also exposes a `scale()` method directly — useful for callers who need a scaled copy of a theme outside `FolderView` (custom previews, integration tests, etc.):

```dart
final scaledTheme = myTheme.scaledForContext(context, 1.5);
// or, without a BuildContext:
final scaledTheme = myTheme.scale(factor: 1.5, defaultFontSize: 14.0);
```

Ctrl (Windows/Linux) or Cmd (macOS) + scroll wheel is blocked by default (`blockModifierScroll: true`) so zoom-by-scroll works without unintended scrolling. Set `blockModifierScroll: false` to allow normal scrolling while the modifier key is held.

The library also exports `isScaleModifierPressed()` — a platform-aware helper that returns `true` when Ctrl (Windows/Linux) or Cmd (macOS) is pressed. Use it to implement custom zoom logic:

```dart
Listener(
  onPointerSignal: (event) {
    if (event is PointerScrollEvent && isScaleModifierPressed()) {
      final delta = event.scrollDelta.dy > 0 ? -0.1 : 0.1;
      setState(() => _scale = (_scale + delta).clamp(0.5, 3.0));
    }
  },
  child: FolderView(
    data: nodes,
    mode: ViewMode.folder,
    scale: _scale,
    expandedNodeIds: expandedIds,
  ),
)
```

```dart
FolderView(
  data: nodes,
  mode: ViewMode.folder,
  scale: 1.5,
  blockModifierScroll: true, // default: true
  expandedNodeIds: expandedIds,
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
| `alignment` | `TooltipAlignment` | Alignment: `start`, `center`, `end`, `startTargetCenter`, `endTargetCenter` |
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
| `showArrow` | `bool?` | Show arrow on tooltip (default: `false`) |
| `arrowBaseWidth` | `double?` | Arrow base width (default: `12.0`) |
| `arrowLength` | `double?` | Arrow length (default: `6.0`) |
| `arrowPositionRatio` | `double?` | Arrow position ratio 0.0~1.0 (default: `0.25`) |
| `borderColor` | `Color?` | Tooltip border color |
| `borderWidth` | `double?` | Tooltip border width (default: `0.0`) |
| `screenMargin` | `double?` | Min margin from screen edges (default: `8.0`) |
| `animation` | `TooltipAnimation?` | Animation type: `none`, `fade`, `scale`, `slide`, `fadeScale`, `fadeSlide`, `rotation` |
| `animationCurve` | `Curve?` | Custom curve for animation |
| `fadeBegin` | `double?` | Starting opacity for fade animations (default: `0.0`) |
| `scaleBegin` | `double?` | Starting scale for scale animations (default: `0.0`) |
| `slideOffset` | `double?` | Slide distance as fraction of tooltip size (default: `0.3`) |
| `rotationBegin` | `double?` | Starting rotation in turns (default: `-0.05`) |
| `hideOnEmptyMessage` | `bool?` | Suppress tooltip when message is empty (default: `true`) |

## Example

See [example/](example/) for complete examples including:
- Theme customization
- Dynamic styling with resolver functions
- Data generation for testing

```bash
cd example
flutter run
```
