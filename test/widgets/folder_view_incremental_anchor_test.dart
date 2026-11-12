// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

// Expanding or collapsing one Parent above the view keeps the rows in view
// still, at the end of the list too, and the vertical scrollbar on the body.

const int _parents = 60;
const int _children = 20;

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

Set<String> _expanded({required bool p0}) => {
  for (var p = p0 ? 0 : 1; p < _parents; p++) 'p$p',
};

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
          wheelMotion: null,
          theme: _theme,
        ),
      ),
    ),
  ),
);

/// The view with its [FolderView] built once per Expanded Set, so a change of
/// [height] alone lays the same [FolderView] out again without rebuilding it.
Widget _heldView(
  ValueNotifier<Set<String>> expanded,
  ValueNotifier<double> height,
) => MaterialApp(
  home: Scaffold(
    body: Center(
      child: ValueListenableBuilder<Set<String>>(
        valueListenable: expanded,
        builder: (context, ids, _) => ValueListenableBuilder<double>(
          valueListenable: height,
          builder: (context, h, child) =>
              SizedBox(width: 400, height: h, child: child),
          child: FolderView<String>(
            data: _nodes,
            mode: ViewMode.tree,
            expandedNodeIds: ids,
            wheelMotion: null,
            theme: _theme,
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

void _winTest(String description, WidgetTesterCallback body) => testWidgets(
  description,
  body,
  variant: TargetPlatformVariant.only(TargetPlatform.windows),
);

void main() {
  final delta = _children * _itemExtent;

  for (final fromEnd in [0.0, 100.0, 1000.0]) {
    _winTest('expanding a Parent above the view at $fromEnd from the end keeps '
        'the rows in view still', (tester) async {
      await tester.pumpWidget(_view(_expanded(p0: false)));
      await tester.pumpAndSettle();
      final oldEnd = _body(tester).maxScrollExtent;
      _body(tester).jumpTo(oldEnd - fromEnd);
      await tester.pumpAndSettle();
      final before = _body(tester).pixels;
      expect(before, oldEnd - fromEnd);
      final (label, top) = _rowAtCentre(tester);

      await tester.pumpWidget(_view(_expanded(p0: true)));
      await tester.pumpAndSettle();

      expect(_body(tester).maxScrollExtent, oldEnd + delta);
      expect(_body(tester).pixels, before + delta);
      expect(tester.getTopLeft(find.text(label)).dy, top);
      expect(_verticalBar(tester).pixels, _body(tester).pixels);
    });
  }

  for (final fromEnd in [0.0, 100.0]) {
    _winTest(
      'collapsing a Parent above the view at $fromEnd from the end keeps '
      'the rows in view still',
      (tester) async {
        await tester.pumpWidget(_view(_expanded(p0: true)));
        await tester.pumpAndSettle();
        final oldEnd = _body(tester).maxScrollExtent;
        _body(tester).jumpTo(oldEnd - fromEnd);
        await tester.pumpAndSettle();
        final before = _body(tester).pixels;
        expect(before, oldEnd - fromEnd);
        final (label, top) = _rowAtCentre(tester);

        await tester.pumpWidget(_view(_expanded(p0: false)));
        await tester.pumpAndSettle();

        expect(_body(tester).maxScrollExtent, oldEnd - delta);
        expect(_body(tester).pixels, before - delta);
        expect(tester.getTopLeft(find.text(label)).dy, top);
        expect(_verticalBar(tester).pixels, _body(tester).pixels);
      },
    );
  }

  for (final expand in [true, false]) {
    final verb = expand ? 'an expand' : 'a collapse';
    final after = expand ? 20000 + delta : 20000 - delta;
    _winTest('a relayout after $verb above the view does not move the rows '
        'again', (tester) async {
      final expanded = ValueNotifier(_expanded(p0: !expand));
      final height = ValueNotifier(300.0);
      addTearDown(expanded.dispose);
      addTearDown(height.dispose);
      await tester.pumpWidget(_heldView(expanded, height));
      await tester.pumpAndSettle();
      _body(tester).jumpTo(20000);
      await tester.pumpAndSettle();

      expanded.value = _expanded(p0: expand);
      await tester.pumpAndSettle();
      expect(_body(tester).pixels, after);
      final (label, top) = _rowAtCentre(tester);
      final folderView = tester.widget(find.byType(FolderView<String>));

      for (final h in [310.0, 320.0]) {
        height.value = h;
        await tester.pumpAndSettle();
        expect(tester.getSize(find.byType(ListView)).height, h);
        expect(
          identical(tester.widget(find.byType(FolderView<String>)), folderView),
          isTrue,
        );
        expect(_body(tester).pixels, after);
        expect(tester.getTopLeft(find.text(label)).dy, top - (h - 300) / 2);
        expect(_verticalBar(tester).pixels, _body(tester).pixels);
      }
    });
  }
}
