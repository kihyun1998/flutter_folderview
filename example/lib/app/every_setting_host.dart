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
      'Expanded Set',
      demo.expandedIds.length,
      {'Expand all': demo.expandAll, 'Collapse all': demo.collapseAll},
    ),
    'FolderView.selectedNodeIds' => _setRow(
      settingId,
      'Selected Set',
      demo.selectedIds.length,
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
    'FolderView.wheelMotion' => buildDropdownRow<WheelMotionKind>(
      id: settingId,
      label: 'Motion',
      value: demo.wheelMotionKind,
      items: WheelMotionKind.values,
      itemLabel: (k) => switch (k) {
        WheelMotionKind.off => 'Off',
        WheelMotionKind.spring => 'Spring',
        WheelMotionKind.curve => 'Curve',
        WheelMotionKind.lerp => 'Lerp',
      },
      onChanged: (k) => demo.wheelMotionKind = k,
    ),
    'wheelDurationMs' => _slider(
      settingId,
      'Duration',
      demo.wheelDurationMs.toDouble(),
      min: 50,
      max: 1000,
      divisions: 475,
      format: (v) => '${v.round()} ms',
      enabled:
          demo.wheelMotionKind == WheelMotionKind.spring ||
          demo.wheelMotionKind == WheelMotionKind.curve,
      onChanged: (v) => demo.wheelDurationMs = v.round(),
    ),
    'wheelBounce' => _slider(
      settingId,
      'Bounce',
      demo.wheelBounce,
      min: -0.5,
      max: 0.8,
      divisions: 26,
      format: (v) => v.toStringAsFixed(2),
      enabled: demo.wheelMotionKind == WheelMotionKind.spring,
      onChanged: (v) => demo.wheelBounce = v,
    ),
    'wheelCurve' => SettingsControl(
      id: settingId,
      label: 'Curve',
      indent: true,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        children: [
          const Text('Curve'),
          DropdownButton<WheelCurveOption>(
            value: demo.wheelCurve,
            items: [
              for (final c in WheelCurveOption.values)
                DropdownMenuItem(value: c, child: Text(c.name)),
            ],
            onChanged: demo.wheelMotionKind == WheelMotionKind.curve
                ? (c) => demo.wheelCurve = c!
                : null,
          ),
        ],
      ),
    ),
    'wheelTimeConstantMs' => _slider(
      settingId,
      'Time constant',
      demo.wheelTimeConstantMs.toDouble(),
      min: 10,
      max: 300,
      divisions: 145,
      format: (v) => '${v.round()} ms',
      enabled: demo.wheelMotionKind == WheelMotionKind.lerp,
      onChanged: (v) => demo.wheelTimeConstantMs = v.round(),
    ),
    _ => throw ArgumentError.value(settingId, 'settingId'),
  };

  @override
  List<Widget> extrasAfterOptions(String featureId, BuildContext context) {
    if (featureId == 'wheel') return _wheelExtras();
    if (featureId != 'interaction') return const [];
    return [
      const SizedBox(height: 12),
      const Text(
        'A second tap on a Child within ChildNodeTheme.clickInterval '
        '(300 ms by default) is a double tap: onNodeTap fires on the first '
        'tap, onDoubleNodeTap on the second. With no onDoubleNodeTap handler '
        'there is no window: every tap fires onNodeTap. Ctrl+tap is always a '
        'single tap. '
        'Folders and Parents get no double tap.',
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

  /// The current `wheelMotion` as code, and what the panel does not set.
  List<Widget> _wheelExtras() => [
    const SizedBox(height: 12),
    SelectableText(
      demo.wheelMotionCode,
      key: const Key('wheel-code'),
      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
    ),
    const SizedBox(height: 12),
    const Text(
      'Turn the mouse wheel over the tree. Only the wheel animates: a '
      'trackpad, a dragged scrollbar, and a wheel turned over a scrollbar '
      'move the view at once. How far one notch travels is app-wide, through '
      'SmoothWheelBinding in flutter_smooth_wheel_scroll, and is not set '
      'here. Choose Generated data with large counts for room to scroll.',
      key: Key('wheel-note'),
      style: TextStyle(fontSize: 12),
    ),
  ];

  /// A slider for a wheel knob, disabled when the chosen motion does not read
  /// it.
  SettingsControl _slider(
    String id,
    String label,
    double value, {
    required double min,
    required double max,
    required int divisions,
    required String Function(double) format,
    required bool enabled,
    required void Function(double) onChanged,
  }) => SettingsControl(
    id: id,
    label: label,
    indent: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${format(value)}'),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: enabled ? onChanged : null,
        ),
      ],
    ),
  );

  /// A caller-owned set's size, and buttons that replace it.
  SettingsControl _setRow(
    String id,
    String label,
    int size,
    Map<String, VoidCallback> actions,
  ) => SettingsControl(
    id: id,
    label: label,
    child: Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        Text('$label: $size'),
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
