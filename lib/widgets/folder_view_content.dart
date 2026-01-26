// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../models/node.dart';
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

  final List<Node<T>> data;
  final ViewMode mode;
  final Function(Node<T>)? onNodeTap;
  final Function(Node<T>)? onDoubleNodeTap;
  final Function(Node<T>, TapDownDetails)? onSecondaryNodeTap;
  final Set<String>? selectedNodeIds;
  final FlutterFolderViewTheme<T> theme;

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
    required this.data,
    required this.mode,
    required this.onNodeTap,
    this.onDoubleNodeTap,
    this.onSecondaryNodeTap,
    required this.selectedNodeIds,
    required this.theme,
  });

  @override
  State<FolderViewContent<T>> createState() => _FolderViewContentState<T>();
}

class _FolderViewContentState<T> extends State<FolderViewContent<T>> {
  bool _isHover = false;
  final GlobalKey _listViewKey = GlobalKey();

  /// Build the ListView
  Widget _buildListView({
    required List<Node<T>> data,
    required ViewMode mode,
    required Function(Node<T>)? onNodeTap,
    required Function(Node<T>)? onDoubleNodeTap,
    required Function(Node<T>, TapDownDetails)? onSecondaryNodeTap,
    required Set<String>? selectedNodeIds,
    required ScrollController horizontalController,
    required ScrollController verticalController,
    required double contentWidth,
    required double viewportWidth,
    required bool needsHorizontalScroll,
    required FlutterFolderViewTheme<T> theme,
  }) {
    final Widget listView = Column(
      children: [
        Expanded(
          child: ListView.builder(
            key: _listViewKey,
            controller: verticalController,
            padding: theme.spacingTheme.contentPadding,
            itemCount: data.length,
            itemBuilder: (context, index) {
              return NodeWidget<T>(
                node: data[index],
                mode: mode,
                onTap: onNodeTap,
                onDoubleTap: onDoubleNodeTap,
                onSecondaryTap: onSecondaryNodeTap,
                isLast: index == data.length - 1,
                isRoot: true,
                selectedNodeIds: selectedNodeIds,
                theme: theme,
              );
            },
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
              data: widget.data,
              mode: widget.mode,
              onNodeTap: widget.onNodeTap,
              onDoubleNodeTap: widget.onDoubleNodeTap,
              onSecondaryNodeTap: widget.onSecondaryNodeTap,
              selectedNodeIds: widget.selectedNodeIds,
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
