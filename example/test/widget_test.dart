import 'package:example/main.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Replaces the `flutter create` counter smoke test, which asserted a counter
  // this app has never had and had therefore failed since the example was
  // added. Nobody saw it: CI's example job runs `flutter analyze`, never
  // `flutter test`.
  //
  // `integration_test/app_boot_test.dart` asserts the same thing against a real
  // desktop build. This is the cheap gate — it runs under `flutter test` in
  // seconds and guards the widget tree rather than the platform.
  //
  // MyApp is the pure MaterialApp + ThemeDemoPage tree. The example's `main()`
  // additionally runs the Windows-only window_manager setup, which needs a real
  // platform channel and cannot be pumped here.
  testWidgets('the demo boots and renders a FolderView with node rows', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    final folderView = find.byType(FolderView<String>);
    expect(folderView, findsOneWidget);

    // The seeded demo data's first root folder. Proves a row actually rendered,
    // rather than the view being present but empty.
    expect(
      find.descendant(
        of: folderView,
        matching: find.text('Theme System Architecture'),
      ),
      findsOneWidget,
    );
  });
}
