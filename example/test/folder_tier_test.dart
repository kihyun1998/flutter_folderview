import 'package:example/app/every_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/shell_harness.dart';

const _f1 = 'Theme System Architecture'; // id 1, two Parents, expanded
const _f3 =
    'Usage Example with really long long long long label to test horizontal '
    'scroll'; // id 3, one Parent, expanded

Finder _inView(Finder matching) =>
    find.descendant(of: find.byType(FolderView<String>), matching: matching);

FolderNodeTheme<String> _folder(WidgetTester tester) =>
    renderedFolderView(tester).theme!.folderTheme;

/// The label `RichText` of the Folder whose label starts with [label].
RichText _label(WidgetTester tester, String label) => tester.widget<RichText>(
  _inView(
    find.byWidgetPredicate(
      (w) => w is RichText && w.text.toPlainText().startsWith(label),
    ),
  ),
);

double _rowY(WidgetTester tester, String label) => tester
    .getCenter(
      _inView(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().startsWith(label),
        ),
      ),
    )
    .dy;

/// The icon glyphs drawn on the row of the Folder labelled [label].
Set<int> _glyphsOn(WidgetTester tester, String label) {
  final view =
      tester.renderObject(find.byType(FolderView<String>)) as RenderBox;
  final scale =
      view.localToGlobal(const Offset(0, 1)).dy -
      view.localToGlobal(Offset.zero).dy;
  final y = _rowY(tester, label);
  return {
    for (final r in tester.widgetList<RichText>(_inView(find.byType(RichText))))
      if (r.text.toPlainText().runes.length == 1 &&
          (tester.getCenter(find.byWidget(r)).dy - y).abs() < 20 * scale)
        r.text.toPlainText().runes.first,
  };
}

/// The Folder label's left edge in the view's own pixels.
double _labelX(WidgetTester tester, String label) {
  final view =
      tester.renderObject(find.byType(FolderView<String>)) as RenderBox;
  final at = tester.getTopLeft(
    _inView(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().startsWith(label),
      ),
    ),
  );
  return view.globalToLocal(at).dx;
}

/// The ink well of the Folder row labelled [label].
InkWell _ink(WidgetTester tester, String label) => tester.widget<InkWell>(
  find
      .ancestor(
        of: _inView(
          find.byWidgetPredicate(
            (w) => w is RichText && w.text.toPlainText().startsWith(label),
          ),
        ),
        matching: find.byType(InkWell),
      )
      .first,
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

/// Taps the Folder row labelled [label], which toggles its expansion.
Future<void> _tapFolder(WidgetTester tester, String label) async {
  await tester.tap(
    _inView(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().startsWith(label),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

int _code(IconData icon) => icon.codePoint;

/// Asserts [label] is laid out at its full width, after asserting the window
/// where a short measurement would show: wider than the view, and narrower
/// than `SizeService`'s cap of three times it.
void _expectFitsInWindow(WidgetTester tester, RichText label) {
  final view =
      tester.renderObject(find.byType(FolderView<String>)) as RenderBox;
  final paragraph =
      tester.renderObject(find.byWidget(label)) as RenderParagraph;
  final needed = paragraph.getMaxIntrinsicWidth(double.infinity);
  expect(needed, greaterThan(view.size.width), reason: 'not past the view');
  expect(needed + 100, lessThan(view.size.width * 3), reason: 'past the cap');
  expect(paragraph.didExceedMaxLines, isFalse);
}

void main() {
  final light = FlutterFolderViewTheme<String>.light().folderTheme;

  group('Every setting: Folder tier', () {
    testWidgets("opens on light()'s Folder theme; an expanded Folder shows "
        'its open icon', (tester) async {
      await pumpShell(tester);
      await openFeature(tester, 'Folder icons');

      final theme = _folder(tester);
      expect((theme.widget! as Icon).icon, Icons.folder);
      expect((theme.openWidget! as Icon).icon, Icons.folder_open);
      expect(theme.width, light.width);
      expect(theme.height, light.height);
      expect(theme.textStyle, light.textStyle);
      expect(theme.hoverColor, light.hoverColor);
      expect(theme.widgetResolver, isNull);
      expect(theme.labelResolver, isNull);
      expect(_glyphsOn(tester, _f1), contains(_code(Icons.folder_open)));
    });

    testWidgets('the widget switch installs the sample, shown when collapsed', (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'Folder icons');
      await _toggle(tester, 'FolderNodeTheme.widget');
      await _tapFolder(tester, _f1);

      expect(
        (_folder(tester).widget! as Icon).icon,
        EverySettingDemo.sampleFolderIcon.icon,
      );
      expect(
        _glyphsOn(tester, _f1),
        contains(_code(EverySettingDemo.sampleFolderIcon.icon!)),
      );
    });

    testWidgets('openWidget: the sample when expanded, or none, which falls '
        'back to widget', (tester) async {
      await pumpShell(tester);
      await openFeature(tester, 'Folder icons');

      await chooseDropdown(tester, 'FolderNodeTheme.openWidget', 'Sample');
      expect(
        _glyphsOn(tester, _f1),
        contains(_code(EverySettingDemo.sampleFolderOpenIcon.icon!)),
      );

      await chooseDropdown(tester, 'FolderNodeTheme.openWidget', 'None');
      expect(_folder(tester).openWidget, isNull);
      expect(_glyphsOn(tester, _f1), contains(_code(Icons.folder)));
      expect(_glyphsOn(tester, _f1), isNot(contains(_code(Icons.folder_open))));
    });

    testWidgets('width, horizontal padding and margin move the label alike; '
        'height does not', (tester) async {
      await pumpShell(tester);
      await openFeature(tester, 'Folder icons');
      final base = _labelX(tester, _f1);

      await setSlider(tester, 'FolderNodeTheme.width', 30);
      final byWidth = _labelX(tester, _f1) - base;
      expect(byWidth, greaterThan(0));
      await setSlider(tester, 'FolderNodeTheme.width', 20);

      await _setSide(tester, 'FolderNodeTheme.padding', 'left', 4);
      await _setSide(tester, 'FolderNodeTheme.padding', 'right', 6);
      expect(_labelX(tester, _f1) - base, closeTo(byWidth, 0.01));
      await _setSide(tester, 'FolderNodeTheme.padding', 'left', 0);
      await _setSide(tester, 'FolderNodeTheme.padding', 'right', 0);

      await _setSide(tester, 'FolderNodeTheme.margin', 'left', 10);
      expect(_labelX(tester, _f1) - base, closeTo(byWidth, 0.01));
      await _setSide(tester, 'FolderNodeTheme.margin', 'left', 0);

      await setSlider(tester, 'FolderNodeTheme.height', 32);
      expect(_folder(tester).height, 32);
      expect(_labelX(tester, _f1), closeTo(base, 0.01));
    });

    testWidgets('textStyle colour, size and weight paint the Folder label', (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'Folder label');

      await _tapSwatch(tester, 'FolderNodeTheme.textStyle', 2);
      await chooseDropdown(tester, 'folderFontSize', '18');
      await tester.tap(
        find.descendant(
          of: find.byWidgetPredicate(
            (w) => w is SettingsControl && w.id == 'folderBold',
          ),
          matching: find.byType(Switch),
        ),
      );
      await tester.pumpAndSettle();

      final style = _label(tester, _f1).text.style!;
      expect(
        style.color!.toARGB32(),
        EverySettingDemo.folderTextColors[2]!.toARGB32(),
      );
      expect(style.fontSize, 18);
      expect(style.fontWeight, FontWeight.bold);
    });

    testWidgets('the textStyle resolver restyles only the single-Parent '
        'Folder', (tester) async {
      await pumpShell(tester);
      await openFeature(tester, 'Folder label');
      final before = _label(tester, _f1).text.style!.color!.toARGB32();

      await _toggle(tester, 'FolderNodeTheme.textStyleResolver');
      expect(
        _label(tester, _f3).text.style!.color!.toARGB32(),
        EverySettingDemo.sampleFolderStyle.color!.toARGB32(),
      );
      expect(_label(tester, _f1).text.style!.color!.toARGB32(), before);
    });

    testWidgets('the label resolver adds the Parent count, and the long label '
        'still fits', (tester) async {
      await pumpShell(tester);
      // The tablet frame is narrower than the long Folder's row but more than
      // a third of it, so the row is laid out at the measured content width,
      // under SizeService's 3× cap, and a short measurement would cut it.
      await tester.tap(find.byTooltip(ViewportSpec.tablet.label));
      await tester.pumpAndSettle();
      await openFeature(tester, 'Folder label');

      await _toggle(tester, 'FolderNodeTheme.labelResolver');
      expect(_label(tester, _f1).text.toPlainText(), '$_f1 (2)');
      final f3 = _label(tester, _f3);
      expect(f3.text.toPlainText(), '$_f3 (1)');
      _expectFitsInWindow(tester, f3);
    });

    testWidgets('the bold textStyle resolver is measured: the long label still '
        'fits', (tester) async {
      await pumpShell(tester);
      await tester.tap(find.byTooltip(ViewportSpec.tablet.label));
      await tester.pumpAndSettle();
      await openFeature(tester, 'Folder label');

      await _toggle(tester, 'FolderNodeTheme.textStyleResolver');
      final f3 = _label(tester, _f3);
      expect(f3.text.style!.fontWeight, FontWeight.bold);
      // The test font is as wide bold as regular, so the sample's larger
      // size is what a short measurement would miss.
      expect(f3.text.style!.fontSize, 16);
      _expectFitsInWindow(tester, f3);
    });

    testWidgets('the icon resolvers swap the single-Parent Folder only', (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'Folder icons');

      await _toggle(tester, 'FolderNodeTheme.openWidgetResolver');
      expect(
        _glyphsOn(tester, _f3),
        contains(_code(EverySettingDemo.sampleSingleParentOpenIcon.icon!)),
      );
      expect(_glyphsOn(tester, _f1), contains(_code(Icons.folder_open)));

      await _toggle(tester, 'FolderNodeTheme.widgetResolver');
      await _tapFolder(tester, _f3);
      await _tapFolder(tester, _f1);
      expect(
        _glyphsOn(tester, _f3),
        contains(_code(EverySettingDemo.sampleSingleParentIcon.icon!)),
      );
      expect(_glyphsOn(tester, _f1), contains(_code(Icons.folder)));
    });

    testWidgets('hover, splash and highlight colours reach the Folder row', (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'Folder ink');

      await _tapSwatch(tester, 'FolderNodeTheme.hoverColor', 2);
      await _tapSwatch(tester, 'FolderNodeTheme.splashColor', 2);
      await _tapSwatch(tester, 'FolderNodeTheme.highlightColor', 2);
      final ink = _ink(tester, _f1);
      expect(ink.hoverColor, EverySettingDemo.folderHoverColors[2]);
      expect(ink.splashColor, EverySettingDemo.folderSplashColors[2]);
      expect(ink.highlightColor, EverySettingDemo.folderHighlightColors[2]);
    });

    testWidgets('moving a Folder setting clears the Light preset', (
      tester,
    ) async {
      await pumpShell(tester);
      ChoiceChip light() => tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('Light'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(light().selected, isTrue);

      await openFeature(tester, 'Folder icons');
      await setSlider(tester, 'FolderNodeTheme.width', 24);
      expect(light().selected, isFalse);
    });

    testWidgets('the Dark preset resets the Folder tier to dark()', (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'Folder label');
      await _toggle(tester, 'FolderNodeTheme.labelResolver');

      await tester.tap(
        find.ancestor(of: find.text('Dark'), matching: find.byType(ChoiceChip)),
      );
      await tester.pumpAndSettle();
      final dark = FlutterFolderViewTheme<String>.dark().folderTheme;
      expect(_folder(tester).labelResolver, isNull);
      expect(_folder(tester).textStyle, dark.textStyle);
      expect(_folder(tester).hoverColor, dark.hoverColor);
      expect(
        (_folder(tester).widget! as Icon).color,
        (dark.widget! as Icon).color,
      );
      expect(_label(tester, _f1).text.toPlainText(), _f1);
    });

    testWidgets('the folderTheme control shows the sub-theme as code', (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'Folder icons');
      await setSlider(tester, 'FolderNodeTheme.width', 24);

      final code = tester
          .widget<SelectableText>(
            find.descendant(
              of: find.byWidgetPredicate(
                (w) =>
                    w is SettingsControl &&
                    w.id == 'FlutterFolderViewTheme.folderTheme',
              ),
              matching: find.byType(SelectableText),
            ),
          )
          .data!;
      expect(code, startsWith('folderTheme: FolderNodeTheme<String>(\n'));
      expect(code, contains('  width: 24,\n'));
      expect(
        code,
        contains(
          '  widget: Icon(Icons.folder, color: Colors.grey.shade700, '
          'size: 20),\n',
        ),
      );
      expect(code, isNot(contains('Resolver')));
    });
  });
}
