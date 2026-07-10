import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

/// A label tooltip is positioned against its target's rect — the Node's
/// icon-and-label content. A row is laid out at the tree's content width, not
/// the viewport's, and `Flexible` grows each label to fill its row. So the
/// longest label's rect is the row's, and when the tree scrolls horizontally
/// that rect runs past the visible view.
///
/// Ellipsis is not involved, and does not happen here: the content width adapts
/// to the longest label (up to 3x the viewport), so the label is laid out at
/// full intrinsic width and merely scrolled out of sight.
///
/// This used to place the tooltip outside the [FolderView] (#47): the target
/// was the label's whole rect, so [TooltipAnchor.child] aimed at a centre
/// nobody could see, and `screenMargin` did not object because it clamps
/// against the enclosing `Overlay` — the app's, not this view's box.
///
/// `just_tooltip 0.4.2` targets the *visible* part of a clipped child, so the
/// tooltip now lands inside the view. These tests hold that fixed. The exact
/// coordinate is not asserted: the real clip is narrower than the view's box
/// (a scrollbar gutter), and that width is not this test's concern.
///
/// Harness constraints are documented in
/// `node_tooltip_anchor_placement_test.dart`.
void main() {
  const double viewWidth = 400;
  const String longLabel =
      'a_very_long_report_filename_that_will_certainly_be_ellipsized.pdf';

  List<Node<String>> data() => [
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
                Node<String>(id: 'c0', label: longLabel, type: NodeType.child),
              ],
            ),
          ],
        ),
      ];

  Future<void> pump(WidgetTester tester, {TooltipAnchor? anchor}) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            key: const Key('view'),
            width: viewWidth,
            height: 200,
            child: FolderView<String>(
              data: data(),
              mode: ViewMode.folder,
              expandedNodeIds: const {'f', 'p'},
              theme: FlutterFolderViewTheme<String>(
                lineTheme:
                    const FolderViewLineTheme(lineColor: Color(0xFF000000)),
                scrollbarTheme: const FolderViewScrollbarTheme(
                  thumbColor: Color(0xFF000000),
                  trackColor: Color(0xFF000000),
                ),
                childTheme: ChildNodeTheme<String>(
                  tooltipTheme: NodeTooltipTheme<String>(
                    useTooltip: true,
                    anchor: anchor ?? const NodeTooltipTheme<String>().anchor,
                    padding: EdgeInsets.zero,
                    tooltipBuilder: (_) =>
                        const SizedBox(key: Key('tip'), width: 100, height: 40),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ));
  }

  Future<void> hoverInsideView(WidgetTester tester, Rect label) async {
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();
    // A point the user can actually reach: inside the view's box.
    await gesture.moveTo(Offset(200, label.center.dy));
    await tester.pumpAndSettle();
  }

  testWidgets('the label outgrows the view without being truncated',
      (tester) async {
    await pump(tester);
    final label = tester.getRect(find.text(longLabel));
    final view = tester.getRect(find.byKey(const Key('view')));
    final para = tester.renderObject<RenderParagraph>(find.text(longLabel));

    expect(view.width, viewWidth);
    expect(label.right, greaterThan(view.right),
        reason: 'the label rect extends past the view it is drawn in');
    expect(label.center.dx, greaterThan(view.right),
        reason: 'and so does the centre a child-anchored tooltip aims at');

    // Ellipsis is not what makes the rect wide, and does not occur here.
    expect(para.didExceedMaxLines, isFalse);
    expect(
        label.width,
        moreOrLessEquals(para.getMaxIntrinsicWidth(double.infinity),
            epsilon: 0.5),
        reason: 'the label is laid out at full intrinsic width, not truncated');
  });

  testWidgets('the default anchor targets the visible part of the label',
      (tester) async {
    await pump(tester);
    final label = tester.getRect(find.text(longLabel));
    final view = tester.getRect(find.byKey(const Key('view')));
    await hoverInsideView(tester, label);

    final tip = tester.getRect(find.byKey(const Key('tip')));

    expect(view.contains(tip.center), isTrue,
        reason: 'the tooltip is drawn inside the FolderView, not over whatever '
            'the host app renders beside it');
    expect(tip.left, greaterThanOrEqualTo(view.left));
    expect(tip.right, lessThanOrEqualTo(view.right));
    expect(tip.center.dx, greaterThan(label.left),
        reason: 'and it is aimed within the part of the label on screen');
    expect(tip.center.dx, lessThan(view.right));
    expect(tip.center.dx, isNot(moreOrLessEquals(label.center.dx, epsilon: 1)),
        reason: 'the whole label rect, whose centre is off screen, is no '
            'longer the target');
  });

  testWidgets('TooltipAnchor.pointer keeps the tooltip inside the view',
      (tester) async {
    await pump(tester, anchor: TooltipAnchor.pointer);
    final label = tester.getRect(find.text(longLabel));
    final view = tester.getRect(find.byKey(const Key('view')));
    await hoverInsideView(tester, label);

    final tip = tester.getRect(find.byKey(const Key('tip')));
    expect(tip.center.dx, moreOrLessEquals(200, epsilon: 0.5),
        reason: 'anchored at the cursor, which is inside the view by '
            'construction');
    expect(view.contains(tip.center), isTrue);
  });
}
