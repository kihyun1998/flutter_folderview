import 'package:flutter/material.dart';

import '../models/flat_node.dart';
import '../models/node.dart';
import '../themes/child_node_theme.dart';
import '../themes/expand_icon_theme.dart';
import '../themes/folder_node_theme.dart';
import '../themes/parent_node_theme.dart';

class SizeService {
  /// Cache for measured text widths to avoid repeated TextPainter layouts.
  /// Key: "label\0fontSize\0fontWeight" — Value: measured pixel width.
  static final Map<String, double> _textWidthCache = {};

  /// Clears the text width cache. Call when theme changes.
  static void clearTextWidthCache() {
    _textWidthCache.clear();
  }

  /// Calculate the total content width from visible flat nodes.
  ///
  /// Iterates through the already-flattened visible nodes to find the widest one.
  /// No recursion needed — the flat list already contains only visible nodes.
  static double calculateContentWidth<T>({
    required List<FlatNode<T>> flatNodes,
    required FolderNodeTheme folderTheme,
    required ParentNodeTheme parentTheme,
    required ChildNodeTheme childTheme,
    required ExpandIconTheme expandIconTheme,
    double leftPadding = 0.0,
    double rightPadding = 16.0,
    double maxWidth = double.infinity,
  }) {
    final linePaintWidth = expandIconTheme.width +
        expandIconTheme.padding.horizontal +
        expandIconTheme.margin.horizontal;

    double maxNodeWidth = 0.0;

    for (final flatNode in flatNodes) {
      final nodeWidth = _calculateNodeWidth(
        node: flatNode.node,
        depth: flatNode.depth,
        folderTheme: folderTheme,
        parentTheme: parentTheme,
        childTheme: childTheme,
        expandIconTheme: expandIconTheme,
        linePaintWidth: linePaintWidth,
        rightPadding: rightPadding,
      );
      if (nodeWidth > maxNodeWidth) {
        maxNodeWidth = nodeWidth;
      }
    }

    final totalWidth = leftPadding + maxNodeWidth;
    return totalWidth.clamp(0.0, maxWidth);
  }

  /// Calculate the width of a single node (public, for lazy per-item measurement).
  static double calculateSingleNodeWidth<T>({
    required Node<T> node,
    required int depth,
    required FolderNodeTheme folderTheme,
    required ParentNodeTheme parentTheme,
    required ChildNodeTheme childTheme,
    required ExpandIconTheme expandIconTheme,
    double leftPadding = 0.0,
    double rightPadding = 16.0,
  }) {
    final linePaintWidth = expandIconTheme.width +
        expandIconTheme.padding.horizontal +
        expandIconTheme.margin.horizontal;
    return leftPadding +
        _calculateNodeWidth(
          node: node,
          depth: depth,
          folderTheme: folderTheme,
          parentTheme: parentTheme,
          childTheme: childTheme,
          expandIconTheme: expandIconTheme,
          linePaintWidth: linePaintWidth,
          rightPadding: rightPadding,
        );
  }

  /// Calculate the width of a single node including its depth indentation.
  static double _calculateNodeWidth<T>({
    required Node<T> node,
    required int depth,
    required FolderNodeTheme folderTheme,
    required ParentNodeTheme parentTheme,
    required ChildNodeTheme childTheme,
    required ExpandIconTheme expandIconTheme,
    required double linePaintWidth,
    required double rightPadding,
  }) {
    // Indent based on depth
    double width = depth * linePaintWidth;

    // Expand/collapse icon space
    width += expandIconTheme.width +
        expandIconTheme.padding.horizontal +
        expandIconTheme.margin.horizontal;

    // Node icon and text style based on type
    double iconWidth;
    TextStyle? textStyle;

    switch (node.type) {
      case NodeType.folder:
        iconWidth = folderTheme.width +
            folderTheme.padding.horizontal +
            folderTheme.margin.horizontal;
        textStyle = folderTheme.textStyle ?? const TextStyle(fontSize: 14);
        break;
      case NodeType.parent:
        iconWidth = parentTheme.width +
            parentTheme.padding.horizontal +
            parentTheme.margin.horizontal;
        textStyle = parentTheme.textStyle ?? const TextStyle(fontSize: 14);
        break;
      case NodeType.child:
        iconWidth = childTheme.width +
            childTheme.padding.horizontal +
            childTheme.margin.horizontal;
        textStyle = childTheme.textStyle ?? const TextStyle(fontSize: 14);
        break;
    }

    width += iconWidth;

    // Text width (cached)
    final cacheKey =
        '${node.label}\x00${textStyle!.fontSize}\x00${textStyle.fontWeight}';
    final textWidth = _textWidthCache[cacheKey] ??= () {
      final tp = TextPainter(
        text: TextSpan(text: node.label, style: textStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      return tp.width;
    }();

    width += textWidth;
    width += rightPadding;

    return width;
  }

  /// Calculate the total content height from a flat item count.
  ///
  /// Since all rows have the same fixed height, this is O(1).
  static double calculateContentHeight({
    required int itemCount,
    double rowHeight = 40.0,
    double rowSpacing = 0.0,
    double topPadding = 0.0,
    double bottomPadding = 0.0,
  }) {
    if (itemCount == 0) return topPadding + bottomPadding;

    final totalRowHeight = itemCount * rowHeight;
    final totalSpacing = (itemCount - 1) * rowSpacing;

    return totalRowHeight + totalSpacing + topPadding + bottomPadding;
  }
}
