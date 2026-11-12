// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

// A Scale change and rows added or removed above the view in one update keep
// the rows in view still: the offset is the row anchor followed by the Scale
// anchor.

const int _parents = 60;
const int _children = 20;
const double _baseExtent = 40;

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

Widget _view(Set<String> expanded, double scale, {double topPadding = 0}) =>
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            height: 300,
            child: FolderView<String>(
              data: _nodes,
              mode: ViewMode.tree,
              expandedNodeIds: expanded,
              scale: scale,
              wheelMotion: null,
              theme: FlutterFolderViewTheme<String>.light().copyWith(
                spacingTheme: FolderViewSpacingTheme(
                  contentPadding: EdgeInsets.only(top: topPadding),
                ),
              ),
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

void _winTest(String description, WidgetTesterCallback body) => testWidgets(
  description,
  body,
  variant: TargetPlatformVariant.only(TargetPlatform.windows),
);

void main() {
  test('the theme has no top padding and a 40 px row', () {
    final theme = FlutterFolderViewTheme<String>.light();
    expect(theme.rowHeight + theme.rowSpacing, _baseExtent);
    expect(theme.spacingTheme.contentPadding.top, 0);
  });

  // Each case: the Parents collapsed before and after, and the rows that adds
  // above the view. Two Parents at once is a bulk change.
  final cases = [
    ('an expand', {'p0'}, <String>{}, _children),
    ('a collapse', <String>{}, {'p0'}, -_children),
    ('a bulk expand', {'p0', 'p1'}, <String>{}, 2 * _children),
  ];

  for (final (verb, before, after, rows) in cases) {
    for (final (from, to) in [(1.0, 1.5), (1.5, 1.0)]) {
      _winTest('$verb above the view with Scale $from → $to in one update '
          'keeps the rows in view still', (tester) async {
        const topRow = 500;
        await tester.pumpWidget(_view(_expandedBut(before), from));
        await tester.pumpAndSettle();
        _body(tester).jumpTo(topRow * _baseExtent * from);
        await tester.pumpAndSettle();
        expect(_body(tester).pixels, topRow * _baseExtent * from);
        final (label, inset) = _rowAtCentre(tester);

        await tester.pumpWidget(_view(_expandedBut(after), to));
        await tester.pumpAndSettle();

        expect(_body(tester).pixels, (topRow + rows) * _baseExtent * to);
        expect(
          tester.getTopLeft(find.text(label)).dy - _listTop(tester),
          moreOrLessEquals(inset / from * to),
        );
        expect(_verticalBar(tester).pixels, _body(tester).pixels);
      });
    }
  }

  _winTest('an expand above the view with a Scale change that moves the view '
      'by 0.5 px or less still moves it by the rows', (tester) async {
    const from = 1.0;
    const to = 1.0005;
    await tester.pumpWidget(_view(_expandedBut({'p0'}), from));
    await tester.pumpAndSettle();
    _body(tester).jumpTo(_baseExtent);
    await tester.pumpAndSettle();
    final (label, inset) = _rowAtCentre(tester);

    await tester.pumpWidget(_view(_expandedBut({}), to));
    await tester.pumpAndSettle();

    final expected = (1 + _children) * _baseExtent * to;
    expect((expected - (1 + _children) * _baseExtent).abs(), lessThan(0.5));
    expect(_body(tester).pixels, moreOrLessEquals(expected, epsilon: 0.5));
    expect(
      tester.getTopLeft(find.text(label)).dy - _listTop(tester),
      moreOrLessEquals(inset, epsilon: 0.5),
    );
    expect(_verticalBar(tester).pixels, _body(tester).pixels);
  });

  _winTest('an expand above the view with Scale 1.0 → 1.5 in one update keeps '
      'the rows in view still under a top padding', (tester) async {
    const topPadding = 30.0;
    const topRow = 500;
    await tester.pumpWidget(
      _view(_expandedBut({'p0'}), 1.0, topPadding: topPadding),
    );
    await tester.pumpAndSettle();
    _body(tester).jumpTo(topPadding + topRow * _baseExtent);
    await tester.pumpAndSettle();
    final (label, inset) = _rowAtCentre(tester);

    await tester.pumpWidget(
      _view(_expandedBut({}), 1.5, topPadding: topPadding),
    );
    await tester.pumpAndSettle();

    expect(
      _body(tester).pixels,
      topPadding * 1.5 + (topRow + _children) * _baseExtent * 1.5,
    );
    expect(
      tester.getTopLeft(find.text(label)).dy - _listTop(tester),
      moreOrLessEquals(inset * 1.5),
    );
    expect(_verticalBar(tester).pixels, _body(tester).pixels);
  });

  _winTest('a bulk collapse at the end with Scale 1.0 → 1.5 in one update '
      'ends on the new end', (tester) async {
    await tester.pumpWidget(_view(_expandedBut({}), 1.0));
    await tester.pumpAndSettle();
    final oldEnd = _body(tester).maxScrollExtent;
    _body(tester).jumpTo(oldEnd);
    await tester.pumpAndSettle();

    // p0 above the view and p59, in view, collapsed together.
    await tester.pumpWidget(_view(_expandedBut({'p0', 'p59'}), 1.5));
    await tester.pumpAndSettle();

    final rows = _parents * (1 + _children) - 2 * _children;
    final newEnd = rows * _baseExtent * 1.5 - 300;
    expect(_body(tester).maxScrollExtent, newEnd);
    expect(_body(tester).pixels, newEnd);
    expect(find.text('p59'), findsOneWidget);
    expect(_verticalBar(tester).pixels, _body(tester).pixels);
  });
}
