# View Mode projection

## What it is
Decides which **Nodes** sit at the root of the rendered list for a given **View Mode**: `folder` keeps the natural three-tier shape, `tree` hides **Folders** and lifts their **Parents** to the root. It does not flatten or mutate the input. Flattening is the next step ([flattening](flattening.md)).

## Governing decisions
**None.**

[`CONTEXT.md`](../../../CONTEXT.md) defines **Folder Mode** and **Tree Mode** and says violations of the tier rules produce undefined visible behavior. That is a definition, not a recorded decision with alternatives. No ADR says *why* there are exactly two modes or why a root-level **Child** is dropped rather than rendered.

## Design model
- `folder`: the root keeps **Folders** and **Parents**. A root-level **Child** is dropped silently.
- `tree`: **Parents** are collected recursively, descending through **Folders** only. A **Parent** nested in a **Parent** (a tier violation) is not lifted.
- A **Folder** ID in the **Expanded Set** has no effect in `tree`, because the **Folder** is never rendered.
- Tier behaviour that depends on mode lives downstream, not here: a **Parent** shows its open-state icon only in `tree` ([tier-rendering](tier-rendering.md)).
- Populated from the source and `CONTEXT.md`. No design doc sits above it.

## Code
- `lib/services/view_mode_projection.dart` — `ViewModeProjection.project`, `ViewModeProjection._collectParents`
- `lib/models/node.dart` — `ViewMode`, `NodeType`

## Reference behaviour
**None.**

## Cross-cutting invariants
None recorded. Mode dependence is local to each consumer (listed below).

## Blast radius
- [flattening](flattening.md) — the projection feeds every full rebuild, and a mode change always forces one (the incremental path requires the same mode).
- [row-geometry](row-geometry.md) — width is measured over the *unprojected* `data` (`RowMetrics.maxWidth(widget.data)`), so the projection does not reach measurement. A change here does not re-measure.
- [scroll-sync](scroll-sync.md) — `SyncedScrollControllers` is keyed by `ValueKey(mode)`, so switching mode replaces all four controllers and scroll position resets to 0.
- [tier-rendering](tier-rendering.md) — the **Parent** open-state icon is mode-dependent.

## Known holes
- **Tree Mode measures with folder-mode depths.** `RowMetrics.maxWidth` walks `widget.data` from depth 0, so in `tree` every lifted **Parent** is measured one indent per enclosing **Folder** deeper than it is drawn. The effect is a wider `contentWidth` than needed. Read from the code; not probed.
