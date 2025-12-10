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

  /// ctrl을 누른다면 onTap 이벤트가 무조건 발생하도록 설정했다.
  void _handleTap() {
    if (HardwareKeyboard.instance.isLogicalKeyPressed(
          LogicalKeyboardKey.controlLeft,
        ) ||
        HardwareKeyboard.instance.isLogicalKeyPressed(
          LogicalKeyboardKey.controlRight,
        )) {
      widget.onTap?.call();
      _timer?.cancel();
      _resetTapCount();
    } else {
      _tapCount++;
      if (_tapCount == 2) {
        _timer?.cancel();
        widget.onDoubleTap?.call();
        _resetTapCount();
      } else {
        widget.onTap?.call();
      }
      if (_tapCount == 1) {
        _timer = Timer(Duration(milliseconds: widget.clickInterval), () {
          // if (_tapCount == 1) {
          //   // widget.onTap?.call();
          // }
          _resetTapCount();
        });
      } else if (_tapCount == 2) {
        _timer?.cancel();
        widget.onDoubleTap?.call();
        _resetTapCount();
      }
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
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            mouseCursor: widget.mouseCursor,
            borderRadius: BorderRadius.circular(8),
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
