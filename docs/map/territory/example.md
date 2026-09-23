# Example

## What it is
The `example/` app. It is built on the `flutter_example_template` shell (menu, preview stage at three widths, Device Wall, Code pane, settings panel), and its purpose is to expose **every** public option of the library (#74). It is a consumer of the library, never a part of it: the dependency on the shell sits in `example/pubspec.yaml` only.

## Governing decisions
**None** as records. Two calls are the maintainer's, made on #75:
- **What counts as an option.** The coverage guard counts the public `final` instance fields of every public class in a file the barrel exports: **158** at #75. The hand count in #74 said 144. It had missed `Node` (5), the eight sub-theme containers of `FlutterFolderViewTheme`, and `FolderViewTheme.data`. The maintainer was shown both counts and chose the mechanical rule.
- **Test helpers live in `example/test/support/`**, so `example/test/` holds only `*_test.dart` files. Neither this repo nor `flutter_table_plus` had a precedent; the maintainer was shown the flat alternative and chose the folder.
- **Windows window size** is 1200×600, wider than `ShellPage.narrowBreakpoint` (900), so the desktop run opens in the three-region layout. Whether `window_manager` stays at all is decided in #91.

## Design model
- **Expand–contract.** The old single-page demo lives on as the "Legacy panel" `RouteDestination` until every option has a home in the shell. #91 removes it. Removing it earlier would take controls away mid-migration.
- **Coverage guard (`option_coverage_test`).** It reads the library's options from source, because Dart has no reflection. It reddens in four cases:
  - an option that is neither covered nor listed;
  - a listed option that does not exist;
  - a listed option that is already covered;
  - a `Class.field` id in the example that names nothing.
  Each entry in the not-yet-covered list carries the issue that owns it, and the list is empty when #74 is done.
- **Option ids.** A settings-spec option or switch id written as `Class.field` *is* that library field; any other id is example-only. One `NodeTooltipTheme.x` id covers all three Tiers, because a Tier selector binds it (#86). There is no mapping table to drift.
- **`show` is not applied** when the guard resolves exports. At #75 the only `show` export (`scale_modifier.dart`) held no class, so a filter guarded nothing, and mutation testing confirmed it. Without the filter, a future `show` that hides a class makes the guard *demand* coverage for it, which is loud, rather than skipping it silently.
- **Recipe seam (`recipe_seam_test`).** It walks `lib/recipes/`, the directory rather than the roster, so a recipe nobody registered is still held to the rule. A Code pane file may import only `dart:`, `package:flutter/` and `package:flutter_folderview/`. Every `StageDestination.source` must be an existing file under `lib/recipes/`.
- **Light mode is pinned** (`ExampleThemeController(ThemeMode.light)`) until #90 wires the `FolderView` theme to the shell's brightness. A dark shell around the default light tree would be a mismatch nobody chose.
- The behaviour seam is the public `FolderView`, read through `renderedFolderView` in `test/support/shell_harness.dart`, never `FolderViewContent` (`CLAUDE.md`).

## Code
- `example/lib/main.dart` — `MyApp`
- `example/lib/app/destinations.dart` — `FolderViewDestinations`
- `example/lib/app/every_setting.dart` — `EverySettingDemo`, `EverySettingStage`
- `example/lib/app/settings_spec.dart` — `settingsSpec`, `recipeCoverage`
- `example/test/option_coverage_test.dart` — `notYetCovered`, `coveredOptions`
- `example/test/support/library_options.dart` — `libraryOptions`, `optionsInSource`
- `example/test/recipe_seam_test.dart` — `allowedImports`, `disallowedImports`
- `example/test/support/shell_harness.dart` — `pumpShell`, `openDestination`, `renderedFolderView`

## Reference behaviour
- `flutter_example_template` **0.2.0**, read from the pub cache source. `PreviewStage` sizes its child with `SizedBox.fromSize(spec.size)` and gives it its own `Overlay`, and `PreviewFrame` scales the whole frame down to fit. Its floor, `flutter >=3.27.0`, is why the example declares the same floor.
- `flutter_table_plus/example`, an *example* to diverge from deliberately. Its `settings_spec_test` and `recipe_seam_test` are the prior art for the guard and the seam. That repo keeps a hand-written spec and settings model in step; this one derives the option list from the library instead.

## Cross-cutting invariants
- [chrome-excluded-from-scale](../invariant/chrome-excluded-from-scale.md) — the settings spec records it as an interaction on Scale (#78).
- [innermost-tooltip-wins](../invariant/innermost-tooltip-wins.md) and [row-wider-than-viewport](../invariant/row-wider-than-viewport.md) — the row-card scenarios (#89) demonstrate both.

## Blast radius
- **Every public field in `lib/`.** Adding, renaming or removing one reddens the example's coverage guard. That is the point, and the change that makes it has to either expose the option or list it with an owning issue.
- [ci-gates](ci-gates.md) — the guard and the seam run in the `example` job. `integration_test/` stays outside it.
- [dependency-floor-release](dependency-floor-release.md) — the example's Flutter floor is the shell's (3.27.0), not the library's (3.13.0).
- [label-tooltip](label-tooltip.md) and [row-card](row-card.md) — both render inside the preview stage's own overlay.

## Known holes
- **Probed on 2026-09-23: a label tooltip in a preview frame.** The probe went through the real `ShellPage` and selected each viewport from its bar. For a Child label with a 300×120 tooltip, the tooltip painted inside the stage's own `Overlay` and scaled with the frame (desktop frame 1008×630 for a 1440×900 spec, tooltip 210×84). It stayed inside the frame in the 7 of 9 cases where it rested: every direction on desktop and tablet, and `top` on mobile. The first probe wrapped `PreviewStage` in a tight `SizedBox`, which overrode `spec.size`, so all three widths measured the same 1400×900. That probe was discarded.
- **Probed on 2026-09-23: a tooltip that fits on neither side flickers.** On mobile with `direction: left` or `right`, it alternated shown and hidden every 50 ms frame (`T-T-T-…`). A control run with a plain 390-wide `MaterialApp` and no shell reproduced it exactly, while at 1440 it stayed shown. So the cause is not the shell: the clamped tooltip covers the pointer, and hover is lost and regained. Placement is `just_tooltip`'s, so it is binding upstream behaviour, and it is not recorded as an issue here.
- The recipe seam walks an empty directory until the first recipe lands. Its import checker is proved on fixtures, and its source check is mutation-tested, but the walk has observed no real file yet.
- `example/integration_test/` runs only locally, one file at a time ([ci-gates](ci-gates.md)).
