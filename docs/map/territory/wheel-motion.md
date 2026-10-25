# Wheel motion

## What it is
How a mouse-wheel notch moves the view: animated by default, or at once. `FolderView.wheelMotion` picks the motion, and the two main scroll controllers carry it out. The distance a notch travels is app-wide and not set here.

## Governing decisions
**None.** The calls are recorded in CHANGELOG 0.12.0 (#100, #101), not in a record.

## Design model
Read from `SyncedScrollControllers` and `FolderView.wheelMotion`'s dartdoc.
- **Only the main controllers animate** (#100). Both are `SmoothScrollController`s from `flutter_smooth_wheel_scroll`, defaulting to `WheelMotion.spring()`, as in `flutter_table_plus`. The bar controllers stay plain `ScrollController`s and follow by `jumpTo` on every frame of a motion ([scroll-sync](scroll-sync.md)).
- The main horizontal controller receives no wheel input of its own: its `Scrollable` is the zero-height hidden one ([scroll-sync](scroll-sync.md)). It is a `SmoothScrollController` for parity (#100).
- **`null` is the same code path, not a branch** (#101). `_motion` turns `null` into a zero-duration spring, which upstream hands to `ScrollController`'s own wheel path, so the main controllers are always `SmoothScrollController`s.
- **A change at runtime keeps the position.** `didUpdateWidget` swaps `motion` on the existing controllers, because recreating them resets the offset. A View Mode change still recreates them ([scroll-sync](scroll-sync.md)).
- Only the wheel is animated. Trackpad scrolling, dragging a scrollbar, and scroll anchoring's jumps move the view at once and stop a motion in progress (`FolderView.wheelMotion` dartdoc).
- The notch distance is app-wide, through `SmoothWheelBinding`, which this package does not install. The barrel re-exports `WheelMotion` alone ([release](release.md)).
- The modifier-scroll block holds under motion: `Scrollable` asks `physics.shouldAcceptUserOffset` before it claims a wheel event, so a refused notch never reaches `SmoothScrollController.pointerScroll` ([scale-input](scale-input.md); read from SDK 3.47.1 for #100).

## Code
- `lib/widgets/synced_scroll_controllers.dart` — `SyncedScrollControllers.wheelMotion`, `_SyncedScrollControllersState._motion`, `_SyncedScrollControllersState._instant`, `_SyncedScrollControllersState.didUpdateWidget`
- `lib/widgets/folder_view.dart` — `FolderView.wheelMotion`
- `lib/flutter_folderview.dart` — `WheelMotion` (re-export)

## Reference behaviour
Read against `flutter_smooth_wheel_scroll` 0.1.3 (pub cache, raw) and the Flutter SDK 3.47.1 `scrollable.dart` for #100. **Binding**: a wrong contract is fixed upstream, not worked around here. Route in [`thegraph.md`](../../agents/thegraph.md).

The motion never passes an end because upstream clamps twice, the target and every tick. Under `ClampingScrollPhysics` (the test default) Flutter's physics would stop it anyway; only under `BouncingScrollPhysics` (macOS) does a missing clamp show: removing both upstream clamps overshot by about 2 px on macOS and passed on the default (measured, #100).

## Cross-cutting invariants
None recorded.

## Blast radius
- [scroll-sync](scroll-sync.md) — the main controllers are this territory's; their followers receive a jump per frame.
- [scroll-anchoring](scroll-anchoring.md) — its `jumpTo` ends a running motion.
- [scale-input](scale-input.md) — the block must refuse a notch before the motion starts.
- [dependency-floor](dependency-floor.md) — `flutter_smooth_wheel_scroll` sets the SDK floor.
- [example](example.md) — the "Smooth wheel" feature (#102) is where the maintainer feels the motion before a release.

## Known holes / open
- **A wheel turned over a scrollbar is not animated.** The bar is its own `Scrollable` with a plain controller. Upstream documents the same limit.
- **A notch during a programmatic `jumpTo` is lost.** Scroll anchoring's post-frame `jumpTo` (expand/collapse, Scale change) ends a running motion, and the remaining distance of that notch goes with it. Read from the code, not probed.
