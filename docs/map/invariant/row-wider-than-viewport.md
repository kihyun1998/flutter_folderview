# A row can be wider than the viewport

## The fact
Every rendered row is laid out at `contentWidth`, the widest row in the tree up to 3× the viewport. It is then shifted by the horizontal offset. Once `contentWidth > viewportWidth`, a row's rect, and a long label's rect inside it, extends past the visible area. **Anything positioned against a row's or label's raw rect aims at a point that may be off screen.** The pointer is the only position guaranteed to be inside the view.

The tooltips are not exposed to that, but to a milder form of it. just_tooltip anchors `TooltipAnchor.child` to the *visible* part of the child's rect, since 0.4.2. For a wide row that part spans the view, so a rect-anchored tooltip opens at the view's centre: on screen, but not where the user is looking. That is why the row card and the README's wide-label recipe use `TooltipAnchor.pointer` (#138). Code here that reads a row's rect directly still meets the off-screen form.

## Why it is cross-cutting
The width is decided in measurement, the shift in scrolling, and the consequence lands in overlays. The overlay code never calls the measurement or the scroll code. Each tooltip surface only sees a `RenderBox` and trusts its rect. No blast edge between the tooltip territories and the scrolling territory could carry the fact, because they share an assumption, not a call.

## Territories it holds in
- [row-geometry](../territory/row-geometry.md) — `RowMetrics.maxWidth` and `SizeService.clampContentWidth` produce the width.
- [scroll-sync](../territory/scroll-sync.md) — `_buildItem` sizes each row to `contentWidth` and translates it, inside the viewport-wide `OverflowBox`, so that the whole visible row stays hit-testable (#136).
- [taps](../territory/taps.md) — a tap reaches a row only where hit testing reaches it.
- [label-tooltip](../territory/label-tooltip.md) — a `child`-anchored tooltip aims at the label rect's centre. The `pointer` anchor is the opt-in escape.
- [row-card](../territory/row-card.md) — the anchor is fixed to `pointer` for this reason.
- [example](../territory/example.md) — the "A row wider than the viewport" scenario (#89) found #136 and pins the card beside the pointer on a scrolled wide row.

## What a violation looks like
A tooltip or overlay drawn far from the cursor, or outside the `FolderView` entirely. Or a part of the row that looks normal but takes no pointer input: any wrapper between the row and the list that is sized to the viewport must not sit inside the translate. It only reproduces **after horizontal scrolling, with a label longer than the viewport**. At rest, with short labels, every rect-anchored overlay looks correct, which is why this was found three times rather than fixed once.

A test that reproduces such a row goes through the public `FolderView`, not the internal `FolderViewContent`.

## Discovery history
- #42 — a label tooltip appeared at the row centre, far from the pointer. `NodeTooltipTheme.anchor` was added with `pointer` as an opt-in.
- #47 — a label tooltip was painted outside the view. The cause was first written as "the label is ellipsized"; the probe showed `didExceedMaxLines == false`, and the real condition was `contentWidth > viewportWidth`. It was fixed upstream by clip-aware placement (`just_tooltip 0.4.2`).
- #44/#45 — the row card. "What if the row is wider than the viewport?" was opened as a measurement task (#45) and closed because `flutter_table_plus` had already answered it with `anchor: pointer`.
- #136 — after horizontal scrolling, the visible part of a row past the first viewport-width took no tap and no hover. The row was painted shifted, but `Transform.translate` sat outside the viewport-wide `OverflowBox`: `RenderTransform` skips its own size check, and the `OverflowBox` rejected every point past its width. Found by the example's wide-row scenario (#89), when the row card did not open. Fixed by putting the translate inside the `OverflowBox`.

Four discoveries, at four sites. The first three were about where an overlay aims; the fourth was about whether the row is reachable at all.

## Where it will recur
Any new code that positions something from a row's or label's `RenderBox`: a context menu, a drag preview, a highlight overlay, an "ensure visible" scroll target. It is subject to this fact when it reads `localToGlobal`/`size` of a row, or anchors a `just_tooltip`, and the tree can scroll horizontally. Use pointer coordinates (`TapDownDetails.globalPosition` is already one) or clip to the viewport.
