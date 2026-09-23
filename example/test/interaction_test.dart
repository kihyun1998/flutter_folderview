import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/shell_harness.dart';

const _child = 'FolderViewLineTheme'; // id 1-1-1
const _otherChild = 'FolderViewNodeTheme (Future)'; // id 1-1-2
const _parent = 'FolderViewTheme (InheritedWidget)'; // id 1-2, collapsed
const _folder = 'Theme System Architecture'; // id 1

Finder _row(String label) => find.descendant(
  of: find.byType(FolderView<String>),
  matching: find.text(label),
);

/// The event log's lines, newest first.
List<String> _log(WidgetTester tester) => tester
    .widgetList<Text>(
      find.descendant(
        of: find.byKey(const Key('interaction-log')),
        matching: find.byType(Text),
      ),
    )
    .map((t) => t.data ?? '')
    .toList();

Future<void> _openInteraction(WidgetTester tester) async {
  await pumpShell(tester);
  await openFeature(tester, 'Taps & state');
}

/// Taps [label] once and lets the double-tap window close.
Future<void> _tap(WidgetTester tester, String label) async {
  await tester.tap(_row(label));
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pumpAndSettle();
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

Future<void> _press(WidgetTester tester, String id, String button) async {
  final target = find.descendant(
    of: find.byWidgetPredicate((w) => w is SettingsControl && w.id == id),
    matching: find.text(button),
  );
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  group('onNodeTap', () {
    testWidgets('a Child tap is logged and selects the Child', (tester) async {
      await _openInteraction(tester);

      await _tap(tester, _child);

      expect(_log(tester), ['onNodeTap · $_child']);
      expect(renderedFolderView(tester).selectedNodeIds, {'1-1-1'});
    });

    testWidgets('a Parent tap toggles its expansion and selects nothing', (
      tester,
    ) async {
      await _openInteraction(tester);
      expect(
        renderedFolderView(tester).expandedNodeIds,
        isNot(contains('1-2')),
      );

      await _tap(tester, _parent);

      expect(renderedFolderView(tester).expandedNodeIds, contains('1-2'));
      expect(renderedFolderView(tester).selectedNodeIds, isEmpty);
      expect(_log(tester), ['onNodeTap · $_parent']);
    });

    testWidgets('with the handler off, taps change neither set', (
      tester,
    ) async {
      await _openInteraction(tester);
      await _toggle(tester, 'FolderView.onNodeTap');

      expect(renderedFolderView(tester).onNodeTap, isNull);
      final expanded = renderedFolderView(tester).expandedNodeIds;

      await _tap(tester, _child);
      await _tap(tester, _parent);

      expect(renderedFolderView(tester).selectedNodeIds, isEmpty);
      expect(renderedFolderView(tester).expandedNodeIds, expanded);
      expect(_log(tester), isEmpty);
    });
  });

  group('onDoubleNodeTap', () {
    testWidgets('a double tap logs onNodeTap, then onDoubleNodeTap', (
      tester,
    ) async {
      await _openInteraction(tester);

      await tester.tap(_row(_child));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(_row(_child));
      await tester.pumpAndSettle();

      expect(_log(tester), [
        'onDoubleNodeTap · $_child',
        'onNodeTap · $_child',
      ]);
    });

    testWidgets('a double tap on a Parent is two single taps', (tester) async {
      await _openInteraction(tester);

      await tester.tap(_row(_parent));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(_row(_parent));
      await tester.pumpAndSettle();

      expect(_log(tester), ['onNodeTap · $_parent', 'onNodeTap · $_parent']);
    });

    testWidgets('with the handler off, a quick second tap is a single tap', (
      tester,
    ) async {
      await _openInteraction(tester);
      await _toggle(tester, 'FolderView.onDoubleNodeTap');
      expect(renderedFolderView(tester).onDoubleNodeTap, isNull);

      await tester.tap(_row(_child));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(_row(_child));
      await tester.pumpAndSettle();

      expect(_log(tester), ['onNodeTap · $_child', 'onNodeTap · $_child']);
      expect(renderedFolderView(tester).selectedNodeIds, isEmpty);
    });

    testWidgets('Ctrl+tap is always a single tap', (tester) async {
      await _openInteraction(tester);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.tap(_row(_child));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(_row(_child));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      expect(_log(tester), ['onNodeTap · $_child', 'onNodeTap · $_child']);
      expect(renderedFolderView(tester).selectedNodeIds, isEmpty);
    });

    testWidgets('the note states the double-tap window', (tester) async {
      await _openInteraction(tester);

      final note = tester.widget<Text>(
        find.byKey(const Key('double-tap-note')),
      );
      expect(note.data, contains('ChildNodeTheme.clickInterval'));
      expect(note.data, contains('Ctrl'));
    });
  });

  group('onSecondaryNodeTap', () {
    testWidgets('a secondary tap on a Folder is logged with its position', (
      tester,
    ) async {
      await _openInteraction(tester);

      final at = tester.getCenter(_row(_folder));
      await tester.tapAt(at, buttons: kSecondaryButton);
      await tester.pumpAndSettle();

      expect(_log(tester), [
        'onSecondaryNodeTap · $_folder @ '
            '(${at.dx.round()}, ${at.dy.round()})',
      ]);
      expect(renderedFolderView(tester).selectedNodeIds, isEmpty);
    });

    testWidgets('with the handler off, a secondary tap logs nothing', (
      tester,
    ) async {
      await _openInteraction(tester);
      await _toggle(tester, 'FolderView.onSecondaryNodeTap');

      expect(renderedFolderView(tester).onSecondaryNodeTap, isNull);
      await tester.tapAt(
        tester.getCenter(_row(_folder)),
        buttons: kSecondaryButton,
      );
      await tester.pumpAndSettle();
      expect(_log(tester), isEmpty);
    });
  });

  group('Selected Set', () {
    testWidgets('single selection keeps only the last Child', (tester) async {
      await _openInteraction(tester);

      await _tap(tester, _child);
      await _tap(tester, _otherChild);

      expect(renderedFolderView(tester).selectedNodeIds, {'1-1-2'});
    });

    testWidgets('multiple selection adds, and a second tap removes', (
      tester,
    ) async {
      await _openInteraction(tester);
      await chooseDropdown(tester, 'selectionMode', 'multiple');

      await _tap(tester, _child);
      await _tap(tester, _otherChild);
      expect(renderedFolderView(tester).selectedNodeIds, {'1-1-1', '1-1-2'});

      await _tap(tester, _child);
      expect(renderedFolderView(tester).selectedNodeIds, {'1-1-2'});
    });

    testWidgets('Clear empties it', (tester) async {
      await _openInteraction(tester);
      await _tap(tester, _child);

      await _press(tester, 'FolderView.selectedNodeIds', 'Clear');

      expect(renderedFolderView(tester).selectedNodeIds, isEmpty);
    });
  });

  group('Expanded Set', () {
    testWidgets('Expand all opens every Folder and Parent; Collapse all none', (
      tester,
    ) async {
      await _openInteraction(tester);

      await _press(tester, 'FolderView.expandedNodeIds', 'Expand all');
      // Every Folder and Parent id in lib/data/theme_demo_data.dart.
      expect(renderedFolderView(tester).expandedNodeIds, {
        '1', '1-1', '1-2', '2', '2-1', '2-2', '3', '3-1', //
      });

      await _press(tester, 'FolderView.expandedNodeIds', 'Collapse all');
      expect(renderedFolderView(tester).expandedNodeIds, isEmpty);
    });
  });

  testWidgets('the log keeps the newest 20 entries', (tester) async {
    await _openInteraction(tester);

    for (var i = 1; i <= 21; i++) {
      await _tap(tester, i.isOdd ? _child : _otherChild);
    }

    final log = _log(tester);
    expect(log, hasLength(20));
    expect(log.first, 'onNodeTap · $_child'); // tap 21
    expect(log.last, 'onNodeTap · $_otherChild'); // tap 2; tap 1 dropped
  });

  testWidgets('changing the data drops selected ids it no longer holds', (
    tester,
  ) async {
    await _openInteraction(tester);
    await _tap(tester, _child);
    expect(renderedFolderView(tester).selectedNodeIds, {'1-1-1'});

    await openFeature(tester, 'Data');
    await chooseDropdown(tester, 'FolderView.data', 'Generated');

    expect(renderedFolderView(tester).selectedNodeIds, isEmpty);
  });
}
