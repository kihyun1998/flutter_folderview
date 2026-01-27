import 'node.dart';

/// A flattened representation of a tree node for virtualized rendering.
///
/// Contains all information needed to render a single row in a flat ListView,
/// including depth, position flags, and ancestor "isLast" info for tree lines.
class FlatNode<T> {
  /// The original tree node
  final Node<T> node;

  /// Depth level (0 = root)
  final int depth;

  /// Whether this node is the first child of its parent
  final bool isFirst;

  /// Whether this node is the last child of its parent
  final bool isLast;

  /// Whether this is a root-level node
  final bool isRoot;

  /// For each ancestor depth level, whether that ancestor is the last child.
  /// Used to decide whether to draw a vertical continuation line at that depth.
  /// Index 0 = depth 0 ancestor, index 1 = depth 1 ancestor, etc.
  final List<bool> ancestorIsLastFlags;

  const FlatNode({
    required this.node,
    required this.depth,
    required this.isFirst,
    required this.isLast,
    required this.isRoot,
    required this.ancestorIsLastFlags,
  });
}
