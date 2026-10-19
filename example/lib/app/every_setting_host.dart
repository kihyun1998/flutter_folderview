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
  List<PresetSummary> get presets => const [
    PresetSummary(
      id: 'light',
      title: 'Light',
      lookFor:
          'Every theme setting is FlutterFolderViewTheme.light()\'s. The '
          "shell's own light/dark button themes the shell, not the tree.",
    ),
    PresetSummary(
      id: 'dark',
      title: 'Dark',
      lookFor:
          'Every theme setting is FlutterFolderViewTheme.dark()\'s: white70 '
          "labels, grey400 icons and thumb. The shell's own light/dark button "
          'themes the shell, not the tree.',
    ),
  ];

  @override
  String? get activePresetId => demo.activePreset?.name;

  @override
  void applyPreset(String presetId) =>
      demo.applyPreset(ThemePreset.values.byName(presetId));

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
    'FolderViewSpacingTheme.contentPadding' => _edgeControl(
      settingId,
      'Content padding',
      demo.contentPadding,
      (p) => demo.contentPadding = p,
    ),
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
    'FolderViewLineTheme.lineColor' => _colorControl(
      settingId,
      'Color',
      demo.lineColor,
      EverySettingDemo.lineColors,
      (c) => demo.lineColor = c!,
    ),
    'FolderView.theme' => buildDropdownRow<ThemeInjection>(
      id: settingId,
      label: 'Inject via',
      value: demo.injection,
      items: ThemeInjection.values,
      itemLabel: (i) => switch (i) {
        ThemeInjection.parameter => 'theme: param',
        ThemeInjection.ancestor => 'Ancestor',
      },
      onChanged: (i) => demo.injection = i,
    ),
    'FolderViewTheme.data' => _codeControl(
      settingId,
      'FolderViewTheme.data',
      demo.injectionCode,
    ),
    'FlutterFolderViewTheme.folderTheme' => _codeControl(
      settingId,
      'folderTheme',
      demo.folderThemeCode,
    ),
    'FolderNodeTheme.widget' => buildSwitchTile(
      id: settingId,
      label: 'Sample widget (outlined folder)',
      value: demo.folderWidgetSample,
      onChanged: (on) => demo.folderWidgetSample = on,
      indent: true,
    ),
    'FolderNodeTheme.openWidget' => buildDropdownRow<FolderOpenWidget>(
      id: settingId,
      label: 'Open widget',
      value: demo.folderOpenWidget,
      items: FolderOpenWidget.values,
      itemLabel: (o) => switch (o) {
        FolderOpenWidget.factory => 'Factory',
        FolderOpenWidget.sample => 'Sample',
        FolderOpenWidget.none => 'None',
      },
      onChanged: (o) => demo.folderOpenWidget = o,
      indent: true,
    ),
    'FolderNodeTheme.widgetResolver' => buildSwitchTile(
      id: settingId,
      label: 'widgetResolver sample',
      value: demo.folderWidgetResolver,
      onChanged: (on) => demo.folderWidgetResolver = on,
      indent: true,
    ),
    'FolderNodeTheme.openWidgetResolver' => buildSwitchTile(
      id: settingId,
      label: 'openWidgetResolver sample',
      value: demo.folderOpenWidgetResolver,
      onChanged: (on) => demo.folderOpenWidgetResolver = on,
      indent: true,
    ),
    'FolderNodeTheme.width' => _pxSlider(
      settingId,
      'Width',
      demo.folderWidth,
      8,
      40,
      (v) => demo.folderWidth = v,
    ),
    'FolderNodeTheme.height' => _pxSlider(
      settingId,
      'Height',
      demo.folderHeight,
      8,
      40,
      (v) => demo.folderHeight = v,
    ),
    'FolderNodeTheme.padding' => _edgeControl(
      settingId,
      'Padding',
      demo.folderPadding,
      (p) => demo.folderPadding = p,
    ),
    'FolderNodeTheme.margin' => _edgeControl(
      settingId,
      'Margin',
      demo.folderMargin,
      (p) => demo.folderMargin = p,
    ),
    'FolderNodeTheme.textStyle' => _colorControl(
      settingId,
      'Text color',
      demo.folderTextColor,
      EverySettingDemo.folderTextColors,
      (c) => demo.folderTextColor = c,
    ),
    'folderFontSize' => buildDropdownRow<double?>(
      id: settingId,
      label: 'Font size',
      value: demo.folderFontSize,
      items: EverySettingDemo.folderFontSizes,
      itemLabel: (s) => s == null ? 'default' : '${s.round()}',
      onChanged: (s) => demo.folderFontSize = s,
      indent: true,
    ),
    'folderBold' => buildSwitchTile(
      id: settingId,
      label: 'Bold',
      value: demo.folderBold,
      onChanged: (on) => demo.folderBold = on,
      indent: true,
    ),
    'FolderNodeTheme.textStyleResolver' => buildSwitchTile(
      id: settingId,
      label: 'textStyleResolver sample',
      value: demo.folderTextStyleResolver,
      onChanged: (on) => demo.folderTextStyleResolver = on,
    ),
    'FolderNodeTheme.labelResolver' => buildSwitchTile(
      id: settingId,
      label: 'labelResolver sample',
      value: demo.folderLabelResolver,
      onChanged: (on) => demo.folderLabelResolver = on,
    ),
    'FolderNodeTheme.hoverColor' => _colorControl(
      settingId,
      'Hover',
      demo.folderHoverColor,
      EverySettingDemo.folderHoverColors,
      (c) => demo.folderHoverColor = c,
    ),
    'FolderNodeTheme.splashColor' => _colorControl(
      settingId,
      'Splash',
      demo.folderSplashColor,
      EverySettingDemo.folderSplashColors,
      (c) => demo.folderSplashColor = c,
    ),
    'FolderNodeTheme.highlightColor' => _colorControl(
      settingId,
      'Highlight',
      demo.folderHighlightColor,
      EverySettingDemo.folderHighlightColors,
      (c) => demo.folderHighlightColor = c,
    ),
    'FlutterFolderViewTheme.parentTheme' => _codeControl(
      settingId,
      'parentTheme',
      demo.parentThemeCode,
    ),
    'ParentNodeTheme.widget' => buildSwitchTile(
      id: settingId,
      label: 'Sample widget (outlined tree)',
      value: demo.parentWidgetSample,
      onChanged: (on) => demo.parentWidgetSample = on,
      indent: true,
    ),
    'ParentNodeTheme.openWidget' => buildDropdownRow<ParentOpenWidget>(
      id: settingId,
      label: 'Open widget',
      value: demo.parentOpenWidget,
      items: ParentOpenWidget.values,
      itemLabel: (o) => switch (o) {
        ParentOpenWidget.factory => 'Factory (none)',
        ParentOpenWidget.sample => 'Sample',
      },
      onChanged: (o) => demo.parentOpenWidget = o,
      indent: true,
    ),
    'ParentNodeTheme.widgetResolver' => buildSwitchTile(
      id: settingId,
      label: 'widgetResolver sample',
      value: demo.parentWidgetResolver,
      onChanged: (on) => demo.parentWidgetResolver = on,
      indent: true,
    ),
    'ParentNodeTheme.openWidgetResolver' => buildSwitchTile(
      id: settingId,
      label: 'openWidgetResolver sample',
      value: demo.parentOpenWidgetResolver,
      onChanged: (on) => demo.parentOpenWidgetResolver = on,
      indent: true,
    ),
    'ParentNodeTheme.width' => _pxSlider(
      settingId,
      'Width',
      demo.parentWidth,
      8,
      40,
      (v) => demo.parentWidth = v,
    ),
    'ParentNodeTheme.height' => _pxSlider(
      settingId,
      'Height',
      demo.parentHeight,
      8,
      40,
      (v) => demo.parentHeight = v,
    ),
    'ParentNodeTheme.padding' => _edgeControl(
      settingId,
      'Padding',
      demo.parentPadding,
      (p) => demo.parentPadding = p,
    ),
    'ParentNodeTheme.margin' => _edgeControl(
      settingId,
      'Margin',
      demo.parentMargin,
      (p) => demo.parentMargin = p,
    ),
    'ParentNodeTheme.textStyle' => _colorControl(
      settingId,
      'Text color',
      demo.parentTextColor,
      EverySettingDemo.parentTextColors,
      (c) => demo.parentTextColor = c,
    ),
    'parentFontSize' => buildDropdownRow<double?>(
      id: settingId,
      label: 'Font size',
      value: demo.parentFontSize,
      items: EverySettingDemo.parentFontSizes,
      itemLabel: (s) => s == null ? 'default' : '${s.round()}',
      onChanged: (s) => demo.parentFontSize = s,
      indent: true,
    ),
    'parentBold' => buildSwitchTile(
      id: settingId,
      label: 'Bold',
      value: demo.parentBold,
      onChanged: (on) => demo.parentBold = on,
      indent: true,
    ),
    'ParentNodeTheme.textStyleResolver' => buildSwitchTile(
      id: settingId,
      label: 'textStyleResolver sample',
      value: demo.parentTextStyleResolver,
      onChanged: (on) => demo.parentTextStyleResolver = on,
    ),
    'ParentNodeTheme.labelResolver' => buildSwitchTile(
      id: settingId,
      label: 'labelResolver sample',
      value: demo.parentLabelResolver,
      onChanged: (on) => demo.parentLabelResolver = on,
    ),
    'ParentNodeTheme.hoverColor' => _colorControl(
      settingId,
      'Hover',
      demo.parentHoverColor,
      EverySettingDemo.parentHoverColors,
      (c) => demo.parentHoverColor = c,
    ),
    'ParentNodeTheme.splashColor' => _colorControl(
      settingId,
      'Splash',
      demo.parentSplashColor,
      EverySettingDemo.parentSplashColors,
      (c) => demo.parentSplashColor = c,
    ),
    'ParentNodeTheme.highlightColor' => _colorControl(
      settingId,
      'Highlight',
      demo.parentHighlightColor,
      EverySettingDemo.parentHighlightColors,
      (c) => demo.parentHighlightColor = c,
    ),
    'FlutterFolderViewTheme.childTheme' => _codeControl(
      settingId,
      'childTheme',
      demo.childThemeCode,
    ),
    'ChildNodeTheme.widget' => buildSwitchTile(
      id: settingId,
      label: 'Sample widget (outlined page)',
      value: demo.childWidgetSample,
      onChanged: (on) => demo.childWidgetSample = on,
      indent: true,
    ),
    'ChildNodeTheme.widgetResolver' => buildSwitchTile(
      id: settingId,
      label: 'widgetResolver sample',
      value: demo.childWidgetResolver,
      onChanged: (on) => demo.childWidgetResolver = on,
      indent: true,
    ),
    'ChildNodeTheme.width' => _pxSlider(
      settingId,
      'Width',
      demo.childWidth,
      8,
      40,
      (v) => demo.childWidth = v,
    ),
    'ChildNodeTheme.height' => _pxSlider(
      settingId,
      'Height',
      demo.childHeight,
      8,
      40,
      (v) => demo.childHeight = v,
    ),
    'ChildNodeTheme.padding' => _edgeControl(
      settingId,
      'Padding',
      demo.childPadding,
      (p) => demo.childPadding = p,
    ),
    'ChildNodeTheme.margin' => _edgeControl(
      settingId,
      'Margin',
      demo.childMargin,
      (p) => demo.childMargin = p,
    ),
    'ChildNodeTheme.textStyle' => _colorControl(
      settingId,
      'Text color',
      demo.childTextColor,
      EverySettingDemo.childTextColors,
      (c) => demo.childTextColor = c,
    ),
    'childFontSize' => buildDropdownRow<double?>(
      id: settingId,
      label: 'Font size',
      value: demo.childFontSize,
      items: EverySettingDemo.childFontSizes,
      itemLabel: (s) => s == null ? 'default' : '${s.round()}',
      onChanged: (s) => demo.childFontSize = s,
      indent: true,
    ),
    'childBold' => buildSwitchTile(
      id: settingId,
      label: 'Bold',
      value: demo.childBold,
      onChanged: (on) => demo.childBold = on,
      indent: true,
    ),
    'ChildNodeTheme.textStyleResolver' => buildSwitchTile(
      id: settingId,
      label: 'textStyleResolver sample',
      value: demo.childTextStyleResolver,
      onChanged: (on) => demo.childTextStyleResolver = on,
    ),
    'ChildNodeTheme.labelResolver' => buildSwitchTile(
      id: settingId,
      label: 'labelResolver sample',
      value: demo.childLabelResolver,
      onChanged: (on) => demo.childLabelResolver = on,
    ),
    'ChildNodeTheme.selectedTextStyle' => _colorControl(
      settingId,
      'Selected text color',
      demo.childSelectedColor,
      EverySettingDemo.childSelectedColors,
      (c) => demo.childSelectedColor = c,
    ),
    'childSelectedBold' => buildSwitchTile(
      id: settingId,
      label: 'Selected bold',
      value: demo.childSelectedBold,
      onChanged: (on) => demo.childSelectedBold = on,
      indent: true,
    ),
    'ChildNodeTheme.selectedTextStyleResolver' => buildSwitchTile(
      id: settingId,
      label: 'selectedTextStyleResolver sample',
      value: demo.childSelectedTextStyleResolver,
      onChanged: (on) => demo.childSelectedTextStyleResolver = on,
    ),
    'ChildNodeTheme.selectedBackgroundColor' => _colorControl(
      settingId,
      'Selected background',
      demo.childSelectedBackground,
      EverySettingDemo.childSelectedBackgrounds,
      (c) => demo.childSelectedBackground = c,
    ),
    'ChildNodeTheme.hoverColor' => _colorControl(
      settingId,
      'Hover',
      demo.childHoverColor,
      EverySettingDemo.childHoverColors,
      (c) => demo.childHoverColor = c,
    ),
    'ChildNodeTheme.splashColor' => _colorControl(
      settingId,
      'Splash',
      demo.childSplashColor,
      EverySettingDemo.childSplashColors,
      (c) => demo.childSplashColor = c,
    ),
    'ChildNodeTheme.highlightColor' => _colorControl(
      settingId,
      'Highlight',
      demo.childHighlightColor,
      EverySettingDemo.childHighlightColors,
      (c) => demo.childHighlightColor = c,
    ),
    'ChildNodeTheme.clickInterval' => _slider(
      settingId,
      'Double-tap window',
      demo.childClickInterval.toDouble(),
      min: 0,
      max: 1000,
      divisions: 20,
      format: (v) => '${v.round()} ms',
      enabled: true,
      indent: false,
      onChanged: (v) => demo.childClickInterval = v.round(),
    ),
    'FlutterFolderViewTheme.scrollbarTheme' => _codeControl(
      settingId,
      'scrollbarTheme',
      demo.scrollbarThemeCode,
    ),
    'FolderViewScrollbarTheme.thumbColor' => _colorControl(
      settingId,
      'Thumb color',
      demo.thumbColor,
      EverySettingDemo.scrollbarThumbColors,
      (c) => demo.thumbColor = c!,
    ),
    'FolderViewScrollbarTheme.thickness' => _pxSlider(
      settingId,
      'Thickness',
      demo.thickness,
      2,
      20,
      (v) => demo.thickness = v,
    ),
    'FolderViewScrollbarTheme.radius' => _pxSlider(
      settingId,
      'Thumb radius',
      demo.thumbRadius,
      0,
      12,
      (v) => demo.thumbRadius = v,
    ),
    'FolderViewScrollbarTheme.thumbVisibility' => buildSwitchTile(
      id: settingId,
      label: 'Thumb always visible',
      value: demo.thumbVisibility,
      onChanged: (on) => demo.thumbVisibility = on,
      indent: true,
    ),
    'FolderViewScrollbarTheme.trackColor' => _colorControl(
      settingId,
      'Track color',
      demo.trackColor,
      EverySettingDemo.scrollbarTrackColors,
      (c) => demo.trackColor = c!,
    ),
    'FolderViewScrollbarTheme.trackWidth' => _pxSlider(
      settingId,
      'Track width',
      demo.trackWidth,
      4,
      32,
      (v) => demo.trackWidth = v,
    ),
    'FolderViewScrollbarTheme.trackRadius' => _pxSlider(
      settingId,
      'Track radius',
      demo.trackRadius,
      0,
      16,
      (v) => demo.trackRadius = v,
    ),
    'FolderViewScrollbarTheme.trackVisibility' => buildSwitchTile(
      id: settingId,
      label: "Material's own track",
      value: demo.trackVisibility,
      onChanged: (on) => demo.trackVisibility = on,
      indent: true,
    ),
    'FolderViewScrollbarTheme.hoverOpacity' => _opacitySlider(
      settingId,
      'Opacity on hover',
      demo.hoverOpacity,
      (v) => demo.hoverOpacity = v,
    ),
    'FolderViewScrollbarTheme.nonHoverOpacity' => _opacitySlider(
      settingId,
      'Opacity otherwise',
      demo.nonHoverOpacity,
      (v) => demo.nonHoverOpacity = v,
    ),
    'FolderViewScrollbarTheme.hoverAnimationDuration' => _slider(
      settingId,
      'Fade duration',
      demo.hoverAnimationMs.toDouble(),
      min: 0,
      max: 1000,
      divisions: 50,
      format: (v) => '${v.round()} ms',
      enabled: true,
      onChanged: (v) => demo.hoverAnimationMs = v.round(),
    ),
    'FlutterFolderViewTheme.expandIconTheme' => _codeControl(
      settingId,
      'expandIconTheme',
      demo.expandIconThemeCode,
    ),
    'ExpandIconTheme.widget' => buildSwitchTile(
      id: settingId,
      label: 'Sample widget (uncoloured arrow)',
      value: demo.expandIconSample,
      onChanged: (on) => demo.expandIconSample = on,
      indent: true,
    ),
    'ExpandIconTheme.width' => _slider(
      settingId,
      'Width',
      demo.expandIconWidth,
      min: 8,
      max: 40,
      divisions: 32,
      format: (v) => '${v.round()} px',
      enabled: true,
      onChanged: (v) => demo.expandIconWidth = v.roundToDouble(),
    ),
    'ExpandIconTheme.height' => _slider(
      settingId,
      'Height',
      demo.expandIconHeight,
      min: 8,
      max: 40,
      divisions: 32,
      format: (v) => '${v.round()} px',
      enabled: true,
      onChanged: (v) => demo.expandIconHeight = v.roundToDouble(),
    ),
    'ExpandIconTheme.padding' => _edgeControl(
      settingId,
      'Padding',
      demo.expandIconPadding,
      (p) => demo.expandIconPadding = p,
    ),
    'ExpandIconTheme.margin' => _edgeControl(
      settingId,
      'Margin',
      demo.expandIconMargin,
      (p) => demo.expandIconMargin = p,
    ),
    'ExpandIconTheme.color' => _colorControl(
      settingId,
      'Color',
      demo.expandIconColor,
      EverySettingDemo.expandIconColors,
      (c) => demo.expandIconColor = c,
    ),
    'ExpandIconTheme.expandedColor' => _colorControl(
      settingId,
      'Expanded color',
      demo.expandIconExpandedColor,
      EverySettingDemo.expandIconColors,
      (c) => demo.expandIconExpandedColor = c,
    ),
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

  /// One swatch per colour in [colors]; a `null` colour is drawn as an empty
  /// box and means "not set".
  SettingsControl _colorControl(
    String id,
    String label,
    Color? value,
    List<Color?> colors,
    void Function(Color?) onChanged,
  ) => SettingsControl(
    id: id,
    label: label,
    indent: true,
    child: Wrap(
      spacing: 4,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(label),
        for (final (i, c) in colors.indexed)
          InkWell(
            key: ValueKey('$id.$i'),
            onTap: () => onChanged(c),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: c ?? Colors.white,
                border: Border.all(
                  color: c == value ? Colors.black : Colors.grey.shade300,
                  width: c == value ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: c == null || c.a == 0
                  ? const Icon(Icons.block, size: 14, color: Colors.grey)
                  : null,
            ),
          ),
      ],
    ),
  );

  /// A whole-pixel slider from [min] to [max].
  SettingsControl _pxSlider(
    String id,
    String label,
    double value,
    double min,
    double max,
    void Function(double) onChanged,
  ) => _slider(
    id,
    label,
    value,
    min: min,
    max: max,
    divisions: (max - min).round(),
    format: (v) => '${v.round()} px',
    enabled: true,
    onChanged: (v) => onChanged(v.roundToDouble()),
  );

  /// An opacity slider from 0 to 1 in steps of 0.05.
  SettingsControl _opacitySlider(
    String id,
    String label,
    double value,
    void Function(double) onChanged,
  ) => _slider(
    id,
    label,
    value,
    min: 0,
    max: 1,
    divisions: 20,
    format: (v) => v.toStringAsFixed(2),
    enabled: true,
    onChanged: (v) => onChanged((v * 20).round() / 20),
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

  /// An `EdgeInsets`: one slider per side, 0 to 40 px.
  SettingsControl _edgeControl(
    String id,
    String label,
    EdgeInsets p,
    void Function(EdgeInsets) onChanged,
  ) {
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
              onChanged: (v) => onChanged(with_(v.roundToDouble())),
            ),
          ],
        );
    return SettingsControl(
      id: id,
      label: label,
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
    if (featureId == 'expandIcon') return _expandIconExtras();
    if (featureId == 'scrollbars') return _scrollbarExtras();
    if (featureId == 'themeInjection') return _themeInjectionExtras();
    if (featureId == 'folderIcons') return _folderIconsExtras();
    if (featureId == 'folderLabel') return _folderLabelExtras();
    if (featureId == 'parentIcons') return _parentIconsExtras();
    if (featureId == 'parentLabel') return _parentLabelExtras();
    if (featureId == 'childSelection') return _childSelectionExtras();
    if (featureId == 'childInk') return _childInkExtras();
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

  /// What the Child selection controls do not show on their own.
  List<Widget> _childSelectionExtras() => const [
    SizedBox(height: 12),
    Text(
      'Select a Child by tapping it (Taps & state decides single or multiple). '
      'selectedTextStyle is merged over the Child\'s own style, so a size or '
      'colour it leaves unset is kept; selectedTextStyleResolver, where it '
      'returns a style, is merged instead of selectedTextStyle. The sample '
      'underlines a selected Child whose label ends in "(Future)". Only '
      'Children take part in Selection (ADR-0003). A background left unset '
      'is not transparent: the row falls back to the colour scheme\'s '
      'primaryContainer.',
      key: Key('child-selection-note'),
      style: TextStyle(fontSize: 12),
    ),
  ];

  /// What the Child ink controls do not show on their own.
  List<Widget> _childInkExtras() => const [
    SizedBox(height: 12),
    Text(
      'The double-tap window is clickInterval: a second tap on a Child '
      'within it fires onDoubleNodeTap. With no onDoubleNodeTap handler there '
      'is no window, and every tap is a single tap (see Taps & state). An ink '
      'colour left unset falls back to the colour scheme: '
      'surfaceContainerHighest for hover, primary at 0.3 for splash and at '
      '0.1 for highlight.',
      key: Key('child-ink-note'),
      style: TextStyle(fontSize: 12),
    ),
  ];

  /// What the Parent icon controls do not show on their own.
  List<Widget> _parentIconsExtras() => const [
    SizedBox(height: 12),
    Text(
      'A Parent shows openWidget only in Tree Mode: in Folder Mode an expanded '
      'Parent keeps its widget. Both factories leave openWidget unset, so '
      'Factory means none, and the widget stays. A resolver wins over the '
      'static widget for the Nodes it returns non-null for: the samples swap '
      'the icon of a Parent that holds two Children. Width plus horizontal '
      'padding and margin is the icon box, which the content width is '
      'measured with.',
      key: Key('parent-icons-note'),
      style: TextStyle(fontSize: 12),
    ),
  ];

  /// What the Parent label controls do not show on their own.
  List<Widget> _parentLabelExtras() => const [
    SizedBox(height: 12),
    Text(
      'textStyleResolver replaces textStyle for the Nodes it returns a style '
      'for; it does not merge with it. The sample restyles a Parent that '
      'holds two Children. labelResolver changes the text drawn and measured: '
      'the sample adds the Child count.',
      key: Key('parent-label-note'),
      style: TextStyle(fontSize: 12),
    ),
  ];

  /// What the Folder icon controls do not show on their own.
  List<Widget> _folderIconsExtras() => const [
    SizedBox(height: 12),
    Text(
      'An expanded Folder shows openWidget; with openWidget None it falls back '
      'to widget. A resolver wins over the static widget for the Nodes it '
      'returns non-null for: the samples swap the icon of a Folder that holds '
      'a single Parent. Width plus horizontal padding and margin is the icon '
      'box, which the content width is measured with. Folders are hidden in '
      'Tree Mode, so nothing here shows there.',
      key: Key('folder-icons-note'),
      style: TextStyle(fontSize: 12),
    ),
  ];

  /// What the Folder label controls do not show on their own.
  List<Widget> _folderLabelExtras() => const [
    SizedBox(height: 12),
    Text(
      'textStyleResolver replaces textStyle for the Nodes it returns a style '
      'for; it does not merge with it. The sample restyles a Folder that holds '
      'a single Parent. labelResolver changes the text drawn and measured, so '
      'a longer label widens the content instead of being cut: the sample '
      'adds the Parent count.',
      key: Key('folder-label-note'),
      style: TextStyle(fontSize: 12),
    ),
  ];

  /// What the Theme injection controls do not show on their own.
  List<Widget> _themeInjectionExtras() => const [
    SizedBox(height: 12),
    Text(
      'Both paths hand the view the same theme instance. FolderView prefers '
      'its theme parameter, so the ancestor is read only while the parameter '
      'is null. The ancestor must name the data type: FolderViewTheme<String> '
      'for a FolderView<String>. An untyped FolderViewTheme(data: '
      'FlutterFolderViewTheme.dark()) is a FolderViewTheme<dynamic>, which '
      'the view does not find, and it falls back to light() without a word. '
      'The presets above reset every theme setting to light() or dark().',
      key: Key('theme-injection-note'),
      style: TextStyle(fontSize: 12),
    ),
  ];

  /// What the Scrollbar controls do not show on their own.
  List<Widget> _scrollbarExtras() => const [
    SizedBox(height: 12),
    Text(
      'The bars fade to "Opacity on hover" while the pointer is over the '
      'tree and to "Opacity otherwise" when it leaves; at the default 0 they '
      'are hidden until you hover. The horizontal bar appears only when the '
      'content is wider than the view. There are two tracks: trackColor, '
      'trackWidth and trackRadius style the box the bar sits in, while '
      "trackVisibility turns on Material's own track inside it, drawn in "
      "Material's colour, not trackColor. A thickness above trackWidth paints "
      'the thumb past the box, over the rows. Scrollbars keep their size at '
      'every Scale (ADR-0001).',
      key: Key('scrollbar-note'),
      style: TextStyle(fontSize: 12),
    ),
  ];

  /// What the Expand icon controls do not show on their own.
  List<Widget> _expandIconExtras() => const [
    SizedBox(height: 12),
    Text(
      'Width plus horizontal padding and margin is the indent unit: every '
      'level of the tree, and every tree-line column, is that wide. Width and '
      'height size the icon box: at Scale 1 the icon keeps its own size '
      'inside it, at any other Scale it is fitted to the box. The icon turns '
      '90° when its row is expanded. '
      'color and expandedColor reach the icon through IconTheme, so they '
      "have no effect on the factory's chevron (light()'s or dark()'s), which "
      'sets its own grey. Turn on '
      'the sample widget to see them: expanded rows take expandedColor, or '
      'color when it is not set.',
      key: Key('expand-icon-note'),
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
