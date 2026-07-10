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

  /// A Child label long enough to make its row the widest in the tree. The row
  /// is sized to it, and `Flexible` grows the label to fill the row — so this
  /// label's rect *is* the row's. It is not truncated: inside a FolderView the
  /// content width adapts to the longest label (up to 3x the viewport).
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

  /// Gives the Expandable rows a real chevron. The theme's `widget` is
  /// caller-supplied and null by default, which renders an empty spacer.
  FlutterFolderViewTheme<String> themeWithChevron() =>
      const FlutterFolderViewTheme<String>(
        lineTheme: FolderViewLineTheme(lineColor: Color(0xFF000000)),
        scrollbarTheme: FolderViewScrollbarTheme(
          thumbColor: Color(0xFF000000),
          trackColor: Color(0xFF000000),
        ),
        expandIconTheme: ExpandIconTheme(widget: Icon(Icons.chevron_right)),
      );

  Future<void> pump(
    WidgetTester tester, {
    Widget? Function(BuildContext, Node<String>)? rowTooltipBuilder,
    String label = 'a.pdf',
    FlutterFolderViewTheme<String>? theme,
    void Function(Node<String>)? onNodeTap,
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
              onNodeTap: onNodeTap,
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

  group('the row card and the row s gestures', () {
    // A smoke guard, not a strong one. An ancestor cannot steal a descendant's
    // tap — hit testing is depth-first, so CustomInkWell's recogniser enters
    // the gesture arena before any wrapper's and wins the sweep. Wrapping the
    // row in a GestureDetector, opaque or not, was verified not to break this.
    // What this test would catch is an AbsorbPointer or IgnorePointer.
    testWidgets('tapping a row wrapped in a card still fires onNodeTap',
        (tester) async {
      final tapped = <Node<String>>[];
      await pump(tester,
          rowTooltipBuilder: cardForChild, onNodeTap: tapped.add);

      await tester.tap(find.text('a.pdf'));
      await tester.pump(const Duration(milliseconds: 400)); // click timer

      expect(tapped, hasLength(1));
      expect(tapped.single.id, 'c0');
    });

    // Deliberately absent: a test that the card is hover-only. `enableTap` on
    // the wrapper is a no-op here — it adds a GestureDetector whose onTap never
    // fires, because CustomInkWell wins the arena. Setting it changes nothing
    // observable, so no test can hold it fixed. Verified, not assumed.
  });

  // The Expandable renderer puts the chevron beside the label part, so the
  // chevron sits inside the row card's hover region and outside the label
  // tooltip's. The Child renderer has no chevron at all.
  group('the row card covers an Expandable row s chevron', () {
    testWidgets('hovering the chevron shows the card', (tester) async {
      await pump(
        tester,
        theme: themeWithChevron(),
        rowTooltipBuilder: (context, node) => node.id == 'f'
            ? const SizedBox(key: Key('card'), width: 100, height: 40)
            : null,
      );

      final chevron = tester.getRect(find.byIcon(Icons.chevron_right).first);
      final gesture = await mouse(tester);
      await gesture.moveTo(chevron.center);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('card')), findsOneWidget);
    });

    testWidgets('tapping the chevron still fires onNodeTap', (tester) async {
      final tapped = <Node<String>>[];
      await pump(
        tester,
        theme: themeWithChevron(),
        rowTooltipBuilder: (context, node) =>
            const SizedBox(key: Key('card'), width: 100, height: 40),
        onNodeTap: tapped.add,
      );

      await tester.tap(find.byIcon(Icons.chevron_right).first);
      await tester.pump(const Duration(milliseconds: 400));

      expect(tapped, hasLength(1));
      expect(tapped.single.id, 'f',
          reason: 'Expansion is caller-driven (ADR-0002): the card must leave '
              'the chevron tap reaching onNodeTap');
    });
  });

  // Coexistence. `just_tooltip` suppresses an ancestor tooltip whenever a
  // descendant one that has something to draw contains the pointer, so exactly
  // one is ever visible: the innermost. The qualifier never bites here, because
  // an empty tooltip is never built: see the guards in `wrapWithNodeTooltip`
  // and `_wrapWithRowTooltip`. These tests characterise that, they do not
  // implement it.
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

    // The trap. The widest row is sized to its own label, and the label grows
    // to fill it, so the label's rect spans the row. There is then no point on
    // the row where the label tooltip does not contain the pointer — and it is
    // the innermost. The row card is unreachable for that Node.
    testWidgets('a row-spanning label leaves the row card nowhere to appear',
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
