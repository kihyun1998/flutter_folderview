# CI gates

## What it is
What must pass before a change merges, and what is deliberately outside every gate. The commands themselves are owned by `.github/workflows/ci.yml`; a local pre-push run is its two jobs' steps, in order. This note records only the shape and the blind spots.

## Governing decisions
**None.**

## Design model
- Two jobs, `test` (package) and `example`. Formatting and analysis are **separate gates** (#48), and format runs after `pub get` so it uses the package's language version.
- The example job runs the example's tests. For a long time it did not, and a red `flutter create` smoke test sat there unseen (#57).
- **Outside every gate, on purpose:** `example/integration_test/`, which launches a desktop app and is run locally with `flutter test integration_test/<file>.dart -d windows`, **one file at a time** (a second in the same session dies with `Error waiting for a debug connection`), and `benchmark/`. The `test` job format-checks `benchmark/` but never runs it.
- Coverage is uploaded as an artifact. The Codecov step is commented out.
- `flutter analyze` regenerates `example/*/flutter/generated_plugin_registrant.*` with line-ending changes only. A `M` there after a gate run is not a content change: check with `git diff --ignore-all-space --stat`, then `git restore`.

## Code
- `.github/workflows/ci.yml` — `test`, `example`
- `benchmark/hot_paths_benchmark.dart` — `main`
- `benchmark/max_width_benchmark.dart` — `main`
- `benchmark/flat_list_memory_benchmark.dart` — `main`

## Reference behaviour
**None.**

## Cross-cutting invariants
None recorded.

## Blast radius
- [dependency-floor-release](dependency-floor-release.md) — CI resolves fresh and on `stable` only, so it cannot catch an SDK floor that is too low.
- [flattening](flattening.md) and [row-geometry](row-geometry.md) — their hot paths are benchmarked, not gated.
- [example](example.md) — the `example` job runs the option coverage guard, so a public field added to `lib/` turns that job red until the example exposes the field or lists it with an owning issue.

## Known holes
- CI runs only the latest stable Flutter. The declared floor (`>=3.13.0`) is never built.
- `benchmark/` has no baseline, so a regression is only visible to someone who runs it and remembers the old number.
