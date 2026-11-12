import 'package:flutter/gestures.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

// An expand or collapse above the view during a wheel motion is added to that
// motion: the rows in view stay still, and the motion settles at its target
// plus the rows added or removed above, with the vertical scrollbar on the
// body.

const int _parents = 60;
const int _children = 20;
const Duration _frame = Duration(milliseconds: 16);

final FlutterFolderViewTheme<String> _theme = FlutterFolderViewTheme.light();
final double _itemExtent = _theme.rowHeight + _theme.rowSpacing;

/// 60 Parents of 20 Children each, every label unique.
final List<Node<String>> _nodes = [
  for (var p = 0; p < _parents; p++)
    Node<String>(
      id: 'p$p',
      label: 'p$p',
      type: NodeType.parent,
      children: [
        for (var c = 0; c < _children; c++)
          Node<String>(id: 'p$p-c$c', label: 'p$p-c$c', type: NodeType.child),
      ],
    ),
];

/// Every Parent expanded but those in [collapsed].
Set<String> _expandedBut(Set<String> collapsed) => {
  for (var p = 0; p < _parents; p++)
    if (!collapsed.contains('p$p')) 'p$p',
};

/// The view under the default `wheelMotion`, `WheelMotion.spring()`.
Widget _view(Set<String> expanded) => MaterialApp(
  home: Scaffold(
    body: Center(
      child: SizedBox(
        width: 400,
        height: 300,
        child: FolderView<String>(
          data: _nodes,
          mode: ViewMode.tree,
          expandedNodeIds: expanded,
          theme: _theme,
        ),
      ),
    ),
  ),
);

ScrollPosition _body(WidgetTester tester) =>
    tester.widget<ListView>(find.byType(ListView)).controller!.position;

ScrollPosition _verticalBar(WidgetTester tester) => tester
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

/// Sends one mouse-wheel notch of [dy] over the view, without pumping.
Future<void> _wheel(WidgetTester tester, double dy) async {
  final at = tester.getCenter(find.byType(FolderView<String>));
  final pointer = TestPointer(1, PointerDeviceKind.mouse);
  await tester.sendEventToBinding(pointer.hover(at));
  await tester.sendEventToBinding(pointer.scroll(Offset(0, dy)));
}

/// Pumps three frames of a running motion, and checks that it has moved from
/// [from] towards [target] without arriving.
Future<void> _midMotion(WidgetTester tester, double from, double target) async {
  for (var i = 0; i < 3; i++) {
    await tester.pump(_frame);
  }
  final pixels = _body(tester).pixels;
  expect(
    from < target
        ? pixels > from && pixels < target
        : pixels < from && pixels > target,
    isTrue,
    reason: 'the motion from $from to $target is under way at $pixels',
  );
}

/// The label of the row nearest the view's vertical centre, and its top.
(String, double) _rowAtCentre(WidgetTester tester) {
  final centreY = tester.getCenter(find.byType(ListView)).dy;
  String? label;
  var top = 0.0;
  var best = double.infinity;
  for (final element
      in find
          .descendant(of: find.byType(ListView), matching: find.byType(Text))
          .evaluate()) {
    final text = element.widget as Text;
    final y = tester.getTopLeft(find.byWidget(text)).dy;
    final distance = (y - centreY).abs();
    if (distance < best) {
      best = distance;
      label = text.data;
      top = y;
    }
  }
  return (label!, top);
}

/// Pumps [expanded] during the motion and checks that the rows in view stay
/// still in that frame.
Future<void> _changeKeepsRowsStill(
  WidgetTester tester,
  Set<String> expanded,
) async {
  final (label, top) = _rowAtCentre(tester);
  await tester.pumpWidget(_view(expanded));
  expect(tester.getTopLeft(find.text(label)).dy, top);
}

void _winTest(String description, WidgetTesterCallback body) => testWidgets(
  description,
  body,
  variant: TargetPlatformVariant.only(TargetPlatform.windows),
);

void main() {
  final delta = _children * _itemExtent;

  _winTest('a notch of 600 alone settles 600 further', (tester) async {
    await tester.pumpWidget(_view(_expandedBut({'p0'})));
    await tester.pumpAndSettle();
    _body(tester).jumpTo(20000);
    await tester.pumpAndSettle();

    await _wheel(tester, 600);
    await tester.pumpAndSettle();

    expect(_body(tester).pixels, 20600);
    expect(_verticalBar(tester).pixels, 20600);
  });

  _winTest('expanding a Parent above the view during a notch adds its rows to '
      'the notch', (tester) async {
    await tester.pumpWidget(_view(_expandedBut({'p0'})));
    await tester.pumpAndSettle();
    _body(tester).jumpTo(20000);
    await tester.pumpAndSettle();

    await _wheel(tester, 600);
    await _midMotion(tester, 20000, 20600);
    await _changeKeepsRowsStill(tester, _expandedBut({}));
    await tester.pumpAndSettle();

    expect(_body(tester).pixels, 20600 + delta);
    expect(_verticalBar(tester).pixels, _body(tester).pixels);
  });

  _winTest('collapsing a Parent above the view during a notch takes its rows '
      'off the notch', (tester) async {
    await tester.pumpWidget(_view(_expandedBut({})));
    await tester.pumpAndSettle();
    _body(tester).jumpTo(20000);
    await tester.pumpAndSettle();

    await _wheel(tester, 600);
    await _midMotion(tester, 20000, 20600);
    await _changeKeepsRowsStill(tester, _expandedBut({'p0'}));
    await tester.pumpAndSettle();

    expect(_body(tester).pixels, 20600 - delta);
    expect(_verticalBar(tester).pixels, _body(tester).pixels);
  });

  _winTest('expanding a Parent above the view during a notch to the end '
      'settles at the new end', (tester) async {
    await tester.pumpWidget(_view(_expandedBut({'p0'})));
    await tester.pumpAndSettle();
    final oldEnd = _body(tester).maxScrollExtent;
    _body(tester).jumpTo(oldEnd - 300);
    await tester.pumpAndSettle();

    await _wheel(tester, 600);
    await _midMotion(tester, oldEnd - 300, oldEnd);
    await _changeKeepsRowsStill(tester, _expandedBut({}));
    await tester.pumpAndSettle();

    expect(_body(tester).maxScrollExtent, oldEnd + delta);
    expect(_body(tester).pixels, oldEnd + delta);
    expect(_verticalBar(tester).pixels, _body(tester).pixels);
  });

  _winTest('expanding two Parents above the view at once during a notch adds '
      'their rows to the notch', (tester) async {
    await tester.pumpWidget(_view(_expandedBut({'p0', 'p1'})));
    await tester.pumpAndSettle();
    _body(tester).jumpTo(20000);
    await tester.pumpAndSettle();

    await _wheel(tester, 600);
    await _midMotion(tester, 20000, 20600);
    await _changeKeepsRowsStill(tester, _expandedBut({}));
    await tester.pumpAndSettle();

    expect(_body(tester).pixels, 20600 + 2 * delta);
    expect(_verticalBar(tester).pixels, _body(tester).pixels);
  });

  _winTest('expanding a Parent above the view during a drag lets the drag go '
      'on', (tester) async {
    await tester.pumpWidget(_view(_expandedBut({'p0'})));
    await tester.pumpAndSettle();
    _body(tester).jumpTo(20000);
    await tester.pumpAndSettle();

    final drag = await tester.startGesture(
      tester.getCenter(find.byType(ListView)),
      kind: PointerDeviceKind.touch,
    );
    Future<void> dragUp(int steps) async {
      for (var i = 0; i < steps; i++) {
        await drag.moveBy(const Offset(0, -10));
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    await dragUp(10);
    final pixels = _body(tester).pixels;
    expect(pixels, greaterThan(20000));
    await _changeKeepsRowsStill(tester, _expandedBut({}));
    await dragUp(10);
    await tester.pump(const Duration(milliseconds: 500));
    await drag.up();
    await tester.pumpAndSettle();

    expect(_body(tester).pixels, pixels + delta + 100);
    expect(_verticalBar(tester).pixels, _body(tester).pixels);
  });

  _winTest('expanding a Parent above the view during an upward notch adds its '
      'rows to the notch', (tester) async {
    await tester.pumpWidget(_view(_expandedBut({'p0'})));
    await tester.pumpAndSettle();
    _body(tester).jumpTo(20000);
    await tester.pumpAndSettle();

    await _wheel(tester, -600);
    await _midMotion(tester, 20000, 19400);
    await _changeKeepsRowsStill(tester, _expandedBut({}));
    await tester.pumpAndSettle();

    expect(_body(tester).pixels, 19400 + delta);
    expect(_verticalBar(tester).pixels, _body(tester).pixels);
  });

  _winTest('expanding a Parent above the view during a trackpad drag lets the '
      'drag go on', (tester) async {
    await tester.pumpWidget(_view(_expandedBut({'p0'})));
    await tester.pumpAndSettle();
    _body(tester).jumpTo(20000);
    await tester.pumpAndSettle();

    final at = tester.getCenter(find.byType(ListView));
    final pan = await tester.startGesture(at, kind: PointerDeviceKind.trackpad);
    var dy = 0.0;
    Future<void> panUp(int steps) async {
      for (var i = 0; i < steps; i++) {
        dy -= 10;
        await pan.panZoomUpdate(at, pan: Offset(0, dy));
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    await panUp(10);
    final pixels = _body(tester).pixels;
    expect(pixels, greaterThan(20000));
    await _changeKeepsRowsStill(tester, _expandedBut({}));
    await panUp(10);
    await tester.pump(const Duration(milliseconds: 500));
    await pan.panZoomEnd();
    await tester.pumpAndSettle();

    expect(_body(tester).pixels, pixels + delta + 100);
    expect(_verticalBar(tester).pixels, _body(tester).pixels);
  });

  _winTest('expanding a Parent above the view during a fling adds its rows to '
      'the fling', (tester) async {
    await tester.pumpWidget(_view(_expandedBut({'p0'})));
    await tester.pumpAndSettle();
    _body(tester).jumpTo(20000);
    await tester.pumpAndSettle();
    await tester.fling(find.byType(ListView), const Offset(0, -200), 2000);
    await tester.pumpAndSettle();
    final flung = _body(tester).pixels - 20000;
    expect(flung, greaterThan(200));

    _body(tester).jumpTo(20000);
    await tester.pumpAndSettle();
    await tester.fling(find.byType(ListView), const Offset(0, -200), 2000);
    await _midMotion(tester, 20000, 20000 + flung);
    await _changeKeepsRowsStill(tester, _expandedBut({}));
    await tester.pumpAndSettle();

    expect(_body(tester).pixels, closeTo(20000 + flung + delta, 0.01));
    expect(_verticalBar(tester).pixels, _body(tester).pixels);
  });

  _winTest('expanding a Parent above the view with no motion running moves '
      'the view by its rows at once', (tester) async {
    await tester.pumpWidget(_view(_expandedBut({'p0'})));
    await tester.pumpAndSettle();
    _body(tester).jumpTo(20000);
    await tester.pumpAndSettle();

    await _changeKeepsRowsStill(tester, _expandedBut({}));
    expect(_body(tester).pixels, 20000 + delta);
    await tester.pumpAndSettle();

    expect(_body(tester).pixels, 20000 + delta);
    expect(_verticalBar(tester).pixels, _body(tester).pixels);
  });

  _winTest('expanding a Parent above the view during a programmatic animation '
      'ends the animation where the rows stay', (tester) async {
    await tester.pumpWidget(_view(_expandedBut({'p0'})));
    await tester.pumpAndSettle();
    _body(tester).jumpTo(20000);
    await tester.pumpAndSettle();

    final animation = _body(tester).animateTo(
      20600,
      duration: const Duration(milliseconds: 400),
      curve: Curves.linear,
    );
    await _midMotion(tester, 20000, 20600);
    final pixels = _body(tester).pixels;
    await _changeKeepsRowsStill(tester, _expandedBut({}));
    await tester.pumpAndSettle();
    await animation;

    expect(_body(tester).pixels, pixels + delta);
    expect(_verticalBar(tester).pixels, _body(tester).pixels);
  });
}
