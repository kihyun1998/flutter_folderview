import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_smooth_wheel_scroll/flutter_smooth_wheel_scroll.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/shell_harness.dart';

WheelMotion? _motion(WidgetTester tester) =>
    renderedFolderView(tester).wheelMotion;

String _code(WidgetTester tester) =>
    tester.widget<SelectableText>(find.byKey(const Key('wheel-code'))).data!;

Slider _slider(WidgetTester tester, String id) => tester.widget<Slider>(
  find.descendant(
    of: find.byWidgetPredicate((w) => w is SettingsControl && w.id == id),
    matching: find.byType(Slider),
  ),
);

void main() {
  group('Every setting: Smooth wheel', () {
    testWidgets('opens on the library default, a 400 ms spring with no '
        'bounce', (tester) async {
      await pumpShell(tester);
      await openFeature(tester, 'Smooth wheel');

      final motion = _motion(tester);
      expect(motion, isA<SpringWheelMotion>());
      motion as SpringWheelMotion;
      expect(motion.duration, const Duration(milliseconds: 400));
      expect(motion.bounce, 0);
      expect(_code(tester), contains('WheelMotion.spring('));
    });

    testWidgets('Off passes null', (tester) async {
      await pumpShell(tester);
      await openFeature(tester, 'Smooth wheel');

      await chooseDropdown(tester, 'FolderView.wheelMotion', 'Off');
      expect(_motion(tester), isNull);
      expect(_code(tester), 'wheelMotion: null,');
    });

    testWidgets('Spring takes the duration and bounce', (tester) async {
      await pumpShell(tester);
      await openFeature(tester, 'Smooth wheel');

      await setSlider(tester, 'wheelDurationMs', 250);
      await setSlider(tester, 'wheelBounce', 0.3);
      final motion = _motion(tester) as SpringWheelMotion;
      expect(motion.duration, const Duration(milliseconds: 250));
      expect(motion.bounce, closeTo(0.3, 1e-9));
      expect(_code(tester), contains('milliseconds: 250'));
      expect(_code(tester), contains('bounce: 0.30'));
    });

    testWidgets('Curve takes the duration and the chosen curve', (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'Smooth wheel');

      await chooseDropdown(tester, 'FolderView.wheelMotion', 'Curve');
      await chooseDropdown(tester, 'wheelCurve', 'decelerate');
      await setSlider(tester, 'wheelDurationMs', 600);
      final motion = _motion(tester) as CurveWheelMotion;
      expect(motion.duration, const Duration(milliseconds: 600));
      expect(motion.curve, Curves.decelerate);
      expect(_code(tester), contains('Curves.decelerate'));
    });

    testWidgets('Lerp takes the time constant', (tester) async {
      await pumpShell(tester);
      await openFeature(tester, 'Smooth wheel');

      await chooseDropdown(tester, 'FolderView.wheelMotion', 'Lerp');
      await setSlider(tester, 'wheelTimeConstantMs', 120);
      final motion = _motion(tester) as LerpWheelMotion;
      expect(motion.timeConstant, const Duration(milliseconds: 120));
      expect(_code(tester), contains('milliseconds: 120'));
    });

    testWidgets('a knob the chosen motion does not read is disabled', (
      tester,
    ) async {
      await pumpShell(tester);
      await openFeature(tester, 'Smooth wheel');

      // Spring reads duration and bounce.
      expect(_slider(tester, 'wheelDurationMs').onChanged, isNotNull);
      expect(_slider(tester, 'wheelBounce').onChanged, isNotNull);
      expect(_slider(tester, 'wheelTimeConstantMs').onChanged, isNull);

      await chooseDropdown(tester, 'FolderView.wheelMotion', 'Lerp');
      expect(_slider(tester, 'wheelDurationMs').onChanged, isNull);
      expect(_slider(tester, 'wheelBounce').onChanged, isNull);
      expect(_slider(tester, 'wheelTimeConstantMs').onChanged, isNotNull);
    });
  });
}
