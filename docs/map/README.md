# Map — flutter_folderview

<!-- grill-map build stamp: 1831304 -->

A dependency graph over what this package *does*. It answers two questions that no ADR, issue or glossary entry is indexed by:

1. **Horizontal: "if I touch this, what else moves?"** Open the territory you are changing and read its `## Blast radius` as a checklist. Then follow its `## Cross-cutting invariants`.
2. **Vertical: "what is this derived from?"** In the same note, `## Governing decisions` gives the record, `## Design model` the rules, `## Code` the symbols, and `## Reference behaviour` the outside source it was checked against.

Domain vocabulary is [`CONTEXT.md`](../../CONTEXT.md). Decisions are [`docs/adr/`](../adr/). Per-incident evidence is in [`lessons.md`](../agents/lessons.md).

## Why this layer exists
The same fact was found three times at three sites: **a row can be wider than the viewport** (#42 label anchor, #47 tooltip outside the view, #44/#45 row-card anchor). The three sites never call each other, so no file, ADR or issue connected them. Each was found from scratch. That fact now has one node: [row-wider-than-viewport](invariant/row-wider-than-viewport.md).

**Completion test.** Had this map existed at #44, would the row-card anchor question (#45) have been asked at all? The route is [label-tooltip](territory/label-tooltip.md), the territory #42 touched → `## Cross-cutting invariants` → the invariant → its `## Territories it holds in` already names [row-card](territory/row-card.md) with the reason. That is one hop from the first fix to the second site. Yes, it would have been answered.

## Reading protocol
- **Before the design is committed**: open the territory note(s) for the change and read Blast radius and Cross-cutting invariants. A territory listed there that you then do not open is the failure this map exists to prevent. Opening one and finding nothing to do is a correct outcome.
- **After the change**, alongside the other surfaces that describe the behaviour:
  - *Coverage*: is the territory in the map, and is its Blast radius still right? Did a `## Code` symbol move? Run the symbol check.
  - *Promotion*: is the fact this fix revealed true at any other site that shares the same assumption (row width, the scaled theme, the tooltip nesting, the tier)? If yes, the fix does not land until an invariant note exists for it.

## Conventions
- Territories **overlap**. A fact that holds in several places is an **invariant** node, not a line copied into each territory.
- **Empty sections stay.** `**None.**` under a heading *is* the finding: nobody decided (Governing decisions), nobody compared (Reference behaviour), nobody built (Code).
- `## Code` names **symbols, never line numbers**.
- Plain relative markdown links, so the map works both on GitHub and as an Obsidian vault.
- An open issue is cited as a *tracking pointer* after an observation that stays true when the issue closes. It is never cited as the status itself.
- A Known hole says whether it was **probed** (with date and numbers) or **read from the code**.

## Queries (instead of a roster)
```sh
ls docs/map/territory docs/map/invariant            # what exists; the folder is the roster
# the heading may or may not be followed by a blank line — both are matched
rg -lU '## Governing decisions\r?\n(\r?\n)?\*\*None\.\*\*' docs/map/territory   # nobody decided
rg -lU '## Reference behaviour\r?\n(\r?\n)?\*\*None\.\*\*' docs/map/territory   # never compared
rg -lU '## Code\r?\n(\r?\n)?\*\*None\.\*\*' docs/map/territory                  # not built
rg -l 'robed on' docs/map/territory docs/map/invariant                            # holes with a measurement behind them
```
Scope each sentinel query to its heading. A bare `**None.**` search conflates the three.

## What the map cannot answer
- **Issues and source files are not nodes.** They appear as text inside notes. The open backlog is read from the tracker, not from here.
- **Gate commands** belong to `.github/workflows/ci.yml`, and **hover-test harness constraints** to the header of `test/widgets/node_tooltip_anchor_placement_test.dart`. This map points at them and does not restate them.
- A blast edge is a judgement made at build time. It is not measured from a call graph, and a shared *assumption* is carried by an invariant instead.

## Measurements at build (2026-09-23)
- **M1, public surface.** Of 17 exported types, 5 are the subject of an ADR (the scrollbar theme and the four tier and tooltip themes). Of 14 `FolderView` parameters, 5 are governed (ADR-0002's interaction state). The newest large surface, `rowTooltipBuilder` / `RowTooltipTheme`, has **no** record. Its central contract (a pointer anchor as a correctness requirement) lives in `CLAUDE.md` and dartdoc.
- **M2, mentioned versus subject.** "row" appears in 2 ADR bodies and 0 titles. Flattening and View Mode appear in 0 ADRs, and `CONTEXT.md` defines them.
- **M3, file size.** No file exceeds 30% of its layer. `folder_view_content.dart` is 27% of `widgets/`, and it hosts four territories (scroll-sync, scroll-anchoring, row-card, and part of scale-input), which is why the map goes finer than the file there.
- **M4, stale forward prose.** [ADR-0003](../adr/0003-selection-is-tier-bound-to-child.md)'s implementation note predicted a removal that had already happened (`bfb91db`), and it recommended `onSecondaryNodeTap` for containers, which the code did not deliver (probed). Both were fixed in 0.11.3.
- **M5, backlog.** One open issue, #16. Its body is partly stale ([theme-composition](territory/theme-composition.md)).
- **Probed at build:** 3 holes, each against a control. Two violated [measured-equals-rendered](invariant/measured-equals-rendered.md), and one was the ADR-0003 gap above. All three were fixed in 0.11.3 rather than filed.

## Coverage and what an absent note means
Covered: all of `lib/`, CI, the dependency floor and release, and `example/` ([example](territory/example.md), added with the shell in #75). The legacy panel inside the example is described there only as a migration step, because #91 deletes it.

For `lib/`: a change that touches a symbol named in no `## Code` section means the map is missing a territory, and the Coverage step adds one. A new public parameter or theme class always gets a home in some territory.

## Nodes
Territories: [view-mode-projection](territory/view-mode-projection.md) · [flattening](territory/flattening.md) · [row-geometry](territory/row-geometry.md) · [scroll-sync](territory/scroll-sync.md) · [scroll-anchoring](territory/scroll-anchoring.md) · [scale](territory/scale.md) · [scale-input](territory/scale-input.md) · [tier-rendering](territory/tier-rendering.md) · [tree-lines](territory/tree-lines.md) · [tap-and-selection](territory/tap-and-selection.md) · [label-tooltip](territory/label-tooltip.md) · [row-card](territory/row-card.md) · [theme-composition](territory/theme-composition.md) · [dependency-floor-release](territory/dependency-floor-release.md) · [ci-gates](territory/ci-gates.md) · [example](territory/example.md)

Invariants: [row-wider-than-viewport](invariant/row-wider-than-viewport.md) · [chrome-excluded-from-scale](invariant/chrome-excluded-from-scale.md) · [measured-equals-rendered](invariant/measured-equals-rendered.md) · [innermost-tooltip-wins](invariant/innermost-tooltip-wins.md)
