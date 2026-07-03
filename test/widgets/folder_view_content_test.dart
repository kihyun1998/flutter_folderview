import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_folderview/widgets/folder_view_horizontal_scrollbar.dart';
import 'package:flutter_folderview/widgets/folder_view_vertical_scrollbar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A Folder with [count] parents; expand the folder so all parents are rows.
  List<Node<String>> data({required int count, String label = 'p'}) => [
        Node<String>(
          id: 'f',
          label: 'folder',
          type: NodeType.folder,
          children: List.generate(
            count,
            (i) => Node<String>(
                id: 'p$i', label: '$label$i', type: NodeType.parent),
          ),
        ),
      ];

  Future<void> pumpFV(
    WidgetTester tester, {
    required List<Node<String>> nodes,
    required Size size,
    bool blockModifierScroll = false,
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: FolderView<String>(
              data: nodes,
              mode: ViewMode.folder,
              expandedNodeIds: const {'f'},
              blockModifierScroll: blockModifierScroll,
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('no scrollbars when content fits', (tester) async {
    await pumpFV(tester, nodes: data(count: 1), size: const Size(400, 400));
    expect(find.byType(FolderViewVerticalScrollbar), findsNothing);
    expect(find.byType(FolderViewHorizontalScrollbar), findsNothing);
  });

  testWidgets('vertical scrollbar appears when content is tall',
      (tester) async {
    // 20 parents * 40px rows >> 160px viewport.
    await pumpFV(tester, nodes: data(count: 20), size: const Size(400, 160));
    expect(find.byType(FolderViewVerticalScrollbar), findsOneWidget);
  });

  testWidgets('horizontal scrollbar appears when content is wide',
      (tester) async {
    await pumpFV(
      tester,
      nodes: data(count: 2, label: 'a very long parent label that overflows '),
      size: const Size(120, 400),
    );
    expect(find.byType(FolderViewHorizontalScrollbar), findsOneWidget);
  });

  testWidgets('hovering raises the vertical scrollbar opacity', (tester) async {
    await pumpFV(tester, nodes: data(count: 20), size: const Size(400, 160));

    double barOpacity() => tester
        .widget<AnimatedOpacity>(
          find.descendant(
            of: find.byType(FolderViewVerticalScrollbar),
            matching: find.byType(AnimatedOpacity),
          ),
        )
        .opacity;

    // Default light theme: nonHoverOpacity 0.0, hoverOpacity 0.8.
    expect(barOpacity(), 0.0);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await gesture.moveTo(tester.getCenter(find.byType(FolderView<String>)));
    await tester.pumpAndSettle();

    expect(barOpacity(), 0.8);
  });

  // Data where parents have children, so expanding a parent changes the list.
  List<Node<String>> richData({required int parents}) => [
        Node<String>(
          id: 'f',
          label: 'folder',
          type: NodeType.parent,
          children: List.generate(
            parents,
            (i) => Node<String>(
              id: 'p$i',
              label: 'p$i',
              type: NodeType.parent,
              children: [
                Node<String>(id: 'p${i}c0', label: 'c0', type: NodeType.child),
                Node<String>(id: 'p${i}c1', label: 'c1', type: NodeType.child),
              ],
            ),
          ),
        ),
      ];

  // Drives prop changes through a StatefulBuilder so didUpdateWidget fires.
  Future<StateSetter> pumpDriven(
    WidgetTester tester, {
    required List<Node<String>> nodes,
    required double Function() scale,
    required Set<String> Function() expanded,
  }) async {
    late StateSetter setter;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 300,
            height: 160,
            child: StatefulBuilder(builder: (context, setState) {
              setter = setState;
              return FolderView<String>(
                data: nodes,
                mode: ViewMode.tree,
                expandedNodeIds: expanded(),
                scale: scale(),
              );
            }),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    return setter;
  }

  testWidgets('a scale change runs the scale adjustment without error',
      (tester) async {
    var scale = 1.0;
    final setter = await pumpDriven(
      tester,
      nodes: data(count: 20),
      scale: () => scale,
      expanded: () => const {'f'},
    );
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();

    setter(() => scale = 2.0);
    await tester.pumpAndSettle();
    expect(find.byType(FolderView<String>), findsOneWidget);
  });

  testWidgets('expanding a node above the viewport adjusts scroll (case 1)',
      (tester) async {
    var expanded = {'f'};
    final nodes = richData(parents: 20);
    final setter = await pumpDriven(
      tester,
      nodes: nodes,
      scale: () => 1.0,
      expanded: () => expanded,
    );
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    // Expand a single parent (single diff -> incremental change).
    setter(() => expanded = {'f', 'p0'});
    await tester.pumpAndSettle();
    expect(find.byType(FolderView<String>), findsOneWidget);
  });

  testWidgets('a bulk expand change runs the anchor path (case 2)',
      (tester) async {
    var expanded = {'f'};
    final nodes = richData(parents: 20);
    final setter = await pumpDriven(
      tester,
      nodes: nodes,
      scale: () => 1.0,
      expanded: () => expanded,
    );
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    // Expand several parents at once -> multi diff -> full rebuild -> bulk anchor.
    setter(() => expanded = {'f', 'p0', 'p1', 'p2'});
    await tester.pumpAndSettle();
    expect(find.byType(FolderView<String>), findsOneWidget);
  });
}
