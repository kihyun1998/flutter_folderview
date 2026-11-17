import 'package:flutter/gestures.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_folderview/widgets/folder_view_horizontal_scrollbar.dart';
import 'package:flutter_folderview/widgets/folder_view_vertical_scrollbar.dart';
import 'package:flutter_test/flutter_test.dart';

/// Each bar's thumb is placed from the bar's own box, whatever MediaQuery
/// padding is above the view (#221).
void main() {
  // Enough rows to scroll vertically, and a label wide enough to scroll
  // horizontally, so both bars are drawn.
  List<Node<String>> data() => [
    Node<String>(
      id: 'f',
      label: 'folder',
      type: NodeType.folder,
      children: [
        for (var i = 0; i < 40; i++)
          Node<String>(
            id: 'p$i',
            label: i == 0 ? 'a very long label ' * 8 : 'parent $i',
            type: NodeType.parent,
          ),
      ],
    ),
  ];

  /// A padding on all four sides, each a different size.
  const padding = EdgeInsets.fromLTRB(20, 30, 40, 50);

  Future<void> pump(WidgetTester tester, EdgeInsets padding) async {
    final light = FlutterFolderViewTheme<String>.light();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(padding: padding),
              child: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: FolderView<String>(
                    data: data(),
                    mode: ViewMode.folder,
                    expandedNodeIds: const {'f'},
                    wheelMotion: null,
                    theme: light.copyWith(
                      scrollbarTheme: light.scrollbarTheme.copyWith(
                        thickness: 6,
                        trackWidth: 12,
                        radius: 1,
                        thumbVisibility: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The rect [bar]'s thumb is painted in, in the bar's own coordinates.
  Rect thumbRect(WidgetTester tester, Type bar) {
    final paint = find
        .descendant(of: find.byType(bar), matching: find.byType(CustomPaint))
        .evaluate()
        .map((element) => element.widget as CustomPaint)
        .where((paint) => paint.foregroundPainter is ScrollbarPainter);
    expect(paint, hasLength(1), reason: '$bar has one thumb');
    final size = tester
        .renderObject<RenderBox>(find.byWidget(paint.single))
        .size;
    final canvas = TestRecordingCanvas();
    paint.single.foregroundPainter!.paint(canvas, size);
    final rects = [
      for (final call in canvas.invocations)
        if (call.invocation.memberName == #drawRRect)
          (call.invocation.positionalArguments.first as RRect).outerRect,
    ];
    expect(rects, hasLength(1), reason: '$bar paints one thumb');
    return rects.single;
  }

  final platforms = TargetPlatformVariant(const {
    TargetPlatform.iOS,
    TargetPlatform.windows,
    TargetPlatform.android,
  });

  for (final bar in [
    FolderViewVerticalScrollbar,
    FolderViewHorizontalScrollbar,
  ]) {
    testWidgets('$bar paints its thumb where it does with no padding', (
      tester,
    ) async {
      await pump(tester, EdgeInsets.zero);
      final unpadded = thumbRect(tester, bar);
      await pump(tester, padding);
      expect(thumbRect(tester, bar), unpadded);
    }, variant: platforms);
  }

  ScrollPosition body(WidgetTester tester, Axis axis) {
    if (axis == Axis.vertical) {
      return tester
          .widget<ListView>(find.byType(ListView))
          .controller!
          .position;
    }
    return tester
        .widgetList<SingleChildScrollView>(
          find.byWidgetPredicate(
            (w) =>
                w is SingleChildScrollView &&
                w.scrollDirection == Axis.horizontal,
          ),
        )
        .where(
          (view) => find
              .ancestor(
                of: find.byWidget(view),
                matching: find.bySubtype<RawScrollbar>(),
              )
              .evaluate()
              .isEmpty,
        )
        .single
        .controller!
        .position;
  }

  /// The body's offset after a mouse drag of 50 px from the start of the
  /// [axis] thumb.
  Future<double> dragThumb(WidgetTester tester, Axis axis) async {
    final rect = tester.getRect(find.byType(FolderView<String>));
    final at = axis == Axis.vertical
        ? Offset(rect.right - 5, rect.top + 5)
        : Offset(rect.left + 5, rect.bottom - 5);
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(pointer.hover(at));
    await tester.pumpAndSettle();
    await tester.sendEventToBinding(pointer.down(at));
    await tester.pump();
    for (var moved = 10.0; moved <= 50; moved += 10) {
      await tester.sendEventToBinding(
        pointer.move(
          at + (axis == Axis.vertical ? Offset(0, moved) : Offset(moved, 0)),
        ),
      );
      await tester.pump();
    }
    await tester.sendEventToBinding(pointer.up());
    await tester.pumpAndSettle();
    return body(tester, axis).pixels;
  }

  for (final axis in Axis.values) {
    testWidgets('a $axis thumb drag moves the body as it does with no '
        'padding', (tester) async {
      await pump(tester, EdgeInsets.zero);
      final unpadded = await dragThumb(tester, axis);
      expect(unpadded, greaterThan(0));
      await tester.pumpWidget(const SizedBox());
      await pump(tester, padding);
      expect(body(tester, axis).pixels, 0);
      expect(await dragThumb(tester, axis), unpadded);
    }, variant: platforms);
  }
}
