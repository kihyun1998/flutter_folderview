import 'package:flutter/material.dart';

/// Defines the visual appearance of scrollbars in a FolderView
@immutable
class FolderViewScrollbarTheme {
  // Basic Scrollbar Properties
  /// The color of the scrollbar thumb
  final Color thumbColor;

  /// The color of the scrollbar track background
  final Color trackColor;

  /// The thickness of the scrollbar thumb
  final double thickness;

  /// The radius of the scrollbar thumb corners
  final double radius;

  /// Whether the scrollbar thumb is always visible
  final bool thumbVisibility;

  // Hover Properties
  /// The opacity of the scrollbar when hovering
  final double hoverOpacity;

  /// The opacity of the scrollbar when not hovering
  final double nonHoverOpacity;

  /// The duration of the hover animation
  final Duration hoverAnimationDuration;

  // Track Properties
  /// The total width of the scrollbar track (including padding)
  final double trackWidth;

  /// The radius of the scrollbar track corners
  final double trackRadius;

  /// Whether the scrollbar track is visible
  final bool trackVisibility;

  /// Creates a [FolderViewScrollbarTheme] with the given properties
  const FolderViewScrollbarTheme({
    required this.thumbColor,
    required this.trackColor,
    this.thickness = 12.0,
    this.radius = 4.0,
    this.thumbVisibility = true,
    this.hoverOpacity = 0.8,
    this.nonHoverOpacity = 0.0,
    this.hoverAnimationDuration = const Duration(milliseconds: 200),
    this.trackWidth = 16.0,
    this.trackRadius = 8.0,
    this.trackVisibility = false,
  });

  /// Creates a copy of this theme with the given fields replaced with new values
  FolderViewScrollbarTheme copyWith({
    Color? thumbColor,
    Color? trackColor,
    double? thickness,
    double? radius,
    bool? thumbVisibility,
    double? hoverOpacity,
    double? nonHoverOpacity,
    Duration? hoverAnimationDuration,
    double? trackWidth,
    double? trackRadius,
    bool? trackVisibility,
  }) {
    return FolderViewScrollbarTheme(
      thumbColor: thumbColor ?? this.thumbColor,
      trackColor: trackColor ?? this.trackColor,
      thickness: thickness ?? this.thickness,
      radius: radius ?? this.radius,
      thumbVisibility: thumbVisibility ?? this.thumbVisibility,
      hoverOpacity: hoverOpacity ?? this.hoverOpacity,
      nonHoverOpacity: nonHoverOpacity ?? this.nonHoverOpacity,
      hoverAnimationDuration:
          hoverAnimationDuration ?? this.hoverAnimationDuration,
      trackWidth: trackWidth ?? this.trackWidth,
      trackRadius: trackRadius ?? this.trackRadius,
      trackVisibility: trackVisibility ?? this.trackVisibility,
    );
  }

  /// Linearly interpolate between two [FolderViewScrollbarTheme]s
  static FolderViewScrollbarTheme lerp(
    FolderViewScrollbarTheme? a,
    FolderViewScrollbarTheme? b,
    double t,
  ) {
    if (a == null && b == null) {
      return FolderViewScrollbarTheme(
        thumbColor: const Color(0xFFFF0000),
        trackColor: const Color(0xFFEEEEEE),
      );
    }
    if (a == null) return b!;
    if (b == null) return a;

    return FolderViewScrollbarTheme(
      thumbColor: Color.lerp(a.thumbColor, b.thumbColor, t)!,
      trackColor: Color.lerp(a.trackColor, b.trackColor, t)!,
      thickness: lerpDouble(a.thickness, b.thickness, t),
      radius: lerpDouble(a.radius, b.radius, t),
      thumbVisibility: t < 0.5 ? a.thumbVisibility : b.thumbVisibility,
      hoverOpacity: lerpDouble(a.hoverOpacity, b.hoverOpacity, t),
      nonHoverOpacity: lerpDouble(a.nonHoverOpacity, b.nonHoverOpacity, t),
      hoverAnimationDuration:
          t < 0.5 ? a.hoverAnimationDuration : b.hoverAnimationDuration,
      trackWidth: lerpDouble(a.trackWidth, b.trackWidth, t),
      trackRadius: lerpDouble(a.trackRadius, b.trackRadius, t),
      trackVisibility: t < 0.5 ? a.trackVisibility : b.trackVisibility,
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
    return other is FolderViewScrollbarTheme &&
        other.thumbColor == thumbColor &&
        other.trackColor == trackColor &&
        other.thickness == thickness &&
        other.radius == radius &&
        other.thumbVisibility == thumbVisibility &&
        other.hoverOpacity == hoverOpacity &&
        other.nonHoverOpacity == nonHoverOpacity &&
        other.hoverAnimationDuration == hoverAnimationDuration &&
        other.trackWidth == trackWidth &&
        other.trackRadius == trackRadius &&
        other.trackVisibility == trackVisibility;
  }

  @override
  int get hashCode => Object.hash(
        thumbColor,
        trackColor,
        thickness,
        radius,
        thumbVisibility,
        hoverOpacity,
        nonHoverOpacity,
        hoverAnimationDuration,
        trackWidth,
        trackRadius,
        trackVisibility,
      );

  @override
  String toString() {
    return 'FolderViewScrollbarTheme('
        'thumbColor: $thumbColor, '
        'trackColor: $trackColor, '
        'thickness: $thickness, '
        'radius: $radius, '
        'thumbVisibility: $thumbVisibility, '
        'hoverOpacity: $hoverOpacity, '
        'nonHoverOpacity: $nonHoverOpacity, '
        'hoverAnimationDuration: $hoverAnimationDuration, '
        'trackWidth: $trackWidth, '
        'trackRadius: $trackRadius, '
        'trackVisibility: $trackVisibility'
        ')';
  }
}
