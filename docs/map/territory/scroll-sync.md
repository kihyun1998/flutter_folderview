# Two-axis scroll sync

## What it is
Scrolls the content vertically and horizontally while keeping the vertical `ListView` fully virtualized. Four controllers are paired so the list and each scrollbar move together, and horizontal scroll is applied per row, not by a scroll view around the list. The bars themselves are [scrollbars](scrollbars.md); how a wheel notch moves the main controllers is [wheel-motion](wheel-motion.md).

## Governing decisions
**None.**

## Design model
Read from `SyncedScrollControllers` and `_FolderViewContentState`.
- **Four controllers**: main vertical, vertical bar, main horizontal and horizontal bar. Each main/bar pair mirrors the other through `_jumpToNoCascade`, which clamps to the follower's extent and sets a one-shot flag (`_doNotReissueJump`) so a mirrored jump does not bounce back.
- **Horizontal scroll is per row.** A hidden, zero-height `SingleChildScrollView` holds `horizontalController` so it has a `ScrollPosition`. Its offset feeds a `ValueNotifier` (`_onHorizontalScroll`), and each row wraps in `OverflowBox` → `ValueListenableBuilder` → `Transform.translate(-offset)` → `SizedBox(contentWidth)` (`_buildItem`). Only visible rows rebuild on a horizontal scroll. When `contentWidth` fits the viewport (`needsHorizontalScroll` false), the wrapper is skipped entirely.
- **The order is a hit-testing requirement (#136).** `RenderTransform` passes a point to its child without checking its own size, so the translate must sit inside the viewport-wide `OverflowBox`: that box tests the untranslated point, and the content-wide `SizedBox` tests the translated one. With the translate outside, everything past the first viewport-width of a scrolled row took no input (CHANGELOG 0.12.0: in a 400 px view scrolled by 300, a tap at x 320 worked and at 500 did nothing). The translate is present at offset 0 too, as an identity, so a row's subtree keeps its State when the offset leaves 0. Pinned by `test/widgets/folder_view_horizontal_hit_test.dart`.
- A row's `RenderBox` is therefore `contentWidth` wide and translated left; its rect extends past the viewport whenever the content is wider than the view ([row-wider-than-viewport](../invariant/row-wider-than-viewport.md)).
- **A View Mode switch replaces all four controllers**, because `SyncedScrollControllers` is keyed by `ValueKey(widget.mode)`, so both offsets start at 0. Intended: the two modes render different row lists (maintainer, 2026-10-25).
- The platform scrollbars are suppressed with `ScrollConfiguration(scrollbars: false)`; the view draws its own ([scrollbars](scrollbars.md)).

## Code
- `lib/widgets/synced_scroll_controllers.dart` — `SyncedScrollControllers`, `_SyncedScrollControllersState._syncScrollControllers`, `_SyncedScrollControllersState._jumpToNoCascade`
- `lib/widgets/folder_view_content.dart` — `_FolderViewContentState._buildItem`, `_FolderViewContentState._onHorizontalScroll`, `_FolderViewContentState.build`
- `lib/widgets/folder_view.dart` — `_FolderViewState.build` (the `ValueKey(widget.mode)`)

## Reference behaviour
`flutter_table_plus`'s `SyncedScrollControllers` is the prior art (an example, not binding; route in [`thegraph.md`](../../agents/thegraph.md)).

## Cross-cutting invariants
- [row-wider-than-viewport](../invariant/row-wider-than-viewport.md) — the per-row translate is what puts a row's rect off screen.

## Blast radius
- [scroll-anchoring](scroll-anchoring.md) — every programmatic `jumpTo` on a main controller must be followed by a bar re-sync once extents have settled; the mirror alone clamps to a stale extent.
- [scrollbars](scrollbars.md) — each bar is driven by its paired controller, and the bar's extent comes from the same `contentWidth`/`contentHeight`.
- [wheel-motion](wheel-motion.md) — the main controllers are `SmoothScrollController`s, so a mirrored follower receives a `jumpTo` on every frame of a motion.
- [label-tooltip](label-tooltip.md) and [row-card](row-card.md) — they place overlays against row and label rects, which the translate moves.
- [taps](taps.md) — a tap reaches a row only where the `OverflowBox` order lets hit testing reach it.
- [row-geometry](row-geometry.md) — `contentWidth` decides whether horizontal scroll exists at all.
- [scale-input](scale-input.md) — the `ListView` physics are swapped to block modifier-wheel scrolling.

## Known holes / open
**None** found by this reading.
