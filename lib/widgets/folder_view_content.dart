// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:just_tooltip/just_tooltip.dart';

import '../input/scale_modifier.dart';
import '../models/flat_node.dart';
import '../models/node.dart';
import '../services/flattener.dart';
import '../services/scroll_anchor.dart';
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

  final List<FlatNode<T>> flatNodes;
  final ViewMode mode;
  final Function(Node<T>)? onNodeTap;
  final Function(Node<T>)? onDoubleNodeTap;
  final Function(Node<T>, TapDownDetails)? onSecondaryNodeTap;
  final Set<String>? selectedNodeIds;
  final Set<String>? expandedNodeIds;

  /// Builds the row card. See `FolderView.rowTooltipBuilder`.
  final Widget? Function(BuildContext context, Node<T> node)? rowTooltipBuilder;

  final FlutterFolderViewTheme<T> theme;

  /// Scale factor applied to content dimensions.
  final double scale;

  /// When `true`, normal scrolling is blocked while Ctrl/Cmd is held.
  final bool blockModifierScroll;

  /// Incremental single-node change from the Flattener, or null for a full
  /// rebuild / no change. Drives the scroll anchor.
  final FlattenChange? change;

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
    required this.flatNodes,
    required this.mode,
    required this.onNodeTap,
    this.onDoubleNodeTap,
    this.onSecondaryNodeTap,
    required this.selectedNodeIds,
    this.expandedNodeIds,
    this.rowTooltipBuilder,
    required this.theme,
    this.scale = 1.0,
    this.blockModifierScroll = true,
    this.change,
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

    final hController = widget.horizontalController;
    final barController = widget.verticalBarController;
    final oldItemExtent =
        oldWidget.theme.rowHeight + oldWidget.theme.rowSpacing;
    final newItemExtent = widget.theme.rowHeight + widget.theme.rowSpacing;
    final oldTopPadding = oldWidget.theme.spacingTheme.contentPadding.top;
    final newTopPadding = widget.theme.spacingTheme.contentPadding.top;
    final currentV = controller.offset;
    final currentH = hController.hasClients ? hController.offset : null;
    final oldContentWidth = oldWidget.contentWidth;
    final newContentWidth = widget.contentWidth;
    final contentHeight = widget.contentHeight;

    // Defer jumpTo to after the build phase to avoid setState-during-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.hasClients) return;

      final result = ScrollAnchor.offsetsForScaleChange(
        currentVerticalOffset: currentV,
        oldItemExtent: oldItemExtent,
        newItemExtent: newItemExtent,
        oldTopPadding: oldTopPadding,
        newTopPadding: newTopPadding,
        newContentHeight: contentHeight,
        viewportHeight: controller.position.viewportDimension,
        currentHorizontalOffset: currentH,
        oldContentWidth: oldContentWidth,
        newContentWidth: newContentWidth,
        hMinScrollExtent:
            hController.hasClients ? hController.position.minScrollExtent : 0.0,
        hMaxScrollExtent:
            hController.hasClients ? hController.position.maxScrollExtent : 0.0,
      );

      if (result.vertical != null) {
        controller.jumpTo(result.vertical!);
      }
      // Re-sync the vertical scrollbar even if the offset didn't move — the
      // scale change altered the scroll extent.
      if (barController.hasClients) {
        final target = controller.offset.clamp(
          barController.position.minScrollExtent,
          barController.position.maxScrollExtent,
        );
        barController.jumpTo(target);
      }

      if (result.horizontal != null && hController.hasClients) {
        hController.jumpTo(result.horizontal!);
      }
    });
  }

  void _applyScrollAdjustment(FolderViewContent<T> oldWidget) {
    final controller = widget.verticalController;
    final itemExtent = widget.theme.rowHeight + widget.theme.rowSpacing;
    final topPadding = widget.theme.spacingTheme.contentPadding.top;

    // Case 1: incremental single-node change.
    final change = widget.change;
    if (change != null && change.deltaItems != 0) {
      if (!controller.hasClients) return;
      final newOffset = ScrollAnchor.verticalOffsetForFlattenChange(
        change: change,
        currentOffset: controller.offset,
        itemExtent: itemExtent,
        topPadding: topPadding,
        minScrollExtent: controller.position.minScrollExtent,
        maxScrollExtent: controller.position.maxScrollExtent,
      );
      if (newOffset != null) controller.jumpTo(newOffset);
      return;
    }

    // Case 2: bulk change (e.g., expandAll / collapseAll).
    if (identical(oldWidget.flatNodes, widget.flatNodes)) return;
    if (oldWidget.flatNodes.isEmpty || widget.flatNodes.isEmpty) return;
    if (!controller.hasClients) return;

    final bottomPadding = widget.theme.spacingTheme.contentPadding.bottom;
    final newContentHeight = SizeService.calculateContentHeight(
      itemCount: widget.flatNodes.length,
      rowHeight: widget.theme.rowHeight,
      rowSpacing: widget.theme.rowSpacing,
      topPadding: topPadding,
      bottomPadding: bottomPadding,
    );

    final newOffset = ScrollAnchor.verticalOffsetForBulkChange<T>(
      oldList: oldWidget.flatNodes,
      newList: widget.flatNodes,
      currentOffset: controller.offset,
      itemExtent: itemExtent,
      topPadding: topPadding,
      newContentHeight: newContentHeight,
      viewportHeight: controller.position.viewportDimension,
    );

    if (newOffset != null) {
      controller.jumpTo(newOffset);

      // The scrollbar controller's maxScrollExtent hasn't updated yet; re-sync
      // after layout when both controllers have correct extents.
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

  /// Wraps a rendered row in its row card, when the caller supplies one.
  ///
  /// The row is the hover region; the pointer is the anchor. A row's RenderBox
  /// is `contentWidth` wide, so anchoring to it would aim at its centre — off
  /// screen once the view scrolls horizontally.
  ///
  /// A Node's label tooltip, if any, is nested inside this one. `just_tooltip`
  /// suppresses an ancestor whenever a descendant tooltip contains the pointer,
  /// so exactly one is visible: the innermost under the cursor.
  ///
  /// The card draws its own surface, so the tooltip contributes no background,
  /// padding, or elevation.
  Widget _wrapWithRowTooltip(Widget row, Node<T> node) {
    final builder = widget.rowTooltipBuilder;
    if (builder == null) return row;
    final card = builder(context, node);
    if (card == null) return row;

    return JustTooltip(
      anchor: TooltipAnchor.pointer,
      theme: const JustTooltipTheme.bare(),
      tooltipBuilder: (_) => card,
      child: row,
    );
  }

  Widget _buildItem(int index) {
    final flatNode = widget.flatNodes[index];
    final isExpanded =
        widget.expandedNodeIds?.contains(flatNode.node.id) ?? false;
    final theme = widget.theme;

    Widget nodeWidget = NodeWidget<T>(
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

    nodeWidget = _wrapWithRowTooltip(nodeWidget, flatNode.node);

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
            physics: widget.blockModifierScroll
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

    // The single shared ink surface for every row. Rows (CustomInkWell) no
    // longer carry their own Material — they paint onto this one ancestor.
    // Transparent so it contributes no background/elevation of its own; it
    // exists purely to host InkWell splashes/highlights. This is the other
    // half of the per-row-Material removal and must not be dropped, or Ink in
    // the rows will assert for lack of a Material ancestor.
    return Material(
      type: MaterialType.transparency,
      child: MouseRegion(
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
                  builder: (context, isHover, _) =>
                      FolderViewHorizontalScrollbar(
                    isHover: isHover,
                    horizontalScrollbarController:
                        widget.horizontalBarController,
                    contentWidth: widget.contentWidth,
                    scrollbarTheme: widget.theme.scrollbarTheme,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Scroll physics that ignores scroll events when the scale-modifier key
/// (Ctrl on Windows/Linux, Cmd on macOS) is pressed, allowing those events
/// to be used for zoom/scale instead.
class _ModifierKeyAwareScrollPhysics extends ScrollPhysics {
  const _ModifierKeyAwareScrollPhysics({super.parent});

  @override
  _ModifierKeyAwareScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _ModifierKeyAwareScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    if (isScaleModifierPressed()) return false;
    return super.shouldAcceptUserOffset(position);
  }
}
