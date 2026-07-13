# theflow bindings (flutter_folderview)

Project-specific data for the `theflow` skill. The skill holds the portable
*method*; this file holds this package's *bindings*. Per-incident evidence lives
in [`lessons.md`](lessons.md).

Identity, the three-tier domain, and the tier rules live in **`CONTEXT.md`**
(the glossary is the source of truth — a `Node` is not a "row"; a "row" is a
*rendered line*). Decisions live in **`docs/adr/`**.

## Crate / module map

Single Flutter package. The barrel `lib/flutter_folderview.dart` **re-exports
`just_tooltip`**, so callers get `TooltipAnchor` etc. from this package.

| Area (`lib/`) | Members / role |
|---|---|
| `models/` | `node.dart` (`Node`: id · label · tier · payload · children), `flat_node.dart` (the flattened projection) |
| `services/` | `flattener` / `flatten_service` (tree → visible list), `view_mode_projection` (folder / tree), `row_metrics`, `scroll_anchor`, `size_service` — pure, testable without widgets |
| `widgets/` | `folder_view.dart` (**public `FolderView`**), `folder_view_content.dart` (**internal — the test seam**), child/expandable node renderers, `node_widget` (`FittedBox` wraps unscaled user widgets), `synced_scroll_controllers`, the two scrollbars, `custom_ink_well`, `tree_lines` |
| `themes/` | per-tier node themes (`folder`/`parent`/`child_node_theme` — **intentional duplication, ADR-0005, do not extract a base**), `folder_view_theme` composition, and the two just_tooltip surfaces: `node_tooltip_theme`, `row_tooltip_theme` |
| `input/` | `scale_modifier` (Ctrl/Cmd + wheel → Scale request) |

## Step 1 — reference routing table

| Change type | Real source to read |
|---|---|
| **`just_tooltip` behavior** | upstream source at `~/AppData/Local/Pub/Cache/hosted/pub.dev/just_tooltip-<ver>/`, `grep`/`sed` (not memory). **Read `just_tooltip_anchor_test.dart` before writing any hover test** — that harness avoids all three hover traps (Step 4). Published version: `curl -s https://pub.dev/api/packages/just_tooltip` |
| **Row / node tooltip design** | the sibling **`flutter_table_plus`** (same author, same just_tooltip) has already solved `rowTooltipBuilder` + `anchor: pointer` — check it first (#44/#45) |
| **Dependency constraint math** | compute what the caret *actually* admits: `^0.4.0` resolves `0.4.2`, which requires Flutter 3.13 — the floor lied by *not* changing (#47). Now on `^0.4.4` |
| **Hidden state / domain** | `CONTEXT.md` glossary + `docs/adr/` |

## Step 2 — boundary rule (the ADRs are the contract)

- **Caller owns interaction state (ADR-0002).** The **Expanded Set**, **Selected
  Set**, and **Scale** are caller-controlled — the library *reads* them, never
  mutates. `onNodeTap` / `onScaleChanged` *propose*; the caller applies.
- **Tooltips and scrollbars are chrome, excluded from Scale** (ADR-0001, ADR-0004).
  Do **not** scale tooltip spatial fields — an earlier attempt made the result
  visually worse because just_tooltip's text default is unscaled.
- **Tier theme fields are intentionally duplicated (ADR-0005)** — folder/parent/
  child themes repeat fields on purpose; do not extract a shared base.
- **Tier rules are not enforced at runtime** — a Child at the root, a Folder in a
  Parent → undefined visible behavior, by contract (`CONTEXT.md`).
- **The `just_tooltip` boundary.** Two surfaces: a **node-label** tooltip and a
  **row-card** tooltip. Nesting is arbitrated **by just_tooltip** (innermost
  wins) — this package holds no priority logic. The row card uses
  **`anchor: pointer` as a correctness requirement** (a row goes off screen once
  it scrolls horizontally wider than the viewport), not a workaround. On
  `^0.4.4`. `RowTooltipTheme`'s `surface: bare()` is a **default, not a law** —
  a caller may return chrome (the dartdoc once stated it as law; corrected). And
  **nested suppression is reachable** (#48 made the `#41` "unreachable" claim false).

## Step 4 — proof method per layer

- **Pure services** (flatten, projection, metrics): unit tests, no widgets.
- **Hover behavior has three traps, each silently wrong** — all hit in this repo:
  1. a `waitDuration` races upstream's microtask hover-intent coalescing (show
     fires before the pointer position settles);
  2. **two hovers in one `testWidgets`** trip just_tooltip's process-global
     registry (the second is suppressed);
  3. a **text-sized tooltip** lets the `screenMargin` clamp move the measured
     coordinate.
  → **one hover per test**; read the upstream anchor test; the constraints are in
  `test/widgets/node_tooltip_anchor_placement_test.dart`'s header. #42 hit all
  three at once and two wrong anchors *agreed*, nearly filed as an upstream bug.
- **Carry the measurement context with the conclusion** (#52): a `NodeLabel` in a
  fixed 400px `SizedBox` ellipsizes; inside `FolderView` `contentWidth` grows to
  fit, so it does not. The same sentence is true in one file and false in another.
- **Integration tests** launch a real desktop app: `flutter test
  integration_test/<file>.dart -d windows`, **one at a time** (a second in the
  same session dies `Error waiting for a debug connection`). **Not in CI.**
- Before release, `cd example && flutter run -d windows` and **eyeball hover** —
  the agent cannot hover.
- Record the **mutation-check** in the PR body (which mutation, what died — and
  if nothing died, that too; it was this repo's most valuable finding, #51).

## Step 6 — behavior-describing surfaces

- **`CHANGELOG.md`** — pub.dev snapshots at publish; an *unpublished* version is
  still editable (0.11.0's "ellipsized" cause was swapped before it shipped).
- **`README.md`** — the tooltip comparison table drifted (claimed the label
  tooltip attaches to "icon and label"; the icon was dropped, #52).
- **dartdoc** → pub.dev API docs. `NodeTooltipTheme.anchor` / `FolderView.
  rowTooltipBuilder` carried a reversed causality and "draws no background,
  padding, or elevation" (now a default, not a law).
- **Reclaim forward references** — dead in this repo: "see the follow-up issue"
  (never existed), "row-wide tooltips tracked in #44" (shipped since),
  "turn the label tooltip off to see the card" (#52 reversed it), "#41: nested
  suppression unreachable here" (#48 made it reachable).
- **example copy + dartdoc** — a switch subtitle still said "turn off the label
  tooltip to see the card" (#52).
- **`docs/adr/`** — flip the ADR when the decision flips. New code honors ADR-0002
  (caller owns interaction state), ADR-0004 (tooltips are chrome), ADR-0005 (tier
  theme duplication is intentional).
- **`CONTEXT.md` glossary** — `Node` is not "row". **`docs/agents/*.md`** —
  `triage-labels.md` once declared five labels when the repo had three.
- **`.pubignore`** — disables git-based file listing when present; the pub.dev
  archive cannot be un-published.

## Step 7 — gate matrix + downstream loop

`.github/workflows/ci.yml` — two jobs. **`analyze` and `dart format
--set-exit-if-changed` are separate gates** (#48: two hand-wrapped lines failed
both). Format runs **after `pub get`** (language version from `package_config`).

```
# job: test (package)
flutter pub get
dart format --output=none --set-exit-if-changed lib test benchmark
flutter analyze
flutter test --coverage

# job: example  (working-directory: example)
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test        # example/test only — integration_test/ is excluded
```

- **example tests ARE a gate** — but were not for a long time: the `flutter
  create` counter smoke test was red from the day the example landed and nobody
  saw it (the example job ran only `analyze`). #57 removed it and added the
  `Test` step. **A test no job runs is not a test** — confirm which job runs a
  new test.
- Local pre-push mirror: `dart format lib test benchmark && (cd example && dart
  format .)` → analyze both → test both.
- **`git status` `M` ≠ content change**: `example/*/flutter/
  generated_plugin_registrant.*` are regenerated by `flutter analyze` with only
  EOL changes; `git diff --ignore-all-space --stat` then `git restore`.
- Branch → `fix|feat(<scope>): …` → PR (`Closes #issue`) → CI green → **squash
  merge (`--delete-branch`)**.
- `dart pub publish` is irreversible (7-day retract only) — **the agent does not
  run it; the user does.** `--dry-run` must be 0 warnings.
- **Downstream loop:** derive consumers on the spot (`grep` sibling manifests);
  the list is not stored here.

## War-story index

The per-incident evidence (#42–#45, #47, #48, #50–#52, #57, and the
`RowTooltipTheme` slice) lives in [`lessons.md`](lessons.md), indexed by step.
Read it before starting.
