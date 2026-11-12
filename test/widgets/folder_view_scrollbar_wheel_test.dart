import 'package:flutter/gestures.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

// A mouse wheel turned over a scrollbar of the public FolderView moves the view
// the way the same wheel over the body does.

const Duration _frame = Duration(milliseconds: 16);
const WheelMotion _spring = WheelMotion.spring(
  duration: Duration(milliseconds: 400),
);

/// 500 Children under one Parent, one with a long label: taller and wider than
/// the 400×300 view, so both scrollbars exist.
final List<Node<String>> _nodes = [
  Node<String>(
    id: 'p',
    label: 'parent',
    type: NodeType.parent,
    children: [
      for (var i = 0; i < 500; i++)
        Node<String>(
          id: 'c$i',
          label: i == 0 ? 'x' * 300 : 'c$i',
          type: NodeType.child,
        ),
    ],
  ),
];

final GlobalKey _viewKey = GlobalKey();

Future<void> _pump(
  WidgetTester tester,
  WheelMotion? wheelMotion, {
  double rowSpacing = 0,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            height: 300,
            child: FolderView<String>(
              key: _viewKey,
              data: _nodes,
              mode: ViewMode.tree,
              expandedNodeIds: const {'p'},
              wheelMotion: wheelMotion,
              theme: FlutterFolderViewTheme<String>.light().copyWith(
                rowSpacing: rowSpacing,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Rect _view(WidgetTester tester) =>
    tester.getRect(find.byType(FolderView<String>));

Offset _overBody(WidgetTester tester) => _view(tester).center;

Offset _overVerticalBar(WidgetTester tester) =>
    Offset(_view(tester).right - 3, _view(tester).center.dy);

Offset _overHorizontalBar(WidgetTester tester) =>
    Offset(_view(tester).center.dx, _view(tester).bottom - 3);

/// Sends one wheel notch of [delta] at [at], without pumping.
Future<void> _wheel(
  WidgetTester tester,
  Offset at,
  Offset delta, {
  PointerDeviceKind kind = PointerDeviceKind.mouse,
}) async {
  final pointer = TestPointer(1, kind);
  if (kind == PointerDeviceKind.mouse) {
    await tester.sendEventToBinding(pointer.hover(at));
  } else {
    pointer.addPointer(location: at);
  }
  await tester.sendEventToBinding(pointer.scroll(delta));
}

ScrollPosition _body(WidgetTester tester) =>
    tester.widget<ListView>(find.byType(ListView)).controller!.position;

/// The scroll view inside the scrollbar of [axis].
ScrollPosition _bar(WidgetTester tester, Axis axis) => tester
    .widget<SingleChildScrollView>(
      find.descendant(
        of: find.byType(Scrollbar),
        matching: find.byWidgetPredicate(
          (w) => w is SingleChildScrollView && w.scrollDirection == axis,
        ),
      ),
    )
    .controller!
    .position;

void _winTest(String description, WidgetTesterCallback body) => testWidgets(
  description,
  body,
  variant: TargetPlatformVariant.only(TargetPlatform.windows),
);

/// Presses and releases the mouse at [at], leaving the track tap's animation
/// to the frames that follow.
Future<void> _trackClick(
  WidgetTester tester,
  TestPointer pointer,
  Offset at,
) async {
  await tester.sendEventToBinding(pointer.hover(at));
  await tester.pump(_frame);
  await tester.sendEventToBinding(pointer.down(at));
  await tester.pump(_frame);
  await tester.sendEventToBinding(pointer.up());
}

void main() {
  _winTest('a notch over the vertical scrollbar animates, with the bar on the '
      'body on every frame', (tester) async {
    await _pump(tester, _spring);

    await _wheel(tester, _overVerticalBar(tester), const Offset(0, 60));
    await tester.pump();
    expect(_body(tester).pixels, 0);

    final seen = <double>[];
    while (tester.binding.hasScheduledFrame) {
      await tester.pump(_frame);
      seen.add(_body(tester).pixels);
      expect(_bar(tester, Axis.vertical).pixels, _body(tester).pixels);
    }
    expect(seen.where((p) => p > 0 && p < 60), isNotEmpty);
    expect(_body(tester).pixels, 60);
  });

  _winTest('a sideways notch over the horizontal scrollbar animates', (
    tester,
  ) async {
    await _pump(tester, _spring);
    final rowStart = tester.getTopLeft(find.text('parent')).dx;

    await _wheel(tester, _overHorizontalBar(tester), const Offset(60, 0));
    await tester.pump();
    expect(_bar(tester, Axis.horizontal).pixels, 0);

    final seen = <double>[];
    while (tester.binding.hasScheduledFrame) {
      await tester.pump(_frame);
      seen.add(_bar(tester, Axis.horizontal).pixels);
    }
    expect(seen.where((p) => p > 0 && p < 60), isNotEmpty);
    expect(_bar(tester, Axis.horizontal).pixels, 60);
    expect(tester.getTopLeft(find.text('parent')).dx, rowStart - 60);
  });

  _winTest('wheelMotion null moves at once over a scrollbar', (tester) async {
    await _pump(tester, null);

    await _wheel(tester, _overVerticalBar(tester), const Offset(0, 60));
    await tester.pump();
    expect(_body(tester).pixels, 60);
    expect(_bar(tester, Axis.vertical).pixels, 60);
  });

  for (final (name, first, second) in [
    ('the body, then the scrollbar', _overBody, _overVerticalBar),
    ('the scrollbar, then the body', _overVerticalBar, _overBody),
    ('the scrollbar twice', _overVerticalBar, _overVerticalBar),
  ]) {
    _winTest('notches over $name add to one target', (tester) async {
      await _pump(tester, _spring);

      await _wheel(tester, first(tester), const Offset(0, 120));
      await tester.pump();
      await tester.pump(_frame);
      await tester.pump(_frame);
      final mid = _body(tester).pixels;
      expect(mid, greaterThan(0));
      expect(mid, lessThan(120));

      await _wheel(tester, second(tester), const Offset(0, 120));
      await tester.pumpAndSettle();
      expect(_body(tester).pixels, 240);
      expect(_bar(tester, Axis.vertical).pixels, 240);
    });
  }

  _winTest('changing wheelMotion keeps the offset and applies to the next '
      'notch over a scrollbar', (tester) async {
    await _pump(tester, _spring);
    await _wheel(tester, _overVerticalBar(tester), const Offset(0, 120));
    await tester.pumpAndSettle();
    expect(_body(tester).pixels, 120);

    await _pump(tester, null);
    expect(_body(tester).pixels, 120);

    await _wheel(tester, _overVerticalBar(tester), const Offset(0, 120));
    await tester.pump();
    expect(_body(tester).pixels, 240);
  });

  for (final (name, over) in [
    ('the scrollbar', _overVerticalBar),
    ('the body', _overBody),
  ]) {
    _winTest('frames running during a thumb drag leave the drag in charge, '
        'with the motion started over $name', (tester) async {
      await _pump(tester, _spring);
      final at = Offset(_overVerticalBar(tester).dx, _view(tester).top + 5);
      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(pointer.hover(at));
      await tester.pumpAndSettle();

      // A second device turns the wheel where [over] says, as the thumb is
      // pressed by the first.
      final wheel = TestPointer(2, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(wheel.hover(over(tester)));
      await tester.sendEventToBinding(wheel.scroll(const Offset(0, 600)));
      await tester.pump();
      await tester.pump(_frame);
      await tester.pump(_frame);
      expect(_body(tester).pixels, lessThan(600));

      await tester.sendEventToBinding(pointer.down(at));
      await tester.pump(_frame);
      await tester.sendEventToBinding(pointer.move(at + const Offset(0, 10)));
      await tester.pump(_frame);
      await tester.sendEventToBinding(pointer.move(at + const Offset(0, 20)));
      await tester.pump(_frame);
      final before = _body(tester).pixels;

      await tester.sendEventToBinding(pointer.move(at + const Offset(0, 30)));
      await tester.pump(_frame);
      final moved = _body(tester).pixels;
      expect(moved, greaterThan(before + 100));

      await tester.pump(const Duration(milliseconds: 500));
      expect(_body(tester).pixels, moved);
      await tester.sendEventToBinding(pointer.up());
      await tester.pumpAndSettle();
      expect(_body(tester).pixels, moved);
      expect(_bar(tester, Axis.vertical).pixels, moved);
    });
  }

  _winTest('a track tap during a motion takes over from the motion', (
    tester,
  ) async {
    await _pump(tester, _spring);
    final at = Offset(_overVerticalBar(tester).dx, _view(tester).bottom - 40);
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(pointer.hover(at));
    await tester.pumpAndSettle();

    await tester.sendEventToBinding(pointer.scroll(const Offset(0, 6000)));
    await tester.pump();
    await tester.pump(_frame);
    await tester.pump(_frame);
    final mid = _body(tester).pixels;
    expect(mid, lessThan(1000));

    await tester.sendEventToBinding(pointer.down(at));
    await tester.pump(_frame);
    await tester.sendEventToBinding(pointer.up());
    await tester.pumpAndSettle();

    final end = _body(tester).pixels;
    expect(end, greaterThan(mid));
    expect(end, lessThan(2000), reason: 'the wheel target is 6000');
    expect(_bar(tester, Axis.vertical).pixels, end);
  });

  _winTest('a notch during a track tap on the vertical scrollbar ends the '
      'animation and moves on from where the view stands', (tester) async {
    await _pump(tester, _spring);
    final at = Offset(_overVerticalBar(tester).dx, _view(tester).bottom - 40);
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(pointer.hover(at));
    await tester.pumpAndSettle();

    await _trackClick(tester, pointer, at);
    await tester.pump(_frame);
    await tester.pump(_frame);
    final bar = _bar(tester, Axis.vertical);
    expect(bar.isScrollingNotifier.value, isTrue);
    final mid = _body(tester).pixels;
    expect(mid, greaterThan(0));

    await tester.sendEventToBinding(pointer.scroll(const Offset(0, 60)));
    await tester.pumpAndSettle();

    expect(_body(tester).pixels, closeTo(mid + 60, 0.001));
    expect(bar.pixels, _body(tester).pixels);
  });

  _winTest('a notch during a track tap on the horizontal scrollbar ends the '
      'animation and moves on from where the view stands', (tester) async {
    await _pump(tester, _spring);
    final rowStart = tester.getTopLeft(find.text('parent')).dx;
    final at = Offset(_view(tester).right - 40, _overHorizontalBar(tester).dy);
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(pointer.hover(at));
    await tester.pumpAndSettle();

    await _trackClick(tester, pointer, at);
    await tester.pump(_frame);
    await tester.pump(_frame);
    final bar = _bar(tester, Axis.horizontal);
    expect(bar.isScrollingNotifier.value, isTrue);
    final mid = bar.pixels;
    expect(mid, greaterThan(0));

    await tester.sendEventToBinding(pointer.scroll(const Offset(60, 0)));
    await tester.pumpAndSettle();

    expect(bar.pixels, closeTo(mid + 60, 0.001));
    expect(
      tester.getTopLeft(find.text('parent')).dx,
      closeTo(rowStart - bar.pixels, 0.001),
    );
  });

  group('with rowSpacing, wheeled past the end over the scrollbar', () {
    Future<TestPointer> pastTheEnd(WidgetTester tester) async {
      await _pump(tester, _spring, rowSpacing: 8);
      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(pointer.hover(_overVerticalBar(tester)));
      await tester.pumpAndSettle();
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, 100000)));
      await tester.pumpAndSettle();
      return pointer;
    }

    Future<void> trackTapNearTheTop(
      WidgetTester tester,
      TestPointer pointer,
    ) async {
      await _trackClick(
        tester,
        pointer,
        Offset(_overVerticalBar(tester).dx, _view(tester).top + 40),
      );
      await tester.pumpAndSettle();
    }

    _winTest('the scrollbar ends where the body ends', (tester) async {
      await pastTheEnd(tester);
      final end = _body(tester).maxScrollExtent;
      expect(_body(tester).pixels, end);
      expect(_bar(tester, Axis.vertical).pixels, end);
    });

    _winTest('a track tap moves the body with the scrollbar', (tester) async {
      final pointer = await pastTheEnd(tester);
      await trackTapNearTheTop(tester, pointer);
      expect(_body(tester).pixels, lessThan(_body(tester).maxScrollExtent));
      expect(_bar(tester, Axis.vertical).pixels, _body(tester).pixels);
    });

    _winTest('a notch after that track tap moves both by the notch', (
      tester,
    ) async {
      final pointer = await pastTheEnd(tester);
      await trackTapNearTheTop(tester, pointer);
      final clicked = _body(tester).pixels;
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, 60)));
      await tester.pumpAndSettle();
      expect(_body(tester).pixels, clicked + 60);
      expect(_bar(tester, Axis.vertical).pixels, clicked + 60);
    });
  });

  group('with rowSpacing, the bar agrees with the list', () {
    final theme = FlutterFolderViewTheme<String>.light().copyWith(
      rowSpacing: 8,
    );
    List<Node<String>> rows(int count) => [
      for (var i = 0; i < count; i++)
        Node<String>(id: 'c$i', label: 'c$i', type: NodeType.parent),
    ];
    // One list across pumps: a new one would run the bulk anchor.
    final many = rows(40);
    final few = rows(10);
    double listHeight(int count) {
      final padding = theme.spacingTheme.contentPadding;
      return count * (theme.rowHeight + theme.rowSpacing) + padding.vertical;
    }

    FolderView<String> view(List<Node<String>> data) => FolderView<String>(
      data: data,
      mode: ViewMode.tree,
      expandedNodeIds: const {},
      wheelMotion: null,
      theme: theme,
    );

    _winTest('a list overflowing by less than rowSpacing has a vertical bar', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                height: listHeight(few.length) - 4,
                child: view(few),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(_body(tester).maxScrollExtent, 4);
      expect(_bar(tester, Axis.vertical).maxScrollExtent, 4);
    });

    _winTest('a bar moved after a wheel to the end moves the list', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(width: 400, height: 300, child: view(many)),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _wheel(tester, _overBody(tester), const Offset(0, 100000));
      await tester.pumpAndSettle();

      final bar = _bar(tester, Axis.vertical);
      final end = _body(tester).maxScrollExtent;
      expect(bar.pixels, end);

      bar.jumpTo(end - 100);
      await tester.pump();
      expect(_body(tester).pixels, end - 100);
    });

    _winTest('inside a page, a notch over the bar at the end, after a resize, '
        'reaches the page', (tester) async {
      final page = ScrollController();
      addTearDown(page.dispose);
      Widget framed(double height) => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            controller: page,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                  child: SizedBox(height: height, child: view(many)),
                ),
                const SizedBox(height: 2000),
              ],
            ),
          ),
        ),
      );
      await tester.pumpWidget(framed(300));
      await tester.pumpAndSettle();
      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(pointer.hover(_overVerticalBar(tester)));
      await tester.pumpAndSettle();
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, 100000)));
      await tester.pumpAndSettle();
      page.jumpTo(0);

      await tester.pumpWidget(framed(320));
      await tester.pumpAndSettle();
      final end = _body(tester).maxScrollExtent;
      expect(_body(tester).pixels, end);
      expect(_bar(tester, Axis.vertical).pixels, end);

      await tester.sendEventToBinding(pointer.scroll(const Offset(0, 40)));
      await tester.pumpAndSettle();
      expect(page.offset, 40);
      expect(_body(tester).pixels, end);
    });
  });

  for (final motion in <WheelMotion?>[null, _spring]) {
    _winTest('a notch after a bulk expand past the old end moves the scrollbar '
        'with the body, ${motion == null ? 'at once' : 'on every frame'}', (
      tester,
    ) async {
      final folders = [
        for (var f = 0; f < 120; f++)
          Node<String>(
            id: 'f$f',
            label: 'f$f',
            type: NodeType.parent,
            children: [
              for (var c = 0; c < 20; c++)
                Node<String>(id: 'f$f-$c', label: 'c$c', type: NodeType.child),
            ],
          ),
      ];
      Widget view(Iterable<int> expanded) => MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 300,
            child: FolderView<String>(
              data: folders,
              mode: ViewMode.tree,
              expandedNodeIds: {for (final f in expanded) 'f$f'},
              wheelMotion: motion,
            ),
          ),
        ),
      );
      await tester.pumpWidget(view([for (var f = 100; f < 120; f++) f]));
      await tester.pumpAndSettle();
      final oldEnd = _body(tester).maxScrollExtent;
      await _wheel(tester, _overBody(tester), const Offset(0, 19000));
      await tester.pumpAndSettle();
      await tester.pumpWidget(view([for (var f = 0; f < 120; f++) f]));
      await tester.pumpAndSettle();
      final expandedAt = _body(tester).pixels;
      expect(expandedAt, greaterThan(oldEnd));
      expect(_bar(tester, Axis.vertical).pixels, expandedAt);

      await _wheel(tester, _overBody(tester), const Offset(0, -120));
      while (tester.binding.hasScheduledFrame) {
        await tester.pump(_frame);
        expect(_bar(tester, Axis.vertical).pixels, _body(tester).pixels);
      }
      expect(_body(tester).pixels, expandedAt - 120);
    });
  }

  testWidgets(
    'after the body bounces past the top, the scrollbar moves the body',
    (tester) async {
      await _pump(tester, null);
      final at = _overBody(tester);
      final pan = TestPointer(1, PointerDeviceKind.trackpad);
      await tester.sendEventToBinding(pan.panZoomStart(at));
      await tester.pump(_frame);
      for (var dy = 10.0; dy <= 60; dy += 10) {
        await tester.sendEventToBinding(
          pan.panZoomUpdate(at, pan: Offset(0, dy)),
        );
        await tester.pump(_frame);
      }
      expect(_body(tester).pixels, lessThan(0));
      expect(_bar(tester, Axis.vertical).pixels, 0);
      await tester.sendEventToBinding(pan.panZoomEnd());
      await tester.pumpAndSettle();
      expect(_body(tester).pixels, 0);

      _bar(tester, Axis.vertical).jumpTo(100);
      await tester.pump();
      expect(_body(tester).pixels, 100);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
  );

  _winTest('the horizontal scrollbar keeps its offset when the vertical one '
      'leaves and comes back', (tester) async {
    final rows = [
      Node<String>(id: 'wide', label: 'w' * 300, type: NodeType.parent),
      for (var f = 0; f < 3; f++)
        Node<String>(
          id: 'f$f',
          label: 'f$f',
          type: NodeType.parent,
          children: [
            for (var c = 0; c < 20; c++)
              Node<String>(id: 'f$f-$c', label: 'c$c', type: NodeType.child),
          ],
        ),
    ];
    Widget view(Set<String> expanded) => MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 300,
          child: FolderView<String>(
            data: rows,
            mode: ViewMode.tree,
            expandedNodeIds: expanded,
            wheelMotion: null,
          ),
        ),
      ),
    );
    final verticalBar = find.descendant(
      of: find.byType(Scrollbar),
      matching: find.byWidgetPredicate(
        (w) => w is SingleChildScrollView && w.scrollDirection == Axis.vertical,
      ),
    );
    double rowsShift(double start) =>
        start - tester.getTopLeft(find.text('f0')).dx;

    await tester.pumpWidget(view({'f0', 'f1', 'f2'}));
    await tester.pumpAndSettle();
    final start = tester.getTopLeft(find.text('f0')).dx;
    _bar(tester, Axis.horizontal).jumpTo(200);
    await tester.pump();
    expect(rowsShift(start), 200);

    await tester.pumpWidget(view(const {}));
    await tester.pumpAndSettle();
    expect(verticalBar, findsNothing);
    expect(_bar(tester, Axis.horizontal).pixels, 200);
    expect(rowsShift(start), 200);

    await _wheel(tester, _overHorizontalBar(tester), const Offset(-60, 0));
    await tester.pumpAndSettle();
    expect(_bar(tester, Axis.horizontal).pixels, 140);
    expect(rowsShift(start), 140);

    await tester.pumpWidget(view({'f0', 'f1', 'f2'}));
    await tester.pumpAndSettle();
    expect(verticalBar, findsOneWidget);
    expect(_bar(tester, Axis.horizontal).pixels, 140);
    expect(rowsShift(start), 140);
  });

  _winTest('when the horizontal end shrinks below the offset, the rows follow '
      'the scrollbar to the new end', (tester) async {
    Widget view(String widest) => MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 300,
          child: FolderView<String>(
            data: [
              Node<String>(id: 'wide', label: widest, type: NodeType.parent),
              Node<String>(id: 'k', label: 'k', type: NodeType.parent),
            ],
            mode: ViewMode.tree,
            expandedNodeIds: const {},
            wheelMotion: null,
          ),
        ),
      ),
    );
    await tester.pumpWidget(view('w' * 300));
    await tester.pumpAndSettle();
    final start = tester.getTopLeft(find.text('k')).dx;
    final bar = _bar(tester, Axis.horizontal);
    final oldEnd = bar.maxScrollExtent;
    bar.jumpTo(oldEnd);
    await tester.pump();

    await tester.pumpWidget(view('y' * 70));
    await tester.pumpAndSettle();

    final newEnd = _bar(tester, Axis.horizontal).maxScrollExtent;
    expect(newEnd, lessThan(oldEnd));
    expect(_bar(tester, Axis.horizontal).pixels, newEnd);
    expect(start - tester.getTopLeft(find.text('k')).dx, newEnd);
  });

  _winTest('a bulk expand from the end leaves the scrollbar on the body', (
    tester,
  ) async {
    List<Node<String>> folders() => [
      for (var f = 0; f < 100; f++)
        Node<String>(
          id: 'f$f',
          label: 'f$f',
          type: NodeType.parent,
          children: [
            for (var c = 0; c < 20; c++)
              Node<String>(id: 'f$f-$c', label: 'c$c', type: NodeType.child),
          ],
        ),
    ];
    Widget view(Set<String> expanded) => MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 300,
          child: FolderView<String>(
            data: folders(),
            mode: ViewMode.tree,
            expandedNodeIds: expanded,
            wheelMotion: null,
          ),
        ),
      ),
    );
    await tester.pumpWidget(view({'f0', 'f1', 'f2'}));
    await tester.pumpAndSettle();
    await _wheel(tester, _overBody(tester), const Offset(0, 100000));
    await tester.pumpAndSettle();
    final before = _body(tester).pixels;

    await tester.pumpWidget(view({for (var f = 0; f < 100; f++) 'f$f'}));
    await tester.pumpAndSettle();

    expect(_body(tester).pixels, greaterThan(before));
    expect(_bar(tester, Axis.vertical).pixels, _body(tester).pixels);
  });

  for (final fadedIn in [false, true]) {
    _winTest('Shift with a vertical notch over the horizontal scrollbar '
        'scrolls sideways, ${fadedIn ? 'with' : 'before'} the thumb faded in', (
      tester,
    ) async {
      await _pump(tester, null);
      final rowStart = tester.getTopLeft(find.text('parent')).dx;
      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(
        pointer.hover(_overHorizontalBar(tester)),
      );
      if (fadedIn) await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, 60)));
      await tester.pumpAndSettle();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);

      expect(_bar(tester, Axis.horizontal).pixels, 60);
      expect(tester.getTopLeft(find.text('parent')).dx, rowStart - 60);
      expect(_body(tester).pixels, 0);
    });
  }

  for (final (name, shift, kind) in [
    ('without Shift', false, PointerDeviceKind.mouse),
    ('from a trackpad, with Shift', true, PointerDeviceKind.trackpad),
  ]) {
    _winTest('a vertical notch $name over a faded-in horizontal scrollbar '
        'moves nothing', (tester) async {
      await _pump(tester, null);
      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(
        pointer.hover(_overHorizontalBar(tester)),
      );
      await tester.pumpAndSettle();

      if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      final signal = TestPointer(2, kind);
      if (kind == PointerDeviceKind.mouse) {
        await tester.sendEventToBinding(
          signal.hover(_overHorizontalBar(tester)),
        );
      } else {
        signal.addPointer(location: _overHorizontalBar(tester));
      }
      await tester.sendEventToBinding(signal.scroll(const Offset(0, 60)));
      await tester.pumpAndSettle();
      if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);

      expect(_bar(tester, Axis.horizontal).pixels, 0);
      expect(_body(tester).pixels, 0);
    });
  }

  _winTest('Shift with a vertical notch during a horizontal thumb drag leaves '
      'the drag in charge', (tester) async {
    await _pump(tester, null);
    final thumb = Offset(
      _view(tester).left + 10,
      _overHorizontalBar(tester).dy,
    );
    final drag = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(drag.hover(thumb));
    await tester.pumpAndSettle();
    await tester.sendEventToBinding(drag.down(thumb));
    await tester.pump(_frame);
    await tester.sendEventToBinding(drag.move(thumb + const Offset(20, 0)));
    await tester.pump(_frame);
    final bar = _bar(tester, Axis.horizontal);
    final dragged = bar.pixels;
    expect(dragged, greaterThan(0));

    final wheel = TestPointer(2, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(wheel.hover(_overHorizontalBar(tester)));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendEventToBinding(wheel.scroll(const Offset(0, 60)));
    await tester.pump(_frame);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    expect(bar.pixels, dragged);

    await tester.sendEventToBinding(drag.move(thumb + const Offset(40, 0)));
    await tester.pump(_frame);
    expect(bar.pixels, closeTo(2 * dragged, 0.5));
    await tester.sendEventToBinding(drag.up());
    await tester.pumpAndSettle();
  });

  for (final fadedIn in [false, true]) {
    _winTest('right to left, Shift with a vertical notch over the horizontal '
        'scrollbar moves it as Flutter does, ${fadedIn ? 'with' : 'before'} '
        'the thumb faded in', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 400,
                  height: 300,
                  child: FolderView<String>(
                    data: _nodes,
                    mode: ViewMode.tree,
                    expandedNodeIds: const {'p'},
                    wheelMotion: null,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final bar = _bar(tester, Axis.horizontal);
      bar.jumpTo(300);
      await tester.pump();
      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(
        pointer.hover(_overHorizontalBar(tester)),
      );
      if (fadedIn) await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, 60)));
      await tester.pumpAndSettle();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);

      expect(bar.pixels, 240);
    });
  }

  _winTest('Shift with a vertical notch over the horizontal scrollbar at its '
      'end reaches an enclosing horizontal page', (tester) async {
    final page = ScrollController();
    addTearDown(page.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            controller: page,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: 400,
                  height: 300,
                  child: FolderView<String>(
                    data: _nodes,
                    mode: ViewMode.tree,
                    expandedNodeIds: const {'p'},
                    wheelMotion: null,
                  ),
                ),
                const SizedBox(width: 2000),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final bar = _bar(tester, Axis.horizontal);
    bar.jumpTo(bar.maxScrollExtent);
    await tester.pump();
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(pointer.hover(_overHorizontalBar(tester)));
    await tester.pumpAndSettle();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendEventToBinding(pointer.scroll(const Offset(0, 60)));
    await tester.pumpAndSettle();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);

    expect(page.offset, 60);
    expect(bar.pixels, bar.maxScrollExtent);
  });

  _winTest('Shift with a vertical notch over a faded-in horizontal scrollbar '
      'animates with wheelMotion', (tester) async {
    await _pump(tester, _spring);
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(pointer.hover(_overHorizontalBar(tester)));
    await tester.pumpAndSettle();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendEventToBinding(pointer.scroll(const Offset(0, 60)));
    await tester.pump();
    await tester.pump(_frame);
    await tester.pump(_frame);
    final mid = _bar(tester, Axis.horizontal).pixels;
    await tester.pumpAndSettle();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);

    expect(mid, greaterThan(0));
    expect(mid, lessThan(60));
    expect(_bar(tester, Axis.horizontal).pixels, 60);
  });

  _winTest('a notch over a scrollbar that has faded in animates', (
    tester,
  ) async {
    await _pump(tester, _spring);
    final at = _overVerticalBar(tester);
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(pointer.hover(at));
    await tester.pumpAndSettle();

    await tester.sendEventToBinding(pointer.scroll(const Offset(0, 60)));
    await tester.pump();
    expect(_body(tester).pixels, 0);
    await tester.pump(_frame);
    await tester.pump(_frame);
    final mid = _body(tester).pixels;
    expect(mid, greaterThan(0));
    expect(mid, lessThan(60));

    await tester.pumpAndSettle();
    expect(_body(tester).pixels, 60);
    expect(_bar(tester, Axis.vertical).pixels, 60);
  });

  _winTest('a wheel event that is not from a mouse moves at once over a '
      'scrollbar, as it does over the body', (tester) async {
    for (final at in [_overBody, _overVerticalBar]) {
      await _pump(tester, _spring);
      final start = _body(tester).pixels;

      await _wheel(
        tester,
        at(tester),
        const Offset(0, 60),
        kind: PointerDeviceKind.trackpad,
      );
      await tester.pump();
      expect(_body(tester).pixels, start + 60);
    }
  });
}
