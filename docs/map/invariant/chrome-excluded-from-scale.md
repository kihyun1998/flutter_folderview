# Chrome is excluded from Scale

## The fact
**Scale** applies to content only. Scrollbars and tooltips (both the label tooltip and the row card) keep their physical size at every Scale. The exclusion is **structural**: a chrome theme has no `scale` method, and the content theme that holds it does not delegate to it. Calling one is a compile error.

## Why it is cross-cutting
One rule spans four theme classes in four territories. Each exclusion is enforced by an *absence*: a missing `scale` method on `NodeTooltipTheme` and `RowTooltipTheme`, or a skipped delegation line in `FlutterFolderViewTheme.scale` (`scrollbarTheme`) and in each tier theme's `scale` (`tooltipTheme`, marked `// ADR-0004`). No site calls another. An absence is exactly what a later "complete the pattern" edit fills in.

## Territories it holds in
- [scale](../territory/scale.md) — `FlutterFolderViewTheme.scale` skips `scrollbarTheme`, and `FolderNodeTheme.scale`, `ParentNodeTheme.scale` and `ChildNodeTheme.scale` skip `tooltipTheme`.
- [scrollbars](../territory/scrollbars.md) — `FolderViewScrollbarTheme` reaches the bars unscaled.
- [label-tooltip](../territory/label-tooltip.md) — `NodeTooltipTheme` has no `scale`.
- [row-card](../territory/row-card.md) — `RowTooltipTheme` has no `scale`.
- [theme-composition](../territory/theme-composition.md) — a new theme class is where the rule is next applied or broken.
- [example](../territory/example.md) — the Scale feature's `scale-note` states it, and the Scrollbars and tooltip features each carry it as an interaction with `scale` (#78, #85, #86).

## What a violation looks like
Tooltips that grow with the view but keep small text: a large box around text at host size, because `just_tooltip` supplies its own unscaled text default when `textStyle` is null (ADR-0004). Or scrollbar thumbs too thin to grab at small Scale (ADR-0001). The example pins the bar's width at Scale 2, and a mutation that scales `scrollbarTheme` reddens it ([example](../territory/example.md)).

## Discovery history
- [ADR-0001](../../adr/0001-scrollbars-excluded-from-scale.md) — scrollbars classified as chrome.
- [ADR-0004](../../adr/0004-tooltips-excluded-from-scale.md) — tooltip scaling was *implemented* during the per-theme `scale` refactor, found visually worse, and reverted. `GLOSSARY.md` keeps the note.
- `RowTooltipTheme` (#44) was born under the rule and says so in its dartdoc.

## Where it will recur
Any new theme class for something drawn *over* content (a context menu, a drag ghost, a badge overlay) gets no `scale` method. Any new spatial field on a *content* theme is added to that theme's `scale`, or it silently stays at 1×. The test for which kind a field is: does it size something the user reads or aims at independently of the tree's density? If yes, it is chrome.
