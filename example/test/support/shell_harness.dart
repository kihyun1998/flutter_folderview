import 'package:example/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sizes the test view above `ShellPage.narrowBreakpoint`, so the three-region
/// layout builds.
void useWideView(WidgetTester tester) {
  tester.view.physicalSize = const Size(1600, 1000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Pumps the example app as it boots: the shell over this app's destinations.
Future<void> pumpShell(WidgetTester tester) async {
  useWideView(tester);
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
}

/// Opens the destination whose menu label is [label].
Future<void> openDestination(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).first);
  await tester.pumpAndSettle();
}

/// The one rendered `FolderView`, read through its public parameters.
FolderView<String> renderedFolderView(WidgetTester tester) =>
    tester.widget<FolderView<String>>(find.byType(FolderView<String>));
