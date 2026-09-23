# Selection is tier-bound to the Child tier

The **Selection** domain concept applies only to the **Child** tier. **Folders** and **Parents** are not selectable as a domain matter; placing their IDs in the **Selected Set** has no defined effect. The `ChildNodeTheme` carries selection-specific styling (`selectedTextStyle`, `selectedTextStyleResolver`, `selectedBackgroundColor`); `FolderNodeTheme` and `ParentNodeTheme` intentionally have no equivalent fields.

## Alternative considered

Universal selection across all tiers, with each tier's theme carrying its own `selected*` fields.

Rejected because:

- The library's mental model is "**Folders** and **Parents** are containers you open; **Children** are items you choose." Mixing those gestures muddies the API.
- Container-level operations (delete this **Folder**, rename this **Parent**) are caller concerns. Callers who need "currently-focused container" state can hold it themselves and react via `onSecondaryNodeTap` or `onNodeTap`.
- Restricting **Selection** to one tier keeps the theme surface narrow: only `ChildNodeTheme` carries selection styling.

## Note on the current implementation

When this ADR was written, `node_widget.dart` still carried a half-finished `isSelected` branch for **Folders** and **Parents** — a vestige of an earlier exploration that contradicted this decision. The tier-renderer split (`bfb91db`) removed it: `ExpandableNodeRenderer` has no selection branch, and only `ChildNodeRenderer` reads the **Selected Set**.

The container route named above holds as of 0.11.3: `onSecondaryNodeTap` fires on **Folder** and **Parent** rows too. Before that it reached **Child** rows only, so this ADR's advice had no path in the code.

Future PRs should not "complete" this branch by adding `selected*` fields to `FolderNodeTheme` / `ParentNodeTheme` — that would re-open this decision.
