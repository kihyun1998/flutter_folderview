import 'package:example/main.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('example app boots and renders a FolderView with a node row',
      (tester) async {
    // Boot the real example widget tree (ProviderScope + MyApp + ThemeDemoPage)
    // directly, rather than calling the example's main(). main() runs the
    // Windows-only window_manager setup, which needs a real platform channel;
    // MyApp is the pure MaterialApp + ThemeDemoPage tree with no platform calls,
    // so it boots headlessly under the integration binding.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    final folderView = find.byType(FolderView<String>);
    expect(folderView, findsOneWidget);

    // The seeded demo data's first root folder is visible in the default
    // (folder) view mode — proof that at least one node row actually rendered.
    expect(
      find.descendant(
        of: folderView,
        matching: find.text('Theme System Architecture'),
      ),
      findsOneWidget,
    );
  });
}
