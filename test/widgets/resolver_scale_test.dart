import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_folderview/widgets/folder_view_content.dart';
import 'package:flutter_test/flutter_test.dart';

/// A style a resolver returns is scaled by the same rule as the field it
/// stands in for (#127).
void main() {
  // On every tier, a node whose resolver returns a style (`…r`) and a sibling
  // whose resolver returns null and so falls back to `textStyle` (`…f`).
  List<Node<String>> data() => [
    for (final f in ['fr', 'ff'])
      Node<String>(
        id: f,
        label: 'folder $f',
        type: NodeType.folder,
        children: [
          if (f == 'fr')
            for (final p in ['pr', 'pf'])
              Node<String>(
                id: p,
                label: 'parent $p',
                type: NodeType.parent,
                children: [
                  if (p == 'pr')
                    for (final c in ['cr', 'cf', 'cs', 'cb'])
                      Node<String>(
                        id: c,
                        label: 'child $c',
                        type: NodeType.child,
                      ),
                ],
              ),
        ],
      ),
  ];

  /// Resolves 16 px for an id ending in `r`, and null otherwise.
  TextStyle? resolved(Node<String> node) =>
      node.id.endsWith('r') ? const TextStyle(fontSize: 16) : null;

  FlutterFolderViewTheme<String> theme() {
    final light = FlutterFolderViewTheme<String>.light();
    const field = TextStyle(fontSize: 16);
    return light.copyWith(
      folderTheme: light.folderTheme.copyWith(
        textStyle: field,
        textStyleResolver: resolved,
      ),
      parentTheme: light.parentTheme.copyWith(
        textStyle: field,
        textStyleResolver: resolved,
      ),
      childTheme: light.childTheme.copyWith(
        textStyle: field,
        textStyleResolver: resolved,
        // `cs` gets a sized selected style; `cb` one with no size.
        selectedTextStyleResolver: (node) => switch (node.id) {
          'cs' => const TextStyle(fontSize: 20),
          'cb' => const TextStyle(fontWeight: FontWeight.bold),
          _ => null,
        },
      ),
    );
  }

  Future<void> pump(WidgetTester tester, {required double scale}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 600,
            child: FolderView<String>(
              data: data(),
              mode: ViewMode.folder,
              expandedNodeIds: const {'fr', 'pr'},
              selectedNodeIds: const {'cs', 'cb'},
              scale: scale,
              theme: theme(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The font size the label [text] is drawn at.
  double sizeOf(WidgetTester tester, String text) => tester
      .widget<RichText>(
        find.descendant(of: find.text(text), matching: find.byType(RichText)),
      )
      .text
      .style!
      .fontSize!;

  for (final (tier, resolvedLabel, fallbackLabel) in [
    ('Folder', 'folder fr', 'folder ff'),
    ('Parent', 'parent pr', 'parent pf'),
    ('Child', 'child cr', 'child cf'),
  ]) {
    testWidgets('$tier: at Scale 2 a resolved style is scaled like textStyle', (
      tester,
    ) async {
      await pump(tester, scale: 2);

      expect(sizeOf(tester, resolvedLabel), 32);
      // A null from the resolver still falls back to the scaled field.
      expect(sizeOf(tester, fallbackLabel), 32);
    });
  }

  testWidgets('at Scale 2 a resolved selected style is scaled', (tester) async {
    await pump(tester, scale: 2);

    expect(sizeOf(tester, 'child cs'), 40);
    // With no size of its own, it keeps the label's scaled size.
    expect(sizeOf(tester, 'child cb'), 32);
  });

  testWidgets('at Scale 1 every label is drawn as resolved', (tester) async {
    await pump(tester, scale: 1);

    expect(sizeOf(tester, 'folder fr'), 16);
    expect(sizeOf(tester, 'child cs'), 20);
    expect(sizeOf(tester, 'child cb'), 16);
  });

  testWidgets('at Scale 2 a resolved label is measured at its scaled size', (
    tester,
  ) async {
    await pump(tester, scale: 2);

    final content = tester.widget<FolderViewContent<String>>(
      find.byType(FolderViewContent<String>),
    );
    final label = tester.getSize(find.text('child cr')).width;
    expect(label, greaterThan(0));
    final labelRight =
        tester.getTopRight(find.text('child cr')).dx -
        tester.getTopLeft(find.byType(FolderViewContent<String>)).dx;
    expect(content.contentWidth, greaterThanOrEqualTo(labelRight));
  });

  group('the tier themes scale their resolvers', () {
    const defaultFontSize = 14.0;
    final node = Node<String>(id: 'r', label: 'r', type: NodeType.child);

    test('scale(1.0) keeps the theme and its resolver', () {
      final t = theme().childTheme;
      expect(
        identical(t.scale(1.0, defaultFontSize: defaultFontSize), t),
        isTrue,
      );
    });

    test('two scalings multiply', () {
      final t = theme().childTheme
          .scale(2, defaultFontSize: defaultFontSize)
          .scale(1.5, defaultFontSize: defaultFontSize);
      expect(t.textStyleResolver!(node)!.fontSize, 48);
    });
  });
}
