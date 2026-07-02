import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_folderview/widgets/custom_ink_well.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Characterization tests: lock the OBSERVABLE tap behavior so the dead-code
  // removal in _handleTap can be proven behavior-preserving. Current contract:
  //   - Ctrl+tap        → onTap once, onDoubleTap never
  //   - single tap      → onTap once, onDoubleTap never
  //   - double tap      → onTap once (first tap) AND onDoubleTap once (second)
  const clickInterval = 300;

  late int onTap;
  late int onDoubleTap;

  Widget harness() {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: CustomInkWell(
            clickInterval: clickInterval,
            onTap: () => onTap++,
            onDoubleTap: () => onDoubleTap++,
            child: const SizedBox(width: 100, height: 40),
          ),
        ),
      ),
    );
  }

  setUp(() {
    onTap = 0;
    onDoubleTap = 0;
  });

  testWidgets('Ctrl+tap fires onTap once and never onDoubleTap',
      (tester) async {
    await tester.pumpWidget(harness());

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.tap(find.byType(CustomInkWell));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump(const Duration(milliseconds: clickInterval + 50));

    expect(onTap, 1);
    expect(onDoubleTap, 0);
  });

  testWidgets('single tap (no follow-up) fires onTap once, no onDoubleTap',
      (tester) async {
    await tester.pumpWidget(harness());

    await tester.tap(find.byType(CustomInkWell));
    // Let the single-tap timer elapse.
    await tester.pump(const Duration(milliseconds: clickInterval + 50));

    expect(onTap, 1);
    expect(onDoubleTap, 0);
  });

  testWidgets('double tap fires onTap once (first) and onDoubleTap once',
      (tester) async {
    await tester.pumpWidget(harness());

    await tester.tap(find.byType(CustomInkWell));
    await tester.pump(const Duration(milliseconds: 50)); // within interval
    await tester.tap(find.byType(CustomInkWell));
    await tester.pump(const Duration(milliseconds: clickInterval + 50));

    expect(onTap, 1);
    expect(onDoubleTap, 1);
  });
}
