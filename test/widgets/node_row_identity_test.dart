// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

/// A rendered row belongs to its Node, not to its index: when the rows above
/// or at a Node change, that Node's label tooltip and its controller stay with
/// it (#172).
void main() {
  List<Node<String>> data(List<String> children) => [
    Node<String>(
      id: 'p',
      label: 'p',
      type: NodeType.parent,
      children: [
        for (final id in children)
          Node<String>(id: id, label: id, type: NodeType.child),
      ],
    ),
    Node<String>(
      id: 'q',
      label: 'q',
      type: NodeType.parent,
      children: [
        for (var i = 0; i < 3; i++)
          Node<String>(id: 'z$i', label: 'z$i', type: NodeType.child),
      ],
    ),
  ];

  Widget view({
    required List<String> children,
    Set<String> expanded = const {'p', 'q'},
    Map<String, JustTooltipController>? controllers,
    bool enableTap = false,
    ValueChanged<Node<String>>? onNodeTap,
  }) {
    final light = FlutterFolderViewTheme<String>.light();
    final tooltip = NodeTooltipTheme<String>(
      useTooltip: true,
      enableTap: enableTap,
      controllerResolver: controllers == null
          ? null
          : (node) =>
                controllers.putIfAbsent(node.id, JustTooltipController.new),
      tooltipBuilderResolver: (node) =>
          (_) => Text('tip ${node.id}'),
    );
    return MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 400,
            height: 500,
            child: FolderView<String>(
              data: data(children),
              mode: ViewMode.tree,
              expandedNodeIds: expanded,
              onNodeTap: onNodeTap,
              theme: light.copyWith(
                parentTheme: light.parentTheme.copyWith(tooltipTheme: tooltip),
                childTheme: light.childTheme.copyWith(tooltipTheme: tooltip),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Iterable<String> shownTips() => find
      .textContaining('tip ')
      .evaluate()
      .map((e) => (e.widget as Text).data!);

  group('with enableTap on, a label tap whose onNodeTap changes the rows', () {
    testWidgets('shows no other Node\'s tooltip when it removes the tapped '
        'Node', (tester) async {
      var children = ['c0', 'c1', 'c2', 'c3'];
      late StateSetter setState;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return view(
              children: children,
              enableTap: true,
              onNodeTap: (node) {
                if (node.id == 'c1') {
                  setState(() => children = ['c0', 'c2', 'c3']);
                }
              },
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('c1'));
      await tester.pumpAndSettle();

      expect(find.text('c1'), findsNothing);
      expect(shownTips(), isEmpty);
    });

    testWidgets('shows no other Node\'s tooltip when a tap beside a Parent\'s '
        'label collapses it', (tester) async {
      final expanded = {'p', 'q'};
      late StateSetter setState;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return view(
              children: const ['c0', 'c1', 'c2', 'c3'],
              expanded: expanded,
              enableTap: true,
              onNodeTap: (node) {
                if (node.id == 'p') setState(() => expanded.remove('p'));
              },
            );
          },
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('c3'));
      await tester.pumpAndSettle();
      expect(shownTips(), ['tip c3']);

      final label = tester.getRect(find.text('p'));
      await tester.tapAt(Offset(label.right + 80, label.center.dy));
      await tester.pumpAndSettle();

      expect(find.text('c3'), findsNothing);
      expect(shownTips(), isEmpty);
    });
  });

  group('a per-Node controller keeps working', () {
    for (final (name, before, after) in [
      (
        'after a row above it is removed',
        (children: ['c0', 'c1', 'c2'], expanded: {'p', 'q'}),
        (children: ['c0', 'c2'], expanded: {'p', 'q'}),
      ),
      (
        'after a row is inserted above it',
        (children: ['c0', 'c2'], expanded: {'p', 'q'}),
        (children: ['c0', 'c1', 'c2'], expanded: {'p', 'q'}),
      ),
      (
        'after the Parent above it collapses',
        (children: ['c0', 'c1', 'c2'], expanded: {'p', 'q'}),
        (children: ['c0', 'c1', 'c2'], expanded: {'q'}),
      ),
    ]) {
      testWidgets(name, (tester) async {
        final controllers = <String, JustTooltipController>{};
        await tester.pumpWidget(
          view(
            children: before.children,
            expanded: before.expanded,
            controllers: controllers,
          ),
        );
        await tester.pumpAndSettle();

        await tester.pumpWidget(
          view(
            children: after.children,
            expanded: after.expanded,
            controllers: controllers,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        controllers['z0']!.show();
        await tester.pumpAndSettle();
        expect(shownTips(), ['tip z0']);
      });
    }
  });

  testWidgets('a second tap at the spot of a row the first tap removed is no '
      'double tap on the Node now there', (tester) async {
    final log = <String>[];
    var children = ['c0', 'c1', 'c2'];
    late StateSetter setState;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, set) {
          setState = set;
          return MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 400,
                  height: 500,
                  child: FolderView<String>(
                    data: data(children),
                    mode: ViewMode.tree,
                    expandedNodeIds: const {'p', 'q'},
                    onNodeTap: (node) {
                      log.add('tap ${node.id}');
                      if (node.id == 'c1') {
                        setState(() => children = ['c0', 'c2']);
                      }
                    },
                    onDoubleNodeTap: (node) => log.add('double ${node.id}'),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    final spot = tester.getCenter(find.text('c1'));
    await tester.tapAt(spot);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(spot);
    await tester.pumpAndSettle();

    expect(log, ['tap c1', 'tap c2']);
  });

  testWidgets('a second tap on a Node the first tap moved is a double tap on '
      'it', (tester) async {
    final log = <String>[];
    var children = ['c0', 'c1', 'c2'];
    late StateSetter setState;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, set) {
          setState = set;
          return MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 400,
                  height: 500,
                  child: FolderView<String>(
                    data: data(children),
                    mode: ViewMode.tree,
                    expandedNodeIds: const {'p', 'q'},
                    onNodeTap: (node) {
                      log.add('tap ${node.id}');
                      if (node.id == 'c1' && children.first != 'c1') {
                        setState(() => children = ['c1', 'c0', 'c2']);
                      }
                    },
                    onDoubleNodeTap: (node) => log.add('double ${node.id}'),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('c1'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('c1'));
    await tester.pumpAndSettle();

    expect(log, ['tap c1', 'double c1']);
  });
}
