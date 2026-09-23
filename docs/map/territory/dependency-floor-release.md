# Dependency floor and release

## What it is
What this package promises consumers about versions: the SDK floor, the `just_tooltip` constraint, what the barrel re-exports from it, and how a version reaches pub.dev. It rarely changes, and when it is wrong nothing local fails. The failure shows up in a consumer's project.

## Governing decisions
**None.**

The reasoning lives in the CHANGELOG entries and a comment in `pubspec.yaml`, not in a record.

## Design model
- **The floor is derived, not chosen.** The Flutter floor comes from `just_tooltip 0.4.2`, whose ancestor clip walk needs `RenderObject.parent` to have a type that exists from Flutter 3.13. A caret admits newer minors, so the floor can become false without anyone editing it (#47).
- **Raising the caret floor is what delivers an upstream fix.** `pub` does not re-resolve a lockfile that still satisfies its constraint (measured; CHANGELOG 0.11.2).
- **The barrel re-exports a chosen subset** of `just_tooltip`. `TooltipRegistry` is withheld on purpose because no use case exists yet. `TooltipAnchor` was withheld until a field could use it (#42).
- Tooltip *behaviour* comes from `just_tooltip`: nested suppression (≥ 0.4.0), `bare()` (≥ 0.4.1), clip-aware placement (≥ 0.4.2).
- Publishing is irreversible and is run by the maintainer, not an agent. `.pubignore` exists, which turns off git-based file listing. The CHANGELOG entry of a published version is superseded by a new entry, never rewritten; an *unpublished* version's entry is still editable (0.11.0's cause was corrected before it shipped). `dart pub publish --dry-run` must show 0 warnings.

## Code
- `lib/flutter_folderview.dart` — `TooltipAnchor`, `JustTooltipTheme`, `JustTooltipController`, `isScaleModifierPressed`
- `pubspec.yaml` — `just_tooltip`, `environment`
- `CHANGELOG.md` — `just_tooltip`

## Reference behaviour
`just_tooltip` is **binding**: this package consumes its behaviour, and divergence is a bug here or upstream, never a design choice. Read its source at the resolved version (the route is in [`thegraph.md`](../../agents/thegraph.md)). No pinned fact store exists.

## Cross-cutting invariants
- [innermost-tooltip-wins](../invariant/innermost-tooltip-wins.md) — arbitrated upstream, so a version bump can change it.

## Blast radius
- [label-tooltip](label-tooltip.md) and [row-card](row-card.md) — their placement and suppression come from the resolved `just_tooltip`.
- [ci-gates](ci-gates.md) — CI resolves fresh, so it never sees a consumer's older lock.
- [example](example.md) — the example's Flutter floor is `flutter_example_template`'s (`>=3.27.0`), above this package's (`>=3.13.0`). Raising this package's floor past 3.27 moves the example's floor too.

## Known holes
- `example/pubspec.lock` is refreshed only when someone runs `pub get` in `example/` and commits the result. It fell a release behind the root once (refreshed in 0.11.3).
- No gate checks the SDK floor against the dependency's own floor. #47 found the mismatch by hand.
