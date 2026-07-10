import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

/// Both tooltips enabled at once, as the example app has them. The label
/// tooltip explains the label; the row card explains the Node. Exactly one is
/// visible — the innermost under the pointer — so the label tooltip must claim
/// no more of the row than the glyphs it describes.
///
/// Mirrors `flutter_table_plus`, whose cell wraps the bare `Text` for a text
/// tooltip and the whole cell only for a widget tooltip: "a text tooltip
/// belongs to the glyphs".
///
/// ONE hover per `testWidgets`: the `just_tooltip` registry is a package-level
/// singleton and suppresses later tooltips in the same test. A scan of many
/// points inside one test reports `none` from the second hover onward, which
/// looks exactly like the row card failing to cover the row.
void main() {
  const short = 'a.pdf';
  const long = 'a_much_longer_child_label_here.pdf';

  List<Node<String>> data() => [
        Node<String>(
          id: 'f',
          label: 'folder-f',
          type: NodeType.folder,
          children: [
            Node<String>(
              id: 'p',
              label: 'parent-p',
              type: NodeType.parent,
              children: [
                Node<String>(id: 'c0', label: short, type: NodeType.child),
                Node<String>(id: 'c1', label: long, type: NodeType.child),
              ],
            ),
          ],
        ),
      ];

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 500,
            height: 300,
            child: FolderView<String>(
              data: data(),
              mode: ViewMode.folder,
              expandedNodeIds: const {'f', 'p'},
              theme: FlutterFolderViewTheme<String>(
                lineTheme:
                    const FolderViewLineTheme(lineColor: Color(0xFF000000)),
                scrollbarTheme: const FolderViewScrollbarTheme(
                  thumbColor: Color(0xFF000000),
                  trackColor: Color(0xFF000000),
                ),
                childTheme: ChildNodeTheme<String>(
                  tooltipTheme: NodeTooltipTheme<String>(
                    useTooltip: true,
                    padding: EdgeInsets.zero,
                    tooltipBuilder: (_) => const SizedBox(
                        key: Key('labeltip'), width: 60, height: 20),
                  ),
                ),
              ),
              rowTooltipBuilder: (context, node) =>
                  const SizedBox(key: Key('card'), width: 80, height: 30),
            ),
          ),
        ),
      ),
    ));
  }

  Future<String> hoverOnce(WidgetTester tester, Offset at) async {
    final g = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await g.addPointer(location: const Offset(495, 295));
    addTearDown(g.removePointer);
    await tester.pump();
    await g.moveTo(at);
    await tester.pumpAndSettle();
    final card = find.byKey(const Key('card')).evaluate().isNotEmpty;
    final tip = find.byKey(const Key('labeltip')).evaluate().isNotEmpty;
    if (card && tip) return 'BOTH';
    if (card) return 'card';
    if (tip) return 'labeltip';
    return 'none';
  }

  testWidgets('short row, over the glyphs', (tester) async {
    await pump(tester);
    final r = tester.getRect(find.text(short));
    expect(await hoverOnce(tester, r.center), 'labeltip');
  });

  testWidgets('short row, far right of the glyphs', (tester) async {
    await pump(tester);
    final r = tester.getRect(find.text(short));
    expect(await hoverOnce(tester, Offset(300, r.center.dy)), 'card');
  });

  testWidgets('short row, over the icon', (tester) async {
    await pump(tester);
    final r = tester.getRect(find.text(short));
    // The icon box sits just left of the glyphs.
    expect(await hoverOnce(tester, Offset(r.left - 10, r.center.dy)), 'card');
  });

  testWidgets('long row, over the glyphs', (tester) async {
    await pump(tester);
    final r = tester.getRect(find.text(long));
    expect(await hoverOnce(tester, Offset(300, r.center.dy)), 'labeltip');
  });

  testWidgets('long row, over the indent', (tester) async {
    await pump(tester);
    final r = tester.getRect(find.text(long));
    expect(await hoverOnce(tester, Offset(10, r.center.dy)), 'card');
  });
}
