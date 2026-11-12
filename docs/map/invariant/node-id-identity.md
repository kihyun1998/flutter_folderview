# A Node's id is its identity

## The fact
A **Node**'s `id` identifies it: no two Nodes in one input tree share an `id` (`GLOSSARY.md`, maintainer, 2026-11-07, #172). The library does not check it, and a duplicate produces undefined visible behavior, as a tier-rule violation does.

## Why it is cross-cutting
Three sites match Nodes across two lists by `id`, and none calls the others:
- `FlattenService` finds the row to expand or collapse in place with `indexWhere` on `node.id`.
- `ScrollAnchor.verticalOffsetForBulkChange` finds the old top Node in the new list the same way.
- `_FolderViewContentState` keys each row by `node.id`, and its `findChildIndexCallback` (`_indexOfRow`) finds a row's new index, so the row's State moves with its Node.

Each takes the first match, so with a duplicate each picks a Node of its own.

Scroll anchoring's correction during a user's scroll (`correctBy`, #195) leans on the keyed rows too: it asks for no layout, and the rows in view changing index under their keys is what lays the list out again in the frame of the change. With the keys removed, a drag case's rows were not laid out at the corrected offset in that frame (probed 2026-11-12).

## Territories it holds in
- [flattening](../territory/flattening.md) — the in-place expand and collapse.
- [scroll-anchoring](../territory/scroll-anchoring.md) — the bulk-change anchor, and the frame in which a correction is laid out.
- [scroll-sync](../territory/scroll-sync.md) — the rows are built by the `ListView` there.
- [label-tooltip](../territory/label-tooltip.md) — the label tooltip and its per-Node controller live in the row's State.
- [row-card](../territory/row-card.md) — the row card's tooltip is built inside the keyed row too (read from `_buildItem`, not probed).
- [taps](../territory/taps.md) — `CustomInkWell`'s double-tap count lives in the row's State, so a double tap follows the Node.

## What a violation looks like
Two Nodes with one `id` under two Parents: collapsing the first Parent asserted in the sliver and left the whole list empty; collapsing the second, or both and expanding again, rendered (probed 2026-11-07, debug widget test; release not run). Without the row keys, the same data rendered, and a removed row's State passed to the Node that took its index instead: the next Child's tooltip, or a controller attached twice.

## Discovery history
- #34 — in-place flattening matched rows by `id`.
- #172 — rows matched by index showed another Node's tooltip and threw on a per-Node controller; keying them by `id` made the uniqueness a contract.

## Where it will recur
Anything that matches a Node between two builds, two lists or two frames: a drag-and-drop, an "ensure visible", an animation of an inserted row, a selection restored after a data change. Test: does it look the Node up by `id`, and does it hold if the `id` is unique and nothing else is?
