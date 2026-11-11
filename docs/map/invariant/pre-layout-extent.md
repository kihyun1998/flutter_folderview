# A scroll extent read before layout is the old one

## The fact
In `didUpdateWidget`, and anywhere else in the build phase, a `ScrollPosition`'s `maxScrollExtent` and `viewportDimension` still describe the last layout, not the content and viewport this frame will lay out. A jump made there takes its end from the new content height (`FolderViewContent.contentHeight`, which `SizeService.calculateContentHeight` computes over the new flat list), minus the viewport, not from the position. A controller that follows the jump, clamping to its own extent, is clamped to its old end, so it is re-synced after the frame's layout.

## Why it is cross-cutting
Four sites move or clamp a scroll offset around a content change:
- `_FolderViewContentState._applyScrollAdjustment`, incremental branch: runs in `didUpdateWidget`, clamps to the end of `contentHeight`, then calls `_syncVerticalBarAfterLayout`.
- The same method, bulk branch: the same, through `ScrollAnchor.verticalOffsetForBulkChange`.
- `_FolderViewContentState._applyScaleAdjustment`: defers the whole computation to a post-frame callback, so the extents it reads there are already the new ones, and re-syncs the bar in the same callback with its own copy of the re-sync.
- `_SyncedScrollControllersState._jumpToNoCascade`: mirrors a jump to the paired controller clamped to that controller's extent. Called during a build, that extent is the old one, which is why the anchor sites re-sync the bar after layout.

The two anchor branches share a method and the bar re-sync. The Scale path and the mirror are separate code that holds the same assumption. All three anchor paths take the end from the new content (checked by reading, 2026-11-11, #176).

The `viewportDimension` the two `didUpdateWidget` branches read is still the old one. It differs from the new one when the view's own height changes in the same frame, or when the horizontal bar comes or goes in it; the bar depends on `contentWidth > availableWidth` in `_FolderViewState.build`, so on the data, the Scale, the theme and the width. An incremental change keeps the same `data` and theme, so the bar does not change with one. Probed on the Windows target, 60 Parents of 20 Children, 2026-11-11, and no case moved the rows where they could have stayed:
- A bulk change that brought the bar in (400×300): the rows stayed still.
- A bulk change that took it away: the body and the bar both ended on the true end, the rows moving by the 16 px the view grew at the bottom.
- An expand at the end in the same frame as the height going 500 → 300: 49100 → 49900, the rows still. Going 300 → 500: 49300 → 49900, the true end; the target computed from the old viewport was 50100, and layout corrected it.

## Territories it holds in
- [scroll-anchoring](../territory/scroll-anchoring.md) — the incremental and bulk anchors run before layout.
- [scroll-sync](../territory/scroll-sync.md) — the mirror clamps to the follower's extent, whatever layout it last had.

## What a violation looks like
The incremental anchor clamped to the position's `maxScrollExtent`. Expanding a Parent of 20 rows of 40 above the view, 60 Parents in a 400×300 view on the Windows target, left 49300 when scrolled to the end and also 100 from it, where keeping the rows still needs 50100 and 50000 (new end 50100). The rows in view moved down by 800 and 700, and the vertical bar stayed with the body at 49300. With the new end but no bar re-sync, those two cases fail on the bar (#176, 2026-11-11). Without the bar re-sync, a bulk expand from the end left 77300 / 6100 (body / bar; 2026-11-07, `flutter_smooth_wheel_scroll` 0.1.6).

## Discovery history
- The bulk branch's post-frame bar re-sync, already in place when the map was built: the bar reports the old end before layout.
- #176 — the incremental branch clamped to the old end; it now computes the new one as the bulk branch does.

## Where it will recur
Any jump or clamp made in the build phase in response to new data or a new theme: an "ensure visible" scroll, keeping a selection in view, restoring an offset. Test: does it read `maxScrollExtent` or `viewportDimension` from a position before the frame's layout? If so, it sees the old content.
