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

- **A row's State follows its Node** (#172). Rows are keyed by `Node.id` with a `findChildIndexCallback` ([node-id-identity](../invariant/node-id-identity.md)). A key on `NodeWidget` alone was rejected: the sliver still matched by index, so a per-Node controller was handed between labels and `assert(_target == null)` fired on a removal, a collapse and an insertion. Pinned by `test/widgets/node_row_identity_test.dart`. A rebuild that replaces every row in one frame still hands a controller over, see Known holes.
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
- [node-id-identity](../invariant/node-id-identity.md) — the tooltip and its controller follow the row's Node.

## Blast radius
- [row-card](row-card.md) — narrowing or widening this hover region moves where the card is reachable.
- [dependency-floor](dependency-floor.md) — placement, suppression and controller behaviour ride the resolved `just_tooltip`.
- [tier-rendering](tier-rendering.md) — `NodeLabel`'s layout is the hover region.
- [taps](taps.md) — a label tap with `enableTap` reaches the row as well.

## Known holes / open
- **What `onNodeTap` does to the view can still leave the label tooltip in a state nobody chose** (#172; maintainer's choices, 2026-11-07, each shown the measured table and the options below). Probed 2026-11-07, `enableTap` on, Flutter 3.47.1, just_tooltip 0.5.1:
  - A row removed or collapsed away while its tooltip is shown: `onHide` does not fire (show/hide 1/0, and 2/0 for a tap on a Child then on a collapsing Parent's label). just_tooltip's `deactivate` closes the overlay at once and `onHide` fires only when the reverse animation is dismissed; Flutter's own tooltip fires nothing on dispose either. Chosen: document it on `NodeTooltipTheme.onHide`. Rejected: having just_tooltip fire `onHide` on teardown, because a synchronous call breaks a `setState` in `onHide` and a microtask reorders it after the next tooltip's `onShow` (a review's probe of a just_tooltip copy, not reproduced here).
  - `onNodeTap` opens a dialog or pushes a page: the tooltip is open during it and after the pop. Whether it draws over the dialog was not measured. Chosen: document it on `enableTap`, and leave closing to just_tooltip (tracked upstream: just_tooltip#100). Closing it here needs a controller of this package's own, which #134 rejected and which collides with `controllerResolver`.
  - `controller.show()` inside `onNodeTap` is undone on a label tap, because the row's tap comes first and the toggle after: show/hide 1/1, closed. Deferred with `scheduleMicrotask`, it opens a closed tooltip; an open one still closes (1 to 0), because just_tooltip ignores `show()` during the reverse animation. Chosen: document it on `enableTap`, and report the reverse case upstream (just_tooltip#101).
  - A `tooltipBuilderResolver` that returns `null` once a Child is selected: the label tap fires `onShow` and nothing is seen (show/hide 1/0). Traced 2026-11-08 with prints in a just_tooltip copy: the tap's toggle runs before the rebuild, while the content is still there, so `_show` and `onShow` run; next frame `wrapWithNodeTooltip` returns no wrapper and just_tooltip's `deactivate` closes it without `onHide`. The same as the removed-row case above, so it is documented on `NodeTooltipTheme.onHide` (#182, maintainer's choice 2026-11-08). Calling `onShow` only after the first frame fixed it in a copy of just_tooltip (0/0) and moved every `onShow` one frame later; proposed upstream: just_tooltip#103.
- **A rebuild that replaces every row in one frame hands a per-Node controller over.** A View Mode switch (`ValueKey(widget.mode)`) and a flip of `needsHorizontalScroll` (the row gains or loses its `OverflowBox`) build new labels while the old ones are only deactivated. just_tooltip attaches a controller in `initState` and detaches it in `dispose`, so `assert(_target == null)` fires and that controller's `show()` then shows nothing. Probed 2026-11-07 (view 400 to 30 wide, and tree to folder), the same before and after #172's row keys. Tracked upstream: just_tooltip#102.
- just_tooltip's shared `TooltipRegistry` shows one tooltip app-wide, so two controllers cannot show two tooltips at once. One controller for two Nodes still fails upstream's assertion; the dartdoc says not to.
