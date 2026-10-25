# Scrollbars

## What it is
The view's own vertical and horizontal scrollbars: a track box styled by `FolderViewScrollbarTheme`, a Material `Scrollbar` thumb inside it, shown on hover of the whole view. Each bar is its own `Scrollable` over a bar controller that [scroll-sync](scroll-sync.md) pairs with the list.

## Governing decisions
- [ADR-0001](../../adr/0001-scrollbars-excluded-from-scale.md): scrollbars are chrome and keep their physical size at every Scale.

## Design model
Read from the bar widgets and `folderViewThumbTheme`.
- **One track per bar.** The `Container` styled by `trackColor`, `trackWidth` and `trackRadius` is the only track. `trackVisibility`, which turned on Material's own faint inner track (never in `trackColor`), was removed in 0.12.0 (#122). Feeding `trackColor` into Material's track was rejected: the same colour over the same colour would make the field a switch with almost no visible effect (maintainer, 2026-10-21, #122).
- **The thumb stays inside the track.** `folderViewThumbTheme` sets `crossAxisMargin` to Material's own platform default (0 on Android, 2 elsewhere) and paints `min(thickness, trackWidth − margin)`, floored at 0. The theme keeps the `thickness` it was given. Material places the thumb at `width − thickness − crossAxisMargin`, so a cap at `trackWidth` alone would still overflow 2 px on desktop; the probe behind the first proposal ran on the test default, Android (#122). Before the fix, `thickness` 20 in an 8 px track painted the thumb from x = −12 (Android) or −14 (desktop) (CHANGELOG 0.12.0). Margin-aware cap chosen by the maintainer at triage and the confirm stop, 2026-10-21. Pinned by `test/widgets/folder_view_scrollbar_track_test.dart`, on Android and Windows.
- **Shown on hover.** `_FolderViewContentState.build` tracks hover of the whole view in `_isHover`; each bar fades between `hoverOpacity` and `nonHoverOpacity` over `hoverAnimationDuration`. With `light()`'s `nonHoverOpacity` of 0 the bars are invisible until the pointer is over the tree.
- **Layout.** A bar is built only when its axis needs scrolling. When the horizontal bar is present, a `trackWidth`-high spacer is reserved under the list and the vertical bar stops above it.
- **Unscaled.** `FlutterFolderViewTheme.scale` does not delegate to `scrollbarTheme`, so the bars receive the theme as given ([chrome-excluded-from-scale](../invariant/chrome-excluded-from-scale.md)).
- A Scale Modifier + wheel over a bar is claimed by `ModifierWheelGuard` while blocking is in effect ([scale-input](scale-input.md)).

## Code
- `lib/widgets/folder_view_vertical_scrollbar.dart` — `FolderViewVerticalScrollbar`
- `lib/widgets/folder_view_horizontal_scrollbar.dart` — `FolderViewHorizontalScrollbar`
- `lib/widgets/folder_view_scrollbar_thumb.dart` — `folderViewThumbTheme`
- `lib/themes/folder_view_scrollbar_theme.dart` — `FolderViewScrollbarTheme`
- `lib/widgets/folder_view_content.dart` — `_FolderViewContentState.build` (`_isHover`, the bars, the spacer)

## Reference behaviour
Material's `Scrollbar` and `widgets/scrollbar.dart` thumb placement, read from the Flutter SDK for #122 (route in [`thegraph.md`](../../agents/thegraph.md)). Not pinned to a version.

## Cross-cutting invariants
- [chrome-excluded-from-scale](../invariant/chrome-excluded-from-scale.md) — `scrollbarTheme` is the one sub-theme `FlutterFolderViewTheme.scale` skips.
- [row-extent](../invariant/row-extent.md) — the vertical bar's extent is `contentHeight`, which disagrees with the list's.

## Blast radius
- [scroll-sync](scroll-sync.md) — a bar's offset is mirrored to the list, clamped to the bar's own extent.
- [row-geometry](row-geometry.md) — `contentHeight` and `contentWidth` size the bars' scroll content.
- [scale-input](scale-input.md) — the guard inside each bar decides whether a modifier wheel scrolls it.
- [wheel-motion](wheel-motion.md) — a wheel over a bar is not animated, because the bar's controller is a plain `ScrollController`.

## Known holes / open
- **Not covered: iOS.** There Material's `Scrollbar` builds a `CupertinoScrollbar` from its own constructor arguments. The bars pass thickness, radius and thumb colour only through `ScrollbarThemeData`, so on iOS those three are ignored, and the #122 cap does not apply. Read from the code, not probed. Tracked: #147.
