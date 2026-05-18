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

  /// Returns a deeply-scaled copy of this theme.
  ///
  /// Delegates to each child theme's `scale` and multiplies top-level
  /// scalars ([rowHeight], [rowSpacing]).
  ///
  /// **Deliberately omitted from delegation** (per ADR-0001):
  /// [scrollbarTheme] is preserved as-is — scrollbars are chrome, not content.
  /// [animationDuration] is preserved as-is — time is not a length.
  ///
  /// [defaultFontSize] is used to resolve null [TextStyle.fontSize] values
  /// before scaling. Widget callers should prefer [scaledForContext] which
  /// extracts this from the ambient [Theme].
  ///
  /// Identity: `scale(factor: 1.0, defaultFontSize: …)` returns `this`.
  FlutterFolderViewTheme<T> scale({
    required double factor,
    required double defaultFontSize,
  }) {
    assert(factor > 0, 'scale factor must be > 0, got $factor');
    if (factor == 1.0) return this;
    return copyWith(
      rowHeight: rowHeight * factor,
      rowSpacing: rowSpacing * factor,
      lineTheme: lineTheme.scale(factor),
      // scrollbarTheme: deliberately NOT delegated (ADR-0001 — scrollbars
      // are chrome, not content, and must remain physically-sized for input).
      folderTheme:
          folderTheme.scale(factor, defaultFontSize: defaultFontSize),
      parentTheme:
          parentTheme.scale(factor, defaultFontSize: defaultFontSize),
      childTheme:
          childTheme.scale(factor, defaultFontSize: defaultFontSize),
      expandIconTheme: expandIconTheme.scale(factor),
      spacingTheme: spacingTheme.scale(factor),
      nodeStyleTheme: nodeStyleTheme.scale(factor),
    );
  }

  /// Convenience for the dominant call site: extracts the ambient
  /// `defaultFontSize` from `Theme.of(context).textTheme.bodyMedium` and
  /// delegates to [scale].
  ///
  /// Couples this entry point to the Material text theme. The per-Theme
  /// `scale` methods remain framework-agnostic and can be tested in pure
  /// Dart without a widget tree.
  ///
  /// Identity: `scaledForContext(context, 1.0)` returns `this`.
  FlutterFolderViewTheme<T> scaledForContext(
    BuildContext context,
    double factor,
  ) {
    if (factor == 1.0) return this;
    final defaultFontSize =
        Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14.0;
    return scale(factor: factor, defaultFontSize: defaultFontSize);
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
