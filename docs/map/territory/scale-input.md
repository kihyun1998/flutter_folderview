# Scale input (modifier + wheel)

## What it is
Turns the **Scale Modifier** held during a mouse-wheel scroll into a proposed **Scale** value for the caller, and optionally stops that wheel from also scrolling the list.

## Governing decisions
- [ADR-0002](../../adr/0002-caller-owns-interaction-state.md): the library proposes through `onScaleChanged`; the caller applies it.

## Design model
- **Blocking gates everything.** Blocking is in effect when `blockModifierScroll ?? (onScaleChanged != null)` is true. Only then does `FolderView` wrap the content in the `Listener` that proposes a Scale. So a proposal needs blocking **and** a non-null `onScaleChanged`. `blockModifierScroll: false` turns zoom-by-wheel off together with the block (pinned: "blockModifierScroll:false overrides a non-null onScaleChanged"), and `true` with no callback blocks the scroll and proposes nothing. The dartdoc, README and `GLOSSARY.md` each state this; a surface that describes only the callback is wrong in two of the six cases.
- While the modifier is down, the `Listener` catches each `PointerScrollEvent` and proposes `scale ± scaleStep` (default 0.05). The value is **not clamped**; the caller clamps.
- Blocking swaps the `ListView` physics to `_ModifierKeyAwareScrollPhysics`, which refuses user offsets while the modifier is pressed.
- A caller's own `Listener` around `FolderView` (the README's `isScaleModifierPressed()` recipe) still receives the event while blocking is on, but no longer scrolls the list along with it. Probed on 2026-10-19 with Ctrl+wheel 200 px over a 40-row list: without blocking, the outer listener fired once **and** the list scrolled 200 px. With `blockModifierScroll: true`, it fired once and the offset stayed at 0.
- The block holds under smooth wheel scrolling (#100): `Scrollable` asks `physics.shouldAcceptUserOffset` before it claims a wheel event, so a refused notch never reaches `SmoothScrollController.pointerScroll` (read from SDK 3.47.1; pinned by the scale-gesture tests, which settle after each notch).
- Modifier: Meta on macOS, Control elsewhere. Meta is ignored off macOS because a Windows-key key-up can be lost, which would leave the flag stuck.

## Code
- `lib/widgets/folder_view.dart` — `_FolderViewState._handlePointerSignalForScale`, `_FolderViewState._blockModifierScroll`
- `lib/widgets/folder_view_content.dart` — `_ModifierKeyAwareScrollPhysics`
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
- **Probed on 2026-10-19: the block does not reach the vertical scrollbar.** Setup: a 400×160 view of 40 rows, `onScaleChanged` set, Ctrl held, and a 300 px wheel. Over the rows the offset stayed at 0 and one Scale was proposed. Over the vertical scrollbar (3 px from the right edge) the offset moved to 300 **and** a second Scale was proposed. The scrollbar is its own `SingleChildScrollView` with default physics, so `_ModifierKeyAwareScrollPhysics` never sees that notch. The `Listener` wraps the whole content, so it still proposes. The docs scope the block to the rows (#114).
- The direction test is `scrollDelta.dy > 0 ? −step : +step`, so a modifier-scroll with `dy == 0` proposes a zoom **in**. A purely horizontal delta, such as a trackpad sideways swipe, has `dy == 0`. Read from the code; not probed.
