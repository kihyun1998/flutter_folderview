# Label tooltip

## What it is
The per-tier tooltip configured by `NodeTooltipTheme` on each tier theme. It explains a Node's **label**, and its hover region is the label's glyphs only. It is one of this package's two `just_tooltip` surfaces. The other is the [row-card](row-card.md).

## Governing decisions
- [ADR-0004](../../adr/0004-tooltips-excluded-from-scale.md): chrome, excluded from Scale. `NodeTooltipTheme` has no `scale` method.

No record governs the anchor, the hover region, or the defaults. They were decided in #42, #44 and #52 and live in dartdoc, the CHANGELOG and [lessons](../../agents/lessons.md).

## Design model
- Wraps the `Text` inside `NodeLabel`, not the icon and not the `Flexible` box. Whatever of the row is left over belongs to the row card.
- **No wrapper at all** when `useTooltip` is false or there is no content. Content precedence is `tooltipBuilderResolver(node)`, then `tooltipBuilder`, then `message`. This absence is load-bearing for [innermost-tooltip-wins](../invariant/innermost-tooltip-wins.md).
- `anchor` defaults to `TooltipAnchor.child`, with `pointer` as an opt-in (#42). The pointer is captured at show time and does not follow the cursor.
- Defaults that differ from the row card, on purpose: `interactive: false`, `enableTap: false`, fade animation, `screenMargin: 8`.
- A `child`-anchored tooltip aims at the label rect's centre. Whether that centre is visible depends on [row-wider-than-viewport](../invariant/row-wider-than-viewport.md). From `just_tooltip 0.4.2`, placement targets the visible part of a clipped child (#47).

## Code
- `lib/widgets/node_render_parts.dart` — `wrapWithNodeTooltip`, `NodeLabel`
- `lib/themes/node_tooltip_theme.dart` — `NodeTooltipTheme`, `NodeTooltipTheme.anchor`

## Reference behaviour
Compared against upstream `just_tooltip`, but not pinned. #42's hover probes were only trusted after reading upstream's `just_tooltip_anchor_test.dart` harness. The three hover-test traps are recorded in `test/widgets/node_tooltip_anchor_placement_test.dart`'s header. No `file:line@SHA` pin exists. Re-read upstream at the resolved version rather than trusting a paraphrase.

## Cross-cutting invariants
- [row-wider-than-viewport](../invariant/row-wider-than-viewport.md)
- [innermost-tooltip-wins](../invariant/innermost-tooltip-wins.md)
- [chrome-excluded-from-scale](../invariant/chrome-excluded-from-scale.md)
- [measured-equals-rendered](../invariant/measured-equals-rendered.md) — a label is only unellipsized, and its rect only as wide as its glyphs, where measurement holds.

## Blast radius
- [row-card](row-card.md) — narrowing or widening this hover region moves where the card is reachable.
- [dependency-floor-release](dependency-floor-release.md) — placement and suppression behaviour ride the `just_tooltip` version.
- [tier-rendering](tier-rendering.md) — `NodeLabel`'s layout is the hover region.

## Known holes
- The defaults are duplicated as literals in `wrapWithNodeTooltip` (`8.0`, `0xFF616161`, `150ms`, …) rather than living on the theme. Not a defect, but the place to look when a default "does not change".
