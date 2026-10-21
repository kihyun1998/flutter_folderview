import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/shell_harness.dart';

const _folder = 'Theme System Architecture'; // id 1

Finder _inView(Finder matching) =>
    find.descendant(of: find.byType(FolderView<String>), matching: matching);

/// The ARGB colour the Folder label is painted in.
int _labelColor(WidgetTester tester) => tester
    .widget<RichText>(
      _inView(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText() == _folder,
        ),
      ),
    )
    .text
    .style!
    .color!
    .toARGB32();

/// The theme the rendered `FolderView` draws with, however it arrived.
FlutterFolderViewTheme<String> _effective(WidgetTester tester) =>
    renderedFolderView(tester).theme ??
    FolderViewTheme.of<String>(tester.element(find.byType(FolderView<String>)));

ChoiceChip _chip(WidgetTester tester, String title) =>
    tester.widget<ChoiceChip>(
      find.ancestor(of: find.text(title), matching: find.byType(ChoiceChip)),
    );

Future<void> _applyPreset(WidgetTester tester, String title) async {
  await tester.tap(
    find.ancestor(of: find.text(title), matching: find.byType(ChoiceChip)),
  );
  await tester.pumpAndSettle();
}

String _injectionCode(WidgetTester tester) => tester
    .widget<SelectableText>(
      find.descendant(
        of: find.byWidgetPredicate(
          (w) => w is SettingsControl && w.id == 'FolderViewTheme.data',
        ),
        matching: find.byType(SelectableText),
      ),
    )
    .data!;

void main() {
  final light = FlutterFolderViewTheme<String>.light();
  final dark = FlutterFolderViewTheme<String>.dark();
  final lightText = light.folderTheme.textStyle!.color!.toARGB32();
  final darkText = dark.folderTheme.textStyle!.color!.toARGB32();

  group('Every setting: Theme injection and presets', () {
    testWidgets('opens on the Light preset, through the theme parameter', (
      tester,
    ) async {
      await pumpShell(tester);

      expect(_chip(tester, 'Light').selected, isTrue);
      expect(_chip(tester, 'Dark').selected, isFalse);
      expect(renderedFolderView(tester).theme, isNotNull);
      expect(_labelColor(tester), lightText);
    });

    testWidgets('the Dark preset paints dark() and resets every theme knob '
        'to it', (tester) async {
      await pumpShell(tester);
      await openFeature(tester, 'Rows & padding');
      await setSlider(tester, 'FlutterFolderViewTheme.rowHeight', 60);

      await _applyPreset(tester, 'Dark');
      expect(_chip(tester, 'Dark').selected, isTrue);
      expect(_labelColor(tester), darkText);
      final theme = _effective(tester);
      expect(theme.rowHeight, dark.rowHeight);
      expect(theme.lineTheme, dark.lineTheme);
      expect(theme.scrollbarTheme, dark.scrollbarTheme);
      expect(theme.expandIconTheme.color, dark.expandIconTheme.color);
    });

    testWidgets('moving a theme knob leaves the preset; Light resets it', (
      tester,
    ) async {
      await pumpShell(tester);
      await _applyPreset(tester, 'Dark');
      await openFeature(tester, 'Rows & padding');

      await setSlider(tester, 'FlutterFolderViewTheme.rowHeight', 50);
      expect(_chip(tester, 'Dark').selected, isFalse);
      expect(_chip(tester, 'Light').selected, isFalse);
      // The base stays dark until a preset is applied.
      expect(_labelColor(tester), darkText);

      await _applyPreset(tester, 'Light');
      expect(_chip(tester, 'Light').selected, isTrue);
      expect(_effective(tester).rowHeight, light.rowHeight);
      expect(_labelColor(tester), lightText);
    });

    testWidgets('through a FolderViewTheme ancestor the view draws the same '
        'theme', (tester) async {
      await pumpShell(tester);
      await _applyPreset(tester, 'Dark');
      final viaParameter = _effective(tester);
      expect(_labelColor(tester), darkText);

      await openFeature(tester, 'Theme injection');
      await chooseDropdown(tester, 'FolderView.theme', 'Ancestor');
      expect(renderedFolderView(tester).theme, isNull);
      final ancestor = tester.widget<FolderViewTheme<String>>(
        find.ancestor(
          of: find.byType(FolderView<String>),
          matching: find.byType(FolderViewTheme<String>),
        ),
      );
      expect(identical(ancestor.data, viaParameter), isTrue);
      // Dark, not the light() fallback a missed ancestor would give.
      expect(_labelColor(tester), darkText);
    });

    testWidgets('on the ancestor path a theme knob still reaches the rows', (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'Theme injection');
      await chooseDropdown(tester, 'FolderView.theme', 'Ancestor');

      await openFeature(tester, 'Rows & padding');
      await setSlider(tester, 'FlutterFolderViewTheme.rowHeight', 56);
      expect(renderedFolderView(tester).theme, isNull);
      expect(
        tester.widget<ListView>(_inView(find.byType(ListView))).itemExtent,
        56,
      );
    });

    testWidgets("after Dark the expand icon's code text names dark()'s grey", (
      tester,
    ) async {
      await pumpShell(tester);
      await _applyPreset(tester, 'Dark');
      await openFeature(tester, 'Expand icon');

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
      expect(code, contains('  color: Color(0xFFBDBDBD),\n'));
    });

    testWidgets('the FolderViewTheme.data control writes the chosen path', (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'Theme injection');

      expect(
        _injectionCode(tester),
        'FolderView<String>(\n'
        '  theme: theme,\n'
        '  // data, mode, …\n'
        ')',
      );
      await chooseDropdown(tester, 'FolderView.theme', 'Ancestor');
      expect(
        _injectionCode(tester),
        'FolderViewTheme<String>(\n'
        '  data: theme,\n'
        '  child: FolderView<String>(\n'
        '    // data, mode, …\n'
        '  ),\n'
        ')',
      );
    });

    testWidgets('a preset themes the tree only, not the shell', (tester) async {
      await pumpShell(tester);

      await _applyPreset(tester, 'Dark');
      expect(_labelColor(tester), darkText);
      expect(
        Theme.of(tester.element(find.byType(FeatureListPane))).brightness,
        Brightness.light,
      );
    });
  });
}
