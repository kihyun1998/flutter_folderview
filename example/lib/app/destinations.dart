import 'package:flutter/widgets.dart';
import 'package:flutter_example_template/flutter_example_template.dart';

import '../pages/theme_demo_page.dart';
import '../recipes/building_a_tree_recipe.dart';
import '../scenarios/large_tree_scenario.dart';
import 'every_setting.dart';

/// The destinations this example shows in the shell, and the demo state
/// behind them.
class FolderViewDestinations implements ShellDestinations {
  FolderViewDestinations();

  final _everySetting = EverySettingDemo();
  LargeTreeDemo? _largeTreeDemo;
  LargeTreeDemo get _largeTree => _largeTreeDemo ??= LargeTreeDemo();

  @override
  late final List<ShellDestination> all = [
    StageDestination(
      id: 'every-setting',
      label: 'Every setting',
      category: ShellCategory.pages,
      stage: (context) => EverySettingStage(demo: _everySetting),
      knobs: (context) => EverySettingKnobs(demo: _everySetting),
    ),
    StageDestination(
      id: 'recipe/building-a-tree',
      label: 'Building a tree',
      category: ShellCategory.recipes,
      source: 'lib/recipes/building_a_tree_recipe.dart',
      stage: (context) => const BuildingATreeRecipe(),
      knobs: (context) => const SizedBox.shrink(),
    ),
    StageDestination(
      id: 'scenario/large-tree',
      label: 'A hundred thousand children',
      category: ShellCategory.scenarios,
      stage: (context) => LargeTreeStage(demo: _largeTree),
      knobs: (context) => const SizedBox.shrink(),
    ),
    RouteDestination(
      id: 'legacy-panel',
      label: 'Legacy panel',
      category: ShellCategory.pages,
      open: (context) => const ThemeDemoPage(),
    ),
  ];

  @override
  void dispose() {
    _everySetting.dispose();
    _largeTreeDemo?.dispose();
  }
}
