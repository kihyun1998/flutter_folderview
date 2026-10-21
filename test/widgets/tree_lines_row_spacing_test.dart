import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_folderview/widgets/tree_lines.dart';
import 'package:flutter_test/flutter_test.dart';

/// The connector stub and a last child's vertical end sit at the vertical
/// centre of the row as laid out, which includes `rowSpacing` (#118).
void main() {
  // A Folder holding Parents p0 and p1, so p0 has a sibling below and p1 is
  // the last child.
  List<Node<String>> data() => [
    Node<String>(
      id: 'f',
      label: 'folder',
      type: NodeType.folder,
      children: [
        Node<String>(id: 'p0', label: 'parent-0', type: NodeType.parent),
        Node<String>(id: 'p1', label: 'parent-1', type: NodeType.parent),
      ],
    ),
  ];

  Future<void> pump(WidgetTester tester, {required double rowSpacing}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 400,
            child: FolderView<String>(
              data: data(),
              mode: ViewMode.folder,
              expandedNodeIds: const {'f'},
              theme: _theme(rowSpacing),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The lines [label]'s row paints, in its own coordinates, and the label's
  /// vertical centre in the same coordinates.
  ({List<(Offset, Offset)> lines, double labelCentre}) rowOf(
    WidgetTester tester,
    String label,
  ) {
    final paintFinder = find.descendant(
      of: find
          .ancestor(of: find.text(label), matching: find.byType(Stack))
          .first,
      matching: find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is TreeLinesPainter,
      ),
    );
    final painter =
        tester.widget<CustomPaint>(paintFinder).painter! as TreeLinesPainter;
    final box = tester.renderObject<RenderBox>(paintFinder);
    final canvas = _LineRecorder();
    painter.paint(canvas, box.size);
    final origin = box.localToGlobal(Offset.zero);
    return (
      lines: canvas.lines,
      labelCentre: tester.getCenter(find.text(label)).dy - origin.dy,
    );
  }

  for (final spacing in [0.0, 10.0]) {
    testWidgets('rowSpacing $spacing: the connector stub is level with the '
        'label centre', (tester) async {
      await pump(tester, rowSpacing: spacing);
      final row = rowOf(tester, 'parent-0');

      final stub = row.lines.singleWhere((l) => l.$1.dy == l.$2.dy);
      expect(stub.$1.dy, closeTo(row.labelCentre, 0.01));
      expect(stub.$1.dy, closeTo((40 + spacing) / 2, 0.01));
    });

    testWidgets('rowSpacing $spacing: a last child\'s vertical line ends at '
        'the label centre', (tester) async {
      await pump(tester, rowSpacing: spacing);
      final row = rowOf(tester, 'parent-1');

      final vertical = row.lines.singleWhere(
        (l) => l.$1.dx == l.$2.dx && l.$1.dy == 0,
      );
      expect(vertical.$2.dy, closeTo(row.labelCentre, 0.01));
    });
  }
}

/// The light theme at a 40 px `rowHeight` and [rowSpacing], with connector
/// lines.
FlutterFolderViewTheme<String> _theme(double rowSpacing) {
  final light = FlutterFolderViewTheme<String>.light();
  return light.copyWith(
    rowHeight: 40,
    rowSpacing: rowSpacing,
    lineTheme: light.lineTheme.copyWith(lineStyle: LineStyle.connector),
  );
}

/// A canvas that records `drawLine` calls and ignores everything else.
class _LineRecorder implements Canvas {
  final lines = <(Offset, Offset)>[];

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) => lines.add((p1, p2));

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
