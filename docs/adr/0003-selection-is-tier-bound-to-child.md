# Selection is tier-bound to the Child tier

The **Selection** domain concept applies only to the **Child** tier. **Folders** and **Parents** are not selectable as a domain matter; placing their IDs in the **Selected Set** has no defined effect. The `ChildNodeTheme` carries selection-specific styling (`selectedTextStyle`, `selectedTextStyleResolver`, `selectedBackgroundColor`); `FolderNodeTheme` and `ParentNodeTheme` intentionally have no equivalent fields.

## Alternative considered

Universal selection across all tiers, with each tier's theme carrying its own `selected*` fields.

Rejected because:

- The library's mental model is "**Folders** and **Parents** are containers you open; **Children** are items you choose." Mixing those gestures muddies the API.
- Container-level operations (delete this **Folder**, rename this **Parent**) are caller concerns. Callers who need "currently-focused container" state can hold it themselves and react via `onSecondaryNodeTap` or `onNodeTap`.
- Restricting **Selection** to one tier keeps the theme surface narrow: only `ChildNodeTheme` carries selection styling.

## Note on the current implementation

`node_widget.dart` (`_buildFolderParentNodeContent`, `_getTextStyle`) currently contains a half-finished `isSelected` branch for **Folders** and **Parents** that applies a hard-coded Material default highlight when their IDs appear in the **Selected Set**. This is a vestige of an earlier exploration and contradicts the decision recorded here. It is scheduled for removal in the architecture review that follows this ADR.

Future PRs should not "complete" this branch by adding `selected*` fields to `FolderNodeTheme` / `ParentNodeTheme` — that would re-open this decision.
