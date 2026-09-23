# Tier rendering

## What it is
Draws one row for one `FlatNode`. It builds a tier-agnostic scaffold (fixed row height, tree lines behind, indent spacer) and dispatches the row content to a tier renderer exactly once. Folders and Parents share one renderer through a read-only view of their themes. Children have their own.

## Governing decisions
- [ADR-0005](../../adr/0005-tier-theme-boilerplate-not-extracted.md): the three tier themes stay separate classes. `ExpandableNodeThemeView` is the read-only exception the ADR's reasoning permits (getters inherit; `copyWith`/`lerp`/`scale` do not).
- [ADR-0003](../../adr/0003-selection-is-tier-bound-to-child.md): only the Child renderer knows about Selection.

## Design model
- `NodeWidget._content` is the only switch on tier. Each renderer is tier-fixed and switch-free.
- Indent is `depth × expandStripWidth`, and tree-line columns have the same width. Both come from `RowMetrics`.
- Icon precedence: `*Resolver(node)` over the static widget. A Folder always uses the open-state icon when it is expanded. A Parent uses it only in `tree` mode.
- The chevron rotates 90° when expanded and takes `expandedColor ?? color`. A node without children still reserves the chevron strip.
- The label shown is `labelResolver?.call(node) ?? node.label`. See [row-geometry](row-geometry.md) for why that matters.
- `NodeLabel` is a start-aligned `Row(min)`: icon box, then `Flexible(Text(ellipsis))`. The label tooltip wraps only the `Text` ([label-tooltip](label-tooltip.md)).

## Code
- `lib/widgets/node_widget.dart` — `NodeWidget`, `NodeWidget._content`
- `lib/widgets/expandable_node_renderer.dart` — `ExpandableNodeRenderer`
- `lib/widgets/child_node_renderer.dart` — `ChildNodeRenderer`
- `lib/widgets/node_render_parts.dart` — `NodeIconBox`, `NodeLabel`
- `lib/themes/expandable_node_theme_view.dart` — `ExpandableNodeThemeView`
- `lib/themes/expand_icon_theme.dart` — `ExpandIconTheme`

## Reference behaviour
**None.**

## Cross-cutting invariants
- [measured-equals-rendered](../invariant/measured-equals-rendered.md) — this territory is the "rendered" half.

## Blast radius
- [row-geometry](row-geometry.md) — any change to what a row draws horizontally (label source, icon box, padding) must be mirrored in `RowMetrics`.
- [tap-and-selection](tap-and-selection.md) — each renderer decides which gestures its `CustomInkWell` receives.
- [label-tooltip](label-tooltip.md) — `NodeLabel` decides the tooltip's hover region.
- [tree-lines](tree-lines.md) — shares the column width.
- [view-mode-projection](view-mode-projection.md) — the Parent open-state icon depends on the mode.

## Known holes
- [ADR-0003](../../adr/0003-selection-is-tier-bound-to-child.md)'s "Note on the current implementation" still says a half-finished Folder/Parent `isSelected` branch lives in `node_widget.dart` and is scheduled for removal. It was removed by the tier-renderer split (`bfb91db`): `ExpandableNodeRenderer` has no selection branch. The ADR's note is a stale prediction. The ADR is not edited from here.
