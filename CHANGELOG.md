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
