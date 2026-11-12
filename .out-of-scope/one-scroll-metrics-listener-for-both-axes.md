# One scroll-metrics listener for both axes

This package keeps two `ScrollMetricsNotification` listeners, one per axis. They
are not merged into one.

## Why this is out of scope

The two listeners keep different things in step, and they are owned by different
modules:

- **Vertical (#194).** `SyncedScrollControllers` listens for a depth-0 vertical
  notification and moves the **vertical scrollbar** to the body's offset. It
  exists because a body jump made before layout, by the expand/collapse anchor in
  `didUpdateWidget`, is mirrored to the scrollbar clamped to the old end
  ([`pre-layout-extent`](../docs/map/invariant/pre-layout-extent.md)).
- **Horizontal (#179).** `FolderViewContent` listens on the hidden horizontal
  `SingleChildScrollView` and updates `_horizontalOffset`, the `ValueNotifier`
  the rows translate by. That notifier is `FolderViewContent`'s own state and has
  nothing to do with the horizontal scrollbar.

The horizontal scrollbar does not have the vertical problem. The only
programmatic jump on the horizontal controller is the Scale anchor's, made in a
post-frame callback after layout, when the extents are already the new ones.
Nothing jumps it before layout, so there is nothing for a metrics-driven follow
to fix there.

Merging the listeners would have `SyncedScrollControllers` update
`FolderViewContent`'s row offset, through a callback or by owning that state. It
would remove one listener and make the two modules depend on each other.

This was read from the code at `1901ea7`. A merged listener was not tried.

## What would reopen it

A programmatic horizontal jump made before layout, which would give the
horizontal scrollbar the same stale-clamp problem the vertical one had.

## Prior requests

- #200: "One ScrollMetricsNotification listener could keep both axes in step after layout"
