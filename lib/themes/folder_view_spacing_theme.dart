import 'package:flutter/material.dart';

/// Theme class for spacing and padding in FolderView
///
/// Controls the spacing of content within the FolderView widget,
/// including padding around the list content.
@immutable
class FolderViewSpacingTheme {
  /// Padding applied to the ListView content
  ///
  /// This affects the internal spacing of the list items:
  /// - Left/Right: Creates margins on the sides (scrollbar stays at edge)
  /// - Top/Bottom: Creates spacing at the top and bottom of the list
  final EdgeInsets contentPadding;

  /// Creates a [FolderViewSpacingTheme] with the given properties
  const FolderViewSpacingTheme({this.contentPadding = EdgeInsets.zero});

  /// Returns a scaled copy with [contentPadding] multiplied by [factor].
  ///
  /// Identity: `scale(1.0)` returns `this`.
  FolderViewSpacingTheme scale(double factor) {
    assert(factor > 0, 'scale factor must be > 0, got $factor');
    if (factor == 1.0) return this;
    return copyWith(contentPadding: contentPadding * factor);
  }

  /// Creates a copy of this theme with the given fields replaced
  FolderViewSpacingTheme copyWith({EdgeInsets? contentPadding}) {
    return FolderViewSpacingTheme(
      contentPadding: contentPadding ?? this.contentPadding,
    );
  }

  /// Linearly interpolate between two [FolderViewSpacingTheme]s
  static FolderViewSpacingTheme lerp(
    FolderViewSpacingTheme? a,
    FolderViewSpacingTheme? b,
    double t,
  ) {
    if (a == null && b == null) return const FolderViewSpacingTheme();
    if (a == null) return b!;
    if (b == null) return a;

    return FolderViewSpacingTheme(
      contentPadding: EdgeInsets.lerp(a.contentPadding, b.contentPadding, t) ??
          EdgeInsets.zero,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is FolderViewSpacingTheme &&
        other.contentPadding == contentPadding;
  }

  @override
  int get hashCode => contentPadding.hashCode;

  @override
  String toString() {
    return 'FolderViewSpacingTheme(contentPadding: $contentPadding)';
  }
}
