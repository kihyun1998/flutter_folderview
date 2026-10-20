import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';

import 'tooltip_settings.dart' show TooltipCurve;

/// Which Nodes the `rowTooltipBuilder` sample builds a card for.
enum RowCardContent {
  /// No builder: `rowTooltipBuilder: null`, and no row is wrapped.
  off,

  /// A card for every Node.
  everyNode,

  /// A card for Folders and Parents; `null`, and no wrapper, for a Child.
  containersOnly,
}

/// The row-card settings: `FolderView.rowTooltipBuilder` as a sample choice,
/// and every `RowTooltipTheme` field.
///
/// `RowTooltipTheme`'s fields are not nullable, so each setting here starts
/// at the constructor default, and [theme] is `null` while none differs.
class RowCardSettings {
  RowCardSettings({required this.record});

  /// Adds an entry to the event log; the onShow / onHide samples call it.
  final void Function(String entry) record;

  static const _defaults = RowTooltipTheme();

  /// The surface the `surface` sample draws, for a builder that returns
  /// bare content.
  static const sampleSurface = JustTooltipTheme(
    backgroundColor: Color(0xFF263238),
    borderRadius: BorderRadius.all(Radius.circular(8)),
    padding: EdgeInsets.all(8),
    elevation: 4,
  );

  RowCardContent content = RowCardContent.off;
  TooltipDirection direction = _defaults.direction;
  TooltipAlignment alignment = _defaults.alignment;
  double offset = _defaults.offset;
  double crossAxisOffset = _defaults.crossAxisOffset;
  double screenMargin = _defaults.screenMargin;
  bool surface = false;
  bool interactive = _defaults.interactive;

  /// `waitDuration` and `showDuration` in milliseconds; 0 leaves it `null`.
  int waitMs = 0;
  int showMs = 0;
  bool enableHover = _defaults.enableHover;
  bool logShow = false;
  bool logHide = false;
  TooltipAnimation animation = _defaults.animation;
  TooltipCurve curve = TooltipCurve.unset;
  double animationMs = _defaults.animationDuration.inMilliseconds.toDouble();
  double fadeBegin = _defaults.fadeBegin;
  double scaleBegin = _defaults.scaleBegin;
  double slideOffset = _defaults.slideOffset;
  double rotationBegin = _defaults.rotationBegin;

  static Duration? _ms(int ms) => ms == 0 ? null : Duration(milliseconds: ms);

  void _onShow() => record('onShow · row card');
  void _onHide() => record('onHide · row card');

  /// The text the sample card shows for [node].
  static String cardText(Node<String> node) =>
      '${node.type.name}: ${node.label}';

  static Widget? _everyNode(BuildContext context, Node<String> node) => Card(
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Text(cardText(node)),
    ),
  );

  static Widget? _containersOnly(BuildContext context, Node<String> node) =>
      node.type == NodeType.child ? null : _everyNode(context, node);

  /// `FolderView.rowTooltipBuilder`.
  Widget? Function(BuildContext, Node<String>)? get builder =>
      switch (content) {
        RowCardContent.off => null,
        RowCardContent.everyNode => _everyNode,
        RowCardContent.containersOnly => _containersOnly,
      };

  /// The fields that differ from `RowTooltipTheme()`, as code lines.
  List<String> get _lines => [
    if (direction != _defaults.direction)
      'direction: TooltipDirection.${direction.name},',
    if (alignment != _defaults.alignment)
      'alignment: TooltipAlignment.${alignment.name},',
    if (offset != _defaults.offset) 'offset: ${_n(offset)},',
    if (crossAxisOffset != _defaults.crossAxisOffset)
      'crossAxisOffset: ${_n(crossAxisOffset)},',
    if (screenMargin != _defaults.screenMargin)
      'screenMargin: ${_n(screenMargin)},',
    if (surface)
      'surface: JustTooltipTheme(\n'
          '  backgroundColor: Color(0xFF263238),\n'
          '  borderRadius: BorderRadius.all(Radius.circular(8)),\n'
          '  padding: EdgeInsets.all(8),\n'
          '  elevation: 4,\n'
          '),',
    if (interactive != _defaults.interactive) 'interactive: $interactive,',
    if (waitMs != 0) 'waitDuration: Duration(milliseconds: $waitMs),',
    if (showMs != 0) 'showDuration: Duration(milliseconds: $showMs),',
    if (enableHover != _defaults.enableHover) 'enableHover: $enableHover,',
    if (animation != _defaults.animation)
      'animation: TooltipAnimation.${animation.name},',
    if (curve.curve != null) 'animationCurve: Curves.${curve.name},',
    if (animationMs != _defaults.animationDuration.inMilliseconds)
      'animationDuration: Duration(milliseconds: ${animationMs.round()}),',
    if (fadeBegin != _defaults.fadeBegin) 'fadeBegin: ${_n(fadeBegin)},',
    if (scaleBegin != _defaults.scaleBegin) 'scaleBegin: ${_n(scaleBegin)},',
    if (slideOffset != _defaults.slideOffset)
      'slideOffset: ${_n(slideOffset)},',
    if (rotationBegin != _defaults.rotationBegin)
      'rotationBegin: ${_n(rotationBegin)},',
    if (logShow) "onShow: () => debugPrint('onShow · row card'),",
    if (logHide) "onHide: () => debugPrint('onHide · row card'),",
  ];

  /// `FolderView.rowTooltipTheme`; `null` while every field is at its
  /// default.
  RowTooltipTheme? get theme => _lines.isEmpty
      ? null
      : RowTooltipTheme(
          direction: direction,
          alignment: alignment,
          offset: offset,
          crossAxisOffset: crossAxisOffset,
          screenMargin: screenMargin,
          surface: surface ? sampleSurface : const JustTooltipTheme.bare(),
          interactive: interactive,
          waitDuration: _ms(waitMs),
          showDuration: _ms(showMs),
          enableHover: enableHover,
          animation: animation,
          animationCurve: curve.curve,
          animationDuration: Duration(milliseconds: animationMs.round()),
          fadeBegin: fadeBegin,
          scaleBegin: scaleBegin,
          slideOffset: slideOffset,
          rotationBegin: rotationBegin,
          onShow: logShow ? _onShow : null,
          onHide: logHide ? _onHide : null,
        );

  static String _n(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toString();

  /// `rowTooltipBuilder` as the argument a caller would write.
  String get builderCode => switch (content) {
    RowCardContent.off => 'rowTooltipBuilder: null,',
    RowCardContent.everyNode =>
      'rowTooltipBuilder: (context, node) => Card(\n'
          '  child: Padding(\n'
          '    padding: const EdgeInsets.all(8),\n'
          "    child: Text('\${node.type.name}: \${node.label}'),\n"
          '  ),\n'
          '),',
    RowCardContent.containersOnly =>
      'rowTooltipBuilder: (context, node) => node.type == NodeType.child\n'
          '    ? null\n'
          '    : Card(\n'
          '        child: Padding(\n'
          '          padding: const EdgeInsets.all(8),\n'
          "          child: Text('\${node.type.name}: \${node.label}'),\n"
          '        ),\n'
          '      ),',
  };

  /// [theme] as the argument a caller would write.
  String get themeCode {
    final lines = _lines;
    if (lines.isEmpty) return 'rowTooltipTheme: null,';
    final body = lines
        .map((l) => l.split('\n').map((s) => '  $s').join('\n'))
        .join('\n');
    return 'rowTooltipTheme: RowTooltipTheme(\n$body\n),';
  }
}
