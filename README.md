# Flutter FolderView

A customizable Flutter widget for displaying hierarchical data in tree and folder views.

## Installation

```yaml
dependencies:
  flutter_folderview: ^0.11.0
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

There are two, and they differ by where you declare them and what they explain.

| | Declared on | Attaches to | Explains |
|---|---|---|---|
| **Label tooltip** | `NodeTooltipTheme`, per node type | The node's icon and label | The label — hover truncated text to read the rest |
| **Row tooltip** | `FolderView.rowTooltipBuilder`, once | The whole rendered row | The node — a card of its details |

Both can be enabled at once. Only one is ever visible: the innermost under the pointer. See [Row tooltip](#row-tooltip) for what that implies.

### Label tooltip

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
| `anchor` | `TooltipAnchor` | Anchor the tooltip to the row's rect or the cursor: `child` (default), `pointer` |
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

### Anchoring to the cursor

A node's tooltip attaches to its icon-and-label content, not to the whole rendered row. But a row is as wide as the tree's longest label, and each label grows to fill its row — so a long label's rect spans the row, and a tooltip anchored to that rect appears at the row's centre, far from where the user is actually pointing. `TooltipAnchor.pointer` keeps the same hover region but places the tooltip at the cursor:

```dart
NodeTooltipTheme(
  useTooltip: true,
  message: 'Report.pdf',
  anchor: TooltipAnchor.pointer, // default: TooltipAnchor.child
)
```

The anchor is captured when the tooltip is shown and does not follow the pointer, so `interactive` tooltips stay reachable. Tap-triggered tooltips anchor at the tap, and a `controller`-driven show with no pointer present falls back to the label's rect.

Against a point there are no target edges to align to, so under `TooltipAnchor.pointer` the `alignment` field selects which of the tooltip's *own* edges lands on the pointer.

Note that `anchor` does not widen the hover region. A short label occupies only the left part of its row, and the space to its right raises no tooltip under either anchor. To make the whole row hoverable, use the row tooltip below.

**Known issue.** When a tree is wide enough to scroll horizontally, a long label's rect extends past the visible `FolderView`, and so does its centre. Under the default `TooltipAnchor.child` the tooltip is aimed there and drawn outside the view — over whatever your app renders beside it. Use `TooltipAnchor.pointer`, whose anchor is the cursor and therefore always inside the view. Tracked in [#47](https://github.com/kihyun1998/flutter_folderview/issues/47).

## Row tooltip

`rowTooltipBuilder` returns a card shown while the pointer is anywhere over a node's row — the indent, the expand chevron, the empty space beside a short label. Return `null` for a node that should not have one.

```dart
FolderView(
  data: nodes,
  expandedNodeIds: expandedIds,
  rowTooltipBuilder: (context, node) {
    if (node.type == NodeType.folder) return null;
    return Card(child: Padding(
      padding: const EdgeInsets.all(12),
      child: Text('${node.label} — ${node.children.length} children'),
    ));
  },
)
```

The card supplies its own surface, so the tooltip around it draws no background, padding, or elevation. Give it a `Card`, not a bare `Text`.

It is anchored at the pointer, and that is not configurable. A row is laid out at the tree's content width rather than the viewport's, so anchoring to the row's rect would aim at a centre that leaves the screen the moment the view scrolls horizontally.

### Enabling both

Only one tooltip is visible at a time — the innermost under the pointer. So a node type whose label tooltip is enabled will hide the row card wherever its label sits.

This bites harder than it sounds. A row is as wide as the tree's longest label, and each label grows to fill its row — so on the widest row the label's rect *is* the row, and that node's card is unreachable at every point along it. **To show a row card on a node type, leave that type's `useTooltip` off.**

The pairing that works is a label tooltip on the types whose text gets truncated, and a row card on the rest.

## Example

See [example/](example/) for complete examples including:
- Theme customization
- Dynamic styling with resolver functions
- Data generation for testing

```bash
cd example
flutter run
```
