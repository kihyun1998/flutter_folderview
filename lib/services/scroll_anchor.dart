import '../models/flat_node.dart';
import 'flattener.dart';

/// Pure scroll-offset math for preserving viewport position across layout
/// changes. It computes target offsets; it never touches a ScrollController —
/// the widget applies the result (post-frame `jumpTo`, scrollbar re-sync).
///
/// Every method returns `null` (or a null field) when no adjustment is needed,
/// using a > 0.5px threshold to avoid churn.
class ScrollAnchor {
  ScrollAnchor._();

  /// New vertical offset after an incremental single-node change, or null when
  /// the change happened at/below the viewport top (so nothing visible moves).
  static double? verticalOffsetForFlattenChange({
    required FlattenChange change,
    required double currentOffset,
    required double itemExtent,
    required double topPadding,
    required double minScrollExtent,
    required double maxScrollExtent,
  }) {
    final changePixel = topPadding + (change.index + 1) * itemExtent;
    if (changePixel <= currentOffset) {
      final delta = change.deltaItems * itemExtent;
      return (currentOffset + delta).clamp(minScrollExtent, maxScrollExtent);
    }
    return null;
  }

  /// New vertical/horizontal offsets after a Scale change, preserving the node
  /// at the top of the viewport. A field is null when that axis needs no move.
  static ({double? vertical, double? horizontal}) offsetsForScaleChange({
    required double currentVerticalOffset,
    required double oldItemExtent,
    required double newItemExtent,
    required double oldTopPadding,
    required double newTopPadding,
    required double newContentHeight,
    required double viewportHeight,
    required double? currentHorizontalOffset,
    required double oldContentWidth,
    required double newContentWidth,
    required double hMinScrollExtent,
    required double hMaxScrollExtent,
  }) {
    // Vertical: map the top fractional item position into the new item extent.
    final topFractionalIndex = oldItemExtent > 0
        ? (currentVerticalOffset - oldTopPadding) / oldItemExtent
        : 0.0;
    final newOffset = newTopPadding + topFractionalIndex * newItemExtent;
    final newMaxExtent =
        (newContentHeight - viewportHeight).clamp(0.0, double.infinity);
    final clampedV = newOffset.clamp(0.0, newMaxExtent);
    final double? vertical =
        (clampedV - currentVerticalOffset).abs() > 0.5 ? clampedV : null;

    // Horizontal: scale the offset by the content-width ratio.
    double? horizontal;
    if (currentHorizontalOffset != null && oldContentWidth > 0) {
      final ratio = newContentWidth / oldContentWidth;
      final newH = currentHorizontalOffset * ratio;
      final clampedH = newH.clamp(hMinScrollExtent, hMaxScrollExtent);
      if ((clampedH - currentHorizontalOffset).abs() > 0.5) {
        horizontal = clampedH;
      }
    }

    return (vertical: vertical, horizontal: horizontal);
  }

  /// New vertical offset after a bulk list change (e.g. expandAll/collapseAll),
  /// anchoring to the top node — or its nearest surviving ancestor if it was
  /// removed. Null when no adjustment is needed.
  static double? verticalOffsetForBulkChange<T>({
    required List<FlatNode<T>> oldList,
    required List<FlatNode<T>> newList,
    required double currentOffset,
    required double itemExtent,
    required double topPadding,
    required double newContentHeight,
    required double viewportHeight,
  }) {
    if (identical(oldList, newList)) return null;
    if (oldList.isEmpty || newList.isEmpty) return null;

    final topIndex = ((currentOffset - topPadding) / itemExtent)
        .floor()
        .clamp(0, oldList.length - 1);

    var anchorPixelOffset =
        currentOffset - (topPadding + topIndex * itemExtent);

    int newIndex = -1;
    for (int i = topIndex; i >= 0; i--) {
      newIndex = newList.indexWhere((fn) => fn.node.id == oldList[i].node.id);
      if (newIndex >= 0) {
        if (i != topIndex) anchorPixelOffset = 0.0;
        break;
      }
    }
    if (newIndex < 0) return null;

    final targetOffset = topPadding + newIndex * itemExtent + anchorPixelOffset;
    final newMaxExtent =
        (newContentHeight - viewportHeight).clamp(0.0, double.infinity);
    final clamped = targetOffset.clamp(0.0, newMaxExtent);

    return (clamped - currentOffset).abs() > 0.5 ? clamped : null;
  }
}
