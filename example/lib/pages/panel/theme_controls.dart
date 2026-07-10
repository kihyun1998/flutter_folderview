import 'package:flutter/material.dart';

import '../../providers/theme_demo_provider.dart';
import 'sections/data_generator_section.dart';
import 'sections/misc_sections.dart';
import 'sections/tier_sections.dart';
import 'sections/tooltip_section.dart';

/// The demo's left-hand control panel: a 350px column beside the tree.
///
/// Most of it is one collapsible card per section, each defined in `sections/`.
/// Data Generator and View Mode are not collapsible — they are plain cards, so
/// they are always on screen.
///
/// Section order is deliberate — Data Generator first, because a reader wants
/// a tree to look at before they start styling it.
class ThemeControls extends StatelessWidget {
  final ThemeDemoViewModel vm;
  final ThemeDemoState notifier;

  const ThemeControls({super.key, required this.vm, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        buildDataGenerator(context, vm, notifier),
        buildViewMode(context, vm, notifier),
        buildLineControls(context, vm, notifier),
        buildExpandIconControls(context, vm, notifier),
        buildFolderControls(context, vm, notifier),
        buildParentControls(context, vm, notifier),
        buildChildControls(context, vm, notifier),
        buildTooltipControls(context, vm, notifier),
        buildNodeStyleControls(context, vm, notifier),
        buildLayoutControls(context, vm, notifier),
        buildInteractionControls(context, vm, notifier),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: notifier.reset,
          icon: const Icon(Icons.refresh),
          label: const Text('Reset Theme'),
        ),
      ],
    );
  }
}
