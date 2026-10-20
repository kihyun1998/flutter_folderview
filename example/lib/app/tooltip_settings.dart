import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';

/// The Tier whose node-label tooltip the tooltip controls edit.
enum TooltipTier { folder, parent, child }

/// The `message` choices: the Tier's sample, a long one, empty, and unset.
enum TooltipMessage { sample, long, empty, unset }

/// The `animationCurve` choices; [unset] leaves it `null`, the raw linear
/// animation.
enum TooltipCurve {
  unset(null),
  easeOut(Curves.easeOut),
  easeInOut(Curves.easeInOut),
  easeOutBack(Curves.easeOutBack),
  bounceOut(Curves.bounceOut);

  const TooltipCurve(this.curve);

  final Curve? curve;
}

/// One Tier's node-label tooltip settings. `NodeTooltipTheme` is one class
/// shared by the three Tier themes, so the example keeps one of these per Tier
/// and binds a single set of controls to the chosen one.
///
/// The defaults are the library's: with [useTooltip] off the Tier gets no
/// tooltip theme at all, as both factories leave it. A surface setting left
/// `null` takes the library's fallback; a colour left `null` shows as the
/// empty swatch.
class TooltipSettings {
  TooltipSettings({
    required this.sampleMessage,
    required this.resolves,
    required this.resolvesCode,
    required this.resolvedText,
    required this.tierLabel,
    required this.record,
  });

  /// The Tier's name, as the event log shows it.
  final String tierLabel;

  /// Adds an entry to the event log; the onShow / onHide samples call it.
  final void Function(String entry) record;

  /// The message the Tier starts with.
  final String sampleMessage;

  /// Which Nodes the `tooltipBuilderResolver` sample builds for, as a test
  /// and as the code a caller would write; every other Node gets `null`.
  final bool Function(Node<String> node) resolves;
  final String resolvesCode;

  /// What the resolver sample shows.
  final String resolvedText;

  static const longMessage =
      'A longer tooltip message, to see the surface settings at work';

  static const builderText = 'Built by tooltipBuilder';

  static const textColors = <Color?>[
    null,
    Colors.amber,
    Colors.lightGreenAccent,
    Colors.black,
  ];
  static const backgroundColors = <Color?>[
    null,
    Colors.indigo,
    Colors.teal,
    Colors.deepOrange,
  ];
  static const borderColors = <Color?>[
    null,
    Colors.white,
    Colors.amber,
    Colors.redAccent,
  ];

  static const sampleShadow = [
    BoxShadow(color: Color(0x66000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  /// The library's fallbacks for the numeric and padding settings left
  /// `null`, which their controls show.
  static const fallbackElevation = 4.0;
  static const fallbackRadius = 6.0;
  static const fallbackPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  );
  static const fallbackBorderWidth = 0.0;

  /// The library's fallbacks for the behaviour and animation settings left
  /// `null`, which their controls show.
  static const fallbackEnableTap = false;
  static const fallbackEnableHover = true;
  static const fallbackInteractive = false;
  static const fallbackAnimation = TooltipAnimation.fade;
  static const fallbackAnimationMs = 150.0;
  static const fallbackFadeBegin = 0.0;
  static const fallbackScaleBegin = 0.0;
  static const fallbackSlideOffset = 0.3;
  static const fallbackRotationBegin = -0.05;

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

  TooltipMessage messageChoice = TooltipMessage.sample;

  /// The `message` [messageChoice] stands for.
  String? get message => switch (messageChoice) {
    TooltipMessage.sample => sampleMessage,
    TooltipMessage.long => longMessage,
    TooltipMessage.empty => '',
    TooltipMessage.unset => null,
  };
  Color? textColor;
  bool builder = false;
  bool resolver = false;
  Color? backgroundColor;
  double? elevation;
  bool boxShadow = false;
  double? borderRadius;
  EdgeInsets? padding;
  Color? borderColor;
  double? borderWidth;

  bool? enableTap;
  bool? enableHover;
  bool? interactive;

  /// `waitDuration` and `showDuration` in milliseconds; 0 leaves it `null`.
  int waitMs = 0;
  int showMs = 0;
  bool logShow = false;
  bool logHide = false;
  TooltipAnimation? animation;
  TooltipCurve curve = TooltipCurve.unset;
  double? animationMs;
  double? fadeBegin;
  double? scaleBegin;
  double? slideOffset;
  double? rotationBegin;

  static Duration? _ms(int ms) => ms == 0 ? null : Duration(milliseconds: ms);

  void _onShow() => record('onShow · $tierLabel tooltip');
  void _onHide() => record('onHide · $tierLabel tooltip');

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
    messageChoice = TooltipMessage.sample;
    textColor = null;
    builder = false;
    resolver = false;
    backgroundColor = null;
    elevation = null;
    boxShadow = false;
    borderRadius = null;
    padding = null;
    borderColor = null;
    borderWidth = null;
    enableTap = null;
    enableHover = null;
    interactive = null;
    waitMs = 0;
    showMs = 0;
    logShow = false;
    logHide = false;
    animation = null;
    curve = TooltipCurve.unset;
    animationMs = null;
    fadeBegin = null;
    scaleBegin = null;
    slideOffset = null;
    rotationBegin = null;
  }

  static Widget _builtContent(BuildContext context) => const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.info_outline, size: 16, color: Colors.white),
      SizedBox(width: 6),
      Text(builderText, style: TextStyle(color: Colors.white)),
    ],
  );

  WidgetBuilder? _resolve(Node<String> node) => resolves(node)
      ? (context) =>
            Text(resolvedText, style: const TextStyle(color: Colors.white))
      : null;

  /// The Tier's `tooltipTheme`; `null` while [useTooltip] is off.
  NodeTooltipTheme<String>? get theme => useTooltip
      ? NodeTooltipTheme<String>(
          useTooltip: true,
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
          message: message,
          textStyle: textColor == null ? null : TextStyle(color: textColor),
          tooltipBuilder: builder ? _builtContent : null,
          tooltipBuilderResolver: resolver ? _resolve : null,
          backgroundColor: backgroundColor,
          elevation: elevation,
          boxShadow: boxShadow ? sampleShadow : null,
          borderRadius: borderRadius == null
              ? null
              : BorderRadius.circular(borderRadius!),
          padding: padding,
          borderColor: borderColor,
          borderWidth: borderWidth,
          enableTap: enableTap,
          enableHover: enableHover,
          interactive: interactive,
          waitDuration: _ms(waitMs),
          showDuration: _ms(showMs),
          onShow: logShow ? _onShow : null,
          onHide: logHide ? _onHide : null,
          animation: animation,
          animationCurve: curve.curve,
          animationDuration: animationMs == null
              ? null
              : Duration(milliseconds: animationMs!.round()),
          fadeBegin: fadeBegin,
          scaleBegin: scaleBegin,
          slideOffset: slideOffset,
          rotationBegin: rotationBegin,
        )
      : null;

  static String _n(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toString();

  static String _color(Color c) =>
      'Color(0x${c.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()})';

  /// [theme] as the argument a caller would write.
  String get code {
    if (!useTooltip) return 'tooltipTheme: null,';
    final p = padding;
    return 'tooltipTheme: NodeTooltipTheme<String>(\n'
        '  useTooltip: true,\n'
        '  direction: TooltipDirection.${direction.name},\n'
        '  alignment: TooltipAlignment.${alignment.name},\n'
        '  anchor: TooltipAnchor.${anchor.name},\n'
        '  offset: ${_n(offset)},\n'
        '  crossAxisOffset: ${_n(crossAxisOffset)},\n'
        '  screenMargin: ${_n(screenMargin)},\n'
        '  showArrow: $showArrow,\n'
        '  arrowBaseWidth: ${_n(arrowBaseWidth)},\n'
        '  arrowLength: ${_n(arrowLength)},\n'
        '  arrowPositionRatio: ${_n(arrowPositionRatio)},\n'
        '${message == null ? '' : "  message: '$message',\n"}'
        '${textColor == null ? '' : '  textStyle: TextStyle(color: ${_color(textColor!)}),\n'}'
        '${builder ? "  tooltipBuilder: (context) => const Row(\n    mainAxisSize: MainAxisSize.min,\n    children: [\n      Icon(Icons.info_outline, size: 16, color: Colors.white),\n      SizedBox(width: 6),\n      Text('$builderText', style: TextStyle(color: Colors.white)),\n    ],\n  ),\n" : ''}'
        '${resolver ? "  tooltipBuilderResolver: (node) => $resolvesCode\n      ? (context) => const Text('$resolvedText', style: TextStyle(color: Colors.white))\n      : null,\n" : ''}'
        '${backgroundColor == null ? '' : '  backgroundColor: ${_color(backgroundColor!)},\n'}'
        '${elevation == null ? '' : '  elevation: ${_n(elevation!)},\n'}'
        '${boxShadow ? '  boxShadow: const [\n    BoxShadow(color: Color(0x66000000), blurRadius: 12, offset: Offset(0, 4)),\n  ],\n' : ''}'
        '${borderRadius == null ? '' : '  borderRadius: BorderRadius.circular(${_n(borderRadius!)}),\n'}'
        '${p == null ? '' : '  padding: EdgeInsets.fromLTRB(${_n(p.left)}, ${_n(p.top)}, ${_n(p.right)}, ${_n(p.bottom)}),\n'}'
        '${borderColor == null ? '' : '  borderColor: ${_color(borderColor!)},\n'}'
        '${borderWidth == null ? '' : '  borderWidth: ${_n(borderWidth!)},\n'}'
        '${enableTap == null ? '' : '  enableTap: $enableTap,\n'}'
        '${enableHover == null ? '' : '  enableHover: $enableHover,\n'}'
        '${interactive == null ? '' : '  interactive: $interactive,\n'}'
        '${waitMs == 0 ? '' : '  waitDuration: const Duration(milliseconds: $waitMs),\n'}'
        '${showMs == 0 ? '' : '  showDuration: const Duration(milliseconds: $showMs),\n'}'
        '${logShow ? "  onShow: () => debugPrint('onShow · $tierLabel tooltip'),\n" : ''}'
        '${logHide ? "  onHide: () => debugPrint('onHide · $tierLabel tooltip'),\n" : ''}'
        '${animation == null ? '' : '  animation: TooltipAnimation.${animation!.name},\n'}'
        '${curve.curve == null ? '' : '  animationCurve: Curves.${curve.name},\n'}'
        '${animationMs == null ? '' : '  animationDuration: const Duration(milliseconds: ${animationMs!.round()}),\n'}'
        '${fadeBegin == null ? '' : '  fadeBegin: ${_n(fadeBegin!)},\n'}'
        '${scaleBegin == null ? '' : '  scaleBegin: ${_n(scaleBegin!)},\n'}'
        '${slideOffset == null ? '' : '  slideOffset: ${_n(slideOffset!)},\n'}'
        '${rotationBegin == null ? '' : '  rotationBegin: ${_n(rotationBegin!)},\n'}'
        '),';
  }
}
