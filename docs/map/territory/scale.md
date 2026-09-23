# Scale

## What it is
Applies the caller's **Scale** factor uniformly to every content-spatial property of the rendered tree: row height and spacing, icon boxes, text, indentation, line width, border radius and content padding. Chrome, durations and colours are excluded. The scaled theme is derived once per build and handed to everything downstream.

## Governing decisions
- [ADR-0002](../../adr/0002-caller-owns-interaction-state.md): Scale is caller-owned.
- [ADR-0001](../../adr/0001-scrollbars-excluded-from-scale.md): scrollbars excluded.
- [ADR-0004](../../adr/0004-tooltips-excluded-from-scale.md): tooltips excluded, encoded structurally (no `scale` method).

## Design model
- `FolderView.scale` → `FlutterFolderViewTheme.scaledForContext`, which returns `this` at 1.0 and otherwise takes `defaultFontSize` from Material `bodyMedium` → `FlutterFolderViewTheme.scale`. That method multiplies `rowHeight` and `rowSpacing` and delegates to each sub-theme's `scale`, **except** `scrollbarTheme`.
- Each tier theme's `scale` does not delegate to its `tooltipTheme`. `NodeTooltipTheme` and `RowTooltipTheme` have no `scale` method.
- Text: `scaleTextStyle` materializes a null style from `defaultFontSize`. `scaleOptionalTextStyle` keeps opt-in styles null.
- User-supplied `Widget`s cannot be rescaled. `NodeIconBox` wraps them in `FittedBox` when `scale != 1`, which is approximate by design (`CONTEXT.md` flagged ambiguity).
- Because each tier theme hand-lists its fields ([ADR-0005](../../adr/0005-tier-theme-boilerplate-not-extracted.md)), a new spatial field has to be added to `scale` in every class that has it, or it silently stays unscaled.

## Code
- `lib/themes/flutter_folder_view_theme.dart` — `FlutterFolderViewTheme.scale`, `FlutterFolderViewTheme.scaledForContext`
- `lib/themes/_scale_text_style.dart` — `scaleTextStyle`, `scaleOptionalTextStyle`
- `lib/themes/folder_node_theme.dart` — `FolderNodeTheme.scale`
- `lib/themes/parent_node_theme.dart` — `ParentNodeTheme.scale`
- `lib/themes/child_node_theme.dart` — `ChildNodeTheme.scale`
- `lib/widgets/node_render_parts.dart` — `NodeIconBox`

## Reference behaviour
**None.**

## Cross-cutting invariants
- [chrome-excluded-from-scale](../invariant/chrome-excluded-from-scale.md)

## Blast radius
- [row-geometry](row-geometry.md) — a Scale change is a width-invalidation trigger, and measurement reads the scaled theme.
- [scroll-anchoring](scroll-anchoring.md) — a Scale change re-anchors both axes.
- [theme-composition](theme-composition.md) — every new theme field is a Scale decision.
- [scale-input](scale-input.md) — the gesture that proposes the new value.
- [tree-lines](tree-lines.md) — line width scales with `lineTheme`.

## Known holes
- `scale` must be > 0 (a constructor `assert`). There is no upper bound, and the library proposes values without clamping ([scale-input](scale-input.md)).
