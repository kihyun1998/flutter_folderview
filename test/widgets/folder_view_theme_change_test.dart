import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_folderview/widgets/folder_view_horizontal_scrollbar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A Parent (root in tree mode) with one Child, both carrying a long label so
  // font size is the dominant driver of measured content width.
  final data = <Node<String>>[
    Node<String>(
      id: 'p1',
      label: 'This is a fairly long node label',
      type: NodeType.parent,
      children: [
        Node<String>(
          id: 'c1',
          label: 'This is a fairly long node label',
          type: NodeType.child,
        ),
      ],
    ),
  ];

  FlutterFolderViewTheme<String> themedWithFont(double fontSize) {
    final base = FlutterFolderViewTheme<String>.light();
    return base.copyWith(
      parentTheme: base.parentTheme.copyWith(
        textStyle: TextStyle(fontSize: fontSize),
      ),
      childTheme: base.childTheme.copyWith(
        textStyle: TextStyle(fontSize: fontSize),
      ),
    );
  }

  Widget harness(FlutterFolderViewTheme<String> theme) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 200,
            height: 400,
            child: FolderView<String>(
              data: data,
              mode: ViewMode.tree,
              expandedNodeIds: const {'p1'},
              theme: theme,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'content width recomputes when the theme prop changes (not just data/scale)',
    (tester) async {
      // Tiny font: content fits within the 200px viewport → no horizontal scroll.
      await tester.pumpWidget(harness(themedWithFont(2)));
      await tester.pumpAndSettle();
      expect(find.byType(FolderViewHorizontalScrollbar), findsNothing);

      // Same widget position, larger font: State is reused (didUpdateWidget).
      // Content now overflows 200px → a horizontal scrollbar must appear.
      await tester.pumpWidget(harness(themedWithFont(60)));
      await tester.pumpAndSettle();
      expect(find.byType(FolderViewHorizontalScrollbar), findsOneWidget);
    },
  );

  // The theme can also reach the view without the `theme:` prop changing: from
  // an ancestor FolderViewTheme, or through the ambient text theme that
  // measurement merges under the tier style. Either one changes what a row
  // draws, so either one must re-measure.
  Widget inheritedHarness({
    required FlutterFolderViewTheme<String> theme,
    TextStyle? bodyMedium,
  }) {
    return MaterialApp(
      theme: ThemeData(textTheme: TextTheme(bodyMedium: bodyMedium)),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 200,
            height: 400,
            child: FolderViewTheme<String>(
              data: theme,
              child: FolderView<String>(
                data: data,
                mode: ViewMode.tree,
                expandedNodeIds: const {'p1'},
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'content width recomputes when an ancestor FolderViewTheme changes',
    (tester) async {
      await tester.pumpWidget(inheritedHarness(theme: themedWithFont(2)));
      await tester.pumpAndSettle();
      expect(find.byType(FolderViewHorizontalScrollbar), findsNothing);

      await tester.pumpWidget(inheritedHarness(theme: themedWithFont(60)));
      await tester.pumpAndSettle();
      expect(find.byType(FolderViewHorizontalScrollbar), findsOneWidget);
    },
  );

  testWidgets(
    'content width recomputes when the ambient text theme changes',
    (tester) async {
      // light() tier styles set no fontSize, so bodyMedium alone sizes the text.
      final plain = FlutterFolderViewTheme<String>.light();
      await tester.pumpWidget(inheritedHarness(
          theme: plain, bodyMedium: const TextStyle(fontSize: 2)));
      await tester.pumpAndSettle();
      expect(find.byType(FolderViewHorizontalScrollbar), findsNothing);

      await tester.pumpWidget(inheritedHarness(
          theme: plain, bodyMedium: const TextStyle(fontSize: 60)));
      await tester.pumpAndSettle();
      expect(find.byType(FolderViewHorizontalScrollbar), findsOneWidget);
    },
  );
}
