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
