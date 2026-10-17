# Two-axis scrolling and scrollbars

## What it is
Scrolls the content vertically and horizontally while keeping the vertical `ListView` fully virtualized, and drives two custom scrollbars from mirrored controllers. Horizontal scroll is not a scroll view around the list. Each row is shifted individually.

## Governing decisions
- [ADR-0001](../../adr/0001-scrollbars-excluded-from-scale.md): scrollbars are chrome and keep their physical size at every Scale.

## Design model
- Four controllers: main vertical, vertical bar, main horizontal and horizontal bar. Each main/bar pair mirrors the other through `_jumpToNoCascade`, which uses a one-shot flag so that a mirrored jump does not bounce back.
- **Wheel input is animated on the main controllers only** (#100). Both are `SmoothScrollController`s from `flutter_smooth_wheel_scroll`, moving as `WheelMotion.spring()`, as in `flutter_table_plus`. The bar controllers stay plain and follow by `jumpTo`, once per frame of a motion. The main horizontal one receives no wheel input: its `Scrollable` is zero-height, and Shift+wheel over the vertical `ListView` reads `dx` (read from the code). It is converted for parity.
- Horizontal scroll: a hidden, zero-height `SingleChildScrollView` holds `horizontalController` so it has a `ScrollPosition`. Its offset feeds a `ValueNotifier`, and each row wraps in `OverflowBox` → `SizedBox(contentWidth)` → `Transform.translate(-offset)`. Only visible rows rebuild on a horizontal scroll. When `contentWidth` fits the viewport, the wrapper is skipped entirely.
- A row's `RenderBox` is therefore `contentWidth` wide and translated left. Its rect extends past the viewport whenever the content is wider than the view ([row-wider-than-viewport](../invariant/row-wider-than-viewport.md)).
- `SyncedScrollControllers` is keyed by `ValueKey(mode)`, so a mode switch creates fresh controllers at offset 0.
- Scrollbars are shown on hover of the whole view. The platform scrollbars are suppressed with `ScrollConfiguration(scrollbars: false)`. When a horizontal bar is needed, a track-height spacer is reserved under the list.

## Code
- `lib/widgets/synced_scroll_controllers.dart` — `SyncedScrollControllers`, `_SyncedScrollControllersState._jumpToNoCascade`
- `lib/widgets/folder_view_content.dart` — `_FolderViewContentState._buildItem`, `_FolderViewContentState._onHorizontalScroll`
- `lib/widgets/folder_view_vertical_scrollbar.dart` — `FolderViewVerticalScrollbar`
- `lib/widgets/folder_view_horizontal_scrollbar.dart` — `FolderViewHorizontalScrollbar`
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
- **A wheel turned over a scrollbar is not animated.** The bar is its own `Scrollable` with a plain controller. Upstream documents the same limit.
- **A notch during a programmatic `jumpTo` is lost.** Scroll anchoring's post-frame `jumpTo` (expand/collapse, Scale change) ends a running motion, and the remaining distance of that notch goes with it. Read from the code, not probed.
- The `_buildItem` comment on `Transform.translate` is duplicated verbatim, a leftover of an edit. Cosmetic.
