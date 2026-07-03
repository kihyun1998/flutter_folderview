import 'package:flutter/widgets.dart';

import '../models/node.dart';
import '../themes/flutter_folder_view_theme.dart';

/// Single source of truth for a row's layout geometry and effective text style.
///
/// Both measurement ([SizeService]-driven width precompute) and rendering
/// ([NodeWidget]) read their facts from here, so measured width and rendered
/// width cannot drift apart. Build one per layout pass from the already-scaled
/// theme; [baseTextStyle] (the ambient `Theme.of(context).textTheme.bodyMedium`)
/// is only needed for measurement.
class RowMetrics<T> {
  final FlutterFolderViewTheme<T> theme;
  final TextStyle? baseTextStyle;

  RowMetrics({required this.theme, this.baseTextStyle});

  /// Cache of measured label widths, keyed by the style attributes that affect
  /// width. Self-invalidating: a different style produces a different key.
  static final Map<String, double> _textWidthCache = {};

  /// Width of the expand/collapse strip (icon box) — one indent unit.
  double get expandStripWidth =>
      theme.expandIconTheme.width +
      theme.expandIconTheme.padding.horizontal +
      theme.expandIconTheme.margin.horizontal;

  /// Horizontal indentation for a node at [depth]: one expand strip per level.
  double indentWidth(int depth) => depth * expandStripWidth;

  /// The theme-level text style for [node] — `textStyleResolver ?? textStyle`
  /// for its tier. This is the single resolution rule shared by rendering
  /// (which applies it via `Text.style` under the ambient `DefaultTextStyle`)
  /// and measurement (which merges [baseTextStyle] over it), so a per-node
  /// resolver affects measured width exactly as it affects rendered width.
  TextStyle? effectiveTextStyle(Node<T> node) {
    switch (node.type) {
      case NodeType.folder:
        return theme.folderTheme.textStyleResolver?.call(node) ??
            theme.folderTheme.textStyle;
      case NodeType.parent:
        return theme.parentTheme.textStyleResolver?.call(node) ??
            theme.parentTheme.textStyle;
      case NodeType.child:
        return theme.childTheme.textStyleResolver?.call(node) ??
            theme.childTheme.textStyle;
    }
  }

  /// Width of the tier icon box (icon width plus its horizontal padding/margin).
  double iconBoxWidth(NodeType type) {
    switch (type) {
      case NodeType.folder:
        return theme.folderTheme.width +
            theme.folderTheme.padding.horizontal +
            theme.folderTheme.margin.horizontal;
      case NodeType.parent:
        return theme.parentTheme.width +
            theme.parentTheme.padding.horizontal +
            theme.parentTheme.margin.horizontal;
      case NodeType.child:
        return theme.childTheme.width +
            theme.childTheme.padding.horizontal +
            theme.childTheme.margin.horizontal;
    }
  }

  /// Total width of a single row: indent + own expand strip + tier icon box +
  /// measured label + right content padding. Uses [baseTextStyle] merged with
  /// [effectiveTextStyle] so the measured label matches what is rendered.
  double measureNodeWidth(Node<T> node, int depth) =>
      _rowWidth(node, depth, _mergedStyle(node));

  /// The base-merged effective text style for [node]. Absent a per-node
  /// `textStyleResolver`, the result depends only on the node's tier, which
  /// lets [maxWidth] cache it per tier instead of merging per node.
  TextStyle _mergedStyle(Node<T> node) =>
      (baseTextStyle ?? const TextStyle(fontSize: 14))
          .merge(effectiveTextStyle(node));

  /// The single row-width formula shared by the per-node [measureNodeWidth] and
  /// the batched [maxWidth], so the two can never drift.
  double _rowWidth(Node<T> node, int depth, TextStyle style) =>
      indentWidth(depth) +
      expandStripWidth +
      iconBoxWidth(node.type) +
      _measureTextWidth(node.label, style) +
      theme.spacingTheme.contentPadding.right;

  /// Whether the tier for [type] resolves its text style per node.
  bool _hasTextStyleResolver(NodeType type) {
    switch (type) {
      case NodeType.folder:
        return theme.folderTheme.textStyleResolver != null;
      case NodeType.parent:
        return theme.parentTheme.textStyleResolver != null;
      case NodeType.child:
        return theme.childTheme.textStyleResolver != null;
    }
  }

  /// Widest row across the whole tree (all descendants, regardless of expand
  /// state) plus the left content padding — a stable width independent of which
  /// nodes are currently expanded.
  double maxWidth(List<Node<T>> nodes) {
    // Merge the effective style once per tier when the tier has no per-node
    // resolver (the common case), instead of allocating a merged TextStyle for
    // every node. Tiers with a resolver keep resolving per node (exact).
    final tierStyle = <NodeType, TextStyle>{};
    TextStyle styleOf(Node<T> node) => _hasTextStyleResolver(node.type)
        ? _mergedStyle(node)
        : (tierStyle[node.type] ??= _mergedStyle(node));

    var widest = 0.0;
    void visit(List<Node<T>> list, int depth) {
      for (final node in list) {
        final w = _rowWidth(node, depth, styleOf(node));
        if (w > widest) widest = w;
        if (node.children.isNotEmpty) visit(node.children, depth + 1);
      }
    }

    visit(nodes, 0);
    return theme.spacingTheme.contentPadding.left + widest;
  }

  static double _measureTextWidth(String label, TextStyle style) {
    final key = '$label\x00${style.fontSize}'
        '\x00${style.fontWeight}\x00${style.letterSpacing}';
    return _textWidthCache[key] ??= (TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout())
        .width;
  }
}
