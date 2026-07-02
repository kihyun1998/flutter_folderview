// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInkWell extends StatefulWidget {
  /// depth left padding
  final EdgeInsetsGeometry childPadding;

  /// isSelected
  final bool isSelected;
  final MouseCursor? mouseCursor;

  /// interval
  final int clickInterval;

  /// Border radius for the ink well
  final double borderRadius;

  /// colors
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? hoverColor;
  final Color? splashColor;
  final Color? highlightColor;

  /// functions
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final void Function(TapDownDetails)? onSecondaryTapDown;

  /// child
  final Widget child;

  const CustomInkWell({
    super.key,
    this.childPadding = const EdgeInsets.all(0),
    this.isSelected = false,
    this.mouseCursor,
    required this.clickInterval,
    this.borderRadius = 8.0,
    this.backgroundColor,
    this.selectedColor,
    this.hoverColor,
    this.splashColor,
    this.highlightColor,
    required this.onTap,
    required this.onDoubleTap,
    this.onSecondaryTapDown,
    required this.child,
  });

  @override
  State<CustomInkWell> createState() => _CustomInkWellState();
}

class _CustomInkWellState extends State<CustomInkWell> {
  int _tapCount = 0;

  Timer? _timer;

  /// Handles a tap.
  ///
  /// Ctrl+tap (either Control key) is treated as an immediate single tap.
  /// Otherwise the first tap fires [CustomInkWell.onTap] and arms a timer; a
  /// second tap within [CustomInkWell.clickInterval] fires
  /// [CustomInkWell.onDoubleTap]. A double tap therefore emits `onTap` (on the
  /// first tap) followed by `onDoubleTap` (on the second) — this dual emission
  /// is intentional so that single-tap feedback stays immediate.
  void _handleTap() {
    final ctrlPressed = HardwareKeyboard.instance
            .isLogicalKeyPressed(LogicalKeyboardKey.controlLeft) ||
        HardwareKeyboard.instance
            .isLogicalKeyPressed(LogicalKeyboardKey.controlRight);
    if (ctrlPressed) {
      _timer?.cancel();
      _resetTapCount();
      widget.onTap?.call();
      return;
    }

    _tapCount++;
    if (_tapCount == 2) {
      _timer?.cancel();
      _resetTapCount();
      widget.onDoubleTap?.call();
    } else {
      widget.onTap?.call();
      _timer = Timer(
        Duration(milliseconds: widget.clickInterval),
        _resetTapCount,
      );
    }
  }

  void _resetTapCount() {
    _tapCount = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeFocus(
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.selectedColor ?? Colors.transparent
                : widget.backgroundColor ?? Colors.transparent,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: InkWell(
            mouseCursor: widget.mouseCursor ?? SystemMouseCursors.click,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            onTap: widget.onTap != null ? _handleTap : null,
            onSecondaryTapDown: widget.onSecondaryTapDown,
            splashColor: widget.splashColor ?? Colors.transparent,
            hoverColor: widget.hoverColor ?? Colors.transparent,
            highlightColor: widget.highlightColor ?? Colors.transparent,
            child: Padding(padding: widget.childPadding, child: widget.child),
          ),
        ),
      ),
    );
  }
}
