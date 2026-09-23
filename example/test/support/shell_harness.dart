import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
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

/// Opens the "Every setting" feature titled [title] in the knob region.
Future<void> openFeature(WidgetTester tester, String title) async {
  final entry = find.descendant(
    of: find.byType(FeatureListPane),
    matching: find.text(title),
  );
  await tester.ensureVisible(entry.first);
  await tester.tap(entry.first);
  await tester.pumpAndSettle();
}

/// Picks [item] from the dropdown of the control with [id].
Future<void> chooseDropdown(WidgetTester tester, String id, String item) async {
  final control = find.byWidgetPredicate(
    (w) => w is SettingsControl && w.id == id,
  );
  await tester.tap(
    find
        .descendant(
          of: control,
          matching: find.byWidgetPredicate((w) => w is DropdownButton),
        )
        .first,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(item).last);
  await tester.pumpAndSettle();
}

/// Drags the slider of the control with [id] until it reads [value].
Future<void> setSlider(WidgetTester tester, String id, double value) async {
  final control = find.byWidgetPredicate(
    (w) => w is SettingsControl && w.id == id,
  );
  final slider = tester.widget<Slider>(
    find.descendant(of: control, matching: find.byType(Slider)),
  );
  slider.onChanged!(value);
  await tester.pumpAndSettle();
}

/// The one rendered `FolderView`, read through its public parameters.
FolderView<String> renderedFolderView(WidgetTester tester) =>
    tester.widget<FolderView<String>>(find.byType(FolderView<String>));
