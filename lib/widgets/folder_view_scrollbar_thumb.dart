import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../themes/folder_view_scrollbar_theme.dart';

/// The `ScrollbarThemeData` a FolderView bar paints its thumb with.
///
/// The cross-axis margin is Material's own default for the platform, and the
/// thickness is capped so the thumb and that margin fit in `trackWidth`.
ScrollbarThemeData folderViewThumbTheme(
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
  return ScrollbarThemeData(
    thumbColor: WidgetStateProperty.all(theme.thumbColor),
    radius: Radius.circular(theme.radius),
    thickness: WidgetStateProperty.all(thickness),
    crossAxisMargin: margin,
  );
}
