import 'package:example/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // The FolderView subtree; row labels are scoped to it so control-panel text
  // never collides with node labels.
  final folderView = find.byType(FolderView<String>);
  Finder row(String label) =>
      find.descendant(of: folderView, matching: find.text(label));

  testWidgets('example app: expand, select, zoom, and switch view mode',
      (tester) async {
    // Boot the real example widget tree (no main(); avoids window_manager).
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();
    expect(folderView, findsOneWidget);
    expect(row('Theme System Architecture'), findsOneWidget);

    // --- Expand -----------------------------------------------------------
    // 'FolderViewTheme (InheritedWidget)' (id 1-2) is collapsed at boot, so its
    // child 'of(context) method' is not rendered. A single tap toggles expand
    // (the example wires onNodeTap -> toggleNode for expandable rows).
    expect(row('of(context) method'), findsNothing);
    await tester.tap(row('FolderViewTheme (InheritedWidget)'));
    await tester.pumpAndSettle();
    expect(row('of(context) method'), findsOneWidget); // children revealed

    // --- Select -----------------------------------------------------------
    // Tapping a child selects it; the selected child renders in the theme's
    // selectedTextStyle (bold), while its base style carries no weight.
    FontWeight? weightOf(String label) =>
        tester.widget<Text>(row(label)).style?.fontWeight;
    expect(weightOf('FolderViewLineTheme'), isNot(FontWeight.bold));
    await tester.tap(row('FolderViewLineTheme'));
    await tester.pump(const Duration(milliseconds: 350)); // flush click timer
    await tester.pumpAndSettle();
    expect(weightOf('FolderViewLineTheme'), FontWeight.bold); // selected

    // --- Zoom (Ctrl+wheel) ------------------------------------------------
    // The example wires onScaleChanged -> setScale, so ctrl+wheel-up grows the
    // whole layout. Measure a stable row's rendered height before and after.
    double labelHeight() =>
        tester.getSize(row('Theme System Architecture')).height;
    final before = labelHeight();

    debugDefaultTargetPlatformOverride = TargetPlatform.windows; // Ctrl modifier
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

    // --- Switch View Mode -------------------------------------------------
    // The SegmentedButton flips folder <-> tree. In tree mode Folders are
    // hidden and their Parents lifted, so the root Folder label disappears.
    await tester.tap(find.text('Tree'));
    await tester.pumpAndSettle();
    expect(row('Theme System Architecture'), findsNothing); // re-projected
  });
}
