import 'package:flutter/material.dart';

import '../models/flat_node.dart';
import '../models/node.dart';
import '../services/flatten_service.dart';
import '../services/size_service.dart';
import '../themes/flutter_folder_view_theme.dart';
import '../themes/folder_view_theme.dart';
import 'folder_view_content.dart';
import 'synced_scroll_controllers.dart';

class FolderView<T> extends StatefulWidget {
  final List<Node<T>> data;
  final ViewMode mode;
  final Function(Node<T>)? onNodeTap;
  final Function(Node<T>)? onDoubleNodeTap;
  final Function(Node<T>, TapDownDetails)? onSecondaryNodeTap;
  final Set<String>? selectedNodeIds;
  final Set<String>? expandedNodeIds;
  final FlutterFolderViewTheme<T>? theme;

  const FolderView({
    super.key,
    required this.data,
    required this.mode,
    this.onNodeTap,
    this.onDoubleNodeTap,
    this.onSecondaryNodeTap,
    this.selectedNodeIds,
    this.expandedNodeIds,
    this.theme,
  });

  @override
  State<FolderView<T>> createState() => _FolderViewState<T>();
}

class _FolderViewState<T> extends State<FolderView<T>> {
  /// Cached flatten result
  List<FlatNode<T>> _cachedFlatNodes = [];

  /// Snapshot of expandedNodeIds used to produce the cached result.
  /// We compare by length + content to detect changes.
  Set<String>? _cachedExpandedIds;

  /// Snapshot of data identity used for cache invalidation.
  List<Node<T>>? _cachedData;

  /// Snapshot of mode used for cache invalidation.
  ViewMode? _cachedMode;

  /// Index of the node that was expanded/collapsed (in the old flat list).
  /// -1 means no pending adjustment.
  int _pendingScrollChangedIndex = -1;

  /// Number of items inserted (positive) or removed (negative) by the
  /// last incremental expand/collapse.
  int _pendingScrollDeltaItems = 0;

  /// Pre-calculated maximum content width from all nodes (including collapsed).
  /// Computed once when data changes, ensuring stable width.
  double _precomputedMaxWidth = 0.0;

  /// Whether the width has been computed for the current data.
  bool _widthComputed = false;

  @override
  void didUpdateWidget(covariant FolderView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset computed width when data changes
    if (!identical(oldWidget.data, widget.data)) {
      _widthComputed = false;
    }
  }

  /// Returns cached flat nodes, recomputing only when inputs change.
  /// Uses incremental expand/collapse when exactly one node changed.
  List<FlatNode<T>> _getFlatNodes(List<Node<T>> displayNodes) {
    final expandedIds = widget.expandedNodeIds;

    // Check if we can reuse the cache
    if (identical(_cachedData, widget.data) &&
        _cachedMode == widget.mode &&
        _expandedIdsEqual(_cachedExpandedIds, expandedIds) &&
        _cachedFlatNodes.isNotEmpty) {
      return _cachedFlatNodes;
    }

    // Try incremental update when only data/mode are unchanged and
    // exactly one node was expanded or collapsed.
    if (identical(_cachedData, widget.data) &&
        _cachedMode == widget.mode &&
        _cachedFlatNodes.isNotEmpty &&
        _cachedExpandedIds != null &&
        expandedIds != null) {
      final changedId = _singleDiff(_cachedExpandedIds!, expandedIds);
      if (changedId != null) {
        final isExpand = expandedIds.contains(changedId);
        final previousLength = _cachedFlatNodes.length;
        final result = isExpand
            ? FlattenService.expandNode<T>(
                currentList: _cachedFlatNodes,
                nodeId: changedId,
                expandedNodeIds: expandedIds,
              )
            : FlattenService.collapseNode<T>(
                currentList: _cachedFlatNodes,
                nodeId: changedId,
              );
        if (result != null) {
          // Record the item count delta at this index so the content
          // widget can adjust the scroll offset when the change happened
          // above the current viewport.
          _pendingScrollDeltaItems = result.list.length - previousLength;
          _pendingScrollChangedIndex = result.index;

          _cachedFlatNodes = result.list;
          _cachedExpandedIds = Set<String>.of(expandedIds);
          return _cachedFlatNodes;
        }
      }
    }

    // Full recompute
    _cachedFlatNodes = FlattenService.flatten<T>(
      nodes: displayNodes,
      expandedNodeIds: expandedIds,
    );
    _cachedData = widget.data;
    _cachedMode = widget.mode;
    _cachedExpandedIds =
        expandedIds != null ? Set<String>.of(expandedIds) : null;
    return _cachedFlatNodes;
  }

  /// Returns the single differing element between two sets, or null if
  /// the sets differ by more than one element.
  static String? _singleDiff(Set<String> old, Set<String> current) {
    final diff = old.length - current.length;
    if (diff == 1) {
      // One node collapsed: find the element in old but not in current
      for (final id in old) {
        if (!current.contains(id)) return id;
      }
    } else if (diff == -1) {
      // One node expanded: find the element in current but not in old
      for (final id in current) {
        if (!old.contains(id)) return id;
      }
    }
    return null;
  }

  /// Efficient Set equality check: same length and same elements.
  static bool _expandedIdsEqual(Set<String>? a, Set<String>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  @override
  Widget build(BuildContext context) {
    // Resolve theme: use provided theme, or get from context, or use default
    final effectiveTheme = widget.theme ?? FolderViewTheme.of<T>(context);

    // Filter data based on mode
    List<Node<T>> displayNodes = _getDisplayNodes();

    // Flatten tree into visible flat list (memoized)
    final List<FlatNode<T>> flatNodes = _getFlatNodes(displayNodes);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableHeight = constraints.maxHeight;
        final double availableWidth = constraints.maxWidth;

        // Pre-compute max width from ALL nodes (including collapsed) once per data change.
        if (!_widthComputed) {
          _precomputedMaxWidth = SizeService.calculateMaxContentWidth<T>(
            context: context,
            nodes: widget.data,
            folderTheme: effectiveTheme.folderTheme,
            parentTheme: effectiveTheme.parentTheme,
            childTheme: effectiveTheme.childTheme,
            expandIconTheme: effectiveTheme.expandIconTheme,
            leftPadding: effectiveTheme.spacingTheme.contentPadding.left,
            rightPadding: effectiveTheme.spacingTheme.contentPadding.right,
          );
          _widthComputed = true;
        }

        // Clamp to a reasonable max (3x viewport).
        final maxAllowed = availableWidth * 3;
        final contentWidth = _precomputedMaxWidth.clamp(0.0, maxAllowed);

        final contentHeight = SizeService.calculateContentHeight(
          itemCount: flatNodes.length,
          rowHeight: effectiveTheme.rowHeight,
          rowSpacing: effectiveTheme.rowSpacing,
          topPadding: effectiveTheme.spacingTheme.contentPadding.top,
          bottomPadding: effectiveTheme.spacingTheme.contentPadding.bottom,
        );

        final needsHorizontalScroll = contentWidth > availableWidth;
        final needsVerticalScroll = contentHeight > availableHeight;

        return SyncedScrollControllers(
          key: ValueKey(widget.mode),
          builder: (
            context,
            verticalController,
            verticalScrollbarController,
            horizontalController,
            horizontalScrollbarController,
          ) {
            // Consume pending scroll adjustment info
            final scrollChangedIndex = _pendingScrollChangedIndex;
            final scrollDeltaItems = _pendingScrollDeltaItems;
            _pendingScrollChangedIndex = -1;
            _pendingScrollDeltaItems = 0;

            return FolderViewContent<T>(
              flatNodes: flatNodes,
              mode: widget.mode,
              onNodeTap: widget.onNodeTap,
              onDoubleNodeTap: widget.onDoubleNodeTap,
              onSecondaryNodeTap: widget.onSecondaryNodeTap,
              selectedNodeIds: widget.selectedNodeIds,
              expandedNodeIds: widget.expandedNodeIds,
              contentWidth: contentWidth,
              contentHeight: contentHeight,
              viewportWidth: availableWidth,
              needsHorizontalScroll: needsHorizontalScroll,
              needsVerticalScroll: needsVerticalScroll,
              horizontalController: horizontalController!,
              verticalController: verticalController!,
              horizontalBarController: horizontalScrollbarController!,
              verticalBarController: verticalScrollbarController!,
              theme: effectiveTheme,
              scrollChangedIndex: scrollChangedIndex,
              scrollDeltaItems: scrollDeltaItems,
            );
          },
        );
      },
    );
  }

  List<Node<T>> _getDisplayNodes() {
    if (widget.mode == ViewMode.tree) {
      // In Tree Mode, we only show Parent nodes at the root level
      // If data contains Folders, we need to extract Parents from within them recursively
      List<Node<T>> parents = [];
      _collectParentsFromNodes(widget.data, parents);
      return parents;
    } else {
      // In Folder Mode, we show Folders and Parents at the root level.
      // "Folder mode: Folder > Parent > Child. Parent of Parent is Folder."
      return widget.data
          .where((n) => n.type == NodeType.folder || n.type == NodeType.parent)
          .toList();
    }
  }

  /// Recursively collect all parent nodes from nested folders
  void _collectParentsFromNodes(List<Node<T>> nodes, List<Node<T>> parents) {
    for (var node in nodes) {
      if (node.type == NodeType.parent) {
        parents.add(node);
      } else if (node.type == NodeType.folder) {
        // Recursively search within folder's children
        _collectParentsFromNodes(node.children, parents);
      }
    }
  }
}
