# Label tooltip

## What it is
The per-tier tooltip configured by `NodeTooltipTheme` on each tier theme. It explains a Node's **label**, and its hover region is the label's glyphs only. It is one of this package's two `just_tooltip` surfaces; the other is the [row-card](row-card.md).

## Governing decisions
- [ADR-0004](../../adr/0004-tooltips-excluded-from-scale.md): chrome, excluded from Scale. `NodeTooltipTheme` has no `scale` method.

No record governs the anchor, the hover region, or the defaults. They were decided in #42, #44 and #52 and live in dartdoc, the CHANGELOG and [lessons](../../agents/lessons.md).

## Design model
Read from `wrapWithNodeTooltip` and `NodeLabel`.
- Wraps the `Text` inside `NodeLabel`, not the icon and not the `Flexible` box. Whatever of the row is left over belongs to the row card (#52).
- **No wrapper at all** when the theme is null, `useTooltip` is false, or there is no content. Content precedence is `tooltipBuilderResolver(node)`, then `tooltipBuilder`, then `message`; a resolved builder sends `message: null`. This absence is load-bearing for [innermost-tooltip-wins](../invariant/innermost-tooltip-wins.md).
- `anchor` defaults to `TooltipAnchor.child`, with `pointer` as an opt-in (#42). The pointer is captured at show time and does not follow the cursor (`NodeTooltipTheme.anchor` dartdoc).
- Defaults that differ from the row card, on purpose: `interactive: false`, `enableTap: false`, fade animation, `screenMargin: 8`. They are literals in `wrapWithNodeTooltip` (`8.0`, `0xFF616161`, `150ms`, …), not theme defaults: the place to look when a default "does not change".
- **A controller is per Node** (#133). `controllerResolver: JustTooltipController? Function(Node<T>)`, shaped like `tooltipBuilderResolver`, replaced the single `controller`: one controller on a Tier theme attached to every built label of the Tier, and just_tooltip 0.4.4's `attach` asserts `_target == null`, so the second label threw in debug and the last one built won in release. BREAKING in 0.12.0, by the maintainer's call at triage, 2026-10-21, over deprecating the field alongside the resolver or documenting it as single-Node. Upstream detaches and reattaches on a controller change and applies a `show()` queued while detached, so a show for an unbuilt row lands when it is built. Pinned by `test/widgets/node_tooltip_controller_test.dart`.
- **`hideOnEmptyMessage` was removed in 0.12.0** (#131, maintainer's call). It could not act: with no builder and an empty message the wrapper is skipped, a builder always counts as content, and `JustTooltip`'s constructor asserts `message != null || tooltipBuilder != null`. Re-adding it means first deciding what an empty bubble is for; it would also hide the row card.
- A `child`-anchored tooltip aims at the label rect's visible part. From `just_tooltip 0.4.2`, placement targets the visible part of a clipped child (#47); whether that is near the pointer depends on [row-wider-than-viewport](../invariant/row-wider-than-viewport.md).

## Code
- `lib/widgets/node_render_parts.dart` — `wrapWithNodeTooltip`, `NodeLabel`
- `lib/themes/node_tooltip_theme.dart` — `NodeTooltipTheme`, `NodeTooltipTheme.anchor`, `NodeTooltipTheme.controllerResolver`, `NodeTooltipTheme.tooltipBuilderResolver`

## Reference behaviour
Compared against upstream `just_tooltip`, not pinned. #42's hover probes were trusted only after reading upstream's `just_tooltip_anchor_test.dart` harness. The hover-test traps are recorded in `test/widgets/node_tooltip_anchor_placement_test.dart`'s header. No `file:line@SHA` pin exists: re-read upstream at the resolved version (route in [`thegraph.md`](../../agents/thegraph.md)).

## Cross-cutting invariants
- [row-wider-than-viewport](../invariant/row-wider-than-viewport.md)
- [innermost-tooltip-wins](../invariant/innermost-tooltip-wins.md)
- [chrome-excluded-from-scale](../invariant/chrome-excluded-from-scale.md)
- [measured-equals-rendered](../invariant/measured-equals-rendered.md) — a label is only unellipsized, and its rect only as wide as its glyphs, where measurement holds.

## Blast radius
- [row-card](row-card.md) — narrowing or widening this hover region moves where the card is reachable.
- [dependency-floor](dependency-floor.md) — placement, suppression and controller behaviour ride the resolved `just_tooltip`.
- [tier-rendering](tier-rendering.md) — `NodeLabel`'s layout is the hover region.
- [taps](taps.md) — `enableTap` competes with the row's tap.

## Known holes / open
- **`enableTap` takes the label's tap from the row.** just_tooltip wraps the label in a `GestureDetector`, whose innermost recognizer wins: no `onNodeTap`, and a Child is not selected from its label; a tap beside the label still selects (measured 2026-10-20, `example/test/tooltip_behaviour_test.dart`). Upstream, here, or documented as intended: not decided. Tracked: #134.
- just_tooltip's shared `TooltipRegistry` shows one tooltip app-wide, so two controllers cannot show two tooltips at once. One controller for two Nodes still fails upstream's assertion; the dartdoc says not to.
