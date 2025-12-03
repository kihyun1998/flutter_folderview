import 'package:flutter/material.dart';

import '../models/node.dart';
import '../themes/folder_view_text_theme.dart';

class SizeService {
  /// Calculate the total content width of all nodes
  static double calculateContentWidth<T>({
    required List<Node<T>> nodes,
    required FolderViewTextTheme textTheme,
    double linePaintWidth = 20.0,
    double iconSize = 20.0,
    double spacing = 8.0,
    double rightPadding = 16.0,
    double maxWidth = double.infinity,
  }) {
    double maxNodeWidth = 0.0;

    for (var node in nodes) {
      final nodeWidth = _calculateNodeWidth(
        node: node,
        textTheme: textTheme,
        depth: 0,
        linePaintWidth: linePaintWidth,
        iconSize: iconSize,
        spacing: spacing,
        rightPadding: rightPadding,
      );
      if (nodeWidth > maxNodeWidth) {
        maxNodeWidth = nodeWidth;
      }

      // Recursively check children if expanded
      if (node.isExpanded && node.children.isNotEmpty) {
        final childrenWidth = calculateContentWidth(
          nodes: node.children,
          textTheme: textTheme,
          linePaintWidth: linePaintWidth,
          iconSize: iconSize,
          spacing: spacing,
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

    return maxNodeWidth.clamp(0.0, maxWidth);
  }

  /// Calculate the width of a single node
  static double _calculateNodeWidth<T>({
    required Node<T> node,
    required FolderViewTextTheme textTheme,
    required int depth,
    required double linePaintWidth,
    required double iconSize,
    required double spacing,
    required double rightPadding,
  }) {
    // Base indent (pipeline spacing)
    double width = linePaintWidth;

    // Expand/collapse icon (or space)
    width += iconSize;

    // Node icon
    width += iconSize;

    // Spacing after icon
    width += spacing;

    // Resolve style
    TextStyle style = textTheme.textStyle ?? const TextStyle(fontSize: 14);
    switch (node.type) {
      case NodeType.folder:
        style = style.merge(textTheme.folderTextStyle);
        break;
      case NodeType.parent:
        style = style.merge(textTheme.parentTextStyle);
        break;
      case NodeType.child:
        style = style.merge(textTheme.childTextStyle);
        break;
    }

    // Text width
    final textPainter = TextPainter(
      text: TextSpan(text: node.label, style: style),
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
        );
      }
    }

    return height;
  }
}
