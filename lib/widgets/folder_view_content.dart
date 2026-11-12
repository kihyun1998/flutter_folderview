// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:just_tooltip/just_tooltip.dart';

import '../input/scale_modifier.dart';
import '../models/flat_node.dart';
import '../models/node.dart';
import '../services/flattener.dart';
import '../services/scroll_anchor.dart';
import '../themes/flutter_folder_view_theme.dart';
import '../themes/row_tooltip_theme.dart';
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

  /// Styles the row card. See `FolderView.rowTooltipTheme`.
  final RowTooltipTheme? rowTooltipTheme;

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
    this.rowTooltipTheme,
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

  /// Whether a drag runs on the vertical scrollbar: set by a scroll start or
  /// update that carries drag details, cleared by one that does not (a fling,
  /// a track tap's animation, a jump) and by a scroll end.
  bool _barDragging = false;

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

    // Rows added or removed above the view move it in the Scale it was laid
    // out in; a Scale change then maps that offset into the new one and clamps
    // it to the end.
    final scaleChanged = oldWidget.scale != widget.scale;
    final rowsOffset = scaleChanged
        ? _rowsAnchorOffset(oldWidget, oldWidget.theme, double.infinity)
        : _rowsAnchorOffset(oldWidget, widget.theme, widget.contentHeight);
    if (scaleChanged) {
      _applyScaleAdjustment(oldWidget, rowsOffset);
    } else if (rowsOffset != null) {
      _anchorTo(rowsOffset);
    }
  }

  /// Moves the view after a Scale change, keeping the row at its top.
  ///
  /// The vertical mapping starts from [rowsOffset], the offset the rows added
  /// or removed in the same update put the view at in the old Scale, or from
  /// the current offset when there is none.
  void _applyScaleAdjustment(
    FolderViewContent<T> oldWidget,
    double? rowsOffset,
  ) {
    final controller = widget.verticalController;
    if (!controller.hasClients) return;

    final hController = widget.horizontalController;
    final oldItemExtent =
        oldWidget.theme.rowHeight + oldWidget.theme.rowSpacing;
    final newItemExtent = widget.theme.rowHeight + widget.theme.rowSpacing;
    final oldTopPadding = oldWidget.theme.spacingTheme.contentPadding.top;
    final newTopPadding = widget.theme.spacingTheme.contentPadding.top;
    final currentV = rowsOffset ?? controller.offset;
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
        hMinScrollExtent: hController.hasClients
            ? hController.position.minScrollExtent
            : 0.0,
        hMaxScrollExtent: hController.hasClients
            ? hController.position.maxScrollExtent
            : 0.0,
      );

      final vertical = result.vertical ?? rowsOffset;
      if (vertical != null) controller.jumpTo(vertical);

      if (result.horizontal != null && hController.hasClients) {
        hController.jumpTo(result.horizontal!);
      }
    });
  }

  /// The offset that keeps the rows in view still across rows added or removed
  /// above the view in this update, in the Scale of [theme] and clamped to the
  /// end of [newContentHeight], or null when nothing above the view changed.
  double? _rowsAnchorOffset(
    FolderViewContent<T> oldWidget,
    FlutterFolderViewTheme<T> theme,
    double newContentHeight,
  ) {
    final controller = widget.verticalController;
    final itemExtent = theme.rowHeight + theme.rowSpacing;
    final topPadding = theme.spacingTheme.contentPadding.top;

    // Case 1: incremental single-node change, applied in the update that
    // brought it.
    final change = widget.change;
    if (change != null && change.deltaItems != 0) {
      if (identical(oldWidget.change, change)) return null;
      if (!controller.hasClients) return null;
      return ScrollAnchor.verticalOffsetForFlattenChange(
        change: change,
        currentOffset: controller.offset,
        itemExtent: itemExtent,
        topPadding: topPadding,
        newContentHeight: newContentHeight,
        viewportHeight: controller.position.viewportDimension,
      );
    }

    // Case 2: bulk change (e.g., expandAll / collapseAll).
    if (identical(oldWidget.flatNodes, widget.flatNodes)) return null;
    if (oldWidget.flatNodes.isEmpty || widget.flatNodes.isEmpty) return null;
    if (!controller.hasClients) return null;

    return ScrollAnchor.verticalOffsetForBulkChange<T>(
      oldList: oldWidget.flatNodes,
      newList: widget.flatNodes,
      currentOffset: controller.offset,
      itemExtent: itemExtent,
      topPadding: topPadding,
      newContentHeight: newContentHeight,
      viewportHeight: controller.position.viewportDimension,
    );
  }

  /// Moves the view to [offset] for rows added or removed above it.
  ///
  /// While the vertical scrollbar is dragged, the body and the scrollbar are
  /// both corrected by their difference to [offset], and the drag goes on.
  /// While a user's scroll runs on the body (a wheel motion, a drag or a
  /// fling), the body is corrected by the difference, so that scroll goes on
  /// from the new offset; a wheel motion's target moves with it. Otherwise the
  /// body jumps, and the scrollbar follows it.
  void _anchorTo(double offset) {
    final body = widget.verticalController.position;
    final bar = widget.verticalBarController;
    if (_barDragging && bar.hasClients) {
      for (final position in [body, bar.position]) {
        position.correctBy(offset - position.pixels);
      }
    } else if (body.userScrollDirection != ScrollDirection.idle) {
      body.correctBy(offset - body.pixels);
    } else {
      body.jumpTo(offset);
    }
  }

  /// Follows whether a drag runs on the vertical scrollbar, from the scroll
  /// notifications of its scroll view.
  bool _onVerticalBarScroll(ScrollNotification notification) {
    _barDragging = switch (notification) {
      ScrollStartNotification(:final dragDetails) => dragDetails != null,
      ScrollUpdateNotification(:final dragDetails) => dragDetails != null,
      ScrollEndNotification() => false,
      _ => _barDragging,
    };
    return false;
  }

  /// The index of the row keyed by a Node id.
  int? _indexOfRow(Key key) {
    final id = (key as ValueKey<String>).value;
    final index = widget.flatNodes.indexWhere((flat) => flat.node.id == id);
    return index < 0 ? null : index;
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
  /// suppresses an ancestor whenever a descendant tooltip that has something to
  /// draw contains the pointer, so exactly one is visible: the innermost under
  /// the cursor. Neither of ours is ever empty — a Node with no label tooltip
  /// content is not wrapped at all, and nor is a row whose builder returns
  /// `null` — so the innermost under the cursor is simply the innermost.
  ///
  /// Everything else comes from `FolderView.rowTooltipTheme`, whose surface
  /// defaults to [JustTooltipTheme.bare] because a card draws its own.
  ///
  /// The anchor is the one knob the theme does not expose: it is always the
  /// pointer, for the reason above.
  Widget _wrapWithRowTooltip(Widget row, Node<T> node) {
    final builder = widget.rowTooltipBuilder;
    if (builder == null) return row;
    final card = builder(context, node);
    if (card == null) return row;

    final t = widget.rowTooltipTheme ?? const RowTooltipTheme();
    return JustTooltip(
      anchor: TooltipAnchor.pointer,
      direction: t.direction,
      alignment: t.alignment,
      offset: t.offset,
      crossAxisOffset: t.crossAxisOffset,
      screenMargin: t.screenMargin,
      theme: t.surface,
      interactive: t.interactive,
      waitDuration: t.waitDuration,
      showDuration: t.showDuration,
      enableHover: t.enableHover,
      animation: t.animation,
      animationCurve: t.animationCurve,
      animationDuration: t.animationDuration,
      fadeBegin: t.fadeBegin,
      scaleBegin: t.scaleBegin,
      slideOffset: t.slideOffset,
      rotationBegin: t.rotationBegin,
      onShow: t.onShow,
      onHide: t.onHide,
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
    if (!widget.needsHorizontalScroll) {
      return nodeWidget;
    }

    final row = SizedBox(width: widget.contentWidth, child: nodeWidget);
    return OverflowBox(
      alignment: Alignment.centerLeft,
      maxWidth: widget.contentWidth,
      minWidth: widget.contentWidth,
      child: ValueListenableBuilder<double>(
        valueListenable: _horizontalOffset,
        child: row,
        builder: (context, offset, child) =>
            Transform.translate(offset: Offset(-offset, 0), child: child),
      ),
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
            itemBuilder: (context, index) => KeyedSubtree(
              key: ValueKey<String>(widget.flatNodes[index].node.id),
              child: _buildItem(index),
            ),
            findChildIndexCallback: _indexOfRow,
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
                child: NotificationListener<ScrollMetricsNotification>(
                  onNotification: (_) {
                    _onHorizontalScroll();
                    return false;
                  },
                  child: SingleChildScrollView(
                    controller: widget.horizontalController,
                    scrollDirection: Axis.horizontal,
                    physics: widget.blockModifierScroll
                        ? const _ModifierKeyAwareScrollPhysics()
                        : null,
                    child: SizedBox(width: widget.contentWidth),
                  ),
                ),
              ),

              /// Vertical scrollbar — only rebuilds when hover state changes
              if (widget.needsVerticalScroll)
                NotificationListener<ScrollNotification>(
                  key: const ValueKey(Axis.vertical),
                  onNotification: _onVerticalBarScroll,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _isHover,
                    builder: (context, isHover, _) =>
                        FolderViewVerticalScrollbar(
                          isHover: isHover,
                          verticalScrollbarController:
                              widget.verticalBarController,
                          contentHeight: widget.contentHeight,
                          needsHorizontalScroll: widget.needsHorizontalScroll,
                          scrollbarTheme: widget.theme.scrollbarTheme,
                        ),
                  ),
                ),

              /// Horizontal scrollbar — only rebuilds when hover state changes
              if (widget.needsHorizontalScroll)
                ValueListenableBuilder<bool>(
                  key: const ValueKey(Axis.horizontal),
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
