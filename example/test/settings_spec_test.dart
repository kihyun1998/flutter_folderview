import 'package:example/app/settings_spec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final features = [for (final g in settingsSpec) ...g.features];

  test('group and feature ids are unique', () {
    final groupIds = settingsSpec.map((g) => g.id).toList();
    final featureIds = features.map((f) => f.id).toList();
    expect(groupIds.toSet(), hasLength(groupIds.length));
    expect(featureIds.toSet(), hasLength(featureIds.length));
  });

  test('every option and switch id appears once across the spec', () {
    final ids = [
      for (final f in features) ...[
        ...f.options,
        if (f.switchId != null) f.switchId!,
      ],
    ];
    expect(ids.toSet(), hasLength(ids.length));
  });

  test('every interaction names another feature and cites evidence', () {
    final featureIds = features.map((f) => f.id).toSet();
    for (final f in features) {
      for (final i in f.interactions) {
        expect(featureIds, contains(i.otherFeatureId), reason: f.id);
        expect(i.otherFeatureId, isNot(f.id), reason: f.id);
        expect(i.evidence.trim(), isNotEmpty, reason: f.id);
      }
    }
  });
}
