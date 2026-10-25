# Tree lines

## What it is
Draws the connector and indent-guide lines behind each row. The geometry is a pure plan computed from the row's position flags; colour, width and style are applied only at paint time.

## Governing decisions
**None.**

## Design model
Read from `TreeLinePlan` and `TreeLinesPainter`.
- `TreeLinePlan.forRow` gives absolute x-centres: one full-height guide per ancestor that still has siblings below it (its `ancestorIsLastMask` bit is clear), plus this row's own connector. Root rows have no connector.
- The column width is `expandStripWidth`, the same unit as the indent ([tier-rendering](tier-rendering.md)).
- `LineStyle.none` skips the widget entirely (`NodeWidget.build`). `connector` draws `├─`/`└─` shapes; `scope` draws vertical guides only.
- One `CustomPainter` per row paints everything in one pass. It repaints only when the plan or the line theme changes.
- **The painter uses half the size it paints, not `rowHeight / 2`** (#118). The row is `rowHeight + rowSpacing` tall with its content centred, so at `rowHeight` 40 and `rowSpacing` 10 the stub used to sit at y 20 against a label centred at y 25 (CHANGELOG 0.12.0). The painter takes no `rowHeight` input, so it cannot drift from the extent again ([row-extent](../invariant/row-extent.md)). `rowSpacing` means extra height on every row, not an empty gap (maintainer, at triage, #118). Pinned by `test/widgets/tree_lines_row_spacing_test.dart`.

## Code
- `lib/widgets/tree_lines.dart` — `TreeLinePlan`, `TreeLinePlan.forRow`, `TreeLinesPainter`, `TreeLines`
- `lib/themes/folder_view_line_theme.dart` — `FolderViewLineTheme`
- `lib/models/node.dart` — `LineStyle`

## Reference behaviour
**None.**

## Cross-cutting invariants
- [row-extent](../invariant/row-extent.md) — the painter follows the extent by reading its own size.

## Blast radius
- [flattening](flattening.md) — the mask encoding is produced there.
- [tier-rendering](tier-rendering.md) — shares the column width, and the scaffold decides whether lines are drawn.
- [scale](scale.md) — line width and column width both scale.

## Known holes / open
**None** found by this reading. `TreeLinePlan` is the unit-tested core (`test/widgets/tree_lines_test.dart`).
