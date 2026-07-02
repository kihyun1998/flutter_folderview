import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Folder 'f' > Parent 'p' > children 'c0','c1'. Folder mode with both
  // containers expanded surfaces both child rows, so selection highlighting
  // can be driven against one child while the sibling stays a control.
  List<Node<String>> selectionData() => [
        Node<String>(
          id: 'f',
          label: 'folder-f',
          type: NodeType.folder,
          children: [
            Node<String>(
              id: 'p',
              label: 'parent-p',
              type: NodeType.parent,
              children: [
                Node<String>(id: 'c0', label: 'child-c0', type: NodeType.child),
                Node<String>(id: 'c1', label: 'child-c1', type: NodeType.child),
              ],
            ),
          ],
        ),
      ];

  // A child renders its label in `selectedTextStyle` when selected, otherwise
  // in `textStyle`. Pinning these to distinct font weights turns "selected" into
  // an observable value on the rendered Text — no reaching into private widgets.
  final theme = FlutterFolderViewTheme<String>.light().copyWith(
    childTheme: const ChildNodeTheme<String>(
      textStyle: TextStyle(fontWeight: FontWeight.normal),
      selectedTextStyle: TextStyle(fontWeight: FontWeight.bold),
    ),
  );

  FontWeight? weightOf(WidgetTester tester, String label) =>
      tester.widget<Text>(find.text(label)).style?.fontWeight;

  // A root Folder wrapping a Parent, plus a second Parent already at the root.
  // Folder mode keeps root Folders/Parents (the folder collapses its inner
  // parent out of view); Tree mode hides Folders and lifts their Parents to the
  // root. So 'folder-row' is folder-mode-only and 'lifted-parent' is
  // tree-mode-only, while 'root-parent' shows in both.
  List<Node<String>> projectionData() => [
        Node<String>(
          id: 'f',
          label: 'folder-row',
          type: NodeType.folder,
          children: [
            Node<String>(
                id: 'pin', label: 'lifted-parent', type: NodeType.parent),
          ],
        ),
        Node<String>(id: 'proot', label: 'root-parent', type: NodeType.parent),
      ];

  Future<void> pumpMode(WidgetTester tester, ViewMode mode) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            height: 400,
            child: FolderView<String>(
              data: projectionData(),
              mode: mode,
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('a child in selectedNodeIds renders selected; siblings do not',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            height: 400,
            child: FolderView<String>(
              data: selectionData(),
              mode: ViewMode.folder,
              expandedNodeIds: const {'f', 'p'},
              selectedNodeIds: const {'c0'},
              theme: theme,
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(weightOf(tester, 'child-c0'), FontWeight.bold); // selected
    expect(weightOf(tester, 'child-c1'), FontWeight.normal); // control
  });

  testWidgets('changing selectedNodeIds moves the highlight and clears the old',
      (tester) async {
    var selected = {'c0'};
    late StateSetter setter;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            height: 400,
            child: StatefulBuilder(builder: (context, setState) {
              setter = setState;
              return FolderView<String>(
                data: selectionData(),
                mode: ViewMode.folder,
                expandedNodeIds: const {'f', 'p'},
                selectedNodeIds: selected,
                theme: theme,
              );
            }),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // Baseline: c0 selected, c1 not.
    expect(weightOf(tester, 'child-c0'), FontWeight.bold);
    expect(weightOf(tester, 'child-c1'), FontWeight.normal);

    // Move selection to the sibling at runtime -> didUpdateWidget re-renders.
    setter(() => selected = {'c1'});
    await tester.pumpAndSettle();

    expect(weightOf(tester, 'child-c1'), FontWeight.bold); // moved here
    expect(weightOf(tester, 'child-c0'), FontWeight.normal); // cleared
  });

  testWidgets('folder and tree modes project the same data to different rows',
      (tester) async {
    await pumpMode(tester, ViewMode.folder);
    // Folder mode: the Folder row shows; its inner Parent is collapsed away.
    expect(find.text('folder-row'), findsOneWidget);
    expect(find.text('lifted-parent'), findsNothing);
    expect(find.text('root-parent'), findsOneWidget);

    await pumpMode(tester, ViewMode.tree);
    // Tree mode: Folders are hidden and their Parents lifted to the root.
    expect(find.text('folder-row'), findsNothing);
    expect(find.text('lifted-parent'), findsOneWidget);
    expect(find.text('root-parent'), findsOneWidget);
  });

  testWidgets('switching mode at runtime re-projects the visible rows',
      (tester) async {
    var mode = ViewMode.folder;
    late StateSetter setter;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            height: 400,
            child: StatefulBuilder(builder: (context, setState) {
              setter = setState;
              return FolderView<String>(data: projectionData(), mode: mode);
            }),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // Starts in folder mode.
    expect(find.text('folder-row'), findsOneWidget);
    expect(find.text('lifted-parent'), findsNothing);

    // Flip to tree mode in place -> the list re-projects, no rebuild from zero.
    setter(() => mode = ViewMode.tree);
    await tester.pumpAndSettle();

    expect(find.text('folder-row'), findsNothing);
    expect(find.text('lifted-parent'), findsOneWidget);
  });
}
