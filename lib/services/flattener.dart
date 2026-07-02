import '../models/flat_node.dart';
import '../models/node.dart';
import 'flatten_service.dart';
import 'view_mode_projection.dart';

/// Metadata describing an incremental single-node expand/collapse, so a scroll
/// anchor can preserve position when the change happened above the viewport.
class FlattenChange {
  /// Index of the changed node in the resulting flat list.
  final int index;

  /// Item count delta: positive when rows were inserted (expand), negative
  /// when removed (collapse).
  final int deltaItems;

  const FlattenChange({required this.index, required this.deltaItems});
}

/// The result of a [Flattener.update]: the current flat list plus, when the
/// update was an incremental single-node change, its [FlattenChange].
class FlattenResult<T> {
  final List<FlatNode<T>> list;

  /// Non-null only for an incremental single-node expand/collapse; null for a
  /// full rebuild or a cache hit.
  final FlattenChange? change;

  const FlattenResult({required this.list, required this.change});
}

/// Owns the flat-list cache and the incremental-vs-rebuild decision.
///
/// The caller pushes the current inputs each build via [update]; the Flattener
/// projects the input for the [ViewMode] (see [ViewModeProjection]), flattens
/// it, and decides whether a single-node change can be applied incrementally or
/// a full rebuild is required. It reads caller-owned state (the Expanded Set)
/// but never mutates it (ADR-0002).
class Flattener<T> {
  List<FlatNode<T>> _cachedList = [];
  Set<String>? _cachedExpandedIds;
  List<Node<T>>? _cachedData;
  ViewMode? _cachedMode;

  /// Recomputes the visible flat list for the given inputs, reusing the cache
  /// and applying an incremental update when exactly one node's expansion
  /// changed.
  FlattenResult<T> update({
    required List<Node<T>> data,
    required ViewMode mode,
    required Set<String>? expandedIds,
  }) {
    // Cache hit: nothing changed.
    if (identical(_cachedData, data) &&
        _cachedMode == mode &&
        _expandedIdsEqual(_cachedExpandedIds, expandedIds) &&
        _cachedList.isNotEmpty) {
      return FlattenResult(list: _cachedList, change: null);
    }

    // Incremental: same data/mode, exactly one node expanded or collapsed.
    if (identical(_cachedData, data) &&
        _cachedMode == mode &&
        _cachedList.isNotEmpty &&
        _cachedExpandedIds != null &&
        expandedIds != null) {
      final changedId = _singleDiff(_cachedExpandedIds!, expandedIds);
      if (changedId != null) {
        final isExpand = expandedIds.contains(changedId);
        final previousLength = _cachedList.length;
        final result = isExpand
            ? FlattenService.expandNode<T>(
                currentList: _cachedList,
                nodeId: changedId,
                expandedNodeIds: expandedIds,
              )
            : FlattenService.collapseNode<T>(
                currentList: _cachedList,
                nodeId: changedId,
              );
        if (result != null) {
          _cachedList = result.list;
          _cachedExpandedIds = Set<String>.of(expandedIds);
          return FlattenResult(
            list: _cachedList,
            change: FlattenChange(
              index: result.index,
              deltaItems: result.list.length - previousLength,
            ),
          );
        }
      }
    }

    // Full rebuild.
    final displayNodes = ViewModeProjection.project<T>(nodes: data, mode: mode);
    _cachedList = FlattenService.flatten<T>(
      nodes: displayNodes,
      expandedNodeIds: expandedIds,
    );
    _cachedData = data;
    _cachedMode = mode;
    _cachedExpandedIds =
        expandedIds != null ? Set<String>.of(expandedIds) : null;
    return FlattenResult(list: _cachedList, change: null);
  }

  /// The single differing element between two sets, or null if they differ by
  /// more than one element.
  static String? _singleDiff(Set<String> old, Set<String> current) {
    final diff = old.length - current.length;
    if (diff == 1) {
      for (final id in old) {
        if (!current.contains(id)) return id;
      }
    } else if (diff == -1) {
      for (final id in current) {
        if (!old.contains(id)) return id;
      }
    }
    return null;
  }

  static bool _expandedIdsEqual(Set<String>? a, Set<String>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }
}
