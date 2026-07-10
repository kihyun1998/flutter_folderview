/// Named combinations of the demo's settings, applied in one click.
library;

import '../providers/theme_demo_provider.dart';

/// A named set of settings, applied to the demo in one click.
///
/// Applying a preset is a pure function of the view model, so what a preset
/// does is asserted without pumping a widget.
class DemoPreset {
  const DemoPreset({required this.title, required this.apply});

  final String title;

  /// Returns the view model this preset describes, given the current one.
  final ThemeDemoViewModel Function(ThemeDemoViewModel) apply;

  /// Every switchable feature off.
  ///
  /// The switches are turned off mechanically rather than selectively: with no
  /// tooltip rendering at all, the six that merely modify a tooltip are
  /// unreachable, and a symmetric `Bare`/`Everything` pair is easier to reason
  /// about than a clever one. The generated tree is left alone — the node count
  /// is not what makes a demo bare.
  static final DemoPreset bare = DemoPreset(
    title: 'Bare',
    apply: (vm) => vm.copyWith(
      rowTooltipEnabled: false,
      folderTooltipEnabled: false,
      parentTooltipEnabled: false,
      childTooltipEnabled: false,
      tooltipEnableTap: false,
      tooltipEnableHover: false,
      tooltipInteractive: false,
      tooltipHideOnEmptyMessage: false,
      tooltipBoxShadowEnabled: false,
      tooltipShowArrow: false,
    ),
  );

  /// Every switchable feature on. The mirror of [bare]: the whole surface at
  /// once, for when that is what you want to see.
  static final DemoPreset everything = DemoPreset(
    title: 'Everything',
    apply: (vm) => vm.copyWith(
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
    ),
  );
}
