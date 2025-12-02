import 'dart:ui' show Color, StrokeCap;

import 'package:flutter/foundation.dart';

import '../models/node.dart';

/// Defines the visual appearance of connection lines in a FolderView
@immutable
class FolderViewLineTheme {
  /// The color of the connection lines
  final Color lineColor;

  /// The width/thickness of the connection lines
  final double lineWidth;

  /// The line style (connector, scope, or none)
  final LineStyle lineStyle;

  /// The stroke cap is always round for smooth line endings
  StrokeCap get strokeCap => StrokeCap.round;

  /// Creates a [FolderViewLineTheme] with the given properties
  const FolderViewLineTheme({
    required this.lineColor,
    this.lineWidth = 1.5,
    this.lineStyle = LineStyle.connector,
  });

  /// Creates a copy of this theme with the given fields replaced with new values
  FolderViewLineTheme copyWith({
    Color? lineColor,
    double? lineWidth,
    LineStyle? lineStyle,
  }) {
    return FolderViewLineTheme(
      lineColor: lineColor ?? this.lineColor,
      lineWidth: lineWidth ?? this.lineWidth,
      lineStyle: lineStyle ?? this.lineStyle,
    );
  }

  /// Linearly interpolate between two [FolderViewLineTheme]s
  static FolderViewLineTheme lerp(
    FolderViewLineTheme? a,
    FolderViewLineTheme? b,
    double t,
  ) {
    if (a == null && b == null) {
      return const FolderViewLineTheme(lineColor: Color(0xFF000000));
    }
    if (a == null) return b!;
    if (b == null) return a;

    return FolderViewLineTheme(
      lineColor: Color.lerp(a.lineColor, b.lineColor, t)!,
      lineWidth: lerpDouble(a.lineWidth, b.lineWidth, t),
      lineStyle: t < 0.5 ? a.lineStyle : b.lineStyle,
    );
  }

  /// Linear interpolation helper for doubles
  static double lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is FolderViewLineTheme &&
        other.lineColor == lineColor &&
        other.lineWidth == lineWidth &&
        other.lineStyle == lineStyle;
  }

  @override
  int get hashCode => Object.hash(lineColor, lineWidth, lineStyle);

  @override
  String toString() {
    return 'FolderViewLineTheme('
        'lineColor: $lineColor, '
        'lineWidth: $lineWidth, '
        'lineStyle: $lineStyle'
        ')';
  }
}
