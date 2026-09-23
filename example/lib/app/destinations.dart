import 'package:flutter/widgets.dart';
import 'package:flutter_example_template/flutter_example_template.dart';

import '../pages/theme_demo_page.dart';
import 'every_setting.dart';

/// The destinations this example shows in the shell, and the demo state
/// behind them.
class FolderViewDestinations implements ShellDestinations {
  FolderViewDestinations();

  final _everySetting = EverySettingDemo();

  @override
  late final List<ShellDestination> all = [
    StageDestination(
      id: 'every-setting',
      label: 'Every setting',
      category: ShellCategory.pages,
      stage: (context) => EverySettingStage(demo: _everySetting),
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
  void dispose() => _everySetting.dispose();
}
