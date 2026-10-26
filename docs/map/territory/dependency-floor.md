# Dependency floor

## What it is
What this package promises consumers about versions: the SDK floor and the `just_tooltip` and `flutter_smooth_wheel_scroll` constraints, and the upstream behaviour those constraints deliver. It rarely changes, and when it is wrong nothing local fails; the failure shows up in a consumer's project. What ships and how is [release](release.md).

## Governing decisions
**None.** The reasoning lives in a `pubspec.yaml` comment and the CHANGELOG, not in a record.

## Design model
- **The floor is derived, not chosen.** It is the max of what the dependencies declare (`pubspec.yaml` comment). `just_tooltip 0.5.0` needs Flutter 3.32 / Dart 3.8 (`OverlayPortal.overlayChildLayoutBuilder`; 0.4.2 needed 3.13); `flutter_smooth_wheel_scroll 0.1.3` needs Flutter 3.32 / Dart 3.8 (`SpringDescription.withDurationAndBounce`). So the floor is 3.32 / 3.8 since 0.12.0 (#100), and from `^0.5.1` both dependencies demand it. A caret admits newer minors, so the floor can become false without anyone editing it (#47).
- **Raising the Dart floor past 3.6 changes the formatter.** `dart format` picks the tall style from the language version; the 3.8 raise reformatted 52 of 66 files (measured, #100) and landed as its own `style:` commit (`8eff8da`).
- **Raising the caret floor is what delivers an upstream fix.** `pub` does not re-resolve a lockfile that still satisfies its constraint (measured; CHANGELOG 0.11.2).
- **Dependabot proposes a floor raise; it never takes one** (`.github/dependabot.yml`, #152). The root runs `increase-if-necessary` against a manifest with no committed lockfile, so a PR appears only when a release falls outside a caret, and at `0.x` every sibling minor does. Each such PR is therefore a release decision read against the dependency's own `environment:`, not a chore, and the root gets one PR per dependency. The example's PRs are grouped, because nothing ships from there. Every Dependabot PR is labelled `needs-triage`.
- **Tooltip behaviour is upstream's**: nested suppression (≥ 0.4.0), `bare()` (≥ 0.4.1), clip-aware placement (≥ 0.4.2), one controller per tooltip (0.4.4's `attach` assert), the `tap` mode that replaced the deprecated `enableTap` (≥ 0.5.0), a pointer-transparent `interactive: false` body and a tooltip that follows the local `Theme`, `Directionality` and `MediaQuery` (≥ 0.5.0, drawn through an `OverlayPortal`), and the tooltip's text on its child's semantics plus Escape to dismiss (≥ 0.5.1). Read from the just_tooltip CHANGELOG and source at 0.5.1.

## Code
- `pubspec.yaml` — `environment`, `just_tooltip`, `flutter_smooth_wheel_scroll`
- `.github/dependabot.yml` — `increase-if-necessary`
- `example/pubspec.yaml` — `environment`

## Reference behaviour
`just_tooltip` and `flutter_smooth_wheel_scroll` are **binding**: this package consumes their behaviour, and divergence is a bug here or upstream, never a design choice. Read their source at the resolved version (route in [`thegraph.md`](../../agents/thegraph.md)). No pinned fact store exists.

## Cross-cutting invariants
- [innermost-tooltip-wins](../invariant/innermost-tooltip-wins.md) — arbitrated upstream, so a version bump can change it.

## Blast radius
- [label-tooltip](label-tooltip.md) and [row-card](row-card.md) — their placement and suppression come from the resolved `just_tooltip`.
- [wheel-motion](wheel-motion.md) — the motion and its clamps come from the resolved `flutter_smooth_wheel_scroll`.
- [release](release.md) — the barrel re-exports types from both; an upstream rename is a breaking change here.
- [ci-gates](ci-gates.md) — CI resolves fresh on `stable`, so it never sees a consumer's older lock or the declared floor.
- [example](example.md) — the example's Flutter floor is the max of `flutter_example_template`'s (`>=3.27.0`) and this package's (`>=3.32.0`), so it is 3.32.

## Known holes / open
- An upstream fix that lands *inside* the caret still reaches no one. With no root lockfile, Dependabot has nothing to update until the caret is outgrown, so raising the floor to deliver a fix is still a human's job.
- No gate checks the SDK floor against the dependencies' own floors. #47 found the mismatch by hand.
- `example/pubspec.lock` once fell a release behind the root (refreshed in 0.11.3). Dependabot's monthly example PR is expected to close this, but that has not been observed yet.
