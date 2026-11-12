# Wheel motion

## What it is
How a mouse-wheel notch moves the view: animated by default, or at once. `FolderView.wheelMotion` picks the motion, and the two main scroll controllers carry it out. The distance a notch travels is app-wide and not set here.

## Governing decisions
**None.** The calls are recorded in CHANGELOG 0.12.0 (#100, #101), not in a record.

## Design model
Read from `SyncedScrollControllers` and `FolderView.wheelMotion`'s dartdoc.
- **Only the main controllers animate** (#100). Both are `SmoothScrollController`s from `flutter_smooth_wheel_scroll`, defaulting to `WheelMotion.spring()`, as in `flutter_table_plus`. The bar controllers run no motion and follow by `jumpTo` on every frame of one ([scroll-sync](scroll-sync.md)).
- **A wheel over a bar is handed to the main controller of that axis** (#168; maintainer's choice at triage, 2026-11-06, shown the table below). Upstream's `ScrollbarController` (`flutter_smooth_wheel_scroll` 0.1.6, #171) calls the main position's `pointerScroll`, so a motion has one owner and every notch adds to one target. A bar that is itself a `SmoothScrollController` was rejected: each mirrored `jumpTo` ends the other side's motion. Measured 2026-11-06 (Flutter 3.41.9, upstream 0.1.3, 400 ms spring), 120 px then 120 px during the motion:

  | Order | Plain bar (before) | Smooth bar | Hand-off |
  |---|---|---|---|
  | Over the body, then the bar | 130.9 | 120 | 240 |
  | Over the bar, then the body | 240 | 120 | 240 |

- Flutter still decides whether to deliver a wheel over a bar from the **bar's** physics and pixels, and from the end its position reports (`Scrollable._receivedPointerSignal`, `RawScrollbar._receivedPointerSignal`). `ScrollbarController` then asks the **main** position's physics before it hands over, and a wheel they refuse moves nothing and leaves the platform's default action allowed ([scale-input](scale-input.md)). A Shift+wheel over the horizontal bar arrives through a `Listener` around it instead ([scrollbars](scrollbars.md)).
- **A wheel ends what the bar is running, then hands over** (#171). Without that, a track tap's animation mirrors a `jumpTo` to the main controller on each tick, which ends the motion the notch just started. Measured 2026-11-07 (Flutter 3.47.1, 400 ms spring, 500 rows), a track tap and a notch of 60 two frames later: the private hand-off settled at 227.2 with the notch lost, `ScrollbarController` at 108.7. Removing `goIdle` from a copy of upstream killed the track-tap tests on both axes.
- **A bar's end is the main position's end** (#171). `ScrollbarController` overrides `maxScrollExtent`, so a notch at the end reaches an enclosing scroll view through the main position. A bar relaid out at its own shorter end stays short of what it reports, which is why the content heights must agree ([row-extent](../invariant/row-extent.md)). With them equal, removing the override from a copy of upstream killed no test here (2026-11-07).
- **A press or a track tap on a bar stops the motion** (#168). `ScrollbarController`'s position ends the main controller's motion first, in `hold` and `animateTo`. Without that, each tick of the motion mirrors a `jumpTo` to the bar, which cancels the drag or the tap's animation, and the view runs on to the wheel's target. A drag needs no stop of its own: `hold` comes first. Removing the stop from `hold` in a copy of upstream killed both thumb-drag tests, and from `animateTo` the track-tap test (2026-11-07).
- A wheel with no main client goes to the bar's own position (upstream README, 0.1.6). `FolderView` builds the `ListView` and the hidden horizontal view whenever a bar exists, so this is not reached there, and no test covers it.
- A wheel during a thumb drag moves nothing, before and after the hand-off: 1674.2 stayed 1674.2 through a 120 px notch (probed 2026-11-06, Windows target). The horizontal bar's Shift `Listener` keeps this by ignoring the wheel while a pointer is pressed on the bar; a Shift notch during a thumb drag ended the drag without that (#169).
- The main horizontal controller's `Scrollable` is the zero-height hidden one ([scroll-sync](scroll-sync.md)), so all its wheel input arrives from the horizontal bar.
- **`null` is the same code path, not a branch** (#101). `_motion` turns `null` into a zero-duration spring, which upstream hands to `ScrollController`'s own wheel path, so the main controllers are always `SmoothScrollController`s.
- **A change at runtime keeps the position.** `didUpdateWidget` swaps `motion` on the existing controllers, because recreating them resets the offset. A View Mode change still recreates them ([scroll-sync](scroll-sync.md)).
- Only the wheel is animated. Trackpad scrolling, dragging a scrollbar, and the Scale anchor's jump move the view at once and stop a motion in progress (`FolderView.wheelMotion` dartdoc). An expand or collapse anchor during a motion shifts the motion's position and target instead, so it settles at its old target plus the rows added or removed ([scroll-anchoring](scroll-anchoring.md), #195).
- The notch distance is app-wide, through `SmoothWheelBinding`, which this package does not install. The barrel re-exports `WheelMotion` alone ([release](release.md)).
- The modifier-scroll block holds under motion over the rows: `Scrollable` asks `physics.shouldAcceptUserOffset` before it claims a wheel event, so a refused notch never reaches `SmoothScrollController.pointerScroll` ([scale-input](scale-input.md); read from SDK 3.47.1 for #100). Over a bar, the block holds through `ScrollbarController`'s physics check ([scale-input](scale-input.md)).

## Code
- `lib/widgets/synced_scroll_controllers.dart` — `SyncedScrollControllers.wheelMotion`, `_SyncedScrollControllersState._motion`, `_SyncedScrollControllersState._instant`, `_SyncedScrollControllersState.didUpdateWidget`, `_SyncedScrollControllersState._initControllers` (the `ScrollbarController` of each bar)
- `lib/widgets/folder_view.dart` — `FolderView.wheelMotion`
- `lib/flutter_folderview.dart` — `WheelMotion` (re-export)

## Reference behaviour
Read against `flutter_smooth_wheel_scroll` 0.1.3 (pub cache, raw) and the Flutter SDK 3.47.1 `scrollable.dart` for #100, against the 0.1.6 archive's `scrollbar_controller.dart` and README for #171, and against 0.1.7's `smooth_scroll_controller.dart` (`correctBy`, `_WheelMotionActivity.shift` and `applyNewDimensions`) for #195. **Binding**: a wrong contract is fixed upstream, not worked around here. Route in [`thegraph.md`](../../agents/thegraph.md).

The motion never passes an end because upstream clamps twice, the target and every tick. Under `ClampingScrollPhysics` (the test default) Flutter's physics would stop it anyway; only under `BouncingScrollPhysics` (macOS) does a missing clamp show: removing both upstream clamps overshot by about 2 px on macOS and passed on the default (measured, #100).

## Cross-cutting invariants
None recorded.

## Blast radius
- [scroll-sync](scroll-sync.md) — the main controllers are this territory's; their followers receive a jump per frame.
- [scrollbars](scrollbars.md) — a wheel over a bar arrives here, and a press on a bar stops the motion.
- [scroll-anchoring](scroll-anchoring.md) — its incremental and bulk anchors shift a running motion through `correctBy`; its Scale jump ends one.
- [scale-input](scale-input.md) — the block must refuse a notch before the motion starts.
- [dependency-floor](dependency-floor.md) — `flutter_smooth_wheel_scroll` sets the SDK floor.
- [example](example.md) — the "Smooth wheel" feature (#102) is where the maintainer feels the motion before a release.

## Known holes / open
- **`ScrollbarController` throws while its main controller has two positions.** `_body` checks `hasClients` and then reads `position`. `FolderView` no longer puts the rows' `ListView` through that state ([scale-input](scale-input.md)). A body controller that holds two positions for any other reason would throw during the bar's layout. Probed through the `Listener` toggle on the 0.1.6 code, 2026-11-07, in a debug test; a throwaway guard in a copy of upstream cleared it. Tracked upstream: flutter_smooth_wheel_scroll#35. `position` ends in `_positions.single`, so a release build would throw too: read from the SDK, not run.
- **An inertia cancel over a bar whose thumb has faded in does not stop a motion.** `RawScrollbar` jumps the bar only. Probed on the macOS target, 2026-11-06, a 600 px notch cancelled at 54.6: over the body it stayed at 54.6; over the bar it ran on to 600. It takes a trackpad touched during a mouse wheel's motion.
- **A notch during the Scale anchor's jump is lost.** A Scale change jumps in a post-frame callback, which ends a running motion, and the remaining distance of that notch goes with it. Read from the code, not probed. The expand and collapse half was fixed in #195 by `correctBy`. It does not carry over as is. `shift` moves the target by the same delta, while a Scale change maps an offset by the ratio of row extents; whether a motion's remaining distance should keep its pixels or its rows is not decided. A post-frame `correctBy` would carry a wheel motion, whose next tick sets the shifted position and notifies, but not a fling, whose next tick writes its absolute value back before any layout reads the correction (read from upstream 0.1.7 `_tick` and SDK 3.47.1 `BallisticScrollActivity._tick`, not probed). `flutter_table_plus` also jumps post-frame on a Scale change.
