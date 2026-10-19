import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_tooltip/just_tooltip.dart' show JustTooltip;

import 'support/shell_harness.dart';

const _f1 = 'Theme System Architecture'; // Folder 1
const _f3 =
    'Usage Example with really long long long long label to test horizontal '
    'scroll'; // Folder 3
const _p1 = 'FlutterFolderViewTheme (Master Class)'; // Parent 1-1
const _c1 = 'FolderViewLineTheme'; // Child 1-1-1

Finder _inView(Finder matching) =>
    find.descendant(of: find.byType(FolderView<String>), matching: matching);

Finder _labelFinder(String label) => _inView(
  find.byWidgetPredicate(
    (w) => w is RichText && w.text.toPlainText().startsWith(label),
  ),
);

FlutterFolderViewTheme<String> _theme(WidgetTester tester) =>
    renderedFolderView(tester).theme!;

/// The `JustTooltip` wrapping the label [label], if any.
Finder _tooltipOf(String label) =>
    find.ancestor(of: _labelFinder(label), matching: find.byType(JustTooltip));

Future<void> _open(WidgetTester tester, {bool room = false}) async {
  await pumpShell(tester);
  if (room) {
    await tester.tap(find.byTooltip(ViewportBar.roomLabel));
    await tester.pumpAndSettle();
  }
  await openFeature(tester, 'Tooltip placement');
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

/// Turns the tooltip on for [tier] (Folder, Parent or Child).
Future<void> _enable(WidgetTester tester, String tier) async {
  await chooseDropdown(tester, 'tooltipTier', tier);
  await _toggle(tester, 'NodeTooltipTheme.useTooltip');
}

/// Hovers the label [label], [dx] from its left edge or at its centre.
Future<void> _hover(WidgetTester tester, String label, {double? dx}) async {
  final rect = tester.getRect(_labelFinder(label));
  final at = dx == null ? rect.center : Offset(rect.left + dx, rect.center.dy);
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  addTearDown(mouse.removePointer);
  await mouse.addPointer(location: at);
  await tester.pumpAndSettle();
}

Rect _tip(WidgetTester tester, String message) =>
    tester.getRect(find.text(message));

void main() {
  group('Every setting: Tooltip placement', () {
    testWidgets('opens with no Tier tooltip, as both factories leave it', (
      tester,
    ) async {
      await _open(tester);

      final theme = _theme(tester);
      expect(theme.folderTheme.tooltipTheme, isNull);
      expect(theme.parentTheme.tooltipTheme, isNull);
      expect(theme.childTheme.tooltipTheme, isNull);
      expect(_inView(find.byType(JustTooltip)), findsNothing);
    });

    testWidgets('editing the chosen Tier changes only that Tier', (
      tester,
    ) async {
      await _open(tester);

      await _enable(tester, 'Parent');
      final theme = _theme(tester);
      expect(theme.parentTheme.tooltipTheme!.useTooltip, isTrue);
      expect(theme.folderTheme.tooltipTheme, isNull);
      expect(theme.childTheme.tooltipTheme, isNull);
      expect(_tooltipOf(_p1), findsOneWidget);
      expect(_tooltipOf(_f1), findsNothing);
      expect(_tooltipOf(_c1), findsNothing);
    });

    testWidgets('every placement setting reaches the label tooltip', (
      tester,
    ) async {
      await _open(tester);
      await _enable(tester, 'Child');

      await chooseDropdown(tester, 'NodeTooltipTheme.direction', 'bottom');
      await chooseDropdown(tester, 'NodeTooltipTheme.alignment', 'start');
      await chooseDropdown(tester, 'NodeTooltipTheme.anchor', 'pointer');
      await setSlider(tester, 'NodeTooltipTheme.offset', 20);
      await setSlider(tester, 'NodeTooltipTheme.crossAxisOffset', 10);
      await setSlider(tester, 'NodeTooltipTheme.screenMargin', 16);
      await _toggle(tester, 'NodeTooltipTheme.showArrow');
      await setSlider(tester, 'NodeTooltipTheme.arrowBaseWidth', 20);
      await setSlider(tester, 'NodeTooltipTheme.arrowLength', 10);
      await setSlider(tester, 'NodeTooltipTheme.arrowPositionRatio', 0.5);

      final tip = tester.widget<JustTooltip>(_tooltipOf(_c1));
      expect(tip.direction, TooltipDirection.bottom);
      expect(tip.alignment, TooltipAlignment.start);
      expect(tip.anchor, TooltipAnchor.pointer);
      expect(tip.offset, 20);
      expect(tip.crossAxisOffset, 10);
      expect(tip.screenMargin, 16);
      expect(tip.theme.showArrow, isTrue);
      expect(tip.theme.arrowBaseWidth, 20);
      expect(tip.theme.arrowLength, 10);
      expect(tip.theme.arrowPositionRatio, closeTo(0.5, 1e-9));
    });

    testWidgets('in the Room a hovered label tooltip paints inside the window '
        'at 1:1, above the label', (tester) async {
      await _open(tester, room: true);
      await _enable(tester, 'Folder');

      await _hover(tester, _f1);
      final tip = _tip(tester, 'Folder tooltip');
      final window = Offset.zero & tester.view.physicalSize;
      expect(
        window.contains(tip.topLeft) && window.contains(tip.bottomRight),
        isTrue,
      );
      final box = tester.renderObject(find.text('Folder tooltip')) as RenderBox;
      expect(tip.width, closeTo(box.size.width, 0.01), reason: 'not 1:1');
      expect(
        tip.bottom,
        lessThanOrEqualTo(tester.getRect(_labelFinder(_f1)).top),
      );
      // It is the app's root Overlay that holds it, not a stage's own.
      final nearest = tester.state<OverlayState>(
        find
            .ancestor(
              of: find.text('Folder tooltip'),
              matching: find.byType(Overlay),
            )
            .first,
      );
      expect(
        nearest,
        same(tester.state<OverlayState>(find.byType(Overlay).first)),
      );
    });

    testWidgets('direction bottom paints the tooltip below the label', (
      tester,
    ) async {
      await _open(tester, room: true);
      await _enable(tester, 'Folder');
      await chooseDropdown(tester, 'NodeTooltipTheme.direction', 'bottom');

      await _hover(tester, _f1);
      expect(
        _tip(tester, 'Folder tooltip').top,
        greaterThanOrEqualTo(tester.getRect(_labelFinder(_f1)).bottom),
      );
    });

    testWidgets('offset is the gap between the label and the tooltip', (
      tester,
    ) async {
      await _open(tester, room: true);
      await _enable(tester, 'Folder');
      await setSlider(tester, 'NodeTooltipTheme.offset', 30);

      await _hover(tester, _f1);
      final gap =
          tester.getRect(_labelFinder(_f1)).top -
          _tip(tester, 'Folder tooltip').bottom;
      // The text sits inside the tooltip's default 8 px vertical padding.
      expect(gap, closeTo(30 + 8, 0.5));
    });

    testWidgets('anchor pointer centres the tooltip on the pointer, not the '
        'long label', (tester) async {
      await _open(tester, room: true);
      await _enable(tester, 'Folder');
      await chooseDropdown(tester, 'NodeTooltipTheme.anchor', 'pointer');

      final label = tester.getRect(_labelFinder(_f3));
      await _hover(tester, _f3, dx: 40);
      final centre = _tip(tester, 'Folder tooltip').center.dx;
      expect((centre - (label.left + 40)).abs(), lessThan(60));
    });

    testWidgets(
      'the Parent tooltipTheme control writes the Tier theme as code',
      (tester) async {
        await _open(tester);
        final code = tester
            .widget<SelectableText>(
              find.descendant(
                of: find.byWidgetPredicate(
                  (w) =>
                      w is SettingsControl &&
                      w.id == 'ParentNodeTheme.tooltipTheme',
                ),
                matching: find.byType(SelectableText),
              ),
            )
            .data!;
        expect(code, 'tooltipTheme: null,');

        await _enable(tester, 'Parent');
        await setSlider(tester, 'NodeTooltipTheme.offset', 20);
        final on = tester
            .widget<SelectableText>(
              find.descendant(
                of: find.byWidgetPredicate(
                  (w) =>
                      w is SettingsControl &&
                      w.id == 'ParentNodeTheme.tooltipTheme',
                ),
                matching: find.byType(SelectableText),
              ),
            )
            .data!;
        expect(on, startsWith('tooltipTheme: NodeTooltipTheme<String>(\n'));
        expect(on, contains("  message: 'Parent tooltip',\n"));
        expect(on, contains('  offset: 20,\n'));
      },
    );

    testWidgets('the tooltip keeps its settings at Scale 2', (tester) async {
      await _open(tester);
      await _enable(tester, 'Folder');
      await setSlider(tester, 'NodeTooltipTheme.offset', 20);
      await openFeature(tester, 'Scale');
      await setSlider(tester, 'FolderView.scale', 2.0);
      expect(renderedFolderView(tester).scale, 2.0);

      final tip = tester.widget<JustTooltip>(_tooltipOf(_f1));
      expect(tip.offset, 20);
      expect(tip.screenMargin, 8);
      expect(tip.theme.arrowBaseWidth, 12);
      expect(
        tip.theme.padding,
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      );
    });

    testWidgets('the Folder and Child containers write their own Tier', (
      tester,
    ) async {
      await _open(tester);
      await _enable(tester, 'Child');
      String code(String id) => tester
          .widget<SelectableText>(
            find.descendant(
              of: find.byWidgetPredicate(
                (w) => w is SettingsControl && w.id == id,
              ),
              matching: find.byType(SelectableText),
            ),
          )
          .data!;
      expect(
        code('ChildNodeTheme.tooltipTheme'),
        contains("message: 'Child tooltip'"),
      );
      expect(code('FolderNodeTheme.tooltipTheme'), 'tooltipTheme: null,');
    });

    testWidgets('a hidden setting under useTooltip off keeps the preset', (
      tester,
    ) async {
      await _open(tester);
      await setSlider(tester, 'NodeTooltipTheme.offset', 20);
      final light = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('Light'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(light.selected, isTrue);
    });

    testWidgets('a preset turns every Tier tooltip back off', (tester) async {
      await _open(tester);
      await _enable(tester, 'Child');
      ChoiceChip chip(String t) => tester.widget<ChoiceChip>(
        find.ancestor(of: find.text(t), matching: find.byType(ChoiceChip)),
      );
      expect(chip('Light').selected, isFalse);

      await tester.tap(
        find.ancestor(
          of: find.text('Light'),
          matching: find.byType(ChoiceChip),
        ),
      );
      await tester.pumpAndSettle();
      expect(_theme(tester).childTheme.tooltipTheme, isNull);
      expect(chip('Light').selected, isTrue);
    });
  });
}
