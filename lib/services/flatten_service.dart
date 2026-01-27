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
        ancestorIsLastFlags: ancestorIsLastFlags,
      ));

      // Recurse into children if expanded
      final isExpanded =
          expandedNodeIds?.contains(node.id) ?? false;
      if (isExpanded && node.children.isNotEmpty) {
        final childFlags = [...ancestorIsLastFlags, isLast];
        result.addAll(flatten<T>(
          nodes: node.children,
          expandedNodeIds: expandedNodeIds,
          depth: depth + 1,
          isRoot: false,
          ancestorIsLastFlags: childFlags,
        ));
      }
    }

    return result;
  }
}
