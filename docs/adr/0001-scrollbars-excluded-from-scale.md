# Scrollbars are excluded from Scale

**Scale** is defined in `CONTEXT.md` as a uniform zoom factor on the **content** of the FolderView. Scrollbars are treated as **chrome** — interactive controls layered on top of content — and are deliberately not scaled.

Reasons:

- A thumb scaled below ~0.5× becomes too thin to grab reliably, especially on touch.
- A thumb scaled above ~2× covers a visually disruptive fraction of viewport width and competes with the content it controls.
- Track and scrollbar colors carry no spatial meaning, so scaling them is meaningless.

Callers who need a different scrollbar size at certain zoom levels can re-theme `FolderViewScrollbarTheme` manually — Scale and scrollbar theming are deliberately orthogonal.
