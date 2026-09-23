# Flattening

## What it is
Turns the projected roots plus the caller's **Expanded Set** into the flat list of visible rows (`FlatNode`s) that the virtualized `ListView` renders. It owns a cache and decides, on every build, between three outcomes: a cache hit, an incremental single-node insert or remove, or a full rebuild.

## Governing decisions
- [ADR-0002](../../adr/0002-caller-owns-interaction-state.md): the **Expanded Set** is caller-owned. The Flattener reads it and never mutates it.

## Design model
- **Cache hit**: `data` is *identical* (same list instance), the mode is the same, and the **Expanded Set** is equal by content. Identity is the test for `data`, so a caller that mutates its list in place without changing the **Expanded Set** gets the stale cached rows. Read from the code; not probed.
- **Incremental**: same `data` instance and mode, and the **Expanded Set** differs by exactly one ID. Expand inserts that node's flattened subtree after it. Collapse removes the consecutive run of deeper rows. Both mutate the cached list in place and report a `FlattenChange(index, deltaItems)`.
- **Full rebuild**: anything else. This includes a node that the incremental path cannot find, which returns null and falls through.
- `FlatNode.ancestorIsLastMask` stores one bit per ancestor depth ("that ancestor is its parent's last child"). This replaces a per-row `List<bool>` and caps depth at `FlatNode.maxDepth`.
- Expansion is gated only by `children.isNotEmpty` (`Node.canExpand`). A **Child** with children (a tier violation) would expand. That is undefined by contract.

## Code
- `lib/services/flattener.dart` — `Flattener.update`, `Flattener._singleDiff`, `FlattenChange`, `FlattenResult`
- `lib/services/flatten_service.dart` — `FlattenService.flatten`, `FlattenService.expandNode`, `FlattenService.collapseNode`
- `lib/models/flat_node.dart` — `FlatNode`, `FlatNode.ancestorIsLastMask`, `FlatNode.maxDepth`
- `lib/models/node.dart` — `Node.canExpand`

## Reference behaviour
**None.**

## Cross-cutting invariants
None recorded. The depth cap is shared with [tree-lines](tree-lines.md) through `FlatNode`. That is a data dependency both sides can see, so it is a blast edge, not an invariant.

## Blast radius
- [scroll-anchoring](scroll-anchoring.md) — `FlattenChange` is what keeps the viewport still when rows are inserted or removed above it. A change to when `change` is non-null changes scroll behaviour.
- [tree-lines](tree-lines.md) — reads `ancestorIsLastMask` and `isLast`. The bit encoding lives in `FlattenService` and must match `TreeLinePlan`.
- [view-mode-projection](view-mode-projection.md) — the full-rebuild input.
- [row-geometry](row-geometry.md) — content height is `SizeService.calculateContentHeight` over the flat list length.

## Known holes
- In-place mutation of `data` is invisible to the cache (see Design model). No test or doc tells callers to pass a new list. Read from the code; not probed.
- `benchmark/` covers these paths but no gate runs it ([ci-gates](ci-gates.md)).
