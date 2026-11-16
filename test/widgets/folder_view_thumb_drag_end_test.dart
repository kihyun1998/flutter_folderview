import 'package:flutter/gestures.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

// A scrollbar thumb dragged past the end stops at the end and the drag goes
// on, with the body on the scrollbar, on desktop and on iOS alike. A fling on
// a scrollbar goes as far as the platform's own physics takes it.

const int _parents = 60;
const int _children = 20;

/// 60 Parents of 20 Children each. The first Parent's label is long enough to
/// scroll horizontally.
final List<Node<String>> _nodes = [
  for (var p = 0; p < _parents; p++)
    Node<String>(
      id: 'p$p',
      label: p == 0 ? 'L' * 40 : 'p$p',
      type: NodeType.parent,
      children: [
        for (var c = 0; c < _children; c++)
          Node<String>(id: 'p$p-c$c', label: 'p$p-c$c', type: NodeType.child),
      ],
    ),
];

Widget _view() => MaterialApp(
  home: Scaffold(
    body: Center(
      child: SizedBox(
        width: 400,
        height: 300,
        child: FolderView<String>(
          data: _nodes,
          mode: ViewMode.tree,
          expandedNodeIds: {for (var p = 0; p < _parents; p++) 'p$p'},
          scale: 1.5,
          wheelMotion: null,
          theme: FlutterFolderViewTheme<String>.light(),
        ),
      ),
    ),
  ),
);

ScrollPosition _bar(WidgetTester tester, Axis axis) => tester
    .widget<SingleChildScrollView>(
      find.descendant(
        of: find.bySubtype<RawScrollbar>(),
        matching: find.byWidgetPredicate(
          (w) => w is SingleChildScrollView && w.scrollDirection == axis,
        ),
      ),
    )
    .controller!
    .position;

/// The body along [axis]: the list's position, or the horizontal scroll view
/// that is not the scrollbar's.
ScrollPosition _body(WidgetTester tester, Axis axis) {
  if (axis == Axis.vertical) {
    return tester.widget<ListView>(find.byType(ListView)).controller!.position;
  }
  final bar = _bar(tester, Axis.horizontal);
  return tester
      .widgetList<SingleChildScrollView>(
        find.byWidgetPredicate(
          (w) =>
              w is SingleChildScrollView &&
              w.scrollDirection == Axis.horizontal,
        ),
      )
      .map((view) => view.controller!.position)
      .firstWhere((position) => position != bar);
}

String _platform(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(FolderView<String>))).platform.name;

/// Where a touch fling on the scrollbar's track ends, by platform, under the
/// platform's own physics. A platform with no entry flings to the end.
const Map<String, double> _verticalTrackFling = {
  'iOS': 20453.80,
  'android': 20191.90,
  'macOS': 20175.06,
  'windows': 20191.90,
};
const Map<String, double> _horizontalTrackFling = {
  'android': 291.90,
  'macOS': 275.06,
  'windows': 291.90,
};
const Map<String, double> _thumbFling = {
  'vertical': 6629.35,
  'horizontal': 292.14,
};

final _allPlatforms = TargetPlatformVariant({
  TargetPlatform.iOS,
  TargetPlatform.android,
  TargetPlatform.macOS,
  TargetPlatform.windows,
});

void main() {
  for (final axis in Axis.values) {
    testWidgets(
      'a $axis thumb drag past the end stops the scrollbar and the '
      'body at the end and lets the drag go on',
      (tester) async {
        await tester.pumpWidget(_view());
        await tester.pumpAndSettle();
        final rect = tester.getRect(find.byType(FolderView<String>));
        final at = axis == Axis.vertical
            ? Offset(rect.right - 3, rect.top + 5)
            : Offset(rect.left + 5, rect.bottom - 3);
        final pointer = TestPointer(1, PointerDeviceKind.mouse);
        await tester.sendEventToBinding(pointer.hover(at));
        await tester.pumpAndSettle();
        await tester.sendEventToBinding(pointer.down(at));
        await tester.pump();

        // Far enough along the track to pass the end by several steps.
        // Steps taken with the scrollbar already at the end.
        var atEnd = 0;
        for (var moved = 10.0; moved <= 450; moved += 10) {
          await tester.sendEventToBinding(
            pointer.move(
              at +
                  (axis == Axis.vertical ? Offset(0, moved) : Offset(moved, 0)),
            ),
          );
          await tester.pump();
          final bar = _bar(tester, axis);
          expect(bar.activity, isA<DragScrollActivity>(), reason: 'at $moved');
          expect(bar.pixels, lessThanOrEqualTo(bar.maxScrollExtent));
          expect(_body(tester, axis).pixels, bar.pixels, reason: 'at $moved');
          if (bar.pixels == bar.maxScrollExtent) atEnd++;
        }
        expect(atEnd, greaterThanOrEqualTo(5));
        final body = _body(tester, axis);
        expect(body.pixels, body.maxScrollExtent);

        await tester.sendEventToBinding(pointer.up());
        await tester.pumpAndSettle();
        expect(body.pixels, body.maxScrollExtent);
        expect(_bar(tester, axis).pixels, body.maxScrollExtent);
      },
      variant: TargetPlatformVariant({
        TargetPlatform.windows,
        TargetPlatform.iOS,
      }),
    );
  }

  for (final axis in Axis.values) {
    testWidgets('a touch fling on the $axis scrollbar goes as far as the '
        "platform's physics takes it", (tester) async {
      await tester.pumpWidget(_view());
      await tester.pumpAndSettle();
      final expected = (axis == Axis.vertical
          ? _verticalTrackFling
          : _horizontalTrackFling)[_platform(tester)];
      final bar = _bar(tester, axis);
      bar.jumpTo(axis == Axis.vertical ? 20000 : 100);
      await tester.pumpAndSettle();
      final rect = tester.getRect(find.byType(FolderView<String>));
      await tester.flingFrom(
        axis == Axis.vertical
            ? Offset(rect.right - 3, rect.bottom - 40)
            : Offset(rect.right - 60, rect.bottom - 3),
        axis == Axis.vertical ? const Offset(0, -60) : const Offset(-60, 0),
        800,
      );
      await tester.pumpAndSettle();
      expect(bar.pixels, closeTo(expected ?? bar.maxScrollExtent, 0.01));
      expect(_body(tester, axis).pixels, bar.pixels);
    }, variant: _allPlatforms);

    testWidgets('a $axis thumb flung on iOS goes on as far as the platform\'s '
        'physics takes it', (tester) async {
      await tester.pumpWidget(_view());
      await tester.pumpAndSettle();
      final rect = tester.getRect(find.byType(FolderView<String>));
      final at = axis == Axis.vertical
          ? Offset(rect.right - 3, rect.top + 5)
          : Offset(rect.left + 5, rect.bottom - 3);
      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(pointer.hover(at));
      await tester.pumpAndSettle();
      await tester.sendEventToBinding(
        pointer.down(at, timeStamp: Duration.zero),
      );
      await tester.pump();
      for (var i = 1; i <= 5; i++) {
        final step = 4.0 * i;
        await tester.sendEventToBinding(
          pointer.move(
            at + (axis == Axis.vertical ? Offset(0, step) : Offset(step, 0)),
            timeStamp: Duration(milliseconds: 8 * i),
          ),
        );
        await tester.pump();
      }
      final released = _bar(tester, axis).pixels;
      await tester.sendEventToBinding(
        pointer.up(timeStamp: const Duration(milliseconds: 48)),
      );
      await tester.pumpAndSettle();
      final bar = _bar(tester, axis);
      expect(bar.pixels, greaterThan(released));
      expect(bar.pixels, closeTo(_thumbFling[axis.name]!, 0.01));
      expect(_body(tester, axis).pixels, bar.pixels);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
  }
}
