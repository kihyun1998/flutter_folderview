# Wheel motion

## What it is
How a mouse-wheel notch moves the view: animated by default, or at once. `FolderView.wheelMotion` picks the motion, and the two main scroll controllers carry it out. The distance a notch travels is app-wide and not set here.

## Governing decisions
**None.** The calls are recorded in CHANGELOG 0.12.0 (#100, #101), not in a record.

## Design model
Read from `SyncedScrollControllers` and `FolderView.wheelMotion`'s dartdoc.
- **Only the main controllers animate** (#100). Both are `SmoothScrollController`s from `flutter_smooth_wheel_scroll`, defaulting to `WheelMotion.spring()`, as in `flutter_table_plus`. The bar controllers run no motion and follow by `jumpTo` on every frame of one ([scroll-sync](scroll-sync.md)).
- **A wheel over a bar is handed to the main controller of that axis** (#168; maintainer's choice at triage, 2026-11-06, shown the table below). `_ScrollbarPosition.pointerScroll` calls the main position's, so a motion has one owner and every notch adds to one target. A bar that is itself a `SmoothScrollController` was rejected: each mirrored `jumpTo` ends the other side's motion. Measured 2026-11-06 (Flutter 3.41.9, upstream 0.1.3, 400 ms spring), 120 px then 120 px during the motion:

  | Order | Plain bar (before) | Smooth bar | Hand-off |
  |---|---|---|---|
  | Over the body, then the bar | 130.9 | 120 | 240 |
  | Over the bar, then the body | 240 | 120 | 240 |

- Flutter still decides whether to deliver a wheel over a bar from the **bar's** physics, pixels and extents (`Scrollable._receivedPointerSignal`, `RawScrollbar._receivedPointerSignal`). The main controller's physics is not asked on the hand-off, so the modifier block over a bar rests on `ModifierWheelGuard` ([scale-input](scale-input.md)).
- **A press or a track tap on a bar stops the motion** (#168). `_ScrollbarPosition.hold` and `animateTo` end the main controller's motion first. Without that, each tick of the motion mirrors a `jumpTo` to the bar, which cancels the drag or the tap's animation, and the view runs on to the wheel's target. A drag needs no stop of its own: `hold` comes first (removing either one alone from `hold` and `drag` killed no test; removing both did, 2026-11-06).
- A wheel with no main client does nothing. `FolderView` builds the `ListView` and the hidden horizontal view whenever a bar exists, so this is not reached there, and no test covers it.
- A wheel during a thumb drag moves nothing, before and after the hand-off: 1674.2 stayed 1674.2 through a 120 px notch (probed 2026-11-06, Windows target).
- The main horizontal controller's `Scrollable` is the zero-height hidden one ([scroll-sync](scroll-sync.md)), so all its wheel input arrives from the horizontal bar.
- **`null` is the same code path, not a branch** (#101). `_motion` turns `null` into a zero-duration spring, which upstream hands to `ScrollController`'s own wheel path, so the main controllers are always `SmoothScrollController`s.
- **A change at runtime keeps the position.** `didUpdateWidget` swaps `motion` on the existing controllers, because recreating them resets the offset. A View Mode change still recreates them ([scroll-sync](scroll-sync.md)).
- Only the wheel is animated. Trackpad scrolling, dragging a scrollbar, and scroll anchoring's jumps move the view at once and stop a motion in progress (`FolderView.wheelMotion` dartdoc).
- The notch distance is app-wide, through `SmoothWheelBinding`, which this package does not install. The barrel re-exports `WheelMotion` alone ([release](release.md)).
- The modifier-scroll block holds under motion over the rows: `Scrollable` asks `physics.shouldAcceptUserOffset` before it claims a wheel event, so a refused notch never reaches `SmoothScrollController.pointerScroll` ([scale-input](scale-input.md); read from SDK 3.47.1 for #100). Over a bar, see the hole in [scale-input](scale-input.md).

## Code
- `lib/widgets/synced_scroll_controllers.dart` — `SyncedScrollControllers.wheelMotion`, `_SyncedScrollControllersState._motion`, `_SyncedScrollControllersState._instant`, `_SyncedScrollControllersState.didUpdateWidget`, `_ScrollbarController`, `_ScrollbarPosition.pointerScroll`, `_ScrollbarPosition.hold`, `_ScrollbarPosition.animateTo`
- `lib/widgets/folder_view.dart` — `FolderView.wheelMotion`
- `lib/flutter_folderview.dart` — `WheelMotion` (re-export)

## Reference behaviour
Read against `flutter_smooth_wheel_scroll` 0.1.3 (pub cache, raw) and the Flutter SDK 3.47.1 `scrollable.dart` for #100. **Binding**: a wrong contract is fixed upstream, not worked around here. Route in [`thegraph.md`](../../agents/thegraph.md).

The motion never passes an end because upstream clamps twice, the target and every tick. Under `ClampingScrollPhysics` (the test default) Flutter's physics would stop it anyway; only under `BouncingScrollPhysics` (macOS) does a missing clamp show: removing both upstream clamps overshot by about 2 px on macOS and passed on the default (measured, #100).

## Cross-cutting invariants
None recorded.

## Blast radius
- [scroll-sync](scroll-sync.md) — the main controllers are this territory's; their followers receive a jump per frame.
- [scrollbars](scrollbars.md) — a wheel over a bar arrives here, and a press on a bar stops the motion.
- [scroll-anchoring](scroll-anchoring.md) — its `jumpTo` ends a running motion.
- [scale-input](scale-input.md) — the block must refuse a notch before the motion starts.
- [dependency-floor](dependency-floor.md) — `flutter_smooth_wheel_scroll` sets the SDK floor.
- [example](example.md) — the "Smooth wheel" feature (#102) is where the maintainer feels the motion before a release.

## Known holes / open
- **An inertia cancel over a bar whose thumb has faded in does not stop a motion.** `RawScrollbar` jumps the bar only. Probed on the macOS target, 2026-11-06, a 600 px notch cancelled at 54.6: over the body it stayed at 54.6; over the bar it ran on to 600. It takes a trackpad touched during a mouse wheel's motion.
- **A notch during a programmatic `jumpTo` is lost.** Scroll anchoring's post-frame `jumpTo` (expand/collapse, Scale change) ends a running motion, and the remaining distance of that notch goes with it. Read from the code, not probed.
