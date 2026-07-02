import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_folderview/models/flat_node.dart';
import 'package:flutter_folderview/widgets/tree_lines.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  FlatNode<String> flat({
    required int depth,
    required bool isLast,
    required bool isRoot,
    required List<bool> ancestors,
  }) {
    return FlatNode<String>(
      node: Node<String>(id: 'n', label: 'n', type: NodeType.parent),
      depth: depth,
      isFirst: false,
      isLast: isLast,
      isRoot: isRoot,
      ancestorIsLastFlags: ancestors,
    );
  }

  group('TreeLinePlan.forRow', () {
    test('a root row draws no connector and no continuation guides', () {
      final plan = TreeLinePlan.forRow(
        row: flat(depth: 0, isLast: false, isRoot: true, ancestors: const []),
        lineWidth: 20,
      );
      expect(plan.connectorX, isNull);
      expect(plan.continuationXs, isEmpty);
    });

    test('continuation guides appear only past ancestors with siblings below',
        () {
      // depth-2 node; ancestor at depth 0 still has siblings (false), ancestor
      // at depth 1 is the last child (true). Only depth 0 keeps a guide.
      final plan = TreeLinePlan.forRow(
        row: flat(
          depth: 2,
          isLast: false,
          isRoot: false,
          ancestors: const [false, true],
        ),
        lineWidth: 20,
      );
      // Column 0 centre = 0*20 + 20/2.
      expect(plan.continuationXs, [10]);
      // Connector sits in the parent column (depth-1 = 1): 1*20 + 20/2.
      expect(plan.connectorX, 30);
      expect(plan.connectorIsLast, isFalse);
      // Horizontal stub ends at the connector column's right edge: depth*20.
      expect(plan.connectorEndX, 40);
    });

    test('a last child gets a mid-row connector (connectorIsLast)', () {
      final plan = TreeLinePlan.forRow(
        row: flat(
          depth: 1,
          isLast: true,
          isRoot: false,
          ancestors: const [true],
        ),
        lineWidth: 20,
      );
      expect(plan.continuationXs, isEmpty); // sole ancestor is a last child
      expect(plan.connectorX, 10); // (1-1)*20 + 10
      expect(plan.connectorIsLast, isTrue);
      expect(plan.connectorEndX, 20);
    });
  });

  testWidgets('non-root rows render TreeLines when a line style is set',
      (tester) async {
    // Tree mode: the Parent is the root (no connector); its expanded Child is a
    // non-root row and must render tree lines. Light theme uses connector style.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FolderView<String>(
            data: [
              Node<String>(
                id: 'p1',
                label: 'parent',
                type: NodeType.parent,
                children: [
                  Node<String>(id: 'c1', label: 'child', type: NodeType.child),
                ],
              ),
            ],
            mode: ViewMode.tree,
            expandedNodeIds: const {'p1'},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TreeLines), findsWidgets);
  });
}
