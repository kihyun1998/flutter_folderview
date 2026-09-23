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

  for (final spec in ViewportSpec.values) {
    testWidgets('the stage renders the FolderView at ${spec.id} width', (
      tester,
    ) async {
      await pumpShell(tester);

      await tester.tap(find.byTooltip(spec.label).first);
      await tester.pumpAndSettle();

      expect(tester.widget<PreviewStage>(find.byType(PreviewStage)).spec, spec);
      expect(
        find.descendant(
          of: find.byType(PreviewStage),
          matching: find.byType(FolderView<String>),
        ),
        findsOneWidget,
      );
    });
  }

  testWidgets('the Device Wall renders the FolderView in every frame', (
    tester,
  ) async {
    await pumpShell(tester);

    await tester.tap(find.byTooltip(ViewportBar.wallLabel).first);
    await tester.pumpAndSettle();

    expect(find.byType(DeviceWall), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(DeviceWall),
        matching: find.byType(FolderView<String>),
      ),
      findsNWidgets(ViewportSpec.values.length),
    );
  });

  testWidgets('the legacy panel opens the previous demo, unchanged', (
    tester,
  ) async {
    await pumpShell(tester);

    await openDestination(tester, 'Legacy panel');

    expect(find.byType(ShellMenu), findsNothing);
    expect(find.byType(ThemeDemoPage), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ThemeDemoPage),
        matching: find.text('Theme System Architecture'),
      ),
      findsOneWidget,
    );

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(ThemeDemoPage), findsNothing);
    expect(find.byType(ShellMenu), findsOneWidget);
  });
}
