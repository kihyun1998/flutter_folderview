import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';
import 'package:just_tooltip/just_tooltip.dart';

/// Presentation and behaviour for the row card raised by
/// `FolderView.rowTooltipBuilder`.
///
/// Distinct from `NodeTooltipTheme`, which styles a Tier's label tooltip.
/// The two describe different things (see `FolderView.rowTooltipBuilder`) and
/// deliberately do not share fields — see ADR-0005.
///
/// Two of the underlying tooltip's knobs are not exposed, because the row card
/// fixes them:
///
///  * **the anchor** is always the pointer. A row is laid out at the tree's
///    content width, so anchoring to the row's rect would aim at a centre that
///    leaves the screen as soon as the view scrolls horizontally.
///  * **the content** comes from `rowTooltipBuilder`, so there is no `message`
///    or builder here.
///
/// Everything else, including the surface, is yours. The surface defaults to
/// nothing at all — no background, padding, elevation, border, or arrow —
/// because a card draws its own. Set [surface] to let the tooltip draw chrome
/// instead, for a builder that returns bare content.
///
/// Tooltips are chrome and excluded from `FlutterFolderViewTheme.scale`
/// (ADR-0004). This class therefore exposes no `scale` method.
@immutable
class RowTooltipTheme {
  /// Which side of the pointer the card is placed on. Flips automatically when
  /// there is no room.
  final TooltipDirection direction;

  /// Against a point there are no target edges to align to, so this selects
  /// which of the card's *own* edges lands on the pointer.
  final TooltipAlignment alignment;

  /// Distance between the pointer and the card.
  final double offset;

  /// Additional offset along the cross-axis of [direction].
  final double crossAxisOffset;

  /// Minimum distance the card keeps from the enclosing `Overlay`'s edges.
  final double screenMargin;

  /// The tooltip's own surface. Defaults to [JustTooltipTheme.bare] — nothing
  /// drawn — because a card supplies its own. Give it a real
  /// [JustTooltipTheme] when `rowTooltipBuilder` returns unadorned content.
  final JustTooltipTheme surface;

  /// Whether the card stays visible when the cursor moves onto it.
  ///
  /// Defaults to `true`. The card is anchored at the pointer, so it is drawn
  /// right beside the cursor and a small movement enters it; and a card is the
  /// kind of thing whose contents a user may want to reach.
  ///
  /// `NodeTooltipTheme.interactive` defaults to the opposite, and should: a
  /// label tooltip explains text you read and then leave. Do not "fix" the
  /// inconsistency — the two describe different things.
  final bool interactive;

  /// Delay before the card appears on hover. Null shows it immediately.
  final Duration? waitDuration;

  /// How long the card stays before hiding itself. Null keeps it while hovered.
  final Duration? showDuration;

  /// Whether hovering a row raises the card at all.
  final bool enableHover;

  final TooltipAnimation animation;
  final Curve? animationCurve;
  final Duration animationDuration;
  final double fadeBegin;
  final double scaleBegin;
  final double slideOffset;
  final double rotationBegin;

  /// Called when a card is shown / hidden.
  final VoidCallback? onShow;
  final VoidCallback? onHide;

  const RowTooltipTheme({
    this.direction = TooltipDirection.top,
    this.alignment = TooltipAlignment.center,
    this.offset = 8.0,
    this.crossAxisOffset = 0.0,
    this.screenMargin = 8.0,
    this.surface = const JustTooltipTheme.bare(),
    this.interactive = true,
    this.waitDuration,
    this.showDuration,
    this.enableHover = true,
    this.animation = TooltipAnimation.fade,
    this.animationCurve,
    this.animationDuration = const Duration(milliseconds: 150),
    this.fadeBegin = 0.0,
    this.scaleBegin = 0.0,
    this.slideOffset = 0.3,
    this.rotationBegin = -0.05,
    this.onShow,
    this.onHide,
  });

  RowTooltipTheme copyWith({
    TooltipDirection? direction,
    TooltipAlignment? alignment,
    double? offset,
    double? crossAxisOffset,
    double? screenMargin,
    JustTooltipTheme? surface,
    bool? interactive,
    Duration? waitDuration,
    Duration? showDuration,
    bool? enableHover,
    TooltipAnimation? animation,
    Curve? animationCurve,
    Duration? animationDuration,
    double? fadeBegin,
    double? scaleBegin,
    double? slideOffset,
    double? rotationBegin,
    VoidCallback? onShow,
    VoidCallback? onHide,
  }) {
    return RowTooltipTheme(
      direction: direction ?? this.direction,
      alignment: alignment ?? this.alignment,
      offset: offset ?? this.offset,
      crossAxisOffset: crossAxisOffset ?? this.crossAxisOffset,
      screenMargin: screenMargin ?? this.screenMargin,
      surface: surface ?? this.surface,
      interactive: interactive ?? this.interactive,
      waitDuration: waitDuration ?? this.waitDuration,
      showDuration: showDuration ?? this.showDuration,
      enableHover: enableHover ?? this.enableHover,
      animation: animation ?? this.animation,
      animationCurve: animationCurve ?? this.animationCurve,
      animationDuration: animationDuration ?? this.animationDuration,
      fadeBegin: fadeBegin ?? this.fadeBegin,
      scaleBegin: scaleBegin ?? this.scaleBegin,
      slideOffset: slideOffset ?? this.slideOffset,
      rotationBegin: rotationBegin ?? this.rotationBegin,
      onShow: onShow ?? this.onShow,
      onHide: onHide ?? this.onHide,
    );
  }

  /// Linearly interpolate between two [RowTooltipTheme]s.
  ///
  /// Non-interpolable fields snap at `t = 0.5`, as the other themes do.
  static RowTooltipTheme lerp(
    RowTooltipTheme? a,
    RowTooltipTheme? b,
    double t,
  ) {
    if (a == null && b == null) return const RowTooltipTheme();
    if (a == null) return b!;
    if (b == null) return a;

    return RowTooltipTheme(
      direction: t < 0.5 ? a.direction : b.direction,
      alignment: t < 0.5 ? a.alignment : b.alignment,
      offset: lerpDouble(a.offset, b.offset, t) ?? 8.0,
      crossAxisOffset:
          lerpDouble(a.crossAxisOffset, b.crossAxisOffset, t) ?? 0.0,
      screenMargin: lerpDouble(a.screenMargin, b.screenMargin, t) ?? 8.0,
      surface: t < 0.5 ? a.surface : b.surface,
      interactive: t < 0.5 ? a.interactive : b.interactive,
      waitDuration: t < 0.5 ? a.waitDuration : b.waitDuration,
      showDuration: t < 0.5 ? a.showDuration : b.showDuration,
      enableHover: t < 0.5 ? a.enableHover : b.enableHover,
      animation: t < 0.5 ? a.animation : b.animation,
      animationCurve: t < 0.5 ? a.animationCurve : b.animationCurve,
      animationDuration: t < 0.5 ? a.animationDuration : b.animationDuration,
      fadeBegin: lerpDouble(a.fadeBegin, b.fadeBegin, t) ?? 0.0,
      scaleBegin: lerpDouble(a.scaleBegin, b.scaleBegin, t) ?? 0.0,
      slideOffset: lerpDouble(a.slideOffset, b.slideOffset, t) ?? 0.3,
      rotationBegin: lerpDouble(a.rotationBegin, b.rotationBegin, t) ?? -0.05,
      onShow: t < 0.5 ? a.onShow : b.onShow,
      onHide: t < 0.5 ? a.onHide : b.onHide,
    );
  }
}
