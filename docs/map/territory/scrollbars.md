# Scrollbars

## What it is
The view's own vertical and horizontal scrollbars: a track box styled by `FolderViewScrollbarTheme`, a thumb inside it (`FolderViewScrollbarThumb`: Material's `Scrollbar`, or on iOS a `RawScrollbar`), shown on hover of the whole view. Each bar is its own `Scrollable` over a bar controller that [scroll-sync](scroll-sync.md) pairs with the list.

## Governing decisions
- [ADR-0001](../../adr/0001-scrollbars-excluded-from-scale.md): scrollbars are chrome and keep their physical size at every Scale.

## Design model
Read from the bar widgets, `folderViewThumbTheme` and `FolderViewScrollbarThumb`.
- **One track per bar.** The `Container` styled by `trackColor`, `trackWidth` and `trackRadius` is the only track. `trackVisibility`, which turned on Material's own faint inner track (never in `trackColor`), was removed in 0.12.0 (#122). Feeding `trackColor` into Material's track was rejected: the same colour over the same colour would make the field a switch with almost no visible effect (maintainer, 2026-10-21, #122).
- **The thumb stays inside the track.** `_thumbMetrics`, which both `folderViewThumbTheme` and the iOS `RawScrollbar` read, sets `crossAxisMargin` to Material's own platform default (0 on Android, 2 elsewhere) and paints `min(thickness, trackWidth − margin)`, floored at 0. The theme keeps the `thickness` it was given. Material places the thumb at `width − thickness − crossAxisMargin`, so a cap at `trackWidth` alone would still overflow 2 px on desktop; the probe behind the first proposal ran on the test default, Android (#122). Before the fix, `thickness` 20 in an 8 px track painted the thumb from x = −12 (Android) or −14 (desktop) (CHANGELOG 0.12.0). Margin-aware cap chosen by the maintainer at triage and the confirm stop, 2026-10-21. Pinned by `test/widgets/folder_view_scrollbar_track_test.dart`, on Android and Windows.
- **The theme paints the thumb on iOS too** (#147). Material's `Scrollbar.build` returns a `CupertinoScrollbar` on `TargetPlatform.iOS`, built only from its own constructor arguments: thickness 3 (8 while dragged), radius 1.5 (4 while dragged) and a fixed `CupertinoDynamicColor`, with no thumb colour argument; the `ScrollbarThemeData` the bars passed was never read (Flutter 3.47.1 SDK, `material/scrollbar.dart`, `cupertino/scrollbar.dart`). Measured at triage on 52d2415 with thickness 6, radius 1, `thumbColor` 0xFFFF0000, `thumbVisibility` true:

  | Target | Widget | Painter thickness / radius / colour |
  |---|---|---|
  | iOS | `CupertinoScrollbar` ×2 | 3.0 / 1.5 / Cupertino default (black 35%, dark white 50%) |
  | Windows | Material | 6.0 / 1.0 / red |

  **Decided by the maintainer at triage, 2026-11-15** (a judgement, shown the table above): iOS is a target and the whole theme applies there; the thumb is not handed to Cupertino, because the theme already draws its own track and a field that works on some platforms and not others breaks its contract. The cost was shown and accepted: iOS loses the native Cupertino thumb, including its thickening on drag. Declined: passing only `thickness` and `radius` as constructor arguments and documenting `thumbColor` as Material-only; documenting all three as ignored on iOS. Not covered by the decision: Android's own scrollbar defaults.

  **Mechanism** (a derivation): on iOS `FolderViewScrollbarThumb` builds a `RawScrollbar` from the same `folderViewThumbTheme` values, with what `_MaterialScrollbar` paints with off Android when the theme sets colour, thickness, radius and margin: margin 2, `minThumbLength` 48 with `minOverscrollLength` 18 (Material sets the painter's `minLength` to 48 and leaves the overscroll length at `RawScrollbar`'s 18), fade 300 / 600 ms, no press delay, gestures on, no inner track. Every other platform keeps Material's `Scrollbar` unchanged. A `RawScrollbar` on every platform was not taken: the existing tests locate the bar by `find.byType(Scrollbar)`, and the other platforms would have moved off a path the issue said to leave alone. On iOS the bar's own `Scrollable` keeps its platform physics (bouncing), as before. Pinned by `test/widgets/folder_view_scrollbar_thumb_platform_test.dart` (iOS, Windows, Android; both bars; the cap).
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
- `lib/widgets/folder_view_scrollbar_thumb.dart` — `_thumbMetrics`, `folderViewThumbTheme`, `FolderViewScrollbarThumb`
- `lib/themes/folder_view_scrollbar_theme.dart` — `FolderViewScrollbarTheme`
- `lib/widgets/folder_view.dart` — `FolderView.build` (`needsHorizontalScroll`, `needsVerticalScroll`)
- `lib/widgets/folder_view_content.dart` — `_FolderViewContentState.build` (`_isHover`, the bars, the spacer)

## Reference behaviour
Material's `Scrollbar` and `widgets/scrollbar.dart` thumb placement, read from the Flutter SDK for #122 (route in [`thegraph.md`](../../agents/thegraph.md)). Not pinned to a version. `_MaterialScrollbar`'s painter values and `CupertinoScrollbar`'s defaults, read from the Flutter 3.47.1 SDK for #147.

## Cross-cutting invariants
- [chrome-excluded-from-scale](../invariant/chrome-excluded-from-scale.md) — `scrollbarTheme` is the one sub-theme `FlutterFolderViewTheme.scale` skips.
- [row-extent](../invariant/row-extent.md) — the vertical bar's content is `contentHeight` tall, the list's extent.

## Blast radius
- [scroll-sync](scroll-sync.md) — a bar's offset is mirrored to the list, clamped to the end its position reports, which is the list's; the vertical bar also follows the list after a layout that changes the list's metrics.
- [row-geometry](row-geometry.md) — `contentHeight` and `contentWidth` size the bars' scroll content.
- [scale-input](scale-input.md) — a modifier wheel over a bar is refused by the main position's physics.
- [wheel-motion](wheel-motion.md) — a wheel over a bar is handed to the main controller of that axis.
- [scroll-anchoring](scroll-anchoring.md) — each bar's scroll notifications tell the anchor whether that bar is dragged, so an anchor during a drag on the bar corrects the bar instead of ending the drag (#203 vertical, #208 the Scale anchor on both axes).

## Known holes / open
- **An ancestor `ScrollbarTheme` widget replaces the thumb theme off iOS.** `ScrollbarTheme.of` returns the nearest `ScrollbarTheme` widget's data before `Theme.of(context).scrollbarTheme`, and `_MaterialScrollbar` reads it that way, so an app's `ScrollbarTheme` around `FolderView` would replace `thickness`, `radius`, `thumbColor` and the #122 cap on every platform but iOS, where the `RawScrollbar` reads no theme. Read from the Flutter 3.47.1 SDK (`material/scrollbar_theme.dart`, `ScrollbarTheme.of`) during #147, not probed. Not tracked.
- **A thumb drag at the end on the iOS target.** The #208 / #210 tests that drag the thumb to the end and then change rows above the view together with the view's size end the drag on the iOS target (`IdleScrollActivity` instead of `DragScrollActivity`). Measured during #147 with the test files copied to the iOS target: they fail the same way with the Cupertino thumb before the fix and the `RawScrollbar` after it, so the thumb widget is not the cause; the bar's iOS physics (bouncing) is a guess, not diagnosed. The same copies otherwise pass: thumb drag, track tap and Scale or anchor changes during a drag. Not tracked.
