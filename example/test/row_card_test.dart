import 'package:example/app/row_card_settings.dart';
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

/// The row card's `JustTooltip` around [label]'s row.
Finder _cardOf(String label) => find.ancestor(
  of: _labelFinder(label),
  matching: find.byWidgetPredicate(
    (w) => w is JustTooltip && w.anchor == TooltipAnchor.pointer,
  ),
);

JustTooltip _card(WidgetTester tester, String label) =>
    tester.widget<JustTooltip>(_cardOf(label));

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

String _builderCode(WidgetTester tester) => tester
    .widget<SelectableText>(find.byKey(const Key('row-card-builder-code')))
    .data!;

List<String> _log(WidgetTester tester) => tester
    .widgetList<Text>(
      find.descendant(
        of: find.byKey(const Key('row-card-log')),
        matching: find.byType(Text),
      ),
    )
    .map((t) => t.data!)
    .toList();

/// Opens Row card placement & surface and picks [content].
Future<void> _open(
  WidgetTester tester, {
  String content = 'every Node',
  bool room = false,
}) async {
  await pumpShell(tester);
  if (room) {
    await tester.tap(find.byTooltip(ViewportBar.roomLabel));
    await tester.pumpAndSettle();
  }
  await openFeature(tester, 'Row card placement & surface');
  await chooseDropdown(tester, 'FolderView.rowTooltipBuilder', content);
}

Future<TestGesture> _mouse(WidgetTester tester) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  addTearDown(mouse.removePointer);
  await mouse.addPointer(location: Offset.zero);
  return mouse;
}

/// A point on [label]'s row, to the right of the label itself.
Offset _besideLabel(WidgetTester tester, String label) {
  final r = tester.getRect(_labelFinder(label));
  return Offset(r.right + 40, r.center.dy);
}

String _cardText(String label, String type) => '$type: $label';

/// Sets every behaviour and animation setting away from its default.
Future<void> _setBehaviour(WidgetTester tester) async {
  await _toggle(tester, 'RowTooltipTheme.interactive');
  await setSlider(tester, 'RowTooltipTheme.waitDuration', 500);
  await setSlider(tester, 'RowTooltipTheme.showDuration', 2000);
  await _toggle(tester, 'RowTooltipTheme.enableHover');
  await _toggle(tester, 'RowTooltipTheme.onShow');
  await _toggle(tester, 'RowTooltipTheme.onHide');
  await chooseDropdown(tester, 'RowTooltipTheme.animation', 'rotation');
  await chooseDropdown(tester, 'RowTooltipTheme.animationCurve', 'easeOutBack');
  await setSlider(tester, 'RowTooltipTheme.animationDuration', 400);
  await setSlider(tester, 'RowTooltipTheme.fadeBegin', 0.5);
  await setSlider(tester, 'RowTooltipTheme.scaleBegin', 0.25);
  await setSlider(tester, 'RowTooltipTheme.slideOffset', 0.75);
  await setSlider(tester, 'RowTooltipTheme.rotationBegin', 0.2);
}

/// Sets every placement and surface setting away from its default.
Future<void> _setPlacement(WidgetTester tester) async {
  await chooseDropdown(tester, 'RowTooltipTheme.direction', 'bottom');
  await chooseDropdown(tester, 'RowTooltipTheme.alignment', 'start');
  await setSlider(tester, 'RowTooltipTheme.offset', 20);
  await setSlider(tester, 'RowTooltipTheme.crossAxisOffset', 10);
  await setSlider(tester, 'RowTooltipTheme.screenMargin', 16);
  await _toggle(tester, 'RowTooltipTheme.surface');
}

void main() {
  group('Every setting: Row card', () {
    testWidgets('with rowTooltipBuilder null no row is wrapped', (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'Row card placement & surface');

      expect(_cardOf(_f1), findsNothing);
      expect(renderedFolderView(tester).rowTooltipBuilder, isNull);
      expect(renderedFolderView(tester).rowTooltipTheme, isNull);
      expect(_builderCode(tester), 'rowTooltipBuilder: null,');
      expect(
        _code(tester, 'FolderView.rowTooltipTheme'),
        'rowTooltipTheme: null,',
      );
    });

    testWidgets('every Node gets a pointer-anchored card with the theme '
        'defaults', (tester) async {
      await _open(tester);

      final card = _card(tester, _f1);
      expect(_cardOf(_c1), findsOneWidget);
      expect(renderedFolderView(tester).rowTooltipTheme, isNull);
      const d = RowTooltipTheme();
      expect(card.direction, d.direction);
      expect(card.alignment, d.alignment);
      expect(card.offset, d.offset);
      expect(card.crossAxisOffset, d.crossAxisOffset);
      expect(card.screenMargin, d.screenMargin);
      expect(card.theme, const JustTooltipTheme.bare());
      expect(card.interactive, isTrue);
      expect(card.enableHover, isTrue);
      expect(card.tap, isNull);
      // ignore: deprecated_member_use
      expect(card.enableTap, isFalse);
      expect(card.waitDuration, isNull);
      expect(card.showDuration, isNull);
      expect(card.animation, TooltipAnimation.fade);
      expect(card.animationCurve, d.animationCurve);
      expect(card.animationDuration, d.animationDuration);
      expect(card.fadeBegin, d.fadeBegin);
      expect(card.scaleBegin, d.scaleBegin);
      expect(card.slideOffset, d.slideOffset);
      expect(card.rotationBegin, d.rotationBegin);
      expect(card.onShow, isNull);
      expect(card.onHide, isNull);
      final built =
          card.tooltipBuilder!(tester.element(_labelFinder(_f1))) as Card;
      final text = (built.child! as Padding).child! as Text;
      expect(text.data, _cardText(_f1, 'folder'));
    });

    testWidgets('Folders and Parents only leaves Child rows unwrapped', (
      tester,
    ) async {
      await _open(tester, content: 'Folders and Parents');

      expect(_cardOf(_f1), findsOneWidget);
      expect(_cardOf(_c1), findsNothing);
      expect(_builderCode(tester), contains('node.type == NodeType.child'));
    });

    testWidgets('every placement and surface setting reaches the card', (
      tester,
    ) async {
      await _open(tester);
      await _setPlacement(tester);

      final card = _card(tester, _f1);
      expect(card.anchor, TooltipAnchor.pointer);
      expect(card.direction, TooltipDirection.bottom);
      expect(card.alignment, TooltipAlignment.start);
      expect(card.offset, 20);
      expect(card.crossAxisOffset, 10);
      expect(card.screenMargin, 16);
      expect(card.theme, RowCardSettings.sampleSurface);
    });

    testWidgets('every behaviour and animation setting reaches the card', (
      tester,
    ) async {
      await _open(tester);
      await openFeature(tester, 'Row card behaviour & animation');
      await _setBehaviour(tester);

      final card = _card(tester, _f1);
      expect(card.interactive, isFalse);
      expect(card.waitDuration, const Duration(milliseconds: 500));
      expect(card.showDuration, const Duration(seconds: 2));
      expect(card.enableHover, isFalse);
      expect(card.onShow, isNotNull);
      expect(card.onHide, isNotNull);
      expect(card.animation, TooltipAnimation.rotation);
      expect(card.animationCurve, Curves.easeOutBack);
      expect(card.animationDuration, const Duration(milliseconds: 400));
      expect(card.fadeBegin, 0.5);
      expect(card.scaleBegin, 0.25);
      expect(card.slideOffset, 0.75);
      expect(card.rotationBegin, 0.2);
    });

    testWidgets('in the Room a hovered row shows its card at 1:1, inside the '
        'window, in the root Overlay', (tester) async {
      await _open(tester, room: true);
      final mouse = await _mouse(tester);

      final at = _besideLabel(tester, _f1);
      await mouse.moveTo(at);
      await tester.pumpAndSettle();
      final text = find.text(_cardText(_f1, 'folder'));
      expect(text, findsOneWidget);

      final card = tester.getRect(
        find.ancestor(of: text, matching: find.byType(Card)),
      );
      final window = Offset.zero & tester.view.physicalSize;
      expect(window.contains(card.topLeft), isTrue);
      expect(window.contains(card.bottomRight), isTrue);
      final box = tester.renderObject(text) as RenderBox;
      expect(
        tester.getRect(text).width,
        closeTo(box.size.width, 0.01),
        reason: 'painted width equals laid-out width: 1:1',
      );
      expect(
        card.bottom,
        lessThanOrEqualTo(at.dy),
        reason: 'above the pointer',
      );
      expect(
        tester.state<OverlayState>(
          find.ancestor(of: text, matching: find.byType(Overlay)).first,
        ),
        same(tester.state<OverlayState>(find.byType(Overlay).first)),
      );
    });

    testWidgets('with enableHover off a hovered row shows no card', (
      tester,
    ) async {
      await _open(tester, room: true);
      final mouse = await _mouse(tester);
      await mouse.moveTo(_besideLabel(tester, _f1));
      await tester.pumpAndSettle();
      expect(find.text(_cardText(_f1, 'folder')), findsOneWidget);
      await mouse.moveTo(Offset.zero);
      await tester.pumpAndSettle();

      await openFeature(tester, 'Row card behaviour & animation');
      await _toggle(tester, 'RowTooltipTheme.enableHover');
      await mouse.moveTo(_besideLabel(tester, _f1));
      await tester.pumpAndSettle();
      expect(find.text(_cardText(_f1, 'folder')), findsNothing);
    });

    testWidgets('onShow and onHide are logged as the card shows and hides', (
      tester,
    ) async {
      await _open(tester, room: true);
      await openFeature(tester, 'Row card behaviour & animation');
      await _toggle(tester, 'RowTooltipTheme.onShow');
      await _toggle(tester, 'RowTooltipTheme.onHide');
      await _toggle(tester, 'RowTooltipTheme.interactive');
      final mouse = await _mouse(tester);

      await mouse.moveTo(_besideLabel(tester, _f1));
      await tester.pumpAndSettle();
      expect(find.text(_cardText(_f1, 'folder')), findsOneWidget);
      expect(_log(tester), ['onShow · row card']);

      await mouse.moveTo(Offset.zero);
      await tester.pumpAndSettle();
      expect(find.text(_cardText(_f1, 'folder')), findsNothing);
      expect(_log(tester), ['onHide · row card', 'onShow · row card']);
    });

    testWidgets('a row tap still reaches onNodeTap with the card on', (
      tester,
    ) async {
      await _open(tester, room: true);

      await tester.tap(_labelFinder(_c1));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(renderedFolderView(tester).selectedNodeIds, {'1-1-1'});
    });

    testWidgets('a theme preset leaves the row card as it is', (tester) async {
      await _open(tester);
      await chooseDropdown(tester, 'RowTooltipTheme.direction', 'bottom');
      await tester.tap(
        find.ancestor(of: find.text('Dark'), matching: find.byType(ChoiceChip)),
      );
      await tester.pumpAndSettle();

      expect(_card(tester, _f1).direction, TooltipDirection.bottom);
    });

    testWidgets('the code shows each setting once it is set', (tester) async {
      await _open(tester);
      await _setPlacement(tester);
      await openFeature(tester, 'Row card behaviour & animation');
      await _setBehaviour(tester);
      await openFeature(tester, 'Row card placement & surface');

      expect(
        _code(tester, 'FolderView.rowTooltipTheme'),
        'rowTooltipTheme: RowTooltipTheme(\n'
        '  direction: TooltipDirection.bottom,\n'
        '  alignment: TooltipAlignment.start,\n'
        '  offset: 20,\n'
        '  crossAxisOffset: 10,\n'
        '  screenMargin: 16,\n'
        '  surface: JustTooltipTheme(\n'
        '    backgroundColor: Color(0xFF263238),\n'
        '    borderRadius: BorderRadius.all(Radius.circular(8)),\n'
        '    padding: EdgeInsets.all(8),\n'
        '    elevation: 4,\n'
        '  ),\n'
        '  interactive: false,\n'
        '  waitDuration: Duration(milliseconds: 500),\n'
        '  showDuration: Duration(milliseconds: 2000),\n'
        '  enableHover: false,\n'
        '  animation: TooltipAnimation.rotation,\n'
        '  animationCurve: Curves.easeOutBack,\n'
        '  animationDuration: Duration(milliseconds: 400),\n'
        '  fadeBegin: 0.5,\n'
        '  scaleBegin: 0.25,\n'
        '  slideOffset: 0.75,\n'
        '  rotationBegin: 0.2,\n'
        "  onShow: () => debugPrint('onShow · row card'),\n"
        "  onHide: () => debugPrint('onHide · row card'),\n"
        '),',
      );
    });
  });

  group('Row card in a preview frame', () {
    for (final spec in [
      ViewportSpec.desktop,
      ViewportSpec.tablet,
      ViewportSpec.mobile,
    ]) {
      testWidgets('${spec.label}: a card raised at the stage\'s corners stays '
          'inside the frame', (tester) async {
        await _open(tester);
        await tester.tap(find.byTooltip(spec.label));
        await tester.pumpAndSettle();
        final mouse = await _mouse(tester);

        final view = tester.getRect(find.byType(FolderView<String>));
        final row = tester.getRect(_labelFinder(_f1));
        final points = {
          'top-left': Offset(view.left + 2, row.center.dy),
          'top-right': Offset(view.right - 2, row.center.dy),
        };
        for (final MapEntry(key: where, value: at) in points.entries) {
          await mouse.moveTo(Offset.zero);
          await tester.pumpAndSettle();
          await mouse.moveTo(at);
          await tester.pumpAndSettle();
          final text = find.text(_cardText(_f1, 'folder'));
          expect(text, findsOneWidget, reason: where);
          final card = tester.getRect(
            find.ancestor(of: text, matching: find.byType(Card)),
          );
          final overlay = tester.getRect(
            find.ancestor(of: text, matching: find.byType(Overlay)).first,
          );
          expect(
            overlay.contains(card.topLeft) &&
                overlay.contains(card.bottomRight),
            isTrue,
            reason: '$where: card $card, frame overlay $overlay',
          );
          expect(
            overlay,
            isNot(Offset.zero & tester.view.physicalSize),
            reason: 'the frame\'s own Overlay, not the window',
          );
          // The frame scales its stage down, so painted is less than laid
          // out; the Room case's 1:1 can therefore fail.
          final painted = tester.getRect(text).width;
          final laidOut = (tester.renderObject(text) as RenderBox).size.width;
          expect(painted / laidOut, lessThan(0.99), reason: where);
        }
      });
    }
  });
}
