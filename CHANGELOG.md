## 0.11.0

- **feat**: `FolderView.rowTooltipBuilder` ([#44](https://github.com/kihyun1998/flutter_folderview/issues/44)) — a card shown while the pointer is anywhere over a Node's rendered row. Return `null` for a Node that should not have one. It is declared once on the `FolderView`, not per Tier, because it explains the **Node**, where the existing `NodeTooltipTheme` tooltip attaches to the icon-and-label content and explains the **label**. Both can be enabled at once.
  - The card is anchored at the pointer, and this is not configurable. A row is laid out at the tree's content width, not the viewport's, so anchoring to the row's rect would aim at a centre that leaves the screen as soon as the view scrolls horizontally.
  - The card supplies its own surface, so the tooltip around it draws no background, padding, or elevation. Give it a `Card`, not a bare `Text`.
  - **Enabling a Tier's label tooltip hides the row card wherever that label sits.** Only one tooltip is ever visible — the innermost under the pointer. A row is as wide as the tree's longest label, and `Flexible` grows each label to whatever its row gives it, so on the widest row the label's rect *is* the row: its card is unreachable. To show a row card on a Tier, leave that Tier's `useTooltip` off.
- **feat**: `NodeTooltipTheme.anchor` ([#42](https://github.com/kihyun1998/flutter_folderview/issues/42)). A node's tooltip attaches to its icon-and-label content, and a long label fills its row — so a tooltip anchored to that rect appears at the row's centre, which can be far from where the user is actually pointing, and outside the view entirely once the tree scrolls horizontally. `anchor: TooltipAnchor.pointer` keeps the same hover region but places the tooltip at the cursor. `TooltipAnchor` is now re-exported. Defaults to `TooltipAnchor.child`, the behaviour shipped in `0.10.2`, so existing tooltips are unchanged.
  - The anchor is captured when the tooltip is shown and does not follow the pointer, so `interactive` tooltips stay reachable. Tap-triggered tooltips anchor at the tap; a `controller`-driven show with no pointer present falls back to the label's rect.
  - Against a point there are no target edges to align to, so under `TooltipAnchor.pointer` the `alignment` field selects which of the tooltip's *own* edges lands on the pointer.
  - `anchor` does not widen the hover region — a short label leaves the space to its right raising no tooltip under either anchor. For that, use `rowTooltipBuilder` above.
- **note**: `TooltipRegistry` (added in `just_tooltip 0.3.0`) is deliberately not re-exported. `rowTooltipBuilder` is the first place this package nests one tooltip inside another, and it needed no registry: `just_tooltip 0.4.0` suppresses an ancestor whenever a descendant holds the pointer, regardless of registry. Exposing it would grow the public surface for a use case — isolating a `FolderView`'s tooltip group from the host app — that has not yet appeared.
- **deps**: `just_tooltip` `^0.4.2`, which **raises the minimum Flutter to `3.13.0`** (Dart `3.1.0`), up from `3.10.0`. Its ancestor clip walk reads `RenderObject.parent`, which was `AbstractNode?` — a type with no `describeApproximatePaintClip` — until Flutter 3.13. `flutter_folderview` declared `>=3.10.0`, and its `^0.4.0` constraint already resolved `0.4.2`, so that floor had become a promise it could not keep.
- **fix**: a label tooltip is no longer painted outside the `FolderView` ([#47](https://github.com/kihyun1998/flutter_folderview/issues/47)). When a tree scrolls horizontally, a long label's rect extends past the view, and `TooltipAnchor.child` aimed at its centre — a point nobody could see. `screenMargin` never objected: it confines the tooltip to the enclosing `Overlay`, usually the whole app. `just_tooltip 0.4.2` now targets the visible part of a clipped child, so the tooltip lands inside the view. Pre-existing; every version with tooltips had it.
  - Two further `just_tooltip` fixes come along: a visible tooltip now re-aims when its child moves (scroll, resize, insertion above it) and hides once the child is clipped away entirely; and the target rect now follows the child's paint transform, so a `Transform.scale` between a node and the `Overlay` no longer mis-sizes it.

## 0.10.2

- **deps**: Bump `just_tooltip` to `^0.4.0`. Not breaking for `flutter_folderview`: nothing was removed from `just_tooltip`'s API, the re-exported `JustTooltipController` is unchanged, and its one behaviour change — a nested tooltip now suppresses its ancestors — cannot be reached from here, since `FolderView` wraps exactly one `JustTooltip` per node label and never nests them. Node tooltips gain `just_tooltip`'s fix for tooltips laid out in an `Overlay` that does not fill the window from its origin: under a nested `Navigator`, an inset `Overlay`, or an embedded Flutter view, a node's tooltip was displaced by the Overlay's offset and had its auto-flip and `screenMargin` clamping measured against the wrong bounds. Placing a `FolderView` inside such a host now positions its tooltips correctly. No `flutter_folderview` API changed.
- **note**: `just_tooltip 0.4.0` adds `TooltipAnchor`, which anchors a tooltip at the pointer instead of the child's rect. It is deliberately **not** re-exported yet: `NodeTooltipTheme` has no `anchor` field, so the enum would be visible but unusable. Exposing it is a `flutter_folderview` feature decision, tracked in [#42](https://github.com/kihyun1998/flutter_folderview/issues/42) along with `TooltipRegistry`, which `just_tooltip 0.3.0` added and which is likewise not re-exported.

## 0.10.1

- **perf**: Remove the per-row `Material` from node rows. `CustomInkWell` no longer wraps each row in its own `Material > Ink > InkWell`; instead `FolderViewContent` provides a single transparent `Material` once above the row list, and every row's ink (splash / highlight) paints onto that shared surface. Profiling a large tree under fling scroll showed the per-row Material crossed the 16 ms frame budget noticeably more often than the shared-Material variant. Ripple, hover, highlight, and selection are visually unchanged; the public `FolderView` API is unchanged (`CustomInkWell` is an internal row primitive and now requires an ancestor `Material` by design).

## 0.10.0

- **BREAKING**: Bump `just_tooltip` to `^0.3.0`. Its `JustTooltipController` — re-exported here and usable via `NodeTooltipTheme.controller` — is no longer a `ChangeNotifier`: `shouldShow` and `addListener` / `removeListener` / `dispose` are removed. Drive it with `show()` / `hide()` / `toggle()` and observe visibility via the tooltip's `onShow` / `onHide` callbacks. `just_tooltip` also narrowed its exports (`JustTooltipPositionDelegate`, `TooltipShapePainter`, `JustTooltipOverlay` are now internal). No `flutter_folderview` API changed.
- **perf**: Pack a `FlatNode`'s ancestor tree-line flags into an `int` bitmask instead of a per-node `List<bool>`, removing a heap allocation for every flattened node (the flags are read only for painted rows). Flatten is ~3× faster and the flat-list heap footprint roughly halves on large trees. Tree-line rendering is unchanged; tree depth is capped at 63.
- **perf**: Apply incremental expand/collapse in place on the cached flat list instead of copying the whole list on every single-node toggle — ~1.7× faster toggles on large trees. Visible rows and scroll anchoring are unchanged.
- **perf**: In `RowMetrics.maxWidth`, merge the effective text style once per tier instead of once per node, removing the per-node `TextStyle` allocation on every data / scale / theme change (~5.5× faster on the warm measurement path). The returned width is unchanged, so horizontal scroll extent and clipping are identical.
- **test / ci**: Add widget tests for the `FolderView` interaction, selection, view-mode, and modifier+wheel scale-gesture contracts; add an `integration_test` harness driving the example app end-to-end (boot, expand, select, zoom, view-mode switch); add a GitHub Actions analyze + test workflow; add `benchmark/` microbenchmarks and heap-footprint measurements for the flatten / projection / maxWidth hot paths.

## 0.9.0

- **refactor**: Decentralize content scaling — each theme class now exposes its own `scale()` method, replacing the prior centralized `_applyScale` implementation. Existing usage (`FolderView(scale: ...)`) is unaffected.
- **feat**: Add `FlutterFolderViewTheme.scale({required factor, required defaultFontSize})` and `FlutterFolderViewTheme.scaledForContext(BuildContext, double)` for callers who want a scaled theme outside `FolderView` (custom previews, integration tests, etc.).
- **docs**: Add `CONTEXT.md` (domain glossary) and ADRs `0001` (scrollbars excluded from scale), `0002` (caller owns interaction state), `0003` (selection tier-bound to child), `0004` (tooltips excluded from scale).
- **test**: Add 31 unit tests covering the new scale API (identity short-circuit, positivity assertion, chrome exclusion for scrollbars/tooltips, null `fontSize` resolution against `defaultFontSize`).

## 0.8.1

- **fix**: Explicitly set `SystemMouseCursors.click` as the default `mouseCursor` on node `InkWell` — newer Flutter versions no longer auto-apply the click cursor on hover

## 0.8.0

- **BREAKING**: Rename `blockCtrlScroll` → `blockModifierScroll` to accurately reflect platform-aware behavior (Ctrl on Windows/Linux, Cmd on macOS)
- **BREAKING**: `blockModifierScroll` is now `bool?` (default `null`) — automatically follows `onScaleChanged` when unset
- **feat**: Add `onScaleChanged` callback and `scaleStep` parameter for built-in modifier+scroll zoom handling
- **feat**: Export `isScaleModifierPressed()` helper for library consumers implementing custom zoom logic
- **fix**: Use platform-aware modifier key check to prevent Windows key from permanently triggering zoom mode

## 0.7.1

- **feat**: Add `blockCtrlScroll` parameter to `FolderView` (default: `true`) — optionally disable Ctrl/Cmd + scroll blocking for users who don't need zoom-by-scroll

## 0.7.0

- **feat**: Add `scale` parameter to `FolderView` for content zoom (default: `1.0`)
- **feat**: Scale all layout dimensions proportionally — row height, icon sizes, text size, spacing, line width, indentation, content padding, border radius
- **feat**: Scrollbar appearance (thickness, track width, colors) is NOT affected by scale
- **feat**: Preserve visible node on scale change with automatic scroll position adjustment
- **feat**: Ignore scroll events when Ctrl/Cmd is pressed to support zoom-by-scroll without unintended scrolling
- **fix**: Defer scroll position adjustment to post-frame callback to prevent `setState() called during build` error
- **fix**: Scale content width clamp limit (`3x viewport * scale`) to prevent text ellipsis at high scale values
- **example**: Add scale slider to Layout controls and Ctrl/Cmd + mouse wheel zoom support

## 0.6.9

- **fix**: Pre-compute content width from all nodes (including collapsed) to prevent layout jumps on expand/collapse
- **fix**: Include `letterSpacing` in text width calculation for accurate horizontal scroll sizing
- **feat**: Add `calculateMaxContentWidth` method to `SizeService` for upfront width calculation
- **example**: Add long name test options (Folder/Parent/Child) to data generator for horizontal scroll testing

## 0.6.8

- **feat**: Bump just_tooltip to 0.2.5
- **feat**: Add `hideOnEmptyMessage` option to `NodeTooltipTheme` — suppress tooltip when message is empty (default: `true`)
- **feat**: Support `TooltipAlignment.startTargetCenter` and `endTargetCenter` alignments — arrow dynamically points to the center of the target widget

## 0.6.7

- **fix**: Bump just_tooltip to 0.2.3 — fix `borderColor` not visible when `showArrow: false`

## 0.6.6

- **fix**: Tighten `just_tooltip` constraint to `^0.2.2` to fix pub.dev lower bounds compatibility check

## 0.6.5

- **feat**: Bump just_tooltip to 0.2.1
- **feat**: Add `animation` (`TooltipAnimation`) option to `NodeTooltipTheme` — supports `none`, `fade`, `scale`, `slide`, `fadeScale`, `fadeSlide`, `rotation`
- **feat**: Add `animationCurve`, `fadeBegin`, `scaleBegin`, `slideOffset`, `rotationBegin` options to `NodeTooltipTheme`
- **feat**: Export `TooltipAnimation` from barrel file

## 0.6.4

- **feat**: Bump just_tooltip to 0.2.0
- **feat**: Add `showArrow`, `arrowBaseWidth`, `arrowLength`, `arrowPositionRatio` options to `NodeTooltipTheme`
- **feat**: Add `borderColor`, `borderWidth` options to `NodeTooltipTheme`
- **feat**: Add `screenMargin` option to `NodeTooltipTheme`
- **feat**: Export `JustTooltipTheme` from barrel file

## 0.6.3

- **fix**: Bump just_tooltip to 0.1.5 (bugfix)

## 0.6.2

- **feat**: Add `interactive`, `waitDuration`, `showDuration`, `boxShadow` options to `NodeTooltipTheme` (just_tooltip 0.1.4)

## 0.6.1

- **fix**: Tooltip hover area now limited to icon+label only, no longer triggers on empty row space

## 0.6.0

- **BREAKING CHANGE**: Migrate tooltip from Flutter `Tooltip` to `just_tooltip` package
- **BREAKING CHANGE**: Remove `TooltipPosition` enum — replaced by `TooltipDirection` (top/bottom/left/right)
- **BREAKING CHANGE**: Remove `margin`, `verticalOffset`, `waitDuration`, `boxShadow` from `NodeTooltipTheme`
- **BREAKING CHANGE**: Remove `richMessage` / `richMessageResolver` — replaced by `tooltipBuilder` / `tooltipBuilderResolver` (`WidgetBuilder`)
- **feat**: Add `direction` (4-directional), `alignment` (start/center/end), `offset`, `crossAxisOffset` properties to `NodeTooltipTheme`
- **feat**: Add `elevation`, `borderRadius`, `padding` properties to `NodeTooltipTheme`
- **feat**: Add `controller` (`JustTooltipController`) for programmatic tooltip show/hide
- **feat**: Add `enableTap`, `enableHover` properties for tooltip trigger control
- **feat**: Add `animationDuration`, `onShow`, `onHide` properties to `NodeTooltipTheme`
- **feat**: Tooltip now wraps both node icon and label instead of label only
- **feat**: Export `TooltipDirection`, `TooltipAlignment`, `JustTooltipController` from barrel file

## 0.5.3

- **fix**: Recursively collect parent nodes from nested folders in tree mode

## 0.5.2

- **perf**: Replace `setState` with `ValueNotifier` for horizontal scroll offset and hover state to prevent full widget tree rebuilds
- **perf**: Eliminate recursive list spreading in `FlattenService.flatten()` by reusing a single mutable list with add/removeLast pattern

## 0.5.1

- **fix**: Show full text on horizontal scroll instead of ellipsis-truncated text using `OverflowBox`

## 0.5.0

- **BREAKING CHANGE**: Remove `isExpanded` property from `Node<T>` model - nodes are now immutable
- **BREAKING CHANGE**: Add `expandedNodeIds` parameter to `FolderView`, `FolderViewContent`, and `NodeWidget` for external expansion state management
- **BREAKING CHANGE**: Update `SizeService` methods to accept `expandedNodeIds` parameter
- **perf**: Add incremental expand/collapse with `expandNode()` and `collapseNode()` methods in `FlattenService`
- **perf**: Implement text width caching via `_textWidthCache` to reduce expensive `TextPainter` layout calls
- **perf**: Add lazy content width measurement - calculate as nodes render instead of upfront O(N) traversal
- **perf**: Optimize scroll performance for 20k+ nodes with `Transform.translate` and `itemExtent` on `ListView.builder`
- **fix**: Clamp scroll offset to valid range instead of skipping sync when out of range
- **fix**: Preserve scroll position on bulk expand/collapse (expandAll/collapseAll) using viewport anchor node

## 0.4.0

- **feat**: Add `labelResolver` to `FolderNodeTheme`, `ParentNodeTheme`, `ChildNodeTheme` for dynamic label resolution based on `node.data`
- **fix**: Update animation controller duration in `didUpdateWidget` when theme `animationDuration` changes at runtime

## 0.2.4

- **feat**: Add `labelResolver` to all node themes for dynamic label display

## 0.2.3

- **feat**: Add `color` and `expandedColor` properties to `ExpandIconTheme` for expand icon color theming

## 0.2.2

- **refactor**: Unified expand icon logic to ensure consistent node layout alignment
- **refactor**: Add `isChild` parameter to `_buildExpandIcon` for proper child node spacing

## 0.2.1

- **feat**: Add `hoverColor`, `splashColor`, and `highlightColor` properties to all node themes for interaction color theming
- **feat**: Add comprehensive tooltip support with `NodeTooltipTheme` class for all node types
- **feat**: Add `rowHeight` property to `FlutterFolderViewTheme` for configurable row height
- **feat**: Add `rowSpacing` property to `FlutterFolderViewTheme` for vertical spacing between rows
- **refactor**: Remove `iconToTextSpacing` property from all node themes - now controlled via icon `margin.right`

## 0.2.0

- **BREAKING CHANGE**: Migrate from unified `FolderViewTextTheme` and `FolderViewIconTheme` to node-type specific themes (`FolderNodeTheme`, `ParentNodeTheme`, `ChildNodeTheme`, `ExpandIconTheme`)
- **feat**: Add custom `Widget?` support for each node type instead of hardcoded `Icon` widgets
- **feat**: Add `openWidget` property for folder nodes (displayed when expanded)
- **feat**: Add `padding` and `margin` properties for each widget type
- **feat**: Add `clickInterval` property to `ChildNodeTheme` for configurable double-click detection (default: 300ms)
- **feat**: Add `animationDuration` property to `FlutterFolderViewTheme` for configurable expand/collapse animation speed
- **feat**: Add theme resolver functions (`widgetResolver`, `textStyleResolver`, `selectedTextStyleResolver`, `openWidgetResolver`) for dynamic styling based on node data
- **feat**: Add generic type support `<T>` to all theme classes for type-safe access to `node.data`

## 0.1.2

- **fix**: Fixed scroll position being reset when expanding/collapsing nodes by removing contentHeight from SyncedScrollControllers key

## 0.1.1

- **fix**: Fixed scroll position calculation when switching between view modes or expanding/collapsing nodes

## 0.1.0

- **feat**: Add dual view modes (Tree and Folder)
- **feat**: Add three node types (Folder, Parent, Child) for flexible hierarchy representation
- **feat**: Add multiple line styles (Connector, Scope, None) for visual tree structure
- **feat**: Add comprehensive theming system (icon, text, line, scrollbar, spacing, node style)
- **feat**: Add interactive features (selection, tap handlers, expand/collapse animations)
- **feat**: Add synchronized horizontal and vertical scrolling with custom scrollbars
- **feat**: Add depth-based indentation for nested nodes
- **fix**: Correct indent and line positioning for nested nodes based on depth level
