import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

// Mouse-wheel scrolling of the public FolderView: a notch animates to its
// target, and the vertical scrollbar follows the list on every frame.

const Duration _frame = Duration(milliseconds: 16);

/// A Folder with 100 Parents, expanded, so the list scrolls vertically.
final List<Node<String>> _nodes = [
  Node<String>(
    id: 'f',
    label: 'folder',
    type: NodeType.folder,
    children: List.generate(
      100,
      (i) => Node<String>(id: 'p$i', label: 'p$i', type: NodeType.parent),
    ),
  ),
];

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            height: 300,
            child: FolderView<String>(
              data: _nodes,
              mode: ViewMode.folder,
              expandedNodeIds: const {'f'},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Sends one mouse-wheel notch of [dy] over the view, without pumping.
Future<void> _wheel(WidgetTester tester, double dy) async {
  final at = tester.getCenter(find.byType(FolderView<String>));
  final pointer = TestPointer(1, PointerDeviceKind.mouse);
  await tester.sendEventToBinding(pointer.hover(at));
  await tester.sendEventToBinding(pointer.scroll(Offset(0, dy)));
}

ScrollPosition _list(WidgetTester tester) =>
    tester.widget<ListView>(find.byType(ListView)).controller!.position;

/// The vertical scrollbar's own scroll view.
ScrollPosition _bar(WidgetTester tester) => tester
    .widget<SingleChildScrollView>(
      find.descendant(
        of: find.byType(Scrollbar),
        matching: find.byWidgetPredicate(
          (w) =>
              w is SingleChildScrollView && w.scrollDirection == Axis.vertical,
        ),
      ),
    )
    .controller!
    .position;

void main() {
  testWidgets('a notch animates to its target instead of jumping', (
    tester,
  ) async {
    await _pump(tester);
    expect(_list(tester).pixels, 0);

    await _wheel(tester, 120);
    await tester.pump();
    await tester.pump(_frame);
    final mid = _list(tester).pixels;
    expect(mid, greaterThan(0));
    expect(mid, lessThan(120));

    await tester.pumpAndSettle();
    expect(_list(tester).pixels, 120);
  });

  testWidgets('the vertical scrollbar follows the list on every frame', (
    tester,
  ) async {
    await _pump(tester);

    await _wheel(tester, 240);
    await tester.pump();
    var frames = 0;
    while (tester.binding.hasScheduledFrame) {
      await tester.pump(_frame);
      final list = _list(tester);
      final bar = _bar(tester);
      expect(
        bar.pixels,
        list.pixels.clamp(bar.minScrollExtent, bar.maxScrollExtent),
        reason: 'frame $frames',
      );
      frames++;
    }
    expect(frames, greaterThan(2));
    expect(_list(tester).pixels, 240);
  });

  testWidgets('a notch near the end stops exactly at the end', (tester) async {
    // macOS scrolls with BouncingScrollPhysics, which lets a position past its
    // end; only the wheel motion's own clamp stops it there.
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      await _pump(tester);
      final max = _list(tester).maxScrollExtent;
      _list(tester).jumpTo(max - 30);
      await tester.pump();

      await _wheel(tester, 120);
      await tester.pump();
      while (tester.binding.hasScheduledFrame) {
        await tester.pump(_frame);
        expect(_list(tester).pixels, lessThanOrEqualTo(max));
      }
      expect(_list(tester).pixels, max);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
