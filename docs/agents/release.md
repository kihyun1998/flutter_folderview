# Release

- Before a release, run `pub-ready`.
- Hover is seen by the maintainer. Before a release the maintainer runs the
  example and eyeballs hover. Report a hover change as tested, not as seen
  working, and name it for that eyeball pass.
- Before that pass, the agent reproduces hover with a screenshot probe and
  reports what it saw. The probe is evidence for the maintainer, not a
  replacement for the eyeball pass: its pointer events are synthesized by the
  test, so the path from the OS cursor into the app is not exercised.

## The hover probe

A throwaway integration test under `example/integration_test/`, run with
`flutter test integration_test/<file>.dart -d windows`. It draws with the real
engine and real fonts, so the screenshot shows the tooltip as it paints. It is
deleted after the run and not committed.

- Boot the shell with `pumpShell` (`example/test/support/shell_harness.dart`).
  Neither tooltip is on in "Every setting" by default:
  - the label tooltip needs `tooltipTier` and the `NodeTooltipTheme.useTooltip`
    switch, under "Tooltip placement";
  - the row card needs `FolderView.rowTooltipBuilder` set to `every Node`, under
    "Row card placement & surface".
- Hover with `tester.createGesture(kind: PointerDeviceKind.mouse)` and
  `moveTo`. Wait out `waitDuration` in real time (`Future.delayed`, then
  `pumpAndSettle`); the integration binding does not fake timers.
- Capture with `(binding.renderViews.first.debugLayer! as OffsetLayer).toImage`
  over `tester.view.physicalSize`, and write the PNG outside the repository.
  Print the pointer, label and tooltip rects next to each shot.
- For a row wider than the viewport, use the "A row wider than the viewport"
  destination. "Every setting" at the default desktop frame has a horizontal
  scroll extent of 0, so a scroll there measures nothing.
- For the label tooltip against the row card, use the "Row card and label
  tooltip" destination.
- Between two hovers in one test, move the pointer off the view and wait. A
  second hover can be suppressed by the global registry
  ([`lessons.md`](lessons.md), Step 2).
- Run one integration test file per `flutter test` call
  ([`lessons.md`](lessons.md), Step 6/7).
