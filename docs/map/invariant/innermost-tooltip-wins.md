# The innermost tooltip wins

## The fact
A row can carry two tooltips: the row card wraps the whole row, and the label tooltip wraps the label's glyphs inside it. Exactly one is visible: **the innermost one under the pointer.** The arbitration is done by `just_tooltip`, which suppresses an ancestor while a descendant that has something to draw holds the pointer. This package holds **no priority logic**. It relies on never creating an empty wrapper, which is why "no content → no wrapper" is enforced at both sites.

## Why it is cross-cutting
The two wrappers are built in different files (`FolderViewContent` and `node_render_parts.dart`), for different tiers of configuration (per `FolderView` versus per tier theme), and neither references the other. What makes them interact is upstream's registry and suppression rule, plus the hover-region boundary `NodeLabel` draws. That is a shared runtime assumption with no call edge.

## Territories it holds in
- [label-tooltip](../territory/label-tooltip.md) — `wrapWithNodeTooltip` returns the bare child when there is no content. The glyph-only hover region is what leaves the rest of the row to the card.
- [row-card](../territory/row-card.md) — `_wrapWithRowTooltip` returns the bare row when the builder is null or returns `null`.
- [dependency-floor-release](../territory/dependency-floor-release.md) — suppression is `just_tooltip ≥ 0.4.0` behaviour, re-verified at each bump.

## What a violation looks like
Both tooltips showing, the card never appearing, or the card appearing only in a thin strip of the row. In tests: an assertion that passes for the wrong reason, such as a neighbouring row's card satisfying `find.byKey`. Suppression is process-global within a test, so a second hover in the same `testWidgets` reads as suppressed.

## Discovery history
- #41 — recorded nested suppression as "unreachable here". #48 made it reachable, and the claim had to be reclaimed.
- #44 — label tooltip plus card coexistence came free from `0.4.0` suppression, so it was pinned by a characterization test. There was nothing to implement.
- #52 — a nine-point scan in one test read `x=200 → none` and concluded "the card cannot cover the row". One hover per test gave `x=300 → card`. The label hover region was then narrowed to the glyphs.
- `RowTooltipTheme` — `interactive: true` and `false` tests both passed because the *next* row's card was under the moved cursor.

Four discoveries across two sites and the upstream boundary.

## Where it will recur
Any new tooltip-bearing surface inside a row, and any change that could produce a wrapper with nothing to draw. Before adding one, answer: when the pointer is over it, which of the three is innermost, and is the wrapper ever empty? Test with one hover per `testWidgets`; the harness constraints are in `test/widgets/node_tooltip_anchor_placement_test.dart`'s header.
