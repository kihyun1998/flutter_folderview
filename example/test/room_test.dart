import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/shell_harness.dart';

/// How much the rendered `FolderView` is scaled on screen: its width in the
/// window over its laid-out width.
double _scale(WidgetTester tester) {
  final box = tester.renderObject(find.byType(FolderView<String>)) as RenderBox;
  final left = box.localToGlobal(Offset.zero);
  final right = box.localToGlobal(Offset(box.size.width, 0));
  return (right.dx - left.dx) / box.size.width;
}

Future<void> _chooseRoom(WidgetTester tester) async {
  await tester.tap(find.byTooltip(ViewportBar.roomLabel));
  await tester.pumpAndSettle();
}

void main() {
  group('the Room', () {
    testWidgets('draws Every setting at 1:1, where desktop scales it down', (
      tester,
    ) async {
      await pumpShell(tester);
      expect(_scale(tester), lessThan(1));

      await _chooseRoom(tester);
      expect(_scale(tester), 1);
    });

    testWidgets('is offered on a recipe, and draws it at 1:1', (tester) async {
      await pumpShell(tester);
      await openDestination(tester, 'Building a tree');
      expect(_scale(tester), lessThan(1));

      await _chooseRoom(tester);
      expect(_scale(tester), 1);
    });
  });
}
