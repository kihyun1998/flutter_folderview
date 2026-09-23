import 'package:example/app/tree_generator.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/shell_harness.dart';

Finder _row(String label) => find.descendant(
  of: find.byType(FolderView<String>),
  matching: find.text(label),
);

void main() {
  group('generateTree', () {
    test('builds Folder → Parent → Child in the requested counts', () {
      final tree = generateTree(
        folders: 2,
        parentsPerFolder: 3,
        childrenPerParent: 4,
      );

      expect(tree, hasLength(2));
      for (final folder in tree) {
        expect(folder.type, NodeType.folder);
        expect(folder.children, hasLength(3));
        for (final parent in folder.children) {
          expect(parent.type, NodeType.parent);
          expect(parent.children, hasLength(4));
          for (final child in parent.children) {
            expect(child.type, NodeType.child);
            expect(child.children, isEmpty);
          }
        }
      }
    });

    test('gives every node a distinct id', () {
      final ids = <String>[];
      void walk(List<Node<String>> nodes) {
        for (final n in nodes) {
          ids.add(n.id);
          walk(n.children);
        }
      }

      walk(generateTree(folders: 3, parentsPerFolder: 2, childrenPerParent: 5));
      expect(ids.toSet(), hasLength(ids.length));
      expect(ids, hasLength(3 + 3 * 2 + 3 * 2 * 5));
    });
  });

  group('Every setting: Data', () {
    testWidgets('generated data reaches the FolderView in the chosen shape', (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'Data');

      await setSlider(tester, 'folderCount', 2);
      await setSlider(tester, 'parentsPerFolder', 3);
      await setSlider(tester, 'childrenPerParent', 4);
      await chooseDropdown(tester, 'FolderView.data', 'Generated');

      final data = renderedFolderView(tester).data;
      expect(data, hasLength(2));
      expect(data.map((f) => f.children.length), everyElement(3));
      expect(
        data.expand((f) => f.children).map((p) => p.children.length),
        everyElement(4),
      );
      expect(_row('Theme System Architecture'), findsNothing);
    });

    testWidgets('changing the data keeps only ids that exist in it expanded', (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'Data');

      await chooseDropdown(tester, 'FolderView.data', 'Generated');

      final view = renderedFolderView(tester);
      final ids = <String>{};
      void walk(List<Node<String>> nodes) {
        for (final n in nodes) {
          ids.add(n.id);
          walk(n.children);
        }
      }

      walk(view.data);
      expect(view.expandedNodeIds, isNotNull);
      expect(view.expandedNodeIds!.difference(ids), isEmpty);
    });

    testWidgets('switching back to demo restores the demo tree', (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'Data');

      await chooseDropdown(tester, 'FolderView.data', 'Generated');
      await chooseDropdown(tester, 'FolderView.data', 'Demo');

      expect(_row('Theme System Architecture'), findsOneWidget);
    });
  });

  group('Every setting: View Mode', () {
    testWidgets('starts in Folder Mode, with Folders rendered', (tester) async {
      await pumpShell(tester);

      expect(renderedFolderView(tester).mode, ViewMode.folder);
      expect(_row('Theme System Architecture'), findsOneWidget);
    });

    testWidgets('Tree Mode hides Folders and lifts Parents to the root', (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'View Mode');

      await chooseDropdown(tester, 'FolderView.mode', 'tree');

      expect(renderedFolderView(tester).mode, ViewMode.tree);
      final data = renderedFolderView(tester).data;
      final folderLabels = data
          .where((n) => n.type == NodeType.folder)
          .map((n) => n.label);
      final parentLabels = data
          .where((n) => n.type == NodeType.folder)
          .expand((f) => f.children)
          .where((n) => n.type == NodeType.parent)
          .map((n) => n.label);
      for (final label in folderLabels) {
        expect(_row(label), findsNothing, reason: 'Folder "$label"');
      }
      for (final label in parentLabels) {
        expect(_row(label), findsWidgets, reason: 'Parent "$label"');
      }
    });
  });
}
