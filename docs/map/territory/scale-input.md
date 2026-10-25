# Scale input (modifier + wheel)

## What it is
Turns the **Scale Modifier** held during a mouse-wheel scroll into a proposed **Scale** value for the caller, and stops that wheel from also scrolling the list or a scrollbar.

## Governing decisions
- [ADR-0002](../../adr/0002-caller-owns-interaction-state.md): the library proposes through `onScaleChanged`; the caller applies it.

## Design model
Read from `_FolderViewState`, `_ModifierKeyAwareScrollPhysics` and `ModifierWheelGuard`.
- **Blocking gates everything.** Blocking is in effect when `blockModifierScroll ?? (onScaleChanged != null)` (`_blockModifierScroll`). Only then does `FolderView` wrap the content in the `Listener` that proposes. So a proposal needs blocking **and** a non-null `onScaleChanged`: `false` turns zoom-by-wheel off together with the block, and `true` with no callback blocks the scroll and proposes nothing (#112). The dartdoc, README and `GLOSSARY.md` each state this; a surface that describes only the callback is wrong in two of the six cases.
- While the modifier is down, the `Listener` proposes `scale ± scaleStep` (default 0.05) per `PointerScrollEvent`. The value is **not clamped**; the caller clamps.
- Blocking swaps the `ListView` physics to `_ModifierKeyAwareScrollPhysics`, which refuses user offsets while the modifier is pressed. The refusal comes before a smooth motion starts ([wheel-motion](wheel-motion.md)).
- **The block also covers both scrollbars (#114): Ctrl+wheel anywhere over the view zooms only** (maintainer, at triage, #114).
  - **How.** Each bar's scroll content is wrapped in `ModifierWheelGuard` with the same `blockModifierScroll`. While the modifier is pressed, the guard registers a no-op handler with `pointerSignalResolver`. It sits deeper than the bar's `Scrollable`, so it registers first and wins. The `FolderView` `Listener` uses plain `onPointerSignal`, so it still proposes.
  - **Why not the physics.** Giving the bars `_ModifierKeyAwareScrollPhysics` blocked the wheel but also froze a thumb drag made while holding Ctrl (offset 0 against 661, measured, #114): the bar's drag also asks `shouldAcceptUserOffset`.
  - **Why translucent.** The bar's content is a childless `SizedBox`, which is never hit, so a guard deferring to its child would never receive the event.
  - Pinned by `test/widgets/folder_view_modifier_wheel_scrollbar_test.dart`: the rows and both bars while blocked, `false`, no modifier, and a Ctrl thumb drag.
- A caller's own `Listener` around `FolderView` (the README's `isScaleModifierPressed()` recipe) still receives the event while blocking is on, and the list no longer scrolls along with it: with Ctrl+wheel 200 px over a 40-row list, unblocked the outer listener fired once **and** the list scrolled 200 px; with `blockModifierScroll: true` it fired once and the offset stayed 0 (probed 2026-10-19).
- **Modifier**: Meta on macOS, Control elsewhere (`isScaleModifierPressed`). Meta is ignored off macOS because a Windows-key key-up can be lost, leaving the flag stuck.

## Code
- `lib/widgets/folder_view.dart` — `_FolderViewState._handlePointerSignalForScale`, `_FolderViewState._blockModifierScroll`, `FolderView.onScaleChanged`, `FolderView.scaleStep`, `FolderView.blockModifierScroll`
- `lib/widgets/folder_view_content.dart` — `_ModifierKeyAwareScrollPhysics`
- `lib/widgets/modifier_wheel_guard.dart` — `ModifierWheelGuard`
- `lib/input/scale_modifier.dart` — `isScaleModifierPressed`

## Reference behaviour
**None.**

## Cross-cutting invariants
None recorded.

## Blast radius
- [scale](scale.md) — the consumer of the proposed value (through the caller).
- [scroll-sync](scroll-sync.md) — the physics on the main vertical list.
- [scrollbars](scrollbars.md) — the guard sits inside each bar.
- [wheel-motion](wheel-motion.md) — a refused notch must never reach the smooth controller.
- [taps](taps.md) — Control has a second meaning there: Ctrl+tap is an immediate single tap. `CustomInkWell` checks the Control keys on every platform, including macOS, where the Scale Modifier is Meta.

## Known holes / open
- The direction test is `scrollDelta.dy > 0 ? −step : +step`, so a modifier-scroll with `dy == 0` proposes a zoom **in**. A purely horizontal delta, such as a trackpad sideways swipe, has `dy == 0`. Read from the code; not probed.
