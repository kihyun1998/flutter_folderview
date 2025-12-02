import 'package:flutter/material.dart';
import '../models/node.dart';

class SizeService {
  /// Calculate the total content width of all nodes
  static double calculateContentWidth<T>({
    required List<Node<T>> nodes,
    required TextStyle textStyle,
    double indentWidth = 24.0,
    double iconSize = 20.0,
    double spacing = 8.0,
    double rightPadding = 16.0,
    double maxWidth = double.infinity,
  }) {
    double maxNodeWidth = 0.0;

    for (var node in nodes) {
      final nodeWidth = _calculateNodeWidth(
        node: node,
        textStyle: textStyle,
        depth: 0,
        indentWidth: indentWidth,
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
          textStyle: textStyle,
          indentWidth: indentWidth,
          iconSize: iconSize,
          spacing: spacing,
          rightPadding: rightPadding,
          maxWidth: maxWidth,
        );
        // Add one level of indentation for children
        final adjustedChildWidth = childrenWidth + indentWidth;
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
    required TextStyle textStyle,
    required int depth,
    required double indentWidth,
    required double iconSize,
    required double spacing,
    required double rightPadding,
  }) {
    // Base indent (pipeline spacing)
    double width = indentWidth;

    // Expand/collapse icon (or space)
    width += iconSize;

    // Node icon
    width += iconSize;

    // Spacing after icon
    width += spacing;

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
