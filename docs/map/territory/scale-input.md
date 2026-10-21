# Scale input (modifier + wheel)

## What it is
Turns the **Scale Modifier** held during a mouse-wheel scroll into a proposed **Scale** value for the caller, and optionally stops that wheel from also scrolling the list.

## Governing decisions
- [ADR-0002](../../adr/0002-caller-owns-interaction-state.md): the library proposes through `onScaleChanged`; the caller applies it.

## Design model
- **Blocking gates everything.** Blocking is in effect when `blockModifierScroll ?? (onScaleChanged != null)` is true. Only then does `FolderView` wrap the content in the `Listener` that proposes a Scale. So a proposal needs blocking **and** a non-null `onScaleChanged`. `blockModifierScroll: false` turns zoom-by-wheel off together with the block (pinned: "blockModifierScroll:false overrides a non-null onScaleChanged"), and `true` with no callback blocks the scroll and proposes nothing. The dartdoc, README and `GLOSSARY.md` each state this; a surface that describes only the callback is wrong in two of the six cases.
- While the modifier is down, the `Listener` catches each `PointerScrollEvent` and proposes `scale ± scaleStep` (default 0.05). The value is **not clamped**; the caller clamps.
- Blocking swaps the `ListView` physics to `_ModifierKeyAwareScrollPhysics`, which refuses user offsets while the modifier is pressed.
- **The block also covers both scrollbars (#114), by the maintainer's call at triage: Ctrl+wheel anywhere over the view zooms only.**
  - **How.** Each bar's scroll content is wrapped in `ModifierWheelGuard`, which receives the same `blockModifierScroll` value. While the modifier is pressed, the guard registers a no-op handler for the `PointerScrollEvent` with `pointerSignalResolver`. It sits deeper than the bar's `Scrollable`, so it registers first and wins: the bar never scrolls. The `FolderView` `Listener` uses plain `onPointerSignal`, so it still proposes.
  - **Why not the physics.** Measured: giving the bars `_ModifierKeyAwareScrollPhysics` blocked the wheel, but it also froze a thumb drag made while holding Ctrl (offset 0 against 661). The bar's drag also asks `shouldAcceptUserOffset`.
  - **Why the guard is translucent.** The bar's content is a childless `SizedBox`, which is never hit, so a guard deferring to its child would never receive the event.
  - **Pinned** by `test/widgets/folder_view_modifier_wheel_scrollbar_test.dart`: the rows and both bars while blocked, `false`, no modifier, and a Ctrl thumb drag.
- A caller's own `Listener` around `FolderView` (the README's `isScaleModifierPressed()` recipe) still receives the event while blocking is on, but no longer scrolls the list along with it. Probed on 2026-10-19 with Ctrl+wheel 200 px over a 40-row list: without blocking, the outer listener fired once **and** the list scrolled 200 px. With `blockModifierScroll: true`, it fired once and the offset stayed at 0.
- The block holds under smooth wheel scrolling (#100): `Scrollable` asks `physics.shouldAcceptUserOffset` before it claims a wheel event, so a refused notch never reaches `SmoothScrollController.pointerScroll` (read from SDK 3.47.1; pinned by the scale-gesture tests, which settle after each notch).
- Modifier: Meta on macOS, Control elsewhere. Meta is ignored off macOS because a Windows-key key-up can be lost, which would leave the flag stuck.

## Code
- `lib/widgets/folder_view.dart` — `_FolderViewState._handlePointerSignalForScale`, `_FolderViewState._blockModifierScroll`
- `lib/widgets/folder_view_content.dart` — `_ModifierKeyAwareScrollPhysics`
- `lib/widgets/modifier_wheel_guard.dart` — `ModifierWheelGuard`
- `lib/input/scale_modifier.dart` — `isScaleModifierPressed`

## Reference behaviour
**None.**

## Cross-cutting invariants
None recorded.

## Blast radius
- [scale](scale.md) — the consumer of the proposed value (through the caller).
- [scroll-sync](scroll-sync.md) — physics on the main vertical list.
- [tap-and-selection](tap-and-selection.md) — Control has a second meaning there: Ctrl+tap is an immediate single tap. `CustomInkWell` checks the Control keys on every platform, including macOS, where the Scale Modifier is Meta.

## Known holes
- The direction test is `scrollDelta.dy > 0 ? −step : +step`, so a modifier-scroll with `dy == 0` proposes a zoom **in**. A purely horizontal delta, such as a trackpad sideways swipe, has `dy == 0`. Read from the code; not probed.
