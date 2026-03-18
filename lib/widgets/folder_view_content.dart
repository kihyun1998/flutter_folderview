// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  /// Scale factor applied to content dimensions.
  final double scale;

  /// When `true`, normal scrolling is blocked while Ctrl/Cmd is held.
  final bool blockCtrlScroll;

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
    this.scale = 1.0,
    this.blockCtrlScroll = true,
    this.scrollChangedIndex = -1,
    this.scrollDeltaItems = 0,
  });

  @override
  State<FolderViewContent<T>> createState() => _FolderViewContentState<T>();
}

class _FolderViewContentState<T> extends State<FolderViewContent<T>> {
  final ValueNotifier<bool> _isHover = ValueNotifier<bool>(false);
  final GlobalKey _listViewKey = GlobalKey();

  /// Current horizontal scroll offset, driven by horizontalController.
  final ValueNotifier<double> _horizontalOffset = ValueNotifier<double>(0.0);

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

    // Adjust scroll position when scale changes (preserve visible node)
    _applyScaleAdjustment(oldWidget);

    // Adjust vertical scroll offset when items were inserted/removed above
    // the current viewport due to expand/collapse.
    _applyScrollAdjustment(oldWidget);
  }

  void _applyScaleAdjustment(FolderViewContent<T> oldWidget) {
    if (oldWidget.scale == widget.scale) return;

    final controller = widget.verticalController;
    if (!controller.hasClients) return;

    final oldItemExtent =
        oldWidget.theme.rowHeight + oldWidget.theme.rowSpacing;
    final newItemExtent = widget.theme.rowHeight + widget.theme.rowSpacing;
    final oldTopPadding = oldWidget.theme.spacingTheme.contentPadding.top;
    final newTopPadding = widget.theme.spacingTheme.contentPadding.top;

    final scrollOffset = controller.offset;

    // Find which fractional item position is at the top of viewport
    final topFractionalIndex = oldItemExtent > 0
        ? (scrollOffset - oldTopPadding) / oldItemExtent
        : 0.0;

    // Map to new offset preserving the same visible node
    final newOffset = newTopPadding + topFractionalIndex * newItemExtent;

    final contentHeight = widget.contentHeight;

    // Also compute horizontal adjustment
    final hController = widget.horizontalController;
    double? newHOffset;
    if (hController.hasClients && oldWidget.contentWidth > 0) {
      final hOffset = hController.offset;
      final ratio = widget.contentWidth / oldWidget.contentWidth;
      newHOffset = hOffset * ratio;
    }

    // Defer all jumpTo calls to after the build phase to avoid
    // "setState() called during build" from scroll notifications.
    final barController = widget.verticalBarController;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Vertical adjustment
      if (controller.hasClients) {
        final viewportHeight = controller.position.viewportDimension;
        final newMaxExtent =
            (contentHeight - viewportHeight).clamp(0.0, double.infinity);
        final clampedV = newOffset.clamp(0.0, newMaxExtent);

        if ((clampedV - controller.offset).abs() > 0.5) {
          controller.jumpTo(clampedV);
        }

        // Re-sync scrollbar controller
        if (barController.hasClients) {
          final target = controller.offset.clamp(
            barController.position.minScrollExtent,
            barController.position.maxScrollExtent,
          );
          barController.jumpTo(target);
        }
      }

      // Horizontal adjustment
      if (newHOffset != null && hController.hasClients) {
        final clampedH = newHOffset.clamp(
          hController.position.minScrollExtent,
          hController.position.maxScrollExtent,
        );
        if ((clampedH - hController.offset).abs() > 0.5) {
          hController.jumpTo(clampedH);
        }
      }
    });
  }

  void _applyScrollAdjustment(FolderViewContent<T> oldWidget) {
    // Case 1: Incremental single-node change
    final changedIndex = widget.scrollChangedIndex;
    final deltaItems = widget.scrollDeltaItems;
    if (changedIndex >= 0 && deltaItems != 0) {
      final controller = widget.verticalController;
      if (!controller.hasClients) return;

      final itemExtent = widget.theme.rowHeight + widget.theme.rowSpacing;
      final topPadding = widget.theme.spacingTheme.contentPadding.top;
      final changePixel = topPadding + (changedIndex + 1) * itemExtent;

      if (changePixel <= controller.offset) {
        final delta = deltaItems * itemExtent;
        final newOffset = (controller.offset + delta).clamp(
          controller.position.minScrollExtent,
          controller.position.maxScrollExtent,
        );
        controller.jumpTo(newOffset);
      }
      return;
    }

    // Case 2: Bulk change (e.g., expandAll / collapseAll)
    // Anchor the viewport to the same node that was at the top.
    if (identical(oldWidget.flatNodes, widget.flatNodes)) return;
    if (oldWidget.flatNodes.isEmpty || widget.flatNodes.isEmpty) return;

    final controller = widget.verticalController;
    if (!controller.hasClients) return;

    final itemExtent = widget.theme.rowHeight + widget.theme.rowSpacing;
    final topPadding = widget.theme.spacingTheme.contentPadding.top;

    // Identify the node at the top of the viewport in the old list.
    final scrollOffset = controller.offset;
    final topIndex = ((scrollOffset - topPadding) / itemExtent)
        .floor()
        .clamp(0, oldWidget.flatNodes.length - 1);

    // Find an anchor node that exists in the new list.
    // Start with the top visible node; if it's gone (e.g., a child removed
    // by collapseAll), walk backwards to find its nearest ancestor.
    int newIndex = -1;
    double anchorPixelOffset =
        scrollOffset - (topPadding + topIndex * itemExtent);
    for (int i = topIndex; i >= 0; i--) {
      newIndex = widget.flatNodes
          .indexWhere((fn) => fn.node.id == oldWidget.flatNodes[i].node.id);
      if (newIndex >= 0) {
        // If we fell back to an ancestor, reset the sub-pixel offset.
        if (i != topIndex) anchorPixelOffset = 0.0;
        break;
      }
    }
    if (newIndex < 0) return;

    final targetOffset = topPadding + newIndex * itemExtent + anchorPixelOffset;

    // Compute expected maxScrollExtent for the new list so we can clamp
    // without waiting for layout (avoids one-frame flicker).
    final bottomPadding = widget.theme.spacingTheme.contentPadding.bottom;
    final newContentHeight = SizeService.calculateContentHeight(
      itemCount: widget.flatNodes.length,
      rowHeight: widget.theme.rowHeight,
      rowSpacing: widget.theme.rowSpacing,
      topPadding: topPadding,
      bottomPadding: bottomPadding,
    );
    final viewportHeight = controller.position.viewportDimension;
    final newMaxExtent = (newContentHeight - viewportHeight).clamp(
      0.0,
      double.infinity,
    );
    final clamped = targetOffset.clamp(0.0, newMaxExtent);

    if ((clamped - scrollOffset).abs() > 0.5) {
      controller.jumpTo(clamped);

      // The scrollbar controller's maxScrollExtent hasn't updated yet,
      // so the sync listener clamped it to a stale range.
      // Re-sync after layout when both controllers have correct extents.
      final barController = widget.verticalBarController;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.hasClients && barController.hasClients) {
          final target = controller.offset.clamp(
            barController.position.minScrollExtent,
            barController.position.maxScrollExtent,
          );
          barController.jumpTo(target);
        }
      });
    }
  }

  @override
  void dispose() {
    widget.horizontalController.removeListener(_onHorizontalScroll);
    _isHover.dispose();
    _horizontalOffset.dispose();
    super.dispose();
  }

  void _onHorizontalScroll() {
    final offset = widget.horizontalController.offset;
    if (offset != _horizontalOffset.value) {
      _horizontalOffset.value = offset;
    }
  }

  Widget _buildItem(int index) {
    final flatNode = widget.flatNodes[index];
    final isExpanded =
        widget.expandedNodeIds?.contains(flatNode.node.id) ?? false;
    final theme = widget.theme;

    final nodeWidget = NodeWidget<T>(
      flatNode: flatNode,
      mode: widget.mode,
      onTap: widget.onNodeTap,
      onDoubleTap: widget.onDoubleNodeTap,
      onSecondaryTap: widget.onSecondaryNodeTap,
      selectedNodeIds: widget.selectedNodeIds,
      isExpanded: isExpanded,
      theme: theme,
      scale: widget.scale,
    );

    // Apply horizontal offset via Transform.translate instead of
    // wrapping the entire ListView in a SingleChildScrollView.
    // This preserves ListView virtualization completely.
    // ValueListenableBuilder ensures only individual items rebuild on scroll,
    // not the entire widget tree.
    // Apply horizontal offset via Transform.translate instead of
    // wrapping the entire ListView in a SingleChildScrollView.
    // This preserves ListView virtualization completely.
    if (!widget.needsHorizontalScroll) {
      return nodeWidget;
    }

    return ValueListenableBuilder<double>(
      valueListenable: _horizontalOffset,
      child: OverflowBox(
        alignment: Alignment.centerLeft,
        maxWidth: widget.contentWidth,
        minWidth: widget.contentWidth,
        child: SizedBox(
          width: widget.contentWidth,
          child: nodeWidget,
        ),
      ),
      builder: (context, offset, child) {
        if (offset == 0.0) return child!;
        return Transform.translate(
          offset: Offset(-offset, 0),
          child: child,
        );
      },
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
            physics: widget.blockCtrlScroll
                ? const _ModifierKeyAwareScrollPhysics()
                : null,
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
      onEnter: (_) => _isHover.value = true,
      onExit: (_) => _isHover.value = false,
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

            /// Vertical scrollbar — only rebuilds when hover state changes
            if (widget.needsVerticalScroll)
              ValueListenableBuilder<bool>(
                valueListenable: _isHover,
                builder: (context, isHover, _) => FolderViewVerticalScrollbar(
                  isHover: isHover,
                  verticalScrollbarController: widget.verticalBarController,
                  contentHeight: widget.contentHeight,
                  needsHorizontalScroll: widget.needsHorizontalScroll,
                  scrollbarTheme: widget.theme.scrollbarTheme,
                ),
              ),

            /// Horizontal scrollbar — only rebuilds when hover state changes
            if (widget.needsHorizontalScroll)
              ValueListenableBuilder<bool>(
                valueListenable: _isHover,
                builder: (context, isHover, _) => FolderViewHorizontalScrollbar(
                  isHover: isHover,
                  horizontalScrollbarController: widget.horizontalBarController,
                  contentWidth: widget.contentWidth,
                  scrollbarTheme: widget.theme.scrollbarTheme,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Scroll physics that ignores scroll events when Ctrl (Windows/Linux)
/// or Cmd (macOS) is pressed, allowing those events to be used for
/// zoom/scale instead.
class _ModifierKeyAwareScrollPhysics extends ScrollPhysics {
  const _ModifierKeyAwareScrollPhysics({super.parent});

  @override
  _ModifierKeyAwareScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _ModifierKeyAwareScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    if (HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed) {
      return false;
    }
    return super.shouldAcceptUserOffset(position);
  }
}
