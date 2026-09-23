import 'package:example/pages/theme_demo_page.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/shell_harness.dart';

void main() {
  testWidgets(
    'the example boots into the shell with a FolderView on the stage',
    (tester) async {
      await pumpShell(tester);

      expect(find.byType(ShellPage), findsOneWidget);
      expect(find.byType(PreviewStage), findsOneWidget);

      final folderView = find.byType(FolderView<String>);
      expect(
        find.descendant(of: find.byType(PreviewStage), matching: folderView),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: folderView,
          matching: find.text('Theme System Architecture'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('the legacy panel opens the previous demo, unchanged', (
    tester,
  ) async {
    await pumpShell(tester);

    await openDestination(tester, 'Legacy panel');

    expect(find.byType(ThemeDemoPage), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ThemeDemoPage),
        matching: find.text('Theme System Architecture'),
      ),
      findsOneWidget,
    );
  });
}
