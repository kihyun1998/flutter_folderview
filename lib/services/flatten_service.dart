import '../models/flat_node.dart';
import '../models/node.dart';

class FlattenService {
  /// Flattens a tree of nodes into a list of [FlatNode]s,
  /// only including children of expanded nodes.
  ///
  /// This produces the visible node list for virtualized rendering.
  static List<FlatNode<T>> flatten<T>({
    required List<Node<T>> nodes,
    required Set<String>? expandedNodeIds,
    int depth = 0,
    bool isRoot = true,
    int ancestorIsLastMask = 0,
  }) {
    final result = <FlatNode<T>>[];
    _flattenInto<T>(
      result: result,
      nodes: nodes,
      expandedNodeIds: expandedNodeIds,
      depth: depth,
      isRoot: isRoot,
      ancestorIsLastMask: ancestorIsLastMask,
    );
    return result;
  }

  /// Internal recursive helper that appends to [result] in-place. The ancestor
  /// "is last" flags are carried as a plain [int] bitmask threaded by value —
  /// no per-level list to allocate or unwind.
  static void _flattenInto<T>({
    required List<FlatNode<T>> result,
    required List<Node<T>> nodes,
    required Set<String>? expandedNodeIds,
    required int depth,
    required bool isRoot,
    required int ancestorIsLastMask,
  }) {
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      final isFirst = i == 0;
      final isLast = i == nodes.length - 1;

      result.add(FlatNode<T>(
        node: node,
        depth: depth,
        isFirst: isFirst,
        isLast: isLast,
        isRoot: isRoot,
        ancestorIsLastMask: ancestorIsLastMask,
      ));

      // Recurse into children if expanded
      final isExpanded = expandedNodeIds?.contains(node.id) ?? false;
      if (isExpanded && node.children.isNotEmpty) {
        _flattenInto<T>(
          result: result,
          nodes: node.children,
          expandedNodeIds: expandedNodeIds,
          depth: depth + 1,
          isRoot: false,
          ancestorIsLastMask: _childAncestorMask(ancestorIsLastMask, depth, isLast),
        );
      }
    }
  }

  /// The ancestor "is last" bitmask to hand to the children of a node at
  /// [parentDepth]: the parent becomes the ancestor at index [parentDepth], so
  /// its bit is set iff [parentIsLast]. Single source of truth for the encoding
  /// and the depth cap.
  static int _childAncestorMask(int parentMask, int parentDepth, bool parentIsLast) {
    assert(parentDepth < FlatNode.maxDepth,
        'tree depth exceeds FlatNode.maxDepth (${FlatNode.maxDepth})');
    return parentIsLast ? (parentMask | (1 << parentDepth)) : parentMask;
  }

  /// Incrementally expand a node: insert its flattened subtree right after it.
  /// Returns the new list and the index of the expanded node, or null if the
  /// node was not found (caller should fall back to full rebuild).
  static ({List<FlatNode<T>> list, int index})? expandNode<T>({
    required List<FlatNode<T>> currentList,
    required String nodeId,
    required Set<String>? expandedNodeIds,
  }) {
    // Find the node's index in the flat list
    final idx = currentList.indexWhere((fn) => fn.node.id == nodeId);
    if (idx == -1) return null;

    final flatNode = currentList[idx];
    final node = flatNode.node;
    if (node.children.isEmpty) return (list: currentList, index: idx);

    // Flatten only this node's children subtree. This node is the ancestor at
    // index [flatNode.depth] for those children.
    final subtree = <FlatNode<T>>[];
    _flattenInto<T>(
      result: subtree,
      nodes: node.children,
      expandedNodeIds: expandedNodeIds,
      depth: flatNode.depth + 1,
      isRoot: false,
      ancestorIsLastMask: _childAncestorMask(
          flatNode.ancestorIsLastMask, flatNode.depth, flatNode.isLast),
    );

    // Insert after the node — modify in place to avoid full copy
    final result = List<FlatNode<T>>.of(currentList)
      ..insertAll(idx + 1, subtree);
    return (list: result, index: idx);
  }

  /// Incrementally collapse a node: remove all descendants that follow it.
  /// Returns the new list and the index of the collapsed node, or null if the
  /// node was not found (caller should fall back to full rebuild).
  static ({List<FlatNode<T>> list, int index})? collapseNode<T>({
    required List<FlatNode<T>> currentList,
    required String nodeId,
  }) {
    final idx = currentList.indexWhere((fn) => fn.node.id == nodeId);
    if (idx == -1) return null;

    final parentDepth = currentList[idx].depth;

    // Find the end of descendants: all consecutive items with depth > parentDepth
    int endIdx = idx + 1;
    while (endIdx < currentList.length &&
        currentList[endIdx].depth > parentDepth) {
      endIdx++;
    }

    if (endIdx == idx + 1) {
      return (list: currentList, index: idx); // Nothing to remove
    }

    final result = List<FlatNode<T>>.of(currentList)
      ..removeRange(idx + 1, endIdx);
    return (list: result, index: idx);
  }
}
