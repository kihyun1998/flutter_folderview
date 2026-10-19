import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/shell_harness.dart';

Future<void> _openLines(WidgetTester tester) async {
  await pumpShell(tester);
  await openFeature(tester, 'Tree lines');
}

FolderViewLineTheme _lineTheme(WidgetTester tester) =>
    renderedFolderView(tester).theme!.lineTheme;

/// One `drawLine` call the rendered `FolderView` makes.
typedef _Line = ({Offset from, Offset to, Paint paint});

/// Every `drawLine` call the rendered `FolderView` makes when painted.
List<_Line> _lines(WidgetTester tester) {
  final lines = <_Line>[];
  expect(
    tester.renderObject(find.byType(FolderView<String>)),
    paints..everything((method, args) {
      if (method == #drawLine) {
        lines.add((
          from: args[0] as Offset,
          to: args[1] as Offset,
          paint: args[2] as Paint,
        ));
      }
      return true;
    }),
  );
  return lines;
}

bool _horizontal(_Line l) => l.from.dy == l.to.dy && l.from.dx != l.to.dx;

/// Taps the colour swatch [index] in the `lineColor` control.
Future<void> _pickColor(WidgetTester tester, int index) async {
  final swatch = find.byKey(ValueKey('FolderViewLineTheme.lineColor.$index'));
  await tester.ensureVisible(swatch);
  await tester.tap(swatch);
  await tester.pumpAndSettle();
}

/// The colour of swatch [index] in the `lineColor` control.
Color _swatch(WidgetTester tester, int index) {
  final box = tester.widget<Container>(
    find.descendant(
      of: find.byKey(ValueKey('FolderViewLineTheme.lineColor.$index')),
      matching: find.byType(Container),
    ),
  );
  return (box.decoration! as BoxDecoration).color!;
}

void main() {
  group('Every setting: Tree lines', () {
    testWidgets('opens on the light theme: grey 1.5 px connectors', (
      tester,
    ) async {
      await _openLines(tester);

      final light = FlutterFolderViewTheme<String>.light().lineTheme;
      expect(_lineTheme(tester), light);

      final lines = _lines(tester);
      expect(lines, isNotEmpty);
      expect(lines.where(_horizontal), isNotEmpty);
      for (final l in lines) {
        expect(l.paint.color.toARGB32(), light.lineColor.toARGB32());
        expect(l.paint.strokeWidth, light.lineWidth);
      }
    });

    testWidgets('Scope draws verticals only, None draws no line', (
      tester,
    ) async {
      await _openLines(tester);

      await chooseDropdown(tester, 'FolderViewLineTheme.lineStyle', 'scope');
      expect(_lineTheme(tester).lineStyle, LineStyle.scope);
      expect(_lines(tester), isNotEmpty);
      expect(_lines(tester).where(_horizontal), isEmpty);

      await chooseDropdown(tester, 'FolderViewLineTheme.lineStyle', 'none');
      expect(_lineTheme(tester).lineStyle, LineStyle.none);
      expect(_lines(tester), isEmpty);
    });

    testWidgets('Width sets lineWidth, and every line is that thick', (
      tester,
    ) async {
      await _openLines(tester);

      await setSlider(tester, 'FolderViewLineTheme.lineWidth', 3);
      expect(_lineTheme(tester).lineWidth, 3);
      expect(_lines(tester).map((l) => l.paint.strokeWidth).toSet(), {3});
    });

    testWidgets('a swatch sets lineColor, and every line is that colour', (
      tester,
    ) async {
      await _openLines(tester);
      final picked = _swatch(tester, 2);

      await _pickColor(tester, 2);
      expect(_lineTheme(tester).lineColor, picked);
      expect(_lines(tester).map((l) => l.paint.color.toARGB32()).toSet(), {
        picked.toARGB32(),
      });
    });

    testWidgets('in Tree Mode the lines still follow the settings', (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'View Mode');
      await chooseDropdown(tester, 'FolderView.mode', 'tree');
      await openFeature(tester, 'Tree lines');
      expect(renderedFolderView(tester).mode, ViewMode.tree);

      expect(_lines(tester).where(_horizontal), isNotEmpty);
      await setSlider(tester, 'FolderViewLineTheme.lineWidth', 3);
      expect(_lines(tester).map((l) => l.paint.strokeWidth).toSet(), {3});

      await chooseDropdown(tester, 'FolderViewLineTheme.lineStyle', 'scope');
      expect(_lines(tester), isNotEmpty);
      expect(_lines(tester).where(_horizontal), isEmpty);

      await chooseDropdown(tester, 'FolderViewLineTheme.lineStyle', 'none');
      expect(_lines(tester), isEmpty);
    });

    testWidgets('the lineTheme control shows the sub-theme as code', (
      tester,
    ) async {
      await _openLines(tester);
      await chooseDropdown(tester, 'FolderViewLineTheme.lineStyle', 'scope');
      await setSlider(tester, 'FolderViewLineTheme.lineWidth', 2.5);

      final code = tester
          .widget<SelectableText>(
            find.descendant(
              of: find.byWidgetPredicate(
                (w) =>
                    w is SettingsControl &&
                    w.id == 'FlutterFolderViewTheme.lineTheme',
              ),
              matching: find.byType(SelectableText),
            ),
          )
          .data!;
      expect(
        code,
        'lineTheme: const FolderViewLineTheme(\n'
        '  lineColor: Color(0xFF9E9E9E),\n'
        '  lineWidth: 2.5,\n'
        '  lineStyle: LineStyle.scope,\n'
        '),',
      );
    });
  });
}
