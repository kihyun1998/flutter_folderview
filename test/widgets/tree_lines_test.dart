import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_folderview/models/flat_node.dart';
import 'package:flutter_folderview/services/flatten_service.dart';
import 'package:flutter_folderview/widgets/tree_lines.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  FlatNode<String> flat({
    required int depth,
    required bool isLast,
    required bool isRoot,
    required List<bool> ancestors,
  }) {
    // Pack the readable per-depth flags into the bitmask the row now carries.
    var mask = 0;
    for (var d = 0; d < ancestors.length; d++) {
      if (ancestors[d]) mask |= 1 << d;
    }
    return FlatNode<String>(
      node: Node<String>(id: 'n', label: 'n', type: NodeType.parent),
      depth: depth,
      isFirst: false,
      isLast: isLast,
      isRoot: isRoot,
      ancestorIsLastMask: mask,
    );
  }

  // Behaviour net through the public flatten path: builds a real Node tree and
  // asserts the resulting deep row's line geometry. It never names the ancestor
  // representation, so it survives a change to how those flags are stored.
  test('flatten feeds a deep row the right continuation/connector geometry',
      () {
    //   A (folder, depth 0, NOT last — sibling B follows)
    //     P (parent, depth 1, last child of A)
    //       C0 (child, depth 2)   <- inspected
    //       C1 (child, depth 2)
    //   B (folder, depth 0, last)
    // For C0: ancestor A still has a sibling below -> its column-0 guide
    // continues; ancestor P is a last child -> no guide at column 1.
    final data = [
      Node<String>(id: 'A', label: 'A', type: NodeType.folder, children: [
        Node<String>(id: 'P', label: 'P', type: NodeType.parent, children: [
          Node<String>(id: 'C0', label: 'C0', type: NodeType.child),
          Node<String>(id: 'C1', label: 'C1', type: NodeType.child),
        ]),
      ]),
      Node<String>(id: 'B', label: 'B', type: NodeType.folder),
    ];
    final flat = FlattenService.flatten<String>(
      nodes: data,
      expandedNodeIds: const {'A', 'P'},
    );
    final c0 = flat.firstWhere((fn) => fn.node.id == 'C0');

    final plan = TreeLinePlan.forRow(row: c0, lineWidth: 20);
    expect(plan.continuationXs, [10]); // guide continues past A (sibling below)
    expect(plan.connectorX, 30); // parent column: (depth-1)*20 + 10
    expect(plan.connectorIsLast, isFalse); // C0 is not P's last child
    expect(plan.connectorEndX, 40); // depth*20
  });

  test('flattening past FlatNode.maxDepth trips the depth guard', () {
    // A single expanded chain deeper than the bitmask can hold must assert
    // rather than silently overflow the ancestor mask.
    Node<String> chain(int levels) {
      Node<String> node =
          const Node<String>(id: 'leaf', label: 'leaf', type: NodeType.child);
      for (var d = levels - 1; d >= 0; d--) {
        node = Node<String>(
            id: 'n$d', label: 'n$d', type: NodeType.parent, children: [node]);
      }
      return node;
    }

    final levels = FlatNode.maxDepth + 2; // a parent exists at depth maxDepth
    final deep = chain(levels);
    final expanded = {for (var d = 0; d < levels; d++) 'n$d'};

    expect(
      () => FlattenService.flatten<String>(
          nodes: [deep], expandedNodeIds: expanded),
      throwsA(isA<AssertionError>()),
    );
  });

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
