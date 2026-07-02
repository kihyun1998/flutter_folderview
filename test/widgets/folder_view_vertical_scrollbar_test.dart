import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_folderview/widgets/folder_view_vertical_scrollbar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const theme = FolderViewScrollbarTheme(
    thumbColor: Color(0xFF333333),
    trackColor: Color(0xFFEEEEEE),
    hoverOpacity: 0.7,
    nonHoverOpacity: 0.1,
    trackWidth: 16,
  );

  Future<void> pumpBar(
    WidgetTester tester, {
    required bool isHover,
    required bool needsHorizontalScroll,
  }) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 300,
            child: Stack(
              children: [
                FolderViewVerticalScrollbar(
                  isHover: isHover,
                  verticalScrollbarController: controller,
                  contentHeight: 1000,
                  needsHorizontalScroll: needsHorizontalScroll,
                  scrollbarTheme: theme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  double opacityOf(WidgetTester tester) =>
      tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;

  testWidgets('renders a Scrollbar and uses hoverOpacity when hovered',
      (tester) async {
    await pumpBar(tester, isHover: true, needsHorizontalScroll: false);
    expect(find.byType(Scrollbar), findsOneWidget);
    expect(opacityOf(tester), 0.7);
  });

  testWidgets('uses nonHoverOpacity when not hovered', (tester) async {
    await pumpBar(tester, isHover: false, needsHorizontalScroll: false);
    expect(opacityOf(tester), 0.1);
  });

  testWidgets('leaves room for the horizontal scrollbar when both are needed',
      (tester) async {
    await pumpBar(tester, isHover: true, needsHorizontalScroll: true);
    // The vertical bar stops short of the bottom by the horizontal track width.
    final positioned = tester.widget<Positioned>(
      find.ancestor(
        of: find.byType(AnimatedOpacity),
        matching: find.byType(Positioned),
      ),
    );
    expect(positioned.bottom, theme.trackWidth);
  });
}
