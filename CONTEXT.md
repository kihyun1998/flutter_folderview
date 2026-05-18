# flutter_folderview

A Flutter widget library for rendering a **semantic three-tier hierarchy** — folders, parents, and children — with two interchangeable view projections. The tier roles are part of the library's contract, not just styling labels.

## Language

### Hierarchy

**Tier**:
One of the three fixed levels a node may occupy: **Folder**, **Parent**, or **Child**. A node declares its tier via `NodeType` and must respect the containment rule (see Relationships).
_Avoid_: Level, rank, kind, category.

**Folder**:
The top tier. Contains **Parents** (and, by convention, never other Folders or direct Children). Visible only in the `folder` **View Mode**.
_Avoid_: Group, section, root, directory.

**Parent**:
The middle tier. Contains **Children**. Visible in both **View Modes** — promoted to the root position in `tree` **View Mode**.
_Avoid_: Branch, container, intermediate.

**Child**:
The leaf tier. Has no children of its own under the tier rules. Rendered as a row in both **View Modes**.
_Avoid_: Leaf, item, entry, file.

**Node**:
A single element in the input tree, regardless of tier. Carries an `id`, a `label`, a tier, optional caller payload, and zero or more child nodes.
_Avoid_: Item, row, entry, element.

### Projections

**View Mode**:
A projection of the underlying hierarchy onto a rendered list. Two are defined: `folder` and `tree`.
_Avoid_: Display mode, layout, style.

**Folder Mode**:
The natural projection. Renders the full three-tier shape: **Folders** at the root, **Parents** beneath them, **Children** beneath those.

**Tree Mode**:
A flattened projection. **Folders** are hidden; their contained **Parents** are recursively lifted to the root position. **Children** still appear beneath their **Parents**.

### Interaction state

**Expansion**:
The state of having a **Folder** or **Parent**'s children rendered beneath it. Only **Folders** and **Parents** are expandable; a **Child** is never expanded.
_Avoid_: Open, opened, unfolded.

**Expanded Set**:
A caller-controlled set of **Node** IDs that are currently expanded. The library reads this set but does not mutate it — the caller decides when to add or remove IDs in response to user input (e.g. `onNodeTap`).
_Avoid_: Open state, open list.

**Selection**:
The state of a **Child** being marked by the caller as currently focused or chosen. Only the **Child** tier participates in Selection — **Folders** and **Parents** are not selectable as a domain concept.
_Avoid_: Active, highlighted, focused.

**Selected Set**:
A caller-controlled set of **Child** **Node** IDs that are currently selected. Like the **Expanded Set**, the library reads it but does not mutate it. The library does not enforce single-vs-multi selection — the caller chooses.
_Avoid_: Active set, highlight set.

**Scale**:
A uniform zoom factor applied to the **content** of the **FolderView**. All spatial properties of the rendered tree — row sizing, icon containers, text size, spacing, indentation, line width, border radius, content padding — scale together. Non-content elements (**scrollbars**, animation durations, click intervals, colors) are excluded by definition.
_Avoid_: Zoom, magnification, size factor.

**Scale Modifier**:
The platform-aware keyboard modifier (Ctrl on Windows/Linux, Cmd on macOS) that, when held during mouse-wheel scrolling, signals a **Scale** change request rather than a normal scroll.
_Avoid_: Zoom key, ctrl-scroll.

## Relationships

- A **Folder** contains zero or more **Parents**.
- A **Parent** contains zero or more **Children**.
- A **Child** contains no nodes under the tier rules.
- A **View Mode** is a projection from the input tree onto a list of visible **Nodes**. It does not mutate the input.
- **Expansion** is tier-bound: only **Folders** and **Parents** participate. A **Child**'s presence in the **Expanded Set** has no defined effect.
- **Selection** is tier-bound to the **Child** tier. A **Folder** or **Parent** ID in the **Selected Set** has no defined effect — the library does not model selection of non-**Child** tiers.
- **Expansion** and **Selection** are independent and apply to disjoint tiers: **Folders** and **Parents** expand; **Children** are selected. A single **Node** is therefore either expandable or selectable, never both.
- In `tree` **View Mode**, a **Folder**'s membership in the **Expanded Set** has no defined effect — the **Folder** is not rendered in that projection.
- **Scale** applies uniformly to all content-spatial properties; **scrollbars** are excluded as chrome (see ADR-0001), and non-spatial properties (colors, durations) are excluded by nature.
- When `onScaleChanged` is provided, the library detects **Scale Modifier** + wheel events and proposes a new **Scale** value; the caller applies it. This follows the same caller-controlled-state pattern as the **Expanded Set** and the **Selected Set**.
- **Scale** is independent of **View Mode**, **Expansion**, and **Selection** — changing **Scale** does not change which **Nodes** are visible or selected.
- Violations of the tier rules (e.g. a **Child** at the root in `folder` **View Mode**, or a **Folder** nested inside a **Parent**) produce undefined visible behavior — the library does not enforce them at runtime.

## Example dialogue

> **Dev:** "If I put a **Child** at the root of my data, what happens in `folder` **View Mode**?"
> **Domain expert:** "It gets filtered out — only **Folders** and **Parents** are accepted at the root in that **View Mode**. The library doesn't warn you; you're expected to honour the tier rules."
> **Dev:** "And in `tree` **View Mode**?"
> **Domain expert:** "Same idea — only **Parents** are collected as roots, recursively from inside any **Folders**. A root-level **Child** is invisible there too."

## Flagged ambiguities

- **User-supplied Widget sizing is not scaled.** User-supplied **Widget** instances inside `*NodeTheme.widget` retain their internally-baked sizes (e.g. `Icon(size: 20)` stays size 20 regardless of **Scale**). `NodeWidget` mitigates this at render time by wrapping the widget in a `FittedBox` when `scale != 1.0`, which fits the icon glyph into the scaled `SizedBox` container — visually approximate but not a true per-glyph re-render. This is an inherent limitation of accepting pre-built Flutter `Widget` instances as theme inputs.

_Resolved (was: NodeTooltipTheme spatial fields not scaled) — closed by per-Theme `scale` methods in `themes/*.dart`, which now recursively scale `NodeTooltipTheme` content-spatial fields (offset, padding, arrow dimensions, screen margin). See `lib/themes/node_tooltip_theme.dart`._
