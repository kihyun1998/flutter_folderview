import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

/// The row card's presentation and behaviour, which used to be frozen at
/// `just_tooltip`'s defaults because the wrapper passed nothing but `anchor`
/// and a bare theme.
///
/// ONE hover per `testWidgets`: the `just_tooltip` registry is a package-level
/// singleton and suppresses later tooltips in the same test.
void main() {
  List<Node<String>> data() => [
        Node<String>(
          id: 'f',
          label: 'folder-f',
          type: NodeType.folder,
          children: [
            Node<String>(id: 'p', label: 'parent-p', type: NodeType.parent),
          ],
        ),
      ];

  Future<void> pump(WidgetTester tester, {RowTooltipTheme? rowTooltipTheme}) {
    return tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 500,
            height: 400,
            child: FolderView<String>(
              data: data(),
              mode: ViewMode.folder,
              expandedNodeIds: const {'f'},
              rowTooltipTheme: rowTooltipTheme,
              // Only the Folder row gets a card. The card is drawn over the
              // row beneath it, so if that row had one too, moving the pointer
              // onto the card would raise the neighbour's card and every
              // assertion below would read `true` regardless of `interactive`.
              rowTooltipBuilder: (context, node) => node.id == 'f'
                  ? const SizedBox(key: Key('card'), width: 120, height: 60)
                  : null,
            ),
          ),
        ),
      ),
    ));
  }

  Future<TestGesture> mouse(WidgetTester tester) async {
    final g = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await g.addPointer(location: const Offset(495, 395));
    addTearDown(g.removePointer);
    await tester.pump();
    return g;
  }

  bool shown() => find.byKey(const Key('card')).evaluate().isNotEmpty;

  testWidgets('unset: the card appears immediately on hover', (tester) async {
    await pump(tester);
    final row = tester.getRect(find.text('folder-f'));
    final g = await mouse(tester);
    await g.moveTo(Offset(300, row.center.dy));
    await tester.pumpAndSettle();

    expect(shown(), isTrue);
  });

  testWidgets('unset: the card is interactive — the pointer may enter it',
      (tester) async {
    await pump(tester);
    final row = tester.getRect(find.text('folder-f'));
    final g = await mouse(tester);
    await g.moveTo(Offset(300, row.center.dy));
    await tester.pumpAndSettle();

    await g.moveTo(tester.getRect(find.byKey(const Key('card'))).center);
    await tester.pumpAndSettle();

    expect(shown(), isTrue,
        reason: 'a card holds widgets the user may want to reach');
  });

  testWidgets('interactive: false — the card leaves with the pointer',
      (tester) async {
    await pump(
      tester,
      rowTooltipTheme: const RowTooltipTheme(interactive: false),
    );
    final row = tester.getRect(find.text('folder-f'));
    final g = await mouse(tester);
    await g.moveTo(Offset(300, row.center.dy));
    await tester.pumpAndSettle();
    final card = tester.getRect(find.byKey(const Key('card')));

    // Onto the card, which no longer holds the tooltip open.
    await g.moveTo(card.center);
    await tester.pumpAndSettle();

    expect(shown(), isFalse);
  });

  testWidgets('waitDuration delays the card', (tester) async {
    await pump(
      tester,
      rowTooltipTheme: const RowTooltipTheme(
        waitDuration: Duration(milliseconds: 300),
      ),
    );
    final row = tester.getRect(find.text('folder-f'));
    final g = await mouse(tester);
    await g.moveTo(Offset(300, row.center.dy));

    await tester.pump(const Duration(milliseconds: 100));
    expect(shown(), isFalse, reason: 'still inside the wait');

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(shown(), isTrue);
  });

  // The tooltip pads its content with `surface.padding`. Comparing the card's
  // rect to that Padding's rect is what tells chrome from no chrome — the
  // card's own size never changes, so asserting on it proves nothing.
  Rect surfaceBoxOf(WidgetTester tester) => tester.getRect(find
      .ancestor(
        of: find.byKey(const Key('card')),
        matching: find.byType(Padding),
      )
      .first);

  testWidgets('unset: the tooltip adds no surface around the card',
      (tester) async {
    await pump(tester);
    final row = tester.getRect(find.text('folder-f'));
    final g = await mouse(tester);
    await g.moveTo(Offset(300, row.center.dy));
    await tester.pumpAndSettle();

    final card = tester.getRect(find.byKey(const Key('card')));
    expect(surfaceBoxOf(tester).size, card.size,
        reason: 'bare(): the tooltip is exactly the card');
  });

  testWidgets('a surface gives the card padding back', (tester) async {
    await pump(
      tester,
      rowTooltipTheme: const RowTooltipTheme(
        surface: JustTooltipTheme(padding: EdgeInsets.all(10)),
      ),
    );
    final row = tester.getRect(find.text('folder-f'));
    final g = await mouse(tester);
    await g.moveTo(Offset(300, row.center.dy));
    await tester.pumpAndSettle();

    final card = tester.getRect(find.byKey(const Key('card')));
    expect(surfaceBoxOf(tester).size, Size(card.width + 20, card.height + 20),
        reason: 'a builder returning bare content can ask for chrome');
  });
}
