# Scroll anchoring

## What it is
Keeps what the user is looking at still when the content changes under the viewport: rows inserted or removed above it, a Scale change, or a bulk expand or collapse. The offset math is pure. The widget applies it.

## Governing decisions
**None.**

## Design model
- `ScrollAnchor` only computes offsets and never touches a controller. It returns `null` when nothing needs to move, with a 0.5 px threshold against churn.
- **Incremental change** (from `FlattenChange`): if the changed row's bottom edge is at or above the current offset, shift by `deltaItems × itemExtent`. Otherwise do nothing.
- **Scale change**: map the top fractional item index into the new item extent. The horizontal offset scales by the new/old `contentWidth` ratio. Applied post-frame, then the vertical bar is re-synced even if the offset did not move, because the extent changed.
- **Bulk change** (a new flat list without a `FlattenChange`, for example expand-all): anchor to the top node, or to its nearest surviving ancestor if the top node was removed. Skipped when either list is empty.
- All three run from `_FolderViewContentState.didUpdateWidget`.

## Code
- `lib/services/scroll_anchor.dart` — `ScrollAnchor.verticalOffsetForFlattenChange`, `ScrollAnchor.offsetsForScaleChange`, `ScrollAnchor.verticalOffsetForBulkChange`
- `lib/widgets/folder_view_content.dart` — `_FolderViewContentState._applyScaleAdjustment`, `_FolderViewContentState._applyScrollAdjustment`

## Reference behaviour
**None.**

## Cross-cutting invariants
None recorded.

## Blast radius
- [flattening](flattening.md) — when `FlattenChange` is emitted decides which branch runs.
- [scale](scale.md) — reads old and new `rowHeight`, `rowSpacing` and top padding from the scaled theme.
- [scroll-sync](scroll-sync.md) — every jump needs the matching bar re-sync.

## Known holes
- A mode switch does not anchor. The controllers are recreated at 0 ([scroll-sync](scroll-sync.md)). Whether that is intended is not recorded.
