# Tier rendering

## What it is
Draws one row for one `FlatNode`. It builds a tier-agnostic scaffold (tree lines behind, indent spacer) and dispatches the row content to a tier renderer exactly once. Folders and Parents share one renderer through a read-only view of their themes; Children have their own.

## Governing decisions
- [ADR-0005](../../adr/0005-tier-theme-boilerplate-not-extracted.md): the three tier themes stay separate classes. `ExpandableNodeThemeView` is the read-only exception the ADR's reasoning permits: getters can be shared, `copyWith`/`lerp`/`scale` cannot (its dartdoc).
- [ADR-0003](../../adr/0003-selection-is-tier-bound-to-child.md): only the Child renderer knows about Selection ([selection](selection.md)).

## Design model
Read from `NodeWidget` and the renderers.
- `NodeWidget._content` is the only switch on tier. Each renderer is tier-fixed and switch-free.
- Indent is `depth × expandStripWidth`, and tree-line columns have the same width. Both come from `RowMetrics`.
- Icon precedence: `*Resolver(node)` over the static widget. A Folder uses the open-state icon whenever it is expanded; a Parent only in `tree` mode (`useOpenState`).
- The chevron rotates 90° when expanded and takes `expandedColor ?? color` through an `IconTheme`. A node without children still reserves the chevron strip.
- **A default colour lives in the theme field meant to override it, never on the default widget** (#120). Flutter's `Icon` takes `color ?? IconTheme.color`, so a widget's own colour silently wins. The factories' chevron is an uncoloured `Icon(Icons.chevron_right, size: 20)` with its grey in `ExpandIconTheme.color` (`grey.shade700` light, `grey.shade400` dark). Before, every chevron rendered `0xFF616161` with `color` red and `expandedColor` green (probed 2026-10-19). Decided by the maintainer at triage, 2026-10-21, over documenting the limitation. Pinned by `test/widgets/expand_icon_color_test.dart`. A caller's own coloured `widget` still ignores both fields, and the dartdoc says so.
- The label shown is `RowMetrics.label`, the same rule measurement uses ([row-geometry](row-geometry.md)).
- `NodeLabel` is a start-aligned `Row(min)`: icon box, then `Flexible(Text(ellipsis))`. The label tooltip wraps only the `Text` ([label-tooltip](label-tooltip.md)).
- `NodeWidget` asks for `SizedBox(height: rowHeight)`, but the `ListView`'s `itemExtent` overrides it, so a row is `rowHeight + rowSpacing` tall with its content centred ([row-extent](../invariant/row-extent.md)).
- Each renderer's ink is a `CustomInkWell` ([taps](taps.md)), with the theme's hover, splash and highlight colours, falling back to the ambient `ColorScheme`.

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
- [row-extent](../invariant/row-extent.md) — the row is the extent tall, not `rowHeight`.

## Blast radius
- [row-geometry](row-geometry.md) — any change to what a row draws horizontally (label source, icon box, padding) must be mirrored in `RowMetrics`.
- [taps](taps.md) — each renderer decides which gestures its `CustomInkWell` receives.
- [selection](selection.md) — the Child renderer paints the Selected Set.
- [label-tooltip](label-tooltip.md) — `NodeLabel` decides the tooltip's hover region.
- [tree-lines](tree-lines.md) — shares the column width, and the scaffold decides whether lines are drawn.
- [view-mode-projection](view-mode-projection.md) — the Parent open-state icon is mode-dependent.
- [theme-composition](theme-composition.md) — the renderers read the tier themes.

## Known holes / open
- A selected Child's style is merged outside `RowMetrics`, so it is the one width input the two paths do not share ([selection](selection.md)).
