## 0.12.0

- **feat**: a mouse-wheel notch over the view animates to its target instead of jumping ([#100](https://github.com/kihyun1998/flutter_folderview/issues/100)). The main vertical and horizontal scroll controllers are now `SmoothScrollController`s from `flutter_smooth_wheel_scroll`, moving as `WheelMotion.spring()`: 400 ms, no bounce. The scrollbars follow the list on every frame of a motion. Trackpad scrolling, dragging, the scrollbar and programmatic jumps behave as before.
  - **What a consumer sees differently.** After a wheel notch, the scroll offset reaches its target over several frames, not at once. A widget test that wheel-scrolls and reads the offset after a single `pump` now has to pump until the motion settles.
  - The Scale Modifier + wheel anywhere over the view still proposes a Scale and, while `blockModifierScroll` is in effect, does not scroll.
- **feat**: `FolderView.wheelMotion` chooses how the wheel moves the view ([#101](https://github.com/kihyun1998/flutter_folderview/issues/101)). The default is `WheelMotion.spring()`. Other options are `WheelMotion.spring(duration:, bounce:)`, `WheelMotion.curve(duration:, curve:)` with any `Curve`, and `WheelMotion.lerp(timeConstant:)`. `null` moves the view at once on every notch, as before 0.12.0.
  - It can change at runtime. The next notch uses the new motion, and the scroll position is kept.
  - `WheelMotion` is re-exported, so no import of `flutter_smooth_wheel_scroll` is needed. How far a notch travels is app-wide, through `SmoothWheelBinding` in that package, and this one does not install it.
- **fix**: after horizontal scrolling, a row takes taps and hovers across its whole visible width ([#136](https://github.com/kihyun1998/flutter_folderview/issues/136)). The rows were painted shifted, but hit testing stopped at the first viewport-width of the row. Past that point a tap fired no `onNodeTap` and selected nothing, and a hover raised no row card. Scrolled to the end, the visible part of every row was dead. Reproduced in a 400 px view scrolled by 300: a tap at x 320 inside the row worked, and at 500 it did nothing.
  - **Also fixed:** a row's widget state is no longer rebuilt each time the horizontal offset leaves or returns to 0. Before, a stateful node icon was created again on every such crossing.
  - **What a consumer sees differently.** Taps, double taps, secondary taps, hovers and tooltips now reach the rows wherever they are visible after a horizontal scroll. Painting and layout are unchanged.
- **fix**: while the modifier scroll is blocked, Ctrl/Cmd+wheel over a scrollbar no longer scrolls ([#114](https://github.com/kihyun1998/flutter_folderview/issues/114)). Reproduced in a 400 px view with `onScaleChanged` set: one 300 px Ctrl+wheel notch over the vertical scrollbar proposed a Scale **and** scrolled the view by 300. A sideways notch over the horizontal scrollbar scrolled it too. Now the notch proposes the Scale and moves nothing, as it already did over the rows.
  - **What a consumer sees differently.** Ctrl/Cmd+wheel zooms only, wherever the pointer is over the view. A wheel over a scrollbar without the modifier still scrolls at once. Dragging a thumb works with or without the modifier held. With `blockModifierScroll: false`, nothing changes.
- **fix**: with `rowSpacing` above 0, the connector line meets the row at its content's centre ([#118](https://github.com/kihyun1998/flutter_folderview/issues/118)). The horizontal stub, and a last child's vertical end, were drawn at `rowHeight / 2`, but each row is `rowHeight + rowSpacing` tall with its content centred in it. At `rowHeight` 40 and `rowSpacing` 10, the stub sat at y 20 against a label centred at y 25. It is now at 25. With `rowSpacing` 0 nothing changes.
  - `rowSpacing`'s documentation now says what it is: extra height added to every row, not an empty gap between rows.
- **fix**: `ExpandIconTheme.color` and `expandedColor` take effect on `light()` and `dark()` ([#120](https://github.com/kihyun1998/flutter_folderview/issues/120)). Both factories gave the chevron `Icon` its own grey, and an `Icon` with its own `color` ignores the ambient `IconTheme` the two fields are applied through. Probed with `color` red and `expandedColor` green on `light()`: every chevron stayed `0xFF616161`. Now collapsed rows are red and expanded rows green.
  - **What a consumer sees differently.** The default look is the same: `light()`'s chevron is still `Colors.grey.shade700`, `dark()`'s `Colors.grey.shade400`. But the grey moved: `expandIconTheme.widget` is now `Icon(Icons.chevron_right, size: 20)` with no colour, and `expandIconTheme.color` is the grey rather than `null`. Code that reads either value sees the new one. `expandedColor` is still `null`, so expanded rows take `color`.
  - A custom `widget` with its own colour keeps it, as before. The two fields' documentation now says they colour only a widget without a colour of its own.
- **BREAKING**: `NodeTooltipTheme.controller` is replaced by `controllerResolver`, a `JustTooltipController? Function(Node<T>)` ([#133](https://github.com/kihyun1998/flutter_folderview/issues/133)). A Tier's `tooltipTheme` reaches every Node of the Tier, so one controller was attached to every built label's `JustTooltip`. just_tooltip lets a controller drive one tooltip: with two Nodes in the Tier, debug failed `This JustTooltipController is already attached to a tooltip`, and release drove whichever label was built last. The resolver gives each Node its own controller.
  - **What a consumer sees differently.** Code that sets `controller` no longer compiles. Migrate `controller: c` to `controllerResolver: (node) => node.id == 'x' ? c : null`, or to a map, `(node) => controllers.putIfAbsent(node.id, JustTooltipController.new)`. Return the same controller for a Node on every call, and never one controller for two Nodes. A controller drives its label while the row is built; a `show()` made before that is applied once it is. As before, just_tooltip shows one tooltip at a time.
- **fix**: a style returned by `textStyleResolver` is scaled, on all three tiers, and so is one returned by `ChildNodeTheme.selectedTextStyleResolver` ([#127](https://github.com/kihyun1998/flutter_folderview/issues/127)). Each tier's `scale` multiplied its `textStyle` but passed the resolvers through as functions, so a resolved style kept its own size. At Scale 2, a Folder with `textStyle: TextStyle(fontSize: 16)` drew 32 px, and one whose resolver returned the same style drew 16 px. Now both draw 32 px. A resolved style follows the rule of the field it stands in for: `textStyle`'s (an unset size starts from the ambient `bodyMedium`) or `selectedTextStyle`'s (an unset size stays unset).
  - **What a consumer sees differently.** At any Scale other than 1, labels styled by a resolver grow and shrink with the rest of the row, and are measured at that size. A resolver that returns `null` still falls back to the scaled field. At Scale 1 nothing changes, and `scale(1.0)` still returns the theme itself.
- **feat**: in debug builds, a `FolderViewTheme` of the wrong type is reported ([#124](https://github.com/kihyun1998/flutter_folderview/issues/124)). `FolderViewTheme.of<T>` and `maybeOf<T>` look up `FolderViewTheme<T>` by exact type. So an untyped `FolderViewTheme(data: FlutterFolderViewTheme.dark())`, which is a `FolderViewTheme<dynamic>`, is not found by a `FolderView<String>`, and the view silently fell back to `light()`. Now, when the lookup misses and a `FolderViewTheme` of another type is above, a `debugPrint` names both types and the fix, once per `T`.
  - **What a consumer sees differently.** Nothing in release builds, and nothing for a correctly typed tree. The lookup and its fallback are unchanged. `FolderViewTheme.debugResetTypeMismatchWarnings()` (`@visibleForTesting`) clears the once-guard. The class dartdoc and the README now show the typed form.
- **fix**: a scrollbar thumb stays inside its track box whatever `thickness` says ([#122](https://github.com/kihyun1998/flutter_folderview/issues/122)). With `thickness: 20` and `trackWidth: 8`, the vertical thumb was painted from x = −12 (Android) or −14 (desktop) in the 8 px bar, so 12 to 14 px of it lay over the rows. The thumb is now painted at what fits: `trackWidth` less Material's cross-axis margin, which is 0 on Android and 2 elsewhere.
  - **What a consumer sees differently.** Only a `thickness` that did not fit changes. The theme keeps the value it was given. With the defaults (`thickness` 12, `trackWidth` 16), nothing changes.
- **BREAKING**: `FolderViewScrollbarTheme.trackVisibility` is removed ([#122](https://github.com/kihyun1998/flutter_folderview/issues/122)). It turned on the Material `Scrollbar`'s own track, painted inside the bar's box in Material's faint colour, never in `trackColor`. So a bar had two different tracks under one name. The box styled by `trackColor`, `trackWidth` and `trackRadius` is now the only track.
  - **What a consumer sees differently.** Code that sets the field, in the constructor or in `copyWith`, no longer compiles: delete the argument. With the default `false`, nothing changes at runtime. With `true`, the faint inner track is gone. The theme's `==`, `hashCode` and `toString` no longer include it.
- **BREAKING**: `FlutterFolderViewTheme.animationDuration` is removed ([#116](https://github.com/kihyun1998/flutter_folderview/issues/116)). Nothing has read it since the switch to a virtualized flat list, and expand and collapse are not animated. The tooltip themes' own `animationDuration` fields are unaffected.
  - **What a consumer sees differently.** Code that sets the field, in the constructor or in `copyWith`, no longer compiles: delete the argument. Nothing changes at runtime, and the theme's `==`, `hashCode` and `toString` no longer include it.
- **BREAKING**: `NodeTooltipTheme.hideOnEmptyMessage` is removed ([#131](https://github.com/kihyun1998/flutter_folderview/issues/131)). It never had an effect through `FolderView`. A label tooltip with no builder and an empty or `null` message is not built at all, so `false` could not bring up an empty tooltip. With a builder, there is always content.
  - **What a consumer sees differently.** Code that sets the field, in the constructor or in `copyWith`, no longer compiles: delete the argument. Nothing changes at runtime.
- **BREAKING**: minimum Flutter is now `3.32.0` (Dart `3.8.0`), up from `3.13.0` (Dart `3.1.0`) ([#100](https://github.com/kihyun1998/flutter_folderview/issues/100)).
  - **What a consumer sees differently.** On Flutter 3.13–3.31 this version does not resolve, and `pub` stays on the previous version. No class, method or field changed because of the floor.
  - **Why.** This package now depends on [`flutter_smooth_wheel_scroll`](https://pub.dev/packages/flutter_smooth_wheel_scroll) `^0.1.3`, which declares Flutter `>=3.32.0` / Dart `^3.8.0`. It uses `SpringDescription.withDurationAndBounce` (flutter#164411), and 3.32.0 is the first stable release to carry it. The floor is the max of what the dependencies demand: `max(3.13, 3.32)`.
  - **The source was reformatted, with no behaviour change.** `dart format` picks its style from the package's language version, and from Dart 3.7 that is the tall style. That reformat is a separate, mechanical commit.
- **deps**: `just_tooltip` `^0.5.1`, up from `^0.4.4`. It declares the same Flutter `3.32.0` / Dart `3.8.0` floor this package already has, so the floor does not move. `NodeTooltipTheme.enableTap` is unchanged. `JustTooltip`'s own `enableTap` is deprecated upstream, so the label tooltip now passes `tap: TooltipTap.claim` for `true` and `TooltipTap.none` for `false`, which upstream documents as identical.
  - **What a consumer sees differently.** These come from just_tooltip, and both tooltips get them unless noted:
    - A screen reader reads a label tooltip's `message` along with the label. A `tooltipBuilder` label tooltip and the row card are not read.
    - Escape closes the tooltip that was shown most recently.
    - A tooltip draws with the `Theme`, `Directionality`, `DefaultTextStyle` and `MediaQuery` around the `FolderView`, not the app-level ones.
    - A label tooltip is `interactive: false` by default, and its body now lets the pointer through. A tap on it reaches the row underneath, and anything clickable in its content can no longer be clicked. Set `interactive: true` for content that should be reachable.
  - A tap on the label with `enableTap` still opens the tooltip and still takes the tap from the row. just_tooltip's new `TooltipTap.observe` mode, which would let the row receive the tap too, is not used ([#134](https://github.com/kihyun1998/flutter_folderview/issues/134)).
- **docs**: the row card's fixed pointer anchor is explained by what it actually prevents ([#138](https://github.com/kihyun1998/flutter_folderview/issues/138)). The `rowTooltipBuilder` and `RowTooltipTheme` dartdocs and the README said anchoring to the row's rect would aim off screen once the view scrolls horizontally. Since just_tooltip 0.4.2, a rect anchor aims at the *visible* part of the rect, so a wide row's card would open at the view's centre: on screen, but not where the user is looking. That is the reason now given. The anchor is unchanged and still not configurable. No behaviour change.
- **docs**: `blockModifierScroll: false` also turns zoom-by-wheel off ([#112](https://github.com/kihyun1998/flutter_folderview/issues/112)). `onScaleChanged` is called only while the modifier scroll is blocked, so with `false` Ctrl/Cmd+wheel scrolls and proposes no Scale. The `onScaleChanged`, `scaleStep` and `blockModifierScroll` dartdocs, the README and `GLOSSARY.md` now say so, and the README gives all six cases. The README's default was also wrong: it is `null`, following `onScaleChanged`, not `true`. Its custom-zoom recipe with `isScaleModifierPressed()` now passes `blockModifierScroll: true`. Without it, the same wheel event zoomed and also scrolled the view. No behaviour change.

## 0.11.3

- **fix**: a label from a `labelResolver` is measured. Content width was measured from `node.label` while the row drew the resolved label, so a resolved label longer than the raw one was cut with an ellipsis where the view should have scrolled horizontally. Measurement and rendering now read the label from one place (`RowMetrics.label`), the way they already shared the text style.
- **fix**: content width is re-measured when the theme reaches the view from an ancestor `FolderViewTheme`, or when the ambient `bodyMedium` changes. Only a new `theme:` argument used to trigger it, so a font change from either source left rows ellipsized at the old width.
- **fix**: `onSecondaryNodeTap` fires on **Folder** and **Parent** rows, not only on **Child** rows. ADR-0003 names it as the way to track a focused container, which are not selectable. `onDoubleNodeTap` remains Child-only, and both callbacks now say which tiers they fire on.
- **fix**: without `onDoubleNodeTap`, every tap on a **Child** row fires `onNodeTap` ([#95](https://github.com/kihyun1998/flutter_folderview/issues/95)). A Child row used to keep a double-tap window with nothing behind it, so a second tap within `ChildNodeTheme.clickInterval` (300 ms by default) fired nothing. Reproduced at 50 ms and at 250 ms, an ordinary pace for tapping a Child off and on again. With `onDoubleNodeTap` set, nothing changes: a double tap still fires `onNodeTap` on the first tap and `onDoubleNodeTap` on the second.
- **docs**: `onNodeTap` and `onDoubleNodeTap` state that a Ctrl+tap is always a single tap.

## 0.11.2

- **deps**: `just_tooltip` `^0.4.4` ([#71](https://github.com/kihyun1998/flutter_folderview/issues/71)). Unlike `0.11.1`'s bump, this one is not documentation of intent: raising the floor is what carries the fix to a project that already depends on us. `pub` does not re-resolve a lockfile that still satisfies its constraint, so `^0.4.3` left an installed `0.4.3` exactly where it was — measured, by pinning this repo's own lock to the floor: `pub get` moved it to `0.4.4` under `^0.4.4` and not at all under `^0.4.3`. No new SDK bound; the Flutter `3.13.0` floor is still `0.4.2`'s.
- **docs**: `just_tooltip` `0.4.4` narrowed its nesting-suppression rule — the innermost tooltip under the pointer **that has something to draw** now wins, where before having nothing to draw was enough to take an ancestor's place. Two places stated the old rule as a fact about the package: `FolderView`'s internal row-card dartdoc, which ships to the API docs, and the characterisation-test header that pins the behaviour. Both now state the rule that 0.4.4 actually implements.
  - No behaviour changes here, and none is claimed. `flutter_folderview` never builds an empty tooltip — a Node with no label tooltip content is not wrapped, and nor is a row whose `rowTooltipBuilder` returns `null` — so the new qualifier can never bite, and the existing tests pass against `0.4.4` untouched. The README's account of the two tooltips describes those guarded tooltips rather than the package's rule, and remains correct as written.

## 0.11.1

- **fix**: a row card no longer dies when the cursor returns to the row from the card itself (via `just_tooltip 0.4.3`). Leaving the card armed a 100 ms hover bridge that re-entering the row never cancelled: it fired unseen, faded the card out, and a pointer already inside the row sends no further enter event to revive it. The card vanished about 250 ms after the cursor came home — a quarter second removed from its cause, and easy to trigger, since an interactive card anchored at the pointer is drawn right beside it. Reproduced against `0.4.2` before the bump: the card was gone 450 ms after the round trip and never returned.
- **deps**: `just_tooltip` `^0.4.3`. Changes no API and no SDK bound — `0.11.0`'s `^0.4.2` constraint already resolved it, so this documents intent. The Flutter `3.13.0` floor is `0.4.2`'s and unchanged.
- **docs**: the README now states the minimum Flutter version beside the install snippet. It never did, while `0.11.0` raised it from `3.10.0`.

## 0.11.0

- **feat**: `FolderView.rowTooltipBuilder` ([#44](https://github.com/kihyun1998/flutter_folderview/issues/44)) — a card shown while the pointer is anywhere over a Node's rendered row. Return `null` for a Node that should not have one. It is declared once on the `FolderView`, not per Tier, because it explains the **Node**, where the existing `NodeTooltipTheme` tooltip attaches to the icon-and-label content and explains the **label**. Both can be enabled at once.
  - The card is anchored at the pointer, and this is not configurable. A row is laid out at the tree's content width, not the viewport's, so anchoring to the row's rect would aim at a centre that leaves the screen as soon as the view scrolls horizontally.
  - **feat**: `FolderView.rowTooltipTheme` — a `RowTooltipTheme` covering the card's presentation and behaviour: `interactive`, `waitDuration`, `showDuration`, `enableHover`, `direction`, `alignment`, `offset`, `crossAxisOffset`, `screenMargin`, the animation fields, `onShow`/`onHide`, and `surface`. Without it the card was frozen at `just_tooltip`'s defaults — shown the instant a pointer crossed a row, with no way to delay it or to stop it holding the cursor.
    - `surface` defaults to `JustTooltipTheme.bare()`, so the tooltip draws no chrome around a card that draws its own. Give it a real `JustTooltipTheme` when the builder returns unadorned content.
    - `interactive` defaults to `true`. The card is anchored at the pointer, so it is drawn beside the cursor and a small movement enters it; and its contents are the kind a user may want to reach. The label tooltip's default is the opposite, and deliberately so — it explains text you read, then leave.
    - The anchor is the one knob the theme does not expose. See above.
  - The two divide the row. Only one tooltip is ever visible — the innermost under the pointer — and a label tooltip claims exactly the glyphs it explains. The row card takes everything else: the indent, the icon, the expand chevron, the space beside a short label. Enable both.
    - The label tooltip now wraps the label's `Text` rather than the icon-and-label `Row`. It previously covered the icon, and — because `Flexible` grows a label to fill its row, and a row is as wide as the tree's longest label — on the widest row it covered the entire row, leaving that Node's card unreachable. Matches `flutter_table_plus`, where a cell's text tooltip wraps the bare `Text`: a text tooltip belongs to the glyphs.
    - `TooltipAnchor.child` therefore now centres a label tooltip on the glyphs rather than on the icon-plus-glyphs box, moving it right by half the icon's width.
- **feat**: `NodeTooltipTheme.anchor` ([#42](https://github.com/kihyun1998/flutter_folderview/issues/42)). A node's tooltip attaches to its icon-and-label content, and a long label fills its row — so a tooltip anchored to that rect appears at the row's centre, which can be far from where the user is actually pointing, and outside the view entirely once the tree scrolls horizontally. `anchor: TooltipAnchor.pointer` keeps the same hover region but places the tooltip at the cursor. `TooltipAnchor` is now re-exported. Defaults to `TooltipAnchor.child`, the behaviour shipped in `0.10.2`, so existing tooltips are unchanged.
  - The anchor is captured when the tooltip is shown and does not follow the pointer, so `interactive` tooltips stay reachable. Tap-triggered tooltips anchor at the tap; a `controller`-driven show with no pointer present falls back to the label's rect.
  - Against a point there are no target edges to align to, so under `TooltipAnchor.pointer` the `alignment` field selects which of the tooltip's *own* edges lands on the pointer.
  - `anchor` does not widen the hover region — a short label leaves the space to its right raising no tooltip under either anchor. For that, use `rowTooltipBuilder` above.
- **note**: `TooltipRegistry` (added in `just_tooltip 0.3.0`) is deliberately not re-exported. `rowTooltipBuilder` is the first place this package nests one tooltip inside another, and it needed no registry: `just_tooltip 0.4.0` suppresses an ancestor whenever a descendant holds the pointer, regardless of registry. Exposing it would grow the public surface for a use case — isolating a `FolderView`'s tooltip group from the host app — that has not yet appeared.
- **deps**: `just_tooltip` `^0.4.2`, which **raises the minimum Flutter to `3.13.0`** (Dart `3.1.0`), up from `3.10.0`. Its ancestor clip walk reads `RenderObject.parent`, which was `AbstractNode?` — a type with no `describeApproximatePaintClip` — until Flutter 3.13. `flutter_folderview` declared `>=3.10.0` while its `^0.4.0` constraint already resolved `0.4.2`, so that floor had become a promise it could not keep.
- **fix**: a label tooltip is no longer painted outside the `FolderView` ([#47](https://github.com/kihyun1998/flutter_folderview/issues/47)). When a tree scrolls horizontally, a long label's rect extends past the view, and `TooltipAnchor.child` aimed at its centre — a point nobody could see. `screenMargin` never objected: it confines the tooltip to the enclosing `Overlay`, usually the whole app. `just_tooltip 0.4.2` now targets the visible part of a clipped child, so the tooltip lands inside the view. Pre-existing; every version with tooltips had it.
  - Two further `just_tooltip` fixes come along: a visible tooltip now re-aims when its child moves (scroll, resize, insertion above it) and hides once the child is clipped away entirely; and the target rect now follows the child's paint transform, so a `Transform.scale` between a node and the `Overlay` no longer mis-sizes it.

## 0.10.2

- **deps**: Bump `just_tooltip` to `^0.4.0`. Not breaking for `flutter_folderview`: nothing was removed from `just_tooltip`'s API, the re-exported `JustTooltipController` is unchanged, and its one behaviour change — a nested tooltip now suppresses its ancestors — cannot be reached from here, since `FolderView` wraps exactly one `JustTooltip` per node label and never nests them. Node tooltips gain `just_tooltip`'s fix for tooltips laid out in an `Overlay` that does not fill the window from its origin: under a nested `Navigator`, an inset `Overlay`, or an embedded Flutter view, a node's tooltip was displaced by the Overlay's offset and had its auto-flip and `screenMargin` clamping measured against the wrong bounds. Placing a `FolderView` inside such a host now positions its tooltips correctly. No `flutter_folderview` API changed.
- **note**: `just_tooltip 0.4.0` adds `TooltipAnchor`, which anchors a tooltip at the pointer instead of the child's rect. It is deliberately **not** re-exported yet: `NodeTooltipTheme` has no `anchor` field, so the enum would be visible but unusable. Exposing it is a `flutter_folderview` feature decision, tracked in [#42](https://github.com/kihyun1998/flutter_folderview/issues/42) along with `TooltipRegistry`, which `just_tooltip 0.3.0` added and which is likewise not re-exported.

## 0.10.1

- **perf**: Remove the per-row `Material` from node rows. `CustomInkWell` no longer wraps each row in its own `Material > Ink > InkWell`; instead `FolderViewContent` provides a single transparent `Material` once above the row list, and every row's ink (splash / highlight) paints onto that shared surface. Profiling a large tree under fling scroll showed the per-row Material crossed the 16 ms frame budget noticeably more often than the shared-Material variant. Ripple, hover, highlight, and selection are visually unchanged; the public `FolderView` API is unchanged (`CustomInkWell` is an internal row primitive and now requires an ancestor `Material` by design).

## 0.10.0

- **BREAKING**: Bump `just_tooltip` to `^0.3.0`. Its `JustTooltipController` — re-exported here and usable via `NodeTooltipTheme.controller` — is no longer a `ChangeNotifier`: `shouldShow` and `addListener` / `removeListener` / `dispose` are removed. Drive it with `show()` / `hide()` / `toggle()` and observe visibility via the tooltip's `onShow` / `onHide` callbacks. `just_tooltip` also narrowed its exports (`JustTooltipPositionDelegate`, `TooltipShapePainter`, `JustTooltipOverlay` are now internal). No `flutter_folderview` API changed.
- **perf**: Pack a `FlatNode`'s ancestor tree-line flags into an `int` bitmask instead of a per-node `List<bool>`, removing a heap allocation for every flattened node (the flags are read only for painted rows). Flatten is ~3× faster and the flat-list heap footprint roughly halves on large trees. Tree-line rendering is unchanged; tree depth is capped at 63.
- **perf**: Apply incremental expand/collapse in place on the cached flat list instead of copying the whole list on every single-node toggle — ~1.7× faster toggles on large trees. Visible rows and scroll anchoring are unchanged.
- **perf**: In `RowMetrics.maxWidth`, merge the effective text style once per tier instead of once per node, removing the per-node `TextStyle` allocation on every data / scale / theme change (~5.5× faster on the warm measurement path). The returned width is unchanged, so horizontal scroll extent and clipping are identical.
- **test / ci**: Add widget tests for the `FolderView` interaction, selection, view-mode, and modifier+wheel scale-gesture contracts; add an `integration_test` harness driving the example app end-to-end (boot, expand, select, zoom, view-mode switch); add a GitHub Actions analyze + test workflow; add `benchmark/` microbenchmarks and heap-footprint measurements for the flatten / projection / maxWidth hot paths.

## 0.9.0

- **refactor**: Decentralize content scaling — each theme class now exposes its own `scale()` method, replacing the prior centralized `_applyScale` implementation. Existing usage (`FolderView(scale: ...)`) is unaffected.
- **feat**: Add `FlutterFolderViewTheme.scale({required factor, required defaultFontSize})` and `FlutterFolderViewTheme.scaledForContext(BuildContext, double)` for callers who want a scaled theme outside `FolderView` (custom previews, integration tests, etc.).
- **docs**: Add `CONTEXT.md` (domain glossary) and ADRs `0001` (scrollbars excluded from scale), `0002` (caller owns interaction state), `0003` (selection tier-bound to child), `0004` (tooltips excluded from scale).
- **test**: Add 31 unit tests covering the new scale API (identity short-circuit, positivity assertion, chrome exclusion for scrollbars/tooltips, null `fontSize` resolution against `defaultFontSize`).

## 0.8.1

- **fix**: Explicitly set `SystemMouseCursors.click` as the default `mouseCursor` on node `InkWell` — newer Flutter versions no longer auto-apply the click cursor on hover

## 0.8.0

- **BREAKING**: Rename `blockCtrlScroll` → `blockModifierScroll` to accurately reflect platform-aware behavior (Ctrl on Windows/Linux, Cmd on macOS)
- **BREAKING**: `blockModifierScroll` is now `bool?` (default `null`) — automatically follows `onScaleChanged` when unset
- **feat**: Add `onScaleChanged` callback and `scaleStep` parameter for built-in modifier+scroll zoom handling
- **feat**: Export `isScaleModifierPressed()` helper for library consumers implementing custom zoom logic
- **fix**: Use platform-aware modifier key check to prevent Windows key from permanently triggering zoom mode

## 0.7.1

- **feat**: Add `blockCtrlScroll` parameter to `FolderView` (default: `true`) — optionally disable Ctrl/Cmd + scroll blocking for users who don't need zoom-by-scroll

## 0.7.0

- **feat**: Add `scale` parameter to `FolderView` for content zoom (default: `1.0`)
- **feat**: Scale all layout dimensions proportionally — row height, icon sizes, text size, spacing, line width, indentation, content padding, border radius
- **feat**: Scrollbar appearance (thickness, track width, colors) is NOT affected by scale
- **feat**: Preserve visible node on scale change with automatic scroll position adjustment
- **feat**: Ignore scroll events when Ctrl/Cmd is pressed to support zoom-by-scroll without unintended scrolling
- **fix**: Defer scroll position adjustment to post-frame callback to prevent `setState() called during build` error
- **fix**: Scale content width clamp limit (`3x viewport * scale`) to prevent text ellipsis at high scale values
- **example**: Add scale slider to Layout controls and Ctrl/Cmd + mouse wheel zoom support

## 0.6.9

- **fix**: Pre-compute content width from all nodes (including collapsed) to prevent layout jumps on expand/collapse
- **fix**: Include `letterSpacing` in text width calculation for accurate horizontal scroll sizing
- **feat**: Add `calculateMaxContentWidth` method to `SizeService` for upfront width calculation
- **example**: Add long name test options (Folder/Parent/Child) to data generator for horizontal scroll testing

## 0.6.8

- **feat**: Bump just_tooltip to 0.2.5
- **feat**: Add `hideOnEmptyMessage` option to `NodeTooltipTheme` — suppress tooltip when message is empty (default: `true`)
- **feat**: Support `TooltipAlignment.startTargetCenter` and `endTargetCenter` alignments — arrow dynamically points to the center of the target widget

## 0.6.7

- **fix**: Bump just_tooltip to 0.2.3 — fix `borderColor` not visible when `showArrow: false`

## 0.6.6

- **fix**: Tighten `just_tooltip` constraint to `^0.2.2` to fix pub.dev lower bounds compatibility check

## 0.6.5

- **feat**: Bump just_tooltip to 0.2.1
- **feat**: Add `animation` (`TooltipAnimation`) option to `NodeTooltipTheme` — supports `none`, `fade`, `scale`, `slide`, `fadeScale`, `fadeSlide`, `rotation`
- **feat**: Add `animationCurve`, `fadeBegin`, `scaleBegin`, `slideOffset`, `rotationBegin` options to `NodeTooltipTheme`
- **feat**: Export `TooltipAnimation` from barrel file

## 0.6.4

- **feat**: Bump just_tooltip to 0.2.0
- **feat**: Add `showArrow`, `arrowBaseWidth`, `arrowLength`, `arrowPositionRatio` options to `NodeTooltipTheme`
- **feat**: Add `borderColor`, `borderWidth` options to `NodeTooltipTheme`
- **feat**: Add `screenMargin` option to `NodeTooltipTheme`
- **feat**: Export `JustTooltipTheme` from barrel file

## 0.6.3

- **fix**: Bump just_tooltip to 0.1.5 (bugfix)

## 0.6.2

- **feat**: Add `interactive`, `waitDuration`, `showDuration`, `boxShadow` options to `NodeTooltipTheme` (just_tooltip 0.1.4)

## 0.6.1

- **fix**: Tooltip hover area now limited to icon+label only, no longer triggers on empty row space

## 0.6.0

- **BREAKING CHANGE**: Migrate tooltip from Flutter `Tooltip` to `just_tooltip` package
- **BREAKING CHANGE**: Remove `TooltipPosition` enum — replaced by `TooltipDirection` (top/bottom/left/right)
- **BREAKING CHANGE**: Remove `margin`, `verticalOffset`, `waitDuration`, `boxShadow` from `NodeTooltipTheme`
- **BREAKING CHANGE**: Remove `richMessage` / `richMessageResolver` — replaced by `tooltipBuilder` / `tooltipBuilderResolver` (`WidgetBuilder`)
- **feat**: Add `direction` (4-directional), `alignment` (start/center/end), `offset`, `crossAxisOffset` properties to `NodeTooltipTheme`
- **feat**: Add `elevation`, `borderRadius`, `padding` properties to `NodeTooltipTheme`
- **feat**: Add `controller` (`JustTooltipController`) for programmatic tooltip show/hide
- **feat**: Add `enableTap`, `enableHover` properties for tooltip trigger control
- **feat**: Add `animationDuration`, `onShow`, `onHide` properties to `NodeTooltipTheme`
- **feat**: Tooltip now wraps both node icon and label instead of label only
- **feat**: Export `TooltipDirection`, `TooltipAlignment`, `JustTooltipController` from barrel file

## 0.5.3

- **fix**: Recursively collect parent nodes from nested folders in tree mode

## 0.5.2

- **perf**: Replace `setState` with `ValueNotifier` for horizontal scroll offset and hover state to prevent full widget tree rebuilds
- **perf**: Eliminate recursive list spreading in `FlattenService.flatten()` by reusing a single mutable list with add/removeLast pattern

## 0.5.1

- **fix**: Show full text on horizontal scroll instead of ellipsis-truncated text using `OverflowBox`

## 0.5.0

- **BREAKING CHANGE**: Remove `isExpanded` property from `Node<T>` model - nodes are now immutable
- **BREAKING CHANGE**: Add `expandedNodeIds` parameter to `FolderView`, `FolderViewContent`, and `NodeWidget` for external expansion state management
- **BREAKING CHANGE**: Update `SizeService` methods to accept `expandedNodeIds` parameter
- **perf**: Add incremental expand/collapse with `expandNode()` and `collapseNode()` methods in `FlattenService`
- **perf**: Implement text width caching via `_textWidthCache` to reduce expensive `TextPainter` layout calls
- **perf**: Add lazy content width measurement - calculate as nodes render instead of upfront O(N) traversal
- **perf**: Optimize scroll performance for 20k+ nodes with `Transform.translate` and `itemExtent` on `ListView.builder`
- **fix**: Clamp scroll offset to valid range instead of skipping sync when out of range
- **fix**: Preserve scroll position on bulk expand/collapse (expandAll/collapseAll) using viewport anchor node

## 0.4.0

- **feat**: Add `labelResolver` to `FolderNodeTheme`, `ParentNodeTheme`, `ChildNodeTheme` for dynamic label resolution based on `node.data`
- **fix**: Update animation controller duration in `didUpdateWidget` when theme `animationDuration` changes at runtime

## 0.2.4

- **feat**: Add `labelResolver` to all node themes for dynamic label display

## 0.2.3

- **feat**: Add `color` and `expandedColor` properties to `ExpandIconTheme` for expand icon color theming

## 0.2.2

- **refactor**: Unified expand icon logic to ensure consistent node layout alignment
- **refactor**: Add `isChild` parameter to `_buildExpandIcon` for proper child node spacing

## 0.2.1

- **feat**: Add `hoverColor`, `splashColor`, and `highlightColor` properties to all node themes for interaction color theming
- **feat**: Add comprehensive tooltip support with `NodeTooltipTheme` class for all node types
- **feat**: Add `rowHeight` property to `FlutterFolderViewTheme` for configurable row height
- **feat**: Add `rowSpacing` property to `FlutterFolderViewTheme` for vertical spacing between rows
- **refactor**: Remove `iconToTextSpacing` property from all node themes - now controlled via icon `margin.right`

## 0.2.0

- **BREAKING CHANGE**: Migrate from unified `FolderViewTextTheme` and `FolderViewIconTheme` to node-type specific themes (`FolderNodeTheme`, `ParentNodeTheme`, `ChildNodeTheme`, `ExpandIconTheme`)
- **feat**: Add custom `Widget?` support for each node type instead of hardcoded `Icon` widgets
- **feat**: Add `openWidget` property for folder nodes (displayed when expanded)
- **feat**: Add `padding` and `margin` properties for each widget type
- **feat**: Add `clickInterval` property to `ChildNodeTheme` for configurable double-click detection (default: 300ms)
- **feat**: Add `animationDuration` property to `FlutterFolderViewTheme` for configurable expand/collapse animation speed
- **feat**: Add theme resolver functions (`widgetResolver`, `textStyleResolver`, `selectedTextStyleResolver`, `openWidgetResolver`) for dynamic styling based on node data
- **feat**: Add generic type support `<T>` to all theme classes for type-safe access to `node.data`

## 0.1.2

- **fix**: Fixed scroll position being reset when expanding/collapsing nodes by removing contentHeight from SyncedScrollControllers key

## 0.1.1

- **fix**: Fixed scroll position calculation when switching between view modes or expanding/collapsing nodes

## 0.1.0

- **feat**: Add dual view modes (Tree and Folder)
- **feat**: Add three node types (Folder, Parent, Child) for flexible hierarchy representation
- **feat**: Add multiple line styles (Connector, Scope, None) for visual tree structure
- **feat**: Add comprehensive theming system (icon, text, line, scrollbar, spacing, node style)
- **feat**: Add interactive features (selection, tap handlers, expand/collapse animations)
- **feat**: Add synchronized horizontal and vertical scrolling with custom scrollbars
- **feat**: Add depth-based indentation for nested nodes
- **fix**: Correct indent and line positioning for nested nodes based on depth level
