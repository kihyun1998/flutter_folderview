# Example

## What it is
The `example/` app. It is built on the `flutter_example_template` shell (menu, preview stage at three widths, Device Wall, Code pane, settings panel), and its purpose is to expose **every** public option of the library (#74). It is a consumer of the library, never a part of it: the dependency on the shell sits in `example/pubspec.yaml` only.

## Governing decisions
**None** as records. These calls are the maintainer's, each made on the ticket it names:
- **What counts as an option.** The coverage guard counts the public `final` instance fields of every public class in a file the barrel exports: **158** at #75. The hand count in #74 said 144. It had missed `Node` (5), the eight sub-theme containers of `FlutterFolderViewTheme`, and `FolderViewTheme.data`. The maintainer was shown both counts and chose the mechanical rule.
- **Test helpers live in `example/test/support/`**, so `example/test/` holds only `*_test.dart` files. Neither this repo nor `flutter_table_plus` had a precedent; the maintainer was shown the flat alternative and chose the folder.
- **`Node`'s five fields are covered by a recipe, not the settings panel** (#76). They are the data's shape, not knobs. The maintainer was also shown the alternative, a read-only "control" in the panel, and chose the recipe. So `Building a tree` became the first recipe, and the first-recipe seam rules from #74 landed with it.
- **Generated data is strictly Folder → Parent → Child** (#76). The count of each is a setting. The legacy generator's nested-Folder depth was dropped on purpose: the maintainer chose the containment rule in `GLOSSARY.md` over keeping that option.
- **Chrome-excluded-from-Scale starts as a panel note under Scale, and each chrome feature adds its interaction** (#78). The note is the Scale feature's `extrasAfterOptions` text (`scale-note`, pinned by `scale_test`), because the template's `SettingFeature` has no note field. An `Interaction` must name another feature, and at #78 no scrollbar or tooltip feature existed. The maintainer was shown three options: a note now, with the interaction handed to #85 / #86 / #89; a note only; or empty Scrollbar and Tooltip features created early. They chose the first. Scrollbars added theirs in #85. The tooltip features add theirs in #86 and #89, pointing at `scale`.
- **A theme container id is covered by a code-text control** (#79). Examples are `FlutterFolderViewTheme.spacingTheme` and `.nodeStyleTheme`. The control is read-only and shows the sub-theme as the argument a caller writes, as Smooth wheel shows `wheelMotion`. The maintainer was shown two alternatives: changing the guard to count a container as covered once its fields are, which reopens the #75 mechanical rule, or a theming recipe. They chose the control. This is the convention for the container ids in #80–#85. It does not cover the Tier `tooltipTheme` containers, which #86 binds through its Tier selector.
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
- **The shell starts light, and its brightness and the tree's theme are independent** (#90).
  - `ExampleThemeController(ThemeMode.light)` sets only the start mode. The shell's `ThemeModeButton` still cycles it.
  - The tree's theme comes from the Light / Dark presets, and a preset never touches the shell.
  - This was the maintainer's call. They were shown three options: no link; a preset that also sets the shell's mode; or a tree that follows the shell's brightness, resetting the knobs on every toggle. They chose no link.
  - `theme_injection_test` pins it: after Dark, the shell's `Theme` is still light.
- **"Every setting" knob region**: `FeatureListPane` above and the open feature's `FeatureDetailPane` below, over one `EverySettingHost`. `settings_render_test` opens every feature in `settingsSpec` and requires a `SettingsControl` carrying each listed id. That makes "listed in the spec" mean "drawn", which the coverage guard alone cannot check.
- **Count sliders are the example's own `SettingsControl`**, not `buildSliderSetting`. The template's slider hard-codes `divisions: (max - min) / 2`, so it cannot step through integers: over 1..50 it steps by 1.96.
- **Changing the data intersects the Expanded Set with the new ids.** Generated ids (`f1-p2-c3`) share nothing with the demo's, so without the intersection the caller would hand the view ids that name nothing. Switching back to Demo restores the demo's own starting set, because the intersection alone would leave it empty.
- **The open feature lives in `EverySettingDemo`, not in the knob widget's `State`.** The shell discards the knob region when you leave the destination, and in the narrow layout when you switch tabs. Measured by the lens read on #76: 1 → 0 detail panes after a round trip.
- **The counts are disabled (`onChanged: null`) while the data is Demo**, labelled "(Generated only)". A live slider that changes nothing on screen would say nothing about why.
- **"Taps & state" (#77) shows ADR-0002 as behaviour.** Each tap callback has a switch: on installs the example's handler, off passes `null`. With `onNodeTap` off, no tap changes either set, because the library proposes and only the caller applies. The handler toggles expansion for a Folder or Parent and selection for a Child. Rendering honours ADR-0003 (only `ChildNodeRenderer` reads the Selected Set), but `onNodeTap` fires for every Tier, so keeping Folders and Parents out of the set is the handler's job. `selectionMode` (single / multiple) is example-only: the library leaves that choice to the caller. The event log keeps the newest 20 callbacks.
- **What the tap log shows about the library** (read in `CustomInkWell._handleTap` and the two tier renderers):
  - A double tap on a Child logs `onNodeTap` on the first tap, then `onDoubleNodeTap`.
  - A Folder or Parent gets no double tap at all (`clickInterval: 0`, `onDoubleTap: null`), so two quick taps there are two `onNodeTap`s.
  - `onDoubleNodeTap` works without `onNodeTap`, because both renderers always pass `CustomInkWell` a non-null *tap* closure. That clearance holds only while they do: `CustomInkWell` attaches no tap handler when its own `onTap` is null.
  - The mirror case: **without `onDoubleNodeTap`, a Child row has no double-tap window**, so every tap fires `onNodeTap` (#95). `interaction_test` pins it: "with the handler off, a quick second tap is a single tap".
  - Ctrl+tap is always an immediate single tap: two Ctrl-taps inside the window log two `onNodeTap`s.
- **The recipe seam is live from #76**: `lib/recipes/` is non-empty, registered sources and recipe files match in both directions, and every source loads through `rootBundle`, the path the Code pane takes. `lib/recipes/` is declared under pubspec `assets`.
- **"Smooth wheel" (#102) lets the maintainer feel `FolderView.wheelMotion` before a release.** A Motion dropdown (Off / Spring / Curve / Lerp) is the `FolderView.wheelMotion` control, and four example-only knobs feed it. Each knob is disabled unless the chosen motion reads it. The defaults are the library's own, so the stage opens on what a `FolderView` with no `wheelMotion` does. Below the knobs, the current value is shown as the argument a caller would write. There is no recipe for it, which is the maintainer's call: the code text stands in for one. The knobs build their own sliders because the template's slider cannot be disabled. The example takes `flutter_smooth_wheel_scroll` as a dev dependency, so that the test can read the rendered motion's subtype and fields. The library re-exports `WheelMotion` alone.
- **"Scale" (#78) shows ADR-0002 for the Scale.** The `onScaleChanged` switch installs the example's handler, which clamps the proposed value to 0.5–3.0 (the legacy panel's range) because the library clamps nothing. With the handler off, only the slider changes the Scale. `blockModifierScroll` is a three-way dropdown, because the field is `bool?`: Follow handler (`null`), On, Off. What the dropdown reveals, read in `_FolderViewState.build` and pinned by the library's scale-gesture tests:
  - The `Listener` that proposes a Scale exists only while blocking is in effect. So **Off scrolls the list and proposes no Scale**, even with a handler installed.
  - **On blocks the modifier scroll with no handler**, so Ctrl+wheel does nothing at all.
  - The interaction with Smooth wheel: a blocked notch never reaches `SmoothScrollController.pointerScroll` ([scale-input](scale-input.md)).
  The dropdown labels are short because the knob region is 279 px wide at a 1600 px window, and the template's `buildDropdownRow` is a `Row` that overflowed by 21 px with "Block modifier scroll" / "Follow onScaleChanged" (measured at #78).
- **"Layout" (#79) is the first feature to pass `FolderView.theme`.** The stage used to pass none, and the view fell back to `FlutterFolderViewTheme.light()`. The knobs start at `light()`'s values, and the theme is `light().copyWith(...)`, so opening the page changes nothing on screen.
  - **The theme is one instance until a theme knob changes.** The view re-measures content width whenever the effective theme is a new instance ([row-geometry](row-geometry.md)). A theme built per rebuild would re-measure on every tap and every unrelated knob. `layout_test` pins the identity across a non-theme knob (Scale's step): rebuilding without the cache reddens only that test. Every theme knob a later category adds has to clear the cache through `EverySettingDemo._setTheme`, or the stage keeps drawing the stale theme. Since #90 it must also appear in `EverySettingDemo.applyPreset`, which resets it, and in `_matches`, which compares it. Otherwise a preset leaves it behind and the chip stays lit after it moves.
  - **The base is the last preset applied** (#90). `EverySettingDemo.theme` is `base.copyWith(...)`, where the base is `light()` or `dark()`.
- **"Theme injection" and the presets (#90).**
  - **The `PresetBar` sits above the feature list.** Light and Dark each reset *every* theme knob to that factory's values. A preset reads as active only while every knob still equals its factory's, so moving one knob clears the chip, and the base stays.
  - The swatch lists hold both factories' colours, so a reset never lands on a colour the control cannot show.
  - **Injection is a dropdown.** On `theme:` param the stage passes `theme:`. On Ancestor it passes `theme: null` and wraps the view in `FolderViewTheme<String>(data: theme)`, because `FolderView` prefers its parameter.
  - **Switching the path remounts the view.** The `FolderViewTheme` parent comes and goes at the view's slot, so `FolderView`'s state starts over: scroll and hover are lost. A `GlobalKey` would keep it, but Every setting allows the Device Wall, which builds the stage three times, so one key would collide. The remount is accepted.
  - **Compare the two paths under Dark.** Under Light, an ancestor the view failed to find falls back to `light()` and would look identical. `theme_injection_test` therefore asserts the dark label colour on the ancestor path. Mutating the ancestor to `FolderViewTheme<dynamic>` reddens it ([theme-composition](theme-composition.md) Known holes).
  - `contentPadding` is one control with a slider per side, because the field is a single `EdgeInsets`.
  - **`FlutterFolderViewTheme.animationDuration` changes nothing on screen**, because the library reads it nowhere ([theme-composition](theme-composition.md) Known holes). The slider is there for coverage, and the panel note says so.
  - The rest is visible in the rendered rows' `ListView`: `itemExtent` is `rowHeight + rowSpacing`, and `padding` is `contentPadding`. `borderRadius` rounds the `Ink` and `InkWell` of every row.
- **"Tree lines" (#80) asserts what is painted.** `lines_test` records the rendered `FolderView`'s `drawLine` calls with `flutter_test`'s `paints` matcher.
  - Each knob is checked against the strokes drawn: a `connector` draws a horizontal stub, `scope` draws verticals only, and `none` draws no line at all. The same holds in Tree Mode, where the lifted Parents are roots and draw no connector, so only Children do.
  - `lineColor` is a row of swatches: the template has no colour control, so the swatches follow the legacy panel's `colorRow`. The first swatch is `light()`'s grey.
  - **Compare a painted colour by `toARGB32()`, not `==`.** `Paint` stores its colour as Float32, so `paint.color == Color(0xFF9E9E9E)` is false even though both print the same channels. Measured at #80.
- **"Folder tier" (#82) is its own group, mirrored later by Parent and Child** (ADR-0005; #74). It has three features: Folder icons, Folder label and Folder ink. Its state is `_folder*` fields on `EverySettingDemo`, and no tier abstraction is shared with #83 or #84.
  - **The resolver samples act on a Folder that holds a single Parent.** In the demo data that is Folder 3, the long-label one. The samples swap its icons and restyle its label. The label resolver appends every Folder's Parent count. The rule was first confirmed as "more than 2 Parents", but the demo Folders hold 2, 2 and 1, so it would have shown nothing. The single-Parent rule is that correction, derived from the data and then accepted by the maintainer.
  - `textStyle` is three controls (colour, font size, bold), because the field is a whole `TextStyle`. A preset resets them to the factory style's colour and size, and to whether it is bold.
  - The splash and highlight swatches are built with `Colors.blue.withValues(alpha: …)`, as the factories do. A `const Color(0x4D…)` has alpha 77/255, not 0.3, so it would never equal them.
  - **Measured-equals-rendered needs a window, and the window has two edges.** A row is cut only when the content is wider than the view and narrower than `SizeService`'s 3× cap. On desktop the long Folder fits, so nothing can be cut. Measured at #82 with the label resolver on:
  - In the mobile frame (view 390 px, cap 1170), the long Folder's row measured 1194.3 px. It was clamped to 1170, and the label, which needs 1154.3 px, was laid out at 1130 and cut, whatever the measurement said.
  - In the tablet frame (view 834 px, cap 2502), the same row fits.

  The resolver tests run in the tablet frame and assert both edges first, through `_expectFitsInWindow`: the label is wider than the view, and well under the cap. On desktop, the `lib/` mutation that measures `node.label` instead of the resolved label survived. In the tablet frame it reddens, and switching the frame to mobile fails the cap edge.
  - The style half was not true yet at #82, because a bold-only sample cannot change a width (see below).
  - Since #83 the sample also sets `fontSize: 16`, and a `maxWidth` that ignores the Folder style resolver reddens.
  - The #82 mutation that reddened then also changed the rendered style.
- **"Parent tier" (#83) mirrors the Folder tier**, with its own `_parent*` fields, `ParentOpenWidget` and swatch lists (ADR-0005).
  - **A Parent shows `openWidget` only in Tree Mode** (`useOpenState: mode == ViewMode.tree`). Both factories leave it unset, so the Factory choice means none, and the openWidget test runs in Tree Mode.
  - **The resolver samples act on a Parent that holds two Children**: 1-2 and 3-1 in the demo data, counted first.
  - **The Parent tests assert no measurement.** They check the resolved text and style only. A window does exist for the label alone: the widest Parent label is 527.3 px, past the 390 px mobile view. But a Parent row never sets the content width (two bullets down), so a short measurement of it cuts nothing.
- **"Node tooltips" → "Tooltip placement" (#86): one set of controls bound to a chosen Tier.**
  - `NodeTooltipTheme` is one library class shared by the three Tier themes. The example therefore keeps one `TooltipSettings` per Tier and binds a single set of controls to the Tier picked in `tooltipTier`. This is what #74 asked for, and it does not breach ADR-0005, which is about the three tier themes, not their shared tooltip class. #87 and #88 add their controls to the same binding.
  - **A label tooltip needs content, or there is no `JustTooltip` at all** (`wrapWithNodeTooltip`). So each Tier starts with a sample message, "Folder tooltip" and so on, which #87 made a `message` choice.
  - A Tier with `useTooltip` off gets `tooltipTheme: null`, as both factories leave it. So a preset resets all three `TooltipSettings`, and `_matches` requires each to be off. It does not require the rest at their defaults: while `useTooltip` is off, nothing else is drawn, so a hidden setting moved keeps the preset.
  - The tests read the rendered `JustTooltip`'s fields for every setting. They also hover a label in the Room: the tooltip is above with `top` and below with `bottom`, `offset` is the gap, and `anchor: pointer` centres it near the pointer on the long Folder 3 label. One case per `testWidgets`, per the hover-harness traps in `test/widgets/node_tooltip_anchor_placement_test.dart`.
  - `JustTooltip` is not re-exported, so the example takes `just_tooltip` as a dev dependency for its tests, as it does `flutter_smooth_wheel_scroll`.
- **"Node tooltips" → "Tooltip content & surface" (#87): the same binding, in its own feature.**
  - Option ids are unique across the spec (`settings_spec_test`), so `tooltipTier` cannot appear twice. The feature has its own Tier dropdown, `tooltipSurfaceTier`, bound to the same `tooltipTier` state: choosing a Tier in either moves both. The maintainer chose this over merging the 12 fields into Tooltip placement, which would have reached about 40 controls in one feature once #88 lands. This was a judgement, made on those two options, and #88 follows it.
  - **Content is chosen resolver, then builder, then message** (`wrapWithNodeTooltip`). A resolved builder sends `message: null` to `JustTooltip`. The resolver samples follow the Tier rules: a Folder with a single Parent, a Parent with two Children, and a "(Future)" Child. Every other Node returns `null` and falls back.
  - **`hideOnEmptyMessage` has no visible effect through `FolderView`.** With no builder and an empty or `null` message, `wrapWithNodeTooltip` returns the bare label. With a builder, `JustTooltip._hasContentOf` (just_tooltip 0.4.4) counts it as content. So `false` can never surface an empty tooltip. The prefilter dates from `0658a60`, before the option arrived in 0.6.8. The test pins that the field reaches `JustTooltip`, and that an empty message leaves no `JustTooltip` even with the option off.
  - **A surface setting left `null` takes `wrapWithNodeTooltip`'s literal fallback**: background `0xFF616161`, elevation 4, radius 6, padding 12/8, border width 0. A slider or the padding control shows that fallback; a colour left `null` shows the empty swatch. The code text writes only what has been set. `message` is an enum choice, because the template's `buildDropdownRow` drops a `null` item: its `onChanged` runs only for a non-null value. `boxShadow` replaces the `Material` elevation with a `DecoratedBox`, and a border is drawn only when `borderColor` is set and `borderWidth > 0` (`just_tooltip_overlay.dart`). The Room tests read the painted `Material` and `DecoratedBox` without the arrow; with `showArrow` on, the surface goes through `TooltipShapePainter` instead.
- **"Child tier" (#84) completes the mirror**, with its own `_child*` fields (ADR-0005). It has four features: Child icons, Child label, Child selection and Child ink.
  - A Child has no `openWidget`.
  - **`selectedTextStyle` is merged over the Child's own style**, and `selectedTextStyleResolver`, where it returns a style, is merged instead. The test proves the merge with a non-default label size: 18 is kept when selected. Under a renderer that replaced the style, the size fell back to 14, so the test reddens.
  - The resolver samples act on a Child whose label ends in "(Future)" (1-1-2 and 1-1-3).
  - `clickInterval` is tested through the Taps & state log. Two taps 200 ms apart are a double tap at 300 ms and two single taps at 100 ms.
  - **A Child never sets the content width either.** The widest Child label is 570 px, so its row is about 650 px, under Folder 3's 1137 px. The Child tests assert drawn text and style only, as the Parent tests do.
- **The test font is as wide bold as regular.** Bold left the long Folder label at exactly 1097.3 px, so a bold-only style resolver can never change a width in a widget test. The tier resolver samples therefore also set `fontSize: 16`. With that, the Folder test catches a `maxWidth` that ignores the Folder style resolver.
- **A Parent's measurement is not testable from the shell, for its label or its style.** `maxWidth` walks every Node, including collapsed ones, and the demo's long Folder 3 row is always the widest. A Parent row never sets the content width, so under-measuring it cuts nothing. Generated labels give no window either.
  - Two measurement-only `lib/` mutations survive the Parent tests for this reason (classified: vacuous window): `_rowWidth` measuring `node.label`, and `maxWidth` ignoring the Parent style resolver.
  - A mutation of `RowMetrics.label` does redden, but through the rendered text, not the measurement.
  - The Folder tests cover the shared label path and the Folder branch of the style switch.
- **"Scrollbars" (#85).**
  - **The bars show only on hover.** At `light()`'s `nonHoverOpacity` of 0 they are hidden until the pointer is over the tree, so `scrollbar_test` drives a mouse pointer.
  - The thumb is asserted where it is painted: the `Scrollbar`'s `drawRRect` carries `thumbColor`, and its rect is `thickness` wide with `radius` corners.
  - **The data must scroll for a thumb to exist**, so the tests take Generated data and Expand all first.
  - The note states the two tracks plainly ([scroll-sync](scroll-sync.md) Known holes).
- **"Expand icon" (#81).**
  - **The widget switch installs an uncoloured `Icons.arrow_right`.** `light()`'s chevron sets its own grey, so `color` and `expandedColor` don't reach it ([tier-rendering](tier-rendering.md) Known holes). The panel note says so, and `expand_icon_test` pins both sides: with the sample, expanded rows take `expandedColor` and the others take `color`; `light()`'s chevron stays grey whatever they say. The colour swatches start with `null`, meaning not set.
  - Width, horizontal padding and horizontal margin are asserted by one rule: each moves a Child's label by the same amount, because their sum is the indent unit. Height does not move it.
  - **A painted glyph is read per row, not per widget.** `const Icon` instances are one object, so `find.byWidget(icon)` matches every row. Read each `RichText` whose text is the glyph, then pick the one nearest the row.
- **`openFeature` scrolls the lazy feature list from the top until the entry is built** (#81). With "Expand icon" ahead of it, "Tree lines" was no longer built while a feature was open, so `ensureVisible` found nothing.
- **`openFeature` settles after `ensureVisible`, before it taps.** Without the settle, an entry low in the feature list is tapped where it was before the scroll. With a feature open, the list pane ends at y = 527.5 on a 1000 px window, so "Tree lines" sat at 533–546, under the detail pane. Measured at #80. Earlier tests passed only because their entries were already in view.
- The behaviour seam is the public `FolderView`, read through `renderedFolderView` in `test/support/shell_harness.dart`, never `FolderViewContent` (`CLAUDE.md`).

## Code
- `example/lib/main.dart` — `MyApp`
- `example/lib/app/destinations.dart` — `FolderViewDestinations`
- `example/lib/app/every_setting.dart` — `EverySettingDemo`, `EverySettingStage`
- `example/lib/app/settings_spec.dart` — `settingsSpec`, `recipeCoverage`
- `example/lib/app/every_setting_host.dart` — `EverySettingHost`
- `example/lib/app/every_setting.dart` — `DataSource`, `EverySettingKnobs`
- `example/lib/app/tree_generator.dart` — `generateTree`
- `example/lib/recipes/building_a_tree_recipe.dart` — `BuildingATreeRecipe`
- `example/lib/scenarios/large_tree_scenario.dart` — `LargeTreeDemo`, `LargeTreeStage`
- `example/test/settings_render_test.dart` — every spec id draws a control
- `example/test/settings_spec_test.dart` — unique ids, interactions name another feature and cite evidence
- `example/test/interaction_test.dart` — tap callbacks, handler switches, Selected and Expanded Set
- `example/lib/app/every_setting.dart` — `WheelMotionKind`, `WheelCurveOption`, `EverySettingDemo.wheelMotion`, `EverySettingDemo.wheelMotionCode`
- `example/lib/app/every_setting.dart` — `ModifierScrollBlock`, `EverySettingDemo.handleScaleChanged`, `EverySettingDemo.blockModifierScroll`
- `example/lib/app/every_setting.dart` — `EverySettingDemo.theme`, `EverySettingDemo.spacingThemeCode`, `EverySettingDemo.nodeStyleThemeCode`
- `example/lib/app/every_setting.dart` — `EverySettingDemo.lineColors`, `EverySettingDemo.lineThemeCode`
- `example/lib/app/every_setting.dart` — `EverySettingDemo.expandIconColors`, `EverySettingDemo.sampleExpandIcon`, `EverySettingDemo.expandIconThemeCode`
- `example/lib/app/every_setting.dart` — `EverySettingDemo.scrollbarThumbColors`, `EverySettingDemo.scrollbarTrackColors`, `EverySettingDemo.scrollbarThemeCode`
- `example/lib/app/every_setting.dart` — `ThemePreset`, `ThemeInjection`, `EverySettingDemo.applyPreset`, `EverySettingDemo.activePreset`, `EverySettingDemo.injectionCode`, `EverySettingStage`
- `example/lib/app/every_setting_host.dart` — `EverySettingHost.presets`, `EverySettingHost.applyPreset`
- `example/lib/app/every_setting.dart` — `FolderOpenWidget`, `EverySettingDemo.folderThemeCode`, `EverySettingDemo._folderMatches`, `EverySettingDemo.sampleFolderIcon`
- `example/lib/app/every_setting.dart` — `ParentOpenWidget`, `EverySettingDemo.parentThemeCode`, `EverySettingDemo._parentMatches`
- `example/lib/app/every_setting.dart` — `EverySettingDemo.childThemeCode`, `EverySettingDemo._childMatches`, `EverySettingDemo.sampleChildIcon`
- `example/lib/app/tooltip_settings.dart` — `TooltipTier`, `TooltipSettings`
- `example/lib/app/every_setting.dart` — `EverySettingDemo.tooltip`, `EverySettingDemo.editTooltip`, `EverySettingDemo.folderTooltip`
- `example/test/tooltip_placement_test.dart` — Tier isolation, every placement field on the rendered `JustTooltip`, hover placement in the Room at 1:1, the Tier container code, presets
- `example/test/tooltip_surface_test.dart` — the shared Tier dropdown, every surface field on the rendered `JustTooltip`, the content precedence and the per-Tier resolver, empty-message suppression, the painted surface in the Room, the code text, presets
- `example/test/child_tier_test.dart` — Child glyphs per row, the icon box, label style and resolvers, the selection merge and background, the ink, clickInterval through the tap log, presets, the code text
- `example/test/parent_tier_test.dart` — Parent glyphs per row (openWidget in Tree Mode), the icon box, label style and resolvers (in the mobile frame), the ink, presets, the code text
- `example/test/folder_tier_test.dart` — Folder glyphs per row, the icon box, the label style and resolvers (in the tablet frame), the ink, presets, the code text
- `example/test/theme_injection_test.dart` — presets reset and release, both injection paths under Dark, the code text, the shell untouched
- `example/test/scrollbar_test.dart` — hover fade, the track box, the painted thumb, Material's track, the bar at Scale 2, the code text
- `example/test/expand_icon_test.dart` — glyph colours per row, the indent unit, the sample switch, the code text
- `example/test/lines_test.dart` — the line knobs reach the painted strokes in both View Modes; the `lineTheme` code text
- `example/test/layout_test.dart` — the Layout controls reach the rendered theme and rows; the theme instance is kept; the container code text
- `example/test/scale_test.dart` — the Scale controls reach the rendered `FolderView`; Ctrl+wheel proposes, the handler clamps, blocking decides scroll versus Scale
- `example/test/room_test.dart` — the Room draws a `FolderView` at 1:1, desktop scales it down
- `example/test/smooth_wheel_test.dart` — the Motion dropdown and knobs reach the rendered `wheelMotion`, and the code text matches
- `example/test/option_coverage_test.dart` — `notYetCovered`, `coveredOptions`
- `example/test/support/library_options.dart` — `libraryOptions`, `optionsInSource`
- `example/test/recipe_seam_test.dart` — `allowedImports`, `disallowedImports`
- `example/test/support/shell_harness.dart` — `pumpShell`, `openDestination`, `openFeature`, `chooseDropdown`, `setSlider`, `renderedFolderView`

## Reference behaviour
- `flutter_example_template` **0.3.0** (#108), read from the pub cache source. In the framed modes, `PreviewStage` sizes its child with `SizedBox.fromSize(spec.size)` and gives it its own `Overlay`, and `PreviewFrame` scales the whole frame down to fit. The **Room** (`ViewportBar.roomId`, offered on every destination by `ShellPage`) is `PreviewRoom`: the stage region at its own size, unscaled. Its `MediaQuery` says that box is the whole screen, and it adds no `Overlay` of its own (#109, read from the 0.3.0 source). `ShellPage` builds it as `PreviewRoom(child: Builder(builder: open.stage))`, where the framed modes go through `PreviewStage` and its `_ContainedOverlay`. So in the Room, `Overlay.of` from a tooltip is the app's root `Overlay`: the whole window, over the shell's menu and knob region, not the stage region. In a frame, a tooltip is contained by the frame; in the Room, only by the window. The label-tooltip half is pinned by `tooltip_placement_test` (#86): in the Room a hovered label's tooltip paints at 1:1, and its nearest `Overlay` is the app's root one. Its laid-out width equals its painted width, 199.5 px; without the Room, it painted at 139.65 in the 0.7× frame. "Inside the window" alone proves nothing, because a framed stage's `Overlay` is inside the window too. The row card's Room case rides on #89. `room_test` measures the rendered `FolderView` at scale 1 in the Room and below 1 in desktop. Its floor is `flutter >=3.27.0`; the example declares the library's higher 3.32.0.
- `flutter_table_plus/example`, an *example* to diverge from deliberately. Its `settings_spec_test` and `recipe_seam_test` are the prior art for the guard and the seam. That repo keeps a hand-written spec and settings model in step; this one derives the option list from the library instead.

## Cross-cutting invariants
- [chrome-excluded-from-scale](../invariant/chrome-excluded-from-scale.md):
  - The Scale feature's panel note (`scale-note`) states it (#78).
  - In the spec, it is the Scrollbars feature's interaction with `scale` (#85). `scrollbar_test` pins the bar's width at Scale 2, and a mutation that scales `scrollbarTheme` reddens it.
  - The label-tooltip half is the Tooltip placement feature's interaction with `scale` (#86). The row card's half becomes one in #89.
- [innermost-tooltip-wins](../invariant/innermost-tooltip-wins.md) and [row-wider-than-viewport](../invariant/row-wider-than-viewport.md) — the row-card scenarios (#89) demonstrate both.

## Blast radius
- **Every public field in `lib/`.** Adding, renaming or removing one reddens the example's coverage guard. That is the point, and the change that makes it has to either expose the option or list it with an owning issue.
- [ci-gates](ci-gates.md) — the guard and the seam run in the `example` job. `integration_test/` stays outside it.
- [dependency-floor-release](dependency-floor-release.md) — the example's Flutter floor is the library's (3.32.0), above the shell's (3.27.0).
- [label-tooltip](label-tooltip.md) and [row-card](row-card.md) — both render inside the preview stage's own overlay.

## Known holes
- **Probed on 2026-09-23: a label tooltip in a preview frame.** The probe went through the real `ShellPage` and selected each viewport from its bar. For a Child label with a 300×120 tooltip, the tooltip painted inside the stage's own `Overlay` and scaled with the frame (desktop frame 1008×630 for a 1440×900 spec, tooltip 210×84). It stayed inside the frame in the 7 of 9 cases where it rested: every direction on desktop and tablet, and `top` on mobile. The first probe wrapped `PreviewStage` in a tight `SizedBox`, which overrode `spec.size`, so all three widths measured the same 1400×900. That probe was discarded.
- **Probed on 2026-09-23: a tooltip that fits on neither side flickers.** On mobile with `direction: left` or `right`, it alternated shown and hidden every 50 ms frame (`T-T-T-…`). A control run with a plain 390-wide `MaterialApp` and no shell reproduced it exactly, while at 1440 it stayed shown. So the cause is not the shell: the clamped tooltip covers the pointer, and hover is lost and regained. Placement is `just_tooltip`'s, so it is binding upstream behaviour, and it is not recorded as an issue here.
- **Probed on 2026-09-23: regenerating on every slider tick.** In Generated mode each count change rebuilds the tree, and at the maximum 50×50×50 (125k nodes) `generateTree` takes 29 ms. A whole tick, including the rebuild, takes 115 ms after warm-up (measured by the assay read on #76), and a drag pays that per tick. It is left as is, because the default counts are far below that.
- **Probed on 2026-09-23: the scenario is created only when opened.** `dispose` used to reach through a `late final`, so it generated the 100k tree just to dispose it: 26–32 ms per `FolderViewDestinations` created and disposed without opening the scenario. With a nullable field it is 0–1 ms.
- **Probed on 2026-09-23: the Device Wall over the 100k-child scenario** (widget test, debug JIT). Opening the scenario takes 72 ms in one viewport and 232 ms on the wall (3.2×). "Every setting" takes 81 / 116 ms. Ten steady frames take 2–3 ms either way, because rows are virtualized, so only the one-time open triples. `allowsWall` stays on. This is a relative number from a test binding, not a profile-mode frame time.
- `example/integration_test/` runs only locally, one file at a time ([ci-gates](ci-gates.md)).
