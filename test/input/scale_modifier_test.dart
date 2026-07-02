import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

// Imported via the public barrel on purpose: this locks both the BEHAVIOR of
// isScaleModifierPressed AND the fact that it stays exported from the package,
// so moving its definition to a dedicated module can be proven non-breaking.
//
// debugDefaultTargetPlatformOverride must be reset before the test body ends
// (testWidgets verifies foundation debug vars are unset at that point, which is
// earlier than tearDown), so each test resets it in a finally block.
void main() {
  testWidgets('on Windows, Control is the scale modifier and Meta is not',
      (tester) async {
    await tester.pumpWidget(const SizedBox());
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      expect(isScaleModifierPressed(), isTrue);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      expect(isScaleModifierPressed(), isFalse,
          reason: 'Windows checks Control only (avoids sticky-Meta bug)');
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('on macOS, Meta is the scale modifier and Control is not',
      (tester) async {
    await tester.pumpWidget(const SizedBox());
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      expect(isScaleModifierPressed(), isTrue);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      expect(isScaleModifierPressed(), isFalse);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
