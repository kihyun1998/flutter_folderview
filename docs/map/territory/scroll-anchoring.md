# Scroll anchoring

## What it is
Keeps what the user is looking at still when the content changes under the viewport: rows inserted or removed above it, a Scale change, or a bulk expand or collapse. The offset math is pure; the widget applies it.

## Governing decisions
**None.**

## Design model
Read from `ScrollAnchor` and `_FolderViewContentState.didUpdateWidget`.
- `ScrollAnchor` only computes offsets and never touches a controller. It returns `null` when nothing needs to move; the Scale and bulk methods also return `null` for a move of 0.5 px or less, against churn. The incremental method has no threshold.
- **Incremental change** (from `FlattenChange`): if the changed row's bottom edge (`topPadding + (index + 1) × itemExtent`) is at or above the current offset, shift by `deltaItems × itemExtent`, clamped to `[0, newContentHeight − viewportHeight]`, the end of the **new** content ([pre-layout-extent](../invariant/pre-layout-extent.md)). Otherwise do nothing. Applied at once in `didUpdateWidget`, then the vertical bar is re-synced post-frame. Pinned by `test/widgets/folder_view_incremental_anchor_test.dart`.
- **Scale change**: map the top fractional item index into the new item extent; the horizontal offset scales by the new/old `contentWidth` ratio. Applied post-frame (a `jumpTo` during build would `setState` during build), then the vertical bar is re-synced even if the offset did not move, because the extent changed.
- **Bulk change** (a new flat list without a `FlattenChange`, for example expand-all): anchor to the top node, or to its nearest surviving ancestor if the top node was removed. Skipped when either list is empty. Clamped to the end of the new content, then the vertical bar is re-synced post-frame ([pre-layout-extent](../invariant/pre-layout-extent.md)). Pinned by `test/widgets/folder_view_scrollbar_wheel_test.dart`.
- All three read `itemExtent` as `rowHeight + rowSpacing` of the theme they are handed ([row-extent](../invariant/row-extent.md)).
- A View Mode switch does not anchor; the controllers are recreated at 0, by design ([scroll-sync](scroll-sync.md)).

## Code
- `lib/services/scroll_anchor.dart` — `ScrollAnchor.verticalOffsetForFlattenChange`, `ScrollAnchor.offsetsForScaleChange`, `ScrollAnchor.verticalOffsetForBulkChange`
- `lib/widgets/folder_view_content.dart` — `_FolderViewContentState._applyScaleAdjustment`, `_FolderViewContentState._applyScrollAdjustment`

## Reference behaviour
**None.**

## Cross-cutting invariants
- [pre-layout-extent](../invariant/pre-layout-extent.md) — the incremental and bulk anchors run before layout and compute the new end themselves.
- [row-extent](../invariant/row-extent.md) — the anchor math is in units of `rowHeight + rowSpacing`.
- [node-id-identity](../invariant/node-id-identity.md) — the bulk anchor finds the top Node by `id`.

## Blast radius
- [flattening](flattening.md) — when `FlattenChange` is emitted decides which branch runs.
- [scale](scale.md) — reads old and new `rowHeight`, `rowSpacing` and top padding from the scaled theme.
- [scroll-sync](scroll-sync.md) — every jump needs the matching bar re-sync.
- [wheel-motion](wheel-motion.md) — a jump ends a running wheel motion.

## Known holes / open
- **The Scale re-sync has no case that needs it.** Removing its `barController.jumpTo` in `_applyScaleAdjustment` left the same values at `rowSpacing` 0 and 8, mid-list and at the end (probed 2026-11-07). No test pins it.
- **A relayout without a rebuild applies the last incremental change again.** `_FolderViewState.build` computes the flatten result outside its `LayoutBuilder`, and the builder hands the same `FlattenChange` to `FolderViewContent` each time it runs. The incremental branch has no guard against an unchanged list, as the bulk branch has with `identical`. Expanding a Parent above the view at 20000 moved it to 20800; then changing only the view's height, 300 → 310, moved it to 21600 (probed 2026-11-11, Windows target, on main and on the #176 fix alike).
- **A collapse whose Children hold the view top lands above the Parent.** The incremental shift is `offset + deltaItems × itemExtent`, clamped, with no fallback to the collapsed row as the bulk branch falls back to the nearest surviving ancestor. Collapsing the Parent at row 10, 20 Children of 40, with the view top at 520 (its third Child), gives 520 − 800 → 0, where the Parent is at 400 (read from the code, 2026-11-11). Only a caller changing the Expanded Set can reach it: the Parent is above the view, so it cannot be tapped.
