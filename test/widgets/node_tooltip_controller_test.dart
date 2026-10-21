import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

/// `NodeTooltipTheme.controllerResolver` gives each Node's label tooltip its
/// own `JustTooltipController` (#133).
void main() {
  // A Folder holding a Parent with [children] Children, all expanded.
  List<Node<String>> data(int children) => [
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
            for (var i = 0; i < children; i++)
              Node<String>(id: 'c$i', label: 'child $i', type: NodeType.child),
          ],
        ),
      ],
    ),
  ];

  Future<void> pump(
    WidgetTester tester, {
    required JustTooltipController? Function(Node<String>) resolver,
    int children = 3,
  }) async {
    final light = FlutterFolderViewTheme<String>.light();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 400,
              height: 300,
              child: FolderView<String>(
                data: data(children),
                mode: ViewMode.folder,
                expandedNodeIds: const {'f', 'p'},
                theme: light.copyWith(
                  childTheme: light.childTheme.copyWith(
                    tooltipTheme: NodeTooltipTheme<String>(
                      useTooltip: true,
                      tooltipBuilderResolver: (node) =>
                          (_) => Text('tip ${node.id}'),
                      controllerResolver: resolver,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Map<String, JustTooltipController> controllers() => {};

  testWidgets('each Node drives its own label tooltip', (tester) async {
    final byId = controllers();
    await pump(
      tester,
      resolver: (node) => byId.putIfAbsent(node.id, JustTooltipController.new),
    );
    expect(tester.takeException(), isNull);
    expect(byId.keys, containsAll(['c0', 'c1', 'c2']));

    byId['c1']!.show();
    await tester.pumpAndSettle();
    expect(find.text('tip c1'), findsOneWidget);
    expect(find.text('tip c0'), findsNothing);
    expect(find.text('tip c2'), findsNothing);

    byId['c1']!.hide();
    await tester.pumpAndSettle();
    expect(find.text('tip c1'), findsNothing);
  });

  testWidgets('a Node the resolver returns null for has no controller', (
    tester,
  ) async {
    final c1 = JustTooltipController();
    await pump(tester, resolver: (node) => node.id == 'c1' ? c1 : null);
    expect(tester.takeException(), isNull);

    c1.show();
    await tester.pumpAndSettle();
    expect(find.text('tip c1'), findsOneWidget);
    expect(find.text('tip c0'), findsNothing);
  });

  testWidgets('a show before the row is built applies once it is built', (
    tester,
  ) async {
    final byId = controllers();
    await pump(
      tester,
      children: 40,
      resolver: (node) => byId.putIfAbsent(node.id, JustTooltipController.new),
    );
    expect(byId.containsKey('c39'), isFalse, reason: 'c39 starts off screen');

    final late = byId.putIfAbsent('c39', JustTooltipController.new)..show();
    await tester.scrollUntilVisible(
      find.text('child 39'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    expect(identical(byId['c39'], late), isTrue);
    expect(find.text('tip c39'), findsOneWidget);
  });

  testWidgets('one controller for two Nodes still fails the assertion', (
    tester,
  ) async {
    final shared = JustTooltipController();
    final errors = <FlutterErrorDetails>[];
    final original = FlutterError.onError;
    FlutterError.onError = errors.add;
    try {
      await pump(tester, resolver: (_) => shared);
    } finally {
      FlutterError.onError = original;
    }

    expect(errors, isNotEmpty);
    expect(
      errors.first.exception,
      isA<AssertionError>().having(
        (e) => e.message,
        'message',
        contains('already attached'),
      ),
    );
  });
}
