enum ViewMode {
  tree,
  folder,
}

enum NodeType {
  folder,
  parent,
  child,
}

enum LineStyle {
  connector, // Traditional tree lines with ├─ and └─
  none, // No lines
  scope, // Vertical indent guide lines only (like VS Code)
}

class Node<T> {
  final String id;
  final String label;
  final NodeType type;
  final T? data;
  final List<Node<T>> children;

  const Node({
    required this.id,
    required this.label,
    required this.type,
    this.data,
    this.children = const [],
  });

  /// Helper to check if this node can have children displayed in the current mode
  bool get canExpand {
    return children.isNotEmpty;
  }
}
