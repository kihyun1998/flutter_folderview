# Theme composition

## What it is
The public theming surface. `FlutterFolderViewTheme` aggregates eight sub-themes plus row metrics. It is resolved per build from the `theme:` parameter or from an ancestor `FolderViewTheme`, then scaled and passed down. Every theme class hand-maintains `copyWith`, `lerp`, `==`/`hashCode`, `toString` and, for content themes, `scale`.

## Governing decisions
- [ADR-0005](../../adr/0005-tier-theme-boilerplate-not-extracted.md): no shared base for the tier themes. A shared-contract change is applied to all three by hand.
- [ADR-0003](../../adr/0003-selection-is-tier-bound-to-child.md): only `ChildNodeTheme` carries `selected*` fields.
- [ADR-0001](../../adr/0001-scrollbars-excluded-from-scale.md) and [ADR-0004](../../adr/0004-tooltips-excluded-from-scale.md): which sub-themes have no `scale`.

## Design model
- Resolution is `widget.theme ?? FolderViewTheme.of<T>(context)`. `of` falls back to `FlutterFolderViewTheme.light()`. `FolderViewTheme` notifies on `data !=`, so it rebuilds dependents.
- `lerp` interpolates the sub-themes and snaps `rowHeight`, `rowSpacing` and `animationDuration` at `t < 0.5`.
- Adding a field means editing the constructor, `copyWith`, `lerp`, `==`, `hashCode`, `toString`, and `scale` if the field is spatial. For a tier field, repeat that three times. `test/themes/data_class_test.dart`, `lerp_test.dart` and `scale_test.dart` are the guards.

## Code
- `lib/themes/flutter_folder_view_theme.dart` — `FlutterFolderViewTheme`, `FlutterFolderViewTheme.copyWith`, `FlutterFolderViewTheme.lerp`, `FlutterFolderViewTheme.animationDuration`
- `lib/themes/folder_view_theme.dart` — `FolderViewTheme`, `FolderViewTheme.of`, `FolderViewTheme.maybeOf`
- `lib/themes/folder_node_theme.dart` — `FolderNodeTheme`
- `lib/themes/parent_node_theme.dart` — `ParentNodeTheme`
- `lib/themes/child_node_theme.dart` — `ChildNodeTheme`
- `lib/themes/folder_view_node_style_theme.dart` — `FolderViewNodeStyleTheme`
- `lib/themes/folder_view_spacing_theme.dart` — `FolderViewSpacingTheme`

## Reference behaviour
**None.**

## Cross-cutting invariants
- [measured-equals-rendered](../invariant/measured-equals-rendered.md) — a theme reaching the view by inheritance does not re-measure.

## Blast radius
- [scale](scale.md) — every new spatial field is a Scale decision.
- [row-geometry](row-geometry.md) — theme identity invalidates measurement, but only for `theme:`.
- [tier-rendering](tier-rendering.md) — the renderers read the tier themes, via `ExpandableNodeThemeView` for Folder and Parent.
- [label-tooltip](label-tooltip.md) — `tooltipTheme` is a field on each tier theme.

## Known holes
- **`FlutterFolderViewTheme.animationDuration` is read nowhere in `lib/`.** It is carried through `copyWith`, `lerp` and `==` but drives no animation. Read from the code.
- `FolderViewNodeStyleTheme` and `FolderViewSpacingTheme` each box one field (`borderRadius`, `contentPadding`). Tracked: [#16](https://github.com/kihyun1998/flutter_folderview/issues/16). That issue's third item, a hand-rolled `lerpDouble`, no longer holds: every theme imports `dart:ui`'s. Its line citation into `node_widget.dart` points past the end of the current file.
- An inherited theme change leaves the width stale ([row-geometry](row-geometry.md), probed).
