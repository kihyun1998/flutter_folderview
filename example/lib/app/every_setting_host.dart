import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_folderview/flutter_folderview.dart';

import 'every_setting.dart';
import 'settings_spec.dart';

/// The shell's settings panel over [EverySettingDemo].
class EverySettingHost extends SettingsHost {
  EverySettingHost(this.demo);

  final EverySettingDemo demo;

  @override
  List<SettingGroup> get spec => settingsSpec;

  @override
  bool isOn(String switchId) => throw ArgumentError.value(switchId, 'switchId');

  @override
  void setSwitch(String switchId, bool on) =>
      throw ArgumentError.value(switchId, 'switchId');

  @override
  SettingsControl control(String settingId) => switch (settingId) {
    'FolderView.data' => buildDropdownRow<DataSource>(
      id: settingId,
      label: 'Data',
      value: demo.dataSource,
      items: DataSource.values,
      itemLabel: (s) => switch (s) {
        DataSource.demo => 'Demo',
        DataSource.generated => 'Generated',
      },
      onChanged: (s) => demo.dataSource = s,
    ),
    'folderCount' => _count(settingId, 'Folders', demo.folderCount, (v) {
      demo.folderCount = v;
    }),
    'parentsPerFolder' => _count(
      settingId,
      'Parents per folder',
      demo.parentsPerFolder,
      (v) => demo.parentsPerFolder = v,
    ),
    'childrenPerParent' => _count(
      settingId,
      'Children per parent',
      demo.childrenPerParent,
      (v) => demo.childrenPerParent = v,
    ),
    'FolderView.mode' => buildDropdownRow<ViewMode>(
      id: settingId,
      label: 'View Mode',
      value: demo.mode,
      items: ViewMode.values,
      itemLabel: (m) => m.name,
      onChanged: (m) => demo.mode = m,
    ),
    'FolderView.onNodeTap' => buildSwitchTile(
      id: settingId,
      label: 'onNodeTap handler',
      value: demo.tapHandlerOn,
      onChanged: (on) => demo.tapHandlerOn = on,
    ),
    'FolderView.onDoubleNodeTap' => buildSwitchTile(
      id: settingId,
      label: 'onDoubleNodeTap handler',
      value: demo.doubleTapHandlerOn,
      onChanged: (on) => demo.doubleTapHandlerOn = on,
    ),
    'FolderView.onSecondaryNodeTap' => buildSwitchTile(
      id: settingId,
      label: 'onSecondaryNodeTap handler',
      value: demo.secondaryTapHandlerOn,
      onChanged: (on) => demo.secondaryTapHandlerOn = on,
    ),
    'FolderView.expandedNodeIds' => _setRow(
      settingId,
      'Expanded Set: ${demo.expandedIds.length}',
      {'Expand all': demo.expandAll, 'Collapse all': demo.collapseAll},
    ),
    'FolderView.selectedNodeIds' => _setRow(
      settingId,
      'Selected Set: ${demo.selectedIds.length}',
      {'Clear': demo.clearSelection},
    ),
    'selectionMode' => buildDropdownRow<SelectionMode>(
      id: settingId,
      label: 'Selection',
      value: demo.selectionMode,
      items: SelectionMode.values,
      itemLabel: (m) => m.name,
      onChanged: (m) => demo.selectionMode = m,
    ),
    _ => throw ArgumentError.value(settingId, 'settingId'),
  };

  @override
  List<Widget> extrasAfterOptions(String featureId, BuildContext context) {
    if (featureId != 'interaction') return const [];
    return [
      const SizedBox(height: 12),
      const Text(
        'A second tap on a Child within ChildNodeTheme.clickInterval '
        '(300 ms by default) is a double tap: onNodeTap fires on the first '
        'tap, onDoubleNodeTap on the second. Folders and Parents get no '
        'double tap.',
        key: Key('double-tap-note'),
        style: TextStyle(fontSize: 12),
      ),
      const SizedBox(height: 12),
      const Text('Event log', style: TextStyle(fontWeight: FontWeight.w600)),
      Column(
        key: const Key('interaction-log'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in demo.log)
            Text(entry, style: const TextStyle(fontSize: 12)),
        ],
      ),
    ];
  }

  /// A caller-owned set's size, and buttons that replace it.
  SettingsControl _setRow(
    String id,
    String label,
    Map<String, VoidCallback> actions,
  ) => SettingsControl(
    id: id,
    label: label,
    child: Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        Text(label),
        for (final MapEntry(:key, :value) in actions.entries)
          TextButton(onPressed: value, child: Text(key)),
      ],
    ),
  );

  /// An integer slider from 1 to 50 in steps of one, disabled unless the data
  /// is generated.
  SettingsControl _count(
    String id,
    String label,
    int value,
    void Function(int) onChanged,
  ) {
    final enabled = demo.dataSource == DataSource.generated;
    return SettingsControl(
      id: id,
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(enabled ? '$label: $value' : '$label: $value (Generated only)'),
          Slider(
            value: value.toDouble(),
            min: 1,
            max: 50,
            divisions: 49,
            onChanged: enabled ? (v) => onChanged(v.round()) : null,
          ),
        ],
      ),
    );
  }
}
