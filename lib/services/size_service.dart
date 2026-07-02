/// Viewport-level layout math for FolderView.
///
/// Per-row geometry and label-width measurement now live in [RowMetrics];
/// this holds only the viewport-scoped helpers — clamping the measured content
/// width and computing total content height.
class SizeService {
  /// Clamps a measured [contentWidth] to a sane ceiling of 3× the viewport.
  ///
  /// [contentWidth] is already expressed in the same (scaled) pixel space as
  /// [viewportWidth], so the ceiling must NOT be re-multiplied by any scale
  /// factor — doing so scales the bound a second time.
  static double clampContentWidth({
    required double contentWidth,
    required double viewportWidth,
  }) {
    final maxAllowed = viewportWidth * 3;
    return contentWidth.clamp(0.0, maxAllowed);
  }

  /// Calculate the total content height from a flat item count.
  ///
  /// Since all rows have the same fixed height, this is O(1).
  static double calculateContentHeight({
    required int itemCount,
    double rowHeight = 40.0,
    double rowSpacing = 0.0,
    double topPadding = 0.0,
    double bottomPadding = 0.0,
  }) {
    if (itemCount == 0) return topPadding + bottomPadding;

    final totalRowHeight = itemCount * rowHeight;
    final totalSpacing = (itemCount - 1) * rowSpacing;

    return totalRowHeight + totalSpacing + topPadding + bottomPadding;
  }
}
