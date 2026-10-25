# Map — flutter_folderview

<!-- grill-map build stamp: 8e5a943 -->
<!-- grill-map synced at: 7558551 (2026-10-25) -->

A graph over what this package *does*. It answers two questions that no ADR, issue or glossary entry is indexed by:

1. **"If I touch this, what else moves?"** Open the territory you are changing and read its `## Blast radius` as a checklist. Then follow its `## Cross-cutting invariants`.
2. **"What is this derived from?"** In the same note, `## Governing decisions` gives the record, `## Design model` the rules, `## Code` the symbols, and `## Reference behaviour` the outside source it was checked against.

Domain vocabulary is [`GLOSSARY.md`](../../GLOSSARY.md). Decisions are [`docs/adr/`](../adr/). Per-incident evidence is in [`lessons.md`](../agents/lessons.md).

## What the system is
`FolderView<T>` takes a tree of **Nodes** in three tiers and the caller's **Expanded Set**, **Selected Set** and **Scale**, which it reads and never changes. Per build it projects the tree for the **View Mode**, flattens the visible rows (incrementally when one Node toggles), measures the widest row of the whole tree to fix one content width, and renders a fixed-extent virtualized `ListView` whose rows are shifted one by one for horizontal scroll. Each row is drawn by a tier renderer from a composable, scalable theme, with tree lines behind it, tap handling, and two `just_tooltip` surfaces: a label tooltip and a row card. Around that sit scroll anchoring, paired scrollbars, an animated wheel, and a modifier-wheel gesture that proposes a Scale. It ships to pub.dev under a dependency-derived SDK floor; an example app exposes and pins every public option.

**Why the layer exists.** The same fact, *a row can be wider than the viewport*, was found at three sites that never call each other (#42, #47, #44/#45), each from scratch. Facts like that are [invariants](#nodes) here: one note, linked from every territory it holds in.

## Reading protocol
- **Before the design is committed**: open the territory note(s) for the change and read Blast radius and Cross-cutting invariants. A territory listed there that you then do not open is the failure this map exists to prevent. Opening one and finding nothing to do is a correct outcome.
- **After the change lands**, alongside the other surfaces that describe the behaviour:
  - *Coverage*: is the territory in the map, is its Blast radius still right, and did a `## Code` symbol move?
  - *Promotion*: is the fact this fix revealed true at every site that shares the same assumption (row width, row extent, the scaled theme, the tooltip nesting, the tier)? If yes, the fix lands with an invariant note.

## Conventions
- Territories **overlap**. A fact that holds in several places is an **invariant** note, not a line copied into each territory.
- **Empty sections stay.** `**None.**` under a heading *is* the finding: nobody decided (Governing decisions), nobody compared (Reference behaviour), nothing built (Code), nothing found (Known holes / open).
- Section headings are the same strings in every note, so the queries below work.
- `## Code` names **symbols, never line numbers**.
- Plain relative markdown links, so the map works on GitHub and as an Obsidian vault.
- **Link a fact, never restate it.** An issue is cited as a tracking pointer after an observation that stays true when the issue closes, never as the status itself.
- **Provenance.** Every claim carries its evidence (a symbol, a test, a commit, a measurement with its issue) or its source and date (`maintainer, 2026-10-25`). A Known hole says whether it was **probed** (with date and numbers) or **read from the code**.

## Queries (instead of a roster)
```sh
ls docs/map/territory docs/map/invariant            # what exists; the folder is the roster
# the heading may or may not be followed by a blank line — both are matched
rg -lU '## Governing decisions\r?\n(\r?\n)?\*\*None\.\*\*' docs/map/territory   # nobody decided
rg -lU '## Reference behaviour\r?\n(\r?\n)?\*\*None\.\*\*' docs/map/territory   # never compared
rg -lU '## Code\r?\n(\r?\n)?\*\*None\.\*\*' docs/map/territory                  # not built
rg -l 'robed ' docs/map/territory docs/map/invariant                              # holes with a measurement behind them
```
Scope each sentinel query to its heading. A bare `**None.**` search conflates them.

## What the map cannot answer
- **Issues and source files are not nodes.** They appear as text inside notes. The open backlog is read from the tracker, not from here.
- **Gate commands** belong to `.github/workflows/ci.yml`, **hover-test harness constraints** to the header of `test/widgets/node_tooltip_anchor_placement_test.dart`, and **benchmark baselines** to each `benchmark/` file's header. The map points at them and does not restate them.
- A blast edge is a judgement made when the note was written, not measured from a call graph; a shared *assumption* is carried by an invariant instead.

## Scope, and what an absent note means
Covered: all of `lib/`, `benchmark/`, CI, the dependency floor, the release surface, and `example/`.

Out of scope, on purpose: `docs/` itself, `GLOSSARY.md` and `CLAUDE.md` (the decision and instruction layer this map links to), `.claude/` (a stale plan, `plan.md`, from the theme refactor), and the example's generated platform runners, except where a note names a file in them.

For `lib/`: a change that touches a symbol named in no `## Code` section means the map is missing a territory, and the Coverage step adds one. A new public parameter or theme class always gets a home in some territory. A territory appears when something in the repo commits to it: code, a decision record, or an open issue with a design.

## Found at build (2026-10-25)
- **Public surface against records.** Of the 17 public types the barrel's own files declare, 5 are the subject of an ADR (the scrollbar theme, the three tier themes and `NodeTooltipTheme`). Of `FolderView`'s 15 parameters, 5 are governed (ADR-0002's interaction state and its callbacks). The newest large surface, `rowTooltipBuilder` / `RowTooltipTheme`, has no record; its central contract lives in `CLAUDE.md` and dartdoc ([row-card](territory/row-card.md)).
- **No record for the data path.** Flattening, View Mode projection and row measurement appear in no ADR; `GLOSSARY.md` defines the first two.
- **One file, six territories.** `folder_view_content.dart` is 463 of `lib/widgets/`' 1900 lines and hosts scroll-sync, scrollbars, scroll-anchoring, row-card, part of scale-input and the shared ink surface of taps, which is why the map goes finer than the file there.
- **The largest gap is upstream-shaped.** Tooltip placement, suppression, controller attachment and wheel motion are binding upstream behaviour with no pinned fact store; each note says to re-read upstream at the resolved version ([dependency-floor](territory/dependency-floor.md)).

## Nodes
Territories: [view-mode-projection](territory/view-mode-projection.md) · [flattening](territory/flattening.md) · [row-geometry](territory/row-geometry.md) · [scroll-sync](territory/scroll-sync.md) · [scrollbars](territory/scrollbars.md) · [wheel-motion](territory/wheel-motion.md) · [scroll-anchoring](territory/scroll-anchoring.md) · [scale](territory/scale.md) · [scale-input](territory/scale-input.md) · [tier-rendering](territory/tier-rendering.md) · [tree-lines](territory/tree-lines.md) · [taps](territory/taps.md) · [selection](territory/selection.md) · [theme-composition](territory/theme-composition.md) · [label-tooltip](territory/label-tooltip.md) · [row-card](territory/row-card.md) · [dependency-floor](territory/dependency-floor.md) · [release](territory/release.md) · [ci-gates](territory/ci-gates.md) · [benchmarks](territory/benchmarks.md) · [example](territory/example.md)

Invariants: [row-wider-than-viewport](invariant/row-wider-than-viewport.md) · [row-extent](invariant/row-extent.md) · [measured-equals-rendered](invariant/measured-equals-rendered.md) · [chrome-excluded-from-scale](invariant/chrome-excluded-from-scale.md) · [innermost-tooltip-wins](invariant/innermost-tooltip-wins.md)
