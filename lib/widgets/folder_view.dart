import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../input/scale_modifier.dart';
import '../models/flat_node.dart';
import '../models/node.dart';
import '../services/flattener.dart';
import '../services/row_metrics.dart';
import '../services/size_service.dart';
import '../themes/flutter_folder_view_theme.dart';
import '../themes/folder_view_theme.dart';
import '../themes/row_tooltip_theme.dart';
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

  /// Scale factor for the content (default 1.0).
  ///
  /// Scales all layout dimensions (row height, icon sizes, text size, spacing,
  /// line width, indentation) proportionally. Scrollbars are NOT scaled.
  final double scale;

  /// Callback fired when the user Ctrl+scrolls (or Cmd+scrolls on macOS)
  /// over the view, requesting a scale change.
  ///
  /// When non-null, the library intercepts modifier+wheel events internally
  /// and calls this callback with the proposed new scale value.
  ///
  /// The caller should update [scale] in response:
  /// ```dart
  /// onScaleChanged: (newScale) {
  ///   setState(() => _scale = newScale.clamp(0.5, 3.0));
  /// },
  /// ```
  ///
  /// When null, modifier+wheel events are not intercepted and scroll normally.
  final ValueChanged<double>? onScaleChanged;

  /// The amount [scale] changes per mouse wheel tick when [onScaleChanged]
  /// is active. Defaults to `0.05`.
  final double scaleStep;

  /// Whether to block normal scrolling while Ctrl (Windows/Linux) or
  /// Cmd (macOS) is held, so that those scroll events can be used for
  /// zoom/scale instead.
  ///
  /// Defaults to `null`, which follows [onScaleChanged]: blocking is enabled
  /// when [onScaleChanged] is non-null, and disabled otherwise.
  final bool? blockModifierScroll;

  /// Builds a card shown while the pointer is anywhere over a Node's rendered
  /// row. Return `null` for a Node that should not have one.
  ///
  /// Distinct from the per-Tier label tooltip on `NodeTooltipTheme`, which
  /// attaches to the Node's icon-and-label content and explains the label. This
  /// one attaches to the whole row and explains the Node.
  ///
  /// The card is anchored at the pointer: a row is as wide as the tree's
  /// content, which can exceed the viewport, so anchoring to the row's rect
  /// would aim at a centre that is off screen once the view scrolls
  /// horizontally.
  ///
  /// The card supplies its own surface, so the tooltip around it draws no
  /// background, padding, or elevation of its own.
  final Widget? Function(BuildContext context, Node<T> node)? rowTooltipBuilder;

  /// Presentation and behaviour for the card built by [rowTooltipBuilder].
  ///
  /// Null uses the defaults: shown immediately on hover, interactive, and
  /// drawing no surface of its own.
  final RowTooltipTheme? rowTooltipTheme;

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
    this.scale = 1.0,
    this.onScaleChanged,
    this.scaleStep = 0.05,
    this.blockModifierScroll,
    this.rowTooltipBuilder,
    this.rowTooltipTheme,
  }) : assert(scale > 0, 'scale must be greater than 0');

  @override
  State<FolderView<T>> createState() => _FolderViewState<T>();
}

class _FolderViewState<T> extends State<FolderView<T>> {
  /// Whether Ctrl/Cmd+wheel scrolling should be blocked.
  bool get _blockModifierScroll =>
      widget.blockModifierScroll ?? (widget.onScaleChanged != null);

  /// Owns the flat-list cache, the incremental-vs-rebuild decision, and the
  /// View Mode projection. Replaces the former widget-internal flatten cache
  /// and diff helpers.
  final Flattener<T> _flattener = Flattener<T>();

  /// Pre-calculated maximum content width from all nodes (including collapsed).
  /// Computed once when data changes, ensuring stable width.
  double _precomputedMaxWidth = 0.0;

  /// Whether the width has been computed for the current data.
  bool _widthComputed = false;

  @override
  void didUpdateWidget(covariant FolderView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset computed width when data, scale, or theme changes. Theme feeds
    // icon sizes, fonts and padding into the width measurement, so a new theme
    // must invalidate the precomputed width too (a different instance is
    // enough — callers own the theme and rebuild it deliberately).
    if (!identical(oldWidget.data, widget.data) ||
        oldWidget.scale != widget.scale ||
        !identical(oldWidget.theme, widget.theme)) {
      _widthComputed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Resolve theme: use provided theme, or get from context, or use default
    final effectiveTheme = widget.theme ?? FolderViewTheme.of<T>(context);

    // Apply scale to the theme. scrollbarTheme is preserved as-is (ADR-0001).
    // Each Theme owns its own scaling logic — see `Theme.scale(...)` methods.
    final scaledTheme = effectiveTheme.scaledForContext(context, widget.scale);

    // Project + flatten (memoized; incremental single-node updates when
    // possible). The Flattener owns the cache and change detection.
    final flattenResult = _flattener.update(
      data: widget.data,
      mode: widget.mode,
      expandedIds: widget.expandedNodeIds,
    );
    final List<FlatNode<T>> flatNodes = flattenResult.list;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableHeight = constraints.maxHeight;
        final double availableWidth = constraints.maxWidth;

        // Pre-compute max width from ALL nodes (including collapsed) once per data/scale change.
        if (!_widthComputed) {
          _precomputedMaxWidth = RowMetrics<T>(
            theme: scaledTheme,
            baseTextStyle: Theme.of(context).textTheme.bodyMedium,
          ).maxWidth(widget.data);
          _widthComputed = true;
        }

        // Clamp to a reasonable max (3× viewport). _precomputedMaxWidth is
        // already measured from the scaled theme, so the ceiling must not be
        // multiplied by scale again.
        final contentWidth = SizeService.clampContentWidth(
          contentWidth: _precomputedMaxWidth,
          viewportWidth: availableWidth,
        );

        final contentHeight = SizeService.calculateContentHeight(
          itemCount: flatNodes.length,
          rowHeight: scaledTheme.rowHeight,
          rowSpacing: scaledTheme.rowSpacing,
          topPadding: scaledTheme.spacingTheme.contentPadding.top,
          bottomPadding: scaledTheme.spacingTheme.contentPadding.bottom,
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
            final content = FolderViewContent<T>(
              flatNodes: flatNodes,
              mode: widget.mode,
              onNodeTap: widget.onNodeTap,
              onDoubleNodeTap: widget.onDoubleNodeTap,
              onSecondaryNodeTap: widget.onSecondaryNodeTap,
              selectedNodeIds: widget.selectedNodeIds,
              expandedNodeIds: widget.expandedNodeIds,
              rowTooltipBuilder: widget.rowTooltipBuilder,
              rowTooltipTheme: widget.rowTooltipTheme,
              contentWidth: contentWidth,
              contentHeight: contentHeight,
              needsHorizontalScroll: needsHorizontalScroll,
              needsVerticalScroll: needsVerticalScroll,
              horizontalController: horizontalController!,
              verticalController: verticalController!,
              horizontalBarController: horizontalScrollbarController!,
              verticalBarController: verticalScrollbarController!,
              theme: scaledTheme,
              scale: widget.scale,
              blockModifierScroll: _blockModifierScroll,
              change: flattenResult.change,
            );

            if (!_blockModifierScroll) return content;

            return Listener(
              onPointerSignal: _handlePointerSignalForScale,
              child: content,
            );
          },
        );
      },
    );
  }

  /// Intercept Ctrl+wheel (or Cmd+wheel on macOS) to change scale.
  void _handlePointerSignalForScale(PointerSignalEvent event) {
    if (event is PointerScrollEvent && isScaleModifierPressed()) {
      if (widget.onScaleChanged != null) {
        final delta =
            event.scrollDelta.dy > 0 ? -widget.scaleStep : widget.scaleStep;
        widget.onScaleChanged!(widget.scale + delta);
      }
    }
  }
}
