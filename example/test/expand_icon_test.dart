import 'package:example/app/every_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/shell_harness.dart';

const _expandedFolder = 'Theme System Architecture'; // id 1, expanded
const _collapsedParent = 'FolderViewTheme (InheritedWidget)'; // id 1-2
const _child = 'FolderViewLineTheme'; // id 1-1-1

Future<void> _openExpandIcon(WidgetTester tester) async {
  await pumpShell(tester);
  await openFeature(tester, 'Expand icon');
}

ExpandIconTheme _expandTheme(WidgetTester tester) =>
    renderedFolderView(tester).theme!.expandIconTheme;

Finder _inView(Finder matching) =>
    find.descendant(of: find.byType(FolderView<String>), matching: matching);

/// The ARGB colour of the [icon] glyph drawn on the row labelled [label].
int _glyphColorOn(WidgetTester tester, String label, IconData icon) {
  final rowY = tester.getCenter(_inView(find.text(label))).dy;
  final glyph = String.fromCharCode(icon.codePoint);
  final glyphs = tester
      .widgetList<RichText>(_inView(find.byType(RichText)))
      .where((r) => r.text.toPlainText() == glyph)
      .toList();
  expect(glyphs, isNotEmpty, reason: 'no ${icon.codePoint} glyph drawn');
  final nearest = glyphs.reduce(
    (a, b) =>
        (tester.getCenter(find.byWidget(a)).dy - rowY).abs() <
            (tester.getCenter(find.byWidget(b)).dy - rowY).abs()
        ? a
        : b,
  );
  final distance = (tester.getCenter(find.byWidget(nearest)).dy - rowY).abs();
  final view =
      tester.renderObject(find.byType(FolderView<String>)) as RenderBox;
  final scale =
      view.localToGlobal(const Offset(0, 1)).dy -
      view.localToGlobal(Offset.zero).dy;
  expect(distance, lessThan(20 * scale), reason: 'no glyph on row "$label"');
  return nearest.text.style!.color!.toARGB32();
}

int _glyphCount(WidgetTester tester, IconData icon) {
  final glyph = String.fromCharCode(icon.codePoint);
  return tester
      .widgetList<RichText>(_inView(find.byType(RichText)))
      .where((r) => r.text.toPlainText() == glyph)
      .length;
}

/// The Child label's left edge in the view's own pixels.
double _childX(WidgetTester tester) {
  final view =
      tester.renderObject(find.byType(FolderView<String>)) as RenderBox;
  final label = tester.getTopLeft(_inView(find.text(_child)));
  return view.globalToLocal(label).dx;
}

Future<void> _tapSwatch(WidgetTester tester, String id, int index) async {
  final swatch = find.byKey(ValueKey('$id.$index'));
  await tester.ensureVisible(swatch);
  await tester.pumpAndSettle();
  await tester.tap(swatch);
  await tester.pumpAndSettle();
}

Future<void> _toggle(WidgetTester tester, String id) async {
  final target = find.descendant(
    of: find.byWidgetPredicate((w) => w is SettingsControl && w.id == id),
    matching: find.byType(Switch),
  );
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _setSide(
  WidgetTester tester,
  String id,
  String side,
  double value,
) async {
  tester.widget<Slider>(find.byKey(ValueKey('$id.$side'))).onChanged!(value);
  await tester.pumpAndSettle();
}

void main() {
  group('Every setting: Expand icon', () {
    testWidgets('opens on the light theme expand icon', (tester) async {
      await _openExpandIcon(tester);

      final light = FlutterFolderViewTheme<String>.light().expandIconTheme;
      final theme = _expandTheme(tester);
      expect(theme.width, light.width);
      expect(theme.height, light.height);
      expect(theme.padding, light.padding);
      expect(theme.margin, light.margin);
      expect(theme.color, isNull);
      expect(theme.expandedColor, isNull);
      expect((theme.widget! as Icon).icon, Icons.chevron_right);
      expect(_glyphCount(tester, Icons.chevron_right), greaterThan(0));
    });

    testWidgets('the sample switch installs an uncoloured arrow', (
      tester,
    ) async {
      await _openExpandIcon(tester);

      await _toggle(tester, 'ExpandIconTheme.widget');
      expect((_expandTheme(tester).widget! as Icon).icon, Icons.arrow_right);
      expect(_glyphCount(tester, Icons.arrow_right), greaterThan(0));
      expect(_glyphCount(tester, Icons.chevron_right), 0);
    });

    testWidgets('on the sample, color paints collapsed rows and expandedColor '
        'expanded ones', (tester) async {
      await _openExpandIcon(tester);
      await _toggle(tester, 'ExpandIconTheme.widget');

      await _tapSwatch(tester, 'ExpandIconTheme.color', 1);
      final color = _expandTheme(tester).color!;
      expect(color, EverySettingDemo.expandIconColors[1]);
      // Without expandedColor, every row takes color.
      expect(
        _glyphColorOn(tester, _expandedFolder, Icons.arrow_right),
        color.toARGB32(),
      );

      await _tapSwatch(tester, 'ExpandIconTheme.expandedColor', 2);
      final expanded = _expandTheme(tester).expandedColor!;
      expect(
        _glyphColorOn(tester, _expandedFolder, Icons.arrow_right),
        expanded.toARGB32(),
      );
      expect(
        _glyphColorOn(tester, _collapsedParent, Icons.arrow_right),
        color.toARGB32(),
      );
    });

    testWidgets("light()'s chevron keeps its own grey whatever color says", (
      tester,
    ) async {
      await _openExpandIcon(tester);

      await _tapSwatch(tester, 'ExpandIconTheme.color', 1);
      await _tapSwatch(tester, 'ExpandIconTheme.expandedColor', 2);
      final grey = Colors.grey.shade700.toARGB32();
      expect(_glyphColorOn(tester, _expandedFolder, Icons.chevron_right), grey);
      expect(
        _glyphColorOn(tester, _collapsedParent, Icons.chevron_right),
        grey,
      );
    });

    testWidgets('width, horizontal padding and margin each widen the indent '
        'unit alike; height does not', (tester) async {
      await _openExpandIcon(tester);
      final base = _childX(tester);

      await setSlider(tester, 'ExpandIconTheme.width', 30);
      expect(_expandTheme(tester).width, 30);
      final byWidth = _childX(tester) - base;
      expect(byWidth, greaterThan(0));
      await setSlider(tester, 'ExpandIconTheme.width', 20);

      await _setSide(tester, 'ExpandIconTheme.padding', 'left', 4);
      await _setSide(tester, 'ExpandIconTheme.padding', 'right', 6);
      expect(
        _expandTheme(tester).padding,
        const EdgeInsets.fromLTRB(4, 0, 6, 0),
      );
      expect(_childX(tester) - base, closeTo(byWidth, 0.01));
      await _setSide(tester, 'ExpandIconTheme.padding', 'left', 0);
      await _setSide(tester, 'ExpandIconTheme.padding', 'right', 0);

      await _setSide(tester, 'ExpandIconTheme.margin', 'left', 10);
      expect(
        _expandTheme(tester).margin,
        const EdgeInsets.fromLTRB(10, 0, 0, 0),
      );
      expect(_childX(tester) - base, closeTo(byWidth, 0.01));
      await _setSide(tester, 'ExpandIconTheme.margin', 'left', 0);

      await setSlider(tester, 'ExpandIconTheme.height', 32);
      expect(_expandTheme(tester).height, 32);
      expect(_childX(tester), closeTo(base, 0.01));
    });

    testWidgets("the code text writes light()'s chevron without const", (
      tester,
    ) async {
      await _openExpandIcon(tester);

      final code = tester
          .widget<SelectableText>(
            find.descendant(
              of: find.byWidgetPredicate(
                (w) =>
                    w is SettingsControl &&
                    w.id == 'FlutterFolderViewTheme.expandIconTheme',
              ),
              matching: find.byType(SelectableText),
            ),
          )
          .data!;
      expect(
        code,
        startsWith(
          'expandIconTheme: ExpandIconTheme(\n'
          '  widget: Icon(Icons.chevron_right, color: Colors.grey.shade700, '
          'size: 20),\n',
        ),
      );
      expect(code, isNot(contains('color: Color(')));
    });

    testWidgets('the expandIconTheme control shows the sub-theme as code', (
      tester,
    ) async {
      await _openExpandIcon(tester);
      await _toggle(tester, 'ExpandIconTheme.widget');
      await setSlider(tester, 'ExpandIconTheme.width', 24);
      await _tapSwatch(tester, 'ExpandIconTheme.color', 1);

      final code = tester
          .widget<SelectableText>(
            find.descendant(
              of: find.byWidgetPredicate(
                (w) =>
                    w is SettingsControl &&
                    w.id == 'FlutterFolderViewTheme.expandIconTheme',
              ),
              matching: find.byType(SelectableText),
            ),
          )
          .data!;
      final argb = EverySettingDemo.expandIconColors[1]!
          .toARGB32()
          .toRadixString(16)
          .toUpperCase();
      expect(
        code,
        'expandIconTheme: const ExpandIconTheme(\n'
        '  widget: Icon(Icons.arrow_right, size: 20),\n'
        '  width: 24,\n'
        '  height: 20,\n'
        '  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),\n'
        '  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),\n'
        '  color: Color(0x$argb),\n'
        '),',
      );
    });
  });
}
