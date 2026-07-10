import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_tooltip/just_tooltip.dart';

/// What a preset does to the settings is asserted in `demo_preset_test.dart`,
/// without a widget. This file asserts what a preset does to the *rendered
/// view*, because #61 requires a preset named for an interaction to actually
/// produce that interaction — a promise the settings alone cannot keep.
///
/// The seam is `MyApp`, pumped whole. Pumping the panel or the preset bar in
/// isolation would size them in an artificial box; #52 established that a
/// `Flexible` measured that way reports an ellipsized label where the real view
/// reports none.
/// The demo is a desktop app. At the default 800×600 test surface the preset
/// bar leaves the `FolderView` 176px tall — four rows — and no Child ever
/// renders, because the widget-test font draws every glyph as a square of the
/// font size and wraps the preset's "what to look for" line into a paragraph.
/// Measured: at 1600×1000 the view is 1162×752 and the Children appear.
void _desktopSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1600, 1000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('the demo opens on Bare — no label tooltip wraps a Node', (
    tester,
  ) async {
    _desktopSurface(tester);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final folderView = find.byType(FolderView<String>);
    expect(folderView, findsOneWidget);

    // Assert the absence of the wrapper itself, not of some marker inside it.
    // #48: a test that looked for a missing key stayed green while every row
    // was being wrapped in an empty tooltip.
    final anyLabel = find
        .descendant(of: folderView, matching: find.byType(Text))
        .first;
    expect(
      find.ancestor(of: anyLabel, matching: find.byType(JustTooltip)),
      findsNothing,
      reason: 'Bare turns every tooltip off, so nothing wraps a Node',
    );
  });

  testWidgets('Row card over a long label renders a label wider than the view', (
    tester,
  ) async {
    _desktopSurface(tester);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Row card over a long label'));
    await tester.pumpAndSettle();

    final folderView = find.byType(FolderView<String>);
    final viewportWidth = tester.getSize(folderView).width;

    final longLabel = find
        .descendant(of: folderView, matching: find.textContaining('.pdf'))
        .first;
    final labelWidth = tester.getSize(longLabel).width;

    // Measured: label 1197.0, viewport 1162.0.
    expect(
      labelWidth,
      greaterThan(viewportWidth),
      reason:
          'the interaction this preset is named for only exists when the row '
          'is wider than the view that shows it',
    );

    // And the label is NOT ellipsized while that is true. Inside a `FolderView`
    // the content width grows to fit the label, so the condition for the
    // tooltip drama is `contentWidth > viewportWidth`, not a truncated label.
    // Measured: didExceedMaxLines false, maxIntrinsicWidth 1197.0 == the rect.
    // #47 asserted the opposite causation for five surfaces before anyone
    // re-measured; #52 showed the same label reads as truncated when it is
    // measured inside a fixed-width box instead.
    final paragraph = tester.renderObject<RenderParagraph>(longLabel);
    expect(paragraph.didExceedMaxLines, isFalse);
    expect(paragraph.getMaxIntrinsicWidth(double.infinity), labelWidth);
  });

  testWidgets('Tree Mode over a deep hierarchy renders no Folder', (
    tester,
  ) async {
    _desktopSurface(tester);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tree Mode over a deep hierarchy'));
    await tester.pumpAndSettle();

    final folderView = find.byType(FolderView<String>);

    // Tree Mode is a projection that hides Folders and lifts Parents to the
    // root. The generator names Folders "Department N" at the root and
    // "Folder N - Depth D" beneath; a Parent is "Category N".
    expect(
      find.descendant(
        of: folderView,
        matching: find.textContaining('Department'),
      ),
      findsNothing,
    );
    expect(
      find.descendant(of: folderView, matching: find.textContaining('Depth')),
      findsNothing,
    );
    expect(
      find.descendant(
        of: folderView,
        matching: find.textContaining('Category'),
      ),
      findsWidgets,
      reason: 'the Parents the Folders contained are lifted to the root',
    );
  });
}
