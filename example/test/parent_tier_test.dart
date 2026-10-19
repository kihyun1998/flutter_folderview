import 'package:example/app/every_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/shell_harness.dart';

const _p1 = 'FlutterFolderViewTheme (Master Class)'; // id 1-1, 3 Children
const _p2 = 'FolderViewTheme (InheritedWidget)'; // id 1-2, 2 Children

Finder _inView(Finder matching) =>
    find.descendant(of: find.byType(FolderView<String>), matching: matching);

ParentNodeTheme<String> _parent(WidgetTester tester) =>
    renderedFolderView(tester).theme!.parentTheme;

Finder _labelFinder(String label) => _inView(
  find.byWidgetPredicate(
    (w) => w is RichText && w.text.toPlainText().startsWith(label),
  ),
);

RichText _label(WidgetTester tester, String label) =>
    tester.widget<RichText>(_labelFinder(label));

/// The icon glyphs drawn on the row of the Parent labelled [label].
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

/// Taps the Parent row labelled [label], which toggles its expansion.
Future<void> _tapParent(WidgetTester tester, String label) async {
  await tester.tap(_labelFinder(label));
  await tester.pumpAndSettle();
}

Future<void> _treeMode(WidgetTester tester) async {
  await openFeature(tester, 'View Mode');
  await chooseDropdown(tester, 'FolderView.mode', 'tree');
}

int _code(IconData icon) => icon.codePoint;

void main() {
  final light = FlutterFolderViewTheme<String>.light().parentTheme;

  group('Every setting: Parent tier', () {
    testWidgets("opens on light()'s Parent theme, which sets no openWidget", (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'Parent icons');

      final theme = _parent(tester);
      expect((theme.widget! as Icon).icon, Icons.account_tree);
      expect(theme.openWidget, isNull);
      expect(theme.textStyle, light.textStyle);
      expect(theme.hoverColor, light.hoverColor);
      expect(theme.widgetResolver, isNull);
      expect(_glyphsOn(tester, _p1), contains(_code(Icons.account_tree)));
    });

    testWidgets('the widget switch installs the sample', (tester) async {
      await pumpShell(tester);
      await openFeature(tester, 'Parent icons');

      await _toggle(tester, 'ParentNodeTheme.widget');
      expect(
        _glyphsOn(tester, _p1),
        contains(_code(EverySettingDemo.sampleParentIcon.icon!)),
      );
    });

    testWidgets('openWidget shows only in Tree Mode', (tester) async {
      await pumpShell(tester);
      await openFeature(tester, 'Parent icons');
      await chooseDropdown(tester, 'ParentNodeTheme.openWidget', 'Sample');
      final open = _code(EverySettingDemo.sampleParentOpenIcon.icon!);

      // Folder Mode: the expanded Parent keeps its widget.
      expect(_glyphsOn(tester, _p1), isNot(contains(open)));
      expect(_glyphsOn(tester, _p1), contains(_code(Icons.account_tree)));

      await _treeMode(tester);
      expect(renderedFolderView(tester).mode, ViewMode.tree);
      expect(_glyphsOn(tester, _p1), contains(open));
    });

    testWidgets('width, horizontal padding and margin move the label alike; '
        'height does not', (tester) async {
      await pumpShell(tester);
      await openFeature(tester, 'Parent icons');
      final base = _labelX(tester, _p1);

      await setSlider(tester, 'ParentNodeTheme.width', 30);
      final byWidth = _labelX(tester, _p1) - base;
      expect(byWidth, greaterThan(0));
      await setSlider(tester, 'ParentNodeTheme.width', 20);

      await _setSide(tester, 'ParentNodeTheme.padding', 'left', 4);
      await _setSide(tester, 'ParentNodeTheme.padding', 'right', 6);
      expect(_labelX(tester, _p1) - base, closeTo(byWidth, 0.01));
      await _setSide(tester, 'ParentNodeTheme.padding', 'left', 0);
      await _setSide(tester, 'ParentNodeTheme.padding', 'right', 0);

      await _setSide(tester, 'ParentNodeTheme.margin', 'left', 10);
      expect(_labelX(tester, _p1) - base, closeTo(byWidth, 0.01));
      await _setSide(tester, 'ParentNodeTheme.margin', 'left', 0);

      await setSlider(tester, 'ParentNodeTheme.height', 32);
      expect(_parent(tester).height, 32);
      expect(_labelX(tester, _p1), closeTo(base, 0.01));
    });

    testWidgets('textStyle colour, size and weight paint the Parent label', (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'Parent label');

      await _tapSwatch(tester, 'ParentNodeTheme.textStyle', 2);
      await chooseDropdown(tester, 'parentFontSize', '18');
      await _toggle(tester, 'parentBold');

      final style = _label(tester, _p1).text.style!;
      expect(
        style.color!.toARGB32(),
        EverySettingDemo.parentTextColors[2]!.toARGB32(),
      );
      expect(style.fontSize, 18);
      expect(style.fontWeight, FontWeight.bold);
    });

    testWidgets('the textStyle resolver restyles only a two-Child Parent', (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'Parent label');
      final before = _label(tester, _p1).text.style!.color!.toARGB32();

      await _toggle(tester, 'ParentNodeTheme.textStyleResolver');
      final p2 = _label(tester, _p2);
      expect(
        p2.text.style!.color!.toARGB32(),
        EverySettingDemo.sampleParentStyle.color!.toARGB32(),
      );
      expect(p2.text.style!.fontWeight, FontWeight.bold);
      // The test font is as wide bold as regular, so the sample's larger
      // size is what a short measurement would miss.
      expect(p2.text.style!.fontSize, 16);
      expect(_label(tester, _p1).text.style!.color!.toARGB32(), before);
    });

    testWidgets('the label resolver adds the Child count', (tester) async {
      await pumpShell(tester);
      await openFeature(tester, 'Parent label');

      await _toggle(tester, 'ParentNodeTheme.labelResolver');
      final p1 = _label(tester, _p1);
      expect(p1.text.toPlainText(), '$_p1 (3)');
      expect(_label(tester, _p2).text.toPlainText(), '$_p2 (2)');
    });

    testWidgets('the icon resolvers swap a two-Child Parent only', (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'Parent icons');

      await _toggle(tester, 'ParentNodeTheme.widgetResolver');
      expect(
        _glyphsOn(tester, _p2),
        contains(_code(EverySettingDemo.sampleTwoChildIcon.icon!)),
      );
      expect(_glyphsOn(tester, _p1), contains(_code(Icons.account_tree)));

      await _toggle(tester, 'ParentNodeTheme.openWidgetResolver');
      await _treeMode(tester);
      await _tapParent(tester, _p2);
      expect(
        _glyphsOn(tester, _p2),
        contains(_code(EverySettingDemo.sampleTwoChildOpenIcon.icon!)),
      );
      expect(_glyphsOn(tester, _p1), contains(_code(Icons.account_tree)));
    });

    testWidgets('hover, splash and highlight colours reach the Parent row', (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'Parent ink');

      await _tapSwatch(tester, 'ParentNodeTheme.hoverColor', 2);
      await _tapSwatch(tester, 'ParentNodeTheme.splashColor', 2);
      await _tapSwatch(tester, 'ParentNodeTheme.highlightColor', 2);
      final ink = _ink(tester, _p1);
      expect(ink.hoverColor, EverySettingDemo.parentHoverColors[2]);
      expect(ink.splashColor, EverySettingDemo.parentSplashColors[2]);
      expect(ink.highlightColor, EverySettingDemo.parentHighlightColors[2]);
    });

    testWidgets('moving a Parent setting clears the Light preset', (
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

      await openFeature(tester, 'Parent icons');
      await setSlider(tester, 'ParentNodeTheme.width', 24);
      expect(lightChip().selected, isFalse);
    });

    testWidgets('the Dark preset resets the Parent tier to dark()', (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'Parent label');
      await _toggle(tester, 'ParentNodeTheme.labelResolver');

      await tester.tap(
        find.ancestor(of: find.text('Dark'), matching: find.byType(ChoiceChip)),
      );
      await tester.pumpAndSettle();
      final dark = FlutterFolderViewTheme<String>.dark().parentTheme;
      expect(_parent(tester).labelResolver, isNull);
      expect(_parent(tester).textStyle, dark.textStyle);
      expect(_parent(tester).hoverColor, dark.hoverColor);
      expect(
        (_parent(tester).widget! as Icon).color,
        (dark.widget! as Icon).color,
      );
      expect(_label(tester, _p1).text.toPlainText(), _p1);
    });

    testWidgets('the parentTheme control shows the sub-theme as code', (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'Parent icons');
      await setSlider(tester, 'ParentNodeTheme.width', 24);

      final code = tester
          .widget<SelectableText>(
            find.descendant(
              of: find.byWidgetPredicate(
                (w) =>
                    w is SettingsControl &&
                    w.id == 'FlutterFolderViewTheme.parentTheme',
              ),
              matching: find.byType(SelectableText),
            ),
          )
          .data!;
      expect(code, startsWith('parentTheme: ParentNodeTheme<String>(\n'));
      expect(code, contains('  width: 24,\n'));
      expect(
        code,
        contains(
          '  widget: Icon(Icons.account_tree, color: Colors.grey.shade700, '
          'size: 20),\n',
        ),
      );
      expect(code, isNot(contains('openWidget')));
      expect(code, isNot(contains('Resolver')));
    });
  });
}
