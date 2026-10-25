# Row card

## What it is
The row-wide tooltip raised by `FolderView.rowTooltipBuilder` and styled by `RowTooltipTheme`. It explains the **Node**, while the [label-tooltip](label-tooltip.md) explains the label. It is declared once on the `FolderView`, not per tier. Its hover region is the whole rendered row.

## Governing decisions
**None.**

[ADR-0004](../../adr/0004-tooltips-excluded-from-scale.md) excludes it from Scale, and `RowTooltipTheme` cites [ADR-0005](../../adr/0005-tier-theme-boilerplate-not-extracted.md) for "deliberately do not share fields". ADR-0005 decides the *tier* themes, though, and is invoked here only by analogy. The central contract, the anchor fixed to the pointer as a usability default (#138), is stated in `CLAUDE.md`, in dartdoc and in #44, but no decision record carries it or its rejected alternative (`TooltipScope`, #43).

## Design model
Read from `_FolderViewContentState._wrapWithRowTooltip` and `RowTooltipTheme`.
- No wrapper when the builder is null or returns `null` for a Node.
- **The anchor is always `TooltipAnchor.pointer`**, the one knob the theme does not expose. The row's rect is `contentWidth` wide and translated ([row-wider-than-viewport](../invariant/row-wider-than-viewport.md)).
  - **Why, since #138.** just_tooltip has anchored `TooltipAnchor.child` to the *visible* part of the child's rect since 0.4.2, so a rect anchor no longer aims off screen; it aims at the view's centre. Measured with the card mutated to `child`, scrolled to the far right and hovered at x 1220: the card spanned x 587–925 around the view centre at 756 (#138). Upstream's own `anchor` dartdoc gives that reason.
  - **A usability default, unexposed** (maintainer, at triage, 2026-10-21). Exposing `anchor` would be a separate enhancement.
- `surface` defaults to `JustTooltipTheme.bare()`, because a card draws its own. A default, not a law: a caller may set `surface`.
- `interactive` defaults to `true`, the opposite of the label tooltip, and deliberately so (`RowTooltipTheme.interactive` dartdoc).
- Wraps `NodeWidget` from outside, so every label tooltip nests inside it ([innermost-tooltip-wins](../invariant/innermost-tooltip-wins.md)).
- Its hover region is reachable across the whole visible row only because the row's translate sits inside the viewport-wide `OverflowBox` ([scroll-sync](scroll-sync.md), #136). The example's wide-row scenario (#89) found it.
- The card has no `enableTap`; a row tap with the card on still selects the Child (pinned in `example/test/row_card_test.dart`).

## Code
- `lib/widgets/folder_view_content.dart` — `_FolderViewContentState._wrapWithRowTooltip`
- `lib/themes/row_tooltip_theme.dart` — `RowTooltipTheme`, `RowTooltipTheme.surface`, `RowTooltipTheme.interactive`
- `lib/widgets/folder_view.dart` — `FolderView.rowTooltipBuilder`, `FolderView.rowTooltipTheme`

## Reference behaviour
Compared, not pinned: the sibling `flutter_table_plus` had already solved `rowTooltipBuilder` + `anchor: pointer` with the same `just_tooltip`, which is why #45 was closed rather than measured ([lessons](../../agents/lessons.md), #44/#45). That sibling is an *example* to diverge from deliberately, not a spec.

## Cross-cutting invariants
- [row-wider-than-viewport](../invariant/row-wider-than-viewport.md)
- [innermost-tooltip-wins](../invariant/innermost-tooltip-wins.md)
- [chrome-excluded-from-scale](../invariant/chrome-excluded-from-scale.md)

## Blast radius
- [label-tooltip](label-tooltip.md) — the two share every row, and suppression decides which one shows.
- [scroll-sync](scroll-sync.md) — the translate is why the anchor is fixed, and its order is why the card is reachable.
- [taps](taps.md) — the card must not intercept row taps.
- [dependency-floor](dependency-floor.md) — nested suppression needs `just_tooltip ≥ 0.4.0`, and `bare()` needs `≥ 0.4.1`.

## Known holes / open
- The anchor contract has no decision record (see Governing decisions).
