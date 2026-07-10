import 'package:example/presets/demo_preset.dart';
import 'package:example/providers/theme_demo_provider.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every switchable feature on.
///
/// `Bare` is asserted against this rather than against the view model's
/// defaults, where five of the ten switches are already off: a `bare` that did
/// nothing at all would satisfy half the assertions below for free.
ThemeDemoViewModel _allSwitchesOn() => ThemeDemoViewModel(
  nodes: const [],
  rowTooltipEnabled: true,
  folderTooltipEnabled: true,
  parentTooltipEnabled: true,
  childTooltipEnabled: true,
  tooltipEnableTap: true,
  tooltipEnableHover: true,
  tooltipInteractive: true,
  tooltipHideOnEmptyMessage: true,
  tooltipBoxShadowEnabled: true,
  tooltipShowArrow: true,
);

void main() {
  // Applying a preset is a pure function over the view model, so it is asserted
  // here rather than by pumping the demo. The expected values come from #61,
  // not from re-reading the implementation.

  group('Bare', () {
    test('turns every switchable feature off', () {
      final bare = DemoPreset.bare.apply(_allSwitchesOn());

      expect(bare.rowTooltipEnabled, isFalse);
      expect(bare.folderTooltipEnabled, isFalse);
      expect(bare.parentTooltipEnabled, isFalse);
      expect(bare.childTooltipEnabled, isFalse);
      expect(bare.tooltipEnableTap, isFalse);
      expect(bare.tooltipEnableHover, isFalse);
      expect(bare.tooltipInteractive, isFalse);
      expect(bare.tooltipHideOnEmptyMessage, isFalse);
      expect(bare.tooltipBoxShadowEnabled, isFalse);
      expect(bare.tooltipShowArrow, isFalse);
    });
  });
}
