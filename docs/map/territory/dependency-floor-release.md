# Dependency floor and release

## What it is
What this package promises consumers about versions: the SDK floor, the `just_tooltip` and `flutter_smooth_wheel_scroll` constraints, what the barrel re-exports from them, and how a version reaches pub.dev. It rarely changes, and when it is wrong nothing local fails. The failure shows up in a consumer's project.

## Governing decisions
**None.**

The reasoning lives in the CHANGELOG entries and a comment in `pubspec.yaml`, not in a record.

## Design model
- **The floor is derived, not chosen.** It is the max of what the dependencies declare. `just_tooltip 0.4.2` needs Flutter 3.13: its ancestor clip walk needs `RenderObject.parent` to have a type that exists from there. `flutter_smooth_wheel_scroll 0.1.3` needs Flutter 3.32 / Dart 3.8 (`SpringDescription.withDurationAndBounce`). So the floor is 3.32 / 3.8 since 0.12.0 (#100). A caret admits newer minors, so the floor can become false without anyone editing it (#47).
- **Raising the Dart floor past 3.6 changes the formatter.** `dart format` picks the tall style from the language version, so the 3.8 raise reformatted 52 of 66 files (measured, #100). It landed as its own `style:` commit.
- **Raising the caret floor is what delivers an upstream fix.** `pub` does not re-resolve a lockfile that still satisfies its constraint (measured; CHANGELOG 0.11.2).
- **The barrel re-exports a chosen subset** of `just_tooltip`. `TooltipRegistry` is withheld on purpose because no use case exists yet. `TooltipAnchor` was withheld until a field could use it (#42). From `flutter_smooth_wheel_scroll` it re-exports `WheelMotion` alone, the type of `FolderView.wheelMotion` (#101). `SmoothScrollController` and `SmoothWheelBinding` are app-level and are not re-exported.
- **Dependabot proposes a floor raise; it never takes one.** The root runs `increase-if-necessary` against a manifest with no committed lockfile, so a PR appears only when a release falls outside a caret, and at `0.x` every sibling minor does. That is the floor decision the first bullet describes, so each such PR is a release decision read against the dependency's own `environment:`, not a chore. The root gets one PR per dependency for that reason. The example's PRs are grouped, because nothing ships from there.
- Tooltip *behaviour* comes from `just_tooltip`: nested suppression (≥ 0.4.0), `bare()` (≥ 0.4.1), clip-aware placement (≥ 0.4.2).
- Publishing is irreversible and is run by the maintainer, not an agent. `.pubignore` exists, which turns off git-based file listing. The CHANGELOG entry of a published version is superseded by a new entry, never rewritten; an *unpublished* version's entry is still editable (0.11.0's cause was corrected before it shipped). `dart pub publish --dry-run` must show 0 warnings.

## Code
- `lib/flutter_folderview.dart` — `TooltipAnchor`, `JustTooltipTheme`, `JustTooltipController`, `isScaleModifierPressed`, `WheelMotion`
- `pubspec.yaml` — `just_tooltip`, `flutter_smooth_wheel_scroll`, `environment`
- `CHANGELOG.md` — `just_tooltip`
- `.github/dependabot.yml` — `increase-if-necessary`

## Reference behaviour
`just_tooltip` is **binding**: this package consumes its behaviour, and divergence is a bug here or upstream, never a design choice. Read its source at the resolved version (the route is in [`thegraph.md`](../../agents/thegraph.md)). No pinned fact store exists.

## Cross-cutting invariants
- [innermost-tooltip-wins](../invariant/innermost-tooltip-wins.md) — arbitrated upstream, so a version bump can change it.

## Blast radius
- [label-tooltip](label-tooltip.md) and [row-card](row-card.md) — their placement and suppression come from the resolved `just_tooltip`.
- [ci-gates](ci-gates.md) — CI resolves fresh, so it never sees a consumer's older lock.
- [example](example.md) — the example's Flutter floor is the max of `flutter_example_template`'s (`>=3.27.0`) and this package's (`>=3.32.0` since 0.12.0), so it is 3.32.

## Known holes
- `example/pubspec.lock` was refreshed only when someone ran `pub get` in `example/` and committed the result. It fell a release behind the root once (refreshed in 0.11.3). Dependabot's monthly example PR is expected to close this hole, but that has not been observed yet.
- An upstream fix that lands *inside* the caret still reaches no one. With no root lockfile, Dependabot has nothing to update until the caret is outgrown, so the third design bullet is still a human's job.
- No gate checks the SDK floor against the dependency's own floor. #47 found the mismatch by hand.
