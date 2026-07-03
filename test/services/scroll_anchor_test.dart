import 'package:flutter_folderview/models/flat_node.dart';
import 'package:flutter_folderview/models/node.dart';
import 'package:flutter_folderview/services/flattener.dart';
import 'package:flutter_folderview/services/scroll_anchor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  FlatNode<String> fn(String id) => FlatNode<String>(
        node: Node<String>(id: id, label: id, type: NodeType.parent),
        depth: 0,
        isFirst: false,
        isLast: false,
        isRoot: true,
        ancestorIsLastMask: 0,
      );

  group('ScrollAnchor.verticalOffsetForFlattenChange', () {
    test('a change above the viewport shifts the offset by the row delta', () {
      // Node 0 expanded (+2 rows) while scrolled to offset 200; the change is
      // above the top, so the viewport must shift down by 2 * itemExtent.
      final offset = ScrollAnchor.verticalOffsetForFlattenChange(
        change: const FlattenChange(index: 0, deltaItems: 2),
        currentOffset: 200,
        itemExtent: 40,
        topPadding: 0,
        minScrollExtent: 0,
        maxScrollExtent: 1000,
      );
      expect(offset, 280);
    });

    test('a change at/below the viewport top needs no adjustment', () {
      final offset = ScrollAnchor.verticalOffsetForFlattenChange(
        change: const FlattenChange(index: 10, deltaItems: 2),
        currentOffset: 40,
        itemExtent: 40,
        topPadding: 0,
        minScrollExtent: 0,
        maxScrollExtent: 1000,
      );
      expect(offset, isNull);
    });
  });

  group('ScrollAnchor.offsetsForScaleChange', () {
    test('preserves the top fractional node across an item-extent change', () {
      final r = ScrollAnchor.offsetsForScaleChange(
        currentVerticalOffset: 100,
        oldItemExtent: 40,
        newItemExtent: 80,
        oldTopPadding: 0,
        newTopPadding: 0,
        newContentHeight: 2000,
        viewportHeight: 400,
        currentHorizontalOffset: 50,
        oldContentWidth: 100,
        newContentWidth: 200,
        hMinScrollExtent: 0,
        hMaxScrollExtent: 1000,
      );
      // topFractionalIndex = (100-0)/40 = 2.5; new = 2.5 * 80 = 200
      expect(r.vertical, 200);
      // horizontal ratio = 200/100 = 2; 50 * 2 = 100
      expect(r.horizontal, 100);
    });
  });

  group('ScrollAnchor.verticalOffsetForBulkChange', () {
    test('anchors to the nearest surviving ancestor after collapseAll', () {
      final oldList = [fn('a'), fn('b'), fn('c'), fn('d')];
      final newList = [fn('a')]; // b,c,d removed
      final offset = ScrollAnchor.verticalOffsetForBulkChange(
        oldList: oldList,
        newList: newList,
        currentOffset: 80, // top index 2 (node c), gone -> fall back to 'a'
        itemExtent: 40,
        topPadding: 0,
        newContentHeight: 40,
        viewportHeight: 400,
      );
      expect(offset, 0);
    });
  });
}
