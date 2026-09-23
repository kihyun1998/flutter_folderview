# Row geometry and width measurement

## What it is
Works out how wide and tall the content is. Every row is laid out at one `contentWidth`, which is the widest row across the whole tree regardless of expansion, and at a fixed height. The width is measured once from the scaled theme, before any row is built. If the measurement falls short of what a row actually draws, the label is cut with an ellipsis instead of the view gaining a horizontal scroll.

## Governing decisions
**None.**

[ADR-0001](../../adr/0001-scrollbars-excluded-from-scale.md) and [ADR-0004](../../adr/0004-tooltips-excluded-from-scale.md) decide what is excluded from Scale. They do not decide how content is measured.

## Design model
- `RowMetrics` is the one formula: row width = indent(depth) + expand strip + tier icon box + measured label + right content padding. `NodeWidget` builds from the same object, so the indent and strip widths match by construction.
- `maxWidth` walks **all** nodes, including collapsed ones, so expanding never changes `contentWidth`. It adds the left content padding once.
- Recomputed only when `_FolderViewState.didUpdateWidget` sees a new `data` instance, a new `scale`, or a new `theme` instance. Nothing else invalidates it.
- `SizeService.clampContentWidth` caps the width at 3× the viewport. It is not re-multiplied by Scale. Rows wider than the cap ellipsize.
- Height is O(1): `itemCount × rowHeight + (itemCount−1) × rowSpacing + vertical padding`. The `ListView` uses a fixed `itemExtent`.
- Label widths are cached in a **static** map keyed by label, `fontSize`, `fontWeight` and `letterSpacing`. The map is never cleared, and its key does not include `fontFamily` or `fontStyle`.

## Code
- `lib/services/row_metrics.dart` — `RowMetrics.maxWidth`, `RowMetrics.measureNodeWidth`, `RowMetrics.effectiveTextStyle`, `RowMetrics.iconBoxWidth`, `RowMetrics.expandStripWidth`, `RowMetrics._textWidthCache`
- `lib/services/size_service.dart` — `SizeService.clampContentWidth`, `SizeService.calculateContentHeight`
- `lib/widgets/folder_view.dart` — `_FolderViewState.didUpdateWidget`, `_FolderViewState._precomputedMaxWidth`

## Reference behaviour
**None.**

## Cross-cutting invariants
- [measured-equals-rendered](../invariant/measured-equals-rendered.md) — this territory is the "measured" half.
- [row-wider-than-viewport](../invariant/row-wider-than-viewport.md) — `contentWidth` is the source of the width.

## Blast radius
- [tier-rendering](tier-rendering.md) — anything a renderer draws that widens a row must be measured here, and vice versa.
- [scroll-sync](scroll-sync.md) — `contentWidth > viewport` is what turns on horizontal scroll and the per-row translate.
- [scale](scale.md) — a Scale change is one of the three invalidation triggers.
- [theme-composition](theme-composition.md) — theme identity is another trigger, and only for the `theme:` parameter.
- [label-tooltip](label-tooltip.md) — whether a label is ellipsized decides the rect a `child`-anchored tooltip aims at.

## Known holes
Each of the first two is a violation of [measured-equals-rendered](../invariant/measured-equals-rendered.md). Both were probed on 2026-09-23, each against a control that does not ellipsize:
- **`labelResolver` is not measured.** Measurement uses `node.label`, but the renderers draw `labelResolver?.call(node) ?? node.label`. A Child whose resolver returns a long label was ellipsized (painted 760 / needed 783.75 px, 800 px viewport). The same text as `node.label` was not.
- **An inherited theme change does not re-measure.** `didUpdateWidget` compares only `widget.theme`. With the theme supplied through `FolderViewTheme` and the font raised from 14 to 40, the label ellipsized (760 / 1610 px). A fresh pump at 40 did not.
- Also read from the code and not probed: `selectedTextStyle` (for example, bold) is merged at render time but never measured. The ambient `Theme.of(context).textTheme.bodyMedium` is measured but its change does not invalidate. The static cache key omits `fontFamily`.
- [view-mode-projection](view-mode-projection.md): tree mode is measured at folder-mode depths.
