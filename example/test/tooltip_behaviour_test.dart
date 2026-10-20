import 'package:example/app/tooltip_settings.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_tooltip/just_tooltip.dart' show JustTooltip;

import 'support/shell_harness.dart';

const _f1 = 'Theme System Architecture'; // Folder 1
const _c1 = 'FolderViewLineTheme'; // Child 1-1-1

Finder _inView(Finder matching) =>
    find.descendant(of: find.byType(FolderView<String>), matching: matching);

Finder _labelFinder(String label) => _inView(
  find.byWidgetPredicate(
    (w) => w is RichText && w.text.toPlainText().startsWith(label),
  ),
);

JustTooltip _tip(WidgetTester tester, String label) =>
    tester.widget<JustTooltip>(
      find.ancestor(
        of: _labelFinder(label),
        matching: find.byType(JustTooltip),
      ),
    );

Finder _control(String id) =>
    find.byWidgetPredicate((w) => w is SettingsControl && w.id == id);

Future<void> _toggle(WidgetTester tester, String id) async {
  final target = find.descendant(
    of: _control(id),
    matching: find.byType(Switch),
  );
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

String _code(WidgetTester tester, String id) => tester
    .widget<SelectableText>(
      find.descendant(of: _control(id), matching: find.byType(SelectableText)),
    )
    .data!;

/// The tooltip event log's lines, newest first.
List<String> _log(WidgetTester tester) => tester
    .widgetList<Text>(
      find.descendant(
        of: find.byKey(const Key('tooltip-log')),
        matching: find.byType(Text),
      ),
    )
    .map((t) => t.data!)
    .toList();

/// Turns [tier]'s tooltip on in Tooltip placement, then opens Tooltip
/// behaviour & animation, whose controls edit the same Tier.
Future<void> _open(
  WidgetTester tester, {
  String tier = 'Folder',
  bool room = false,
}) async {
  await pumpShell(tester);
  if (room) {
    await tester.tap(find.byTooltip(ViewportBar.roomLabel));
    await tester.pumpAndSettle();
  }
  await openFeature(tester, 'Tooltip placement');
  await chooseDropdown(tester, 'tooltipTier', tier);
  await _toggle(tester, 'NodeTooltipTheme.useTooltip');
  await openFeature(tester, 'Tooltip behaviour & animation');
}

/// A mouse that has not entered the tree yet.
Future<TestGesture> _mouse(WidgetTester tester) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  addTearDown(mouse.removePointer);
  await mouse.addPointer(location: Offset.zero);
  return mouse;
}

const _tipText = 'Folder tooltip';

/// Sets every behaviour and animation setting away from its fallback.
Future<void> _setEvery(WidgetTester tester) async {
  await _toggle(tester, 'NodeTooltipTheme.enableTap');
  await _toggle(tester, 'NodeTooltipTheme.enableHover');
  await _toggle(tester, 'NodeTooltipTheme.interactive');
  await setSlider(tester, 'NodeTooltipTheme.waitDuration', 500);
  await setSlider(tester, 'NodeTooltipTheme.showDuration', 2000);
  await _toggle(tester, 'NodeTooltipTheme.onShow');
  await _toggle(tester, 'NodeTooltipTheme.onHide');
  await chooseDropdown(tester, 'NodeTooltipTheme.animation', 'rotation');
  await chooseDropdown(
    tester,
    'NodeTooltipTheme.animationCurve',
    'easeOutBack',
  );
  await setSlider(tester, 'NodeTooltipTheme.animationDuration', 400);
  await setSlider(tester, 'NodeTooltipTheme.fadeBegin', 0.5);
  await setSlider(tester, 'NodeTooltipTheme.scaleBegin', 0.25);
  await setSlider(tester, 'NodeTooltipTheme.slideOffset', 0.75);
  await setSlider(tester, 'NodeTooltipTheme.rotationBegin', 0.2);
}

/// The library's behaviour and animation fallbacks, on [tip].
void _expectFallbacks(JustTooltip tip) {
  expect(tip.enableTap, isFalse);
  expect(tip.enableHover, isTrue);
  expect(tip.interactive, isFalse);
  expect(tip.waitDuration, isNull);
  expect(tip.showDuration, isNull);
  expect(tip.onShow, isNull);
  expect(tip.onHide, isNull);
  expect(tip.controller, isNull);
  expect(tip.animation, TooltipAnimation.fade);
  expect(tip.animationCurve, isNull);
  expect(tip.animationDuration, const Duration(milliseconds: 150));
  expect(tip.fadeBegin, 0.0);
  expect(tip.scaleBegin, 0.0);
  expect(tip.slideOffset, 0.3);
  expect(tip.rotationBegin, -0.05);
}

void main() {
  group('Every setting: Tooltip behaviour & animation', () {
    testWidgets('a Tier turned on takes the library behaviour and animation '
        'fallbacks', (tester) async {
      await _open(tester);

      _expectFallbacks(_tip(tester, _f1));
    });

    testWidgets('its Tier is the Tooltip placement Tier', (tester) async {
      await _open(tester);
      await chooseDropdown(tester, 'tooltipBehaviourTier', 'Child');
      await _toggle(tester, 'NodeTooltipTheme.enableTap');
      await openFeature(tester, 'Tooltip placement');
      await _toggle(tester, 'NodeTooltipTheme.useTooltip');

      expect(_tip(tester, _c1).enableTap, isTrue);
      expect(
        tester
            .widget<DropdownButton<TooltipTier>>(
              find.descendant(
                of: _control('tooltipTier'),
                matching: find.byType(DropdownButton<TooltipTier>),
              ),
            )
            .value,
        TooltipTier.child,
      );
    });

    testWidgets('every setting reaches the Tier\'s JustTooltip', (
      tester,
    ) async {
      await _open(tester);
      await _setEvery(tester);

      final tip = _tip(tester, _f1);
      expect(tip.enableTap, isTrue);
      expect(tip.enableHover, isFalse);
      expect(tip.interactive, isTrue);
      expect(tip.waitDuration, const Duration(milliseconds: 500));
      expect(tip.showDuration, const Duration(seconds: 2));
      expect(tip.onShow, isNotNull);
      expect(tip.onHide, isNotNull);
      expect(tip.animation, TooltipAnimation.rotation);
      expect(tip.animationCurve, Curves.easeOutBack);
      expect(tip.animationDuration, const Duration(milliseconds: 400));
      expect(tip.fadeBegin, 0.5);
      expect(tip.scaleBegin, 0.25);
      expect(tip.slideOffset, 0.75);
      expect(tip.rotationBegin, 0.2);
    });

    testWidgets('onShow and onHide are logged as the tooltip shows and hides', (
      tester,
    ) async {
      await _open(tester, room: true);
      await _toggle(tester, 'NodeTooltipTheme.onShow');
      await _toggle(tester, 'NodeTooltipTheme.onHide');
      final mouse = await _mouse(tester);

      await mouse.moveTo(tester.getCenter(_labelFinder(_f1)));
      await tester.pumpAndSettle();
      expect(find.text(_tipText), findsOneWidget);
      expect(_log(tester), ['onShow · Folder tooltip']);

      await mouse.moveTo(Offset.zero);
      await tester.pumpAndSettle();
      expect(find.text(_tipText), findsNothing);
      expect(_log(tester), [
        'onHide · Folder tooltip',
        'onShow · Folder tooltip',
      ]);
    });

    testWidgets('with the onShow / onHide samples off nothing is logged', (
      tester,
    ) async {
      await _open(tester, room: true);
      final mouse = await _mouse(tester);

      await mouse.moveTo(tester.getCenter(_labelFinder(_f1)));
      await tester.pumpAndSettle();
      expect(find.text(_tipText), findsOneWidget);
      await mouse.moveTo(Offset.zero);
      await tester.pumpAndSettle();
      expect(_log(tester), isEmpty);
    });

    testWidgets('with enableHover off a hover shows nothing', (tester) async {
      await _open(tester, room: true);
      final mouse = await _mouse(tester);
      await mouse.moveTo(tester.getCenter(_labelFinder(_f1)));
      await tester.pumpAndSettle();
      expect(find.text(_tipText), findsOneWidget);
      await mouse.moveTo(Offset.zero);
      await tester.pumpAndSettle();

      await _toggle(tester, 'NodeTooltipTheme.enableHover');
      await mouse.moveTo(tester.getCenter(_labelFinder(_f1)));
      await tester.pumpAndSettle();
      expect(find.text(_tipText), findsNothing);
    });

    testWidgets('with enableTap on a tap shows the tooltip and a second tap '
        'hides it', (tester) async {
      await _open(tester, room: true);
      await _toggle(tester, 'NodeTooltipTheme.enableHover');
      await _toggle(tester, 'NodeTooltipTheme.enableTap');

      await tester.tap(_labelFinder(_f1));
      await tester.pumpAndSettle();
      expect(find.text(_tipText), findsOneWidget);
      await tester.tap(_labelFinder(_f1));
      await tester.pumpAndSettle();
      expect(find.text(_tipText), findsNothing);
    });

    testWidgets('with enableTap on a Child label tap opens the tooltip '
        'instead of reaching onNodeTap; the rest of the row still does', (
      tester,
    ) async {
      await _open(tester, tier: 'Child', room: true);
      await _toggle(tester, 'NodeTooltipTheme.enableTap');

      await tester.tap(_labelFinder(_c1));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(find.text('Child tooltip'), findsOneWidget);
      expect(_log(tester), isEmpty);
      expect(renderedFolderView(tester).selectedNodeIds, isEmpty);

      final label = tester.getRect(_labelFinder(_c1));
      await tester.tapAt(Offset(label.right + 40, label.center.dy));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(_log(tester), ['onNodeTap · $_c1']);
      expect(renderedFolderView(tester).selectedNodeIds, {'1-1-1'});
    });

    testWidgets('waitDuration delays the hover', (tester) async {
      await _open(tester, room: true);
      await setSlider(tester, 'NodeTooltipTheme.waitDuration', 500);
      final mouse = await _mouse(tester);

      await mouse.moveTo(tester.getCenter(_labelFinder(_f1)));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text(_tipText), findsNothing);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(find.text(_tipText), findsOneWidget);
    });

    testWidgets('showDuration hides the tooltip while the pointer stays', (
      tester,
    ) async {
      await _open(tester, room: true);
      await setSlider(tester, 'NodeTooltipTheme.showDuration', 1000);
      final mouse = await _mouse(tester);

      await mouse.moveTo(tester.getCenter(_labelFinder(_f1)));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(_tipText), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(find.text(_tipText), findsNothing);
    });

    testWidgets('the animation picks the transition the tooltip opens with', (
      tester,
    ) async {
      await _open(tester, room: true);
      await chooseDropdown(tester, 'NodeTooltipTheme.animation', 'scale');
      final mouse = await _mouse(tester);

      await mouse.moveTo(tester.getCenter(_labelFinder(_f1)));
      await tester.pumpAndSettle();
      final around = find.ancestor(
        of: find.text(_tipText),
        matching: find.byType(ScaleTransition),
      );
      expect(around, findsOneWidget);
      expect(
        find.ancestor(
          of: find.text(_tipText),
          matching: find.byType(FadeTransition),
        ),
        findsNothing,
      );
    });

    testWidgets('the code shows each setting once it is set', (tester) async {
      await _open(tester);
      await openFeature(tester, 'Tooltip placement');
      expect(
        _code(tester, 'FolderNodeTheme.tooltipTheme'),
        endsWith("  message: 'Folder tooltip',\n),"),
      );
      await openFeature(tester, 'Tooltip behaviour & animation');
      await _setEvery(tester);
      await openFeature(tester, 'Tooltip placement');

      final code = _code(tester, 'FolderNodeTheme.tooltipTheme');
      expect(
        code,
        contains(
          "  message: 'Folder tooltip',\n"
          '  enableTap: true,\n'
          '  enableHover: false,\n'
          '  interactive: true,\n'
          '  waitDuration: const Duration(milliseconds: 500),\n'
          '  showDuration: const Duration(milliseconds: 2000),\n'
          "  onShow: () => debugPrint('onShow · Folder tooltip'),\n"
          "  onHide: () => debugPrint('onHide · Folder tooltip'),\n"
          '  animation: TooltipAnimation.rotation,\n'
          '  animationCurve: Curves.easeOutBack,\n'
          '  animationDuration: const Duration(milliseconds: 400),\n'
          '  fadeBegin: 0.5,\n'
          '  scaleBegin: 0.25,\n'
          '  slideOffset: 0.75,\n'
          '  rotationBegin: 0.2,\n'
          '),',
        ),
      );
    });

    testWidgets('a theme preset resets every behaviour setting', (
      tester,
    ) async {
      await _open(tester);
      await _setEvery(tester);

      await tester.tap(
        find.ancestor(
          of: find.text('Light'),
          matching: find.byType(ChoiceChip),
        ),
      );
      await tester.pumpAndSettle();
      await openFeature(tester, 'Tooltip placement');
      await _toggle(tester, 'NodeTooltipTheme.useTooltip');

      _expectFallbacks(_tip(tester, _f1));
    });
  });
}
