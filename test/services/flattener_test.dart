import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_folderview/services/flattener.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Folder mode: root Folder f1 with two Parents, each with children.
  List<Node<String>> buildData() => [
        Node<String>(
          id: 'f1',
          label: 'f1',
          type: NodeType.folder,
          children: [
            Node<String>(
                id: 'p1',
                label: 'p1',
                type: NodeType.parent,
                children: [
                  Node<String>(id: 'c1', label: 'c1', type: NodeType.child),
                  Node<String>(id: 'c2', label: 'c2', type: NodeType.child),
                ]),
            Node<String>(
                id: 'p2',
                label: 'p2',
                type: NodeType.parent,
                children: [
                  Node<String>(id: 'c3', label: 'c3', type: NodeType.child),
                ]),
          ],
        ),
      ];

  List<String> ids(FlattenResult<String> r) =>
      r.list.map((e) => e.node.id).toList();

  group('Flattener — full rebuild & cache', () {
    test('first update is a full rebuild with no change metadata', () {
      final data = buildData();
      final f = Flattener<String>();
      final r =
          f.update(data: data, mode: ViewMode.folder, expandedIds: {'f1'});
      expect(ids(r), ['f1', 'p1', 'p2']);
      expect(r.change, isNull);
    });

    test('identical inputs return the cached list with no change', () {
      final data = buildData();
      final f = Flattener<String>();
      final first =
          f.update(data: data, mode: ViewMode.folder, expandedIds: {'f1'});
      final second =
          f.update(data: data, mode: ViewMode.folder, expandedIds: {'f1'});
      expect(identical(second.list, first.list), isTrue);
      expect(second.change, isNull);
    });

    test('a mode change forces a full rebuild', () {
      final data = buildData();
      final f = Flattener<String>();
      f.update(data: data, mode: ViewMode.folder, expandedIds: {'f1'});
      final r = f.update(data: data, mode: ViewMode.tree, expandedIds: {'f1'});
      // Tree mode lifts Parents to root (Folder hidden).
      expect(ids(r), ['p1', 'p2']);
      expect(r.change, isNull);
    });
  });

  group('Flattener — incremental vs fallback', () {
    test('expanding one node inserts its children incrementally', () {
      final data = buildData();
      final f = Flattener<String>();
      f.update(data: data, mode: ViewMode.folder, expandedIds: {'f1'});
      final r = f
          .update(data: data, mode: ViewMode.folder, expandedIds: {'f1', 'p1'});
      expect(ids(r), ['f1', 'p1', 'c1', 'c2', 'p2']);
      expect(r.change, isNotNull);
      expect(r.change!.index, 1); // p1's position
      expect(r.change!.deltaItems, 2); // c1, c2 inserted
    });

    test('collapsing one node removes its descendants incrementally', () {
      final data = buildData();
      final f = Flattener<String>();
      f.update(data: data, mode: ViewMode.folder, expandedIds: {'f1', 'p1'});
      final r =
          f.update(data: data, mode: ViewMode.folder, expandedIds: {'f1'});
      expect(ids(r), ['f1', 'p1', 'p2']);
      expect(r.change, isNotNull);
      expect(r.change!.index, 1);
      expect(r.change!.deltaItems, -2);
    });

    test('a multi-node diff falls back to a full rebuild (no change)', () {
      final data = buildData();
      final f = Flattener<String>();
      f.update(data: data, mode: ViewMode.folder, expandedIds: {'f1'});
      // Two nodes newly expanded at once -> not a single diff.
      final r = f.update(
          data: data, mode: ViewMode.folder, expandedIds: {'f1', 'p1', 'p2'});
      expect(ids(r), ['f1', 'p1', 'c1', 'c2', 'p2', 'c3']);
      expect(r.change, isNull);
    });

    test('a sequence of single-node toggles stays correct across updates', () {
      // Drives several consecutive incremental updates so any corruption from
      // reusing/aliasing the flat list across mutations would surface as wrong
      // rows or a wrong change delta on a later step.
      final data = buildData();
      final f = Flattener<String>();
      f.update(data: data, mode: ViewMode.folder, expandedIds: {'f1'});

      final e1 = f
          .update(data: data, mode: ViewMode.folder, expandedIds: {'f1', 'p1'});
      expect(ids(e1), ['f1', 'p1', 'c1', 'c2', 'p2']);
      expect(e1.change!.deltaItems, 2);

      final c1 =
          f.update(data: data, mode: ViewMode.folder, expandedIds: {'f1'});
      expect(ids(c1), ['f1', 'p1', 'p2']);
      expect(c1.change!.deltaItems, -2);

      final e2 = f
          .update(data: data, mode: ViewMode.folder, expandedIds: {'f1', 'p2'});
      expect(ids(e2), ['f1', 'p1', 'p2', 'c3']);
      expect(e2.change!.index, 2); // p2's position
      expect(e2.change!.deltaItems, 1);

      final e3 = f.update(
          data: data, mode: ViewMode.folder, expandedIds: {'f1', 'p1', 'p2'});
      expect(ids(e3), ['f1', 'p1', 'c1', 'c2', 'p2', 'c3']);
      expect(e3.change!.index, 1); // p1's position
      expect(e3.change!.deltaItems, 2);
    });
  });
}
