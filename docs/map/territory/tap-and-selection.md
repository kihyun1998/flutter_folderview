# Tap, double tap, secondary tap and Selection

## What it is
Turns pointer taps on a row into the caller's callbacks (`onNodeTap`, `onDoubleNodeTap`, `onSecondaryNodeTap`) and paints the Selection state the caller supplies. Which gestures a row receives depends on its tier.

## Governing decisions
- [ADR-0002](../../adr/0002-caller-owns-interaction-state.md): the **Selected Set** is caller-owned. Taps propose; the caller applies.
- [ADR-0003](../../adr/0003-selection-is-tier-bound-to-child.md): Selection is tier-bound to Child.

## Design model
- `CustomInkWell` fires `onTap` immediately on the first tap and arms a `clickInterval` timer. A second tap inside the window fires `onDoubleTap`. A double tap therefore emits both, on purpose, so single-tap feedback is never delayed. Ctrl+tap is always an immediate single tap, and so is every tap when `onDoubleTap` is null: a row with no double-tap handler has no window (#95). `ChildNodeRenderer` passes `null` through when `FolderView.onDoubleNodeTap` is null, so the absence reaches `CustomInkWell` instead of being hidden behind a wrapper closure.
- **Per tier.** A Child row gets `onTap`, `onDoubleTap`, `onSecondaryTap`, `ChildNodeTheme.clickInterval` and the selection colours. A Folder or Parent row gets `onTap` and `onSecondaryTap`, with `clickInterval: 0` and `onDoubleTap: null`. The secondary route is how ADR-0003 lets a caller track a focused container.
- Ink is hoisted: `FolderViewContent` supplies one transparent `Material` above the list, and rows paint onto it. A `CustomInkWell` outside that ancestor asserts, by design. A per-row `Material` was measurably slower under scroll.
- Rows are wrapped in `ExcludeFocus`, so there is no keyboard focus or navigation.

## Code
- `lib/widgets/custom_ink_well.dart` — `CustomInkWell`, `_CustomInkWellState._handleTap`
- `lib/widgets/child_node_renderer.dart` — `ChildNodeRenderer`
- `lib/widgets/expandable_node_renderer.dart` — `ExpandableNodeRenderer`
- `lib/themes/child_node_theme.dart` — `ChildNodeTheme.clickInterval`, `ChildNodeTheme.selectedBackgroundColor`, `ChildNodeTheme.selectedTextStyle`
- `lib/widgets/folder_view_content.dart` — `_FolderViewContentState.build`

## Reference behaviour
**None.**

## Cross-cutting invariants
None recorded.

## Blast radius
- [tier-rendering](tier-rendering.md) — the renderers decide what reaches `CustomInkWell`.
- [row-card](row-card.md) — a card over a row must not steal its taps. Hit testing is depth-first, so an ancestor `GestureDetector` cannot take a child `InkWell`'s tap ([lessons](../../agents/lessons.md), #51).
- [row-geometry](row-geometry.md) — `selectedTextStyle` changes what is drawn but is not measured.
- [scale-input](scale-input.md) — Control is also the Scale Modifier off macOS.

## Known holes
- `onDoubleNodeTap` is Child-only by construction: container rows pass `onDoubleTap: null`, which since #95 means no double-tap window. The `clickInterval: 0` they also pass has had no effect since then. Its dartdoc says so. No record decides it.
- **Probed on 2026-09-23 (the lens read on #95): swapping `onDoubleNodeTap` at runtime.** Set-then-removed and removed-then-set between two taps both give `[tap, tap]`. Removing it and setting it back within the window, with no tap in between, keeps the first tap's count, so the second tap is a double: `[tap, dbl]`. Flutter's `GestureDetector` would drop that state, because it registers no double-tap recognizer while the callback is null. Reachable only by flipping the handler twice inside 300 ms, so it is left as is. The fix, if it ever matters, is to reset the count in `didUpdateWidget` when `onDoubleTap` changes to or from null.
