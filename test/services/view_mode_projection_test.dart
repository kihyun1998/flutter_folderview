import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_folderview/services/view_mode_projection.dart';
import 'package:flutter_test/flutter_test.dart';

// Expected outputs come from the CONTEXT.md domain rules for View Mode, not from
// the current implementation:
//   - folder mode: root shows Folders + Parents; a root-level Child is dropped.
//   - tree mode: Folders are hidden and their Parents are lifted (recursively)
//     to the root; root-level Children never appear.
void main() {
  Node<String> n(String id, NodeType type,
      [List<Node<String>> children = const []]) {
    return Node<String>(id: id, label: id, type: type, children: children);
  }

  List<String> ids(List<Node<String>> nodes) => nodes.map((e) => e.id).toList();

  group('ViewModeProjection.project — folder mode', () {
    test('keeps Folders and Parents at the root and drops a root-level Child',
        () {
      final data = [
        n('F', NodeType.folder),
        n('P', NodeType.parent),
        n('C', NodeType.child),
      ];
      final result = ViewModeProjection.project(
        nodes: data,
        mode: ViewMode.folder,
      );
      expect(ids(result), ['F', 'P']);
    });
  });

  group('ViewModeProjection.project — tree mode', () {
    test('lifts Parents out of Folders to the root, preserving order', () {
      final data = [
        n('F', NodeType.folder,
            [n('P1', NodeType.parent), n('P2', NodeType.parent)]),
        n('P3', NodeType.parent),
      ];
      final result = ViewModeProjection.project(
        nodes: data,
        mode: ViewMode.tree,
      );
      expect(ids(result), ['P1', 'P2', 'P3']);
    });

    test('descends recursively through nested Folder-in-Folder', () {
      final data = [
        n('F', NodeType.folder, [
          n('G', NodeType.folder, [n('P', NodeType.parent)]),
        ]),
      ];
      final result = ViewModeProjection.project(
        nodes: data,
        mode: ViewMode.tree,
      );
      expect(ids(result), ['P']);
    });

    test('a Folder with no Parent descendants yields nothing', () {
      final data = [
        n('F', NodeType.folder, [n('C', NodeType.child)]),
      ];
      final result = ViewModeProjection.project(
        nodes: data,
        mode: ViewMode.tree,
      );
      expect(result, isEmpty);
    });
  });
}
