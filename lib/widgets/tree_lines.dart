import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/flat_node.dart';
import '../models/node.dart';
import '../themes/folder_view_line_theme.dart';

/// The geometry of the connector/indent lines for a single flattened row.
///
/// This is the pure, testable core of tree-line rendering: it decides *where*
/// lines go (in absolute x-centres) from a [FlatNode]'s position flags. It
/// carries no colour/width/style — those are applied by [TreeLinesPainter] at
/// paint time.
@immutable
class TreeLinePlan {
  /// Absolute x-centres of full-height vertical guides — one for each ancestor
  /// that still has siblings below it, so the guide "continues" past this row.
  final List<double> continuationXs;

  /// Absolute x-centre of this row's own connector, or null for a root row
  /// (a root has no parent to connect to).
  final double? connectorX;

  /// Whether this row is its parent's last child — the connector's vertical
  /// then stops at mid-row instead of running the full row height.
  final bool connectorIsLast;

  /// Absolute x where the connector's horizontal stub ends (the right edge of
  /// the connector column). Only meaningful when [connectorX] is non-null.
  final double connectorEndX;

  const TreeLinePlan({
    required this.continuationXs,
    required this.connectorX,
    required this.connectorIsLast,
    required this.connectorEndX,
  });

  /// Derives the line plan for [row]. Each column is [lineWidth] wide and lines
  /// are centred within their column.
  factory TreeLinePlan.forRow({
    required FlatNode row,
    required double lineWidth,
  }) {
    final continuationXs = <double>[];
    for (var d = 0; d < row.depth; d++) {
      // Bit d clear => the ancestor at depth d still has siblings below, so its
      // vertical guide continues through this row.
      if ((row.ancestorIsLastMask >> d) & 1 == 0) {
        continuationXs.add(d * lineWidth + lineWidth / 2);
      }
    }

    if (row.isRoot) {
      return TreeLinePlan(
        continuationXs: continuationXs,
        connectorX: null,
        connectorIsLast: false,
        connectorEndX: 0,
      );
    }

    return TreeLinePlan(
      continuationXs: continuationXs,
      connectorX: (row.depth - 1) * lineWidth + lineWidth / 2,
      connectorIsLast: row.isLast,
      connectorEndX: row.depth * lineWidth,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TreeLinePlan &&
      listEquals(other.continuationXs, continuationXs) &&
      other.connectorX == connectorX &&
      other.connectorIsLast == connectorIsLast &&
      other.connectorEndX == connectorEndX;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(continuationXs),
        connectorX,
        connectorIsLast,
        connectorEndX,
      );
}

/// Paints a row's connector and ancestor continuation lines in one pass,
/// replacing the previous per-line painters.
class TreeLinesPainter extends CustomPainter {
  final TreeLinePlan plan;
  final FolderViewLineTheme lineTheme;
  final double rowHeight;

  const TreeLinesPainter({
    required this.plan,
    required this.lineTheme,
    required this.rowHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (lineTheme.lineStyle == LineStyle.none) return;

    final paint = Paint()
      ..color = lineTheme.lineColor
      ..strokeWidth = lineTheme.lineWidth
      ..strokeCap = lineTheme.strokeCap
      ..style = PaintingStyle.stroke;

    // Ancestor continuation guides: always full-height verticals.
    for (final x in plan.continuationXs) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    final cx = plan.connectorX;
    if (cx == null) return;

    switch (lineTheme.lineStyle) {
      case LineStyle.connector:
        // Vertical: top to mid-row (last child) or full height otherwise.
        canvas.drawLine(
          Offset(cx, 0),
          Offset(cx, plan.connectorIsLast ? rowHeight / 2 : size.height),
          paint,
        );
        // Horizontal stub into the content column.
        final connectorY = rowHeight / 2;
        canvas.drawLine(
          Offset(cx, connectorY),
          Offset(plan.connectorEndX, connectorY),
          paint,
        );
        break;
      case LineStyle.scope:
        canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), paint);
        break;
      case LineStyle.none:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant TreeLinesPainter oldDelegate) {
    return oldDelegate.plan != plan ||
        oldDelegate.lineTheme != lineTheme ||
        oldDelegate.rowHeight != rowHeight;
  }
}

/// Renders the tree lines (connector + ancestor continuations) for one row.
///
/// Small interface — a [FlatNode] plus line theme, row height and column width
/// — over the whole line-geometry implementation. Place it in a [Stack] behind
/// the row content (e.g. via `Positioned.fill`).
class TreeLines extends StatelessWidget {
  final FlatNode flatNode;
  final FolderViewLineTheme lineTheme;
  final double rowHeight;
  final double lineWidth;

  const TreeLines({
    super.key,
    required this.flatNode,
    required this.lineTheme,
    required this.rowHeight,
    required this.lineWidth,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: TreeLinesPainter(
        plan: TreeLinePlan.forRow(row: flatNode, lineWidth: lineWidth),
        lineTheme: lineTheme,
        rowHeight: rowHeight,
      ),
    );
  }
}
