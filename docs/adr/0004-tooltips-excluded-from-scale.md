# Tooltips are excluded from Scale

**Tooltips** are classified as **chrome** — supplementary UI surfaces overlaid on content rather than part of the rendered tree itself. They are therefore excluded from `FlutterFolderViewTheme.scale`, mirroring the treatment already established for scrollbars in ADR-0001.

This decision overrides a prior interpretation, briefly held during the per-Theme `scale` refactor, where `NodeTooltipTheme` participated in scaling. Empirical testing showed that:

- The just_tooltip package supplies its own un-scaled text-size defaults when `NodeTooltipTheme.textStyle` is null, so tooltip text remained at the host size even when the box and arrow scaled.
- The resulting visual state — large box with small text — was worse than the original "tooltip does not scale at all" behavior.
- OS-level conventions agree: zooming a webpage in Chrome, or increasing system text size, leaves tooltips at a fixed physical size.

Reasons to treat tooltips as chrome rather than content:

- A tooltip appears on demand (hover/tap) and is meant for reading regardless of the underlying view zoom. Scaling it with content makes it harder to read at small scales and visually disruptive at large scales.
- A tooltip's arrow and padding are sized for pointer/finger interaction, not for content density — same argument as scrollbars in ADR-0001.
- Container chrome (scrollbars, tooltips, overlays) and content (tree rows, icons, text) form a coherent dichotomy in this library. Drawing the line consistently keeps the **Scale** contract small and predictable.

## Encoding

Like ADR-0001, this decision is encoded **structurally**: `NodeTooltipTheme` has no `scale` method. Calling `tooltipTheme.scale(...)` is a compile error. The `*NodeTheme.scale` methods explicitly do not delegate to `tooltipTheme.scale` (and a `// ADR-0004` comment marks the omission). A future contributor cannot accidentally re-enable tooltip scaling without first defining a `scale` method on `NodeTooltipTheme` — at which point this ADR is the next thing they should read.

## Caller workaround if scaling is genuinely desired

A caller who wants their tooltips to scale with the view (against this ADR's recommendation) can wire it manually in their own state-management layer: derive a scaled `NodeTooltipTheme` themselves from the `FolderView.scale` they're already feeding the widget, and supply explicit spatial values (offset, padding, arrowBaseWidth, arrowLength, screenMargin, textStyle, borderRadius). Nothing in the library prevents this — but it must be opt-in, on the caller, and explicit.
