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
- Defaults that differ from the row card, on purpose: `interactive: false`, `enableTap: false`, fade animation, `screenMargin: 8`. `enableTap` is this package's field; `wrapWithNodeTooltip` maps it to upstream's `tap`, `true` to `TooltipTap.observe` and `false` to `TooltipTap.none`. They are literals in `wrapWithNodeTooltip` (`8.0`, `0xFF616161`, `150ms`, …), not theme defaults: the place to look when a default "does not change".
- **A controller is per Node** (#133). `controllerResolver: JustTooltipController? Function(Node<T>)`, shaped like `tooltipBuilderResolver`, replaced the single `controller`: one controller on a Tier theme attached to every built label of the Tier, and just_tooltip 0.4.4's `attach` asserts `_target == null`, so the second label threw in debug and the last one built won in release. BREAKING in 0.12.0, by the maintainer's call at triage, 2026-10-21, over deprecating the field alongside the resolver or documenting it as single-Node. Upstream detaches and reattaches on a controller change and applies a `show()` queued while detached, so a show for an unbuilt row lands when it is built. Pinned by `test/widgets/node_tooltip_controller_test.dart`.
- **`hideOnEmptyMessage` was removed in 0.12.0** (#131, maintainer's call). It could not act: with no builder and an empty message the wrapper is skipped, a builder always counts as content, and `JustTooltip`'s constructor asserts `message != null || tooltipBuilder != null`. Re-adding it means first deciding what an empty bubble is for; it would also hide the row card.
- **A label tap toggles the tooltip and reaches the row** (#134). The maintainer chose the fix at triage, 2026-10-21: an opt-in upstream (just_tooltip's #66), over driving the tooltip from the row's tap here, which collides with one controller per tooltip and moves trigger logic out of just_tooltip, or documenting the stolen tap, which is at odds with ADR-0003. `TooltipTap.observe` enters the gesture arena and gives it up on release, so a drag from a label scrolls and toggles nothing, and a secondary tap toggles nothing. Pinned by `test/widgets/node_tooltip_tap_test.dart`.
  - A screen reader's tap goes to the row; `claim` gave it an action that opened the tooltip. The message is heard with the label. When a builder supplies the content nothing is heard (`wrapWithNodeTooltip` sends `message: null`), and that tooltip can no longer be reached by a screen reader's tap. Probed 2026-11-06 with a semantics tap: before, the tooltip opened and no callback fired; after, `onNodeTap` fired, no tooltip opened, and the node kept the tooltip text. The maintainer confirmed the consequence at the confirm stop, 2026-11-06.
- With `interactive: false`, the body is transparent to the pointer from `just_tooltip 0.5.0`: a tap on it reaches the row beneath, and content inside it cannot be clicked.
- **A screen reader hears `message` on the label** from `just_tooltip 0.5.1`: `wrapWithNodeTooltip` passes neither `semanticsTooltip` nor `excludeFromSemantics`, so upstream puts the message on the label's semantics node. A builder-only tooltip is not heard. `NodeTooltipTheme` exposes neither field.
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
- [taps](taps.md) — a label tap with `enableTap` reaches the row as well.

## Known holes / open
- **What `onNodeTap` does to the view can leave the label tooltip behind.** Since #134 a label tap reaches the caller while its tooltip opens. Each probed 2026-11-06, `enableTap` on, comparing the tree before and after #134:
  - `onNodeTap` removes the tapped row: the tooltip then shows the next Node's content (`tip c2` for a tap on c1). Rows have no key, so the label's State stays at its index. A tap beside a label that collapses a Parent showed another Node's tooltip before #134 too (`tip z1`).
  - Its row is torn down: `onHide` does not fire. A tap on a Child then on a collapsing Parent's label counted show/hide 2/0. A resolver that returns `null` once a Child is selected counted 1/0, and the tooltip was never seen.
  - `onNodeTap` opens a dialog or pushes a page: the tooltip is open during it and after the pop. Whether it draws over the dialog was not measured.
  - `controller.show()` inside `onNodeTap` is undone on a label tap, because the row's tap comes first and the toggle after: show/hide 1/1, closed. Beside the label it stays open. Tracked: #172.
- just_tooltip's shared `TooltipRegistry` shows one tooltip app-wide, so two controllers cannot show two tooltips at once. One controller for two Nodes still fails upstream's assertion; the dartdoc says not to.
