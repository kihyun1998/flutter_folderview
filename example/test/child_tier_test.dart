import 'package:example/app/every_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/shell_harness.dart';

const _c1 = 'FolderViewLineTheme'; // id 1-1-1
const _future = 'FolderViewNodeTheme (Future)'; // id 1-1-2

Finder _inView(Finder matching) =>
    find.descendant(of: find.byType(FolderView<String>), matching: matching);

ChildNodeTheme<String> _child(WidgetTester tester) =>
    renderedFolderView(tester).theme!.childTheme;

Finder _labelFinder(String label) => _inView(
  find.byWidgetPredicate(
    (w) => w is RichText && w.text.toPlainText().startsWith(label),
  ),
);

RichText _label(WidgetTester tester, String label) =>
    tester.widget<RichText>(_labelFinder(label));

/// The icon glyphs drawn on the row of the Child labelled [label].
Set<int> _glyphsOn(WidgetTester tester, String label) {
  final view =
      tester.renderObject(find.byType(FolderView<String>)) as RenderBox;
  final scale =
      view.localToGlobal(const Offset(0, 1)).dy -
      view.localToGlobal(Offset.zero).dy;
  final y = tester.getCenter(_labelFinder(label)).dy;
  return {
    for (final r in tester.widgetList<RichText>(_inView(find.byType(RichText))))
      if (r.text.toPlainText().runes.length == 1 &&
          (tester.getCenter(find.byWidget(r)).dy - y).abs() < 20 * scale)
        r.text.toPlainText().runes.first,
  };
}

double _labelX(WidgetTester tester, String label) {
  final view =
      tester.renderObject(find.byType(FolderView<String>)) as RenderBox;
  return view.globalToLocal(tester.getTopLeft(_labelFinder(label))).dx;
}

InkWell _ink(WidgetTester tester, String label) => tester.widget<InkWell>(
  find.ancestor(of: _labelFinder(label), matching: find.byType(InkWell)).first,
);

/// The background the Child row's `Ink` paints.
Color? _rowBackground(WidgetTester tester, String label) {
  final ink = tester.widget<Ink>(
    find.ancestor(of: _labelFinder(label), matching: find.byType(Ink)).first,
  );
  return (ink.decoration! as BoxDecoration).color;
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

Future<void> _tapSwatch(WidgetTester tester, String id, int index) async {
  final swatch = find.byKey(ValueKey('$id.$index'));
  await tester.ensureVisible(swatch);
  await tester.pumpAndSettle();
  await tester.tap(swatch);
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

/// Taps the Child labelled [label] once and lets the double-tap window close,
/// which selects it through the example's handler.
Future<void> _select(WidgetTester tester, String label) async {
  await tester.tap(_labelFinder(label));
  await tester.pump(const Duration(milliseconds: 1100));
  await tester.pumpAndSettle();
}

/// The Taps & state event log, newest first.
List<String> _log(WidgetTester tester) => tester
    .widgetList<Text>(
      find.descendant(
        of: find.byKey(const Key('interaction-log')),
        matching: find.byType(Text),
      ),
    )
    .map((t) => t.data ?? '')
    .toList();

int _code(IconData icon) => icon.codePoint;

void main() {
  final light = FlutterFolderViewTheme<String>.light().childTheme;

  group('Every setting: Child tier', () {
    testWidgets("opens on light()'s Child theme", (tester) async {
      await pumpShell(tester);
      await openFeature(tester, 'Child icons');

      final theme = _child(tester);
      expect((theme.widget! as Icon).icon, Icons.insert_drive_file);
      expect(theme.textStyle, light.textStyle);
      expect(theme.selectedTextStyle, light.selectedTextStyle);
      expect(theme.selectedBackgroundColor, light.selectedBackgroundColor);
      expect(theme.hoverColor, light.hoverColor);
      expect(theme.clickInterval, light.clickInterval);
      expect(theme.widgetResolver, isNull);
      expect(_glyphsOn(tester, _c1), contains(_code(Icons.insert_drive_file)));
    });

    testWidgets('the widget switch installs the sample', (tester) async {
      await pumpShell(tester);
      await openFeature(tester, 'Child icons');

      await _toggle(tester, 'ChildNodeTheme.widget');
      expect(
        _glyphsOn(tester, _c1),
        contains(_code(EverySettingDemo.sampleChildIcon.icon!)),
      );
    });

    testWidgets('the widget resolver swaps only a "(Future)" Child', (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'Child icons');

      await _toggle(tester, 'ChildNodeTheme.widgetResolver');
      expect(
        _glyphsOn(tester, _future),
        contains(_code(EverySettingDemo.sampleFutureIcon.icon!)),
      );
      expect(_glyphsOn(tester, _c1), contains(_code(Icons.insert_drive_file)));
    });

    testWidgets('width, horizontal padding and margin move the label alike; '
        'height does not', (tester) async {
      await pumpShell(tester);
      await openFeature(tester, 'Child icons');
      final base = _labelX(tester, _c1);

      await setSlider(tester, 'ChildNodeTheme.width', 30);
      final byWidth = _labelX(tester, _c1) - base;
      expect(byWidth, greaterThan(0));
      await setSlider(tester, 'ChildNodeTheme.width', 20);

      await _setSide(tester, 'ChildNodeTheme.padding', 'left', 4);
      await _setSide(tester, 'ChildNodeTheme.padding', 'right', 6);
      expect(_labelX(tester, _c1) - base, closeTo(byWidth, 0.01));
      await _setSide(tester, 'ChildNodeTheme.padding', 'left', 0);
      await _setSide(tester, 'ChildNodeTheme.padding', 'right', 0);

      await _setSide(tester, 'ChildNodeTheme.margin', 'left', 10);
      expect(_labelX(tester, _c1) - base, closeTo(byWidth, 0.01));
      await _setSide(tester, 'ChildNodeTheme.margin', 'left', 0);

      await setSlider(tester, 'ChildNodeTheme.height', 32);
      expect(_child(tester).height, 32);
      expect(_labelX(tester, _c1), closeTo(base, 0.01));
    });

    testWidgets('textStyle colour, size and weight paint the Child label', (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'Child label');

      await _tapSwatch(tester, 'ChildNodeTheme.textStyle', 2);
      await chooseDropdown(tester, 'childFontSize', '18');
      await _toggle(tester, 'childBold');

      final style = _label(tester, _c1).text.style!;
      expect(
        style.color!.toARGB32(),
        EverySettingDemo.childTextColors[2]!.toARGB32(),
      );
      expect(style.fontSize, 18);
      expect(style.fontWeight, FontWeight.bold);
    });

    testWidgets('the textStyle and label resolvers act per Child', (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'Child label');
      final before = _label(tester, _c1).text.style!.color!.toARGB32();

      await _toggle(tester, 'ChildNodeTheme.textStyleResolver');
      final future = _label(tester, _future).text.style!;
      expect(
        future.color!.toARGB32(),
        EverySettingDemo.sampleChildStyle.color!.toARGB32(),
      );
      expect(future.fontStyle, FontStyle.italic);
      expect(_label(tester, _c1).text.style!.color!.toARGB32(), before);

      await _toggle(tester, 'ChildNodeTheme.labelResolver');
      expect(_label(tester, _c1).text.toPlainText(), '$_c1 · 1-1-1');
    });

    testWidgets('a selected Child merges selectedTextStyle over its style and '
        'paints selectedBackgroundColor', (tester) async {
      await pumpShell(tester);
      // A non-default size, so a replaced (not merged) style would lose it.
      await openFeature(tester, 'Child label');
      await chooseDropdown(tester, 'childFontSize', '18');
      await openFeature(tester, 'Child selection');
      await _tapSwatch(tester, 'ChildNodeTheme.selectedTextStyle', 2);
      await _tapSwatch(tester, 'ChildNodeTheme.selectedBackgroundColor', 2);

      await _select(tester, _c1);
      expect(renderedFolderView(tester).selectedNodeIds, {'1-1-1'});
      final style = _label(tester, _c1).text.style!;
      expect(style.fontWeight, FontWeight.bold);
      expect(
        style.color!.toARGB32(),
        EverySettingDemo.childSelectedColors[2]!.toARGB32(),
      );
      // Merged: the label's own size is kept.
      expect(style.fontSize, 18);
      expect(
        _rowBackground(tester, _c1),
        EverySettingDemo.childSelectedBackgrounds[2],
      );
      expect(_rowBackground(tester, _future), Colors.transparent);
    });

    testWidgets('the selectedTextStyle resolver wins for a selected "(Future)" '
        'Child only', (tester) async {
      await pumpShell(tester);
      await openFeature(tester, 'Child selection');
      await _toggle(tester, 'ChildNodeTheme.selectedTextStyleResolver');

      await _select(tester, _future);
      final style = _label(tester, _future).text.style!;
      expect(style.decoration, TextDecoration.underline);
      // Instead of selectedTextStyle, not on top of it: no bold.
      expect(style.fontWeight, isNot(FontWeight.bold));
      expect(
        style.color!.toARGB32(),
        EverySettingDemo.sampleSelectedStyle.color!.toARGB32(),
      );

      await _select(tester, _c1);
      expect(
        _label(tester, _c1).text.style!.decoration,
        isNot(TextDecoration.underline),
      );
      expect(_label(tester, _c1).text.style!.fontWeight, FontWeight.bold);
    });

    testWidgets('hover, splash and highlight colours reach the Child row', (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'Child ink');

      await _tapSwatch(tester, 'ChildNodeTheme.hoverColor', 2);
      await _tapSwatch(tester, 'ChildNodeTheme.splashColor', 2);
      await _tapSwatch(tester, 'ChildNodeTheme.highlightColor', 2);
      final ink = _ink(tester, _c1);
      expect(ink.hoverColor, EverySettingDemo.childHoverColors[2]);
      expect(ink.splashColor, EverySettingDemo.childSplashColors[2]);
      expect(ink.highlightColor, EverySettingDemo.childHighlightColors[2]);
    });

    testWidgets('clickInterval is the double-tap window', (tester) async {
      await pumpShell(tester);
      Future<void> twoTaps(Duration gap) async {
        await tester.tap(_labelFinder(_c1));
        await tester.pump(gap);
        await tester.tap(_labelFinder(_c1));
        await tester.pump(const Duration(milliseconds: 1100));
        await tester.pumpAndSettle();
      }

      // Default 300 ms: a second tap after 200 ms is a double tap.
      await openFeature(tester, 'Taps & state');
      await twoTaps(const Duration(milliseconds: 200));
      expect(_log(tester).first, startsWith('onDoubleNodeTap'));

      await openFeature(tester, 'Child ink');
      await setSlider(tester, 'ChildNodeTheme.clickInterval', 100);
      expect(_child(tester).clickInterval, 100);
      await openFeature(tester, 'Taps & state');
      await twoTaps(const Duration(milliseconds: 200));
      expect(_log(tester).take(2), everyElement(startsWith('onNodeTap')));
    });

    testWidgets('moving a Child setting clears the Light preset', (
      tester,
    ) async {
      await pumpShell(tester);
      ChoiceChip lightChip() => tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('Light'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(lightChip().selected, isTrue);

      await openFeature(tester, 'Child ink');
      await setSlider(tester, 'ChildNodeTheme.clickInterval', 500);
      expect(lightChip().selected, isFalse);
    });

    testWidgets('the Dark preset resets the Child tier to dark()', (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'Child label');
      await _toggle(tester, 'ChildNodeTheme.labelResolver');

      await tester.tap(
        find.ancestor(of: find.text('Dark'), matching: find.byType(ChoiceChip)),
      );
      await tester.pumpAndSettle();
      final dark = FlutterFolderViewTheme<String>.dark().childTheme;
      expect(_child(tester).labelResolver, isNull);
      expect(_child(tester).textStyle, dark.textStyle);
      expect(
        _child(tester).selectedBackgroundColor,
        dark.selectedBackgroundColor,
      );
      expect(_child(tester).hoverColor, dark.hoverColor);
      expect(_label(tester, _c1).text.toPlainText(), _c1);
    });

    testWidgets('the childTheme control shows the sub-theme as code', (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'Child icons');
      await setSlider(tester, 'ChildNodeTheme.width', 24);

      final code = tester
          .widget<SelectableText>(
            find.descendant(
              of: find.byWidgetPredicate(
                (w) =>
                    w is SettingsControl &&
                    w.id == 'FlutterFolderViewTheme.childTheme',
              ),
              matching: find.byType(SelectableText),
            ),
          )
          .data!;
      expect(code, startsWith('childTheme: ChildNodeTheme<String>(\n'));
      expect(code, contains('  width: 24,\n'));
      expect(
        code,
        contains(
          '  widget: Icon(Icons.insert_drive_file, color: Colors.grey.shade700, '
          'size: 20),\n',
        ),
      );
      expect(
        code,
        contains(
          '  selectedTextStyle: TextStyle(fontWeight: FontWeight.bold),\n',
        ),
      );
      expect(
        code,
        contains('  selectedBackgroundColor: Colors.blue.shade50,\n'),
      );
      expect(code, contains('  clickInterval: 300,\n'));
      expect(code, isNot(contains('Resolver')));
    });
  });
}
