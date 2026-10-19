import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/shell_harness.dart';

Future<void> _openLayout(WidgetTester tester) async {
  await pumpShell(tester);
  await openFeature(tester, 'Rows & padding');
}

/// The corner radius of the first row's ink surface.
BorderRadiusGeometry? _inkRadius(WidgetTester tester) {
  final ink = tester.widget<Ink>(
    find
        .descendant(
          of: find.byType(FolderView<String>),
          matching: find.byType(Ink),
        )
        .first,
  );
  return (ink.decoration! as BoxDecoration).borderRadius;
}

FlutterFolderViewTheme<String> _theme(WidgetTester tester) =>
    renderedFolderView(tester).theme!;

/// The rows' `ListView` inside the rendered `FolderView`.
ListView _list(WidgetTester tester) => tester.widget<ListView>(
  find.descendant(
    of: find.byType(FolderView<String>),
    matching: find.byType(ListView),
  ),
);

/// Calls the `onChanged` of the slider labelled [label] in the control with
/// [id].
Future<void> _setSide(
  WidgetTester tester,
  String id,
  String label,
  double value,
) async {
  final row = find.descendant(
    of: find.byWidgetPredicate((w) => w is SettingsControl && w.id == id),
    matching: find.byKey(ValueKey('$id.$label')),
  );
  tester.widget<Slider>(row).onChanged!(value);
  await tester.pumpAndSettle();
}

/// The code text drawn by the control with [id].
String _code(WidgetTester tester, String id) => tester
    .widget<SelectableText>(
      find.descendant(
        of: find.byWidgetPredicate((w) => w is SettingsControl && w.id == id),
        matching: find.byType(SelectableText),
      ),
    )
    .data!;

void main() {
  group('Every setting: Layout', () {
    testWidgets('opens on the light theme the view would use with no theme', (
      tester,
    ) async {
      await _openLayout(tester);

      final light = FlutterFolderViewTheme<String>.light();
      final theme = _theme(tester);
      expect(theme.rowHeight, light.rowHeight);
      expect(theme.rowSpacing, light.rowSpacing);
      expect(theme.animationDuration, light.animationDuration);
      expect(
        theme.spacingTheme.contentPadding,
        light.spacingTheme.contentPadding,
      );
      expect(
        theme.nodeStyleTheme.borderRadius,
        light.nodeStyleTheme.borderRadius,
      );
      expect(theme.lineTheme, light.lineTheme);
    });

    testWidgets('Row height sets rowHeight, and each row is that tall', (
      tester,
    ) async {
      await _openLayout(tester);

      await setSlider(tester, 'FlutterFolderViewTheme.rowHeight', 60);
      expect(_theme(tester).rowHeight, 60);
      expect(_list(tester).itemExtent, 60);
    });

    testWidgets('Row spacing sets rowSpacing, and adds to each row', (
      tester,
    ) async {
      await _openLayout(tester);

      await setSlider(tester, 'FlutterFolderViewTheme.rowSpacing', 6);
      expect(_theme(tester).rowSpacing, 6);
      expect(_list(tester).itemExtent, 40 + 6);
    });

    testWidgets('Content padding sets each side, and pads the rows', (
      tester,
    ) async {
      await _openLayout(tester);
      const id = 'FolderViewSpacingTheme.contentPadding';

      await _setSide(tester, id, 'left', 12);
      await _setSide(tester, id, 'top', 4);
      await _setSide(tester, id, 'right', 8);
      await _setSide(tester, id, 'bottom', 2);

      const expected = EdgeInsets.fromLTRB(12, 4, 8, 2);
      expect(_theme(tester).spacingTheme.contentPadding, expected);
      expect(_list(tester).padding, expected);
    });

    testWidgets('Border radius sets nodeStyleTheme.borderRadius', (
      tester,
    ) async {
      await _openLayout(tester);

      await setSlider(tester, 'FolderViewNodeStyleTheme.borderRadius', 0);
      expect(_theme(tester).nodeStyleTheme.borderRadius, 0);
      expect(_inkRadius(tester), BorderRadius.zero);

      await setSlider(tester, 'FolderViewNodeStyleTheme.borderRadius', 12);
      expect(_inkRadius(tester), BorderRadius.circular(12));
    });

    testWidgets('Animation duration sets animationDuration', (tester) async {
      await _openLayout(tester);

      await setSlider(tester, 'FlutterFolderViewTheme.animationDuration', 500);
      expect(_theme(tester).animationDuration, 500);
    });

    testWidgets('the container controls show the sub-themes as code', (
      tester,
    ) async {
      await _openLayout(tester);

      await _setSide(
        tester,
        'FolderViewSpacingTheme.contentPadding',
        'left',
        12,
      );
      await setSlider(tester, 'FolderViewNodeStyleTheme.borderRadius', 4);

      expect(
        _code(tester, 'FlutterFolderViewTheme.spacingTheme'),
        'spacingTheme: const FolderViewSpacingTheme(\n'
        '  contentPadding: EdgeInsets.fromLTRB(12, 0, 0, 0),\n'
        '),',
      );
      expect(
        _code(tester, 'FlutterFolderViewTheme.nodeStyleTheme'),
        'nodeStyleTheme: const FolderViewNodeStyleTheme(borderRadius: 4),',
      );
    });

    testWidgets('the theme is one instance until a layout setting changes', (
      tester,
    ) async {
      await _openLayout(tester);
      final before = _theme(tester);

      // A setting outside the theme rebuilds the stage.
      await openFeature(tester, 'Scale');
      await setSlider(tester, 'FolderView.scaleStep', 0.2);
      expect(renderedFolderView(tester).scaleStep, closeTo(0.2, 1e-9));
      expect(identical(_theme(tester), before), isTrue);

      await openFeature(tester, 'Rows & padding');
      await setSlider(tester, 'FlutterFolderViewTheme.rowHeight', 50);
      expect(identical(_theme(tester), before), isFalse);
    });

    testWidgets('the note says animationDuration drives nothing', (
      tester,
    ) async {
      await _openLayout(tester);

      final note = tester.widget<Text>(find.byKey(const Key('layout-note')));
      expect(note.data, contains('animationDuration is read nowhere'));
    });
  });
}
