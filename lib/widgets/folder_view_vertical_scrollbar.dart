// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../themes/folder_view_scrollbar_theme.dart';

class FolderViewVerticalScrollbar extends StatelessWidget {
  final bool isHover;
  final ScrollController verticalScrollbarController;
  final double contentHeight;
  final bool needsHorizontalScroll;
  final FolderViewScrollbarTheme scrollbarTheme;

  const FolderViewVerticalScrollbar({
    super.key,
    required this.isHover,
    required this.verticalScrollbarController,
    required this.contentHeight,
    required this.needsHorizontalScroll,
    required this.scrollbarTheme,
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
              scrollbarTheme: ScrollbarThemeData(
                thumbColor: WidgetStateProperty.all(scrollbarTheme.thumbColor),
                radius: Radius.circular(scrollbarTheme.radius),
                thickness: WidgetStateProperty.all(scrollbarTheme.thickness),
              ),
            ),
            child: Scrollbar(
              controller: verticalScrollbarController,
              thumbVisibility: scrollbarTheme.thumbVisibility,
              trackVisibility: scrollbarTheme.trackVisibility,
              child: SingleChildScrollView(
                controller: verticalScrollbarController,
                scrollDirection: Axis.vertical,
                child: SizedBox(
                  width: scrollbarTheme.trackWidth,
                  height: contentHeight,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
