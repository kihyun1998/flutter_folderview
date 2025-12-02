import 'package:flutter/material.dart';

import '../models/node.dart';
import 'folder_view_line_theme.dart';
import 'folder_view_scrollbar_theme.dart';

/// Master theme class for the entire FolderView component
///
/// This class provides a centralized way to customize the appearance
/// of FolderView widgets. Currently supports line theming, with the
/// architecture designed to easily add more theme properties in the future
/// (e.g., nodeTheme, textTheme, iconTheme, animationTheme, etc.).
@immutable
class FlutterFolderViewTheme {
  /// Theme for connection lines between nodes
  final FolderViewLineTheme lineTheme;

  /// Theme for scrollbars
  final FolderViewScrollbarTheme scrollbarTheme;

  // Future theme properties can be added here:
  // final FolderViewNodeTheme? nodeTheme;
  // final FolderViewTextTheme? textTheme;
  // final FolderViewIconTheme? iconTheme;
  // final FolderViewAnimationTheme? animationTheme;
  // final FolderViewSpacingTheme? spacingTheme;

  /// Creates a [FlutterFolderViewTheme] with the given properties
  const FlutterFolderViewTheme({
    required this.lineTheme,
    required this.scrollbarTheme,
  });

  /// Creates a light theme with sensible defaults
  factory FlutterFolderViewTheme.light() {
    return FlutterFolderViewTheme(
      lineTheme: FolderViewLineTheme(
        lineColor: const Color(0xFF9E9E9E), // Grey 500
        lineWidth: 1.5,
        lineStyle: LineStyle.connector,
      ),
      scrollbarTheme: FolderViewScrollbarTheme(
        thumbColor: Colors.grey.shade600,
        trackColor: Colors.grey.shade200,
      ),
    );
  }

  /// Creates a dark theme with sensible defaults
  factory FlutterFolderViewTheme.dark() {
    return FlutterFolderViewTheme(
      lineTheme: FolderViewLineTheme(
        lineColor: const Color(0xFF757575), // Grey 600
        lineWidth: 1.5,
        lineStyle: LineStyle.connector,
      ),
      scrollbarTheme: FolderViewScrollbarTheme(
        thumbColor: Colors.grey.shade400,
        trackColor: Colors.grey.shade800,
      ),
    );
  }

  /// Creates a copy of this theme with the given fields replaced with new values
  FlutterFolderViewTheme copyWith({
    FolderViewLineTheme? lineTheme,
    FolderViewScrollbarTheme? scrollbarTheme,
  }) {
    return FlutterFolderViewTheme(
      lineTheme: lineTheme ?? this.lineTheme,
      scrollbarTheme: scrollbarTheme ?? this.scrollbarTheme,
    );
  }

  /// Linearly interpolate between two [FlutterFolderViewTheme]s
  static FlutterFolderViewTheme lerp(
    FlutterFolderViewTheme? a,
    FlutterFolderViewTheme? b,
    double t,
  ) {
    if (a == null && b == null) {
      return FlutterFolderViewTheme.light();
    }
    if (a == null) return b!;
    if (b == null) return a;

    return FlutterFolderViewTheme(
      lineTheme: FolderViewLineTheme.lerp(a.lineTheme, b.lineTheme, t),
      scrollbarTheme: FolderViewScrollbarTheme.lerp(
        a.scrollbarTheme,
        b.scrollbarTheme,
        t,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is FlutterFolderViewTheme &&
        other.lineTheme == lineTheme &&
        other.scrollbarTheme == scrollbarTheme;
  }

  @override
  int get hashCode => Object.hash(lineTheme, scrollbarTheme);

  @override
  String toString() {
    return 'FlutterFolderViewTheme('
        'lineTheme: $lineTheme, '
        'scrollbarTheme: $scrollbarTheme'
        ')';
  }
}
