// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../themes/folder_view_scrollbar_theme.dart';
import 'folder_view_scrollbar_thumb.dart';

class FolderViewHorizontalScrollbar extends StatefulWidget {
  final bool isHover;
  final ScrollController horizontalScrollbarController;
  final double contentWidth;
  final FolderViewScrollbarTheme scrollbarTheme;

  const FolderViewHorizontalScrollbar({
    super.key,
    required this.isHover,
    required this.horizontalScrollbarController,
    required this.contentWidth,
    required this.scrollbarTheme,
  });

  @override
  State<FolderViewHorizontalScrollbar> createState() =>
      _FolderViewHorizontalScrollbarState();
}

class _FolderViewHorizontalScrollbarState
    extends State<FolderViewHorizontalScrollbar> {
  /// Pointers pressed on the bar, such as one dragging the thumb.
  final Set<int> _pressed = {};

  /// Moves the bar by a mouse wheel turned with an axis modifier held, while
  /// no pointer is pressed on the bar.
  void _handleAxisModifierWheel(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || event.kind != PointerDeviceKind.mouse) {
      return;
    }
    if (_pressed.isNotEmpty) return;
    final modifiers = ScrollConfiguration.of(context).pointerAxisModifiers;
    if (!HardwareKeyboard.instance.logicalKeysPressed.any(modifiers.contains)) {
      return;
    }
    final controller = widget.horizontalScrollbarController;
    if (!controller.hasClients) return;
    final position = controller.position;
    final delta = axisDirectionIsReversed(position.axisDirection)
        ? -event.scrollDelta.dy
        : event.scrollDelta.dy;
    final target = (position.pixels + delta).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (target == position.pixels) return;
    GestureBinding.instance.pointerSignalResolver.register(
      event,
      (_) => position.pointerScroll(delta),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scrollbarTheme = widget.scrollbarTheme;
    final horizontalScrollbarController = widget.horizontalScrollbarController;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedOpacity(
        opacity: widget.isHover
            ? scrollbarTheme.hoverOpacity
            : scrollbarTheme.nonHoverOpacity,
        duration: scrollbarTheme.hoverAnimationDuration,
        child: Container(
          height: scrollbarTheme.trackWidth,
          decoration: BoxDecoration(
            color: scrollbarTheme.trackColor,
            borderRadius: BorderRadius.circular(scrollbarTheme.trackRadius),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              scrollbarTheme: folderViewThumbTheme(context, scrollbarTheme),
            ),
            child: Listener(
              onPointerDown: (event) => _pressed.add(event.pointer),
              onPointerUp: (event) => _pressed.remove(event.pointer),
              onPointerCancel: (event) => _pressed.remove(event.pointer),
              onPointerSignal: _handleAxisModifierWheel,
              child: Scrollbar(
                controller: horizontalScrollbarController,
                thumbVisibility: scrollbarTheme.thumbVisibility,
                child: SingleChildScrollView(
                  controller: horizontalScrollbarController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: widget.contentWidth,
                    height: scrollbarTheme.trackWidth,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
