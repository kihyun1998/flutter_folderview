import 'package:example/app/settings_spec.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/shell_harness.dart';

void main() {
  test('the settings spec is not empty', () {
    expect(settingsSpec.expand((g) => g.features), isNotEmpty);
  });

  for (final group in settingsSpec) {
    for (final feature in group.features) {
      testWidgets('"${feature.title}" draws a control for every id it lists', (
        tester,
      ) async {
        await pumpShell(tester);
        await openFeature(tester, feature.title);

        final ids = [
          if (feature.switchId != null) feature.switchId!,
          ...feature.options,
        ];
        for (final id in ids) {
          expect(
            find.byWidgetPredicate((w) => w is SettingsControl && w.id == id),
            findsOneWidget,
            reason: id,
          );
        }
      });
    }
  }
}
