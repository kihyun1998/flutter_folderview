import 'package:flutter/material.dart';

import '../models/flat_node.dart';
import '../models/node.dart';
import '../services/row_metrics.dart';
import '../themes/flutter_folder_view_theme.dart';
import 'child_node_renderer.dart';
import 'expandable_node_renderer.dart';
import 'tree_lines.dart';

/// A single-row widget for a flattened tree node.
///
/// Owns the tier-agnostic scaffold (row height, tree lines, indent) and
/// dispatches the row content to a tier renderer exactly once, based on
/// `flatNode.node.type`.
class NodeWidget<T> extends StatelessWidget {
  final FlatNode<T> flatNode;
  final ViewMode mode;
  final Function(Node<T>)? onTap;
  final Function(Node<T>)? onDoubleTap;
  final Function(Node<T>, TapDownDetails)? onSecondaryTap;
  final Set<String>? selectedNodeIds;
  final bool isExpanded;
  final FlutterFolderViewTheme<T> theme;
  final double scale;

  const NodeWidget({
    super.key,
    required this.flatNode,
    required this.mode,
    this.onTap,
    this.onDoubleTap,
    this.onSecondaryTap,
    this.selectedNodeIds,
    required this.isExpanded,
    required this.theme,
    this.scale = 1.0,
  });

  Node<T> get node => flatNode.node;

  /// Single source of truth for row geometry and text style, shared with the
  /// width measurement path (see [RowMetrics]).
  RowMetrics<T> get _metrics => RowMetrics<T>(theme: theme);

  @override
  Widget build(BuildContext context) {
    final metrics = _metrics;
    final lineWidth = metrics.expandStripWidth;

    return SizedBox(
      height: theme.rowHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Tier-agnostic scaffold: tree lines behind, indent spacer, content.
          if (theme.lineTheme.lineStyle != LineStyle.none)
            Positioned.fill(
              child: TreeLines(
                flatNode: flatNode,
                lineTheme: theme.lineTheme,
                rowHeight: theme.rowHeight,
                lineWidth: lineWidth,
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: flatNode.depth * lineWidth),
              Expanded(child: _content(metrics)),
            ],
          ),
        ],
      ),
    );
  }

  /// Dispatches the row content to the matching tier renderer. This is the one
  /// and only switch on tier; each renderer is tier-fixed and switch-free.
  Widget _content(RowMetrics<T> metrics) {
    switch (node.type) {
      case NodeType.child:
        return ChildNodeRenderer<T>(
          flatNode: flatNode,
          metrics: metrics,
          selectedNodeIds: selectedNodeIds,
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          onSecondaryTap: onSecondaryTap,
          scale: scale,
        );
      case NodeType.folder:
        return ExpandableNodeRenderer<T>(
          flatNode: flatNode,
          metrics: metrics,
          themeView: theme.folderTheme,
          useOpenState: true,
          isExpanded: isExpanded,
          onTap: onTap,
          scale: scale,
        );
      case NodeType.parent:
        return ExpandableNodeRenderer<T>(
          flatNode: flatNode,
          metrics: metrics,
          themeView: theme.parentTheme,
          useOpenState: mode == ViewMode.tree,
          isExpanded: isExpanded,
          onTap: onTap,
          scale: scale,
        );
    }
  }
}
