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
- The label shown is `RowMetrics.label`, the same rule measurement uses ([row-geometry](row-geometry.md)).
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
- **Fixed in #120: the factories' expand icon follows `ExpandIconTheme.color` and `expandedColor`.**
  - **The cause.** The renderer applies both through an `IconTheme` around the icon box, and Flutter's `Icon` takes `color ?? IconTheme.color` (`widgets/icon.dart`). `light()` and `dark()` gave the chevron its own grey, so on the default themes both fields did nothing: probed on 2026-10-19 with `color` red and `expandedColor` green, every chevron rendered `0xFF616161`.
  - **The fix.** Each factory's chevron is an uncoloured `Icon(Icons.chevron_right, size: 20)`, and its grey is the factory's `ExpandIconTheme.color` (`grey.shade700` light, `grey.shade400` dark). `expandedColor` stays `null`. The rendered colour is unchanged; what moved is where the value lives, so `light().expandIconTheme.color` is no longer `null`.
  - **The rule it leaves.** A default colour belongs in the theme field meant to override it, never on the default widget; a widget's own colour silently wins over the field. A caller's own coloured `widget` still ignores both fields, by Flutter's precedence, and the dartdoc says so.
  - **The decision.** The maintainer's, at triage on 2026-10-21, over documenting the limitation instead.
  - **Pinned** by `test/widgets/expand_icon_color_test.dart`, through `FolderView`, on both factories.
- `ChildNodeRenderer` merges `selectedTextStyle` itself, outside `RowMetrics`, so it is the one width input the two paths do not share ([row-geometry](row-geometry.md)).
