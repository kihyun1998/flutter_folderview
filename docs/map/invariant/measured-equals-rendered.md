# Measured width equals rendered width

## The fact
`contentWidth` is measured once, from the theme and `data`, before any row is built. Every row is then laid out at that width. If a row draws anything wider than what was measured, **the label is ellipsized instead of the view scrolling**, and no error appears. So every input that changes a rendered row's width must be (a) read by `RowMetrics` and (b) able to trigger re-measurement.

## Why it is cross-cutting
Measurement (`RowMetrics.maxWidth`, run from `_FolderViewState.build`) and rendering (the tier renderers) are separate code paths over the same theme. They agree where both read one `RowMetrics` rule (indent, strip, `label`, `effectiveTextStyle`) and only by convention elsewhere (`selectedTextStyle` is merged by the Child renderer alone). Invalidation is a third site: the set of inputs compared on each build.

## Territories it holds in
- [row-geometry](../territory/row-geometry.md) — `RowMetrics.maxWidth` measures, and `_FolderViewState.build` decides when to re-measure.
- [tier-rendering](../territory/tier-rendering.md) — `ChildNodeRenderer`, `ExpandableNodeRenderer` and `NodeLabel` decide what is drawn.
- [theme-composition](../territory/theme-composition.md) — the effective theme, however it arrives, is one of the re-measure inputs.
- [label-tooltip](../territory/label-tooltip.md) — a label's rect equals its glyphs only while this holds, and #47's diagnosis turned on exactly that.

## What a violation looks like
A label cut with `…` inside a view that has room to scroll, or that would scroll if it knew. It only reproduces when the width comes from something measurement does not see, or from a change that does not trigger re-measurement. Before 0.11.3 that meant a `labelResolver`, an inherited theme change, or an ambient text theme change. A selected style still does.

## Discovery history
- #47 — the tooltip bug's cause was first written as "the label is ellipsized". A probe showed the label rect at 926 == `maxIntrinsicWidth` 926: measurement held there, and the cause was elsewhere. The wrong sentence had spread to five surfaces.
- #52 — a `NodeLabel` in a fixed 400 px `SizedBox` ellipsizes; inside `FolderView` it does not, because `contentWidth` grows to fit. The same sentence was true in one test file and false in another.
- 2026-09-23 (map build) — three violations: `labelResolver` not measured (probed: 760 / 783.75 px), and an inherited theme or ambient text theme change not re-measured (probed: 760 / 1610 px). All three were fixed in 0.11.3 with tests that fail when each fix is reverted.

## Where it will recur
A new theme field, resolver or state that changes what a row draws horizontally, such as label text, text style, icon box, padding or a trailing widget, is subject to this. Check two things by grep: that `RowMetrics` reads it, and that the re-measure condition in `_FolderViewState.build` compares it.
