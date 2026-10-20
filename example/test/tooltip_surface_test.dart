import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_tooltip/just_tooltip.dart' show JustTooltip;

import 'support/shell_harness.dart';

const _f1 = 'Theme System Architecture'; // Folder 1, two Parents
const _f3 =
    'Usage Example with really long long long long label to test horizontal '
    'scroll'; // Folder 3, a single Parent
const _p1 = 'FlutterFolderViewTheme (Master Class)'; // Parent 1-1, 3 Children
const _p2 = 'FolderViewTheme (InheritedWidget)'; // Parent 1-2, 2 Children
const _c1 = 'FolderViewLineTheme'; // Child 1-1-1
const _cFuture = 'FolderViewNodeTheme (Future)'; // Child 1-1-2

Finder _inView(Finder matching) =>
    find.descendant(of: find.byType(FolderView<String>), matching: matching);

Finder _labelFinder(String label) => _inView(
  find.byWidgetPredicate(
    (w) => w is RichText && w.text.toPlainText().startsWith(label),
  ),
);

Finder _tooltipOf(String label) =>
    find.ancestor(of: _labelFinder(label), matching: find.byType(JustTooltip));

JustTooltip _tip(WidgetTester tester, String label) =>
    tester.widget<JustTooltip>(_tooltipOf(label));

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

String _code(WidgetTester tester, String id) => tester
    .widget<SelectableText>(
      find.descendant(of: _control(id), matching: find.byType(SelectableText)),
    )
    .data!;

/// Turns [tier]'s tooltip on in Tooltip placement, then opens Tooltip content
/// & surface, whose controls edit the same Tier.
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
  await openFeature(tester, 'Tooltip content & surface');
}

Future<void> _hover(WidgetTester tester, String label) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  addTearDown(mouse.removePointer);
  await mouse.addPointer(location: tester.getCenter(_labelFinder(label)));
  await tester.pumpAndSettle();
}

/// The text of what the label [label]'s tooltip builder builds.
String _built(WidgetTester tester, String label) {
  final built = _tip(tester, label).tooltipBuilder!(
    tester.element(_labelFinder(label)),
  );
  return (built as Text).data!;
}

T _around<T extends Widget>(WidgetTester tester, String text) =>
    tester.widget<T>(
      find.ancestor(of: find.text(text), matching: find.byType(T)).first,
    );

void main() {
  group('Every setting: Tooltip content & surface', () {
    testWidgets('a Tier turned on shows its sample message with the library '
        'surface fallbacks', (tester) async {
      await _open(tester);

      final tip = _tip(tester, _f1);
      expect(tip.message, 'Folder tooltip');
      expect(tip.tooltipBuilder, isNull);
      expect(tip.theme.backgroundColor, const Color(0xFF616161));
      expect(tip.theme.elevation, 4);
      expect(tip.theme.borderRadius, BorderRadius.circular(6));
      expect(
        tip.theme.padding,
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      );
      expect(tip.theme.borderWidth, 0);
      expect(tip.theme.boxShadow, isNull);
      expect(tip.theme.textStyle, isNull);
      expect(tip.hideOnEmptyMessage, isTrue, reason: 'just_tooltip default');
    });

    testWidgets('its Tier dropdown is the Tooltip placement one: choosing a '
        'Tier in either moves both', (tester) async {
      await _open(tester);
      Object? tier(String id) => tester
          .widget<DropdownButton<Object?>>(
            find.descendant(
              of: _control(id),
              matching: find.byWidgetPredicate((w) => w is DropdownButton),
            ),
          )
          .value;
      await chooseDropdown(tester, 'tooltipSurfaceTier', 'Child');
      await chooseDropdown(tester, 'NodeTooltipTheme.message', 'long');
      var theme = renderedFolderView(tester).theme!;
      expect(theme.childTheme.tooltipTheme, isNull, reason: 'Child is off');
      expect(theme.folderTheme.tooltipTheme!.message, 'Folder tooltip');

      await openFeature(tester, 'Tooltip placement');
      expect(tier('tooltipTier').toString(), endsWith('child'));
      await _toggle(tester, 'NodeTooltipTheme.useTooltip');
      theme = renderedFolderView(tester).theme!;
      expect(theme.childTheme.tooltipTheme!.message, startsWith('A longer'));

      await chooseDropdown(tester, 'tooltipTier', 'Parent');
      await openFeature(tester, 'Tooltip content & surface');
      expect(tier('tooltipSurfaceTier').toString(), endsWith('parent'));
    });

    testWidgets('every surface setting reaches the label tooltip', (
      tester,
    ) async {
      await _open(tester, tier: 'Parent');

      await chooseDropdown(tester, 'NodeTooltipTheme.message', 'long');
      await _tapSwatch(tester, 'NodeTooltipTheme.textStyle', 1);
      await _tapSwatch(tester, 'NodeTooltipTheme.backgroundColor', 2);
      await setSlider(tester, 'NodeTooltipTheme.elevation', 10);
      await setSlider(tester, 'NodeTooltipTheme.borderRadius', 12);
      await _setSide(tester, 'NodeTooltipTheme.padding', 'left', 20);
      await _tapSwatch(tester, 'NodeTooltipTheme.borderColor', 3);
      await setSlider(tester, 'NodeTooltipTheme.borderWidth', 3);
      await _toggle(tester, 'NodeTooltipTheme.boxShadow');

      final tip = _tip(tester, _p1);
      expect(tip.message, startsWith('A longer tooltip'));
      expect(tip.theme.textStyle!.color, Colors.amber);
      expect(tip.theme.backgroundColor, Colors.teal);
      expect(tip.theme.elevation, 10);
      expect(tip.theme.borderRadius, BorderRadius.circular(12));
      expect(tip.theme.padding, const EdgeInsets.fromLTRB(20, 8, 12, 8));
      expect(tip.theme.borderColor, Colors.redAccent);
      expect(tip.theme.borderWidth, 3);
      expect(tip.theme.boxShadow, hasLength(1));
    });

    testWidgets('an empty or unset message with no builder leaves the label '
        'without a tooltip', (tester) async {
      await _open(tester);
      await chooseDropdown(tester, 'NodeTooltipTheme.message', 'empty');
      final tooltipTheme = renderedFolderView(
        tester,
      ).theme!.folderTheme.tooltipTheme!;
      expect(tooltipTheme.message, '');
      expect(_tooltipOf(_f1), findsNothing);

      await chooseDropdown(tester, 'NodeTooltipTheme.message', 'null');
      expect(
        renderedFolderView(tester).theme!.folderTheme.tooltipTheme!.message,
        isNull,
      );
      expect(_tooltipOf(_f1), findsNothing);
    });

    testWidgets('tooltipBuilder replaces the message, even an empty one', (
      tester,
    ) async {
      await _open(tester, room: true);
      await chooseDropdown(tester, 'NodeTooltipTheme.message', 'empty');
      await _toggle(tester, 'NodeTooltipTheme.tooltipBuilder');

      expect(_tip(tester, _f1).message, isNull);
      await _hover(tester, _f1);
      expect(find.text('Built by tooltipBuilder'), findsOneWidget);
    });

    testWidgets('the Child resolver builds for a "(Future)" Child and falls '
        'back to the message for the rest', (tester) async {
      await _open(tester, tier: 'Child', room: true);
      await chooseDropdown(tester, 'tooltipSurfaceTier', 'Child');
      await _toggle(tester, 'NodeTooltipTheme.tooltipBuilderResolver');

      expect(_tip(tester, _c1).tooltipBuilder, isNull);
      expect(_tip(tester, _c1).message, 'Child tooltip');
      expect(_tip(tester, _cFuture).message, isNull);
      await _hover(tester, _cFuture);
      expect(find.text('Not built yet'), findsOneWidget);
    });

    testWidgets('a resolver that returns null falls back to tooltipBuilder', (
      tester,
    ) async {
      await _open(tester, tier: 'Child', room: true);
      await chooseDropdown(tester, 'tooltipSurfaceTier', 'Child');
      await _toggle(tester, 'NodeTooltipTheme.tooltipBuilder');
      await _toggle(tester, 'NodeTooltipTheme.tooltipBuilderResolver');

      await _hover(tester, _c1);
      expect(find.text('Built by tooltipBuilder'), findsOneWidget);
    });

    testWidgets('the Folder and Parent resolvers act on a single-Parent '
        'Folder and a two-Child Parent', (tester) async {
      await _open(tester);
      await _toggle(tester, 'NodeTooltipTheme.tooltipBuilderResolver');
      expect(_built(tester, _f3), 'Holds a single Parent');
      expect(_tip(tester, _f1).tooltipBuilder, isNull);

      await openFeature(tester, 'Tooltip placement');
      await chooseDropdown(tester, 'tooltipTier', 'Parent');
      await _toggle(tester, 'NodeTooltipTheme.useTooltip');
      await openFeature(tester, 'Tooltip content & surface');
      await _toggle(tester, 'NodeTooltipTheme.tooltipBuilderResolver');
      expect(_built(tester, _p2), 'Holds two Children');
      expect(_tip(tester, _p1).tooltipBuilder, isNull);
    });

    testWidgets('in the Room the hovered tooltip paints its background and '
        'text colour', (tester) async {
      await _open(tester, room: true);
      await _tapSwatch(tester, 'NodeTooltipTheme.backgroundColor', 2);
      await _tapSwatch(tester, 'NodeTooltipTheme.textStyle', 1);
      await setSlider(tester, 'NodeTooltipTheme.elevation', 10);

      await _hover(tester, _f1);
      final surface = _around<Material>(tester, 'Folder tooltip');
      expect(surface.color, Colors.teal);
      expect(surface.elevation, 10);
      final text = tester.widget<Text>(find.text('Folder tooltip'));
      expect(text.style!.color, Colors.amber);
    });

    testWidgets('a border shows only once borderWidth is above 0', (
      tester,
    ) async {
      await _open(tester, room: true);
      await _tapSwatch(tester, 'NodeTooltipTheme.borderColor', 3);

      await _hover(tester, _f1);
      expect(find.text('Folder tooltip'), findsOneWidget);
      expect(_around<Material>(tester, 'Folder tooltip').elevation, 4);
      expect(
        find.ancestor(
          of: find.text('Folder tooltip'),
          matching: find.byType(DecoratedBox),
        ),
        findsNothing,
      );
    });

    testWidgets('with a border, the tooltip paints it', (tester) async {
      await _open(tester, room: true);
      await _tapSwatch(tester, 'NodeTooltipTheme.borderColor', 3);
      await setSlider(tester, 'NodeTooltipTheme.borderWidth', 3);

      await _hover(tester, _f1);
      final box = _around<DecoratedBox>(tester, 'Folder tooltip');
      final border = (box.decoration as BoxDecoration).border! as Border;
      expect(border.top.color, Colors.redAccent);
      expect(border.top.width, 3);
    });

    testWidgets('boxShadow replaces the elevation shadow', (tester) async {
      await _open(tester, room: true);
      await setSlider(tester, 'NodeTooltipTheme.elevation', 10);
      await _toggle(tester, 'NodeTooltipTheme.boxShadow');

      await _hover(tester, _f1);
      final box = _around<DecoratedBox>(tester, 'Folder tooltip');
      expect((box.decoration as BoxDecoration).boxShadow, hasLength(1));
      expect(_around<Material>(tester, 'Folder tooltip').elevation, 0);
    });

    testWidgets('the Tier tooltipTheme code writes the surface settings', (
      tester,
    ) async {
      await _open(tester);
      await _tapSwatch(tester, 'NodeTooltipTheme.backgroundColor', 2);
      await _toggle(tester, 'NodeTooltipTheme.tooltipBuilder');
      await _toggle(tester, 'NodeTooltipTheme.tooltipBuilderResolver');
      await openFeature(tester, 'Tooltip placement');

      final code = _code(tester, 'FolderNodeTheme.tooltipTheme');
      expect(code, contains("  message: 'Folder tooltip',\n"));
      expect(code, contains('  backgroundColor: Color(0xFF009688),\n'));
      expect(code, contains('  tooltipBuilder: (context) =>'));
      expect(
        code,
        contains(
          '  tooltipBuilderResolver: (node) => '
          'node.children.length == 1\n',
        ),
      );
      expect(code, isNot(contains('elevation:')));
    });

    testWidgets('every set surface setting is written in the code', (
      tester,
    ) async {
      await _open(tester, tier: 'Child');
      await chooseDropdown(tester, 'tooltipSurfaceTier', 'Child');
      await chooseDropdown(tester, 'NodeTooltipTheme.message', 'empty');
      await _tapSwatch(tester, 'NodeTooltipTheme.textStyle', 1);
      await _toggle(tester, 'NodeTooltipTheme.tooltipBuilderResolver');
      await setSlider(tester, 'NodeTooltipTheme.elevation', 10);
      await _toggle(tester, 'NodeTooltipTheme.boxShadow');
      await setSlider(tester, 'NodeTooltipTheme.borderRadius', 12);
      await _setSide(tester, 'NodeTooltipTheme.padding', 'left', 20);
      await _tapSwatch(tester, 'NodeTooltipTheme.borderColor', 3);
      await setSlider(tester, 'NodeTooltipTheme.borderWidth', 3);
      await openFeature(tester, 'Tooltip placement');

      final code = _code(tester, 'ChildNodeTheme.tooltipTheme');
      for (final line in [
        "  message: '',\n",
        '  textStyle: TextStyle(color: Color(0xFFFFC107)),\n',
        "  tooltipBuilderResolver: (node) => node.label.endsWith('(Future)')\n"
            "      ? (context) => const Text('Not built yet', "
            'style: TextStyle(color: Colors.white))\n'
            '      : null,\n',
        '  elevation: 10,\n',
        '  boxShadow: const [\n',
        '  borderRadius: BorderRadius.circular(12),\n',
        '  padding: EdgeInsets.fromLTRB(20, 8, 12, 8),\n',
        '  borderColor: Color(0xFFFF5252),\n',
        '  borderWidth: 3,\n',
      ]) {
        expect(code, contains(line));
      }
    });

    testWidgets('a preset puts the surface settings back', (tester) async {
      await _open(tester);
      await _tapSwatch(tester, 'NodeTooltipTheme.backgroundColor', 2);
      await chooseDropdown(tester, 'NodeTooltipTheme.message', 'long');
      await tester.tap(
        find.ancestor(
          of: find.text('Light'),
          matching: find.byType(ChoiceChip),
        ),
      );
      await tester.pumpAndSettle();

      await openFeature(tester, 'Tooltip placement');
      await _toggle(tester, 'NodeTooltipTheme.useTooltip');
      final tip = _tip(tester, _f1);
      expect(tip.message, 'Folder tooltip');
      expect(tip.theme.backgroundColor, const Color(0xFF616161));
    });
  });
}
