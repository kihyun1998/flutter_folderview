// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../themes/folder_view_scrollbar_theme.dart';
import 'folder_view_scrollbar_thumb.dart';
import 'modifier_wheel_guard.dart';

class FolderViewHorizontalScrollbar extends StatelessWidget {
  final bool isHover;
  final ScrollController horizontalScrollbarController;
  final double contentWidth;
  final FolderViewScrollbarTheme scrollbarTheme;

  /// Whether a Scale Modifier + wheel over the bar is kept from scrolling.
  final bool blockModifierWheel;

  const FolderViewHorizontalScrollbar({
    super.key,
    required this.isHover,
    required this.horizontalScrollbarController,
    required this.contentWidth,
    required this.scrollbarTheme,
    this.blockModifierWheel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedOpacity(
        opacity: isHover
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
            child: Scrollbar(
              controller: horizontalScrollbarController,
              thumbVisibility: scrollbarTheme.thumbVisibility,
              child: SingleChildScrollView(
                controller: horizontalScrollbarController,
                scrollDirection: Axis.horizontal,
                child: ModifierWheelGuard(
                  enabled: blockModifierWheel,
                  child: SizedBox(
                    width: contentWidth,
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
