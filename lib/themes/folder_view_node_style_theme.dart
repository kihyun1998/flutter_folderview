import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Theme class for node visual styling in FolderView
///
/// Controls the visual appearance of nodes such as border radius,
/// hover effects, and other style properties.
@immutable
class FolderViewNodeStyleTheme {
  /// Border radius for node containers
  final double borderRadius;

  /// Creates a [FolderViewNodeStyleTheme] with the given properties
  const FolderViewNodeStyleTheme({this.borderRadius = 8.0});

  /// Returns a scaled copy with [borderRadius] multiplied by [factor].
  ///
  /// Identity: `scale(1.0)` returns `this`.
  FolderViewNodeStyleTheme scale(double factor) {
    assert(factor > 0, 'scale factor must be > 0, got $factor');
    if (factor == 1.0) return this;
    return copyWith(borderRadius: borderRadius * factor);
  }

  /// Creates a copy of this theme with the given fields replaced
  FolderViewNodeStyleTheme copyWith({double? borderRadius}) {
    return FolderViewNodeStyleTheme(
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  /// Linearly interpolate between two [FolderViewNodeStyleTheme]s
  static FolderViewNodeStyleTheme lerp(
    FolderViewNodeStyleTheme? a,
    FolderViewNodeStyleTheme? b,
    double t,
  ) {
    if (a == null && b == null) return const FolderViewNodeStyleTheme();
    if (a == null) return b!;
    if (b == null) return a;

    return FolderViewNodeStyleTheme(
      borderRadius: lerpDouble(a.borderRadius, b.borderRadius, t) ?? 8.0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is FolderViewNodeStyleTheme &&
        other.borderRadius == borderRadius;
  }

  @override
  int get hashCode => borderRadius.hashCode;

  @override
  String toString() {
    return 'FolderViewNodeStyleTheme(borderRadius: $borderRadius)';
  }
}
