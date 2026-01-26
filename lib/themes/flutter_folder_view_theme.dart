import 'package:flutter/material.dart';

import '../models/node.dart';
import 'child_node_theme.dart';
import 'expand_icon_theme.dart';
import 'folder_node_theme.dart';
import 'folder_view_line_theme.dart';
import 'folder_view_node_style_theme.dart';
import 'folder_view_scrollbar_theme.dart';
import 'folder_view_spacing_theme.dart';
import 'parent_node_theme.dart';

/// Master theme class for the entire FolderView component
///
/// This class provides a centralized way to customize the appearance
/// of FolderView widgets with separate themes for each node type.
@immutable
class FlutterFolderViewTheme<T> {
  /// Theme for connection lines between nodes
  final FolderViewLineTheme lineTheme;

  /// Theme for scrollbars
  final FolderViewScrollbarTheme scrollbarTheme;

  /// Theme for folder nodes
  final FolderNodeTheme<T> folderTheme;

  /// Theme for parent nodes
  final ParentNodeTheme<T> parentTheme;

  /// Theme for child nodes
  final ChildNodeTheme<T> childTheme;

  /// Theme for expand/collapse icon
  final ExpandIconTheme expandIconTheme;

  /// Theme for spacing and padding
  final FolderViewSpacingTheme spacingTheme;

  /// Theme for node visual styling
  final FolderViewNodeStyleTheme nodeStyleTheme;

  /// Animation duration for expand/collapse animations in milliseconds
  final int animationDuration;

  /// Height of each row/node in pixels
  final double rowHeight;

  /// Vertical spacing between rows in pixels
  final double rowSpacing;

  /// Creates a [FlutterFolderViewTheme] with the given properties
  const FlutterFolderViewTheme({
    required this.lineTheme,
    required this.scrollbarTheme,
    this.folderTheme = const FolderNodeTheme(),
    this.parentTheme = const ParentNodeTheme(),
    this.childTheme = const ChildNodeTheme(),
    this.expandIconTheme = const ExpandIconTheme(),
    this.spacingTheme = const FolderViewSpacingTheme(),
    this.nodeStyleTheme = const FolderViewNodeStyleTheme(),
    this.animationDuration = 200,
    this.rowHeight = 40.0,
    this.rowSpacing = 0.0,
  });

  /// Creates a light theme with sensible defaults
  factory FlutterFolderViewTheme.light() {
    return FlutterFolderViewTheme<T>(
      lineTheme: FolderViewLineTheme(
        lineColor: const Color(0xFF9E9E9E), // Grey 500
        lineWidth: 1.5,
        lineStyle: LineStyle.connector,
      ),
      scrollbarTheme: FolderViewScrollbarTheme(
        thumbColor: Colors.grey.shade600,
        trackColor: Colors.grey.shade200,
      ),
      folderTheme: FolderNodeTheme<T>(
        widget: Icon(Icons.folder, color: Colors.grey.shade700, size: 20),
        openWidget:
            Icon(Icons.folder_open, color: Colors.grey.shade700, size: 20),
        textStyle: const TextStyle(color: Colors.black87),
        hoverColor: Colors.grey.shade200,
        splashColor: Colors.blue.withValues(alpha: 0.3),
        highlightColor: Colors.blue.withValues(alpha: 0.1),
      ),
      parentTheme: ParentNodeTheme<T>(
        widget: Icon(Icons.account_tree, color: Colors.grey.shade700, size: 20),
        textStyle: const TextStyle(color: Colors.black87),
        hoverColor: Colors.grey.shade200,
        splashColor: Colors.blue.withValues(alpha: 0.3),
        highlightColor: Colors.blue.withValues(alpha: 0.1),
      ),
      childTheme: ChildNodeTheme<T>(
        widget: Icon(Icons.insert_drive_file,
            color: Colors.grey.shade700, size: 20),
        textStyle: const TextStyle(color: Colors.black87),
        selectedTextStyle: const TextStyle(fontWeight: FontWeight.bold),
        selectedBackgroundColor: Colors.blue.shade50,
        hoverColor: Colors.grey.shade200,
        splashColor: Colors.blue.withValues(alpha: 0.3),
        highlightColor: Colors.blue.withValues(alpha: 0.1),
      ),
      expandIconTheme: ExpandIconTheme(
        widget:
            Icon(Icons.chevron_right, color: Colors.grey.shade700, size: 20),
      ),
      spacingTheme: const FolderViewSpacingTheme(),
    );
  }

  /// Creates a dark theme with sensible defaults
  factory FlutterFolderViewTheme.dark() {
    return FlutterFolderViewTheme<T>(
      lineTheme: FolderViewLineTheme(
        lineColor: const Color(0xFF757575), // Grey 600
        lineWidth: 1.5,
        lineStyle: LineStyle.connector,
      ),
      scrollbarTheme: FolderViewScrollbarTheme(
        thumbColor: Colors.grey.shade400,
        trackColor: Colors.grey.shade800,
      ),
      folderTheme: FolderNodeTheme<T>(
        widget: Icon(Icons.folder, color: Colors.grey.shade400, size: 20),
        openWidget:
            Icon(Icons.folder_open, color: Colors.grey.shade400, size: 20),
        textStyle: const TextStyle(color: Colors.white70),
        hoverColor: Colors.grey.shade800,
        splashColor: Colors.blue.withValues(alpha: 0.3),
        highlightColor: Colors.blue.withValues(alpha: 0.1),
      ),
      parentTheme: ParentNodeTheme<T>(
        widget: Icon(Icons.account_tree, color: Colors.grey.shade400, size: 20),
        textStyle: const TextStyle(color: Colors.white70),
        hoverColor: Colors.grey.shade800,
        splashColor: Colors.blue.withValues(alpha: 0.3),
        highlightColor: Colors.blue.withValues(alpha: 0.1),
      ),
      childTheme: ChildNodeTheme<T>(
        widget: Icon(Icons.insert_drive_file,
            color: Colors.grey.shade400, size: 20),
        textStyle: const TextStyle(color: Colors.white70),
        selectedTextStyle: const TextStyle(fontWeight: FontWeight.bold),
        selectedBackgroundColor: Colors.blue.shade900.withValues(alpha: 0.3),
        hoverColor: Colors.grey.shade800,
        splashColor: Colors.blue.withValues(alpha: 0.3),
        highlightColor: Colors.blue.withValues(alpha: 0.1),
      ),
      expandIconTheme: ExpandIconTheme(
        widget:
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
      ),
      spacingTheme: const FolderViewSpacingTheme(),
    );
  }

  /// Creates a copy of this theme with the given fields replaced with new values
  FlutterFolderViewTheme<T> copyWith({
    FolderViewLineTheme? lineTheme,
    FolderViewScrollbarTheme? scrollbarTheme,
    FolderNodeTheme<T>? folderTheme,
    ParentNodeTheme<T>? parentTheme,
    ChildNodeTheme<T>? childTheme,
    ExpandIconTheme? expandIconTheme,
    FolderViewSpacingTheme? spacingTheme,
    FolderViewNodeStyleTheme? nodeStyleTheme,
    int? animationDuration,
    double? rowHeight,
    double? rowSpacing,
  }) {
    return FlutterFolderViewTheme<T>(
      lineTheme: lineTheme ?? this.lineTheme,
      scrollbarTheme: scrollbarTheme ?? this.scrollbarTheme,
      folderTheme: folderTheme ?? this.folderTheme,
      parentTheme: parentTheme ?? this.parentTheme,
      childTheme: childTheme ?? this.childTheme,
      expandIconTheme: expandIconTheme ?? this.expandIconTheme,
      spacingTheme: spacingTheme ?? this.spacingTheme,
      nodeStyleTheme: nodeStyleTheme ?? this.nodeStyleTheme,
      animationDuration: animationDuration ?? this.animationDuration,
      rowHeight: rowHeight ?? this.rowHeight,
      rowSpacing: rowSpacing ?? this.rowSpacing,
    );
  }

  /// Linearly interpolate between two [FlutterFolderViewTheme]s
  static FlutterFolderViewTheme<T> lerp<T>(
    FlutterFolderViewTheme<T>? a,
    FlutterFolderViewTheme<T>? b,
    double t,
  ) {
    if (a == null && b == null) {
      return FlutterFolderViewTheme<T>.light();
    }
    if (a == null) return b!;
    if (b == null) return a;

    return FlutterFolderViewTheme<T>(
      lineTheme: FolderViewLineTheme.lerp(a.lineTheme, b.lineTheme, t),
      scrollbarTheme: FolderViewScrollbarTheme.lerp(
        a.scrollbarTheme,
        b.scrollbarTheme,
        t,
      ),
      folderTheme: FolderNodeTheme.lerp(a.folderTheme, b.folderTheme, t),
      parentTheme: ParentNodeTheme.lerp(a.parentTheme, b.parentTheme, t),
      childTheme: ChildNodeTheme.lerp(a.childTheme, b.childTheme, t),
      expandIconTheme:
          ExpandIconTheme.lerp(a.expandIconTheme, b.expandIconTheme, t),
      spacingTheme: FolderViewSpacingTheme.lerp(
        a.spacingTheme,
        b.spacingTheme,
        t,
      ),
      nodeStyleTheme: FolderViewNodeStyleTheme.lerp(
        a.nodeStyleTheme,
        b.nodeStyleTheme,
        t,
      ),
      animationDuration: t < 0.5 ? a.animationDuration : b.animationDuration,
      rowHeight: t < 0.5 ? a.rowHeight : b.rowHeight,
      rowSpacing: t < 0.5 ? a.rowSpacing : b.rowSpacing,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is FlutterFolderViewTheme<T> &&
        other.lineTheme == lineTheme &&
        other.scrollbarTheme == scrollbarTheme &&
        other.folderTheme == folderTheme &&
        other.parentTheme == parentTheme &&
        other.childTheme == childTheme &&
        other.expandIconTheme == expandIconTheme &&
        other.spacingTheme == spacingTheme &&
        other.nodeStyleTheme == nodeStyleTheme &&
        other.animationDuration == animationDuration &&
        other.rowHeight == rowHeight &&
        other.rowSpacing == rowSpacing;
  }

  @override
  int get hashCode => Object.hash(
        lineTheme,
        scrollbarTheme,
        folderTheme,
        parentTheme,
        childTheme,
        expandIconTheme,
        spacingTheme,
        nodeStyleTheme,
        animationDuration,
        Object.hash(rowHeight, rowSpacing),
      );

  @override
  String toString() {
    return 'FlutterFolderViewTheme<$T>('
        'lineTheme: $lineTheme, '
        'scrollbarTheme: $scrollbarTheme, '
        'folderTheme: $folderTheme, '
        'parentTheme: $parentTheme, '
        'childTheme: $childTheme, '
        'expandIconTheme: $expandIconTheme, '
        'spacingTheme: $spacingTheme, '
        'nodeStyleTheme: $nodeStyleTheme, '
        'animationDuration: $animationDuration, '
        'rowHeight: $rowHeight, '
        'rowSpacing: $rowSpacing'
        ')';
  }
}
