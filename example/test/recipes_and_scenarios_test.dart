import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/shell_harness.dart';

void main() {
  group('Building a tree', () {
    testWidgets('renders its hand-built Folder → Parent → Child tree', (
      tester,
    ) async {
      await pumpShell(tester);
      await openDestination(tester, 'Building a tree');

      final view = renderedFolderView(tester);
      expect(view.data.single.type, NodeType.folder);
      expect(
        view.data.single.children.map((n) => n.type),
        everyElement(NodeType.parent),
      );
      expect(find.text('q1.pdf'), findsOneWidget);
    });

    testWidgets('tapping a Child shows its data payload', (tester) async {
      await pumpShell(tester);
      await openDestination(tester, 'Building a tree');

      await tester.tap(find.text('q1.pdf'));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('First-quarter report, 12 pages'), findsOneWidget);
    });
  });

  group('A hundred thousand children', () {
    testWidgets('renders 100 × 10 × 100 nodes, fully expanded', (tester) async {
      await pumpShell(tester);
      await openDestination(tester, 'A hundred thousand children');

      final view = renderedFolderView(tester);
      expect(view.data, hasLength(100));
      final parents = view.data.expand((f) => f.children).toList();
      expect(parents, hasLength(1000));
      expect(parents.expand((p) => p.children), hasLength(100000));
      expect(view.expandedNodeIds, hasLength(1100));
      expect(find.text('Child 1.1.1'), findsOneWidget);
    });
  });

  testWidgets('the menu lists the recipe and the scenario', (tester) async {
    await pumpShell(tester);

    expect(find.text('Building a tree'), findsWidgets);
    expect(find.text('A hundred thousand children'), findsWidgets);
  });
}
