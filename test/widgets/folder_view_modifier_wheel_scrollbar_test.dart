import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

/// Scale Modifier + wheel over the scrollbars (#114).
///
/// While the modifier scroll is blocked, a modifier notch must move no scroll
/// offset anywhere over the view, the scrollbars included, and still propose
/// a Scale. The scrollbars are their own scroll views, so before #114 a notch
/// over the vertical bar both scrolled and proposed.
void main() {
  // 40 Children under one Parent, one with a long label: taller and wider than
  // the 400×160 view, so both scrollbars exist.
  List<Node<String>> data() => [
    Node<String>(
      id: 'p',
      label: 'parent',
      type: NodeType.parent,
      children: [
        for (var i = 0; i < 40; i++)
          Node<String>(
            id: 'c$i',
            label: i == 0 ? 'x' * 300 : 'c$i',
            type: NodeType.child,
          ),
      ],
    ),
  ];

  Future<List<double>> pump(
    WidgetTester tester, {
    bool withHandler = true,
    bool? blockModifierScroll,
  }) async {
    final proposed = <double>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              height: 160,
              child: FolderView<String>(
                data: data(),
                mode: ViewMode.tree,
                expandedNodeIds: const {'p'},
                wheelMotion: null,
                onScaleChanged: withHandler ? proposed.add : null,
                blockModifierScroll: blockModifierScroll,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return proposed;
  }

  /// Every scroll offset in the view: the rows' and both scrollbars'.
  List<double> offsets(WidgetTester tester) => tester
      .stateList<ScrollableState>(
        find.descendant(
          of: find.byType(FolderView<String>),
          matching: find.byType(Scrollable),
        ),
      )
      .map((s) => s.position.pixels)
      .toList();

  Offset overVerticalBar(WidgetTester tester) {
    final view = tester.getRect(find.byType(FolderView<String>));
    return Offset(view.right - 3, view.center.dy);
  }

  Offset overHorizontalBar(WidgetTester tester) {
    final view = tester.getRect(find.byType(FolderView<String>));
    return Offset(view.center.dx, view.bottom - 3);
  }

  Future<void> wheel(
    WidgetTester tester,
    Offset at,
    Offset delta, {
    required bool modifier,
  }) async {
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(pointer.hover(at));
    if (modifier) await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendEventToBinding(pointer.scroll(delta));
    await tester.pumpAndSettle();
    if (modifier) await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  }

  // On Windows the Scale Modifier is Ctrl (see isScaleModifierPressed).
  void winTest(String description, WidgetTesterCallback body) => testWidgets(
    description,
    body,
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );

  group('while the modifier scroll is blocked', () {
    winTest('over the rows a modifier notch proposes and does not scroll', (
      tester,
    ) async {
      final proposed = await pump(tester);
      final view = tester.getRect(find.byType(FolderView<String>));

      await wheel(tester, view.center, const Offset(0, 300), modifier: true);
      expect(offsets(tester).every((o) => o == 0), isTrue);
      expect(proposed, hasLength(1));
    });

    winTest('over the vertical scrollbar a modifier notch proposes and '
        'does not scroll', (tester) async {
      final proposed = await pump(tester);

      await wheel(
        tester,
        overVerticalBar(tester),
        const Offset(0, 300),
        modifier: true,
      );
      expect(offsets(tester), everyElement(0));
      expect(proposed, hasLength(1));
    });

    winTest('over the horizontal scrollbar a sideways modifier notch '
        'proposes and does not scroll', (tester) async {
      final proposed = await pump(tester);

      await wheel(
        tester,
        overHorizontalBar(tester),
        const Offset(300, 0),
        modifier: true,
      );
      expect(offsets(tester), everyElement(0));
      expect(proposed, hasLength(1));
    });

    winTest('blockModifierScroll: true without a handler blocks the '
        'scrollbar too and proposes nothing', (tester) async {
      final proposed = await pump(
        tester,
        withHandler: false,
        blockModifierScroll: true,
      );

      await wheel(
        tester,
        overVerticalBar(tester),
        const Offset(0, 300),
        modifier: true,
      );
      expect(offsets(tester), everyElement(0));
      expect(proposed, isEmpty);
    });
  });

  winTest('with blockModifierScroll: false a modifier notch over the '
      'vertical scrollbar scrolls and proposes nothing', (tester) async {
    final proposed = await pump(tester, blockModifierScroll: false);

    await wheel(
      tester,
      overVerticalBar(tester),
      const Offset(0, 300),
      modifier: true,
    );
    expect(offsets(tester).any((o) => o > 0), isTrue);
    expect(proposed, isEmpty);
  });

  winTest('without the modifier a notch over the vertical scrollbar '
      'still scrolls and proposes nothing', (tester) async {
    final proposed = await pump(tester);

    await wheel(
      tester,
      overVerticalBar(tester),
      const Offset(0, 300),
      modifier: false,
    );
    expect(offsets(tester).any((o) => o > 0), isTrue);
    expect(proposed, isEmpty);
  });

  winTest('dragging the vertical thumb while holding the modifier still '
      'scrolls', (tester) async {
    await pump(tester);
    final at = overVerticalBar(tester);
    final view = tester.getRect(find.byType(FolderView<String>));
    final top = Offset(at.dx, view.top + 10);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: top);
    await tester.pumpAndSettle();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await mouse.down(top);
    for (var i = 0; i < 5; i++) {
      await mouse.moveBy(const Offset(0, 10));
      await tester.pump();
    }
    await mouse.up();
    await tester.pumpAndSettle();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

    expect(offsets(tester).any((o) => o > 0), isTrue);
  });
}
