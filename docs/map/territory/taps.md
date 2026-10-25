# Taps

## What it is
Turns pointer taps on a row into the caller's callbacks: `onNodeTap`, `onDoubleNodeTap` and `onSecondaryNodeTap`. Which gestures a row receives depends on its tier. What a tap does to the Selected Set is the caller's ([selection](selection.md)).

## Governing decisions
- [ADR-0002](../../adr/0002-caller-owns-interaction-state.md): taps propose; the caller applies.
- [ADR-0003](../../adr/0003-selection-is-tier-bound-to-child.md): the secondary tap on any tier is how a caller tracks a focused Folder or Parent.

## Design model
Read from `CustomInkWell` and the two renderers.
- `CustomInkWell` fires `onTap` immediately on the first tap and arms a `clickInterval` timer; a second tap inside the window fires `onDoubleTap`. A double tap therefore emits both, on purpose, so single-tap feedback is never delayed. Ctrl+tap (either Control key, on every platform) is always an immediate single tap, and so is every tap when `onDoubleTap` is null: a row with no double-tap handler has no window (#95). `ChildNodeRenderer` passes `null` through when `FolderView.onDoubleNodeTap` is null, so the absence reaches `CustomInkWell`.
- **Per tier.** A Child row gets `onTap`, `onDoubleTap`, `onSecondaryTap` and `ChildNodeTheme.clickInterval`. A Folder or Parent row gets `onTap` and `onSecondaryTap`, with `clickInterval: 0` and `onDoubleTap: null`. `onSecondaryNodeTap` reaches every tier since 0.11.3 (ADR-0003, note).
- Both renderers always pass `CustomInkWell` a non-null tap closure, so `onDoubleNodeTap` works without `onNodeTap`; `CustomInkWell` attaches no tap handler when its own `onTap` is null.
- **Ink is hoisted.** `FolderViewContent` supplies one transparent `Material` above the list, and rows paint onto it. A `CustomInkWell` outside that ancestor asserts, by design: a per-row `Material` was measurably slower under scroll (its comment in `CustomInkWell.build`).
- Rows are wrapped in `ExcludeFocus`, so there is no keyboard focus or navigation.

## Code
- `lib/widgets/custom_ink_well.dart` — `CustomInkWell`, `_CustomInkWellState._handleTap`
- `lib/widgets/child_node_renderer.dart` — `ChildNodeRenderer`
- `lib/widgets/expandable_node_renderer.dart` — `ExpandableNodeRenderer`
- `lib/widgets/folder_view.dart` — `FolderView.onNodeTap`, `FolderView.onDoubleNodeTap`, `FolderView.onSecondaryNodeTap`
- `lib/themes/child_node_theme.dart` — `ChildNodeTheme.clickInterval`
- `lib/widgets/folder_view_content.dart` — `_FolderViewContentState.build` (the shared `Material`)

## Reference behaviour
**None.**

## Cross-cutting invariants
- [row-wider-than-viewport](../invariant/row-wider-than-viewport.md) — a tap reaches a row only where hit testing reaches it.

## Blast radius
- [tier-rendering](tier-rendering.md) — the renderers decide what reaches `CustomInkWell`.
- [selection](selection.md) — a Child tap is the caller's usual cue to change the Selected Set.
- [label-tooltip](label-tooltip.md) — `enableTap` puts a tap recognizer inside the row's, and the innermost recognizer wins.
- [row-card](row-card.md) — a card over a row must not steal its taps. Hit testing is depth-first, so an ancestor `GestureDetector` cannot take a child `InkWell`'s tap ([lessons](../../agents/lessons.md), #51).
- [scroll-sync](scroll-sync.md) — the `OverflowBox` order decides where a scrolled row is hit.
- [scale-input](scale-input.md) — Control is also the Scale Modifier off macOS.

## Known holes / open
- `onDoubleNodeTap` is Child-only by construction: container rows pass `onDoubleTap: null`, which since #95 means no window. The `clickInterval: 0` they also pass has had no effect since then. No record decides it.
- **Swapping `onDoubleNodeTap` at runtime** (probed 2026-09-23, the lens read on #95). Set-then-removed and removed-then-set between two taps both give `[tap, tap]`. Removing it and setting it back within the window, with no tap in between, keeps the first tap's count, so the second tap is a double: `[tap, dbl]`. Flutter's `GestureDetector` would drop that state. Reachable only by flipping the handler twice inside 300 ms, so it is left as is; the fix, if it ever matters, is to reset the count in `didUpdateWidget` when `onDoubleTap` changes to or from null.
- `NodeTooltipTheme.enableTap` takes the label's tap from the row: no `onNodeTap` from the label (measured 2026-10-20, example). Where to fix it is not decided. Tracked: #134.
