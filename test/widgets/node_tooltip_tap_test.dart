import 'package:flutter/gestures.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

/// `NodeTooltipTheme.enableTap`: a tap on a label toggles the label tooltip and
/// reaches the row as any other tap does.
void main() {
  const folderTip = 'folder tip';
  const parentTip = 'parent tip';
  const childTip = 'child tip';

  final data = [
    Node<String>(
      id: 'f',
      label: 'folder',
      type: NodeType.folder,
      children: [
        Node<String>(
          id: 'p',
          label: 'parent',
          type: NodeType.parent,
          children: [
            for (var i = 0; i < 40; i++)
              Node<String>(id: 'c$i', label: 'child $i', type: NodeType.child),
          ],
        ),
      ],
    ),
  ];

  /// The caller's side of the view: it logs every callback, selects a tapped
  /// Child and toggles a tapped Folder or Parent. Returns the log.
  Future<List<String>> pump(
    WidgetTester tester, {
    required bool enableTap,
    Set<String> expanded = const {'f', 'p'},
    bool withDoubleTap = false,
    Widget? Function(BuildContext, Node<String>)? rowTooltipBuilder,
  }) async {
    final log = <String>[];
    final expandedIds = {...expanded};
    final selectedIds = <String>{};
    final light = FlutterFolderViewTheme<String>.light();

    NodeTooltipTheme<String> tooltip(String message) =>
        NodeTooltipTheme<String>(
          useTooltip: true,
          message: message,
          enableTap: enableTap,
        );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 400,
              height: 300,
              child: StatefulBuilder(
                builder: (context, setState) => FolderView<String>(
                  data: data,
                  mode: ViewMode.folder,
                  expandedNodeIds: expandedIds,
                  selectedNodeIds: selectedIds,
                  rowTooltipBuilder: rowTooltipBuilder,
                  theme: light.copyWith(
                    folderTheme: light.folderTheme.copyWith(
                      tooltipTheme: tooltip(folderTip),
                    ),
                    parentTheme: light.parentTheme.copyWith(
                      tooltipTheme: tooltip(parentTip),
                    ),
                    childTheme: light.childTheme.copyWith(
                      tooltipTheme: tooltip(childTip),
                    ),
                  ),
                  onNodeTap: (node) => setState(() {
                    log.add('tap ${node.id}');
                    if (node.type == NodeType.child) {
                      selectedIds
                        ..clear()
                        ..add(node.id);
                    } else if (!expandedIds.remove(node.id)) {
                      expandedIds.add(node.id);
                    }
                  }),
                  onDoubleNodeTap: withDoubleTap
                      ? (node) => log.add('double ${node.id}')
                      : null,
                  onSecondaryNodeTap: (node, _) =>
                      log.add('secondary ${node.id}'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return log;
  }

  Set<String> selected(WidgetTester tester) => tester
      .widget<FolderView<String>>(find.byType(FolderView<String>))
      .selectedNodeIds!;

  Set<String> expanded(WidgetTester tester) => tester
      .widget<FolderView<String>>(find.byType(FolderView<String>))
      .expandedNodeIds!;

  group('with enableTap on', () {
    testWidgets('a tap on a Child label selects it and opens the tooltip; a '
        'second tap closes the tooltip and fires onNodeTap again', (
      tester,
    ) async {
      final log = await pump(tester, enableTap: true);

      await tester.tap(find.text('child 0'));
      await tester.pumpAndSettle();
      expect(log, ['tap c0']);
      expect(selected(tester), {'c0'});
      expect(find.text(childTip), findsOneWidget);

      await tester.tap(find.text('child 0'));
      await tester.pumpAndSettle();
      expect(log, ['tap c0', 'tap c0']);
      expect(find.text(childTip), findsNothing);
    });

    testWidgets('a tap on a Folder label expands it and opens the tooltip', (
      tester,
    ) async {
      final log = await pump(tester, enableTap: true, expanded: const {});
      expect(find.text('parent'), findsNothing);

      await tester.tap(find.text('folder'));
      await tester.pumpAndSettle();
      expect(log, ['tap f']);
      expect(expanded(tester), {'f'});
      expect(find.text('parent'), findsOneWidget);
      expect(find.text(folderTip), findsOneWidget);
    });

    testWidgets('a tap on a Parent label collapses it and opens the tooltip', (
      tester,
    ) async {
      final log = await pump(tester, enableTap: true);
      expect(find.text('child 0'), findsOneWidget);

      await tester.tap(find.text('parent'));
      await tester.pumpAndSettle();
      expect(log, ['tap p']);
      expect(expanded(tester), {'f'});
      expect(find.text('child 0'), findsNothing);
      expect(find.text(parentTip), findsOneWidget);
    });

    testWidgets('a double tap on a Child label fires what a double tap beside '
        'it fires, with the tooltip open after the first and closed after the '
        'second', (tester) async {
      final log = await pump(tester, enableTap: true, withDoubleTap: true);

      final label = tester.getRect(find.text('child 1'));
      final beside = Offset(label.right + 40, label.center.dy);
      await tester.tapAt(beside);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(beside);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(log, ['tap c1', 'double c1']);
      log.clear();

      await tester.tap(find.text('child 0'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 200));
      expect(log, ['tap c0']);
      expect(find.text(childTip), findsOneWidget);

      await tester.tap(find.text('child 0'));
      await tester.pumpAndSettle();
      expect(log, ['tap c0', 'double c0']);
      expect(find.text(childTip), findsNothing);
    });

    testWidgets('a hover opens the tooltip, and a click on the label closes it '
        'and still reaches the row', (tester) async {
      final log = await pump(tester, enableTap: true);
      final at = tester.getCenter(find.text('child 0'));

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(at);
      await tester.pumpAndSettle();
      expect(find.text(childTip), findsOneWidget);
      expect(log, isEmpty);

      await mouse.down(at);
      await tester.pump();
      await mouse.up();
      await tester.pumpAndSettle();
      expect(log, ['tap c0']);
      expect(selected(tester), {'c0'});
      expect(find.text(childTip), findsNothing);
    });

    testWidgets('a tap beside the label reaches the row and opens no tooltip', (
      tester,
    ) async {
      final log = await pump(tester, enableTap: true);

      final label = tester.getRect(find.text('child 0'));
      await tester.tapAt(Offset(label.right + 40, label.center.dy));
      await tester.pumpAndSettle();
      expect(log, ['tap c0']);
      expect(find.text(childTip), findsNothing);
    });

    testWidgets('a drag that starts on a label scrolls, opens no tooltip and '
        'fires no tap', (tester) async {
      final log = await pump(tester, enableTap: true);
      final list = tester.widget<ListView>(find.byType(ListView)).controller!;

      await tester.drag(find.text('child 0'), const Offset(0, -120));
      await tester.pumpAndSettle();
      expect(list.offset, greaterThan(0));
      expect(log, isEmpty);
      expect(find.text(childTip), findsNothing);
    });

    testWidgets('inside a row card, a tap on a label reaches the row and opens '
        'the label tooltip, not the card', (tester) async {
      final log = await pump(
        tester,
        enableTap: true,
        rowTooltipBuilder: (context, node) => const Text('row card'),
      );

      await tester.tap(find.text('child 0'));
      await tester.pumpAndSettle();
      expect(log, ['tap c0']);
      expect(find.text(childTip), findsOneWidget);
      expect(find.text('row card'), findsNothing);
    });

    testWidgets('a secondary tap on a label fires onSecondaryNodeTap and opens '
        'no tooltip', (tester) async {
      final log = await pump(tester, enableTap: true);

      await tester.tap(find.text('child 0'), buttons: kSecondaryButton);
      await tester.pumpAndSettle();
      expect(log, ['secondary c0']);
      expect(find.text(childTip), findsNothing);
    });
  });

  testWidgets(
    'with enableTap off a tap on a label fires onNodeTap and opens no '
    'tooltip',
    (tester) async {
      final log = await pump(tester, enableTap: false);

      await tester.tap(find.text('child 0'));
      await tester.pumpAndSettle();
      expect(log, ['tap c0']);
      expect(selected(tester), {'c0'});
      expect(find.text(childTip), findsNothing);
    },
  );
}
