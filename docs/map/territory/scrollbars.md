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
- **Layout.** A bar is built only when its axis needs scrolling. When the horizontal bar is present, a `trackWidth`-high spacer is reserved under the list and the vertical bar stops above it. `FolderView.build` decides the horizontal axis from the width alone, then the vertical axis against the list's own viewport: the available height, less the spacer's `trackWidth` when the horizontal bar is present. The decision, the spacer (`_FolderViewContentState.build`) and the vertical bar's bottom inset (`FolderViewVerticalScrollbar.build`) read the same unscaled `scrollbarTheme.trackWidth` with no shared helper; if the decision and the spacer drift, the list scrolls with no vertical bar, or a bar shows over a list that cannot scroll. Comparing against the whole height left a band, content height < view height < content height + `trackWidth`, where the list scrolled with no vertical bar: at height 324 with content 320 the list's end was 12 (#177, probed 2026-11-07 and 2026-11-11). The vertical bar overlays the rows and reserves no width, so the two decisions do not depend on each other. Pinned by `test/widgets/folder_view_vertical_scrollbar_band_test.dart`. The two bars are conditional children of one `Stack` and carry keys (`ValueKey(Axis.vertical)`, `ValueKey(Axis.horizontal)`, #175): without them, the vertical bar leaving moved the horizontal one into its slot, a new bar `Scrollable` started at 0 while the rows stayed scrolled (200 against 0), and a sideways notch over it was lost. Either key alone keeps the slots apart; removing both kills the test in `test/widgets/folder_view_scrollbar_wheel_test.dart`. flutter_table_plus's #214 also takes the body's offset when a bar attaches; here a bar appears only when its body could not scroll, so at 0, and a vertical bar coming back read 0 / 0 (probed 2026-11-08), so nothing does that on attach. The vertical bar's first layout does send a metrics notification, so [scroll-sync](scroll-sync.md)'s re-follow would move it to the body's offset a frame later (read from the SDK, not probed); the horizontal bar has nothing like it.
- **Unscaled.** `FlutterFolderViewTheme.scale` does not delegate to `scrollbarTheme`, so the bars receive the theme as given ([chrome-excluded-from-scale](../invariant/chrome-excluded-from-scale.md)).
- A Scale Modifier + wheel over a bar moves nothing while blocking is in effect ([scale-input](scale-input.md)).
- **Shift+wheel over the horizontal bar scrolls it sideways, in both states** (#169; maintainer, 2026-11-07, shown the Shift table below and `flutter_table_plus`'s `_handleHorizontalScrollbarSignal`). `RawScrollbar` reads the wheel along its own axis and ignores `pointerAxisModifiers` (flutter/flutter#193282, open), so once the thumb has faded in a vertical notch did nothing. A `Listener` around the horizontal `Scrollbar` (`FolderViewHorizontalScrollbar._handleAxisModifierWheel`) claims a mouse wheel with an axis modifier held and hands its `dy` to the bar's `pointerScroll`, so it joins the wheel motion. It mirrors the checks `RawScrollbar` and `Scrollable` make before taking a wheel: no pointer pressed on the bar (a Shift notch during a thumb drag ended the drag), the `dy` negated on a reversed axis (right to left, a notch moved the bar the other way once the thumb had faded in), and no claim when the bar is at its end, so the notch reaches an enclosing scroll view. Before the fade, the bar's own `Scrollable` flips the axis and registers first, with the same result. Over the rows and the vertical bar, Shift+wheel is left to Flutter. Measured on 9b5d261 (Windows target, 400×160 view), Shift with a vertical notch of 60:

  | Over | Before the fade | Faded in |
  |---|---|---|
  | the horizontal bar | sideways 60 | 0, now sideways 60 |
  | the vertical bar | 0 | down 60 |
  | the rows | 0 | 0 |

  A trackpad and a wheel without the modifier are not claimed, as `Scrollable` flips axes for a mouse wheel only. Pinned by `test/widgets/folder_view_scrollbar_wheel_test.dart`.

## Code
- `lib/widgets/folder_view_vertical_scrollbar.dart` — `FolderViewVerticalScrollbar`
- `lib/widgets/folder_view_horizontal_scrollbar.dart` — `FolderViewHorizontalScrollbar`, `FolderViewHorizontalScrollbar._handleAxisModifierWheel`
- `lib/widgets/folder_view_scrollbar_thumb.dart` — `folderViewThumbTheme`
- `lib/themes/folder_view_scrollbar_theme.dart` — `FolderViewScrollbarTheme`
- `lib/widgets/folder_view.dart` — `FolderView.build` (`needsHorizontalScroll`, `needsVerticalScroll`)
- `lib/widgets/folder_view_content.dart` — `_FolderViewContentState.build` (`_isHover`, the bars, the spacer)

## Reference behaviour
Material's `Scrollbar` and `widgets/scrollbar.dart` thumb placement, read from the Flutter SDK for #122 (route in [`thegraph.md`](../../agents/thegraph.md)). Not pinned to a version.

## Cross-cutting invariants
- [chrome-excluded-from-scale](../invariant/chrome-excluded-from-scale.md) — `scrollbarTheme` is the one sub-theme `FlutterFolderViewTheme.scale` skips.
- [row-extent](../invariant/row-extent.md) — the vertical bar's content is `contentHeight` tall, the list's extent.

## Blast radius
- [scroll-sync](scroll-sync.md) — a bar's offset is mirrored to the list, clamped to the end its position reports, which is the list's; the vertical bar also follows the list after a layout that changes the list's metrics.
- [row-geometry](row-geometry.md) — `contentHeight` and `contentWidth` size the bars' scroll content.
- [scale-input](scale-input.md) — a modifier wheel over a bar is refused by the main position's physics.
- [wheel-motion](wheel-motion.md) — a wheel over a bar is handed to the main controller of that axis.
- [scroll-anchoring](scroll-anchoring.md) — the vertical bar's scroll notifications tell the anchor whether the bar is dragged, so an anchor during a drag on the bar corrects the bar instead of ending the drag (#203).

## Known holes / open
- **Not covered: iOS.** There Material's `Scrollbar` builds a `CupertinoScrollbar` from its own constructor arguments. The bars pass thickness, radius and thumb colour only through `ScrollbarThemeData`, so on iOS those three are ignored, and the #122 cap does not apply. Read from the code, not probed. Tracked: #147.
