import 'package:flutter/widgets.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_folderview/services/row_metrics.dart';
import 'package:flutter_test/flutter_test.dart';

FlutterFolderViewTheme<String> buildTheme() {
  return const FlutterFolderViewTheme<String>(
    lineTheme: FolderViewLineTheme(lineColor: Color(0xFF000000)),
    scrollbarTheme: FolderViewScrollbarTheme(
      thumbColor: Color(0xFF000000),
      trackColor: Color(0xFF000000),
    ),
    // expand strip = 10 + horizontal padding(2+2) + horizontal margin(1+1) = 16
    expandIconTheme: ExpandIconTheme(
      width: 10,
      padding: EdgeInsets.symmetric(horizontal: 2),
      margin: EdgeInsets.symmetric(horizontal: 1),
    ),
    folderTheme: FolderNodeTheme<String>(width: 20),
    parentTheme: ParentNodeTheme<String>(width: 30),
    childTheme: ChildNodeTheme<String>(width: 40),
  );
}

void main() {
  // TextPainter (used by measureNodeWidth) needs an initialized binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RowMetrics geometry', () {
    final metrics = RowMetrics<String>(theme: buildTheme());

    test('expandStripWidth = width + horizontal padding + horizontal margin',
        () {
      expect(metrics.expandStripWidth, 16);
    });

    test('indentWidth is depth times the expand strip width', () {
      expect(metrics.indentWidth(0), 0);
      expect(metrics.indentWidth(3), 48); // 3 * 16
    });

    test('iconBoxWidth is per-tier width plus horizontal padding and margin',
        () {
      // no padding/margin on the node themes here, so box == width
      expect(metrics.iconBoxWidth(NodeType.folder), 20);
      expect(metrics.iconBoxWidth(NodeType.parent), 30);
      expect(metrics.iconBoxWidth(NodeType.child), 40);
    });
  });

  group('RowMetrics.effectiveTextStyle (measure == render resolution)', () {
    test('falls back to the tier textStyle when no resolver is set', () {
      final theme = buildTheme().copyWith(
        childTheme: const ChildNodeTheme<String>(
          textStyle: TextStyle(fontSize: 22),
        ),
      );
      final metrics = RowMetrics<String>(theme: theme);
      final child =
          Node<String>(id: 'c', label: 'c', type: NodeType.child);
      expect(metrics.effectiveTextStyle(child)?.fontSize, 22);
    });

    test('a textStyleResolver wins over the tier textStyle', () {
      final theme = buildTheme().copyWith(
        childTheme: ChildNodeTheme<String>(
          textStyle: const TextStyle(fontSize: 22),
          textStyleResolver: (n) => const TextStyle(fontSize: 99),
        ),
      );
      final metrics = RowMetrics<String>(theme: theme);
      final child =
          Node<String>(id: 'c', label: 'c', type: NodeType.child);
      // Render uses resolver ?? textStyle; measurement must resolve the same
      // way, so effectiveTextStyle reflects the resolver.
      expect(metrics.effectiveTextStyle(child)?.fontSize, 99);
    });
  });

  group('RowMetrics measurement', () {
    final metrics = RowMetrics<String>(
      theme: buildTheme(),
      baseTextStyle: const TextStyle(fontSize: 14),
    );

    test('increasing depth by one adds exactly one expand strip width', () {
      final node = Node<String>(id: 'n', label: 'hello', type: NodeType.child);
      final w1 = metrics.measureNodeWidth(node, 1);
      final w2 = metrics.measureNodeWidth(node, 2);
      // Only the indent changes with depth — a text-metric-independent invariant.
      expect(w2 - w1, closeTo(metrics.expandStripWidth, 1e-9));
    });

    test('maxWidth reflects the widest node', () {
      final narrow = [
        Node<String>(id: 'a', label: 'i', type: NodeType.child),
      ];
      final wide = [
        Node<String>(id: 'b', label: 'wwwwwwwwww', type: NodeType.child),
      ];
      expect(metrics.maxWidth(wide) > metrics.maxWidth(narrow), isTrue);
    });
  });
}
