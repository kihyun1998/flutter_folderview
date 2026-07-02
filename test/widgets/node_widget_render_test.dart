import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_folderview/models/flat_node.dart';
import 'package:flutter_folderview/widgets/child_node_renderer.dart';
import 'package:flutter_folderview/widgets/expandable_node_renderer.dart';
import 'package:flutter_folderview/widgets/node_widget.dart';
import 'package:flutter_test/flutter_test.dart';

// Characterization tests for NodeWidget's observable render behavior. They lock
// what the row shows so the tier-renderer extraction (#8) can be proven
// behavior-preserving.
void main() {
  FlatNode<String> flat(
    Node<String> node, {
    int depth = 0,
    bool isRoot = true,
    bool isLast = true,
  }) {
    return FlatNode<String>(
      node: node,
      depth: depth,
      isFirst: true,
      isLast: isLast,
      isRoot: isRoot,
      ancestorIsLastFlags: const [],
    );
  }

  // A theme with a recognizable expand icon and distinct text sizes so styling
  // is observable.
  FlutterFolderViewTheme<String> theme() {
    final base = FlutterFolderViewTheme<String>.light();
    return base.copyWith(
      expandIconTheme: const ExpandIconTheme(
        widget: Icon(Icons.chevron_right),
      ),
      folderTheme: const FolderNodeTheme<String>(
        textStyle: TextStyle(fontSize: 14),
      ),
      childTheme: const ChildNodeTheme<String>(
        textStyle: TextStyle(fontSize: 14),
        selectedTextStyle: TextStyle(fontSize: 99),
      ),
    );
  }

  Widget host(Widget child) => MaterialApp(
        home: Scaffold(body: SizedBox(width: 320, child: child)),
      );

  TextStyle? styleOf(WidgetTester tester, String label) =>
      tester.widget<Text>(find.text(label)).style;

  testWidgets('renders the node label', (tester) async {
    await tester.pumpWidget(host(NodeWidget<String>(
      flatNode: flat(Node(id: 'P', label: 'Parent A', type: NodeType.parent)),
      mode: ViewMode.folder,
      isExpanded: false,
      theme: theme(),
    )));
    expect(find.text('Parent A'), findsOneWidget);
  });

  testWidgets('a selected Child merges selectedTextStyle into the label',
      (tester) async {
    final node = Node<String>(id: 'C', label: 'Child A', type: NodeType.child);
    await tester.pumpWidget(host(NodeWidget<String>(
      flatNode: flat(node, isRoot: false, depth: 1),
      mode: ViewMode.tree,
      isExpanded: false,
      selectedNodeIds: const {'C'},
      theme: theme(),
    )));
    expect(styleOf(tester, 'Child A')?.fontSize, 99);
  });

  testWidgets('an unselected Child uses the base textStyle', (tester) async {
    final node = Node<String>(id: 'C', label: 'Child A', type: NodeType.child);
    await tester.pumpWidget(host(NodeWidget<String>(
      flatNode: flat(node, isRoot: false, depth: 1),
      mode: ViewMode.tree,
      isExpanded: false,
      selectedNodeIds: const {},
      theme: theme(),
    )));
    expect(styleOf(tester, 'Child A')?.fontSize, 14);
  });

  testWidgets('a Folder in the Selected Set gets no selection styling (ADR-0003)',
      (tester) async {
    final node = Node<String>(id: 'F', label: 'Folder A', type: NodeType.folder);
    await tester.pumpWidget(host(NodeWidget<String>(
      flatNode: flat(node),
      mode: ViewMode.folder,
      isExpanded: false,
      selectedNodeIds: const {'F'},
      theme: theme(),
    )));
    // Unchanged from the folder's base style — selection has no effect.
    expect(styleOf(tester, 'Folder A')?.fontSize, 14);
  });

  testWidgets('an expandable node with children shows the expand icon', (tester) async {
    final node = Node<String>(
      id: 'F',
      label: 'Folder A',
      type: NodeType.folder,
      children: [Node(id: 'p', label: 'p', type: NodeType.parent)],
    );
    await tester.pumpWidget(host(NodeWidget<String>(
      flatNode: flat(node),
      mode: ViewMode.folder,
      isExpanded: false,
      theme: theme(),
    )));
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('a Child row shows no expand icon', (tester) async {
    final node = Node<String>(id: 'C', label: 'Child A', type: NodeType.child);
    await tester.pumpWidget(host(NodeWidget<String>(
      flatNode: flat(node, isRoot: false, depth: 1),
      mode: ViewMode.tree,
      isExpanded: false,
      theme: theme(),
    )));
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });

  testWidgets('dispatches Child to ChildNodeRenderer', (tester) async {
    await tester.pumpWidget(host(NodeWidget<String>(
      flatNode: flat(Node(id: 'C', label: 'C', type: NodeType.child),
          isRoot: false, depth: 1),
      mode: ViewMode.tree,
      isExpanded: false,
      theme: theme(),
    )));
    expect(find.byType(ChildNodeRenderer<String>), findsOneWidget);
    expect(find.byType(ExpandableNodeRenderer<String>), findsNothing);
  });

  testWidgets('dispatches Folder to ExpandableNodeRenderer', (tester) async {
    await tester.pumpWidget(host(NodeWidget<String>(
      flatNode: flat(Node(id: 'F', label: 'F', type: NodeType.folder)),
      mode: ViewMode.folder,
      isExpanded: false,
      theme: theme(),
    )));
    expect(find.byType(ExpandableNodeRenderer<String>), findsOneWidget);
    expect(find.byType(ChildNodeRenderer<String>), findsNothing);
  });
}
