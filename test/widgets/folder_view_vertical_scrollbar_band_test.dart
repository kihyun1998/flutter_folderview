import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_folderview/widgets/folder_view_vertical_scrollbar.dart';
import 'package:flutter_test/flutter_test.dart';

// The vertical scrollbar of the public FolderView is built exactly when the
// list's viewport is shorter than the content. With the horizontal scrollbar
// present, that viewport is shorter than the view by the horizontal track.

const double _width = 300;
const double _rowHeight = 40;
const double _trackWidth = 16;
const int _rows = 8;

/// Content height of [_rows] rows at [scale]: no rowSpacing, no padding.
double _contentHeight({double scale = 1}) => _rows * _rowHeight * scale;

List<Node<String>> _nodes({required bool wide}) => [
  for (var i = 0; i < _rows; i++)
    Node<String>(
      id: 'p$i',
      label: wide && i == 0 ? 'w' * 200 : 'p$i',
      type: NodeType.parent,
    ),
];

Future<void> _pump(
  WidgetTester tester, {
  required double height,
  required bool wide,
  double scale = 1,
}) async {
  final light = FlutterFolderViewTheme<String>.light();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: _width,
            height: height,
            child: FolderView<String>(
              data: _nodes(wide: wide),
              mode: ViewMode.tree,
              expandedNodeIds: const {},
              scale: scale,
              theme: light.copyWith(
                rowHeight: _rowHeight,
                rowSpacing: 0,
                spacingTheme: const FolderViewSpacingTheme(),
                scrollbarTheme: light.scrollbarTheme.copyWith(
                  trackWidth: _trackWidth,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

double _listMaxScrollExtent(WidgetTester tester) => tester
    .state<ScrollableState>(
      find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    )
    .position
    .maxScrollExtent;

Finder get _verticalBar => find.byType(FolderViewVerticalScrollbar);

void main() {
  group('with a row wider than the view', () {
    testWidgets('a list that overflows by less than the horizontal track '
        'builds one vertical scrollbar', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      try {
        await _pump(tester, height: _contentHeight() + 4, wide: true);
        expect(_listMaxScrollExtent(tester), 12);
        expect(_verticalBar, findsOneWidget);

        await _pump(
          tester,
          height: _contentHeight() + _trackWidth - 1,
          wide: true,
        );
        expect(_listMaxScrollExtent(tester), 1);
        expect(_verticalBar, findsOneWidget);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('a list that fits above the horizontal track builds no '
        'vertical scrollbar', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      try {
        await _pump(tester, height: _contentHeight() + _trackWidth, wide: true);
        expect(_listMaxScrollExtent(tester), 0);
        expect(_verticalBar, findsNothing);

        await _pump(tester, height: _contentHeight() + 40, wide: true);
        expect(_listMaxScrollExtent(tester), 0);
        expect(_verticalBar, findsNothing);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('the band is the unscaled track at any Scale', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      try {
        // Rows are 60 at Scale 1.5; the track stays 16 (ADR-0001).
        final content = _contentHeight(scale: 1.5);
        await _pump(tester, height: content + 4, wide: true, scale: 1.5);
        expect(_listMaxScrollExtent(tester), 12);
        expect(_verticalBar, findsOneWidget);

        await _pump(
          tester,
          height: content + _trackWidth,
          wide: true,
          scale: 1.5,
        );
        expect(_listMaxScrollExtent(tester), 0);
        expect(_verticalBar, findsNothing);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  });

  testWidgets('with no wide row, the threshold is the content height', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      await _pump(tester, height: _contentHeight() + 4, wide: false);
      expect(_listMaxScrollExtent(tester), 0);
      expect(_verticalBar, findsNothing);

      await _pump(tester, height: _contentHeight() - 1, wide: false);
      expect(_listMaxScrollExtent(tester), 1);
      expect(_verticalBar, findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
