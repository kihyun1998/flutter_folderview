import 'package:example/main.dart';
import 'package:flutter/material.dart';
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
void main() {
  testWidgets('the demo opens on Bare — no label tooltip wraps a Node', (
    tester,
  ) async {
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
}
