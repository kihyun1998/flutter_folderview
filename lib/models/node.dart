enum ViewMode {
  tree,
  folder,
}

enum NodeType {
  folder,
  parent,
  child,
}

class Node<T> {
  final String id;
  final String label;
  final NodeType type;
  final T? data;
  final List<Node<T>> children;
  bool isExpanded;

  Node({
    required this.id,
    required this.label,
    required this.type,
    this.data,
    this.children = const [],
    this.isExpanded = false,
  });

  /// Helper to check if this node can have children displayed in the current mode
  bool get canExpand {
    return children.isNotEmpty;
  }
}
