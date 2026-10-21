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
- **Fixed in #118: the stub and a last child's vertical end follow the row's extent.**
  - **The cause.** The `ListView`'s `itemExtent` is `rowHeight + rowSpacing`, and it overrides `NodeWidget`'s `SizedBox(rowHeight)`, so the row and its painter are the full extent tall. The content is centred in that extent, but the painter put the stub and a last child's vertical end at `rowHeight / 2`. At a 40 px `rowHeight` and `rowSpacing` 10, that left the stub at y = 20 against a label centred at y = 25.
  - **The fix.** The painter now uses half the size it paints, and it no longer takes a `rowHeight` input, so it cannot drift from the extent again.
  - **The decision.** By the maintainer's call at triage, `rowSpacing` means extra height added to every row, as content, ink and hit areas already treated it, not an empty gap. Its dartdoc says so.
  - **Pinned** by `test/widgets/tree_lines_row_spacing_test.dart`, at `rowSpacing` 0 and 10, through `FolderView`.
- `TreeLinePlan` is the unit-tested core (`test/widgets/tree_lines_test.dart`).
