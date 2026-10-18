import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/shell_harness.dart';

Future<void> _openScale(WidgetTester tester) async {
  await pumpShell(tester);
  await openFeature(tester, 'Scale');
}

Future<void> _toggle(WidgetTester tester, String id) async {
  final target = find.descendant(
    of: find.byWidgetPredicate((w) => w is SettingsControl && w.id == id),
    matching: find.byType(Switch),
  );
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

/// The vertical list's scroll offset inside the rendered `FolderView`.
double _offset(WidgetTester tester) => tester
    .widget<ListView>(
      find.descendant(
        of: find.byType(FolderView<String>),
        matching: find.byType(ListView),
      ),
    )
    .controller!
    .offset;

/// Turns the mouse wheel by [dy] over the tree and lets any wheel motion
/// settle.
Future<void> _wheel(WidgetTester tester, double dy) async {
  final pointer = TestPointer(1, PointerDeviceKind.mouse);
  final at = tester.getCenter(find.byType(FolderView<String>));
  await tester.sendEventToBinding(pointer.hover(at));
  await tester.sendEventToBinding(pointer.scroll(Offset(0, dy)));
  await tester.pumpAndSettle();
}

/// [_wheel] with Ctrl held, the Scale Modifier on Windows.
Future<void> _ctrlWheel(WidgetTester tester, double dy) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.windows;
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  try {
    await _wheel(tester, dy);
  } finally {
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    debugDefaultTargetPlatformOverride = null;
  }
}

/// Generated data with every Folder and Parent expanded: taller than the
/// stage, so a scroll is observable.
Future<void> _tallTree(WidgetTester tester) async {
  await openFeature(tester, 'Data');
  await chooseDropdown(tester, 'FolderView.data', 'Generated');
  await openFeature(tester, 'Taps & state');
  final expandAll = find.descendant(
    of: find.byWidgetPredicate(
      (w) => w is SettingsControl && w.id == 'FolderView.expandedNodeIds',
    ),
    matching: find.text('Expand all'),
  );
  await tester.ensureVisible(expandAll);
  await tester.tap(expandAll);
  await tester.pumpAndSettle();
  await openFeature(tester, 'Scale');
}

void main() {
  group('Every setting: Scale', () {
    testWidgets('opens on the library defaults, with the handler on', (
      tester,
    ) async {
      await _openScale(tester);

      final view = renderedFolderView(tester);
      expect(view.scale, 1.0);
      expect(view.scaleStep, 0.05);
      expect(view.blockModifierScroll, isNull);
      expect(view.onScaleChanged, isNotNull);
    });

    testWidgets('the Scale slider sets FolderView.scale', (tester) async {
      await _openScale(tester);

      await setSlider(tester, 'FolderView.scale', 1.5);
      expect(renderedFolderView(tester).scale, 1.5);
    });

    testWidgets('the Step slider sets FolderView.scaleStep', (tester) async {
      await _openScale(tester);

      await setSlider(tester, 'FolderView.scaleStep', 0.2);
      expect(renderedFolderView(tester).scaleStep, closeTo(0.2, 1e-9));
    });

    testWidgets('Block modifier scroll is null, true or false', (tester) async {
      await _openScale(tester);

      await chooseDropdown(tester, 'FolderView.blockModifierScroll', 'On');
      expect(renderedFolderView(tester).blockModifierScroll, isTrue);
      await chooseDropdown(tester, 'FolderView.blockModifierScroll', 'Off');
      expect(renderedFolderView(tester).blockModifierScroll, isFalse);
      await chooseDropdown(
        tester,
        'FolderView.blockModifierScroll',
        'Follow handler',
      );
      expect(renderedFolderView(tester).blockModifierScroll, isNull);
    });

    testWidgets('Ctrl+wheel moves the Scale by the step, both ways', (
      tester,
    ) async {
      await _openScale(tester);
      await setSlider(tester, 'FolderView.scaleStep', 0.1);

      await _ctrlWheel(tester, -50);
      expect(renderedFolderView(tester).scale, closeTo(1.1, 1e-9));
      await _ctrlWheel(tester, 50);
      await _ctrlWheel(tester, 50);
      expect(renderedFolderView(tester).scale, closeTo(0.9, 1e-9));
    });

    testWidgets('the handler clamps what the library proposes to 0.5–3.0', (
      tester,
    ) async {
      await _openScale(tester);
      await setSlider(tester, 'FolderView.scale', 3.0);

      await _ctrlWheel(tester, -50);
      expect(renderedFolderView(tester).scale, 3.0);

      await setSlider(tester, 'FolderView.scale', 0.5);
      await _ctrlWheel(tester, 50);
      expect(renderedFolderView(tester).scale, 0.5);
    });

    testWidgets('with the handler off, Ctrl+wheel scrolls and leaves the '
        'Scale', (tester) async {
      await pumpShell(tester);
      await _tallTree(tester);

      await _toggle(tester, 'FolderView.onScaleChanged');
      expect(renderedFolderView(tester).onScaleChanged, isNull);

      await _ctrlWheel(tester, 200);
      expect(_offset(tester), greaterThan(0));
      expect(renderedFolderView(tester).scale, 1.0);
    });

    testWidgets('Ctrl+wheel does not scroll while blocking follows the '
        'handler', (tester) async {
      await pumpShell(tester);
      await _tallTree(tester);

      await _ctrlWheel(tester, 200);
      expect(_offset(tester), 0);
      expect(renderedFolderView(tester).scale, closeTo(0.95, 1e-9));

      // The same notch without Ctrl scrolls: the tree can move.
      await _wheel(tester, 200);
      expect(_offset(tester), greaterThan(0));
    });

    testWidgets('blocking On holds the list still with no handler', (
      tester,
    ) async {
      await pumpShell(tester);
      await _tallTree(tester);
      await _toggle(tester, 'FolderView.onScaleChanged');
      await chooseDropdown(tester, 'FolderView.blockModifierScroll', 'On');

      await _ctrlWheel(tester, 200);
      expect(_offset(tester), 0);
      expect(renderedFolderView(tester).scale, 1.0);

      await _wheel(tester, 200);
      expect(_offset(tester), greaterThan(0));
    });

    testWidgets('the note says scrollbars and tooltips are excluded from '
        'Scale', (tester) async {
      await _openScale(tester);

      final note = tester.widget<Text>(find.byKey(const Key('scale-note')));
      expect(note.data, contains('Scrollbars and tooltips keep their size'));
      expect(note.data, contains('ADR-0001'));
      expect(note.data, contains('ADR-0004'));
    });

    testWidgets('with blocking Off, Ctrl+wheel scrolls and proposes nothing', (
      tester,
    ) async {
      await pumpShell(tester);
      await _tallTree(tester);
      await chooseDropdown(tester, 'FolderView.blockModifierScroll', 'Off');

      await _ctrlWheel(tester, 200);
      expect(_offset(tester), greaterThan(0));
      expect(renderedFolderView(tester).scale, 1.0);
    });
  });
}
