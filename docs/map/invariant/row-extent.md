# A row's extent is rowHeight + rowSpacing

## The fact
Every rendered row is exactly `rowHeight + rowSpacing` tall, with its content centred in that height. `rowSpacing` is extra height on every row, not an empty gap between rows (maintainer, at triage, #118). So the list's total extent is `n × (rowHeight + rowSpacing)` plus vertical content padding, and every site that converts between pixels and rows must use the same unit.

## Why it is cross-cutting
The unit is recomputed at each site from the theme, `theme.rowHeight + theme.rowSpacing`, with no shared helper. `_FolderViewContentState.build` hands it to the `ListView` as `itemExtent`; `_applyScrollAdjustment` and `_applyScaleAdjustment` compute it again for `ScrollAnchor`; `SizeService.calculateContentHeight` computes its own total for the scrollbars and for `needsVerticalScroll`. None calls the others. `NodeWidget` asks for `rowHeight` and is overridden by the `itemExtent`, and `TreeLinesPainter` follows by reading the size it paints. A site that drifts produces rows, anchors and bars that disagree, with no error.

## Territories it holds in
- [tier-rendering](../territory/tier-rendering.md) — `NodeWidget`'s `SizedBox(height: rowHeight)` is overridden by the `itemExtent`.
- [tree-lines](../territory/tree-lines.md) — `TreeLinesPainter` uses half its own size, so it follows the extent (#118).
- [scroll-anchoring](../territory/scroll-anchoring.md) — `_applyScrollAdjustment` and `_applyScaleAdjustment` convert offsets in units of the extent.
- [row-geometry](../territory/row-geometry.md) — `SizeService.calculateContentHeight` counts `rowSpacing` n−1 times: **it disagrees**.
- [scrollbars](../territory/scrollbars.md) — the vertical bar's scroll content is `contentHeight` tall.

## What a violation looks like
Since #118 one site still disagrees. `calculateContentHeight` returns `n × rowHeight + (n−1) × rowSpacing + padding`, one `rowSpacing` less than the list's extent. With `rowSpacing > 0`, the vertical bar's extent is one `rowSpacing` short of the list's, so the list can scroll past where the bar's mirror clamps; and a list that overflows its view by less than `rowSpacing` gets no vertical bar at all (`needsVerticalScroll` is false). Read from the code; not probed. Not intended (maintainer, 2026-10-25). With `rowSpacing` 0 the sites agree. Tracked: #157.

Before #118, the tree-lines painter drew at `rowHeight / 2`: at `rowHeight` 40 and `rowSpacing` 10 the stub sat at y 20 against a label centred at y 25.

## Discovery history
- #118 — the connector stub was off-centre with `rowSpacing > 0`. The fix made the painter read its own size and settled what `rowSpacing` means.
- Map rebuild, 2026-10-25 — reading `SizeService.calculateContentHeight` beside the `itemExtent` found the gap-era formula still in place. No test covers `calculateContentHeight` (`test/services/size_service_test.dart` tests only the width clamp).

## Where it will recur
Any code that converts between a pixel offset and a row index, sizes something to the list's height, or draws within a row: an "ensure visible" scroll, a sticky header, a drag-and-drop drop indicator, a row overlay. Test: does it compute `rowHeight + rowSpacing` itself, or read the row's laid-out size? If it uses `rowHeight` alone, or spacing between rows, it is subject to this.
