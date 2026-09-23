# Tree lines

## What it is
Draws the connector and indent-guide lines behind each row. The geometry is a pure plan computed from the row's position flags. Colour, width and style are applied only at paint time.

## Governing decisions
**None.**

## Design model
- `TreeLinePlan` gives absolute x-centres: one full-height guide per ancestor that still has siblings below it (its `ancestorIsLastMask` bit is clear), plus this row's own connector. The connector's vertical stops at mid-row for a last child. Root rows have no connector.
- The column width is `expandStripWidth`, the same unit as the indent ([tier-rendering](tier-rendering.md)).
- `LineStyle.none` skips the widget entirely. `connector` draws `├─`/`└─` shapes. `scope` draws vertical guides only.
- One `CustomPainter` per row paints everything in one pass.

## Code
- `lib/widgets/tree_lines.dart` — `TreeLinePlan`, `TreeLinesPainter`, `TreeLines`
- `lib/themes/folder_view_line_theme.dart` — `FolderViewLineTheme`
- `lib/models/node.dart` — `LineStyle`

## Reference behaviour
**None.**

## Cross-cutting invariants
None recorded.

## Blast radius
- [flattening](flattening.md) — the mask encoding is produced there.
- [tier-rendering](tier-rendering.md) — shares the column width, and the scaffold decides whether lines are drawn.
- [scale](scale.md) — line width and column width both scale.

## Known holes
- Nothing recorded. `TreeLinePlan` is the unit-tested core (`test/widgets/tree_lines_test.dart`).
