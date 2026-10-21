import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

/// `ExpandIconTheme.color` and `expandedColor` colour the factories' chevron,
/// and the factories' grey lives in `color` (#120).
void main() {
  // An expanded Folder holding a collapsed Parent that has a Child.
  List<Node<String>> data() => [
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
            Node<String>(id: 'c', label: 'child', type: NodeType.child),
          ],
        ),
      ],
    ),
  ];

  Future<void> pump(
    WidgetTester tester,
    FlutterFolderViewTheme<String> theme,
  ) async {
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
              theme: theme,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The ARGB colour the [icon] glyph is drawn in on the row labelled [label].
  int glyphColorOn(WidgetTester tester, String label, IconData icon) {
    final rowY = tester.getCenter(find.text(label)).dy;
    final glyph = String.fromCharCode(icon.codePoint);
    final onRow = tester
        .widgetList<RichText>(find.byType(RichText))
        .where((r) => r.text.toPlainText() == glyph)
        .where((r) => (tester.getCenter(find.byWidget(r)).dy - rowY).abs() < 10)
        .toList();
    expect(onRow, hasLength(1), reason: 'one glyph on row "$label"');
    return onRow.single.text.style!.color!.toARGB32();
  }

  FlutterFolderViewTheme<String> recoloured(
    FlutterFolderViewTheme<String> base,
  ) => base.copyWith(
    expandIconTheme: base.expandIconTheme.copyWith(
      color: Colors.red,
      expandedColor: Colors.green,
    ),
  );

  for (final (name, factory, grey) in [
    ('light()', FlutterFolderViewTheme<String>.light, Colors.grey.shade700),
    ('dark()', FlutterFolderViewTheme<String>.dark, Colors.grey.shade400),
  ]) {
    testWidgets('$name draws its chevron in its grey on every row', (
      tester,
    ) async {
      await pump(tester, factory());

      expect(
        glyphColorOn(tester, 'folder', Icons.chevron_right),
        grey.toARGB32(),
      );
      expect(
        glyphColorOn(tester, 'parent', Icons.chevron_right),
        grey.toARGB32(),
      );
    });

    testWidgets('$name: color paints collapsed rows and expandedColor '
        'expanded ones', (tester) async {
      await pump(tester, recoloured(factory()));

      expect(
        glyphColorOn(tester, 'folder', Icons.chevron_right),
        Colors.green.toARGB32(),
      );
      expect(
        glyphColorOn(tester, 'parent', Icons.chevron_right),
        Colors.red.toARGB32(),
      );
    });
  }

  testWidgets('a widget with its own colour keeps it whatever color says', (
    tester,
  ) async {
    final light = FlutterFolderViewTheme<String>.light();
    await pump(
      tester,
      light.copyWith(
        expandIconTheme: light.expandIconTheme.copyWith(
          widget: const Icon(Icons.arrow_right, color: Colors.blue),
          color: Colors.red,
          expandedColor: Colors.green,
        ),
      ),
    );

    expect(
      glyphColorOn(tester, 'folder', Icons.arrow_right),
      Colors.blue.toARGB32(),
    );
    expect(
      glyphColorOn(tester, 'parent', Icons.arrow_right),
      Colors.blue.toARGB32(),
    );
  });
}
