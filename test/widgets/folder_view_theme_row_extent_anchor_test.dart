import 'package:flutter/gestures.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

// A theme change that alters the row extent or the top padding keeps the rows
// in view still, as a Scale change does, on the vertical axis only.

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

/// Wide enough to scroll horizontally.
final String _wideLabel = 'L' * 40;
final List<Node<String>> _wide = _nodes(firstLabel: _wideLabel);

/// Every Parent expanded but those in [collapsed].
Set<String> _expandedBut(Set<String> collapsed) => {
  for (var p = 0; p < _parents; p++)
    if (!collapsed.contains('p$p')) 'p$p',
};

/// The light theme with the given row geometry, label font size and line
/// colour.
FlutterFolderViewTheme<String> _theme({
  double rowHeight = 40,
  double rowSpacing = 0,
  double topPadding = 0,
  double? fontSize,
  Color? lineColor,
}) {
  final base = FlutterFolderViewTheme<String>.light();
  return base.copyWith(
    rowHeight: rowHeight,
    rowSpacing: rowSpacing,
    spacingTheme: FolderViewSpacingTheme(
      contentPadding: EdgeInsets.only(top: topPadding),
    ),
    lineTheme: lineColor == null
        ? null
        : base.lineTheme.copyWith(lineColor: lineColor),
    parentTheme: fontSize == null
        ? null
        : base.parentTheme.copyWith(textStyle: TextStyle(fontSize: fontSize)),
    childTheme: fontSize == null
        ? null
        : base.childTheme.copyWith(textStyle: TextStyle(fontSize: fontSize)),
  );
}

Widget _view(
  FlutterFolderViewTheme<String> theme, {
  List<Node<String>>? data,
  Set<String> collapsed = const {},
}) => MaterialApp(
  home: Scaffold(
    body: Center(
      child: SizedBox(
        width: 400,
        height: 300,
        child: FolderView<String>(
          data: data ?? _narrow,
          mode: ViewMode.tree,
          expandedNodeIds: _expandedBut(collapsed),
          wheelMotion: null,
          theme: theme,
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
        of: find.byType(Scrollbar),
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

/// The row under the top edge of the view, as its Node id, and the share of
/// its height above that edge.
(String, double) _topRow(WidgetTester tester) {
  final listTop = tester.getTopLeft(find.byType(ListView)).dy;
  for (final element
      in find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(KeyedSubtree),
          )
          .evaluate()) {
    final key = element.widget.key;
    if (key is! ValueKey<String>) continue;
    final rect = tester.getRect(find.byKey(key));
    if (rect.top <= listTop && listTop < rect.bottom) {
      return (key.value, (listTop - rect.top) / rect.height);
    }
  }
  throw StateError('no row under the top edge');
}

/// A mouse drag on the vertical scrollbar's thumb, pressed at the start of its
/// track and moved along it in steps of 10 with a frame after each.
class _ThumbDrag {
  _ThumbDrag._(this._tester, this._at);

  final WidgetTester _tester;
  final Offset _at;
  final TestPointer _pointer = TestPointer(1, PointerDeviceKind.mouse);
  double _moved = 0;

  static Future<_ThumbDrag> start(WidgetTester tester) async {
    final rect = tester.getRect(find.byType(FolderView<String>));
    final drag = _ThumbDrag._(tester, Offset(rect.right - 3, rect.top + 5));
    await tester.sendEventToBinding(drag._pointer.hover(drag._at));
    await tester.pumpAndSettle();
    await tester.sendEventToBinding(drag._pointer.down(drag._at));
    await tester.pump();
    return drag;
  }

  Future<void> along(int steps) async {
    for (var i = 0; i < steps; i++) {
      _moved += 10;
      await _tester.sendEventToBinding(_pointer.move(_at + Offset(0, _moved)));
      await _tester.pump();
    }
  }

  Future<void> release() async {
    await _tester.sendEventToBinding(_pointer.up());
    await _tester.pumpAndSettle();
  }
}

/// Checks that the vertical thumb drag is still running, with the body on the
/// scrollbar.
void _thumbDragRuns(WidgetTester tester) {
  expect(_bar(tester, Axis.vertical).activity, isA<DragScrollActivity>());
  expect(_verticalBody(tester).pixels, _bar(tester, Axis.vertical).pixels);
}

void _winTest(String description, WidgetTesterCallback body) => testWidgets(
  description,
  body,
  variant: TargetPlatformVariant.only(TargetPlatform.windows),
);

void main() {
  test('the default theme has no top padding and a 40 px row', () {
    final theme = _theme();
    expect(theme.rowHeight + theme.rowSpacing, _baseExtent);
    expect(theme.spacingTheme.contentPadding.top, 0);
  });

  // Each case: the theme after the change, and the offset of row 500's top in
  // it. Row 500 is p23-c16: 21 rows a Parent in tree mode.
  final cases = [
    ('rowHeight 40 → 60', _theme(rowHeight: 60), 500 * 60.0),
    ('rowSpacing 0 → 20', _theme(rowSpacing: 20), 500 * 60.0),
    ('contentPadding.top 0 → 30', _theme(topPadding: 30), 30 + 500 * 40.0),
  ];

  for (final (change, after, rowTop) in cases) {
    _winTest('a theme change of $change keeps the rows in view still', (
      tester,
    ) async {
      await tester.pumpWidget(_view(_theme()));
      await tester.pumpAndSettle();
      _verticalBody(tester).jumpTo(500 * _baseExtent + 10);
      await tester.pumpAndSettle();
      final (id, share) = _topRow(tester);
      expect(id, 'p23-c16');
      expect(share, moreOrLessEquals(0.25));

      await tester.pumpWidget(_view(after));
      await tester.pumpAndSettle();

      final newExtent = after.rowHeight + after.rowSpacing;
      expect(_verticalBody(tester).pixels, rowTop + share * newExtent);
      final (newId, newShare) = _topRow(tester);
      expect(newId, id);
      expect(newShare, moreOrLessEquals(share));
      expect(_bar(tester, Axis.vertical).pixels, _verticalBody(tester).pixels);
    });

    _winTest('a theme change of $change with a Parent expanded above the view '
        'in one update keeps the rows in view still', (tester) async {
      await tester.pumpWidget(_view(_theme(), collapsed: {'p0'}));
      await tester.pumpAndSettle();
      // Row 480 with p0 collapsed is row 500 with it expanded: p23-c16.
      _verticalBody(tester).jumpTo(480 * _baseExtent);
      await tester.pumpAndSettle();
      final (id, share) = _topRow(tester);
      expect(id, 'p23-c16');
      expect(share, moreOrLessEquals(0));

      await tester.pumpWidget(_view(after));
      await tester.pumpAndSettle();

      expect(_verticalBody(tester).pixels, rowTop);
      final (newId, newShare) = _topRow(tester);
      expect(newId, id);
      expect(newShare, moreOrLessEquals(0));
      expect(_bar(tester, Axis.vertical).pixels, _verticalBody(tester).pixels);
    });
  }

  for (final (offset, rowHeight) in [(0.0, 20.0), (10.0, 20.0), (10.0, 60.0)]) {
    _winTest('a theme change of rowHeight 40 → $rowHeight at $offset inside '
        'a top padding of 30 keeps the rows in view still', (tester) async {
      await tester.pumpWidget(_view(_theme(topPadding: 30)));
      await tester.pumpAndSettle();
      _verticalBody(tester).jumpTo(offset);
      await tester.pumpAndSettle();
      final listTop = tester.getTopLeft(find.byType(ListView)).dy;
      final firstTop = tester.getTopLeft(find.byKey(const ValueKey('p0'))).dy;
      expect(firstTop - listTop, 30 - offset);

      await tester.pumpWidget(
        _view(_theme(topPadding: 30, rowHeight: rowHeight)),
      );
      await tester.pumpAndSettle();

      expect(_verticalBody(tester).pixels, offset);
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('p0'))).dy - listTop,
        30 - offset,
      );
      expect(_bar(tester, Axis.vertical).pixels, _verticalBody(tester).pixels);
    });
  }

  _winTest('a theme change of rowHeight 40 → 60 during a vertical thumb drag '
      'keeps the rows in view still and lets the drag go on', (tester) async {
    await tester.pumpWidget(_view(_theme()));
    await tester.pumpAndSettle();
    final drag = await _ThumbDrag.start(tester);
    await drag.along(3);
    final pixels = _verticalBody(tester).pixels;
    expect(pixels, greaterThan(0));
    _thumbDragRuns(tester);
    final (id, share) = _topRow(tester);

    await tester.pumpWidget(_view(_theme(rowHeight: 60)));
    await tester.pump();
    expect(_verticalBody(tester).pixels, moreOrLessEquals(pixels / 40 * 60));
    final (newId, newShare) = _topRow(tester);
    expect(newId, id);
    expect(newShare, moreOrLessEquals(share));
    _thumbDragRuns(tester);

    await drag.along(3);
    _thumbDragRuns(tester);
    expect(_verticalBody(tester).pixels, greaterThan(pixels / 40 * 60));
    await drag.release();
    expect(_bar(tester, Axis.vertical).pixels, _verticalBody(tester).pixels);
  });

  _winTest('a theme change with the row extent and top padding unchanged '
      'moves nothing', (tester) async {
    await tester.pumpWidget(_view(_theme()));
    await tester.pumpAndSettle();
    _verticalBody(tester).jumpTo(500 * _baseExtent + 10);
    await tester.pumpAndSettle();

    // 30 + 10 against 40 + 0: the same extent.
    await tester.pumpWidget(
      _view(_theme(rowHeight: 30, rowSpacing: 10, lineColor: Colors.red)),
    );
    await tester.pumpAndSettle();

    expect(_verticalBody(tester).pixels, 500 * _baseExtent + 10);
    final (id, share) = _topRow(tester);
    expect(id, 'p23-c16');
    expect(share, moreOrLessEquals(0.25));
  });

  _winTest('a theme change that resizes rows and widens the content leaves '
      'the horizontal offset unchanged', (tester) async {
    await tester.pumpWidget(_view(_theme(), data: _wide));
    await tester.pumpAndSettle();
    final oldWidth =
        _horizontalBody(tester).maxScrollExtent +
        _horizontalBody(tester).viewportDimension;
    _horizontalBody(tester).jumpTo(100);
    _verticalBody(tester).jumpTo(500 * _baseExtent);
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      _view(_theme(rowHeight: 60, fontSize: 20), data: _wide),
    );
    await tester.pumpAndSettle();

    final body = _horizontalBody(tester);
    expect(
      body.maxScrollExtent + body.viewportDimension,
      greaterThan(oldWidth + 1),
    );
    expect(body.pixels, 100);
    expect(_bar(tester, Axis.horizontal).pixels, 100);
    expect(_verticalBody(tester).pixels, 500 * 60.0);
  });
}
