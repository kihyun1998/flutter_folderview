import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/theme_demo_data.dart';

part 'theme_demo_provider.g.dart';

@riverpod
class ThemeDemoState extends _$ThemeDemoState {
  @override
  ThemeDemoViewModel build() {
    return ThemeDemoViewModel(
      nodes: getThemeDemoData(),
      selectedIds: {},
      expandedIds: {'1', '1-1', '2', '2-1', '2-2', '3'},
    );
  }

  // Node interactions
  void toggleNode(String nodeId) {
    final newExpanded = Set<String>.from(state.expandedIds);
    if (newExpanded.contains(nodeId)) {
      newExpanded.remove(nodeId);
    } else {
      newExpanded.add(nodeId);
    }
    state = state.copyWith(expandedIds: newExpanded);
  }

  void selectNode(String nodeId) {
    final newSelected = Set<String>.from(state.selectedIds);
    if (newSelected.contains(nodeId)) {
      newSelected.remove(nodeId);
    } else {
      newSelected.add(nodeId);
    }
    state = state.copyWith(selectedIds: newSelected);
  }

  void expandAll() {
    final allIds = <String>{};
    _collectExpandableIds(state.nodes, allIds);
    state = state.copyWith(expandedIds: allIds);
  }

  void collapseAll() {
    state = state.copyWith(expandedIds: {});
  }

  void _collectExpandableIds(List<Node<String>> nodes, Set<String> ids) {
    for (final node in nodes) {
      if (node.children.isNotEmpty) {
        ids.add(node.id);
        _collectExpandableIds(node.children, ids);
      }
    }
  }

  // View mode
  void setViewMode(ViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  // Line theme
  void setLineColor(Color color) {
    state = state.copyWith(lineColor: color);
  }

  void setLineWidth(double width) {
    state = state.copyWith(lineWidth: width);
  }

  void setLineStyle(LineStyle style) {
    state = state.copyWith(lineStyle: style);
  }

  // Folder theme
  void setFolderIconSize(double size) {
    state = state.copyWith(folderIconSize: size);
  }

  void setFolderIconColor(Color color) {
    state = state.copyWith(folderIconColor: color);
  }

  void setFolderPadding(double padding) {
    state = state.copyWith(folderPadding: padding);
  }

  void setFolderMargin(double margin) {
    state = state.copyWith(folderMargin: margin);
  }

  void setFolderTextColor(Color color) {
    state = state.copyWith(folderTextColor: color);
  }

  void setFolderFontSize(double size) {
    state = state.copyWith(folderFontSize: size);
  }

  void setFolderHoverColor(Color color) {
    state = state.copyWith(folderHoverColor: color);
  }

  void setFolderSplashColor(Color color) {
    state = state.copyWith(folderSplashColor: color);
  }

  void setFolderHighlightColor(Color color) {
    state = state.copyWith(folderHighlightColor: color);
  }

  // Parent theme
  void setParentIconSize(double size) {
    state = state.copyWith(parentIconSize: size);
  }

  void setParentIconColor(Color color) {
    state = state.copyWith(parentIconColor: color);
  }

  void setParentPadding(double padding) {
    state = state.copyWith(parentPadding: padding);
  }

  void setParentMargin(double margin) {
    state = state.copyWith(parentMargin: margin);
  }

  void setParentTextColor(Color color) {
    state = state.copyWith(parentTextColor: color);
  }

  void setParentFontSize(double size) {
    state = state.copyWith(parentFontSize: size);
  }

  void setParentHoverColor(Color color) {
    state = state.copyWith(parentHoverColor: color);
  }

  void setParentSplashColor(Color color) {
    state = state.copyWith(parentSplashColor: color);
  }

  void setParentHighlightColor(Color color) {
    state = state.copyWith(parentHighlightColor: color);
  }

  // Child theme
  void setChildIconSize(double size) {
    state = state.copyWith(childIconSize: size);
  }

  void setChildIconColor(Color color) {
    state = state.copyWith(childIconColor: color);
  }

  void setChildPadding(double padding) {
    state = state.copyWith(childPadding: padding);
  }

  void setChildMargin(double margin) {
    state = state.copyWith(childMargin: margin);
  }

  void setChildTextColor(Color color) {
    state = state.copyWith(childTextColor: color);
  }

  void setChildFontSize(double size) {
    state = state.copyWith(childFontSize: size);
  }

  void setChildSelectedBg(Color color) {
    state = state.copyWith(childSelectedBg: color);
  }

  void setChildHoverColor(Color color) {
    state = state.copyWith(childHoverColor: color);
  }

  void setChildSplashColor(Color color) {
    state = state.copyWith(childSplashColor: color);
  }

  void setChildHighlightColor(Color color) {
    state = state.copyWith(childHighlightColor: color);
  }

  // Expand icon theme
  void setExpandIconSize(double size) {
    state = state.copyWith(expandIconSize: size);
  }

  void setExpandIconColor(Color color) {
    state = state.copyWith(expandIconColor: color);
  }

  void setExpandIconExpandedColor(Color color) {
    state = state.copyWith(expandIconExpandedColor: color);
  }

  void setExpandPadding(double padding) {
    state = state.copyWith(expandPadding: padding);
  }

  void setExpandMargin(double margin) {
    state = state.copyWith(expandMargin: margin);
  }

  // Node style
  void setBorderRadius(double radius) {
    state = state.copyWith(borderRadius: radius);
  }

  // Interaction
  void setClickInterval(double interval) {
    state = state.copyWith(clickInterval: interval);
  }

  void setAnimationDuration(double duration) {
    state = state.copyWith(animationDuration: duration);
  }

  // Layout
  void setRowHeight(double height) {
    state = state.copyWith(rowHeight: height);
  }

  void setRowSpacing(double spacing) {
    state = state.copyWith(rowSpacing: spacing);
  }

  // Tooltip
  void setFolderTooltipEnabled(bool enabled) {
    state = state.copyWith(folderTooltipEnabled: enabled);
  }

  void setFolderTooltipBgColor(Color color) {
    state = state.copyWith(folderTooltipBgColor: color);
  }

  void setParentTooltipEnabled(bool enabled) {
    state = state.copyWith(parentTooltipEnabled: enabled);
  }

  void setParentTooltipBgColor(Color color) {
    state = state.copyWith(parentTooltipBgColor: color);
  }

  void setChildTooltipEnabled(bool enabled) {
    state = state.copyWith(childTooltipEnabled: enabled);
  }

  void setChildTooltipBgColor(Color color) {
    state = state.copyWith(childTooltipBgColor: color);
  }

  void setTooltipDirection(TooltipDirection direction) {
    state = state.copyWith(tooltipDirection: direction);
  }

  void setTooltipAlignment(TooltipAlignment alignment) {
    state = state.copyWith(tooltipAlignment: alignment);
  }

  void setTooltipOffset(double offset) {
    state = state.copyWith(tooltipOffset: offset);
  }

  void setTooltipElevation(double elevation) {
    state = state.copyWith(tooltipElevation: elevation);
  }

  void setTooltipEnableTap(bool enabled) {
    state = state.copyWith(tooltipEnableTap: enabled);
  }

  void setTooltipEnableHover(bool enabled) {
    state = state.copyWith(tooltipEnableHover: enabled);
  }

  void setTooltipInteractive(bool enabled) {
    state = state.copyWith(tooltipInteractive: enabled);
  }

  void setTooltipWaitDuration(double ms) {
    state = state.copyWith(tooltipWaitDuration: ms);
  }

  void setTooltipShowDuration(double ms) {
    state = state.copyWith(tooltipShowDuration: ms);
  }

  void setTooltipBoxShadowEnabled(bool enabled) {
    state = state.copyWith(tooltipBoxShadowEnabled: enabled);
  }

  void setTooltipBoxShadowBlur(double blur) {
    state = state.copyWith(tooltipBoxShadowBlur: blur);
  }

  void setTooltipBoxShadowSpread(double spread) {
    state = state.copyWith(tooltipBoxShadowSpread: spread);
  }

  void setTooltipShowArrow(bool enabled) {
    state = state.copyWith(tooltipShowArrow: enabled);
  }

  void setTooltipArrowBaseWidth(double width) {
    state = state.copyWith(tooltipArrowBaseWidth: width);
  }

  void setTooltipArrowLength(double length) {
    state = state.copyWith(tooltipArrowLength: length);
  }

  void setTooltipArrowPositionRatio(double ratio) {
    state = state.copyWith(tooltipArrowPositionRatio: ratio);
  }

  void setTooltipBorderWidth(double width) {
    state = state.copyWith(tooltipBorderWidth: width);
  }

  void setTooltipBorderColor(Color color) {
    state = state.copyWith(tooltipBorderColor: color);
  }

  void setTooltipScreenMargin(double margin) {
    state = state.copyWith(tooltipScreenMargin: margin);
  }

  // Reset
  void reset() {
    state = ThemeDemoViewModel(
      nodes: getThemeDemoData(),
      selectedIds: {},
      expandedIds: {'1', '1-1', '2', '2-1', '2-2', '3'},
    );
  }

  // Data generation parameters
  void setGenRootCount(int count) {
    state = state.copyWith(genRootCount: count);
  }

  void setGenMaxDepth(int depth) {
    state = state.copyWith(genMaxDepth: depth);
  }

  void setGenSubFolderCount(int count) {
    state = state.copyWith(genSubFolderCount: count);
  }

  void setGenParentCount(int count) {
    state = state.copyWith(genParentCount: count);
  }

  void setGenChildCount(int count) {
    state = state.copyWith(genChildCount: count);
  }

  // Load demo data
  void loadDemoData() {
    state = state.copyWith(
      nodes: getThemeDemoData(),
      selectedIds: {},
      expandedIds: {'1', '1-1', '2', '2-1', '2-2', '3'},
      genRootCount: 5,
      genMaxDepth: 2,
      genSubFolderCount: 3,
      genParentCount: 3,
      genChildCount: 5,
    );
  }

  // Generate data based on parameters
  void generateData() {
    final nodes = _generateDataset(
      rootCount: state.genRootCount,
      maxDepth: state.genMaxDepth,
      subFolderCount: state.genSubFolderCount,
      parentCount: state.genParentCount,
      childCount: state.genChildCount,
    );
    state = state.copyWith(nodes: nodes, selectedIds: {}, expandedIds: {});
  }

  List<Node<String>> _generateDataset({
    required int rootCount,
    required int maxDepth,
    required int subFolderCount,
    required int parentCount,
    required int childCount,
  }) {
    final rng = Random(42);
    int idCounter = 0;

    final longNames = [
      'This is a very long folder name that should cause text overflow',
      'Another extremely long directory name - Project Alpha Release 2024',
      'Deep nested folder with ridiculously long name for testing scroll',
      'Super_Long_File_Name_With_Underscores_Configuration_v2.json',
      'quarterly-financial-report-infrastructure-operations-2024-Q4.xlsx',
    ];

    Node<String> generateChild(String prefix) {
      final id = '${prefix}_child_${++idCounter}';
      final useLong = rng.nextDouble() < 0.1;
      final label = useLong
          ? longNames[rng.nextInt(longNames.length)]
          : 'Item $idCounter.pdf';
      return Node<String>(
        id: id,
        label: label,
        type: NodeType.child,
        data: 'Data for $id',
      );
    }

    List<Node<String>> generateParents(String prefix) {
      final parents = <Node<String>>[];
      for (int i = 1; i <= parentCount; i++) {
        final id = '${prefix}_parent_${++idCounter}';
        final useLong = rng.nextDouble() < 0.1;
        final label = useLong
            ? longNames[rng.nextInt(longNames.length)]
            : 'Category $idCounter';

        parents.add(
          Node<String>(
            id: id,
            label: label,
            type: NodeType.parent,
            children: List.generate(childCount, (_) => generateChild(id)),
          ),
        );
      }
      return parents;
    }

    List<Node<String>> generateFolderLevel(String prefix, int currentDepth) {
      final nodes = <Node<String>>[];

      for (int i = 1; i <= subFolderCount; i++) {
        final id = '${prefix}_folder_${++idCounter}';
        final useLong = rng.nextDouble() < 0.15;
        final label = useLong
            ? longNames[rng.nextInt(longNames.length)]
            : 'Folder $idCounter - Depth $currentDepth';

        List<Node<String>> children;
        if (currentDepth < maxDepth) {
          children = generateFolderLevel(id, currentDepth + 1);
        } else {
          children = generateParents(id);
        }

        nodes.add(
          Node<String>(
            id: id,
            label: label,
            type: NodeType.folder,
            children: children,
          ),
        );
      }

      return nodes;
    }

    final roots = <Node<String>>[];
    for (int i = 1; i <= rootCount; i++) {
      final id = 'root_$i';
      final useLong = rng.nextDouble() < 0.15;
      final label = useLong
          ? longNames[rng.nextInt(longNames.length)]
          : 'Department $i';

      roots.add(
        Node<String>(
          id: id,
          label: label,
          type: NodeType.folder,
          children: generateFolderLevel(id, 1),
        ),
      );
    }

    return roots;
  }
}

class ThemeDemoViewModel {
  // Data
  final List<Node<String>> nodes;
  final Set<String> selectedIds;
  final Set<String> expandedIds;

  // View mode
  final ViewMode viewMode;

  // Line theme
  final Color lineColor;
  final double lineWidth;
  final LineStyle lineStyle;

  // Folder theme
  final double folderIconSize;
  final Color folderIconColor;
  final double folderPadding;
  final double folderMargin;
  final Color folderTextColor;
  final double folderFontSize;
  final Color folderHoverColor;
  final Color folderSplashColor;
  final Color folderHighlightColor;

  // Parent theme
  final double parentIconSize;
  final Color parentIconColor;
  final double parentPadding;
  final double parentMargin;
  final Color parentTextColor;
  final double parentFontSize;
  final Color parentHoverColor;
  final Color parentSplashColor;
  final Color parentHighlightColor;

  // Child theme
  final double childIconSize;
  final Color childIconColor;
  final double childPadding;
  final double childMargin;
  final Color childTextColor;
  final double childFontSize;
  final Color childSelectedBg;
  final Color childHoverColor;
  final Color childSplashColor;
  final Color childHighlightColor;

  // Expand icon theme
  final double expandIconSize;
  final Color expandIconColor;
  final Color expandIconExpandedColor;
  final double expandPadding;
  final double expandMargin;

  // Node style
  final double borderRadius;

  // Interaction
  final double clickInterval;
  final double animationDuration;

  // Layout
  final double rowHeight;
  final double rowSpacing;

  // Tooltip
  final bool folderTooltipEnabled;
  final Color folderTooltipBgColor;
  final bool parentTooltipEnabled;
  final Color parentTooltipBgColor;
  final bool childTooltipEnabled;
  final Color childTooltipBgColor;
  final TooltipDirection tooltipDirection;
  final TooltipAlignment tooltipAlignment;
  final double tooltipOffset;
  final double tooltipElevation;
  final bool tooltipEnableTap;
  final bool tooltipEnableHover;
  final bool tooltipInteractive;
  final double tooltipWaitDuration;
  final double tooltipShowDuration;
  final bool tooltipBoxShadowEnabled;
  final double tooltipBoxShadowBlur;
  final double tooltipBoxShadowSpread;
  final bool tooltipShowArrow;
  final double tooltipArrowBaseWidth;
  final double tooltipArrowLength;
  final double tooltipArrowPositionRatio;
  final double tooltipBorderWidth;
  final Color tooltipBorderColor;
  final double tooltipScreenMargin;

  // Data generation parameters
  final int genRootCount;
  final int genMaxDepth;
  final int genSubFolderCount;
  final int genParentCount;
  final int genChildCount;

  /// Calculate estimated node count based on current parameters
  int get estimatedNodeCount {
    // Folders at each depth level
    int totalFolders = genRootCount;
    int foldersAtCurrentDepth = genRootCount;
    for (int d = 1; d <= genMaxDepth; d++) {
      foldersAtCurrentDepth *= genSubFolderCount;
      totalFolders += foldersAtCurrentDepth;
    }
    // Leaf folders (at max depth)
    final leafFolders = genRootCount * _pow(genSubFolderCount, genMaxDepth);
    final totalParents = leafFolders * genParentCount;
    final totalChildren = totalParents * genChildCount;
    return totalFolders + totalParents + totalChildren;
  }

  static int _pow(int base, int exp) {
    int result = 1;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }

  ThemeDemoViewModel({
    required this.nodes,
    this.selectedIds = const {},
    this.expandedIds = const {},
    this.viewMode = ViewMode.folder,
    // Line theme defaults
    this.lineColor = const Color(0xFF2196F3),
    this.lineWidth = 1.5,
    this.lineStyle = LineStyle.connector,
    // Folder theme defaults
    this.folderIconSize = 20.0,
    this.folderIconColor = const Color(0xFF616161),
    this.folderPadding = 0.0,
    this.folderMargin = 0.0,
    this.folderTextColor = Colors.black87,
    this.folderFontSize = 14.0,
    this.folderHoverColor = const Color(0xFFEEEEEE),
    this.folderSplashColor = const Color(0x4D2196F3),
    this.folderHighlightColor = const Color(0x1A2196F3),
    // Parent theme defaults
    this.parentIconSize = 20.0,
    this.parentIconColor = const Color(0xFF616161),
    this.parentPadding = 0.0,
    this.parentMargin = 0.0,
    this.parentTextColor = Colors.black87,
    this.parentFontSize = 14.0,
    this.parentHoverColor = const Color(0xFFEEEEEE),
    this.parentSplashColor = const Color(0x4D2196F3),
    this.parentHighlightColor = const Color(0x1A2196F3),
    // Child theme defaults
    this.childIconSize = 20.0,
    this.childIconColor = const Color(0xFF616161),
    this.childPadding = 0.0,
    this.childMargin = 0.0,
    this.childTextColor = Colors.black87,
    this.childFontSize = 14.0,
    this.childSelectedBg = const Color(0xFFE3F2FD),
    this.childHoverColor = const Color(0xFFEEEEEE),
    this.childSplashColor = const Color(0x4D2196F3),
    this.childHighlightColor = const Color(0x1A2196F3),
    // Expand icon theme defaults
    this.expandIconSize = 20.0,
    this.expandIconColor = const Color(0xFF616161),
    this.expandIconExpandedColor = const Color(0xFF2196F3),
    this.expandPadding = 0.0,
    this.expandMargin = 0.0,
    // Node style defaults
    this.borderRadius = 8.0,
    // Interaction defaults
    this.clickInterval = 300.0,
    this.animationDuration = 200.0,
    // Layout defaults
    this.rowHeight = 40.0,
    this.rowSpacing = 0.0,
    // Tooltip defaults
    this.folderTooltipEnabled = true,
    this.folderTooltipBgColor = const Color(0xFF424242),
    this.parentTooltipEnabled = true,
    this.parentTooltipBgColor = const Color(0xFF424242),
    this.childTooltipEnabled = true,
    this.childTooltipBgColor = const Color(0xFF424242),
    this.tooltipDirection = TooltipDirection.top,
    this.tooltipAlignment = TooltipAlignment.center,
    this.tooltipOffset = 8.0,
    this.tooltipElevation = 4.0,
    this.tooltipEnableTap = false,
    this.tooltipEnableHover = true,
    this.tooltipInteractive = false,
    this.tooltipWaitDuration = 0.0,
    this.tooltipShowDuration = 0.0,
    this.tooltipBoxShadowEnabled = false,
    this.tooltipBoxShadowBlur = 4.0,
    this.tooltipBoxShadowSpread = 0.0,
    this.tooltipShowArrow = false,
    this.tooltipArrowBaseWidth = 12.0,
    this.tooltipArrowLength = 6.0,
    this.tooltipArrowPositionRatio = 0.25,
    this.tooltipBorderWidth = 0.0,
    this.tooltipBorderColor = const Color(0xFF616161),
    this.tooltipScreenMargin = 8.0,
    // Data generation defaults
    this.genRootCount = 5,
    this.genMaxDepth = 2,
    this.genSubFolderCount = 3,
    this.genParentCount = 3,
    this.genChildCount = 5,
  });

  ThemeDemoViewModel copyWith({
    List<Node<String>>? nodes,
    Set<String>? selectedIds,
    Set<String>? expandedIds,
    ViewMode? viewMode,
    Color? lineColor,
    double? lineWidth,
    LineStyle? lineStyle,
    double? folderIconSize,
    Color? folderIconColor,
    double? folderPadding,
    double? folderMargin,
    Color? folderTextColor,
    double? folderFontSize,
    Color? folderHoverColor,
    Color? folderSplashColor,
    Color? folderHighlightColor,
    double? parentIconSize,
    Color? parentIconColor,
    double? parentPadding,
    double? parentMargin,
    Color? parentTextColor,
    double? parentFontSize,
    Color? parentHoverColor,
    Color? parentSplashColor,
    Color? parentHighlightColor,
    double? childIconSize,
    Color? childIconColor,
    double? childPadding,
    double? childMargin,
    Color? childTextColor,
    double? childFontSize,
    Color? childSelectedBg,
    Color? childHoverColor,
    Color? childSplashColor,
    Color? childHighlightColor,
    double? expandIconSize,
    Color? expandIconColor,
    Color? expandIconExpandedColor,
    double? expandPadding,
    double? expandMargin,
    double? borderRadius,
    double? clickInterval,
    double? animationDuration,
    double? rowHeight,
    double? rowSpacing,
    bool? folderTooltipEnabled,
    Color? folderTooltipBgColor,
    bool? parentTooltipEnabled,
    Color? parentTooltipBgColor,
    bool? childTooltipEnabled,
    Color? childTooltipBgColor,
    TooltipDirection? tooltipDirection,
    TooltipAlignment? tooltipAlignment,
    double? tooltipOffset,
    double? tooltipElevation,
    bool? tooltipEnableTap,
    bool? tooltipEnableHover,
    bool? tooltipInteractive,
    double? tooltipWaitDuration,
    double? tooltipShowDuration,
    bool? tooltipBoxShadowEnabled,
    double? tooltipBoxShadowBlur,
    double? tooltipBoxShadowSpread,
    bool? tooltipShowArrow,
    double? tooltipArrowBaseWidth,
    double? tooltipArrowLength,
    double? tooltipArrowPositionRatio,
    double? tooltipBorderWidth,
    Color? tooltipBorderColor,
    double? tooltipScreenMargin,
    int? genRootCount,
    int? genMaxDepth,
    int? genSubFolderCount,
    int? genParentCount,
    int? genChildCount,
  }) {
    return ThemeDemoViewModel(
      nodes: nodes ?? this.nodes,
      selectedIds: selectedIds ?? this.selectedIds,
      expandedIds: expandedIds ?? this.expandedIds,
      viewMode: viewMode ?? this.viewMode,
      lineColor: lineColor ?? this.lineColor,
      lineWidth: lineWidth ?? this.lineWidth,
      lineStyle: lineStyle ?? this.lineStyle,
      folderIconSize: folderIconSize ?? this.folderIconSize,
      folderIconColor: folderIconColor ?? this.folderIconColor,
      folderPadding: folderPadding ?? this.folderPadding,
      folderMargin: folderMargin ?? this.folderMargin,
      folderTextColor: folderTextColor ?? this.folderTextColor,
      folderFontSize: folderFontSize ?? this.folderFontSize,
      folderHoverColor: folderHoverColor ?? this.folderHoverColor,
      folderSplashColor: folderSplashColor ?? this.folderSplashColor,
      folderHighlightColor: folderHighlightColor ?? this.folderHighlightColor,
      parentIconSize: parentIconSize ?? this.parentIconSize,
      parentIconColor: parentIconColor ?? this.parentIconColor,
      parentPadding: parentPadding ?? this.parentPadding,
      parentMargin: parentMargin ?? this.parentMargin,
      parentTextColor: parentTextColor ?? this.parentTextColor,
      parentFontSize: parentFontSize ?? this.parentFontSize,
      parentHoverColor: parentHoverColor ?? this.parentHoverColor,
      parentSplashColor: parentSplashColor ?? this.parentSplashColor,
      parentHighlightColor: parentHighlightColor ?? this.parentHighlightColor,
      childIconSize: childIconSize ?? this.childIconSize,
      childIconColor: childIconColor ?? this.childIconColor,
      childPadding: childPadding ?? this.childPadding,
      childMargin: childMargin ?? this.childMargin,
      childTextColor: childTextColor ?? this.childTextColor,
      childFontSize: childFontSize ?? this.childFontSize,
      childSelectedBg: childSelectedBg ?? this.childSelectedBg,
      childHoverColor: childHoverColor ?? this.childHoverColor,
      childSplashColor: childSplashColor ?? this.childSplashColor,
      childHighlightColor: childHighlightColor ?? this.childHighlightColor,
      expandIconSize: expandIconSize ?? this.expandIconSize,
      expandIconColor: expandIconColor ?? this.expandIconColor,
      expandIconExpandedColor:
          expandIconExpandedColor ?? this.expandIconExpandedColor,
      expandPadding: expandPadding ?? this.expandPadding,
      expandMargin: expandMargin ?? this.expandMargin,
      borderRadius: borderRadius ?? this.borderRadius,
      clickInterval: clickInterval ?? this.clickInterval,
      animationDuration: animationDuration ?? this.animationDuration,
      rowHeight: rowHeight ?? this.rowHeight,
      rowSpacing: rowSpacing ?? this.rowSpacing,
      folderTooltipEnabled: folderTooltipEnabled ?? this.folderTooltipEnabled,
      folderTooltipBgColor: folderTooltipBgColor ?? this.folderTooltipBgColor,
      parentTooltipEnabled: parentTooltipEnabled ?? this.parentTooltipEnabled,
      parentTooltipBgColor: parentTooltipBgColor ?? this.parentTooltipBgColor,
      childTooltipEnabled: childTooltipEnabled ?? this.childTooltipEnabled,
      childTooltipBgColor: childTooltipBgColor ?? this.childTooltipBgColor,
      tooltipDirection: tooltipDirection ?? this.tooltipDirection,
      tooltipAlignment: tooltipAlignment ?? this.tooltipAlignment,
      tooltipOffset: tooltipOffset ?? this.tooltipOffset,
      tooltipElevation: tooltipElevation ?? this.tooltipElevation,
      tooltipEnableTap: tooltipEnableTap ?? this.tooltipEnableTap,
      tooltipEnableHover: tooltipEnableHover ?? this.tooltipEnableHover,
      tooltipInteractive: tooltipInteractive ?? this.tooltipInteractive,
      tooltipWaitDuration: tooltipWaitDuration ?? this.tooltipWaitDuration,
      tooltipShowDuration: tooltipShowDuration ?? this.tooltipShowDuration,
      tooltipBoxShadowEnabled:
          tooltipBoxShadowEnabled ?? this.tooltipBoxShadowEnabled,
      tooltipBoxShadowBlur: tooltipBoxShadowBlur ?? this.tooltipBoxShadowBlur,
      tooltipBoxShadowSpread:
          tooltipBoxShadowSpread ?? this.tooltipBoxShadowSpread,
      tooltipShowArrow: tooltipShowArrow ?? this.tooltipShowArrow,
      tooltipArrowBaseWidth:
          tooltipArrowBaseWidth ?? this.tooltipArrowBaseWidth,
      tooltipArrowLength: tooltipArrowLength ?? this.tooltipArrowLength,
      tooltipArrowPositionRatio:
          tooltipArrowPositionRatio ?? this.tooltipArrowPositionRatio,
      tooltipBorderWidth: tooltipBorderWidth ?? this.tooltipBorderWidth,
      tooltipBorderColor: tooltipBorderColor ?? this.tooltipBorderColor,
      tooltipScreenMargin: tooltipScreenMargin ?? this.tooltipScreenMargin,
      genRootCount: genRootCount ?? this.genRootCount,
      genMaxDepth: genMaxDepth ?? this.genMaxDepth,
      genSubFolderCount: genSubFolderCount ?? this.genSubFolderCount,
      genParentCount: genParentCount ?? this.genParentCount,
      genChildCount: genChildCount ?? this.genChildCount,
    );
  }
}
