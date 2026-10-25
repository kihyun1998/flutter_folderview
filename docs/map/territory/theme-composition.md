# Theme composition

## What it is
The public theming surface. `FlutterFolderViewTheme` aggregates eight sub-themes plus `rowHeight` and `rowSpacing`. It is resolved per build from the `theme:` parameter or from an ancestor `FolderViewTheme`, then scaled and passed down. Every theme class hand-maintains `copyWith`, `lerp`, `==`/`hashCode`, `toString` and, for content themes, `scale`.

## Governing decisions
- [ADR-0005](../../adr/0005-tier-theme-boilerplate-not-extracted.md): no shared base for the tier themes. A shared-contract change is applied to all three by hand.
- [ADR-0003](../../adr/0003-selection-is-tier-bound-to-child.md): only `ChildNodeTheme` carries `selected*` fields.
- [ADR-0001](../../adr/0001-scrollbars-excluded-from-scale.md) and [ADR-0004](../../adr/0004-tooltips-excluded-from-scale.md): which sub-themes have no `scale`.

## Design model
Read from `FlutterFolderViewTheme` and `FolderViewTheme`.
- Resolution is `widget.theme ?? FolderViewTheme.of<T>(context)` (`_FolderViewState.build`). `of` falls back to `FlutterFolderViewTheme.light()`. `FolderViewTheme` notifies on `data !=`.
- **The lookup is by exact type** (#124). `FolderViewTheme(data: FlutterFolderViewTheme.dark())` infers `FolderViewTheme<dynamic>`, so a `FolderView<String>` below it falls back to `light()` (probed 2026-10-19: its Folder label rendered `0xDD000000` where `FolderViewTheme<String>` gave dark's `0xB3FFFFFF`). The lookup stays exact because `T` is real: the tier resolvers take `Node<T>`.
  - **On a miss, debug walks the ancestors** for any `FolderViewTheme` and, if it finds one, `debugPrint`s both types and the fix, once per `T` (`_debugReportTypeMismatch`). Once per `T` and not per pair, because the found type is known only after the walk, and the guard is what saves the walk. Release builds and hits never walk; with no `FolderViewTheme` at all, debug walks on every miss and prints nothing, O(depth) per build.
  - Decided by the maintainer at triage, 2026-10-21: documentation plus a one-time debug warning. An `assert` was rejected because a `FolderViewTheme<int>` placed for another view above a `FolderView<String>` that wants the default is a legitimate tree. Pinned by `test/themes/folder_view_theme_test.dart`'s "type mismatch (#124)" group.
- `lerp` interpolates the sub-themes and snaps `rowHeight` and `rowSpacing` at `t < 0.5`. `lerp(null, null)` is `light()`.
- Adding a field means editing the constructor, `copyWith`, `lerp`, `==`, `hashCode`, `toString`, and `scale` if the field is spatial; for a tier field, three times. `test/themes/data_class_test.dart`, `lerp_test.dart` and `scale_test.dart` are the guards, and the example's coverage guard demands a control for it ([example](example.md)).
- `FolderNodeTheme` and `ParentNodeTheme` implement the read-only `ExpandableNodeThemeView` ([tier-rendering](tier-rendering.md)).
- The library has no expand/collapse animation. `FlutterFolderViewTheme.animationDuration`, read nowhere since the flat-list rewrite (`51d86a8`), was removed in 0.12.0 (#116, maintainer's call at triage). A future animation would be a new, additive field.

## Code
- `lib/themes/flutter_folder_view_theme.dart` — `FlutterFolderViewTheme`, `FlutterFolderViewTheme.light`, `FlutterFolderViewTheme.dark`, `FlutterFolderViewTheme.copyWith`, `FlutterFolderViewTheme.lerp`
- `lib/themes/folder_view_theme.dart` — `FolderViewTheme`, `FolderViewTheme.of`, `FolderViewTheme.maybeOf`, `FolderViewTheme._debugReportTypeMismatch`
- `lib/themes/folder_node_theme.dart` — `FolderNodeTheme`
- `lib/themes/parent_node_theme.dart` — `ParentNodeTheme`
- `lib/themes/child_node_theme.dart` — `ChildNodeTheme`
- `lib/themes/folder_view_node_style_theme.dart` — `FolderViewNodeStyleTheme`
- `lib/themes/folder_view_spacing_theme.dart` — `FolderViewSpacingTheme`

## Reference behaviour
**None.**

## Cross-cutting invariants
- [measured-equals-rendered](../invariant/measured-equals-rendered.md) — a theme field that changes a row's width has to reach measurement, however the theme arrives.
- [chrome-excluded-from-scale](../invariant/chrome-excluded-from-scale.md) — a new theme for something drawn over content gets no `scale`.

## Blast radius
- [scale](scale.md) — every new spatial field is a Scale decision.
- [row-geometry](row-geometry.md) — the effective theme's identity invalidates measurement, whether it comes from `theme:` or from an ancestor.
- [tier-rendering](tier-rendering.md) — the renderers read the tier themes, via `ExpandableNodeThemeView` for Folder and Parent.
- [label-tooltip](label-tooltip.md) — `tooltipTheme` is a field on each tier theme.
- [example](example.md) — a new public field turns the coverage guard red until the example exposes it.

## Known holes / open
- `FolderViewNodeStyleTheme` and `FolderViewSpacingTheme` each box one field (`borderRadius`, `contentPadding`). Tracked: [#16](https://github.com/kihyun1998/flutter_folderview/issues/16). That issue's third item, a hand-rolled `lerpDouble`, no longer holds: every theme that interpolates a double imports `dart:ui`'s. Its line citation into `node_widget.dart` points past the end of the current file.
