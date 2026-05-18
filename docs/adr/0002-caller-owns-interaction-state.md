# Caller owns interaction state (controlled-state pattern)

The library treats all interaction state — the **Expanded Set**, the **Selected Set**, and **Scale** — as **caller-owned**. The widget reads these values from its constructor but never mutates them. State changes happen only when the caller's own state-management layer (setState, Provider, Riverpod, BLoC, etc.) responds to library-emitted callbacks (`onNodeTap`, `onScaleChanged`, etc.) and feeds new values back through `setState`.

## Alternative considered

Holding state inside `_FolderViewState` and exposing controllers or imperative methods (`folderViewController.expand(id)`, `.select(id)`, `.setScale(s)`).

Rejected because:

- Trees in real apps usually need to coordinate with external state — the URL, persisted user preferences, selection-driven side effects. Internal state would force every caller to mirror it.
- Controllers introduce a second source of truth that drifts from the widget's `data` prop on rebuild.
- The controlled pattern composes naturally with reactive frameworks already shown in `example/lib/`.

## Trade-off

Callers write a few extra `setState` calls for the trivial single-page case. Accepted cost in exchange for predictable single-source-of-truth state flow.
