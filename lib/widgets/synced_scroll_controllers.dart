// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class SyncedScrollControllers extends StatefulWidget {
  const SyncedScrollControllers({
    super.key,
    required this.builder,
  });

  final Widget Function(
    BuildContext context,
    ScrollController? verticalController,
    ScrollController? verticalScrollbarController,
    ScrollController? horizontalController,
    ScrollController? horizontalScrollbarController,
  ) builder;

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
  void dispose() {
    _disposeOrUnsubscribe();
    super.dispose();
  }

  void _initControllers() {
    _doNotReissueJump.clear();

    /// Main vertical scroll controller
    _sc11 = ScrollController();

    /// Main horizontal scroll controller
    _sc21 = ScrollController();

    /// Vertical scrollbar controller
    _sc12 = ScrollController(initialScrollOffset: 0.0);
    
    /// Horizontal scrollbar controller
    _sc22 = ScrollController(initialScrollOffset: 0.0);

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
    if (!master.hasClients || !slave.hasClients || slave.position.outOfRange) {
      return;
    }

    if (_doNotReissueJump[master] == null ||
        _doNotReissueJump[master]! == false) {
      _doNotReissueJump[slave] = true;
      slave.jumpTo(master.offset);
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
