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
    List<bool> ancestorIsLastFlags = const [],
  }) {
    final result = <FlatNode<T>>[];
    // Use a mutable list for recursion to avoid spreading a new list
    // at every level. Each FlatNode receives an unmodifiable snapshot.
    final mutableFlags = List<bool>.of(ancestorIsLastFlags);
    _flattenInto<T>(
      result: result,
      nodes: nodes,
      expandedNodeIds: expandedNodeIds,
      depth: depth,
      isRoot: isRoot,
      mutableFlags: mutableFlags,
    );
    return result;
  }

  /// Internal recursive helper that appends to [result] in-place
  /// and reuses [mutableFlags] across sibling/child iterations.
  static void _flattenInto<T>({
    required List<FlatNode<T>> result,
    required List<Node<T>> nodes,
    required Set<String>? expandedNodeIds,
    required int depth,
    required bool isRoot,
    required List<bool> mutableFlags,
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
        ancestorIsLastFlags: List<bool>.unmodifiable(mutableFlags),
      ));

      // Recurse into children if expanded
      final isExpanded = expandedNodeIds?.contains(node.id) ?? false;
      if (isExpanded && node.children.isNotEmpty) {
        mutableFlags.add(isLast);
        _flattenInto<T>(
          result: result,
          nodes: node.children,
          expandedNodeIds: expandedNodeIds,
          depth: depth + 1,
          isRoot: false,
          mutableFlags: mutableFlags,
        );
        mutableFlags.removeLast();
      }
    }
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

    // Flatten only this node's children subtree
    final childFlags = List<bool>.of(flatNode.ancestorIsLastFlags)
      ..add(flatNode.isLast);
    final subtree = <FlatNode<T>>[];
    _flattenInto<T>(
      result: subtree,
      nodes: node.children,
      expandedNodeIds: expandedNodeIds,
      depth: flatNode.depth + 1,
      isRoot: false,
      mutableFlags: childFlags,
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
