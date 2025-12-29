import 'package:flutter/material.dart';

import '../models/node.dart';
import 'folder_view_icon_theme.dart';
import 'folder_view_line_theme.dart';
import 'folder_view_node_style_theme.dart';
import 'folder_view_scrollbar_theme.dart';
import 'folder_view_spacing_theme.dart';
import 'folder_view_text_theme.dart';

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

  /// Theme for text styles
  final FolderViewTextTheme textTheme;

  /// Theme for icons
  final FolderViewIconTheme iconTheme;

  /// Theme for spacing and padding
  final FolderViewSpacingTheme spacingTheme;

  /// Theme for node visual styling
  final FolderViewNodeStyleTheme nodeStyleTheme;

  // Future theme properties can be added here:
  // final FolderViewAnimationTheme? animationTheme;

  /// Creates a [FlutterFolderViewTheme] with the given properties
  const FlutterFolderViewTheme({
    required this.lineTheme,
    required this.scrollbarTheme,
    this.textTheme = const FolderViewTextTheme(),
    this.iconTheme = const FolderViewIconTheme(),
    this.spacingTheme = const FolderViewSpacingTheme(),
    this.nodeStyleTheme = const FolderViewNodeStyleTheme(),
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
      textTheme: const FolderViewTextTheme(
        textStyle: TextStyle(color: Colors.black87),
        selectedTextStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      iconTheme: FolderViewIconTheme(
        iconSize: 20.0,
        iconColor: Colors.grey.shade700,
        selectedIconColor: Colors.blue.shade700,
      ),
      spacingTheme: const FolderViewSpacingTheme(),
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
      textTheme: const FolderViewTextTheme(
        textStyle: TextStyle(color: Colors.white70),
        selectedTextStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      iconTheme: FolderViewIconTheme(
        iconSize: 20.0,
        iconColor: Colors.grey.shade400,
        selectedIconColor: Colors.blue.shade300,
      ),
      spacingTheme: const FolderViewSpacingTheme(),
    );
  }

  /// Creates a copy of this theme with the given fields replaced with new values
  FlutterFolderViewTheme copyWith({
    FolderViewLineTheme? lineTheme,
    FolderViewScrollbarTheme? scrollbarTheme,
    FolderViewTextTheme? textTheme,
    FolderViewIconTheme? iconTheme,
    FolderViewSpacingTheme? spacingTheme,
    FolderViewNodeStyleTheme? nodeStyleTheme,
  }) {
    return FlutterFolderViewTheme(
      lineTheme: lineTheme ?? this.lineTheme,
      scrollbarTheme: scrollbarTheme ?? this.scrollbarTheme,
      textTheme: textTheme ?? this.textTheme,
      iconTheme: iconTheme ?? this.iconTheme,
      spacingTheme: spacingTheme ?? this.spacingTheme,
      nodeStyleTheme: nodeStyleTheme ?? this.nodeStyleTheme,
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
      textTheme: FolderViewTextTheme.lerp(a.textTheme, b.textTheme, t),
      iconTheme: FolderViewIconTheme.lerp(a.iconTheme, b.iconTheme, t),
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
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is FlutterFolderViewTheme &&
        other.lineTheme == lineTheme &&
        other.scrollbarTheme == scrollbarTheme &&
        other.textTheme == textTheme &&
        other.iconTheme == iconTheme &&
        other.spacingTheme == spacingTheme &&
        other.nodeStyleTheme == nodeStyleTheme;
  }

  @override
  int get hashCode => Object.hash(
        lineTheme,
        scrollbarTheme,
        textTheme,
        iconTheme,
        spacingTheme,
        nodeStyleTheme,
      );

  @override
  String toString() {
    return 'FlutterFolderViewTheme('
        'lineTheme: $lineTheme, '
        'scrollbarTheme: $scrollbarTheme, '
        'textTheme: $textTheme, '
        'iconTheme: $iconTheme, '
        'spacingTheme: $spacingTheme, '
        'nodeStyleTheme: $nodeStyleTheme'
        ')';
  }
}
