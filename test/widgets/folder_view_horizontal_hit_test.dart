import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pointer input on a row after horizontal scrolling (#136).
///
/// Every row is laid out at the content width and shifted by the horizontal
/// offset. Painting followed the shift, but hit testing stopped at the first
/// viewport-width of the row, so once the view scrolled, the visible part of
/// a row past that point took no tap and no hover.
void main() {
  // A Parent with a Child whose label makes the content wider than the view,
  // and a short Child whose row is just as wide.
  List<Node<String>> data() => [
    Node<String>(
      id: 'p',
      label: 'parent',
      type: NodeType.parent,
      children: [
        Node<String>(id: 'long', label: 'x' * 400, type: NodeType.child),
        Node<String>(id: 'short', label: 'short', type: NodeType.child),
      ],
    ),
  ];

  Future<void> pump(
    WidgetTester tester, {
    void Function(Node<String>)? onNodeTap,
    Widget? Function(BuildContext, Node<String>)? rowTooltipBuilder,
    Widget? childWidget,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              height: 300,
              child: FolderView<String>(
                data: data(),
                mode: ViewMode.tree,
                expandedNodeIds: const {'p'},
                onNodeTap: onNodeTap,
                rowTooltipBuilder: rowTooltipBuilder,
                theme: childWidget == null
                    ? null
                    : FlutterFolderViewTheme<String>.light().copyWith(
                        childTheme: ChildNodeTheme<String>(widget: childWidget),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  ScrollPosition horizontal(WidgetTester tester) => tester
      .stateList<ScrollableState>(find.byType(Scrollable))
      .firstWhere((s) => s.position.axis == Axis.horizontal)
      .position;

  Future<void> scrollTo(WidgetTester tester, double offset) async {
    horizontal(tester).jumpTo(offset);
    await tester.pumpAndSettle();
  }

  for (final offset in [300.0, 800.0]) {
    testWidgets('scrolled to $offset, a tap anywhere visible on a row fires '
        'onNodeTap', (tester) async {
      final tapped = <String>[];
      await pump(tester, onNodeTap: (n) => tapped.add(n.id));
      expect(horizontal(tester).maxScrollExtent, 800);
      await scrollTo(tester, offset);

      // The short label is scrolled out of sight; tap the row's empty part.
      final y = tester.getCenter(find.text('short', skipOffstage: false)).dy;
      final view = tester.getRect(find.byType(FolderView<String>));
      for (final x in [view.left + 20, view.center.dx, view.right - 30]) {
        tapped.clear();
        await tester.tapAt(Offset(x, y));
        await tester.pumpAndSettle();
        expect(tapped, ['short'], reason: 'tap at x $x, offset $offset');
      }
    });
  }

  testWidgets('scrolled to the end, hovering a row raises its row card', (
    tester,
  ) async {
    await pump(
      tester,
      rowTooltipBuilder: (context, node) => Text('card ${node.id}'),
    );
    await scrollTo(tester, 800);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    final view = tester.getRect(find.byType(FolderView<String>));
    final y = tester.getCenter(find.text('short', skipOffstage: false)).dy;
    await mouse.moveTo(Offset(view.center.dx, y));
    await tester.pumpAndSettle();
    expect(find.text('card short'), findsOneWidget);
  });

  testWidgets('the first horizontal scroll keeps a row\'s state', (
    tester,
  ) async {
    _Counted.created = 0;
    await pump(tester, childWidget: const _Counted());
    final before = _Counted.created;
    expect(before, greaterThan(0));

    await scrollTo(tester, 10);
    await scrollTo(tester, 0);
    await scrollTo(tester, 20);
    expect(_Counted.created, before, reason: 'row state was recreated');
  });
}

/// A Child icon that counts how many of its States are created.
class _Counted extends StatefulWidget {
  const _Counted();

  static int created = 0;

  @override
  State<_Counted> createState() => _CountedState();
}

class _CountedState extends State<_Counted> {
  @override
  void initState() {
    super.initState();
    _Counted.created++;
  }

  @override
  Widget build(BuildContext context) => const SizedBox(width: 16, height: 16);
}
