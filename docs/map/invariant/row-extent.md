# A row's extent is rowHeight + rowSpacing

## The fact
Every rendered row is exactly `rowHeight + rowSpacing` tall, with its content centred in that height. `rowSpacing` is extra height on every row, not an empty gap between rows (maintainer, at triage, #118). So the list's total extent is `n × (rowHeight + rowSpacing)` plus vertical content padding, and every site that converts between pixels and rows must use the same unit.

## Why it is cross-cutting
The unit is recomputed at each site from the theme, `theme.rowHeight + theme.rowSpacing`, with no shared helper. `_FolderViewContentState.build` hands it to the `ListView` as `itemExtent`; `_rowsAnchorOffset` and `_applyScaleAdjustment` compute it again for `ScrollAnchor`; `SizeService.calculateContentHeight` computes its own total, `n × (rowHeight + rowSpacing)` plus padding, for the scrollbars and for `needsVerticalScroll`. None calls the others. `NodeWidget` asks for `rowHeight` and is overridden by the `itemExtent`, and `TreeLinesPainter` follows by reading the size it paints. A site that drifts produces rows, anchors and bars that disagree, with no error.

## Territories it holds in
- [tier-rendering](../territory/tier-rendering.md) — `NodeWidget`'s `SizedBox(height: rowHeight)` is overridden by the `itemExtent`.
- [tree-lines](../territory/tree-lines.md) — `TreeLinesPainter` uses half its own size, so it follows the extent (#118).
- [scroll-anchoring](../territory/scroll-anchoring.md) — `_rowsAnchorOffset` and `_applyScaleAdjustment` convert offsets in units of the extent.
- [row-geometry](../territory/row-geometry.md) — `SizeService.calculateContentHeight` totals the same unit.
- [scrollbars](../territory/scrollbars.md) — the vertical bar's scroll content is `contentHeight` tall.

## What a violation looks like
`calculateContentHeight` once used the gap formula, `n × rowHeight + (n−1) × rowSpacing + padding`, one `rowSpacing` less than the list's extent (#157). At `rowSpacing` 8, a list overflowing its view by 4 px got no vertical bar. A bar relaid out at its own end sat 8 px short of the list: 1648 / 1640 (list / bar, 40 rows, 2026-11-07), and `ScrollbarController`, which reports the list's end, then lost a notch that should have reached an enclosing page. Pinned by `test/widgets/folder_view_scrollbar_wheel_test.dart`.

Before #118, the tree-lines painter drew at `rowHeight / 2`: at `rowHeight` 40 and `rowSpacing` 10 the stub sat at y 20 against a label centred at y 25.

## Discovery history
- #118 — the connector stub was off-centre with `rowSpacing > 0`. The fix made the painter read its own size and settled what `rowSpacing` means.
- Map rebuild, 2026-10-25 — reading `SizeService.calculateContentHeight` beside the `itemExtent` found the gap-era formula still in place. #157 fixed it, with #171.

## Where it will recur
Any code that converts between a pixel offset and a row index, sizes something to the list's height, or draws within a row: an "ensure visible" scroll, a sticky header, a drag-and-drop drop indicator, a row overlay. Test: does it compute `rowHeight + rowSpacing` itself, or read the row's laid-out size? If it uses `rowHeight` alone, or spacing between rows, it is subject to this.
