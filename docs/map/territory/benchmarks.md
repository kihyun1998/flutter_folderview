# Benchmarks

## What it is
Local measurements of the hot pure paths behind virtualized rendering: flattening and projection time, the flat list's heap footprint, and the cold cost of the width precompute. They catch algorithmic regressions for whoever runs them; nothing runs them automatically.

## Governing decisions
**None.**

## Design model
Read from each file's header.
- Each is run explicitly with `flutter test benchmark/<file>.dart`. They live outside `test/`, so the default suite and CI never run them ([ci-gates](ci-gates.md)). `benchmark_harness` is a dev dependency for them (`pubspec.yaml` comment).
- `hot_paths_benchmark` times `FlattenService.flatten`, `ViewModeProjection.project` and an incremental toggle through `Flattener`, in microseconds per operation, on a fully expanded forest.
- `flat_list_memory_benchmark` approximates bytes per `FlatNode` by RSS delta with retention, and quantifies what the `ancestorIsLastMask` bitmask saved over a per-node `List<bool>` (#33).
- `max_width_benchmark` measures `RowMetrics.maxWidth` **cold**: labels are salted so the static width cache never hits, which is the case a data change produces (#35, #37).
- **The recorded baselines live in each file's header**, with the machine they were taken on. They are machine-dependent and deliberately not a gate. This map points at them and does not restate them.

## Code
- `benchmark/hot_paths_benchmark.dart` — `FlattenBenchmark`, `ProjectTreeBenchmark`, `IncrementalToggleBenchmark`
- `benchmark/flat_list_memory_benchmark.dart` — `main`
- `benchmark/max_width_benchmark.dart` — `main`

## Reference behaviour
**None.**

## Cross-cutting invariants
None recorded.

## Blast radius
- [flattening](flattening.md) and [view-mode-projection](view-mode-projection.md) — a change to their algorithms or to `FlatNode`'s shape invalidates the recorded baselines.
- [row-geometry](row-geometry.md) — a change to `maxWidth` or the width cache invalidates its baseline.
- [ci-gates](ci-gates.md) — the gate format-checks this folder.

## Known holes / open
- A regression is visible only to someone who runs a benchmark and compares against the header's number by hand.
