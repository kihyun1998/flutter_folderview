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

  /// Bitmask of "is this ancestor the last child?" over ancestor depth levels.
  /// Bit `d` (for `d` in `0 .. depth-1`) is set when the ancestor at depth `d`
  /// is the last child of its parent — meaning no vertical continuation line is
  /// drawn at that depth. Replaces a per-node `List<bool>` to avoid a heap
  /// allocation for every flattened node (the flags are read only when a row is
  /// painted, i.e. only for visible rows). Tree depth is therefore capped at
  /// [maxDepth].
  final int ancestorIsLastMask;

  /// Maximum tree depth representable in [ancestorIsLastMask] (one bit per
  /// ancestor level, within a 64-bit int with headroom).
  static const int maxDepth = 63;

  const FlatNode({
    required this.node,
    required this.depth,
    required this.isFirst,
    required this.isLast,
    required this.isRoot,
    required this.ancestorIsLastMask,
  });
}
