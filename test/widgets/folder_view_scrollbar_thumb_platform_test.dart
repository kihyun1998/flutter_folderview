import 'package:flutter/foundation.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_folderview/widgets/folder_view_horizontal_scrollbar.dart';
import 'package:flutter_folderview/widgets/folder_view_vertical_scrollbar.dart';
import 'package:flutter_test/flutter_test.dart';

/// Each bar's thumb is painted with the theme's thickness, radius and colour on
/// every platform, iOS included (#147).
void main() {
  // Enough rows to scroll vertically, and a label wide enough to scroll
  // horizontally, so both bars are drawn.
  List<Node<String>> data() => [
    Node<String>(
      id: 'f',
      label: 'folder',
      type: NodeType.folder,
      children: [
        for (var i = 0; i < 40; i++)
          Node<String>(
            id: 'p$i',
            label: i == 0 ? 'a very long label ' * 8 : 'parent $i',
            type: NodeType.parent,
          ),
      ],
    ),
  ];

  Future<void> pump(
    WidgetTester tester, {
    required double thickness,
    required double trackWidth,
  }) async {
    final light = FlutterFolderViewTheme<String>.light();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 300,
            child: FolderView<String>(
              data: data(),
              mode: ViewMode.folder,
              expandedNodeIds: const {'f'},
              theme: light.copyWith(
                scrollbarTheme: light.scrollbarTheme.copyWith(
                  thickness: thickness,
                  trackWidth: trackWidth,
                  radius: 1,
                  thumbColor: const Color(0xFFFF0000),
                  thumbVisibility: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The painter of the thumb inside [bar].
  ScrollbarPainter thumbPainter(WidgetTester tester, Type bar) {
    final painters = tester
        .widgetList<CustomPaint>(
          find.descendant(
            of: find.byType(bar),
            matching: find.byType(CustomPaint),
          ),
        )
        .map((paint) => paint.foregroundPainter)
        .whereType<ScrollbarPainter>()
        .toList();
    expect(painters, hasLength(1), reason: '$bar has one thumb');
    return painters.single;
  }

  final platforms = TargetPlatformVariant(const {
    TargetPlatform.iOS,
    TargetPlatform.windows,
    TargetPlatform.android,
  });

  for (final bar in [
    FolderViewVerticalScrollbar,
    FolderViewHorizontalScrollbar,
  ]) {
    testWidgets("$bar paints the theme's thickness, radius and colour", (
      tester,
    ) async {
      await pump(tester, thickness: 6, trackWidth: 16);

      final painter = thumbPainter(tester, bar);
      expect(painter.thickness, 6);
      expect(painter.radius, const Radius.circular(1));
      expect(painter.color, const Color(0xFFFF0000));
      // Material's `Scrollbar` minimum thumb length.
      expect(painter.minLength, 48);
    }, variant: platforms);

    testWidgets('$bar caps a thickness above trackWidth less the margin', (
      tester,
    ) async {
      await pump(tester, thickness: 20, trackWidth: 8);

      final android = defaultTargetPlatform == TargetPlatform.android;
      final margin = android ? 0.0 : 2.0;
      final painter = thumbPainter(tester, bar);
      expect(painter.crossAxisMargin, margin);
      expect(painter.thickness, 8 - margin);
    }, variant: platforms);
  }
}
