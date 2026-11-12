// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_smooth_wheel_scroll/flutter_smooth_wheel_scroll.dart';

class SyncedScrollControllers extends StatefulWidget {
  const SyncedScrollControllers({
    super.key,
    required this.builder,
    this.wheelMotion,
  });

  /// How the two main controllers move on mouse wheel input; `null` moves
  /// them at once.
  final WheelMotion? wheelMotion;

  final Widget Function(
    BuildContext context,
    ScrollController? verticalController,
    ScrollController? verticalScrollbarController,
    ScrollController? horizontalController,
    ScrollController? horizontalScrollbarController,
  )
  builder;

  @override
  State<SyncedScrollControllers> createState() =>
      _SyncedScrollControllersState();
}

class _SyncedScrollControllersState extends State<SyncedScrollControllers> {
  ScrollController? _sc11; // Main vertical (for ListView)
  ScrollController? _sc12; // Vertical scrollbar
  ScrollController? _sc21; // Main horizontal
  ScrollController? _sc22; // Horizontal scrollbar

  /// Listener map for each controller
  final Map<ScrollController, VoidCallback> _listenersMap = {};

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(SyncedScrollControllers oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.wheelMotion != oldWidget.wheelMotion) {
      for (final controller in [_sc11, _sc21]) {
        if (controller is SmoothScrollController) controller.motion = _motion;
      }
    }
  }

  /// A zero duration takes `ScrollController`'s own wheel path.
  static const WheelMotion _instant = WheelMotion.spring(
    duration: Duration.zero,
  );

  WheelMotion get _motion => widget.wheelMotion ?? _instant;

  @override
  void dispose() {
    _disposeOrUnsubscribe();
    super.dispose();
  }

  void _initControllers() {
    _doNotReissueJump.clear();

    /// Main vertical scroll controller
    _sc11 = SmoothScrollController(motion: _motion);

    /// Main horizontal scroll controller
    _sc21 = SmoothScrollController(motion: _motion);

    /// Vertical scrollbar controller
    _sc12 = ScrollbarController(body: _sc11!);

    /// Horizontal scrollbar controller
    _sc22 = ScrollbarController(body: _sc21!);

    _syncScrollControllers(_sc11!, _sc12!);
    _syncScrollControllers(_sc21!, _sc22!);
  }

  final Map<ScrollController, bool> _doNotReissueJump = {};

  void _syncScrollControllers(ScrollController master, ScrollController slave) {
    masterListener() => _jumpToNoCascade(master, slave);
    master.addListener(masterListener);
    _listenersMap[master] = masterListener;

    slaveListener() => _jumpToNoCascade(slave, master);
    slave.addListener(slaveListener);
    _listenersMap[slave] = slaveListener;
  }

  void _jumpToNoCascade(ScrollController master, ScrollController slave) {
    if (!master.hasClients || !slave.hasClients) {
      return;
    }

    if (_doNotReissueJump[master] == null ||
        _doNotReissueJump[master]! == false) {
      final clampedOffset = master.offset.clamp(
        slave.position.minScrollExtent,
        slave.position.maxScrollExtent,
      );
      if (clampedOffset != slave.offset) _doNotReissueJump[slave] = true;
      slave.jumpTo(clampedOffset);
    } else {
      _doNotReissueJump[master] = false;
    }
  }

  /// Moves the vertical scrollbar to the main vertical offset, clamped to the
  /// scrollbar's extent, when the two differ.
  void _verticalBarFollowsBody() {
    final body = _sc11;
    final bar = _sc12;
    if (body == null || bar == null) return;
    if (!body.hasClients || !bar.hasClients) return;
    final target = body.offset.clamp(
      bar.position.minScrollExtent,
      bar.position.maxScrollExtent,
    );
    if (target == bar.offset) return;
    _doNotReissueJump[bar] = true;
    bar.jumpTo(target);
  }

  /// Re-follows the vertical scrollbar on a change of the metrics of a
  /// vertical scroll view directly below this widget.
  bool _onScrollMetrics(ScrollMetricsNotification notification) {
    if (notification.depth == 0 && notification.metrics.axis == Axis.vertical) {
      _verticalBarFollowsBody();
    }
    return false;
  }

  void _disposeOrUnsubscribe() {
    _listenersMap.forEach((controller, listener) {
      controller.removeListener(listener);
    });
    _listenersMap.clear();

    _sc11?.dispose();
    _sc21?.dispose();
    _sc12?.dispose();
    _sc22?.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollMetricsNotification>(
        onNotification: _onScrollMetrics,
        child: widget.builder(context, _sc11, _sc12, _sc21, _sc22),
      );
}
