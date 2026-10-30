# CLAUDE.md

## Working discipline

Substantive changes follow `thegraph`. Its build is `docs/agents/thegraph.md`;
what depends on what is `docs/map/`; per-incident evidence is
`docs/agents/lessons.md` (add new war-stories there).

- Branch → `fix|feat(<scope>): …` → PR (`Closes #n`) → CI green → squash merge
  `--delete-branch`.
- Record the mutation check in the PR body: which mutation, and what died (or
  that nothing did).
- Before a release, run `pub-ready`.

| Read | When |
|---|---|
| `docs/map/invariant/row-wider-than-viewport.md` | before writing a test for a row wider than the viewport |
| `docs/agents/release.md` | before preparing a release, or claiming a hover change works |
| `docs/agents/issue-tracker.md` | before filing, reading or labelling an issue |
| `docs/agents/domain.md` | before naming a domain concept, or working in an area an ADR covers |

## Identity & invariants (the boundary)

`flutter_folderview` renders a **semantic three-tier hierarchy** — **Folder →
Parent → Child** (each a `Node`) — in two interchangeable **View Modes**
(`folder` / `tree`). The tier roles are part of the *contract*, not styling. The
full domain, the tier rules, and the ubiquitous language live in **`GLOSSARY.md`**
(source of truth — a `Node` is **not** a "row"; a "row" is a *rendered line*);
decisions in **`docs/adr/`**.

- **Caller owns interaction state (ADR-0002).** The **Expanded Set**, **Selected
  Set**, and **Scale** are caller-controlled — the library *reads* them, never
  mutates. `onNodeTap` / `onScaleChanged` propose; the caller applies.
- **Chrome is excluded from Scale.** Scrollbars (ADR-0001) and tooltips (ADR-0004)
  do not scale.
- **Tier theme fields are intentionally duplicated (ADR-0005)** — do not extract
  a shared base.
- **Tier rules are not enforced at runtime** — violations produce undefined
  visible behavior, by contract.
- **Consumes `just_tooltip`** (re-exported: `grep export lib/flutter_folderview.dart`;
  version: `grep just_tooltip pubspec.yaml`). Two surfaces — a node-label tooltip
  and a row-card tooltip; nesting is arbitrated **upstream** (innermost wins), so
  this package holds no priority logic. The row card is fixed to
  `TooltipAnchor.pointer` as a **usability default**: a row can be wider than the
  viewport, and the centre of its visible part is not where the user is looking
  (#138).

## Comments and the map

A comment says what the code is. Why it is this way, what it deliberately leaves
out, the trap and the measured value go to the territory note under `docs/map/`.
Where none seems to hold it, search the folder and the code symbol first; only
then start a new note, named for what the system does there, not for the file.
History goes to the commit message. Comments written before this rule still carry
the rest: never delete one whose content the map does not yet hold — move it there
first. The map's entry point and reading protocol: `docs/map/README.md`.

- **Before the design is committed** (`read-it`): open the territory notes for the
  change and work their Blast radius and Cross-cutting invariants as a checklist.
- **After it lands** (`sweep`): bring those notes back in line, and ask whether the
  fact the fix revealed holds at every site that shares the same assumption. If
  it does, the fix lands with an invariant note.
