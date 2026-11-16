import 'package:flutter/gestures.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

// A Scale change during a scrollbar thumb drag keeps what is in view still and
// lets the drag go on, on either axis, with the body on the scrollbar.

const int _parents = 60;
const int _children = 20;
const double _baseExtent = 40;

/// 60 Parents of 20 Children each, every label unique. The first Parent's
/// label is [firstLabel] when given, to widen the content.
List<Node<String>> _nodes({String? firstLabel}) => [
  for (var p = 0; p < _parents; p++)
    Node<String>(
      id: 'p$p',
      label: p == 0 && firstLabel != null ? firstLabel : 'p$p',
      type: NodeType.parent,
      children: [
        for (var c = 0; c < _children; c++)
          Node<String>(id: 'p$p-c$c', label: 'p$p-c$c', type: NodeType.child),
      ],
    ),
];

final List<Node<String>> _narrow = _nodes();

/// Wide enough to scroll horizontally, and below the 3× ceiling at Scale 1.0
/// and 1.5, so a Scale change moves the horizontal offset.
final String _wideLabel = 'L' * 40;
final List<Node<String>> _wide = _nodes(firstLabel: _wideLabel);

/// Every Parent expanded but those in [collapsed].
Set<String> _expandedBut(Set<String> collapsed) => {
  for (var p = 0; p < _parents; p++)
    if (!collapsed.contains('p$p')) 'p$p',
};

Widget _view(
  double scale, {
  List<Node<String>>? data,
  Set<String> collapsed = const {},
  double width = 400,
  double height = 300,
}) => MaterialApp(
  home: Scaffold(
    body: Center(
      child: SizedBox(
        width: width,
        height: height,
        child: FolderView<String>(
          data: data ?? _narrow,
          mode: ViewMode.tree,
          expandedNodeIds: _expandedBut(collapsed),
          scale: scale,
          wheelMotion: null,
          theme: FlutterFolderViewTheme<String>.light(),
        ),
      ),
    ),
  ),
);

ScrollPosition _verticalBody(WidgetTester tester) =>
    tester.widget<ListView>(find.byType(ListView)).controller!.position;

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

/// The horizontal body: the horizontal scroll view that is not the scrollbar's.
ScrollPosition _horizontalBody(WidgetTester tester) {
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

ScrollPosition _body(WidgetTester tester, Axis axis) =>
    axis == Axis.vertical ? _verticalBody(tester) : _horizontalBody(tester);

double _listTop(WidgetTester tester) =>
    tester.getTopLeft(find.byType(ListView)).dy;

/// The label of the row nearest the view's vertical centre, and its top from
/// the view's top.
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
  return (label!, top - _listTop(tester));
}

/// A mouse drag on a scrollbar's thumb, pressed at the start of its track and
/// moved along it in steps of 10 with a frame after each.
class _ThumbDrag {
  _ThumbDrag._(this._tester, this._axis, this._at);

  final WidgetTester _tester;
  final Axis _axis;
  final Offset _at;
  final TestPointer _pointer = TestPointer(1, PointerDeviceKind.mouse);
  double _moved = 0;

  /// Presses [along] further than the start of the track plus 5.
  static Future<_ThumbDrag> start(
    WidgetTester tester,
    Axis axis, {
    double along = 0,
  }) async {
    final rect = tester.getRect(find.byType(FolderView<String>));
    final drag = _ThumbDrag._(
      tester,
      axis,
      axis == Axis.vertical
          ? Offset(rect.right - 3, rect.top + 5 + along)
          : Offset(rect.left + 5 + along, rect.bottom - 3),
    );
    await tester.sendEventToBinding(drag._pointer.hover(drag._at));
    await tester.pumpAndSettle();
    await tester.sendEventToBinding(drag._pointer.down(drag._at));
    await tester.pump();
    return drag;
  }

  Future<void> along(int steps) async {
    for (var i = 0; i < steps; i++) {
      _moved += 10;
      final step = _axis == Axis.vertical
          ? Offset(0, _moved)
          : Offset(_moved, 0);
      await _tester.sendEventToBinding(_pointer.move(_at + step));
      await _tester.pump();
    }
  }

  Future<void> release() async {
    await _tester.sendEventToBinding(_pointer.up());
    await _tester.pumpAndSettle();
  }
}

/// Where a thumb drag of [steps] along [axis] moves the view from the start,
/// at [scale] with no change during the drag.
Future<double> _thumbDragAlone(
  WidgetTester tester,
  Axis axis,
  double scale,
  int steps, {
  List<Node<String>>? data,
}) async {
  await tester.pumpWidget(_view(scale, data: data));
  await tester.pumpAndSettle();
  final drag = await _ThumbDrag.start(tester, axis);
  await drag.along(steps);
  final pixels = _body(tester, axis).pixels;
  await drag.release();
  _body(tester, axis).jumpTo(0);
  await tester.pumpAndSettle();
  return pixels;
}

/// Checks that the thumb drag along [axis] is still running, with the body on
/// the scrollbar.
void _thumbDragRuns(WidgetTester tester, Axis axis) {
  expect(_bar(tester, axis).activity, isA<DragScrollActivity>());
  expect(_body(tester, axis).pixels, _bar(tester, axis).pixels);
}

void _winTest(String description, WidgetTesterCallback body) => testWidgets(
  description,
  body,
  variant: TargetPlatformVariant.only(TargetPlatform.windows),
);

/// A test run on Windows and on iOS, where a scrollbar thumb drag could pass
/// the end if the scrollbar's physics allowed it.
void _winAndIosTest(String description, WidgetTesterCallback body) =>
    testWidgets(
      description,
      body,
      variant: TargetPlatformVariant({
        TargetPlatform.windows,
        TargetPlatform.iOS,
      }),
    );

void main() {
  test('the theme has no top padding and a 40 px row', () {
    final theme = FlutterFolderViewTheme<String>.light();
    expect(theme.rowHeight + theme.rowSpacing, _baseExtent);
    expect(theme.spacingTheme.contentPadding.top, 0);
  });

  // A thumb drag sets the offset from where the pointer is on the track,
  // mapped onto the content as it is now, so after the change the drag goes
  // on to the place the pointer stands for in the new Scale.

  for (final (from, to) in [(1.0, 1.5), (1.5, 1.0)]) {
    _winTest('a Scale change $from → $to during a vertical thumb drag keeps '
        'the rows in view still and lets the drag go on', (tester) async {
      final expected = await _thumbDragAlone(tester, Axis.vertical, to, 6);

      await tester.pumpWidget(_view(from));
      await tester.pumpAndSettle();
      final drag = await _ThumbDrag.start(tester, Axis.vertical);
      await drag.along(3);
      final pixels = _verticalBody(tester).pixels;
      expect(pixels, greaterThan(0));
      _thumbDragRuns(tester, Axis.vertical);
      final (label, inset) = _rowAtCentre(tester);

      await tester.pumpWidget(_view(to));
      await tester.pump();
      expect(
        _verticalBody(tester).pixels,
        moreOrLessEquals(pixels / from * to),
      );
      expect(
        tester.getTopLeft(find.text(label)).dy - _listTop(tester),
        moreOrLessEquals(inset / from * to),
      );
      _thumbDragRuns(tester, Axis.vertical);

      await drag.along(3);
      _thumbDragRuns(tester, Axis.vertical);
      expect(_verticalBody(tester).pixels, moreOrLessEquals(expected));
      await drag.release();

      expect(_verticalBody(tester).pixels, moreOrLessEquals(expected));
      expect(_bar(tester, Axis.vertical).pixels, _verticalBody(tester).pixels);
    });
  }

  _winTest('a Scale change with a Parent expanded above the view during a '
      'vertical thumb drag keeps the rows in view still and lets the drag go '
      'on', (tester) async {
    final expected = await _thumbDragAlone(tester, Axis.vertical, 1.5, 6);

    await tester.pumpWidget(_view(1.0, collapsed: {'p0'}));
    await tester.pumpAndSettle();
    final drag = await _ThumbDrag.start(tester, Axis.vertical);
    await drag.along(3);
    final pixels = _verticalBody(tester).pixels;
    _thumbDragRuns(tester, Axis.vertical);
    final (label, inset) = _rowAtCentre(tester);

    await tester.pumpWidget(_view(1.5));
    await tester.pump();
    expect(
      _verticalBody(tester).pixels,
      moreOrLessEquals((pixels + _children * _baseExtent) * 1.5),
    );
    expect(
      tester.getTopLeft(find.text(label)).dy - _listTop(tester),
      moreOrLessEquals(inset * 1.5),
    );
    _thumbDragRuns(tester, Axis.vertical);

    await drag.along(3);
    _thumbDragRuns(tester, Axis.vertical);
    expect(_verticalBody(tester).pixels, moreOrLessEquals(expected));
    await drag.release();
  });

  for (final (from, to) in [(1.0, 1.5), (1.5, 1.0)]) {
    _winTest('a Scale change $from → $to during a horizontal thumb drag maps '
        'the offset and lets the drag go on', (tester) async {
      final expected = await _thumbDragAlone(
        tester,
        Axis.horizontal,
        to,
        6,
        data: _wide,
      );

      await tester.pumpWidget(_view(from, data: _wide));
      await tester.pumpAndSettle();
      final oldWidth =
          _horizontalBody(tester).maxScrollExtent +
          _horizontalBody(tester).viewportDimension;
      final drag = await _ThumbDrag.start(tester, Axis.horizontal);
      await drag.along(3);
      final pixels = _horizontalBody(tester).pixels;
      expect(pixels, greaterThan(0));
      _thumbDragRuns(tester, Axis.horizontal);
      final left = tester.getTopLeft(find.text(_wideLabel)).dx;

      await tester.pumpWidget(_view(to, data: _wide));
      await tester.pump();
      final body = _horizontalBody(tester);
      final newWidth = body.maxScrollExtent + body.viewportDimension;
      expect(newWidth, isNot(moreOrLessEquals(oldWidth)));
      final mapped = pixels / oldWidth * newWidth;
      expect(mapped, lessThan(body.maxScrollExtent));
      expect(body.pixels, moreOrLessEquals(mapped));
      // The rows are drawn at the mapped offset.
      final unscrolled = left + pixels;
      final listLeft = tester.getTopLeft(find.byType(ListView)).dx;
      expect(
        tester.getTopLeft(find.text(_wideLabel)).dx,
        moreOrLessEquals(
          listLeft + (unscrolled - listLeft) / from * to - mapped,
        ),
      );
      _thumbDragRuns(tester, Axis.horizontal);

      await drag.along(3);
      _thumbDragRuns(tester, Axis.horizontal);
      expect(_horizontalBody(tester).pixels, moreOrLessEquals(expected));
      await drag.release();

      expect(_horizontalBody(tester).pixels, moreOrLessEquals(expected));
      expect(
        _bar(tester, Axis.horizontal).pixels,
        _horizontalBody(tester).pixels,
      );
    });
  }

  _winAndIosTest(
    'a Scale change 1.5 → 1.0 during a horizontal thumb drag at the end '
    'puts the view at the new end and lets the drag go on',
    (tester) async {
      await tester.pumpWidget(_view(1.5, data: _wide));
      await tester.pumpAndSettle();
      final drag = await _ThumbDrag.start(tester, Axis.horizontal);
      await drag.along(40);
      final oldEnd = _horizontalBody(tester).maxScrollExtent;
      expect(_horizontalBody(tester).pixels, oldEnd);
      _thumbDragRuns(tester, Axis.horizontal);

      await tester.pumpWidget(_view(1.0, data: _wide));
      await tester.pump();
      final body = _horizontalBody(tester);
      expect(body.maxScrollExtent, lessThan(oldEnd));
      expect(body.pixels, body.maxScrollExtent);
      _thumbDragRuns(tester, Axis.horizontal);

      await drag.along(3);
      _thumbDragRuns(tester, Axis.horizontal);
      expect(_horizontalBody(tester).pixels, body.maxScrollExtent);
      await drag.release();
    },
  );

  _winAndIosTest(
    'a Scale change 1.0 → 1.5 during a horizontal thumb drag at the end '
    'maps the offset past the old end and lets the drag go on',
    (tester) async {
      await tester.pumpWidget(_view(1.0, data: _wide));
      await tester.pumpAndSettle();
      final drag = await _ThumbDrag.start(tester, Axis.horizontal);
      await drag.along(40);
      final old = _horizontalBody(tester);
      final oldEnd = old.maxScrollExtent;
      final oldWidth = oldEnd + old.viewportDimension;
      expect(old.pixels, oldEnd);
      _thumbDragRuns(tester, Axis.horizontal);

      await tester.pumpWidget(_view(1.5, data: _wide));
      await tester.pump();
      final body = _horizontalBody(tester);
      final newWidth = body.maxScrollExtent + body.viewportDimension;
      final mapped = oldEnd / oldWidth * newWidth;
      expect(mapped, greaterThan(oldEnd));
      expect(mapped, lessThan(body.maxScrollExtent));
      expect(body.pixels, moreOrLessEquals(mapped));
      _thumbDragRuns(tester, Axis.horizontal);
      await drag.release();
    },
  );

  for (final height in [250.0, 350.0]) {
    _winAndIosTest(
      'a Scale change 1.5 → 1.0 and a view height of $height in one '
      'update during a vertical thumb drag at the end put the view at the '
      'new end and let the drag go on',
      (tester) async {
        await tester.pumpWidget(_view(1.5));
        await tester.pumpAndSettle();
        final drag = await _ThumbDrag.start(tester, Axis.vertical);
        await drag.along(30);
        expect(
          _verticalBody(tester).pixels,
          _verticalBody(tester).maxScrollExtent,
        );
        _thumbDragRuns(tester, Axis.vertical);

        await tester.pumpWidget(_view(1.0, height: height));
        await tester.pump();
        _thumbDragRuns(tester, Axis.vertical);
        final body = _verticalBody(tester);
        expect(body.pixels, body.maxScrollExtent);

        await tester.pump(const Duration(milliseconds: 500));
        await drag.along(3);
        _thumbDragRuns(tester, Axis.vertical);
        expect(body.pixels, body.maxScrollExtent);
        await drag.release();
      },
    );
  }

  for (final width in [380.0, 420.0]) {
    _winAndIosTest('a Scale change 1.5 → 1.0 and a view width of $width in one '
        'update during a horizontal thumb drag at the end put the view at the '
        'new end and let the drag go on', (tester) async {
      await tester.pumpWidget(_view(1.5, data: _wide));
      await tester.pumpAndSettle();
      final drag = await _ThumbDrag.start(tester, Axis.horizontal);
      await drag.along(40);
      expect(
        _horizontalBody(tester).pixels,
        _horizontalBody(tester).maxScrollExtent,
      );
      _thumbDragRuns(tester, Axis.horizontal);

      await tester.pumpWidget(_view(1.0, data: _wide, width: width));
      await tester.pump();
      _thumbDragRuns(tester, Axis.horizontal);
      final body = _horizontalBody(tester);
      expect(body.pixels, body.maxScrollExtent);

      await tester.pump(const Duration(milliseconds: 500));
      await drag.along(3);
      _thumbDragRuns(tester, Axis.horizontal);
      expect(body.pixels, body.maxScrollExtent);
      await drag.release();
    });
  }

  _winTest('a Scale change while the vertical thumb is pressed and not moved '
      'keeps the rows in view still and lets the drag go on', (tester) async {
    await tester.pumpWidget(_view(1.0));
    await tester.pumpAndSettle();
    final drag = await _ThumbDrag.start(tester, Axis.vertical);
    await drag.along(3);
    await drag.release();
    final pixels = _verticalBody(tester).pixels;
    expect(pixels, greaterThan(0));

    // Pressed again where the first drag left the thumb.
    final pressed = await _ThumbDrag.start(tester, Axis.vertical, along: 30);
    _thumbDragRuns(tester, Axis.vertical);
    await tester.pumpWidget(_view(1.5));
    await tester.pump();
    expect(_verticalBody(tester).pixels, moreOrLessEquals(pixels * 1.5));
    _thumbDragRuns(tester, Axis.vertical);

    await pressed.along(1);
    _thumbDragRuns(tester, Axis.vertical);
    expect(_verticalBody(tester).pixels, greaterThan(pixels * 1.5));
    await pressed.release();
  });

  // The axis that is not dragged still moves with the Scale change, after the
  // frame.

  _winTest('a Scale change during a vertical thumb drag also maps the '
      'horizontal offset', (tester) async {
    await tester.pumpWidget(_view(1.0, data: _wide));
    await tester.pumpAndSettle();
    _horizontalBody(tester).jumpTo(40);
    await tester.pumpAndSettle();
    final oldWidth =
        _horizontalBody(tester).maxScrollExtent +
        _horizontalBody(tester).viewportDimension;
    final drag = await _ThumbDrag.start(tester, Axis.vertical);
    await drag.along(3);
    final pixels = _verticalBody(tester).pixels;
    _thumbDragRuns(tester, Axis.vertical);

    await tester.pumpWidget(_view(1.5, data: _wide));
    await tester.pump();
    final h = _horizontalBody(tester);
    final newWidth = h.maxScrollExtent + h.viewportDimension;
    expect(h.pixels, moreOrLessEquals(40 / oldWidth * newWidth));
    expect(_bar(tester, Axis.horizontal).pixels, h.pixels);
    expect(_verticalBody(tester).pixels, moreOrLessEquals(pixels * 1.5));
    _thumbDragRuns(tester, Axis.vertical);

    await drag.along(3);
    _thumbDragRuns(tester, Axis.vertical);
    await drag.release();
  });

  _winTest('a Scale change during a horizontal thumb drag also maps the '
      'vertical offset', (tester) async {
    await tester.pumpWidget(_view(1.0, data: _wide));
    await tester.pumpAndSettle();
    _verticalBody(tester).jumpTo(20000);
    await tester.pumpAndSettle();
    final (label, inset) = _rowAtCentre(tester);
    final drag = await _ThumbDrag.start(tester, Axis.horizontal);
    await drag.along(3);
    final pixels = _horizontalBody(tester).pixels;
    _thumbDragRuns(tester, Axis.horizontal);

    await tester.pumpWidget(_view(1.5, data: _wide));
    await tester.pump();
    expect(_verticalBody(tester).pixels, moreOrLessEquals(30000));
    expect(_bar(tester, Axis.vertical).pixels, _verticalBody(tester).pixels);
    expect(
      tester.getTopLeft(find.text(label)).dy - _listTop(tester),
      moreOrLessEquals(inset * 1.5),
    );
    expect(_horizontalBody(tester).pixels, greaterThan(pixels));
    _thumbDragRuns(tester, Axis.horizontal);

    await drag.along(3);
    _thumbDragRuns(tester, Axis.horizontal);
    await drag.release();
  });
}
