// Microbenchmarks for the hot pure paths behind FolderView's virtualized
// rendering.
//
// These are NOT part of the default test run (they live under benchmark/, not
// test/). Run them explicitly:
//
//   flutter test benchmark/hot_paths_benchmark.dart
//
// Each benchmark reports RunTime in microseconds PER OPERATION (exercise() is
// overridden to a single run()). The numbers catch algorithmic regressions in
// the flatten / projection paths locally; they are machine-dependent and are
// deliberately not a CI gate.

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_folderview/models/flat_node.dart';
import 'package:flutter_folderview/services/flatten_service.dart';
import 'package:flutter_folderview/services/view_mode_projection.dart';
import 'package:flutter_test/flutter_test.dart';

/// A regular Folder > Parent > Child forest sized to ~[targetNodes] total nodes.
///
/// Every Folder and Parent id is collected into [expandedIds], so flattening it
/// yields the fully-expanded visible list — the worst case the hot paths face.
class _Forest {
  _Forest(int targetNodes) {
    const parentsPerFolder = 5;
    const childrenPerParent = 8;
    const perRoot = 1 + parentsPerFolder * (1 + childrenPerParent); // 46
    final rootCount = (targetNodes / perRoot).ceil();

    for (var r = 0; r < rootCount; r++) {
      final fId = 'f$r';
      expandedIds.add(fId);
      final parents = <Node<String>>[];
      for (var p = 0; p < parentsPerFolder; p++) {
        final pId = '${fId}_p$p';
        expandedIds.add(pId);
        final children = <Node<String>>[
          for (var c = 0; c < childrenPerParent; c++)
            Node<String>(
                id: '${pId}_c$c', label: '${pId}_c$c', type: NodeType.child),
        ];
        parents.add(Node<String>(
            id: pId, label: pId, type: NodeType.parent, children: children));
      }
      roots.add(Node<String>(
          id: fId, label: fId, type: NodeType.folder, children: parents));
    }
  }

  final List<Node<String>> roots = [];
  final Set<String> expandedIds = {};

  int get nodeCount => expandedIds.length +
      roots.fold<int>(0, (s, f) => s + _leafCount(f));

  static int _leafCount(Node<String> n) => n.children.isEmpty
      ? 1
      : n.children.fold<int>(0, (s, c) => s + _leafCount(c));
}

/// Full flatten of a fully-expanded forest — the rebuild path (data change,
/// view-mode switch, expand-all). O(visible nodes) with a per-node flags alloc.
class FlattenBenchmark extends BenchmarkBase {
  FlattenBenchmark(this.n) : super('flatten(fully-expanded, n=$n)');

  final int n;
  late final _Forest _forest;

  @override
  void setup() => _forest = _Forest(n);

  @override
  void exercise() => run();

  @override
  void run() {
    FlattenService.flatten<String>(
      nodes: _forest.roots,
      expandedNodeIds: _forest.expandedIds,
    );
  }
}

/// Tree-mode projection: hide Folders and recursively lift their Parents to the
/// root. Runs on every rebuild before flattening.
class ProjectTreeBenchmark extends BenchmarkBase {
  ProjectTreeBenchmark(this.n) : super('project(tree, n=$n)');

  final int n;
  late final _Forest _forest;

  @override
  void setup() => _forest = _Forest(n);

  @override
  void exercise() => run();

  @override
  void run() {
    ViewModeProjection.project<String>(
      nodes: _forest.roots,
      mode: ViewMode.tree,
    );
  }
}

/// Incremental collapse of a mid-deep Parent (~75% down the flat list): the
/// per-tap hot path — an indexWhere scan plus a copy-with-removeRange.
class CollapseNodeBenchmark extends BenchmarkBase {
  CollapseNodeBenchmark(this.n) : super('collapseNode(n=$n)');

  final int n;
  late final List<FlatNode<String>> _fullyExpanded;
  late final String _targetId;

  @override
  void setup() {
    final forest = _Forest(n);
    _fullyExpanded = FlattenService.flatten<String>(
      nodes: forest.roots,
      expandedNodeIds: forest.expandedIds,
    );
    _targetId = _pickExpandableNear(_fullyExpanded, 0.75);
  }

  @override
  void exercise() => run();

  @override
  void run() {
    FlattenService.collapseNode<String>(
      currentList: _fullyExpanded,
      nodeId: _targetId,
    );
  }
}

/// Incremental expand of the same mid-deep Parent: indexWhere scan, subtree
/// flatten, then copy-with-insertAll. Driven from a list where the target is
/// collapsed, so the run reproduces a real "tap to expand".
class ExpandNodeBenchmark extends BenchmarkBase {
  ExpandNodeBenchmark(this.n) : super('expandNode(n=$n)');

  final int n;
  late final List<FlatNode<String>> _targetCollapsed;
  late final Set<String> _expandedIds;
  late final String _targetId;

  @override
  void setup() {
    final forest = _Forest(n);
    final full = FlattenService.flatten<String>(
      nodes: forest.roots,
      expandedNodeIds: forest.expandedIds,
    );
    _targetId = _pickExpandableNear(full, 0.75);
    _expandedIds = forest.expandedIds;
    // Flatten with the target collapsed so expandNode has a subtree to insert.
    _targetCollapsed = FlattenService.flatten<String>(
      nodes: forest.roots,
      expandedNodeIds: forest.expandedIds.difference({_targetId}),
    );
  }

  @override
  void exercise() => run();

  @override
  void run() {
    FlattenService.expandNode<String>(
      currentList: _targetCollapsed,
      nodeId: _targetId,
      expandedNodeIds: _expandedIds,
    );
  }
}

/// The id of an expandable node (has children) whose position in [flat] is
/// closest to [fraction] of the way down — a realistic deep-scan target.
String _pickExpandableNear(List<FlatNode<String>> flat, double fraction) {
  final wanted = (flat.length * fraction).floor();
  var bestId = flat.first.node.id;
  var bestDist = flat.length;
  for (var i = 0; i < flat.length; i++) {
    if (flat[i].node.children.isEmpty) continue;
    final dist = (i - wanted).abs();
    if (dist < bestDist) {
      bestDist = dist;
      bestId = flat[i].node.id;
    }
  }
  return bestId;
}

void main() {
  test('run hot-path microbenchmarks', () {
    for (final n in [1000, 10000]) {
      // Report the real node count once so the sizes are unambiguous.
      // ignore: avoid_print
      print('--- target n=$n (actual nodes=${_Forest(n).nodeCount}) ---');
      FlattenBenchmark(n).report();
      ProjectTreeBenchmark(n).report();
      CollapseNodeBenchmark(n).report();
      ExpandNodeBenchmark(n).report();
    }
  }, timeout: const Timeout(Duration(minutes: 2)));
}
