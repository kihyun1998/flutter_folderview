import 'package:flutter/material.dart';

import '../models/node.dart';
import '../themes/child_node_theme.dart';
import '../themes/expand_icon_theme.dart';
import '../themes/folder_node_theme.dart';
import '../themes/parent_node_theme.dart';

class SizeService {
  /// Calculate the total content width of all nodes
  static double calculateContentWidth<T>({
    required List<Node<T>> nodes,
    required FolderNodeTheme folderTheme,
    required ParentNodeTheme parentTheme,
    required ChildNodeTheme childTheme,
    required ExpandIconTheme expandIconTheme,
    double leftPadding = 0.0,
    double rightPadding = 16.0,
    double maxWidth = double.infinity,
  }) {
    // Calculate line width based on expand icon size
    final linePaintWidth = expandIconTheme.width +
        expandIconTheme.padding.horizontal +
        expandIconTheme.margin.horizontal;

    double maxNodeWidth = 0.0;

    for (var node in nodes) {
      final nodeWidth = _calculateNodeWidth(
        node: node,
        folderTheme: folderTheme,
        parentTheme: parentTheme,
        childTheme: childTheme,
        expandIconTheme: expandIconTheme,
        depth: 0,
        linePaintWidth: linePaintWidth,
        rightPadding: rightPadding,
      );
      if (nodeWidth > maxNodeWidth) {
        maxNodeWidth = nodeWidth;
      }

      // Recursively check children if expanded
      if (node.isExpanded && node.children.isNotEmpty) {
        final childrenWidth = calculateContentWidth(
          nodes: node.children,
          folderTheme: folderTheme,
          parentTheme: parentTheme,
          childTheme: childTheme,
          expandIconTheme: expandIconTheme,
          leftPadding: 0.0, // Children don't need extra left padding
          rightPadding: rightPadding,
          maxWidth: maxWidth,
        );
        // Add one level of indentation for children
        final adjustedChildWidth = childrenWidth + linePaintWidth;
        if (adjustedChildWidth > maxNodeWidth) {
          maxNodeWidth = adjustedChildWidth;
        }
      }
    }

    // Add left and right padding to the final width
    final totalWidth = leftPadding + maxNodeWidth;
    return totalWidth.clamp(0.0, maxWidth);
  }

  /// Calculate the width of a single node
  static double _calculateNodeWidth<T>({
    required Node<T> node,
    required FolderNodeTheme folderTheme,
    required ParentNodeTheme parentTheme,
    required ChildNodeTheme childTheme,
    required ExpandIconTheme expandIconTheme,
    required int depth,
    required double linePaintWidth,
    required double rightPadding,
  }) {
    // Base indent (pipeline spacing)
    double width = linePaintWidth;

    // Expand/collapse icon (or space)
    width += expandIconTheme.width +
        expandIconTheme.padding.horizontal +
        expandIconTheme.margin.horizontal;

    // Node icon and spacing based on node type
    double iconWidth;
    double iconToTextSpacing;
    TextStyle? textStyle;

    switch (node.type) {
      case NodeType.folder:
        iconWidth = folderTheme.width +
            folderTheme.padding.horizontal +
            folderTheme.margin.horizontal;
        iconToTextSpacing = folderTheme.iconToTextSpacing;
        textStyle = folderTheme.textStyle ?? const TextStyle(fontSize: 14);
        break;
      case NodeType.parent:
        iconWidth = parentTheme.width +
            parentTheme.padding.horizontal +
            parentTheme.margin.horizontal;
        iconToTextSpacing = parentTheme.iconToTextSpacing;
        textStyle = parentTheme.textStyle ?? const TextStyle(fontSize: 14);
        break;
      case NodeType.child:
        iconWidth = childTheme.width +
            childTheme.padding.horizontal +
            childTheme.margin.horizontal;
        iconToTextSpacing = childTheme.iconToTextSpacing;
        textStyle = childTheme.textStyle ?? const TextStyle(fontSize: 14);
        break;
    }

    width += iconWidth;
    width += iconToTextSpacing;

    // Text width
    final textPainter = TextPainter(
      text: TextSpan(text: node.label, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    width += textPainter.width;

    // Right padding
    width += rightPadding;

    return width;
  }

  /// Calculate the total content height of all visible nodes
  static double calculateContentHeight<T>({
    required List<Node<T>> nodes,
    double rowHeight = 40.0,
    double topPadding = 0.0,
    double bottomPadding = 0.0,
  }) {
    double height = 0.0;

    for (var node in nodes) {
      // Add this node's height
      height += rowHeight;

      // If expanded, add children's height recursively
      if (node.isExpanded && node.children.isNotEmpty) {
        height += calculateContentHeight(
          nodes: node.children,
          rowHeight: rowHeight,
          // Children don't need extra padding
          topPadding: 0.0,
          bottomPadding: 0.0,
        );
      }
    }

    // Add top and bottom padding to the total height
    return height + topPadding + bottomPadding;
  }
}
