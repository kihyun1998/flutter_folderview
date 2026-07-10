import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_tooltip/just_tooltip.dart' show JustTooltip;

/// The row tooltip: a card shown while hovering anywhere on a Node's rendered
/// row, declared once on [FolderView] rather than per Tier.
///
/// Harness constraints (see `node_tooltip_anchor_placement_test.dart` for how
/// each was learned): no `waitDuration`, one case per `testWidgets` because
/// `just_tooltip`'s registry is a package-level singleton, and a fixed-size
/// zero-padding card so `screenMargin` clamping never shifts a measured
/// coordinate.
void main() {
  // Folder 'f' > Parent 'p' > Child 'c0'. The Child carries a short label, so a
  // wide row leaves empty space to its right — space that raises no label
  // tooltip today, and is therefore where a row card must become visible.
  List<Node<String>> data(String childLabel) => [
        Node<String>(
          id: 'f',
          label: 'folder-f',
          type: NodeType.folder,
          children: [
            Node<String>(
              id: 'p',
              label: 'parent-p',
              type: NodeType.parent,
              children: [
                Node<String>(id: 'c0', label: childLabel, type: NodeType.child),
              ],
            ),
          ],
        ),
      ];

  /// A Child label long enough to ellipsize: its rect then spans the whole row.
  const String longLabel =
      'a_very_long_report_filename_that_will_certainly_be_ellipsized.pdf';

  /// Enables the Child Tier's label tooltip, so it nests inside the row card.
  FlutterFolderViewTheme<String> themeWithLabelTooltip() =>
      FlutterFolderViewTheme<String>(
        lineTheme: const FolderViewLineTheme(lineColor: Color(0xFF000000)),
        scrollbarTheme: const FolderViewScrollbarTheme(
          thumbColor: Color(0xFF000000),
          trackColor: Color(0xFF000000),
        ),
        childTheme: ChildNodeTheme<String>(
          tooltipTheme: NodeTooltipTheme<String>(
            useTooltip: true,
            padding: EdgeInsets.zero,
            tooltipBuilder: (_) =>
                const SizedBox(key: Key('labeltip'), width: 80, height: 30),
          ),
        ),
      );

  Future<void> pump(
    WidgetTester tester, {
    Widget? Function(BuildContext, Node<String>)? rowTooltipBuilder,
    String label = 'a.pdf',
    FlutterFolderViewTheme<String>? theme,
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 400,
            height: 200,
            child: FolderView<String>(
              data: data(label),
              mode: ViewMode.folder,
              expandedNodeIds: const {'f', 'p'},
              theme: theme,
              rowTooltipBuilder: rowTooltipBuilder,
            ),
          ),
        ),
      ),
    ));
  }

  Widget? cardForChild(BuildContext context, Node<String> node) =>
      node.id == 'c0'
          ? const SizedBox(key: Key('card'), width: 100, height: 40)
          : null;

  Future<TestGesture> mouse(WidgetTester tester) async {
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();
    return gesture;
  }

  testWidgets('a row card appears when hovering the empty space beside a label',
      (tester) async {
    await pump(tester, rowTooltipBuilder: cardForChild);

    final label = tester.getRect(find.text('a.pdf'));
    expect(find.byKey(const Key('card')), findsNothing);

    final gesture = await mouse(tester);
    // Well to the right of the label's glyphs: empty row space.
    await gesture.moveTo(Offset(label.right + 120, label.center.dy));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('card')), findsOneWidget);
  });

  testWidgets('a Node whose builder returns null is left unwrapped',
      (tester) async {
    await pump(tester, rowTooltipBuilder: cardForChild);

    // Asserting the card's absence is not enough: a row wrapped in a tooltip
    // with empty content would satisfy that too. Assert the absence of the
    // wrapper itself.
    expect(
      find.ancestor(
        of: find.text('folder-f'),
        matching: find.byType(JustTooltip),
      ),
      findsNothing,
      reason: 'the builder returned null for the Folder, so no JustTooltip',
    );
    expect(
      find.ancestor(
        of: find.text('a.pdf'),
        matching: find.byType(JustTooltip),
      ),
      findsOneWidget,
      reason: 'and exactly one for the Child, which does have a card',
    );
  });

  // The card is anchored at the pointer, never at the row's rect. A row is as
  // wide as the tree's content, so its centre leaves the viewport as soon as
  // the view scrolls horizontally — a card anchored there would be unreachable.
  group('the card is anchored at the pointer', () {
    testWidgets('on a row narrower than the viewport', (tester) async {
      await pump(tester, rowTooltipBuilder: cardForChild);

      final label = tester.getRect(find.text('a.pdf'));
      expect(label.width, lessThan(400));

      final gesture = await mouse(tester);
      await gesture.moveTo(Offset(320, label.center.dy));
      await tester.pumpAndSettle();

      final card = tester.getRect(find.byKey(const Key('card')));
      expect(card.center.dx, moreOrLessEquals(320, epsilon: 0.5));
    });

    testWidgets('on a row wider than the viewport', (tester) async {
      await pump(tester, label: longLabel, rowTooltipBuilder: cardForChild);

      final label = tester.getRect(find.text(longLabel));
      expect(label.width, greaterThan(400),
          reason: 'the row really did outgrow its 400px viewport');

      final gesture = await mouse(tester);
      await gesture.moveTo(Offset(120, label.center.dy));
      await tester.pumpAndSettle();

      final card = tester.getRect(find.byKey(const Key('card')));
      expect(card.center.dx, moreOrLessEquals(120, epsilon: 0.5),
          reason: 'the card follows the cursor');
      expect(
          card.center.dx, isNot(moreOrLessEquals(label.center.dx, epsilon: 1)),
          reason: 'and emphatically not the off-screen centre of the row');
    });
  });

  // Coexistence. `just_tooltip` suppresses an ancestor tooltip whenever a
  // descendant one contains the pointer, so exactly one is ever visible: the
  // innermost. These tests characterise that, they do not implement it.
  group('label tooltip nested inside the row card', () {
    testWidgets('hovering the glyphs of a short label shows the label tooltip',
        (tester) async {
      await pump(
        tester,
        rowTooltipBuilder: cardForChild,
        theme: themeWithLabelTooltip(),
      );

      final label = tester.getRect(find.text('a.pdf'));
      final gesture = await mouse(tester);
      await gesture.moveTo(label.center);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('labeltip')), findsOneWidget);
      expect(find.byKey(const Key('card')), findsNothing,
          reason: 'the innermost tooltip under the pointer wins');
    });

    testWidgets('hovering beside a short label shows the row card',
        (tester) async {
      await pump(
        tester,
        rowTooltipBuilder: cardForChild,
        theme: themeWithLabelTooltip(),
      );

      final label = tester.getRect(find.text('a.pdf'));
      final gesture = await mouse(tester);
      await gesture.moveTo(Offset(label.right + 120, label.center.dy));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('card')), findsOneWidget);
      expect(find.byKey(const Key('labeltip')), findsNothing,
          reason: 'the pointer is outside the label, so only the row remains');
    });

    // The trap. An ellipsized label consumed all the width available to it, so
    // its rect spans the row. There is then no point on the row where the label
    // tooltip does not contain the pointer — and it is the innermost. The row
    // card is unreachable for that Node.
    testWidgets('an ellipsized label leaves the row card nowhere to appear',
        (tester) async {
      await pump(
        tester,
        label: longLabel,
        rowTooltipBuilder: cardForChild,
        theme: themeWithLabelTooltip(),
      );

      final label = tester.getRect(find.text(longLabel));
      expect(label.width, greaterThan(400),
          reason: 'the label really did span past the viewport');

      final gesture = await mouse(tester);
      // A point inside the viewport. The label's own centre is off screen —
      // moving the cursor there would dispatch no hover at all.
      await gesture.moveTo(Offset(200, label.center.dy));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('labeltip')), findsOneWidget);
      expect(find.byKey(const Key('card')), findsNothing,
          reason: 'callers wanting a row card must disable the label tooltip '
              'for that Tier');
    });
  });
}
