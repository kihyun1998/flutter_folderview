import 'dart:math' as math;

// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../themes/folder_view_scrollbar_theme.dart';

/// The cross-axis margin and thickness a FolderView bar paints its thumb with.
///
/// The margin is Material's own default for the platform, and the thickness is
/// capped so the thumb and that margin fit in `trackWidth`.
({double margin, double thickness}) _thumbMetrics(
  BuildContext context,
  FolderViewScrollbarTheme theme,
) {
  final margin = Theme.of(context).platform == TargetPlatform.android
      ? 0.0
      : 2.0;
  final thickness = math.max(
    0.0,
    math.min(theme.thickness, theme.trackWidth - margin),
  );
  return (margin: margin, thickness: thickness);
}

/// The `ScrollbarThemeData` a FolderView bar paints its thumb with.
ScrollbarThemeData folderViewThumbTheme(
  BuildContext context,
  FolderViewScrollbarTheme theme,
) {
  final metrics = _thumbMetrics(context, theme);
  return ScrollbarThemeData(
    thumbColor: WidgetStateProperty.all(theme.thumbColor),
    radius: Radius.circular(theme.radius),
    thickness: WidgetStateProperty.all(metrics.thickness),
    crossAxisMargin: metrics.margin,
  );
}

/// Material's `Scrollbar` minimum thumb length.
const double _materialMinThumbLength = 48;

/// `RawScrollbar`'s default minimum thumb length, which Material's `Scrollbar`
/// keeps as its minimum overscroll length.
const double _rawMinOverscrollLength = 18;

/// The thumb of a FolderView bar over [child], painted from [theme].
///
/// A Material `Scrollbar` under a `ScrollbarTheme` of [folderViewThumbTheme] on
/// every platform but iOS. On iOS, a `RawScrollbar` with the values Material's
/// `Scrollbar` paints with on desktop. On every platform the thumb takes drags
/// and the track takes taps.
class FolderViewScrollbarThumb extends StatelessWidget {
  const FolderViewScrollbarThumb({
    super.key,
    required this.controller,
    required this.theme,
    required this.child,
  });

  final ScrollController controller;
  final FolderViewScrollbarTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      final metrics = _thumbMetrics(context, theme);
      return RawScrollbar(
        controller: controller,
        thumbVisibility: theme.thumbVisibility,
        thumbColor: theme.thumbColor,
        thickness: metrics.thickness,
        radius: Radius.circular(theme.radius),
        crossAxisMargin: metrics.margin,
        minThumbLength: _materialMinThumbLength,
        minOverscrollLength: _rawMinOverscrollLength,
        child: child,
      );
    }
    return ScrollbarTheme(
      data: folderViewThumbTheme(context, theme),
      child: Scrollbar(
        controller: controller,
        thumbVisibility: theme.thumbVisibility,
        interactive: true,
        child: child,
      ),
    );
  }
}
