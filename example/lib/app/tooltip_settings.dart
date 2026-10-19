import 'package:flutter_folderview/flutter_folderview.dart';

/// The Tier whose node-label tooltip the tooltip controls edit.
enum TooltipTier { folder, parent, child }

/// One Tier's node-label tooltip settings. `NodeTooltipTheme` is one class
/// shared by the three Tier themes, so the example keeps one of these per Tier
/// and binds a single set of controls to the chosen one.
///
/// The defaults are the library's: with [useTooltip] off the Tier gets no
/// tooltip theme at all, as both factories leave it.
class TooltipSettings {
  bool useTooltip = false;
  TooltipDirection direction = TooltipDirection.top;
  TooltipAlignment alignment = TooltipAlignment.center;
  TooltipAnchor anchor = TooltipAnchor.child;
  double offset = 8;
  double crossAxisOffset = 0;
  double screenMargin = 8;
  bool showArrow = false;
  double arrowBaseWidth = 12;
  double arrowLength = 6;
  double arrowPositionRatio = 0.25;

  /// Whether the Tier renders as a factory theme leaves it: no tooltip. The
  /// other settings are not drawn while [useTooltip] is off.
  bool get matchesFactory => !useTooltip;

  /// Back to the defaults.
  void reset() {
    useTooltip = false;
    direction = TooltipDirection.top;
    alignment = TooltipAlignment.center;
    anchor = TooltipAnchor.child;
    offset = 8;
    crossAxisOffset = 0;
    screenMargin = 8;
    showArrow = false;
    arrowBaseWidth = 12;
    arrowLength = 6;
    arrowPositionRatio = 0.25;
  }

  /// The Tier's `tooltipTheme`, showing [message]; `null` while [useTooltip]
  /// is off.
  NodeTooltipTheme<String>? theme(String message) => useTooltip
      ? NodeTooltipTheme<String>(
          useTooltip: true,
          message: message,
          direction: direction,
          alignment: alignment,
          anchor: anchor,
          offset: offset,
          crossAxisOffset: crossAxisOffset,
          screenMargin: screenMargin,
          showArrow: showArrow,
          arrowBaseWidth: arrowBaseWidth,
          arrowLength: arrowLength,
          arrowPositionRatio: arrowPositionRatio,
        )
      : null;

  /// [theme] as the argument a caller would write.
  String code(String message) {
    if (!useTooltip) return 'tooltipTheme: null,';
    String n(double v) =>
        v == v.roundToDouble() ? v.round().toString() : v.toString();
    return 'tooltipTheme: NodeTooltipTheme<String>(\n'
        '  useTooltip: true,\n'
        "  message: '$message',\n"
        '  direction: TooltipDirection.${direction.name},\n'
        '  alignment: TooltipAlignment.${alignment.name},\n'
        '  anchor: TooltipAnchor.${anchor.name},\n'
        '  offset: ${n(offset)},\n'
        '  crossAxisOffset: ${n(crossAxisOffset)},\n'
        '  screenMargin: ${n(screenMargin)},\n'
        '  showArrow: $showArrow,\n'
        '  arrowBaseWidth: ${n(arrowBaseWidth)},\n'
        '  arrowLength: ${n(arrowLength)},\n'
        '  arrowPositionRatio: ${n(arrowPositionRatio)},\n'
        '),';
  }
}
