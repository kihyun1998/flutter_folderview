# Release

## What it is
What reaches a consumer and how: the barrel's public surface (including what it re-exports from upstream), the files `.pubignore` lets into the archive, the CHANGELOG entry, and publishing to pub.dev. The version constraints the package declares are [dependency-floor](dependency-floor.md).

## Governing decisions
**None.**

## Design model
- **The barrel re-exports a chosen subset of upstream** (`lib/flutter_folderview.dart`). From `just_tooltip`: `TooltipDirection`, `TooltipAlignment`, `TooltipAnchor`, `TooltipAnimation`, `JustTooltipController`, `JustTooltipTheme`. `TooltipRegistry` is withheld because no use case exists yet; `TooltipAnchor` was withheld until a field could use it (#42); `JustTooltip` itself is not re-exported, which is why the example takes `just_tooltip` as a dev dependency. From `flutter_smooth_wheel_scroll`: `WheelMotion` alone, the type of `FolderView.wheelMotion` (#101); `SmoothScrollController` and `SmoothWheelBinding` are app-level. `scale_modifier.dart` is exported with `show isScaleModifierPressed`.
- **`.pubignore` replaces `.gitignore` for pub**, so it mirrors the build artifacts and adds the repo-only content: `.github/`, `.claude/`, `docs/`, `benchmark/`, `CLAUDE.md`, `GLOSSARY.md` (its comments). It also clears the "rename docs/ to doc/" layout warning.
- Before a release, run `pub-ready`.
- Before a release the maintainer runs the example and eyeballs hover, because an agent cannot hover ([`release.md`](../../agents/release.md)).
- **A published version's CHANGELOG entry is superseded by a new entry, never rewritten**; an unpublished version's entry is still editable (0.11.0's cause was corrected before it shipped). Each entry says, per change, what a consumer sees differently (CHANGELOG 0.12.0's "What a consumer sees differently" lines).
- A breaking change is marked `!` in the commit subject and **BREAKING** in the CHANGELOG (for example `2ad0a2a`, #133).

## Code
- `lib/flutter_folderview.dart` — the barrel
- `.pubignore`
- `CHANGELOG.md`
- `pubspec.yaml` — `version`

## Reference behaviour
**None.**

## Cross-cutting invariants
None recorded.

## Blast radius
- [dependency-floor](dependency-floor.md) — a re-exported upstream type ties this package's API to that dependency's major version.
- [example](example.md) — the coverage guard counts the public fields of every class the barrel exports, so a new export demands example coverage.
- [ci-gates](ci-gates.md) — no gate runs `pub publish --dry-run`.

## Known holes / open
- No gate runs `dart pub publish --dry-run`; the 0-warning rule is checked by hand.
