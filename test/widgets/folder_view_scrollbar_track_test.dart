import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_folderview/widgets/folder_view_horizontal_scrollbar.dart';
import 'package:flutter_folderview/widgets/folder_view_vertical_scrollbar.dart';
import 'package:flutter_test/flutter_test.dart';

/// The box styled by `trackColor` is a bar's only track, and the thumb stays
/// inside that box whatever `thickness` says (#122).
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
                  trackColor: const Color(0xFF00FF00),
                  thickness: thickness,
                  trackWidth: trackWidth,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The [bar]th scrollbar in the view: 0 vertical, 1 horizontal.
  Finder scrollbar(int bar) => find
      .descendant(
        of: find.byType(
          bar == 0
              ? FolderViewVerticalScrollbar
              : FolderViewHorizontalScrollbar,
        ),
        matching: find.byType(Scrollbar),
      )
      .first;

  /// What the [bar]th `Scrollbar` paints, in its own coordinates: the thumb's
  /// rect and the colour of every rect it fills.
  ({Rect thumb, List<int> rects, Size box}) painted(
    WidgetTester tester,
    int bar,
  ) {
    Rect? thumb;
    final rects = <int>[];
    final box = tester.renderObject<RenderBox>(scrollbar(bar));
    expect(
      box,
      paints..everything((method, args) {
        if (method == #drawRRect) thumb = (args.first as RRect).outerRect;
        if (method == #drawRect) {
          final color = (args.last as Paint).color.toARGB32();
          if ((color >> 24) != 0) rects.add(color);
        }
        return true;
      }),
    );
    expect(thumb, isNotNull, reason: 'bar $bar draws a thumb');
    return (thumb: thumb!, rects: rects, box: box.size);
  }

  // Material's thumb margin is 0 on Android and 2 on desktop.
  void bothTest(String description, WidgetTesterCallback body) => testWidgets(
    description,
    body,
    variant: TargetPlatformVariant(const {
      TargetPlatform.android,
      TargetPlatform.windows,
    }),
  );

  bothTest('a thickness above trackWidth keeps each thumb in its bar', (
    tester,
  ) async {
    await pump(tester, thickness: 20, trackWidth: 8);

    final vertical = painted(tester, 0);
    expect(vertical.box.width, 8);
    expect(vertical.thumb.left, greaterThanOrEqualTo(0));
    expect(vertical.thumb.right, lessThanOrEqualTo(8));

    final horizontal = painted(tester, 1);
    expect(horizontal.box.height, 8);
    expect(horizontal.thumb.top, greaterThanOrEqualTo(0));
    expect(horizontal.thumb.bottom, lessThanOrEqualTo(8));
  });

  bothTest('a thickness that fits is painted as given', (tester) async {
    await pump(tester, thickness: 6, trackWidth: 16);

    expect(painted(tester, 0).thumb.width, 6);
    expect(painted(tester, 1).thumb.height, 6);
  });

  bothTest("neither bar's Scrollbar paints a track of its own", (tester) async {
    await pump(tester, thickness: 12, trackWidth: 16);

    for (final bar in [0, 1]) {
      expect(
        tester.widget<Scrollbar>(scrollbar(bar)).trackVisibility,
        isNot(true),
      );
      expect(painted(tester, bar).rects, isEmpty, reason: 'bar $bar');
      final track =
          tester
                  .widget<Container>(
                    find
                        .ancestor(
                          of: scrollbar(bar),
                          matching: find.byType(Container),
                        )
                        .first,
                  )
                  .decoration!
              as BoxDecoration;
      expect(track.color, const Color(0xFF00FF00));
    }
  });
}
