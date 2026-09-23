import 'package:example/main.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('example app boots and renders a FolderView with a node row', (
    tester,
  ) async {
    // MyApp without main(): the shell over the example's destinations, with
    // the "Every setting" stage open. main() adds the Windows window setup.
    await tester.pumpWidget(const MyApp());
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
