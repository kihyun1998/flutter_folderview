# Chrome is excluded from Scale

## The fact
**Scale** applies to content only. Scrollbars and tooltips (both the label tooltip and the row card) keep their physical size at every Scale. The exclusion is **structural**: a chrome theme has no `scale` method, and the content theme that holds it does not delegate to it. Calling one is a compile error.

## Why it is cross-cutting
One rule spans four theme classes in three territories. Each exclusion is enforced by an *absence*: a missing `scale` method, or a skipped delegation line in `FlutterFolderViewTheme.scale` or in each tier theme's `scale`. No site calls another. An absence is exactly what a later "complete the pattern" edit fills in.

## Territories it holds in
- [scale](../territory/scale.md) — `FlutterFolderViewTheme.scale` skips `scrollbarTheme`, and tier `scale` methods skip `tooltipTheme` (marked `// ADR-0004`).
- [scroll-sync](../territory/scroll-sync.md) — `FolderViewScrollbarTheme` is passed through unscaled.
- [label-tooltip](../territory/label-tooltip.md) — `NodeTooltipTheme` has no `scale`.
- [row-card](../territory/row-card.md) — `RowTooltipTheme` has no `scale`.

## What a violation looks like
Tooltips that grow with the view but keep small text: a large box around text at host size, because `just_tooltip` supplies its own unscaled text default when `textStyle` is null. Or scrollbar thumbs too thin to grab at small Scale.

## Discovery history
- [ADR-0001](../../adr/0001-scrollbars-excluded-from-scale.md) — scrollbars classified as chrome.
- [ADR-0004](../../adr/0004-tooltips-excluded-from-scale.md) — tooltip scaling was *implemented* during the per-theme `scale` refactor, measured as visually worse, and reverted. `CONTEXT.md` keeps the flagged ambiguity.
- `RowTooltipTheme` (#44) was born under the rule and says so in its dartdoc.

Two decisions and one reverted implementation.

## Where it will recur
Any new theme class for something drawn *over* content (a context menu, a drag ghost, a badge overlay) must get no `scale` method. Any new spatial field on a *content* theme must be added to that theme's `scale`, or it silently stays at 1×. The test for which kind a field is: does it size something the user reads or aims at independently of the tree's density? If yes, it is chrome.
