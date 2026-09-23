# Scale input (modifier + wheel)

## What it is
Turns the **Scale Modifier** held during a mouse-wheel scroll into a proposed **Scale** value for the caller, and optionally stops that wheel from also scrolling the list.

## Governing decisions
- [ADR-0002](../../adr/0002-caller-owns-interaction-state.md): the library proposes through `onScaleChanged`; the caller applies it.

## Design model
- Only active when `onScaleChanged` is non-null. A `Listener` catches `PointerScrollEvent` while the modifier is down and proposes `scale ± scaleStep` (default 0.05). The value is **not clamped**; the caller clamps.
- `blockModifierScroll` defaults to following `onScaleChanged`. Blocking swaps the `ListView` physics to `_ModifierKeyAwareScrollPhysics`, which refuses user offsets while the modifier is pressed.
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
- The direction test is `scrollDelta.dy > 0 ? −step : +step`, so a modifier-scroll with `dy == 0` proposes a zoom **in**. A purely horizontal delta, such as a trackpad sideways swipe, has `dy == 0`. Read from the code; not probed.
