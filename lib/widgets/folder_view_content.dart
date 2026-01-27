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
  });

  @override
  State<FolderViewContent<T>> createState() => _FolderViewContentState<T>();
}

class _FolderViewContentState<T> extends State<FolderViewContent<T>> {
  bool _isHover = false;
  final GlobalKey _listViewKey = GlobalKey();

  /// Build the ListView from flat nodes
  Widget _buildListView({
    required List<FlatNode<T>> flatNodes,
    required ViewMode mode,
    required Function(Node<T>)? onNodeTap,
    required Function(Node<T>)? onDoubleNodeTap,
    required Function(Node<T>, TapDownDetails)? onSecondaryNodeTap,
    required Set<String>? selectedNodeIds,
    required Set<String>? expandedNodeIds,
    required ScrollController horizontalController,
    required ScrollController verticalController,
    required double contentWidth,
    required double viewportWidth,
    required bool needsHorizontalScroll,
    required FlutterFolderViewTheme<T> theme,
  }) {
    Widget buildItem(int index) {
      final flatNode = flatNodes[index];
      final isExpanded =
          expandedNodeIds?.contains(flatNode.node.id) ?? false;

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

      return NodeWidget<T>(
        flatNode: flatNode,
        mode: mode,
        onTap: onNodeTap,
        onDoubleTap: onDoubleNodeTap,
        onSecondaryTap: onSecondaryNodeTap,
        selectedNodeIds: selectedNodeIds,
        isExpanded: isExpanded,
        theme: theme,
      );
    }

    final Widget listView = Column(
      children: [
        Expanded(
          child: theme.rowSpacing > 0
              ? ListView.separated(
                  key: _listViewKey,
                  controller: verticalController,
                  padding: theme.spacingTheme.contentPadding,
                  itemCount: flatNodes.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: theme.rowSpacing),
                  itemBuilder: (context, index) => buildItem(index),
                )
              : ListView.builder(
                  key: _listViewKey,
                  controller: verticalController,
                  padding: theme.spacingTheme.contentPadding,
                  itemCount: flatNodes.length,
                  itemBuilder: (context, index) => buildItem(index),
                ),
        ),
        // Only add spacing when horizontal scrollbar is actually needed
        if (needsHorizontalScroll)
          SizedBox(height: theme.scrollbarTheme.trackWidth),
      ],
    );

    // Always wrap in SingleChildScrollView to maintain tree stability
    return SingleChildScrollView(
      controller: horizontalController,
      scrollDirection: Axis.horizontal,
      physics: needsHorizontalScroll
          ? const ClampingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      child: SizedBox(
        width: needsHorizontalScroll ? contentWidth : viewportWidth,
        child: listView,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHover = true),
      onExit: (_) => setState(() => _isHover = false),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: Stack(
          children: [
            _buildListView(
              flatNodes: widget.flatNodes,
              mode: widget.mode,
              onNodeTap: widget.onNodeTap,
              onDoubleNodeTap: widget.onDoubleNodeTap,
              onSecondaryNodeTap: widget.onSecondaryNodeTap,
              selectedNodeIds: widget.selectedNodeIds,
              expandedNodeIds: widget.expandedNodeIds,
              horizontalController: widget.horizontalController,
              verticalController: widget.verticalController,
              contentWidth: widget.contentWidth,
              viewportWidth: widget.viewportWidth,
              needsHorizontalScroll: widget.needsHorizontalScroll,
              theme: widget.theme,
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
