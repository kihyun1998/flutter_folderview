# Selection

## What it is
Paints the caller's **Selected Set** on **Child** rows: a selected background and a selected text style. The library reads the set and never changes it; it does not choose single or multiple selection.

## Governing decisions
- [ADR-0003](../../adr/0003-selection-is-tier-bound-to-child.md): Selection is tier-bound to Child. Only `ChildNodeTheme` carries `selected*` fields, and `ExpandableNodeRenderer` has no selection branch. Adding `selected*` fields to the Folder or Parent themes would re-open the decision.
- [ADR-0002](../../adr/0002-caller-owns-interaction-state.md): the **Selected Set** is caller-owned.

## Design model
Read from `ChildNodeRenderer`.
- `isSelected` is `selectedNodeIds?.contains(node.id)`. Only `ChildNodeRenderer` reads the set, so a Folder or Parent ID in it has no effect.
- **The selected style is merged over the Child's own style**, not substituted: `selectedTextStyleResolver(node)` where it returns a style, else `selectedTextStyle`, merged onto `effectiveTextStyle`. The example pins the merge: a label size of 18 is kept when selected (`example/test/child_tier_test.dart`).
- The background is `selectedBackgroundColor ?? ColorScheme.primaryContainer`, painted by `CustomInkWell`'s `Ink` decoration.
- `onNodeTap` fires for every tier, so keeping Folders and Parents out of the set is the caller's handler's job ([taps](taps.md)).

## Code
- `lib/widgets/child_node_renderer.dart` — `ChildNodeRenderer`
- `lib/widgets/custom_ink_well.dart` — `CustomInkWell.isSelected`, `CustomInkWell.selectedColor`
- `lib/themes/child_node_theme.dart` — `ChildNodeTheme.selectedTextStyle`, `ChildNodeTheme.selectedTextStyleResolver`, `ChildNodeTheme.selectedBackgroundColor`
- `lib/widgets/folder_view.dart` — `FolderView.selectedNodeIds`

## Reference behaviour
**None.**

## Cross-cutting invariants
- [measured-equals-rendered](../invariant/measured-equals-rendered.md) — the selected style is drawn but not measured.

## Blast radius
- [row-geometry](row-geometry.md) — a selected style that widens a label is not measured.
- [scale](scale.md) — `selectedTextStyle` and its resolver scale by the optional-style rule.
- [taps](taps.md) — a Child tap is the caller's usual cue to change the set; `NodeTooltipTheme.enableTap` takes that tap from the label (#134).
- [theme-composition](theme-composition.md) — the `selected*` fields live on `ChildNodeTheme` alone.

## Known holes / open
- **`selectedTextStyle` is not measured.** A bold or larger selected label can be ellipsized where the unselected one fits. Read from the code; not probed.
