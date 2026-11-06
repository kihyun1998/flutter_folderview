// ignore_for_file: public_member_api_docs, sort_constructors_first
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
    _sc12 = _ScrollbarController(main: _sc11!);

    /// Horizontal scrollbar controller
    _sc22 = _ScrollbarController(main: _sc21!);

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
      _doNotReissueJump[slave] = true;
      final clampedOffset = master.offset.clamp(
        slave.position.minScrollExtent,
        slave.position.maxScrollExtent,
      );
      slave.jumpTo(clampedOffset);
    } else {
      _doNotReissueJump[master] = false;
    }
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
      widget.builder(context, _sc11, _sc12, _sc21, _sc22);
}

/// A scrollbar's controller: wheel input goes to [main], and a press or a track
/// tap stays on this controller and stops [main]'s motion.
class _ScrollbarController extends ScrollController {
  _ScrollbarController({required this.main});

  final ScrollController main;

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return _ScrollbarPosition(
      main: main,
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }
}

class _ScrollbarPosition extends ScrollPositionWithSingleContext {
  _ScrollbarPosition({
    required this.main,
    required super.physics,
    required super.context,
    super.initialPixels,
    super.keepScrollOffset,
    super.oldPosition,
    super.debugLabel,
  });

  final ScrollController main;

  @override
  void pointerScroll(double delta) {
    if (main.hasClients) main.position.pointerScroll(delta);
  }

  @override
  ScrollHoldController hold(VoidCallback holdCancelCallback) {
    _stopMainMotion();
    return super.hold(holdCancelCallback);
  }

  @override
  Future<void> animateTo(
    double to, {
    required Duration duration,
    required Curve curve,
  }) {
    _stopMainMotion();
    return super.animateTo(to, duration: duration, curve: curve);
  }

  void _stopMainMotion() {
    if (main.hasClients) main.position.jumpTo(main.position.pixels);
  }
}
