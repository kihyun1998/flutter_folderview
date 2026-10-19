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

  /// The colours the `lineColor` control offers; the first is `light()`'s.
  static const lineColors = [
    Color(0xFF9E9E9E),
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

  FlutterFolderViewTheme<String>? _theme;

  /// The `FolderView.theme` the settings describe: one instance until a theme
  /// setting changes.
  FlutterFolderViewTheme<String> get theme => _theme ??= _buildTheme();

  FlutterFolderViewTheme<String> _buildTheme() {
    final light = FlutterFolderViewTheme<String>.light();
    return light.copyWith(
      expandIconTheme: ExpandIconTheme(
        widget: _expandIconSample
            ? sampleExpandIcon
            : light.expandIconTheme.widget,
        width: _expandIconWidth,
        height: _expandIconHeight,
        padding: _expandIconPadding,
        margin: _expandIconMargin,
        color: _expandIconColor,
        expandedColor: _expandIconExpandedColor,
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
    );
  }

  /// `FlutterFolderViewTheme.expandIconTheme` as the argument a caller would
  /// write.
  String get expandIconThemeCode {
    final widget = _expandIconSample
        ? 'Icon(Icons.arrow_right, size: 20)'
        : 'Icon(Icons.chevron_right, color: Colors.grey.shade700, size: 20)';
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
      builder: (context, _) => FolderView<String>(
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
        theme: demo.theme,
      ),
    );
  }
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
