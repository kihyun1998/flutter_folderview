import 'package:example/scenarios/row_card_scenarios.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_tooltip/just_tooltip.dart' show JustTooltip;

import 'support/shell_harness.dart';

Finder _labelFinder(String label) => find.descendant(
  of: find.byType(FolderView<String>),
  matching: find.byWidgetPredicate(
    (w) => w is RichText && w.text.toPlainText().startsWith(label),
  ),
);

Future<TestGesture> _mouse(WidgetTester tester) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  addTearDown(mouse.removePointer);
  await mouse.addPointer(location: Offset.zero);
  return mouse;
}

/// Opens the scenario [label] in the Room.
Future<void> _openInRoom(WidgetTester tester, String label) async {
  await pumpShell(tester);
  await openDestination(tester, label);
  await tester.tap(find.byTooltip(ViewportBar.roomLabel));
  await tester.pumpAndSettle();
}

void main() {
  group('Scenario: Row card and label tooltip', () {
    const label = 'index.html';
    const card = 'Row card · index.html';

    testWidgets('on the label the label tooltip shows and the card does not', (
      tester,
    ) async {
      await _openInRoom(tester, 'Row card and label tooltip');
      final mouse = await _mouse(tester);

      await mouse.moveTo(tester.getCenter(_labelFinder(label)));
      await tester.pumpAndSettle();
      expect(find.text(RowCardNestingStage.labelTooltip), findsOneWidget);
      expect(find.text(card), findsNothing);
    });

    testWidgets('beside the label the card shows and the label tooltip does '
        'not', (tester) async {
      await _openInRoom(tester, 'Row card and label tooltip');
      final mouse = await _mouse(tester);

      final r = tester.getRect(_labelFinder(label));
      await mouse.moveTo(Offset(r.right + 40, r.center.dy));
      await tester.pumpAndSettle();
      expect(find.text(card), findsOneWidget);
      expect(find.text(RowCardNestingStage.labelTooltip), findsNothing);
    });
  });

  group('Scenario: A row wider than the viewport', () {
    testWidgets('scrolled to the far right, a hovered row\'s card opens beside '
        'the pointer, on screen, while the row\'s centre is off screen', (
      tester,
    ) async {
      await _openInRoom(tester, 'A row wider than the viewport');
      final view = tester.getRect(find.byType(FolderView<String>));

      final horizontal = tester
          .stateList<ScrollableState>(
            find.descendant(
              of: find.byType(FolderView<String>),
              matching: find.byType(Scrollable),
            ),
          )
          .firstWhere((s) => s.position.axis == Axis.horizontal);
      expect(horizontal.position.maxScrollExtent, greaterThan(0));
      horizontal.position.jumpTo(horizontal.position.maxScrollExtent);
      await tester.pumpAndSettle();

      // The short Child's row is as wide as the long one, and now mostly to
      // the left of the view.
      final row = tester.getRect(
        find.ancestor(
          of: _labelFinder('summary.pdf'),
          matching: find.byType(JustTooltip),
        ),
      );
      expect(view.contains(row.center), isFalse, reason: 'row centre $row');

      final mouse = await _mouse(tester);
      final at = Offset(view.right - 60, row.center.dy);
      await mouse.moveTo(at);
      await tester.pumpAndSettle();
      final text = find.text('Row card · summary.pdf');
      expect(text, findsOneWidget);
      final card = tester.getRect(
        find.ancestor(of: text, matching: find.byType(Card)),
      );
      final window = Offset.zero & tester.view.physicalSize;
      expect(window.contains(card.topLeft), isTrue);
      expect(window.contains(card.bottomRight), isTrue);
      expect(
        (card.center.dy - at.dy).abs(),
        lessThan(card.height + 20),
        reason: 'beside the pointer, card $card, pointer $at',
      );
      // Horizontally too: anchored to the row's visible part instead, the
      // card would sit at the centre of the view, far left of the pointer.
      expect(
        card.left <= at.dx + 20 && card.right >= at.dx - 20,
        isTrue,
        reason:
            'pointer x ${at.dx} outside card $card; view centre '
            '${view.center.dx}',
      );
    });
  });
}
