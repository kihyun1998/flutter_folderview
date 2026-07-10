import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_folderview/widgets/node_render_parts.dart';
import 'package:flutter_test/flutter_test.dart';

/// Where the tooltip is *painted*, not merely which value reached [JustTooltip].
///
/// The forwarding tests in `node_render_parts_test.dart` prove the theme's
/// `anchor` arrives at the widget. They cannot prove `just_tooltip` then honours
/// it, because the placement happens in an Overlay this package never touches.
///
/// Three constraints on the harness, learned by getting each of them wrong:
///
///  * **No `waitDuration`.** Hover intent is coalesced into a microtask before
///    it reaches the visibility scheduler; a short timer races that and can show
///    the tooltip before the pointer position is frozen, silently falling back
///    to the child rect.
///  * **One case per `testWidgets`.** `just_tooltip`'s tooltip registry is a
///    package-level singleton. Looping cases inside one test leaves the previous
///    tooltip registered and suppresses every later one.
///  * **Fixed-size tooltip, zero padding.** A text-sized tooltip near a screen
///    edge gets `screenMargin`-clamped, which shifts the very coordinate under
///    measurement.
///
/// Mirrors the harness in `just_tooltip`'s own `just_tooltip_anchor_test.dart`.
void main() {
  // Long enough to ellipsize: the label then spans the full row, so the label
  // rect's centre is nowhere near a pointer resting at the leading edge. That
  // divergence is the whole point of TooltipAnchor.pointer.
  const String longLabel =
      'a_very_long_report_filename_that_will_certainly_be_ellipsized_so_the_'
      'label_rect_spans_the_entire_row.pdf';

  Widget wideRowApp(TooltipAnchor anchor) {
    final node = Node<String>(id: 'n', label: longLabel, type: NodeType.child);
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            key: const Key('row'),
            width: 700,
            height: 60,
            child: NodeLabel<String>(
              iconBox: const SizedBox(width: 20, height: 20),
              label: longLabel,
              style: const TextStyle(fontSize: 14),
              tooltipTheme: NodeTooltipTheme<String>(
                useTooltip: true,
                anchor: anchor,
                padding: EdgeInsets.zero,
                tooltipBuilder: (context) =>
                    const SizedBox(key: Key('tip'), width: 100, height: 40),
              ),
              node: node,
            ),
          ),
        ),
      ),
    );
  }

  Future<TestGesture> mouse(WidgetTester tester) async {
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();
    return gesture;
  }

  /// Well inside the row, far from its centre.
  Offset nearLeadingEdge(WidgetTester tester) {
    final rect = tester.getRect(find.byKey(const Key('row')));
    return Offset(rect.left + 80, rect.center.dy);
  }

  testWidgets('TooltipAnchor.pointer paints the tooltip at the cursor',
      (tester) async {
    await tester.pumpWidget(wideRowApp(TooltipAnchor.pointer));
    final gesture = await mouse(tester);
    final pointer = nearLeadingEdge(tester);
    await gesture.moveTo(pointer);
    await tester.pumpAndSettle();

    final tip = tester.getRect(find.byKey(const Key('tip')));
    final row = tester.getRect(find.byKey(const Key('row')));

    expect(tip.center.dx, moreOrLessEquals(pointer.dx, epsilon: 0.5),
        reason: 'the tooltip is centred on the pointer');
    expect(tip.center.dx, isNot(moreOrLessEquals(row.center.dx, epsilon: 1)),
        reason: 'and emphatically not on the ellipsized label');
  });

  testWidgets('TooltipAnchor.child paints the tooltip at the glyphs\' centre',
      (tester) async {
    await tester.pumpWidget(wideRowApp(TooltipAnchor.child));
    final gesture = await mouse(tester);
    final pointer = nearLeadingEdge(tester);
    await gesture.moveTo(pointer);
    await tester.pumpAndSettle();

    final tip = tester.getRect(find.byKey(const Key('tip')));
    final row = tester.getRect(find.byKey(const Key('row')));
    final glyphs = tester.getRect(find.text(longLabel));

    expect(tip.center.dx, moreOrLessEquals(glyphs.center.dx, epsilon: 1),
        reason: 'the default anchor ignores the pointer and targets the '
            'glyphs — not the icon beside them, and not the row');
    expect(tip.center.dx, isNot(moreOrLessEquals(row.center.dx, epsilon: 1)),
        reason: 'the icon box is outside the target, so the glyphs\' centre '
            'sits right of the row\'s');
    expect(tip.center.dx, greaterThan(pointer.dx));
  });
}
