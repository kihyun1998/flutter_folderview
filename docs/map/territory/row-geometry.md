# Row geometry and width measurement

## What it is
Works out how wide and tall the content is. Every row is laid out at one `contentWidth`, which is the widest row across the whole tree regardless of expansion, and at a fixed height. The width is measured once from the scaled theme, before any row is built. If the measurement falls short of what a row actually draws, the label is cut with an ellipsis instead of the view gaining a horizontal scroll.

## Governing decisions
**None.**

[ADR-0001](../../adr/0001-scrollbars-excluded-from-scale.md) and [ADR-0004](../../adr/0004-tooltips-excluded-from-scale.md) decide what is excluded from Scale. They do not decide how content is measured.

## Design model
- `RowMetrics` is the one formula: row width = indent(depth) + expand strip + tier icon box + measured label + right content padding. The renderers read the label (`RowMetrics.label`), its style (`effectiveTextStyle`), the indent and the strip from the same object, so those match by construction.
- `maxWidth` walks **all** nodes, including collapsed ones, so expanding never changes `contentWidth`. It adds the left content padding once.
- Re-measured in `build` whenever any input it was measured from differs: the `data` instance, the *effective* theme instance (from `theme:` or an ancestor `FolderViewTheme`), `scale`, or the ambient `bodyMedium` (by value).
- `SizeService.clampContentWidth` caps the width at 3× the viewport. It is not re-multiplied by Scale. Rows wider than the cap ellipsize.
- Height is O(1): `itemCount × rowHeight + (itemCount−1) × rowSpacing + vertical padding`. The `ListView` uses a fixed `itemExtent`.
- Label widths are cached in a **static** map keyed by label, `fontSize`, `fontWeight` and `letterSpacing`. The map is never cleared, and its key does not include `fontFamily` or `fontStyle`.

## Code
- `lib/services/row_metrics.dart` — `RowMetrics.maxWidth`, `RowMetrics.measureNodeWidth`, `RowMetrics.label`, `RowMetrics.effectiveTextStyle`, `RowMetrics.iconBoxWidth`, `RowMetrics.expandStripWidth`, `RowMetrics._textWidthCache`
- `lib/services/size_service.dart` — `SizeService.clampContentWidth`, `SizeService.calculateContentHeight`
- `lib/widgets/folder_view.dart` — `_FolderViewState._precomputedMaxWidth`, `_FolderViewState._measuredTheme`, `_FolderViewState._measuredBaseStyle`

## Reference behaviour
**None.**

## Cross-cutting invariants
- [measured-equals-rendered](../invariant/measured-equals-rendered.md) — this territory is the "measured" half.
- [row-wider-than-viewport](../invariant/row-wider-than-viewport.md) — `contentWidth` is the source of the width.

## Blast radius
- [tier-rendering](tier-rendering.md) — anything a renderer draws that widens a row must be measured here, and vice versa.
- [scroll-sync](scroll-sync.md) — `contentWidth > viewport` is what turns on horizontal scroll and the per-row translate.
- [scale](scale.md) — a Scale change is one of the four re-measure inputs.
- [theme-composition](theme-composition.md) — the effective theme's identity is a trigger, however the theme arrives.
- [label-tooltip](label-tooltip.md) — whether a label is ellipsized decides the rect a `child`-anchored tooltip aims at.

## Known holes
- **`selectedTextStyle` is not measured.** It is merged at render time (for example, bold on a selected Child) and never measured, a remaining case of [measured-equals-rendered](../invariant/measured-equals-rendered.md). Read from the code; not probed.
- The static cache key omits `fontFamily`, so two tiers that differ only in font family share a cached width. Read from the code; not probed.
- [view-mode-projection](view-mode-projection.md): tree mode is measured at folder-mode depths.
