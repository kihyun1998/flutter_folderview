import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/support/shell_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // The FolderView subtree; row labels are scoped to it so control-panel text
  // never collides with node labels.
  final folderView = find.byType(FolderView<String>);
  Finder row(String label) =>
      find.descendant(of: folderView, matching: find.text(label));

  testWidgets('example app: expand, select, zoom, and switch view mode', (
    tester,
  ) async {
    // MyApp without main(): the shell, which opens on "Every setting", over
    // the demo data. Its tap handler expands containers and selects Children.
    await pumpShell(tester);
    expect(folderView, findsOneWidget);
    expect(row('Theme System Architecture'), findsOneWidget);

    // --- Expand -----------------------------------------------------------
    // 'FolderViewTheme (InheritedWidget)' (id 1-2) is collapsed at boot, so its
    // child 'of(context) method' is not rendered. A single tap toggles expand
    // ("Every setting" wires onNodeTap to expand a container).
    expect(row('of(context) method'), findsNothing);
    await tester.tap(row('FolderViewTheme (InheritedWidget)'));
    await tester.pumpAndSettle();
    expect(row('of(context) method'), findsOneWidget); // children revealed

    // --- Select -----------------------------------------------------------
    // Tapping a child selects it; the selected child renders in the theme's
    // selectedTextStyle (bold by default), while its base style carries no
    // weight.
    FontWeight? weightOf(String label) =>
        tester.widget<Text>(row(label)).style?.fontWeight;
    expect(weightOf('FolderViewLineTheme'), isNot(FontWeight.bold));
    await tester.tap(row('FolderViewLineTheme'));
    await tester.pump(const Duration(milliseconds: 350)); // flush click timer
    await tester.pumpAndSettle();
    expect(weightOf('FolderViewLineTheme'), FontWeight.bold); // selected

    // --- Zoom (Ctrl+wheel) ------------------------------------------------
    // "Every setting" has its onScaleChanged handler on by default, so
    // ctrl+wheel-up grows the whole layout. Measure a stable row's rendered
    // height before and after.
    double labelHeight() =>
        tester.getSize(row('Theme System Architecture')).height;
    final before = labelHeight();

    debugDefaultTargetPlatformOverride =
        TargetPlatform.windows; // Ctrl modifier
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    try {
      final center = tester.getCenter(folderView);
      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(pointer.hover(center));
      // Several wheel-up ticks; settle between each so the scale state
      // propagates and the deltas compound (each tick reads the updated scale).
      for (var i = 0; i < 5; i++) {
        await tester.sendEventToBinding(pointer.scroll(const Offset(0, -50)));
        await tester.pumpAndSettle();
      }
    } finally {
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      debugDefaultTargetPlatformOverride = null;
    }

    expect(labelHeight(), greaterThan(before)); // layout scaled up
    expect(renderedFolderView(tester).scale, greaterThan(1.0));

    // --- Switch View Mode -------------------------------------------------
    // The View Mode control flips folder <-> tree. In tree mode Folders are
    // hidden and their Parents lifted, so the root Folder label disappears.
    await openFeature(tester, 'View Mode');
    await chooseDropdown(tester, 'FolderView.mode', 'tree');
    expect(renderedFolderView(tester).mode, ViewMode.tree);
    expect(row('Theme System Architecture'), findsNothing); // re-projected
  });
}
