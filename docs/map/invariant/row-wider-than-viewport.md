# A row can be wider than the viewport

## The fact
Every rendered row is laid out at `contentWidth`, the widest row in the tree up to 3× the viewport. It is then shifted by the horizontal offset. Once `contentWidth > viewportWidth`, a row's rect, and a long label's rect inside it, extends past the visible area. **Anything positioned against a row's or label's rect aims at a point that may be off screen.** The pointer is the only position guaranteed to be inside the view.

## Why it is cross-cutting
The width is decided in measurement, the shift in scrolling, and the consequence lands in overlays. The overlay code never calls the measurement or the scroll code. Each tooltip surface only sees a `RenderBox` and trusts its rect. No blast edge between the tooltip territories and the scrolling territory could carry the fact, because they share an assumption, not a call.

## Territories it holds in
- [row-geometry](../territory/row-geometry.md) — `RowMetrics.maxWidth` and `SizeService.clampContentWidth` produce the width.
- [scroll-sync](../territory/scroll-sync.md) — `_buildItem` sizes each row to `contentWidth` and translates it.
- [label-tooltip](../territory/label-tooltip.md) — a `child`-anchored tooltip aims at the label rect's centre. The `pointer` anchor is the opt-in escape.
- [row-card](../territory/row-card.md) — the anchor is fixed to `pointer` for this reason.

## What a violation looks like
A tooltip or overlay drawn far from the cursor, or outside the `FolderView` entirely. It only reproduces **after horizontal scrolling, with a label longer than the viewport**. At rest, with short labels, every rect-anchored overlay looks correct, which is why this was found three times rather than fixed once.

## Discovery history
- #42 — a label tooltip appeared at the row centre, far from the pointer. `NodeTooltipTheme.anchor` was added with `pointer` as an opt-in.
- #47 — a label tooltip was painted outside the view. The cause was first written as "the label is ellipsized"; the probe showed `didExceedMaxLines == false`, and the real condition was `contentWidth > viewportWidth`. It was fixed upstream by clip-aware placement (`just_tooltip 0.4.2`).
- #44/#45 — the row card. "What if the row is wider than the viewport?" was opened as a measurement task (#45) and closed because `flutter_table_plus` had already answered it with `anchor: pointer`.

Three discoveries, at three sites.

## Where it will recur
Any new code that positions something from a row's or label's `RenderBox`: a context menu, a drag preview, a highlight overlay, an "ensure visible" scroll target. It is subject to this fact when it reads `localToGlobal`/`size` of a row, or anchors a `just_tooltip`, and the tree can scroll horizontally. Use pointer coordinates (`TapDownDetails.globalPosition` is already one) or clip to the viewport.
