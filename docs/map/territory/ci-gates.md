# CI gates

## What it is
What must pass before a change merges, and what is deliberately outside every gate. The commands are owned by `.github/workflows/ci.yml`; a local pre-push run is its two jobs' steps, in order. This note records the shape and the blind spots.

## Governing decisions
**None.**

## Design model
Read from `.github/workflows/ci.yml`.
- Two jobs, `test` (package) and `example`, on pushes to `main` and PRs targeting it, on Flutter `stable`. Formatting and analysis are **separate gates** (#48), and format runs after `pub get` so it uses the package's language version (its comment).
- The `test` job format-checks `lib test benchmark`, analyzes, and runs `flutter test --coverage`. Coverage is uploaded as an artifact; the Codecov step is commented out.
- The `example` job formats, analyzes and runs `example/test`. For a long time it did not run the tests, and a red `flutter create` smoke test sat there unseen (#57, the workflow's comment).
- **Outside every gate, on purpose:** `example/integration_test/`, which launches a desktop app and is run locally, one file at a time ([example](example.md)); and `benchmark/`, which the `test` job format-checks but never runs ([benchmarks](benchmarks.md)).
- `flutter analyze` regenerates `example/*/flutter/generated_plugin_registrant.*` with line-ending changes only. A `M` there after a gate run is not a content change: check with `git diff --ignore-all-space --stat`, then `git restore`.

## Code
- `.github/workflows/ci.yml` — `test`, `example`
- `analysis_options.yaml`

## Reference behaviour
**None.**

## Cross-cutting invariants
None recorded.

## Blast radius
- [dependency-floor](dependency-floor.md) — CI resolves fresh and on `stable` only, so it cannot catch an SDK floor that is too low.
- [example](example.md) — the `example` job runs the option coverage guard, so a public field added to `lib/` turns that job red until the example exposes it or lists it with an owning issue.
- [benchmarks](benchmarks.md) — formatted by the gate, never run by it.
- [release](release.md) — no gate runs the publish dry-run.

## Known holes / open
- CI runs only the latest stable Flutter. The declared floor (`>=3.32.0`) is never built.
