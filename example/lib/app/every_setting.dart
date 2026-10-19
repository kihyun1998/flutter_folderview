import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_folderview/flutter_folderview.dart';

import '../data/theme_demo_data.dart';
import 'every_setting_host.dart';
import 'tree_generator.dart';

/// Where the "Every setting" stage takes its nodes from.
enum DataSource { demo, generated }

/// The "Every setting" destination's state: the settings the panel edits, the
/// nodes they produce, and the caller-owned Expanded Set and Selected Set.
class EverySettingDemo extends ChangeNotifier {
  EverySettingDemo() {
    _rebuildNodes();
  }

  static const _demoExpandedIds = {'1', '1-1', '2', '2-1', '2-2', '3'};

  String? _openFeatureId;

  /// The feature open in the knob region.
  String? get openFeatureId => _openFeatureId;
  set openFeatureId(String? value) {
    if (value == _openFeatureId) return;
    _openFeatureId = value;
    notifyListeners();
  }

  DataSource _dataSource = DataSource.demo;
  DataSource get dataSource => _dataSource;

  int _folderCount = 5;
  int get folderCount => _folderCount;

  int _parentsPerFolder = 3;
  int get parentsPerFolder => _parentsPerFolder;

  int _childrenPerParent = 5;
  int get childrenPerParent => _childrenPerParent;

  ViewMode _mode = ViewMode.folder;
  ViewMode get mode => _mode;

  late List<Node<String>> _nodes;
  List<Node<String>> get nodes => _nodes;

  Set<String> _expandedIds = {};
  Set<String> get expandedIds => _expandedIds;

  Set<String> _selectedIds = {};
  Set<String> get selectedIds => _selectedIds;

  SelectionMode _selectionMode = SelectionMode.single;
  SelectionMode get selectionMode => _selectionMode;

  bool _tapHandlerOn = true;
  bool get tapHandlerOn => _tapHandlerOn;

  bool _doubleTapHandlerOn = true;
  bool get doubleTapHandlerOn => _doubleTapHandlerOn;

  bool _secondaryTapHandlerOn = true;
  bool get secondaryTapHandlerOn => _secondaryTapHandlerOn;

  WheelMotionKind _wheelMotionKind = WheelMotionKind.spring;
  WheelMotionKind get wheelMotionKind => _wheelMotionKind;

  // The defaults are the library's own, so the stage opens on what a
  // FolderView with no `wheelMotion` does.
  int _wheelDurationMs = 400;
  int get wheelDurationMs => _wheelDurationMs;

  double _wheelBounce = 0;
  double get wheelBounce => _wheelBounce;

  WheelCurveOption _wheelCurve = WheelCurveOption.easeOutCubic;
  WheelCurveOption get wheelCurve => _wheelCurve;

  int _wheelTimeConstantMs = 60;
  int get wheelTimeConstantMs => _wheelTimeConstantMs;

  /// The `FolderView.wheelMotion` the settings describe.
  WheelMotion? get wheelMotion => switch (_wheelMotionKind) {
    WheelMotionKind.off => null,
    WheelMotionKind.spring => WheelMotion.spring(
      duration: Duration(milliseconds: _wheelDurationMs),
      bounce: _wheelBounce,
    ),
    WheelMotionKind.curve => WheelMotion.curve(
      duration: Duration(milliseconds: _wheelDurationMs),
      curve: _wheelCurve.curve,
    ),
    WheelMotionKind.lerp => WheelMotion.lerp(
      timeConstant: Duration(milliseconds: _wheelTimeConstantMs),
    ),
  };

  /// [wheelMotion] as the argument a caller would write.
  String get wheelMotionCode => switch (_wheelMotionKind) {
    WheelMotionKind.off => 'wheelMotion: null,',
    WheelMotionKind.spring =>
      'wheelMotion: const WheelMotion.spring(\n'
          '  duration: Duration(milliseconds: $_wheelDurationMs),\n'
          '  bounce: ${_wheelBounce.toStringAsFixed(2)},\n'
          '),',
    WheelMotionKind.curve =>
      'wheelMotion: const WheelMotion.curve(\n'
          '  duration: Duration(milliseconds: $_wheelDurationMs),\n'
          '  curve: Curves.${_wheelCurve.name},\n'
          '),',
    WheelMotionKind.lerp =>
      'wheelMotion: const WheelMotion.lerp(\n'
          '  timeConstant: Duration(milliseconds: $_wheelTimeConstantMs),\n'
          '),',
  };

  /// The range the example's `onScaleChanged` handler clamps a proposed Scale
  /// to; the library proposes without clamping.
  static const minScale = 0.5;
  static const maxScale = 3.0;

  double _scale = 1.0;
  double get scale => _scale;

  bool _scaleHandlerOn = true;
  bool get scaleHandlerOn => _scaleHandlerOn;

  double _scaleStep = 0.05;
  double get scaleStep => _scaleStep;

  ModifierScrollBlock _modifierScrollBlock = ModifierScrollBlock.follow;
  ModifierScrollBlock get modifierScrollBlock => _modifierScrollBlock;

  /// The `FolderView.blockModifierScroll` the settings describe.
  bool? get blockModifierScroll => switch (_modifierScrollBlock) {
    ModifierScrollBlock.follow => null,
    ModifierScrollBlock.on => true,
    ModifierScrollBlock.off => false,
  };

  // The defaults are `FlutterFolderViewTheme.light()`'s, the theme a
  // FolderView with no `theme` falls back to.
  double _rowHeight = 40;
  double get rowHeight => _rowHeight;

  double _rowSpacing = 0;
  double get rowSpacing => _rowSpacing;

  int _animationDuration = 200;
  int get animationDuration => _animationDuration;

  EdgeInsets _contentPadding = EdgeInsets.zero;
  EdgeInsets get contentPadding => _contentPadding;

  double _borderRadius = 8;
  double get borderRadius => _borderRadius;

  /// The colours the `lineColor` control offers; the first two are `light()`'s
  /// and `dark()`'s.
  static const lineColors = [
    Color(0xFF9E9E9E),
    Color(0xFF757575),
    Color(0xFF2196F3),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFFF44336),
    Color(0xFF9C27B0),
    Color(0xDD000000),
  ];

  Color _lineColor = lineColors.first;
  Color get lineColor => _lineColor;

  double _lineWidth = 1.5;
  double get lineWidth => _lineWidth;

  LineStyle _lineStyle = LineStyle.connector;
  LineStyle get lineStyle => _lineStyle;

  /// The colours the expand icon's `color` and `expandedColor` controls offer;
  /// `null` is `light()`'s.
  static const expandIconColors = <Color?>[
    null,
    Color(0xFFF44336),
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFF9800),
  ];

  /// The sample `ExpandIconTheme.widget`: an icon with no colour of its own,
  /// so `color` and `expandedColor` reach it.
  static const sampleExpandIcon = Icon(Icons.arrow_right, size: 20);

  bool _expandIconSample = false;
  bool get expandIconSample => _expandIconSample;

  double _expandIconWidth = 20;
  double get expandIconWidth => _expandIconWidth;

  double _expandIconHeight = 20;
  double get expandIconHeight => _expandIconHeight;

  EdgeInsets _expandIconPadding = EdgeInsets.zero;
  EdgeInsets get expandIconPadding => _expandIconPadding;

  EdgeInsets _expandIconMargin = EdgeInsets.zero;
  EdgeInsets get expandIconMargin => _expandIconMargin;

  Color? _expandIconColor;
  Color? get expandIconColor => _expandIconColor;

  Color? _expandIconExpandedColor;
  Color? get expandIconExpandedColor => _expandIconExpandedColor;

  /// The colours the scrollbar's thumb and track controls offer; the first two
  /// of each are `light()`'s and `dark()`'s.
  static const scrollbarThumbColors = [
    Color(0xFF757575),
    Color(0xFFBDBDBD),
    Color(0xFF2196F3),
    Color(0xFF4CAF50),
    Color(0xFFF44336),
    Color(0xFF212121),
  ];
  static const scrollbarTrackColors = [
    Color(0xFFEEEEEE),
    Color(0xFF424242),
    Color(0xFFE3F2FD),
    Color(0xFFFFF3E0),
    Color(0x00000000),
  ];

  // The defaults are `FlutterFolderViewTheme.light().scrollbarTheme`'s.
  Color _thumbColor = scrollbarThumbColors.first;
  Color get thumbColor => _thumbColor;

  Color _trackColor = scrollbarTrackColors.first;
  Color get trackColor => _trackColor;

  double _thickness = 12;
  double get thickness => _thickness;

  double _thumbRadius = 4;
  double get thumbRadius => _thumbRadius;

  bool _thumbVisibility = true;
  bool get thumbVisibility => _thumbVisibility;

  double _hoverOpacity = 0.8;
  double get hoverOpacity => _hoverOpacity;

  double _nonHoverOpacity = 0;
  double get nonHoverOpacity => _nonHoverOpacity;

  int _hoverAnimationMs = 200;
  int get hoverAnimationMs => _hoverAnimationMs;

  double _trackWidth = 16;
  double get trackWidth => _trackWidth;

  double _trackRadius = 8;
  double get trackRadius => _trackRadius;

  bool _trackVisibility = false;
  bool get trackVisibility => _trackVisibility;

  /// The samples the Folder icon controls install. They have no colour of
  /// their own, so the ambient icon colour reaches them.
  static const sampleFolderIcon = Icon(Icons.folder_outlined, size: 20);
  static const sampleFolderOpenIcon = Icon(
    Icons.folder_open_outlined,
    size: 20,
  );

  /// What the Folder resolver samples return for a Folder that holds a single
  /// Parent; every other Folder gets `null`, so the static field applies.
  static const sampleSingleParentIcon = Icon(Icons.folder_special, size: 20);
  static const sampleSingleParentOpenIcon = Icon(
    Icons.snippet_folder,
    size: 20,
  );
  static const sampleFolderStyle = TextStyle(
    color: Color(0xFF00897B),
    fontWeight: FontWeight.bold,
  );

  /// The colours the Folder label and ink controls offer; the first two are
  /// `light()`'s and `dark()`'s.
  static const folderTextColors = <Color?>[
    Color(0xDD000000),
    Color(0xB3FFFFFF),
    Color(0xFFD32F2F),
    Color(0xFF1976D2),
  ];
  static const folderHoverColors = <Color?>[
    Color(0xFFEEEEEE),
    Color(0xFF424242),
    Color(0xFFFFECB3),
    null,
  ];
  static final folderSplashColors = <Color?>[
    Colors.blue.withValues(alpha: 0.3),
    Colors.red.withValues(alpha: 0.3),
    Colors.green.withValues(alpha: 0.3),
    null,
  ];
  static final folderHighlightColors = <Color?>[
    Colors.blue.withValues(alpha: 0.1),
    Colors.red.withValues(alpha: 0.1),
    Colors.green.withValues(alpha: 0.1),
    null,
  ];

  /// The font sizes the Folder label offers; `null` is the ambient size.
  static const folderFontSizes = <double?>[null, 12, 14, 16, 18, 20];

  static Widget? _singleParentIcon(Node<String> node) =>
      node.children.length == 1 ? sampleSingleParentIcon : null;
  static Widget? _singleParentOpenIcon(Node<String> node) =>
      node.children.length == 1 ? sampleSingleParentOpenIcon : null;
  static TextStyle? _singleParentStyle(Node<String> node) =>
      node.children.length == 1 ? sampleFolderStyle : null;
  static String? _parentCountLabel(Node<String> node) =>
      '${node.label} (${node.children.length})';

  // The defaults are `FlutterFolderViewTheme.light().folderTheme`'s.
  bool _folderWidgetSample = false;
  bool get folderWidgetSample => _folderWidgetSample;

  FolderOpenWidget _folderOpenWidget = FolderOpenWidget.factory;
  FolderOpenWidget get folderOpenWidget => _folderOpenWidget;

  bool _folderWidgetResolver = false;
  bool get folderWidgetResolver => _folderWidgetResolver;

  bool _folderOpenWidgetResolver = false;
  bool get folderOpenWidgetResolver => _folderOpenWidgetResolver;

  double _folderWidth = 20;
  double get folderWidth => _folderWidth;

  double _folderHeight = 20;
  double get folderHeight => _folderHeight;

  EdgeInsets _folderPadding = EdgeInsets.zero;
  EdgeInsets get folderPadding => _folderPadding;

  EdgeInsets _folderMargin = EdgeInsets.zero;
  EdgeInsets get folderMargin => _folderMargin;

  Color? _folderTextColor = folderTextColors.first;
  Color? get folderTextColor => _folderTextColor;

  double? _folderFontSize;
  double? get folderFontSize => _folderFontSize;

  bool _folderBold = false;
  bool get folderBold => _folderBold;

  bool _folderTextStyleResolver = false;
  bool get folderTextStyleResolver => _folderTextStyleResolver;

  bool _folderLabelResolver = false;
  bool get folderLabelResolver => _folderLabelResolver;

  Color? _folderHoverColor = folderHoverColors.first;
  Color? get folderHoverColor => _folderHoverColor;

  Color? _folderSplashColor = folderSplashColors.first;
  Color? get folderSplashColor => _folderSplashColor;

  Color? _folderHighlightColor = folderHighlightColors.first;
  Color? get folderHighlightColor => _folderHighlightColor;

  TextStyle get _folderTextStyle => TextStyle(
    color: _folderTextColor,
    fontSize: _folderFontSize,
    fontWeight: _folderBold ? FontWeight.bold : null,
  );

  FlutterFolderViewTheme<String>? _theme;

  /// The `FolderView.theme` the settings describe: one instance until a theme
  /// setting changes.
  FlutterFolderViewTheme<String> get theme => _theme ??= _buildTheme();

  ThemePreset _base = ThemePreset.light;

  /// The factory the theme starts from: the last preset applied.
  ThemePreset get base => _base;

  /// The preset the theme settings still match, or null once a theme setting
  /// has moved away from it.
  ThemePreset? get activePreset => _matches(_base.theme) ? _base : null;

  ThemeInjection _injection = ThemeInjection.parameter;
  ThemeInjection get injection => _injection;
  set injection(ThemeInjection value) => _set(() => _injection = value);

  /// Resets every theme setting to [preset]'s factory, and starts from it.
  void applyPreset(ThemePreset preset) {
    final f = preset.theme;
    _base = preset;
    _rowHeight = f.rowHeight;
    _rowSpacing = f.rowSpacing;
    _animationDuration = f.animationDuration;
    _contentPadding = f.spacingTheme.contentPadding;
    _borderRadius = f.nodeStyleTheme.borderRadius;
    _lineColor = f.lineTheme.lineColor;
    _lineWidth = f.lineTheme.lineWidth;
    _lineStyle = f.lineTheme.lineStyle;
    final e = f.expandIconTheme;
    _expandIconSample = false;
    _expandIconWidth = e.width;
    _expandIconHeight = e.height;
    _expandIconPadding = e.padding;
    _expandIconMargin = e.margin;
    _expandIconColor = e.color;
    _expandIconExpandedColor = e.expandedColor;
    final b = f.scrollbarTheme;
    _thumbColor = b.thumbColor;
    _trackColor = b.trackColor;
    _thickness = b.thickness;
    _thumbRadius = b.radius;
    _thumbVisibility = b.thumbVisibility;
    _hoverOpacity = b.hoverOpacity;
    _nonHoverOpacity = b.nonHoverOpacity;
    _hoverAnimationMs = b.hoverAnimationDuration.inMilliseconds;
    _trackWidth = b.trackWidth;
    _trackRadius = b.trackRadius;
    _trackVisibility = b.trackVisibility;
    final d = f.folderTheme;
    _folderWidgetSample = false;
    _folderOpenWidget = FolderOpenWidget.factory;
    _folderWidgetResolver = false;
    _folderOpenWidgetResolver = false;
    _folderWidth = d.width;
    _folderHeight = d.height;
    _folderPadding = d.padding;
    _folderMargin = d.margin;
    _folderTextColor = d.textStyle?.color;
    _folderFontSize = d.textStyle?.fontSize;
    _folderBold = d.textStyle?.fontWeight == FontWeight.bold;
    _folderTextStyleResolver = false;
    _folderLabelResolver = false;
    _folderHoverColor = d.hoverColor;
    _folderSplashColor = d.splashColor;
    _folderHighlightColor = d.highlightColor;
    _theme = null;
    notifyListeners();
  }

  bool _matches(FlutterFolderViewTheme<String> f) {
    final e = f.expandIconTheme;
    final b = f.scrollbarTheme;
    return _rowHeight == f.rowHeight &&
        _rowSpacing == f.rowSpacing &&
        _animationDuration == f.animationDuration &&
        _contentPadding == f.spacingTheme.contentPadding &&
        _borderRadius == f.nodeStyleTheme.borderRadius &&
        _lineColor == f.lineTheme.lineColor &&
        _lineWidth == f.lineTheme.lineWidth &&
        _lineStyle == f.lineTheme.lineStyle &&
        !_expandIconSample &&
        _expandIconWidth == e.width &&
        _expandIconHeight == e.height &&
        _expandIconPadding == e.padding &&
        _expandIconMargin == e.margin &&
        _expandIconColor == e.color &&
        _expandIconExpandedColor == e.expandedColor &&
        _thumbColor == b.thumbColor &&
        _trackColor == b.trackColor &&
        _thickness == b.thickness &&
        _thumbRadius == b.radius &&
        _thumbVisibility == b.thumbVisibility &&
        _hoverOpacity == b.hoverOpacity &&
        _nonHoverOpacity == b.nonHoverOpacity &&
        _hoverAnimationMs == b.hoverAnimationDuration.inMilliseconds &&
        _trackWidth == b.trackWidth &&
        _trackRadius == b.trackRadius &&
        _trackVisibility == b.trackVisibility &&
        _folderMatches(f.folderTheme);
  }

  bool _folderMatches(FolderNodeTheme<String> d) =>
      !_folderWidgetSample &&
      _folderOpenWidget == FolderOpenWidget.factory &&
      !_folderWidgetResolver &&
      !_folderOpenWidgetResolver &&
      _folderWidth == d.width &&
      _folderHeight == d.height &&
      _folderPadding == d.padding &&
      _folderMargin == d.margin &&
      _folderTextColor == d.textStyle?.color &&
      _folderFontSize == d.textStyle?.fontSize &&
      _folderBold == (d.textStyle?.fontWeight == FontWeight.bold) &&
      !_folderTextStyleResolver &&
      !_folderLabelResolver &&
      _folderHoverColor == d.hoverColor &&
      _folderSplashColor == d.splashColor &&
      _folderHighlightColor == d.highlightColor;

  /// `FolderViewTheme.data`'s path, as the code a caller would write.
  String get injectionCode => switch (_injection) {
    ThemeInjection.parameter =>
      'FolderView<String>(\n'
          '  theme: theme,\n'
          '  // data, mode, …\n'
          ')',
    ThemeInjection.ancestor =>
      'FolderViewTheme<String>(\n'
          '  data: theme,\n'
          '  child: FolderView<String>(\n'
          '    // data, mode, …\n'
          '  ),\n'
          ')',
  };

  FlutterFolderViewTheme<String> _buildTheme() {
    final base = _base.theme;
    return base.copyWith(
      expandIconTheme: ExpandIconTheme(
        widget: _expandIconSample
            ? sampleExpandIcon
            : base.expandIconTheme.widget,
        width: _expandIconWidth,
        height: _expandIconHeight,
        padding: _expandIconPadding,
        margin: _expandIconMargin,
        color: _expandIconColor,
        expandedColor: _expandIconExpandedColor,
      ),
      folderTheme: FolderNodeTheme<String>(
        widget: _folderWidgetSample
            ? sampleFolderIcon
            : base.folderTheme.widget,
        widgetResolver: _folderWidgetResolver ? _singleParentIcon : null,
        openWidget: switch (_folderOpenWidget) {
          FolderOpenWidget.factory => base.folderTheme.openWidget,
          FolderOpenWidget.sample => sampleFolderOpenIcon,
          FolderOpenWidget.none => null,
        },
        openWidgetResolver: _folderOpenWidgetResolver
            ? _singleParentOpenIcon
            : null,
        width: _folderWidth,
        height: _folderHeight,
        padding: _folderPadding,
        margin: _folderMargin,
        textStyle: _folderTextStyle,
        textStyleResolver: _folderTextStyleResolver ? _singleParentStyle : null,
        labelResolver: _folderLabelResolver ? _parentCountLabel : null,
        hoverColor: _folderHoverColor,
        splashColor: _folderSplashColor,
        highlightColor: _folderHighlightColor,
        tooltipTheme: base.folderTheme.tooltipTheme,
      ),
      rowHeight: _rowHeight,
      rowSpacing: _rowSpacing,
      animationDuration: _animationDuration,
      spacingTheme: FolderViewSpacingTheme(contentPadding: _contentPadding),
      nodeStyleTheme: FolderViewNodeStyleTheme(borderRadius: _borderRadius),
      lineTheme: FolderViewLineTheme(
        lineColor: _lineColor,
        lineWidth: _lineWidth,
        lineStyle: _lineStyle,
      ),
      scrollbarTheme: FolderViewScrollbarTheme(
        thumbColor: _thumbColor,
        trackColor: _trackColor,
        thickness: _thickness,
        radius: _thumbRadius,
        thumbVisibility: _thumbVisibility,
        hoverOpacity: _hoverOpacity,
        nonHoverOpacity: _nonHoverOpacity,
        hoverAnimationDuration: Duration(milliseconds: _hoverAnimationMs),
        trackWidth: _trackWidth,
        trackRadius: _trackRadius,
        trackVisibility: _trackVisibility,
      ),
    );
  }

  /// `FlutterFolderViewTheme.scrollbarTheme` as the argument a caller would
  /// write.
  String get scrollbarThemeCode =>
      'scrollbarTheme: const FolderViewScrollbarTheme(\n'
      '  thumbColor: ${_colorCode(_thumbColor)},\n'
      '  trackColor: ${_colorCode(_trackColor)},\n'
      '  thickness: ${_num(_thickness)},\n'
      '  radius: ${_num(_thumbRadius)},\n'
      '  thumbVisibility: $_thumbVisibility,\n'
      '  hoverOpacity: ${_num(_hoverOpacity)},\n'
      '  nonHoverOpacity: ${_num(_nonHoverOpacity)},\n'
      '  hoverAnimationDuration: Duration(milliseconds: $_hoverAnimationMs),\n'
      '  trackWidth: ${_num(_trackWidth)},\n'
      '  trackRadius: ${_num(_trackRadius)},\n'
      '  trackVisibility: $_trackVisibility,\n'
      '),';

  /// `FlutterFolderViewTheme.folderTheme` as the argument a caller would
  /// write. The tooltip theme is left out: its knobs belong to the tooltip
  /// features.
  String get folderThemeCode {
    final grey = switch (_base) {
      ThemePreset.light => 'shade700',
      ThemePreset.dark => 'shade400',
    };
    final style = [
      if (_folderTextColor != null) 'color: ${_colorCode(_folderTextColor!)}',
      if (_folderFontSize != null) 'fontSize: ${_num(_folderFontSize!)}',
      if (_folderBold) 'fontWeight: FontWeight.bold',
    ].join(', ');
    return 'folderTheme: FolderNodeTheme<String>(\n'
        '  widget: ${_folderWidgetSample ? 'const Icon(Icons.folder_outlined, size: 20)' : 'Icon(Icons.folder, color: Colors.grey.$grey, size: 20)'},\n'
        '${_folderWidgetResolver ? '  widgetResolver: (node) => node.children.length == 1\n      ? const Icon(Icons.folder_special, size: 20)\n      : null,\n' : ''}'
        '${switch (_folderOpenWidget) {
          FolderOpenWidget.factory => '  openWidget: Icon(Icons.folder_open, color: Colors.grey.$grey, size: 20),\n',
          FolderOpenWidget.sample => '  openWidget: const Icon(Icons.folder_open_outlined, size: 20),\n',
          FolderOpenWidget.none => '',
        }}'
        '${_folderOpenWidgetResolver ? '  openWidgetResolver: (node) => node.children.length == 1\n      ? const Icon(Icons.snippet_folder, size: 20)\n      : null,\n' : ''}'
        '  width: ${_num(_folderWidth)},\n'
        '  height: ${_num(_folderHeight)},\n'
        '  padding: ${_edgeCode(_folderPadding)},\n'
        '  margin: ${_edgeCode(_folderMargin)},\n'
        '  textStyle: TextStyle($style),\n'
        '${_folderTextStyleResolver ? '  textStyleResolver: (node) => node.children.length == 1\n      ? const TextStyle(color: Color(0xFF00897B), fontWeight: FontWeight.bold)\n      : null,\n' : ''}'
        '${_folderLabelResolver ? "  labelResolver: (node) => '\${node.label} (\${node.children.length})',\n" : ''}'
        '${_colorLine('hoverColor', _folderHoverColor)}'
        '${_inkLine('splashColor', _folderSplashColor, folderSplashColors, 0.3)}'
        '${_inkLine('highlightColor', _folderHighlightColor, folderHighlightColors, 0.1)}'
        '),';
  }

  /// `FlutterFolderViewTheme.expandIconTheme` as the argument a caller would
  /// write.
  String get expandIconThemeCode {
    final widget = _expandIconSample
        ? 'Icon(Icons.arrow_right, size: 20)'
        : 'Icon(Icons.chevron_right, color: Colors.grey.${switch (_base) {
            ThemePreset.light => 'shade700',
            ThemePreset.dark => 'shade400',
          }}, size: 20)';
    return 'expandIconTheme: ${_expandIconSample ? 'const ' : ''}'
        'ExpandIconTheme(\n'
        '  widget: $widget,\n'
        '  width: ${_num(_expandIconWidth)},\n'
        '  height: ${_num(_expandIconHeight)},\n'
        '  padding: ${_edgeCode(_expandIconPadding)},\n'
        '  margin: ${_edgeCode(_expandIconMargin)},\n'
        '${_colorLine('color', _expandIconColor)}'
        '${_colorLine('expandedColor', _expandIconExpandedColor)}'
        '),';
  }

  static String _edgeCode(EdgeInsets p) =>
      'EdgeInsets.fromLTRB(${_num(p.left)}, ${_num(p.top)}, '
      '${_num(p.right)}, ${_num(p.bottom)})';

  static String _colorCode(Color c) =>
      'Color(0x${c.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()})';

  /// An ink colour line: a swatch built with `withValues` is written the same
  /// way, since its hex form has a different alpha.
  static String _inkLine(
    String name,
    Color? c,
    List<Color?> swatches,
    double alpha,
  ) {
    const bases = ['Colors.blue', 'Colors.red', 'Colors.green'];
    final i = swatches.indexOf(c);
    if (c == null || i < 0 || i >= bases.length) return _colorLine(name, c);
    return '  $name: ${bases[i]}.withValues(alpha: $alpha),\n';
  }

  static String _colorLine(String name, Color? c) =>
      c == null ? '' : '  $name: ${_colorCode(c)},\n';

  /// `FlutterFolderViewTheme.lineTheme` as the argument a caller would write.
  String get lineThemeCode {
    return 'lineTheme: const FolderViewLineTheme(\n'
        '  lineColor: ${_colorCode(_lineColor)},\n'
        '  lineWidth: ${_num(_lineWidth)},\n'
        '  lineStyle: LineStyle.${_lineStyle.name},\n'
        '),';
  }

  /// `FlutterFolderViewTheme.spacingTheme` as the argument a caller would
  /// write.
  String get spacingThemeCode =>
      'spacingTheme: const FolderViewSpacingTheme(\n'
      '  contentPadding: ${_edgeCode(_contentPadding)},\n'
      '),';

  /// `FlutterFolderViewTheme.nodeStyleTheme` as the argument a caller would
  /// write.
  String get nodeStyleThemeCode =>
      'nodeStyleTheme: const FolderViewNodeStyleTheme(borderRadius: '
      '${_num(_borderRadius)}),';

  static String _num(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toString();

  final List<String> _log = [];

  /// The tap callbacks that fired, newest first, at most [logLength].
  List<String> get log => List.unmodifiable(_log);
  static const logLength = 20;

  set dataSource(DataSource value) => _update(() => _dataSource = value);
  set folderCount(int value) => _update(() => _folderCount = value);
  set parentsPerFolder(int value) => _update(() => _parentsPerFolder = value);
  set childrenPerParent(int value) => _update(() => _childrenPerParent = value);

  set mode(ViewMode value) => _set(() => _mode = value);
  set selectionMode(SelectionMode value) => _set(() => _selectionMode = value);
  set tapHandlerOn(bool value) => _set(() => _tapHandlerOn = value);
  set doubleTapHandlerOn(bool value) => _set(() => _doubleTapHandlerOn = value);
  set secondaryTapHandlerOn(bool value) =>
      _set(() => _secondaryTapHandlerOn = value);
  set wheelMotionKind(WheelMotionKind value) =>
      _set(() => _wheelMotionKind = value);
  set wheelDurationMs(int value) => _set(() => _wheelDurationMs = value);
  set wheelBounce(double value) => _set(() => _wheelBounce = value);
  set wheelCurve(WheelCurveOption value) => _set(() => _wheelCurve = value);
  set wheelTimeConstantMs(int value) =>
      _set(() => _wheelTimeConstantMs = value);
  set scale(double value) => _set(() => _scale = value);
  set scaleHandlerOn(bool value) => _set(() => _scaleHandlerOn = value);
  set scaleStep(double value) => _set(() => _scaleStep = value);
  set modifierScrollBlock(ModifierScrollBlock value) =>
      _set(() => _modifierScrollBlock = value);

  set rowHeight(double value) => _setTheme(() => _rowHeight = value);
  set rowSpacing(double value) => _setTheme(() => _rowSpacing = value);
  set animationDuration(int value) =>
      _setTheme(() => _animationDuration = value);
  set contentPadding(EdgeInsets value) =>
      _setTheme(() => _contentPadding = value);
  set borderRadius(double value) => _setTheme(() => _borderRadius = value);
  set lineColor(Color value) => _setTheme(() => _lineColor = value);
  set lineWidth(double value) => _setTheme(() => _lineWidth = value);
  set lineStyle(LineStyle value) => _setTheme(() => _lineStyle = value);
  set expandIconSample(bool value) =>
      _setTheme(() => _expandIconSample = value);
  set expandIconWidth(double value) =>
      _setTheme(() => _expandIconWidth = value);
  set expandIconHeight(double value) =>
      _setTheme(() => _expandIconHeight = value);
  set expandIconPadding(EdgeInsets value) =>
      _setTheme(() => _expandIconPadding = value);
  set expandIconMargin(EdgeInsets value) =>
      _setTheme(() => _expandIconMargin = value);
  set expandIconColor(Color? value) =>
      _setTheme(() => _expandIconColor = value);
  set expandIconExpandedColor(Color? value) =>
      _setTheme(() => _expandIconExpandedColor = value);
  set thumbColor(Color value) => _setTheme(() => _thumbColor = value);
  set trackColor(Color value) => _setTheme(() => _trackColor = value);
  set thickness(double value) => _setTheme(() => _thickness = value);
  set thumbRadius(double value) => _setTheme(() => _thumbRadius = value);
  set thumbVisibility(bool value) => _setTheme(() => _thumbVisibility = value);
  set hoverOpacity(double value) => _setTheme(() => _hoverOpacity = value);
  set nonHoverOpacity(double value) =>
      _setTheme(() => _nonHoverOpacity = value);
  set hoverAnimationMs(int value) => _setTheme(() => _hoverAnimationMs = value);
  set trackWidth(double value) => _setTheme(() => _trackWidth = value);
  set trackRadius(double value) => _setTheme(() => _trackRadius = value);
  set trackVisibility(bool value) => _setTheme(() => _trackVisibility = value);
  set folderWidgetSample(bool value) =>
      _setTheme(() => _folderWidgetSample = value);
  set folderOpenWidget(FolderOpenWidget value) =>
      _setTheme(() => _folderOpenWidget = value);
  set folderWidgetResolver(bool value) =>
      _setTheme(() => _folderWidgetResolver = value);
  set folderOpenWidgetResolver(bool value) =>
      _setTheme(() => _folderOpenWidgetResolver = value);
  set folderWidth(double value) => _setTheme(() => _folderWidth = value);
  set folderHeight(double value) => _setTheme(() => _folderHeight = value);
  set folderPadding(EdgeInsets value) =>
      _setTheme(() => _folderPadding = value);
  set folderMargin(EdgeInsets value) => _setTheme(() => _folderMargin = value);
  set folderTextColor(Color? value) =>
      _setTheme(() => _folderTextColor = value);
  set folderFontSize(double? value) => _setTheme(() => _folderFontSize = value);
  set folderBold(bool value) => _setTheme(() => _folderBold = value);
  set folderTextStyleResolver(bool value) =>
      _setTheme(() => _folderTextStyleResolver = value);
  set folderLabelResolver(bool value) =>
      _setTheme(() => _folderLabelResolver = value);
  set folderHoverColor(Color? value) =>
      _setTheme(() => _folderHoverColor = value);
  set folderSplashColor(Color? value) =>
      _setTheme(() => _folderSplashColor = value);
  set folderHighlightColor(Color? value) =>
      _setTheme(() => _folderHighlightColor = value);

  /// `onScaleChanged`: applies the proposed Scale, clamped to [minScale] ..
  /// [maxScale].
  void handleScaleChanged(double proposed) =>
      _set(() => _scale = proposed.clamp(minScale, maxScale));

  /// `onNodeTap`: a Folder or Parent toggles its expansion, a Child toggles
  /// its selection.
  void handleTap(Node<String> node) {
    _record('onNodeTap · ${node.label}');
    if (node.type == NodeType.child) {
      final selected = _selectedIds.contains(node.id);
      _selectedIds = switch (_selectionMode) {
        SelectionMode.single => selected ? {} : {node.id},
        SelectionMode.multiple =>
          selected
              ? (Set.of(_selectedIds)..remove(node.id))
              : {..._selectedIds, node.id},
      };
    } else {
      final next = Set<String>.of(_expandedIds);
      if (!next.remove(node.id)) next.add(node.id);
      _expandedIds = next;
    }
    notifyListeners();
  }

  /// `onDoubleNodeTap`: logged only.
  void handleDoubleTap(Node<String> node) {
    _record('onDoubleNodeTap · ${node.label}');
    notifyListeners();
  }

  /// `onSecondaryNodeTap`: logged with the global position of the tap.
  void handleSecondaryTap(Node<String> node, TapDownDetails details) {
    final at = details.globalPosition;
    _record(
      'onSecondaryNodeTap · ${node.label} @ '
      '(${at.dx.round()}, ${at.dy.round()})',
    );
    notifyListeners();
  }

  void expandAll() => _set(() {
    final ids = <String>{};
    void collect(List<Node<String>> nodes) {
      for (final node in nodes) {
        if (node.type != NodeType.child) ids.add(node.id);
        collect(node.children);
      }
    }

    collect(_nodes);
    _expandedIds = ids;
  });

  void collapseAll() => _set(() => _expandedIds = {});

  void clearSelection() => _set(() => _selectedIds = {});

  void _record(String entry) {
    _log.insert(0, entry);
    if (_log.length > logLength) _log.removeLast();
  }

  void _set(void Function() change) {
    change();
    notifyListeners();
  }

  void _setTheme(void Function() change) {
    change();
    _theme = null;
    notifyListeners();
  }

  void _update(void Function() change) {
    change();
    _rebuildNodes();
    notifyListeners();
  }

  void _rebuildNodes() {
    _nodes = switch (_dataSource) {
      DataSource.demo => getThemeDemoData(),
      DataSource.generated => generateTree(
        folders: _folderCount,
        parentsPerFolder: _parentsPerFolder,
        childrenPerParent: _childrenPerParent,
      ),
    };
    final ids = <String>{};
    void collect(List<Node<String>> nodes) {
      for (final node in nodes) {
        ids.add(node.id);
        collect(node.children);
      }
    }

    collect(_nodes);
    _expandedIds = _dataSource == DataSource.demo
        ? _demoExpandedIds
        : _expandedIds.intersection(ids);
    _selectedIds = _selectedIds.intersection(ids);
  }
}

/// How the example's `onNodeTap` handler updates the Selected Set.
enum SelectionMode { single, multiple }

/// Which `WheelMotion` the stage hands the view; [off] is `null`, which moves
/// the view at once.
enum WheelMotionKind { off, spring, curve, lerp }

/// The `FolderView.blockModifierScroll` value: [follow] is `null`, which
/// blocks exactly when `onScaleChanged` is non-null.
enum ModifierScrollBlock { follow, on, off }

/// The `FlutterFolderViewTheme` factories offered as presets.
enum ThemePreset {
  light,
  dark;

  FlutterFolderViewTheme<String> get theme => switch (this) {
    ThemePreset.light => FlutterFolderViewTheme<String>.light(),
    ThemePreset.dark => FlutterFolderViewTheme<String>.dark(),
  };
}

/// How the stage hands the view its theme.
enum ThemeInjection { parameter, ancestor }

/// The Folder `openWidget`: the factory's, the sample, or none, which falls
/// back to `widget`.
enum FolderOpenWidget { factory, sample, none }

/// The curves the panel offers a `WheelMotion.curve`.
enum WheelCurveOption {
  easeOutCubic(Curves.easeOutCubic),
  easeOut(Curves.easeOut),
  easeInOut(Curves.easeInOut),
  decelerate(Curves.decelerate),
  linear(Curves.linear);

  const WheelCurveOption(this.curve);

  final Curve curve;
}

/// The "Every setting" stage: a `FolderView` over [EverySettingDemo].
class EverySettingStage extends StatelessWidget {
  const EverySettingStage({super.key, required this.demo});

  final EverySettingDemo demo;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: demo,
      builder: (context, _) => switch (demo.injection) {
        ThemeInjection.parameter => _view(demo.theme),
        ThemeInjection.ancestor => FolderViewTheme<String>(
          data: demo.theme,
          child: _view(null),
        ),
      },
    );
  }

  FolderView<String> _view(FlutterFolderViewTheme<String>? theme) =>
      FolderView<String>(
        data: demo.nodes,
        mode: demo.mode,
        expandedNodeIds: demo.expandedIds,
        selectedNodeIds: demo.selectedIds,
        onNodeTap: demo.tapHandlerOn ? demo.handleTap : null,
        onDoubleNodeTap: demo.doubleTapHandlerOn ? demo.handleDoubleTap : null,
        onSecondaryNodeTap: demo.secondaryTapHandlerOn
            ? demo.handleSecondaryTap
            : null,
        wheelMotion: demo.wheelMotion,
        scale: demo.scale,
        onScaleChanged: demo.scaleHandlerOn ? demo.handleScaleChanged : null,
        scaleStep: demo.scaleStep,
        blockModifierScroll: demo.blockModifierScroll,
        theme: theme,
      );
}

/// The "Every setting" knob region: the feature list, and the open feature's
/// controls below it.
class EverySettingKnobs extends StatefulWidget {
  const EverySettingKnobs({super.key, required this.demo});

  final EverySettingDemo demo;

  @override
  State<EverySettingKnobs> createState() => _EverySettingKnobsState();
}

class _EverySettingKnobsState extends State<EverySettingKnobs> {
  late final _host = EverySettingHost(widget.demo);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.demo,
      builder: (context, _) {
        final features = [for (final g in _host.spec) ...g.features];
        final feature = features
            .where((f) => f.id == widget.demo.openFeatureId)
            .firstOrNull;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PresetBar(host: _host),
            Expanded(
              child: FeatureListPane(
                host: _host,
                selectedFeatureId: widget.demo.openFeatureId,
                onFeatureSelected: (id) => widget.demo.openFeatureId = id,
              ),
            ),
            if (feature != null) ...[
              const Divider(height: 1),
              Expanded(
                child: FeatureDetailPane(host: _host, feature: feature),
              ),
            ],
          ],
        );
      },
    );
  }
}
