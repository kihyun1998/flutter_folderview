# Flattening

## What it is
Turns the projected roots plus the caller's **Expanded Set** into the flat list of visible rows (`FlatNode`s) that the virtualized `ListView` renders. It owns a cache and decides, on every build, between three outcomes: a cache hit, an incremental single-node insert or remove, or a full rebuild.

## Governing decisions
- [ADR-0002](../../adr/0002-caller-owns-interaction-state.md): the **Expanded Set** is caller-owned. `Flattener` reads it and keeps a copy (`Set<String>.of`), never mutating the caller's set.

## Design model
Read from `Flattener.update` and `FlattenService`.
- **Cache hit**: `data` is *identical* (same list instance), the mode is the same, and the **Expanded Set** is equal by content (`_expandedIdsEqual`). Identity is the test for `data`, so a caller that mutates its list in place without changing the **Expanded Set** gets the stale cached rows.
- **Incremental**: same `data` instance and mode, and the **Expanded Set** differs by exactly one ID (`_singleDiff`). Expand inserts that node's flattened subtree after it; collapse removes the consecutive run of deeper rows. Both mutate the cached list in place and report a `FlattenChange(index, deltaItems)`.
- **Full rebuild**: anything else, including a node the incremental path cannot find (it returns null and falls through). A full rebuild reports `change: null`.
- `FlatNode.ancestorIsLastMask` stores one bit per ancestor depth ("that ancestor is its parent's last child"), replacing a per-row `List<bool>`. The encoding lives in one place, `FlattenService._childAncestorMask`, and caps depth at `FlatNode.maxDepth` (63, an `assert`).
- Expansion is gated only by `children.isNotEmpty` (`Node.canExpand`, and the `node.children.isNotEmpty` checks in `FlattenService`). A **Child** with children (a tier violation) would expand. That is undefined by contract.

## Code
- `lib/services/flattener.dart` — `Flattener.update`, `Flattener._singleDiff`, `FlattenChange`, `FlattenResult`
- `lib/services/flatten_service.dart` — `FlattenService.flatten`, `FlattenService.expandNode`, `FlattenService.collapseNode`, `FlattenService._childAncestorMask`
- `lib/models/flat_node.dart` — `FlatNode`, `FlatNode.ancestorIsLastMask`, `FlatNode.maxDepth`
- `lib/models/node.dart` — `Node.canExpand`

## Reference behaviour
**None.**

## Cross-cutting invariants
None recorded. The mask is shared with [tree-lines](tree-lines.md) through `FlatNode`, a data dependency both sides can see, so it is a blast edge, not an invariant.

## Blast radius
- [scroll-anchoring](scroll-anchoring.md) — `FlattenChange` is what keeps the viewport still when rows are inserted or removed above it. A change to when `change` is non-null changes which anchoring branch runs.
- [tree-lines](tree-lines.md) — reads `ancestorIsLastMask` and `isLast`; the bit encoding written here must match the one `TreeLinePlan.forRow` reads.
- [view-mode-projection](view-mode-projection.md) — the full-rebuild input.
- [row-geometry](row-geometry.md) — content height is computed from the flat list's length.
- [benchmarks](benchmarks.md) — these are the hot paths `hot_paths_benchmark` and `flat_list_memory_benchmark` time.

## Known holes / open
- In-place mutation of `data` is invisible to the cache (see Design model). No test or doc tells callers to pass a new list. Read from the code; not probed.
