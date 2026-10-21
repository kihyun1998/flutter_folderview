import 'package:example/app/every_setting.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/shell_harness.dart';

Finder _inView(Finder matching) =>
    find.descendant(of: find.byType(FolderView<String>), matching: matching);

FolderViewScrollbarTheme _barTheme(WidgetTester tester) =>
    renderedFolderView(tester).theme!.scrollbarTheme;

/// Generated data with every Folder and Parent expanded, so the list scrolls
/// and the thumb is drawn, then the Scrollbars feature.
Future<void> _openScrollbars(WidgetTester tester) async {
  await pumpShell(tester);
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
  await tester.pumpAndSettle();
  await tester.tap(expandAll);
  await tester.pumpAndSettle();
  await openFeature(tester, 'Scrollbars');
}

/// Moves a mouse over the tree, or off it when [over] is false.
Future<void> _hover(WidgetTester tester, {bool over = true}) async {
  final pointer = TestPointer(1, PointerDeviceKind.mouse);
  final at = over
      ? tester.getCenter(find.byType(FolderView<String>))
      : const Offset(1, 1);
  await tester.sendEventToBinding(pointer.hover(at));
  await tester.pumpAndSettle();
}

/// The vertical bar's fading wrapper, track box and Material scrollbar.
AnimatedOpacity _fade(WidgetTester tester, [int bar = 0]) => tester
    .widget<AnimatedOpacity>(_inView(find.byType(AnimatedOpacity)).at(bar));

/// The rows' `ListView`.
ListView _list(WidgetTester tester) =>
    tester.widget<ListView>(_inView(find.byType(ListView)));

BoxDecoration _track(WidgetTester tester) =>
    tester
            .widget<Container>(
              find
                  .descendant(
                    of: _inView(find.byType(AnimatedOpacity)).first,
                    matching: find.byType(Container),
                  )
                  .first,
            )
            .decoration!
        as BoxDecoration;

double _trackWidth(WidgetTester tester) => tester
    .getSize(
      find
          .descendant(
            of: _inView(find.byType(AnimatedOpacity)).first,
            matching: find.byType(Container),
          )
          .first,
    )
    .width;

Scrollbar _scrollbar(WidgetTester tester) =>
    tester.widget<Scrollbar>(_inView(find.byType(Scrollbar)).first);

/// What the vertical `Scrollbar` paints: each call's method and paint colour,
/// and the thumb's rounded rect.
({List<(Symbol, int)> calls, RRect? thumb}) _painted(WidgetTester tester) {
  final calls = <(Symbol, int)>[];
  RRect? thumb;
  expect(
    tester.renderObject(_inView(find.byType(Scrollbar)).first),
    paints..everything((method, args) {
      if (method == #drawRect || method == #drawLine || method == #drawRRect) {
        calls.add((method, (args.last as Paint).color.toARGB32()));
        if (method == #drawRRect) thumb = args.first as RRect;
      }
      return true;
    }),
  );
  return (calls: calls, thumb: thumb);
}

Future<void> _tapSwatch(WidgetTester tester, String id, int index) async {
  final swatch = find.byKey(ValueKey('$id.$index'));
  await tester.ensureVisible(swatch);
  await tester.pumpAndSettle();
  await tester.tap(swatch);
  await tester.pumpAndSettle();
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

void main() {
  group('Every setting: Scrollbars', () {
    testWidgets('opens on the light theme; the bar shows only on hover', (
      tester,
    ) async {
      await _openScrollbars(tester);

      expect(
        _barTheme(tester),
        FlutterFolderViewTheme<String>.light().scrollbarTheme,
      );
      await _hover(tester, over: false);
      expect(_fade(tester).opacity, 0.0);
      await _hover(tester);
      expect(_fade(tester).opacity, 0.8);
    });

    testWidgets('the opacities and the fade duration reach the bar', (
      tester,
    ) async {
      await _openScrollbars(tester);

      await setSlider(tester, 'FolderViewScrollbarTheme.hoverOpacity', 0.5);
      await setSlider(tester, 'FolderViewScrollbarTheme.nonHoverOpacity', 0.2);
      await setSlider(
        tester,
        'FolderViewScrollbarTheme.hoverAnimationDuration',
        600,
      );
      expect(_barTheme(tester).hoverOpacity, closeTo(0.5, 1e-9));
      expect(_barTheme(tester).nonHoverOpacity, closeTo(0.2, 1e-9));
      expect(_fade(tester).duration, const Duration(milliseconds: 600));

      await _hover(tester);
      expect(_fade(tester).opacity, closeTo(0.5, 1e-9));
      // Leaving the tree fades back, so the exit is exercised too.
      await _hover(tester, over: false);
      expect(_fade(tester).opacity, closeTo(0.2, 1e-9));
    });

    testWidgets('track width, radius and colour style the track box', (
      tester,
    ) async {
      await _openScrollbars(tester);

      await setSlider(tester, 'FolderViewScrollbarTheme.trackWidth', 24);
      await setSlider(tester, 'FolderViewScrollbarTheme.trackRadius', 2);
      await _tapSwatch(tester, 'FolderViewScrollbarTheme.trackColor', 2);

      final picked = EverySettingDemo.scrollbarTrackColors[2];
      expect(_barTheme(tester).trackWidth, 24);
      expect(_trackWidth(tester), 24);
      expect(_track(tester).borderRadius, BorderRadius.circular(2));
      expect(_track(tester).color!.toARGB32(), picked.toARGB32());
    });

    testWidgets(
      'thumb colour, thickness and radius are what the thumb paints',
      (tester) async {
        await _openScrollbars(tester);
        await _hover(tester);

        await _tapSwatch(tester, 'FolderViewScrollbarTheme.thumbColor', 1);
        await setSlider(tester, 'FolderViewScrollbarTheme.thickness', 6);
        await setSlider(tester, 'FolderViewScrollbarTheme.radius', 3);

        final picked = EverySettingDemo.scrollbarThumbColors[1];
        final thumb = _painted(tester).thumb!;
        expect(
          _painted(tester).calls.where((c) => c.$1 == #drawRRect).single.$2,
          picked.toARGB32(),
        );
        expect(thumb.width, 6);
        expect(thumb.tlRadius, const Radius.circular(3));
      },
    );

    testWidgets('the box in trackColor is the only track', (tester) async {
      await _openScrollbars(tester);
      await _hover(tester);
      await _tapSwatch(tester, 'FolderViewScrollbarTheme.trackColor', 2);

      expect(_scrollbar(tester).trackVisibility, isNot(true));
      expect(
        _painted(
          tester,
        ).calls.where((c) => c.$1 == #drawRect && (c.$2 >> 24) != 0),
        isEmpty,
      );
      expect(
        _track(tester).color!.toARGB32(),
        EverySettingDemo.scrollbarTrackColors[2].toARGB32(),
      );
    });

    testWidgets('a thickness above the track width is painted at what fits', (
      tester,
    ) async {
      await _openScrollbars(tester);
      await _hover(tester);
      await setSlider(tester, 'FolderViewScrollbarTheme.trackWidth', 8);
      await setSlider(tester, 'FolderViewScrollbarTheme.thickness', 20);

      expect(_barTheme(tester).thickness, 20);
      expect(_trackWidth(tester), 8);
      final thumb = _painted(tester).thumb!;
      expect(thumb.left, greaterThanOrEqualTo(0));
      expect(thumb.right, lessThanOrEqualTo(8));
    });

    testWidgets('thumbVisibility reaches the Material scrollbar', (
      tester,
    ) async {
      await _openScrollbars(tester);
      expect(_scrollbar(tester).thumbVisibility, isTrue);

      await _toggle(tester, 'FolderViewScrollbarTheme.thumbVisibility');
      expect(_barTheme(tester).thumbVisibility, isFalse);
      expect(_scrollbar(tester).thumbVisibility, isFalse);
    });

    testWidgets('the bar keeps its size at every Scale, while rows double', (
      tester,
    ) async {
      await _openScrollbars(tester);
      final width = _trackWidth(tester);
      final thumb = _painted(tester).thumb!.width;
      final row = _list(tester).itemExtent!;

      await openFeature(tester, 'Scale');
      await setSlider(tester, 'FolderView.scale', 2.0);
      expect(_list(tester).itemExtent, row * 2);
      expect(_trackWidth(tester), width);
      expect(_painted(tester).thumb!.width, thumb);
      expect(_track(tester).borderRadius, BorderRadius.circular(8));
    });

    testWidgets('the horizontal bar, shown when content is wider, reads the '
        'same fields', (tester) async {
      await _openScrollbars(tester);
      await tester.tap(find.byTooltip(ViewportSpec.mobile.label));
      await tester.pumpAndSettle();
      await openFeature(tester, 'Scale');
      await setSlider(tester, 'FolderView.scale', 3.0);
      await openFeature(tester, 'Scrollbars');
      await setSlider(tester, 'FolderViewScrollbarTheme.trackWidth', 24);
      await setSlider(tester, 'FolderViewScrollbarTheme.thickness', 6);
      await _hover(tester);

      final bars = _inView(find.byType(Scrollbar));
      expect(bars, findsNWidgets(2), reason: 'no horizontal bar');
      final horizontal = find
          .descendant(
            of: _inView(find.byType(AnimatedOpacity)).at(1),
            matching: find.byType(Container),
          )
          .first;
      expect(tester.getSize(horizontal).height, 24);
      expect(_fade(tester, 1).opacity, 0.8);
      final thumbs = <RRect>[];
      expect(
        tester.renderObject(bars.at(1)),
        paints..everything((method, args) {
          if (method == #drawRRect) thumbs.add(args.first as RRect);
          return true;
        }),
      );
      expect(thumbs.single.height, 6);
    });

    testWidgets('the scrollbarTheme control shows the sub-theme as code', (
      tester,
    ) async {
      await _openScrollbars(tester);
      await setSlider(tester, 'FolderViewScrollbarTheme.thickness', 6);

      final code = tester
          .widget<SelectableText>(
            find.descendant(
              of: find.byWidgetPredicate(
                (w) =>
                    w is SettingsControl &&
                    w.id == 'FlutterFolderViewTheme.scrollbarTheme',
              ),
              matching: find.byType(SelectableText),
            ),
          )
          .data!;
      expect(
        code,
        'scrollbarTheme: const FolderViewScrollbarTheme(\n'
        '  thumbColor: Color(0xFF757575),\n'
        '  trackColor: Color(0xFFEEEEEE),\n'
        '  thickness: 6,\n'
        '  radius: 4,\n'
        '  thumbVisibility: true,\n'
        '  hoverOpacity: 0.8,\n'
        '  nonHoverOpacity: 0,\n'
        '  hoverAnimationDuration: Duration(milliseconds: 200),\n'
        '  trackWidth: 16,\n'
        '  trackRadius: 8,\n'
        '),',
      );
    });
  });
}
