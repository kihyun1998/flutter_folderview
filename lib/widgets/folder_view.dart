import 'package:flutter/material.dart';

import '../models/node.dart';
import '../services/size_service.dart';
import '../themes/flutter_folder_view_theme.dart';
import '../themes/folder_view_theme.dart';
import 'folder_view_content.dart';
import 'synced_scroll_controllers.dart';

class FolderView<T> extends StatelessWidget {
  final List<Node<T>> data;
  final ViewMode mode;
  final Function(Node<T>)? onNodeTap;
  final Function(Node<T>)? onDoubleNodeTap;
  final Function(Node<T>, TapDownDetails)? onSecondaryNodeTap;
  final Set<String>? selectedNodeIds;
  final FlutterFolderViewTheme? theme;

  const FolderView({
    super.key,
    required this.data,
    required this.mode,
    this.onNodeTap,
    this.onDoubleNodeTap,
    this.onSecondaryNodeTap,
    this.selectedNodeIds,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // Resolve theme: use provided theme, or get from context, or use default
    final effectiveTheme = theme ?? FolderViewTheme.of(context);

    // Filter data based on mode
    List<Node<T>> displayNodes = _getDisplayNodes();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableHeight = constraints.maxHeight;
        final double availableWidth = constraints.maxWidth;

        // Calculate content dimensions
        final contentWidth = SizeService.calculateContentWidth(
          nodes: displayNodes,
          textTheme: effectiveTheme.textTheme,
          iconSize: effectiveTheme.iconTheme.iconSize,
          leftPadding: effectiveTheme.spacingTheme.contentPadding.left,
          rightPadding: effectiveTheme.spacingTheme.contentPadding.right,
          maxWidth: availableWidth * 3, // Allow up to 3x viewport width
        );

        final contentHeight = SizeService.calculateContentHeight(
          nodes: displayNodes,
          rowHeight: 40.0,
          topPadding: effectiveTheme.spacingTheme.contentPadding.top,
          bottomPadding: effectiveTheme.spacingTheme.contentPadding.bottom,
        );

        final needsHorizontalScroll = contentWidth > availableWidth;
        final needsVerticalScroll = contentHeight > availableHeight;

        return SyncedScrollControllers(
          builder: (
            context,
            verticalController,
            verticalScrollbarController,
            horizontalController,
            horizontalScrollbarController,
          ) {
            return FolderViewContent<T>(
              data: displayNodes,
              mode: mode,
              onNodeTap: onNodeTap,
              onDoubleNodeTap: onDoubleNodeTap,
              onSecondaryNodeTap: onSecondaryNodeTap,
              selectedNodeIds: selectedNodeIds,
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
            );
          },
        );
      },
    );
  }

  List<Node<T>> _getDisplayNodes() {
    if (mode == ViewMode.tree) {
      // In Tree Mode, we only show Parent nodes at the root level
      // If data contains Folders, we need to extract Parents from within them
      List<Node<T>> parents = [];

      for (var node in data) {
        if (node.type == NodeType.parent) {
          // Direct parent node
          parents.add(node);
        } else if (node.type == NodeType.folder) {
          // Extract parent nodes from folder
          parents.addAll(
            node.children.where((child) => child.type == NodeType.parent),
          );
        }
      }

      return parents;
    } else {
      // In Folder Mode, we show Folders and Parents at the root level.
      // "Folder mode: Folder > Parent > Child. Parent of Parent is Folder."
      return data
          .where((n) => n.type == NodeType.folder || n.type == NodeType.parent)
          .toList();
    }
  }
}
