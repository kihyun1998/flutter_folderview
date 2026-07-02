import 'package:flutter/gestures.dart' show kSecondaryButton;
import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Folder 'f' > Parent 'p' > children 'c0','c1'. In folder mode with both
  // containers expanded, all four rows are visible, giving one row of each
  // tier (folder, parent, child) to drive gestures against.
  List<Node<String>> data() => [
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

  Future<void> pump(
    WidgetTester tester, {
    void Function(Node<String>)? onNodeTap,
    void Function(Node<String>)? onDoubleNodeTap,
    void Function(Node<String>, TapDownDetails)? onSecondaryNodeTap,
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            height: 400,
            child: FolderView<String>(
              data: data(),
              mode: ViewMode.folder,
              expandedNodeIds: const {'f', 'p'},
              onNodeTap: onNodeTap,
              onDoubleNodeTap: onDoubleNodeTap,
              onSecondaryNodeTap: onSecondaryNodeTap,
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('tapping a row fires onNodeTap once with the matching Node',
      (tester) async {
    final tapped = <Node<String>>[];
    await pump(tester, onNodeTap: tapped.add);

    await tester.tap(find.text('folder-f'));
    await tester.pump(const Duration(milliseconds: 400)); // flush click timer

    expect(tapped, hasLength(1));
    expect(tapped.single.id, 'f');
  });

  testWidgets(
      'double-tapping a child fires onNodeTap (first tap) then onDoubleNodeTap',
      (tester) async {
    // Record both streams into one ordered log to assert the dual-emission
    // sequence documented on CustomInkWell.
    final events = <String>[];
    await pump(
      tester,
      onNodeTap: (n) => events.add('tap:${n.id}'),
      onDoubleNodeTap: (n) => events.add('double:${n.id}'),
    );

    // Two taps within the click interval -> second tap resolves as a double.
    await tester.tap(find.text('child-c0'));
    await tester.tap(find.text('child-c0'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(events, ['tap:c0', 'double:c0']);
  });

  testWidgets(
      'right-clicking a child fires onSecondaryNodeTap with node and details',
      (tester) async {
    Node<String>? node;
    TapDownDetails? details;
    await pump(
      tester,
      onSecondaryNodeTap: (n, d) {
        node = n;
        details = d;
      },
    );

    await tester.tap(find.text('child-c1'), buttons: kSecondaryButton);
    await tester.pump();

    expect(node?.id, 'c1');
    expect(details, isNotNull);
  });

  testWidgets('with sibling rows, the tapped node is identified, not a sibling',
      (tester) async {
    final tapped = <String>[];
    await pump(tester, onNodeTap: (n) => tapped.add(n.id));

    await tester.tap(find.text('child-c0'));
    await tester.tap(find.text('child-c1'));
    await tester.pump(const Duration(milliseconds: 400)); // flush click timers

    // Each tap resolves to the row actually hit, in order.
    expect(tapped, ['c0', 'c1']);
  });
}
