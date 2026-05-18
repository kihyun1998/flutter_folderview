import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const defaultFontSize = 14.0;

  group('Identity short-circuit (factor == 1.0 returns identical this)', () {
    test('FlutterFolderViewTheme', () {
      final theme = FlutterFolderViewTheme<String>.light();
      final result =
          theme.scale(factor: 1.0, defaultFontSize: defaultFontSize);
      expect(identical(result, theme), isTrue,
          reason: 'scale(1.0) must return identical this — no allocation');
    });

    test('FolderNodeTheme', () {
      const t = FolderNodeTheme<String>();
      expect(
          identical(t.scale(1.0, defaultFontSize: defaultFontSize), t), isTrue);
    });

    test('ParentNodeTheme', () {
      const t = ParentNodeTheme<String>();
      expect(
          identical(t.scale(1.0, defaultFontSize: defaultFontSize), t), isTrue);
    });

    test('ChildNodeTheme', () {
      const t = ChildNodeTheme<String>();
      expect(
          identical(t.scale(1.0, defaultFontSize: defaultFontSize), t), isTrue);
    });

    test('NodeTooltipTheme', () {
      const t = NodeTooltipTheme<String>();
      expect(
          identical(t.scale(1.0, defaultFontSize: defaultFontSize), t), isTrue);
    });

    test('ExpandIconTheme', () {
      const t = ExpandIconTheme();
      expect(identical(t.scale(1.0), t), isTrue);
    });

    test('FolderViewLineTheme', () {
      const t = FolderViewLineTheme(lineColor: Color(0xFF000000));
      expect(identical(t.scale(1.0), t), isTrue);
    });

    test('FolderViewSpacingTheme', () {
      const t = FolderViewSpacingTheme();
      expect(identical(t.scale(1.0), t), isTrue);
    });

    test('FolderViewNodeStyleTheme', () {
      const t = FolderViewNodeStyleTheme();
      expect(identical(t.scale(1.0), t), isTrue);
    });

    testWidgets('scaledForContext(_, 1.0) also identity', (tester) async {
      final theme = FlutterFolderViewTheme<String>.light();
      late FlutterFolderViewTheme<String> result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              result = theme.scaledForContext(context, 1.0);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(identical(result, theme), isTrue,
          reason: 'scaledForContext must short-circuit before Theme.of lookup');
    });
  });

  group('Positivity assertion (factor > 0)', () {
    test('FlutterFolderViewTheme.scale throws on factor == 0', () {
      final theme = FlutterFolderViewTheme<String>.light();
      expect(
        () => theme.scale(factor: 0.0, defaultFontSize: defaultFontSize),
        throwsA(isA<AssertionError>()),
      );
    });

    test('FlutterFolderViewTheme.scale throws on negative factor', () {
      final theme = FlutterFolderViewTheme<String>.light();
      expect(
        () => theme.scale(factor: -1.0, defaultFontSize: defaultFontSize),
        throwsA(isA<AssertionError>()),
      );
    });

    test('FolderViewLineTheme.scale throws on negative factor', () {
      const t = FolderViewLineTheme(lineColor: Color(0xFF000000));
      expect(() => t.scale(-0.5), throwsA(isA<AssertionError>()));
    });
  });

  group('Spatial scaling — basic fields', () {
    test('FlutterFolderViewTheme scales rowHeight and rowSpacing', () {
      final theme = FlutterFolderViewTheme<String>.light().copyWith(
        rowHeight: 40.0,
        rowSpacing: 4.0,
      );
      final scaled =
          theme.scale(factor: 2.0, defaultFontSize: defaultFontSize);
      expect(scaled.rowHeight, 80.0);
      expect(scaled.rowSpacing, 8.0);
    });

    test('ExpandIconTheme scales width/height/padding/margin', () {
      const t = ExpandIconTheme(
        width: 20.0,
        height: 20.0,
        padding: EdgeInsets.all(4.0),
        margin: EdgeInsets.all(2.0),
      );
      final scaled = t.scale(2.0);
      expect(scaled.width, 40.0);
      expect(scaled.height, 40.0);
      expect(scaled.padding, const EdgeInsets.all(8.0));
      expect(scaled.margin, const EdgeInsets.all(4.0));
    });

    test('FolderViewLineTheme scales lineWidth only (not color/style)', () {
      const t = FolderViewLineTheme(
        lineColor: Color(0xFF123456),
        lineWidth: 2.0,
        lineStyle: LineStyle.connector,
      );
      final scaled = t.scale(1.5);
      expect(scaled.lineWidth, 3.0);
      expect(scaled.lineColor, const Color(0xFF123456));
      expect(scaled.lineStyle, LineStyle.connector);
    });

    test('FolderViewNodeStyleTheme scales borderRadius', () {
      const t = FolderViewNodeStyleTheme(borderRadius: 8.0);
      expect(t.scale(2.0).borderRadius, 16.0);
    });

    test('FolderViewSpacingTheme scales contentPadding', () {
      const t = FolderViewSpacingTheme(
        contentPadding: EdgeInsets.all(10.0),
      );
      expect(t.scale(2.0).contentPadding, const EdgeInsets.all(20.0));
    });
  });

  group('TextStyle scaling and null fontSize resolution', () {
    test('null textStyle becomes TextStyle(fontSize: defaultFontSize * factor)',
        () {
      const t = ChildNodeTheme<String>();
      final scaled = t.scale(2.0, defaultFontSize: 14.0);
      expect(scaled.textStyle, isNotNull);
      expect(scaled.textStyle!.fontSize, 28.0);
    });

    test('present textStyle without fontSize uses defaultFontSize', () {
      const t = ChildNodeTheme<String>(
        textStyle: TextStyle(color: Color(0xFF000000)),
      );
      final scaled = t.scale(2.0, defaultFontSize: 14.0);
      expect(scaled.textStyle!.fontSize, 28.0);
      expect(scaled.textStyle!.color, const Color(0xFF000000));
    });

    test('present fontSize ignores defaultFontSize and scales by factor', () {
      const t = ChildNodeTheme<String>(textStyle: TextStyle(fontSize: 20));
      final scaled = t.scale(2.0, defaultFontSize: 999.0);
      expect(scaled.textStyle!.fontSize, 40.0);
    });

    test('letterSpacing scales when present, stays null when null', () {
      const tWithLetter = ChildNodeTheme<String>(
        textStyle: TextStyle(fontSize: 16, letterSpacing: 1.5),
      );
      final scaled = tWithLetter.scale(2.0, defaultFontSize: 14.0);
      expect(scaled.textStyle!.letterSpacing, 3.0);

      const tNoLetter = ChildNodeTheme<String>(
        textStyle: TextStyle(fontSize: 16),
      );
      final scaled2 = tNoLetter.scale(2.0, defaultFontSize: 14.0);
      expect(scaled2.textStyle!.letterSpacing, isNull);
    });

    test('selectedTextStyle preserves null (no defaultFontSize resolution)',
        () {
      const t = ChildNodeTheme<String>();
      final scaled = t.scale(2.0, defaultFontSize: 14.0);
      expect(scaled.selectedTextStyle, isNull,
          reason:
              'Opt-in styles must stay null when unset — no surprise materialization');
    });

    test('selectedTextStyle scales when set', () {
      const t = ChildNodeTheme<String>(
        selectedTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      );
      final scaled = t.scale(2.0, defaultFontSize: 14.0);
      expect(scaled.selectedTextStyle!.fontSize, 32.0);
      expect(scaled.selectedTextStyle!.fontWeight, FontWeight.bold);
    });
  });

  group('NodeTooltipTheme participation (closes the CONTEXT.md gap)', () {
    test('NodeTooltipTheme.scale scales offset/crossAxisOffset', () {
      const t = NodeTooltipTheme<String>(
        offset: 8.0,
        crossAxisOffset: 4.0,
      );
      final scaled = t.scale(2.0, defaultFontSize: 14.0);
      expect(scaled.offset, 16.0);
      expect(scaled.crossAxisOffset, 8.0);
    });

    test('NodeTooltipTheme.scale scales nullable spatial fields when present',
        () {
      const t = NodeTooltipTheme<String>(
        padding: EdgeInsets.all(6.0),
        arrowBaseWidth: 12.0,
        arrowLength: 8.0,
        screenMargin: 16.0,
      );
      final scaled = t.scale(1.5, defaultFontSize: 14.0);
      expect(scaled.padding, const EdgeInsets.all(9.0));
      expect(scaled.arrowBaseWidth, 18.0);
      expect(scaled.arrowLength, 12.0);
      expect(scaled.screenMargin, 24.0);
    });

    test('NodeTooltipTheme.scale preserves null nullable fields', () {
      const t = NodeTooltipTheme<String>();
      final scaled = t.scale(2.0, defaultFontSize: 14.0);
      expect(scaled.padding, isNull);
      expect(scaled.arrowBaseWidth, isNull);
      expect(scaled.arrowLength, isNull);
      expect(scaled.screenMargin, isNull);
    });

    test('NodeTooltipTheme.scale preserves non-spatial fields unchanged', () {
      const t = NodeTooltipTheme<String>(
        useTooltip: true,
        message: 'hello',
        backgroundColor: Color(0xFF112233),
        arrowPositionRatio: 0.25,
        elevation: 4.0,
      );
      final scaled = t.scale(2.0, defaultFontSize: 14.0);
      expect(scaled.useTooltip, true);
      expect(scaled.message, 'hello');
      expect(scaled.backgroundColor, const Color(0xFF112233));
      expect(scaled.arrowPositionRatio, 0.25,
          reason: 'arrowPositionRatio is a ratio, not a length');
      expect(scaled.elevation, 4.0,
          reason: 'elevation is a shadow depth, not a content length');
    });

    test('FolderNodeTheme.scale delegates to tooltipTheme.scale', () {
      const t = FolderNodeTheme<String>(
        tooltipTheme: NodeTooltipTheme<String>(offset: 10.0),
      );
      final scaled = t.scale(2.0, defaultFontSize: 14.0);
      expect(scaled.tooltipTheme!.offset, 20.0,
          reason: 'parent theme must recursively scale its tooltip');
    });
  });

  group('Scrollbar exclusion (ADR-0001)', () {
    test('FlutterFolderViewTheme.scale passes scrollbarTheme through identical',
        () {
      final theme = FlutterFolderViewTheme<String>.light();
      final scaled =
          theme.scale(factor: 2.0, defaultFontSize: defaultFontSize);
      expect(identical(scaled.scrollbarTheme, theme.scrollbarTheme), isTrue,
          reason:
              'ADR-0001: scrollbarTheme must be pointer-equal pass-through');
    });

    test('scrollbarTheme fields literally unchanged across scale', () {
      final theme = FlutterFolderViewTheme<String>.light();
      final scaled =
          theme.scale(factor: 3.0, defaultFontSize: defaultFontSize);
      expect(scaled.scrollbarTheme.thickness, theme.scrollbarTheme.thickness);
      expect(scaled.scrollbarTheme.trackWidth, theme.scrollbarTheme.trackWidth);
      expect(scaled.scrollbarTheme.radius, theme.scrollbarTheme.radius);
    });
  });

  group('Non-spatial preservation', () {
    test('animationDuration is not scaled (time is not space)', () {
      final theme = FlutterFolderViewTheme<String>.light();
      final scaled =
          theme.scale(factor: 2.0, defaultFontSize: defaultFontSize);
      expect(scaled.animationDuration, theme.animationDuration);
    });

    test('Colors are not scaled', () {
      const t = ChildNodeTheme<String>(
        hoverColor: Color(0xFFAABBCC),
        splashColor: Color(0xFF112233),
        selectedBackgroundColor: Color(0xFF445566),
      );
      final scaled = t.scale(2.0, defaultFontSize: 14.0);
      expect(scaled.hoverColor, const Color(0xFFAABBCC));
      expect(scaled.splashColor, const Color(0xFF112233));
      expect(scaled.selectedBackgroundColor, const Color(0xFF445566));
    });

    test('clickInterval is not scaled (interaction timing)', () {
      const t = ChildNodeTheme<String>(clickInterval: 300);
      final scaled = t.scale(2.0, defaultFontSize: 14.0);
      expect(scaled.clickInterval, 300);
    });
  });
}
