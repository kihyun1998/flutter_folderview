# Two-axis scrolling and scrollbars

## What it is
Scrolls the content vertically and horizontally while keeping the vertical `ListView` fully virtualized, and drives two custom scrollbars from mirrored controllers. Horizontal scroll is not a scroll view around the list. Each row is shifted individually.

## Governing decisions
- [ADR-0001](../../adr/0001-scrollbars-excluded-from-scale.md): scrollbars are chrome and keep their physical size at every Scale.

## Design model
- Four controllers: main vertical, vertical bar, main horizontal and horizontal bar. Each main/bar pair mirrors the other through `_jumpToNoCascade`, which uses a one-shot flag so that a mirrored jump does not bounce back.
- **Wheel input is animated on the main controllers only** (#100). Both are `SmoothScrollController`s from `flutter_smooth_wheel_scroll`, moving as `WheelMotion.spring()`, as in `flutter_table_plus`. The bar controllers stay plain and follow by `jumpTo`, once per frame of a motion. The main horizontal one receives no wheel input: its `Scrollable` is zero-height, and Shift+wheel over the vertical `ListView` reads `dx` (read from the code). It is converted for parity.
- **`FolderView.wheelMotion` picks the motion** (#101), defaulting to `WheelMotion.spring()`. `null` is a zero-duration spring, which upstream hands to `ScrollController`'s own `pointerScroll`. So `null` is the same code path, not a branch, and the main controllers are always `SmoothScrollController`s. A change swaps the motion on the existing controllers in `didUpdateWidget`, because recreating them resets the offset. A View Mode change still recreates them.
- Horizontal scroll: a hidden, zero-height `SingleChildScrollView` holds `horizontalController` so it has a `ScrollPosition`. Its offset feeds a `ValueNotifier`, and each row wraps in `OverflowBox` → `Transform.translate(-offset)` → `SizedBox(contentWidth)`. Only visible rows rebuild on a horizontal scroll. When `contentWidth` fits the viewport, the wrapper is skipped entirely.
- **The order is a hit-testing requirement (#136).** `RenderTransform` passes a point to its child without checking its own size. So the translate must sit inside the viewport-wide `OverflowBox`: that box tests the untranslated point, and the content-wide `SizedBox` tests the translated one. With the translate outside, everything past the first viewport-width of a scrolled row took no input. The translate is also present at offset 0, as an identity, so the row's subtree keeps its State when the offset leaves 0. `test/widgets/folder_view_horizontal_hit_test.dart` pins both.
- A row's `RenderBox` is therefore `contentWidth` wide and translated left. Its rect extends past the viewport whenever the content is wider than the view ([row-wider-than-viewport](../invariant/row-wider-than-viewport.md)).
- `SyncedScrollControllers` is keyed by `ValueKey(mode)`, so a mode switch creates fresh controllers at offset 0.
- Scrollbars are shown on hover of the whole view. The platform scrollbars are suppressed with `ScrollConfiguration(scrollbars: false)`. When a horizontal bar is needed, a track-height spacer is reserved under the list.

## Code
- `lib/widgets/synced_scroll_controllers.dart` — `SyncedScrollControllers`, `_SyncedScrollControllersState._jumpToNoCascade`, `_SyncedScrollControllersState.didUpdateWidget`
- `lib/widgets/folder_view.dart` — `FolderView.wheelMotion`
- `lib/flutter_folderview.dart` — `WheelMotion` (re-export)
- `lib/widgets/folder_view_content.dart` — `_FolderViewContentState._buildItem`, `_FolderViewContentState._onHorizontalScroll`
- `lib/widgets/folder_view_vertical_scrollbar.dart` — `FolderViewVerticalScrollbar`
- `lib/widgets/folder_view_horizontal_scrollbar.dart` — `FolderViewHorizontalScrollbar`
- `lib/widgets/folder_view_scrollbar_thumb.dart` — `folderViewThumbTheme`
- `lib/themes/folder_view_scrollbar_theme.dart` — `FolderViewScrollbarTheme`

## Reference behaviour
The wheel path was read against `flutter_smooth_wheel_scroll` 0.1.3 (pub cache, raw) and the Flutter SDK 3.47.1 `scrollable.dart` for #100. It is **binding**: a wrong contract is fixed upstream, not worked around here. `flutter_table_plus`'s `SyncedScrollControllers` is the prior art (example, not binding).

The motion never passes an end, and that rests on upstream clamping twice: the target and every tick. Under `ClampingScrollPhysics` (the test default) Flutter's physics would stop it at the end anyway. Only under `BouncingScrollPhysics` (macOS) does a missing clamp show (measured: removing both upstream clamps overshoots by about 2 px on macOS and passes on the default).

## Cross-cutting invariants
- [row-wider-than-viewport](../invariant/row-wider-than-viewport.md) — the per-row translate is what puts a row's rect off screen.
- [chrome-excluded-from-scale](../invariant/chrome-excluded-from-scale.md) — `scrollbarTheme` is not delegated in `FlutterFolderViewTheme.scale`.

## Blast radius
- [scroll-anchoring](scroll-anchoring.md) — every programmatic `jumpTo` on a main controller must be followed by a bar re-sync once extents have settled.
- [label-tooltip](label-tooltip.md) and [row-card](row-card.md) — they place overlays against row and label rects, which the translate moves.
- [row-geometry](row-geometry.md) — `contentWidth` decides whether horizontal scroll exists at all.
- [scale-input](scale-input.md) — the `ListView` physics are swapped to block modifier-wheel scrolling.

## Known holes
- **Fixed in #122: a bar has one track, and its thumb stays in it.**
  - **Two tracks, before.** `trackColor`, `trackWidth` and `trackRadius` styled the `Container` the bar sits in, while `trackVisibility` turned on the Material `Scrollbar`'s own track inside it, in Material's colour (a `0x081D1B20` rect and a `0x1A1D1B20` edge line), never `trackColor`. `trackVisibility` is removed; the `Container` is the only track. Feeding `trackColor` into Material's track was rejected: the same colour over the same colour would have made the field a switch with almost no visible effect.
  - **The overflow, before.** With `thickness` 20 and `trackWidth` 8, the thumb's rect ran from x = −12 to 8 on Android, and from −14 on Windows. No clip sits above the bar.
  - **The margin is the trap.** Material places the thumb at `width − thickness − crossAxisMargin` (`widgets/scrollbar.dart`), and the margin is 0 on Android but 2 elsewhere (`material/scrollbar.dart`). The probe behind the decision ran on the test default, Android, so a cap at `trackWidth` alone would still have overflowed 2 px on desktop.
  - **The fix.** `folderViewThumbTheme` sets `crossAxisMargin` explicitly to Material's own platform default, and paints `min(thickness, trackWidth − margin)`, floored at 0. The value capped against is the value painted, and the default look is unchanged. The theme keeps the `thickness` it was given.
  - **The decisions.** Both are the maintainer's, at triage and at the confirm stop on 2026-10-21. The margin-aware cap was chosen once the margin finding was shown.
  - **Pinned** by `test/widgets/folder_view_scrollbar_track_test.dart`, through `FolderView`, on Android and Windows.
- **Not covered: iOS.** There Material's `Scrollbar` builds a `CupertinoScrollbar` from its own constructor arguments. The bars pass thickness, radius and thumb colour only through `ScrollbarThemeData`, so on iOS those three are ignored (read from the code, not probed).
- **A wheel turned over a scrollbar is not animated.** The bar is its own `Scrollable` with a plain controller. Upstream documents the same limit.
- **A notch during a programmatic `jumpTo` is lost.** Scroll anchoring's post-frame `jumpTo` (expand/collapse, Scale change) ends a running motion, and the remaining distance of that notch goes with it. Read from the code, not probed.
