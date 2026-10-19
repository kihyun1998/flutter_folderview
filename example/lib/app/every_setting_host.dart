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
    'FolderView.scale' => _slider(
      settingId,
      'Scale',
      demo.scale,
      min: EverySettingDemo.minScale,
      max: EverySettingDemo.maxScale,
      divisions: 50,
      format: (v) => v.toStringAsFixed(2),
      enabled: true,
      indent: false,
      onChanged: (v) => demo.scale = v,
    ),
    'FolderView.onScaleChanged' => buildSwitchTile(
      id: settingId,
      label: 'onScaleChanged handler',
      value: demo.scaleHandlerOn,
      onChanged: (on) => demo.scaleHandlerOn = on,
    ),
    'FolderView.scaleStep' => _slider(
      settingId,
      'Step',
      demo.scaleStep,
      min: 0.01,
      max: 0.25,
      divisions: 24,
      format: (v) => v.toStringAsFixed(2),
      enabled: true,
      indent: false,
      onChanged: (v) => demo.scaleStep = v,
    ),
    'FolderView.blockModifierScroll' => buildDropdownRow<ModifierScrollBlock>(
      id: settingId,
      label: 'Block scroll',
      value: demo.modifierScrollBlock,
      items: ModifierScrollBlock.values,
      itemLabel: (b) => switch (b) {
        ModifierScrollBlock.follow => 'Follow handler',
        ModifierScrollBlock.on => 'On',
        ModifierScrollBlock.off => 'Off',
      },
      onChanged: (b) => demo.modifierScrollBlock = b,
    ),
    'FlutterFolderViewTheme.rowHeight' => _slider(
      settingId,
      'Row height',
      demo.rowHeight,
      min: 20,
      max: 80,
      divisions: 60,
      format: (v) => '${v.round()} px',
      enabled: true,
      indent: false,
      onChanged: (v) => demo.rowHeight = v.roundToDouble(),
    ),
    'FlutterFolderViewTheme.rowSpacing' => _slider(
      settingId,
      'Row spacing',
      demo.rowSpacing,
      min: 0,
      max: 20,
      divisions: 20,
      format: (v) => '${v.round()} px',
      enabled: true,
      indent: false,
      onChanged: (v) => demo.rowSpacing = v.roundToDouble(),
    ),
    'FlutterFolderViewTheme.animationDuration' => _slider(
      settingId,
      'Animation duration',
      demo.animationDuration.toDouble(),
      min: 0,
      max: 1000,
      divisions: 50,
      format: (v) => '${v.round()} ms',
      enabled: true,
      indent: false,
      onChanged: (v) => demo.animationDuration = v.round(),
    ),
    'FlutterFolderViewTheme.spacingTheme' => _codeControl(
      settingId,
      'spacingTheme',
      demo.spacingThemeCode,
    ),
    'FolderViewSpacingTheme.contentPadding' => _paddingControl(settingId),
    'FlutterFolderViewTheme.nodeStyleTheme' => _codeControl(
      settingId,
      'nodeStyleTheme',
      demo.nodeStyleThemeCode,
    ),
    'FolderViewNodeStyleTheme.borderRadius' => _slider(
      settingId,
      'Border radius',
      demo.borderRadius,
      min: 0,
      max: 20,
      divisions: 20,
      format: (v) => '${v.round()} px',
      enabled: true,
      indent: true,
      onChanged: (v) => demo.borderRadius = v.roundToDouble(),
    ),
    'FlutterFolderViewTheme.lineTheme' => _codeControl(
      settingId,
      'lineTheme',
      demo.lineThemeCode,
    ),
    'FolderViewLineTheme.lineStyle' => buildDropdownRow<LineStyle>(
      id: settingId,
      label: 'Style',
      value: demo.lineStyle,
      items: LineStyle.values,
      itemLabel: (s) => s.name,
      onChanged: (s) => demo.lineStyle = s,
      indent: true,
    ),
    'FolderViewLineTheme.lineColor' => _colorControl(settingId),
    'FolderViewLineTheme.lineWidth' => _slider(
      settingId,
      'Width',
      demo.lineWidth,
      min: 0.5,
      max: 5,
      divisions: 9,
      format: (v) => '${v.toStringAsFixed(1)} px',
      enabled: true,
      onChanged: (v) => demo.lineWidth = v,
    ),
    _ => throw ArgumentError.value(settingId, 'settingId'),
  };

  /// `lineColor`: one swatch per colour in `EverySettingDemo.lineColors`.
  SettingsControl _colorControl(String id) => SettingsControl(
    id: id,
    label: 'Color',
    indent: true,
    child: Wrap(
      spacing: 4,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text('Color'),
        for (final (i, c) in EverySettingDemo.lineColors.indexed)
          InkWell(
            key: ValueKey('$id.$i'),
            onTap: () => demo.lineColor = c,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: c,
                border: Border.all(
                  color: c == demo.lineColor
                      ? Colors.black
                      : Colors.grey.shade300,
                  width: c == demo.lineColor ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
      ],
    ),
  );

  /// A theme container, shown as the argument a caller would write.
  SettingsControl _codeControl(String id, String label, String code) =>
      SettingsControl(
        id: id,
        label: label,
        child: SelectableText(
          code,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      );

  /// `contentPadding`: one slider per side, 0 to 40 px.
  SettingsControl _paddingControl(String id) {
    final p = demo.contentPadding;
    Widget side(String name, double value, EdgeInsets Function(double) with_) =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$name: ${value.round()} px'),
            Slider(
              key: ValueKey('$id.$name'),
              value: value,
              min: 0,
              max: 40,
              divisions: 40,
              onChanged: (v) => demo.contentPadding = with_(v.roundToDouble()),
            ),
          ],
        );
    return SettingsControl(
      id: id,
      label: 'Content padding',
      indent: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          side('left', p.left, (v) => p.copyWith(left: v)),
          side('top', p.top, (v) => p.copyWith(top: v)),
          side('right', p.right, (v) => p.copyWith(right: v)),
          side('bottom', p.bottom, (v) => p.copyWith(bottom: v)),
        ],
      ),
    );
  }

  @override
  List<Widget> extrasAfterOptions(String featureId, BuildContext context) {
    if (featureId == 'wheel') return _wheelExtras();
    if (featureId == 'scale') return _scaleExtras();
    if (featureId == 'layout') return _layoutExtras();
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

  /// What the Scale controls do not show on their own.
  List<Widget> _scaleExtras() => [
    const SizedBox(height: 12),
    const Text(
      'Hold Ctrl (Cmd on macOS) and turn the mouse wheel over the tree. The '
      'library proposes scale ± step through onScaleChanged and clamps '
      'nothing; this example applies the value clamped to 0.5–3.0. With the '
      'handler off, nothing changes the Scale but the slider. Follow blocks '
      'the modifier scroll exactly when the handler is on. Off lets the notch '
      'scroll and proposes no Scale; On blocks it even with no handler. '
      'Scrollbars and tooltips keep their size at every Scale (ADR-0001, '
      'ADR-0004). The preview frames shrink the whole stage; choose the Room '
      'to see a Scale at real pixels.',
      key: Key('scale-note'),
      style: TextStyle(fontSize: 12),
    ),
  ];

  /// What the Layout controls do not show on their own.
  List<Widget> _layoutExtras() => const [
    SizedBox(height: 12),
    Text(
      'Each row is rowHeight + rowSpacing tall. Left and right content '
      'padding widen the content and can bring in the horizontal scrollbar; '
      'top and bottom pad the list. borderRadius rounds the hover, splash and '
      'highlight of every row and the selected background of a Child: hover '
      'a row or select a Child to see it. '
      'FlutterFolderViewTheme.animationDuration is read nowhere in the '
      'library: expand and collapse are not animated, so this slider changes '
      'nothing on screen. The Scale multiplies every value here except '
      'animationDuration.',
      key: Key('layout-note'),
      style: TextStyle(fontSize: 12),
    ),
  ];

  /// A slider for a numeric setting, disabled when [enabled] is false; a wheel
  /// knob is [indent]ed under the Motion dropdown.
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
    bool indent = true,
  }) => SettingsControl(
    id: id,
    label: label,
    indent: indent,
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
