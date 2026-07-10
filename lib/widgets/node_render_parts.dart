import 'package:flutter/widgets.dart';
import 'package:just_tooltip/just_tooltip.dart';

import '../models/node.dart';
import '../themes/node_tooltip_theme.dart';

/// A tier icon box: renders [iconWidget] inside its padding/margin box, or an
/// empty spacer of [emptyWidth] when null. When [scale] != 1 the icon is fit
/// into the (scaled) box with a [FittedBox].
class NodeIconBox extends StatelessWidget {
  final Widget? iconWidget;
  final double width;
  final double height;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double emptyWidth;
  final double scale;

  const NodeIconBox({
    super.key,
    required this.iconWidget,
    required this.width,
    required this.height,
    required this.padding,
    required this.margin,
    required this.emptyWidth,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final icon = iconWidget;
    if (icon == null) {
      return SizedBox(width: emptyWidth);
    }
    return Container(
      margin: margin,
      padding: padding,
      child: SizedBox(
        width: width,
        height: height,
        child: scale != 1.0 ? FittedBox(child: icon) : icon,
      ),
    );
  }
}

/// The shared "icon + label" content, left-aligned. The tier's label tooltip
/// wraps the glyphs alone — see [build]. Used by the Child and Expandable
/// renderers.
class NodeLabel<T> extends StatelessWidget {
  final Widget iconBox;
  final String label;
  final TextStyle? style;
  final NodeTooltipTheme<T>? tooltipTheme;
  final Node<T> node;

  const NodeLabel({
    super.key,
    required this.iconBox,
    required this.label,
    required this.style,
    required this.tooltipTheme,
    required this.node,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconBox,
          Flexible(
            // The tooltip wraps the glyphs, not the icon and not the box
            // [Flexible] grows to fill. A label tooltip explains the label, so
            // the label is its hover region; everything else on the row is left
            // free for `FolderView.rowTooltipBuilder`, which nests outside this
            // one and is suppressed wherever this one contains the pointer.
            child: wrapWithNodeTooltip<T>(
              tooltipTheme: tooltipTheme,
              node: node,
              child: Text(
                label,
                style: style,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Wraps [child] in a [JustTooltip] built from [tooltipTheme], or returns
/// [child] unchanged when tooltips are disabled or there is no content.
Widget wrapWithNodeTooltip<T>({
  required Widget child,
  required NodeTooltipTheme<T>? tooltipTheme,
  required Node<T> node,
}) {
  if (tooltipTheme == null || !tooltipTheme.useTooltip) {
    return child;
  }

  // Resolve tooltip content: tooltipBuilderResolver > tooltipBuilder > message
  WidgetBuilder? resolvedBuilder;
  if (tooltipTheme.tooltipBuilderResolver != null) {
    resolvedBuilder = tooltipTheme.tooltipBuilderResolver?.call(node);
  }
  resolvedBuilder ??= tooltipTheme.tooltipBuilder;

  final String? message = tooltipTheme.message;

  if (resolvedBuilder == null && (message == null || message.isEmpty)) {
    return child;
  }

  return JustTooltip(
    direction: tooltipTheme.direction,
    alignment: tooltipTheme.alignment,
    anchor: tooltipTheme.anchor,
    offset: tooltipTheme.offset,
    crossAxisOffset: tooltipTheme.crossAxisOffset,
    screenMargin: tooltipTheme.screenMargin ?? 8.0,
    theme: JustTooltipTheme(
      textStyle: tooltipTheme.textStyle,
      backgroundColor: tooltipTheme.backgroundColor ?? const Color(0xFF616161),
      borderRadius: tooltipTheme.borderRadius ??
          const BorderRadius.all(Radius.circular(6)),
      padding: tooltipTheme.padding ??
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: tooltipTheme.elevation ?? 4.0,
      boxShadow: tooltipTheme.boxShadow,
      borderColor: tooltipTheme.borderColor,
      borderWidth: tooltipTheme.borderWidth ?? 0.0,
      showArrow: tooltipTheme.showArrow ?? false,
      arrowBaseWidth: tooltipTheme.arrowBaseWidth ?? 12.0,
      arrowLength: tooltipTheme.arrowLength ?? 6.0,
      arrowPositionRatio: tooltipTheme.arrowPositionRatio ?? 0.25,
    ),
    controller: tooltipTheme.controller,
    enableTap: tooltipTheme.enableTap ?? false,
    enableHover: tooltipTheme.enableHover ?? true,
    animation: tooltipTheme.animation ?? TooltipAnimation.fade,
    animationCurve: tooltipTheme.animationCurve,
    fadeBegin: tooltipTheme.fadeBegin ?? 0.0,
    scaleBegin: tooltipTheme.scaleBegin ?? 0.0,
    slideOffset: tooltipTheme.slideOffset ?? 0.3,
    rotationBegin: tooltipTheme.rotationBegin ?? -0.05,
    animationDuration:
        tooltipTheme.animationDuration ?? const Duration(milliseconds: 150),
    onShow: tooltipTheme.onShow,
    onHide: tooltipTheme.onHide,
    interactive: tooltipTheme.interactive ?? false,
    waitDuration: tooltipTheme.waitDuration,
    showDuration: tooltipTheme.showDuration,
    hideOnEmptyMessage: tooltipTheme.hideOnEmptyMessage ?? true,
    message: resolvedBuilder == null ? message : null,
    tooltipBuilder: resolvedBuilder,
    child: child,
  );
}
