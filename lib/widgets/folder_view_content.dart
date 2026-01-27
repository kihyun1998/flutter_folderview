// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../models/flat_node.dart';
import '../models/node.dart';
import '../services/size_service.dart';
import '../themes/flutter_folder_view_theme.dart';
import 'folder_view_horizontal_scrollbar.dart';
import 'folder_view_vertical_scrollbar.dart';
import 'node_widget.dart';

class FolderViewContent<T> extends StatefulWidget {
  /// Scroll controllers
  final ScrollController horizontalController;
  final ScrollController horizontalBarController;
  final ScrollController verticalController;
  final ScrollController verticalBarController;

  /// Scroll flags
  final bool needsVerticalScroll;
  final bool needsHorizontalScroll;

  final double contentWidth;
  final double contentHeight;
  final double viewportWidth;

  final List<FlatNode<T>> flatNodes;
  final ViewMode mode;
  final Function(Node<T>)? onNodeTap;
  final Function(Node<T>)? onDoubleNodeTap;
  final Function(Node<T>, TapDownDetails)? onSecondaryNodeTap;
  final Set<String>? selectedNodeIds;
  final Set<String>? expandedNodeIds;
  final FlutterFolderViewTheme<T> theme;

  /// Called when a rendered node's width is measured.
  /// The parent uses this to track the observed max content width.
  final ValueChanged<double>? onNodeWidthMeasured;

  /// Index (in the previous flat list) of the node that was expanded/collapsed.
  /// -1 means no adjustment needed.
  final int scrollChangedIndex;

  /// Number of items inserted (positive) or removed (negative).
  final int scrollDeltaItems;

  const FolderViewContent({
    super.key,
    required this.horizontalController,
    required this.horizontalBarController,
    required this.verticalController,
    required this.verticalBarController,
    required this.needsVerticalScroll,
    required this.needsHorizontalScroll,
    required this.contentWidth,
    required this.contentHeight,
    required this.viewportWidth,
    required this.flatNodes,
    required this.mode,
    required this.onNodeTap,
    this.onDoubleNodeTap,
    this.onSecondaryNodeTap,
    required this.selectedNodeIds,
    this.expandedNodeIds,
    required this.theme,
    this.onNodeWidthMeasured,
    this.scrollChangedIndex = -1,
    this.scrollDeltaItems = 0,
  });

  @override
  State<FolderViewContent<T>> createState() => _FolderViewContentState<T>();
}

class _FolderViewContentState<T> extends State<FolderViewContent<T>> {
  bool _isHover = false;
  final GlobalKey _listViewKey = GlobalKey();

  /// Current horizontal scroll offset, driven by horizontalController.
  double _horizontalOffset = 0.0;

  @override
  void initState() {
    super.initState();
    widget.horizontalController.addListener(_onHorizontalScroll);
  }

  @override
  void didUpdateWidget(covariant FolderViewContent<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.horizontalController != widget.horizontalController) {
      oldWidget.horizontalController.removeListener(_onHorizontalScroll);
      widget.horizontalController.addListener(_onHorizontalScroll);
    }

    // Adjust vertical scroll offset when items were inserted/removed above
    // the current viewport due to expand/collapse.
    _applyScrollAdjustment();
  }

  void _applyScrollAdjustment() {
    final changedIndex = widget.scrollChangedIndex;
    final deltaItems = widget.scrollDeltaItems;
    if (changedIndex < 0 || deltaItems == 0) return;

    final controller = widget.verticalController;
    if (!controller.hasClients) return;

    final itemExtent = widget.theme.rowHeight + widget.theme.rowSpacing;
    final topPadding = widget.theme.spacingTheme.contentPadding.top;

    // The pixel position where inserted/removed items begin
    // (right after the changed node).
    final changePixel = topPadding + (changedIndex + 1) * itemExtent;

    // Only adjust if the change happened above (or at) the current scroll offset.
    if (changePixel <= controller.offset) {
      final delta = deltaItems * itemExtent;
      final newOffset = (controller.offset + delta).clamp(
        controller.position.minScrollExtent,
        controller.position.maxScrollExtent,
      );
      controller.jumpTo(newOffset);
    }
  }

  @override
  void dispose() {
    widget.horizontalController.removeListener(_onHorizontalScroll);
    super.dispose();
  }

  void _onHorizontalScroll() {
    final offset = widget.horizontalController.offset;
    if (offset != _horizontalOffset) {
      setState(() {
        _horizontalOffset = offset;
      });
    }
  }

  Widget _buildItem(int index) {
    final flatNode = widget.flatNodes[index];
    final isExpanded =
        widget.expandedNodeIds?.contains(flatNode.node.id) ?? false;
    final theme = widget.theme;

    // Report this node's intrinsic width for lazy max-width tracking
    if (widget.onNodeWidthMeasured != null) {
      final nodeWidth = SizeService.calculateSingleNodeWidth(
        node: flatNode.node,
        depth: flatNode.depth,
        folderTheme: theme.folderTheme,
        parentTheme: theme.parentTheme,
        childTheme: theme.childTheme,
        expandIconTheme: theme.expandIconTheme,
        leftPadding: theme.spacingTheme.contentPadding.left,
        rightPadding: theme.spacingTheme.contentPadding.right,
      );
      widget.onNodeWidthMeasured!(nodeWidth);
    }

    final nodeWidget = NodeWidget<T>(
      flatNode: flatNode,
      mode: widget.mode,
      onTap: widget.onNodeTap,
      onDoubleTap: widget.onDoubleNodeTap,
      onSecondaryTap: widget.onSecondaryNodeTap,
      selectedNodeIds: widget.selectedNodeIds,
      isExpanded: isExpanded,
      theme: theme,
    );

    // Apply horizontal offset via Transform.translate instead of
    // wrapping the entire ListView in a SingleChildScrollView.
    // This preserves ListView virtualization completely.
    if (_horizontalOffset == 0.0) return nodeWidget;
    return Transform.translate(
      offset: Offset(-_horizontalOffset, 0),
      child: nodeWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    // Fixed item extent enables O(1) scroll offset calculation.
    // Without it, jumping to the middle of 20k items forces Flutter
    // to lay out all preceding items to determine their cumulative height.
    final double itemExtent = theme.rowHeight + theme.rowSpacing;

    final Widget listView = Column(
      children: [
        Expanded(
          child: ListView.builder(
            key: _listViewKey,
            controller: widget.verticalController,
            padding: theme.spacingTheme.contentPadding,
            itemCount: widget.flatNodes.length,
            itemExtent: itemExtent,
            itemBuilder: (context, index) => _buildItem(index),
          ),
        ),
        // Only add spacing when horizontal scrollbar is actually needed
        if (widget.needsHorizontalScroll)
          SizedBox(height: theme.scrollbarTheme.trackWidth),
      ],
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHover = true),
      onExit: (_) => setState(() => _isHover = false),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: Stack(
          children: [
            // ListView directly — no SingleChildScrollView wrapper.
            // Horizontal offset is applied per-item via Transform.translate.
            ClipRect(child: listView),

            // Hidden SingleChildScrollView to keep horizontalController
            // attached to a ScrollPosition (required for synced scrollbar).
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 0,
              child: SingleChildScrollView(
                controller: widget.horizontalController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(width: widget.contentWidth),
              ),
            ),

            /// Vertical scrollbar
            if (widget.needsVerticalScroll)
              FolderViewVerticalScrollbar(
                isHover: _isHover,
                verticalScrollbarController: widget.verticalBarController,
                contentHeight: widget.contentHeight,
                needsHorizontalScroll: widget.needsHorizontalScroll,
                scrollbarTheme: widget.theme.scrollbarTheme,
              ),

            /// Horizontal scrollbar
            if (widget.needsHorizontalScroll)
              FolderViewHorizontalScrollbar(
                isHover: _isHover,
                horizontalScrollbarController: widget.horizontalBarController,
                contentWidth: widget.contentWidth,
                scrollbarTheme: widget.theme.scrollbarTheme,
              ),
          ],
        ),
      ),
    );
  }
}
