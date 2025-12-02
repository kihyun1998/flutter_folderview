import 'package:flutter/material.dart';

import '../models/node.dart';
import '../services/size_service.dart';
import 'folder_view_content.dart';
import 'synced_scroll_controllers.dart';

class FolderView<T> extends StatelessWidget {
  final List<Node<T>> data;
  final ViewMode mode;
  final Function(Node<T>)? onNodeTap;
  final Set<String>? selectedNodeIds;
  final LineStyle lineStyle;

  const FolderView({
    super.key,
    required this.data,
    required this.mode,
    this.onNodeTap,
    this.selectedNodeIds,
    this.lineStyle = LineStyle.connector,
  });

  @override
  Widget build(BuildContext context) {
    // Filter data based on mode
    List<Node<T>> displayNodes = _getDisplayNodes();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableHeight = constraints.maxHeight;
        final double availableWidth = constraints.maxWidth;

        // Default text style for measurement
        final textStyle = const TextStyle(fontSize: 14);

        // Calculate content dimensions
        final contentWidth = SizeService.calculateContentWidth(
          nodes: displayNodes,
          textStyle: textStyle,
          maxWidth: availableWidth * 3, // Allow up to 3x viewport width
        );

        final contentHeight = SizeService.calculateContentHeight(
          nodes: displayNodes,
          rowHeight: 40.0,
        );

        final needsHorizontalScroll = contentWidth > availableWidth;
        final needsVerticalScroll = contentHeight > availableHeight;

        return SyncedScrollControllers(
          builder: (context, verticalController, verticalScrollbarController,
              horizontalController, horizontalScrollbarController) {
            return FolderViewContent<T>(
              data: displayNodes,
              mode: mode,
              onNodeTap: onNodeTap,
              selectedNodeIds: selectedNodeIds,
              contentWidth: contentWidth,
              contentHeight: contentHeight,
              needsHorizontalScroll: needsHorizontalScroll,
              needsVerticalScroll: needsVerticalScroll,
              horizontalController: horizontalController!,
              verticalController: verticalController!,
              horizontalBarController: horizontalScrollbarController!,
              verticalBarController: verticalScrollbarController!,
              lineStyle: lineStyle,
            );
          },
        );
      },
    );
  }

  List<Node<T>> _getDisplayNodes() {
    if (mode == ViewMode.tree) {
      // In Tree Mode, we only show Parent nodes at the root level (and their children when expanded)
      // Assuming the input 'data' contains all root nodes.
      // If the input data is mixed, we might need to filter.
      // Based on requirements: "Tree mode: Parent > Child only. No Parent of Parent."
      // So we expect the root list to contain Parent nodes.
      return data.where((n) => n.type == NodeType.parent).toList();
    } else {
      // In Folder Mode, we show Folders and Parents at the root level.
      // "Folder mode: Folder > Parent > Child. Parent of Parent is Folder."
      return data
          .where((n) => n.type == NodeType.folder || n.type == NodeType.parent)
          .toList();
    }
  }
}
