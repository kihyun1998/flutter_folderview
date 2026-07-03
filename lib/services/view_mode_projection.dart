import '../models/node.dart';

/// Projects the input hierarchy onto the list of root nodes visible in a given
/// [ViewMode] — the code counterpart of the **View Mode projection** described
/// in `CONTEXT.md`.
///
/// The projection does not flatten or mutate the input; it only decides which
/// nodes occupy the root of the rendered list. Flattening (expand/collapse) is
/// a separate downstream step ([FlattenService]).
class ViewModeProjection {
  /// Returns the root-level nodes to display for [mode]:
  ///
  /// - [ViewMode.folder]: the natural projection — keep **Folders** and
  ///   **Parents** at the root; a root-level **Child** is dropped.
  /// - [ViewMode.tree]: the flattened projection — **Folders** are hidden and
  ///   their contained **Parents** are recursively lifted to the root.
  static List<Node<T>> project<T>({
    required List<Node<T>> nodes,
    required ViewMode mode,
  }) {
    switch (mode) {
      case ViewMode.tree:
        final parents = <Node<T>>[];
        _collectParents(nodes, parents);
        return parents;
      case ViewMode.folder:
        return nodes
            .where(
                (n) => n.type == NodeType.folder || n.type == NodeType.parent)
            .toList();
    }
  }

  /// Recursively collects **Parents**, descending through **Folders**.
  static void _collectParents<T>(
    List<Node<T>> nodes,
    List<Node<T>> parents,
  ) {
    for (final node in nodes) {
      if (node.type == NodeType.parent) {
        parents.add(node);
      } else if (node.type == NodeType.folder) {
        _collectParents(node.children, parents);
      }
    }
  }
}
