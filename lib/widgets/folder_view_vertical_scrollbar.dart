// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../themes/folder_view_scrollbar_theme.dart';
import 'folder_view_scrollbar_thumb.dart';
import 'modifier_wheel_guard.dart';

class FolderViewVerticalScrollbar extends StatelessWidget {
  final bool isHover;
  final ScrollController verticalScrollbarController;
  final double contentHeight;
  final bool needsHorizontalScroll;
  final FolderViewScrollbarTheme scrollbarTheme;

  /// Whether a Scale Modifier + wheel over the bar is kept from scrolling.
  final bool blockModifierWheel;

  const FolderViewVerticalScrollbar({
    super.key,
    required this.isHover,
    required this.verticalScrollbarController,
    required this.contentHeight,
    required this.needsHorizontalScroll,
    required this.scrollbarTheme,
    this.blockModifierWheel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      bottom: needsHorizontalScroll ? scrollbarTheme.trackWidth : 0,
      child: AnimatedOpacity(
        opacity: isHover
            ? scrollbarTheme.hoverOpacity
            : scrollbarTheme.nonHoverOpacity,
        duration: scrollbarTheme.hoverAnimationDuration,
        child: Container(
          width: scrollbarTheme.trackWidth,
          decoration: BoxDecoration(
            color: scrollbarTheme.trackColor,
            borderRadius: BorderRadius.circular(scrollbarTheme.trackRadius),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              scrollbarTheme: folderViewThumbTheme(context, scrollbarTheme),
            ),
            child: Scrollbar(
              controller: verticalScrollbarController,
              thumbVisibility: scrollbarTheme.thumbVisibility,
              child: SingleChildScrollView(
                controller: verticalScrollbarController,
                scrollDirection: Axis.vertical,
                child: ModifierWheelGuard(
                  enabled: blockModifierWheel,
                  child: SizedBox(
                    width: scrollbarTheme.trackWidth,
                    height: contentHeight,
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
