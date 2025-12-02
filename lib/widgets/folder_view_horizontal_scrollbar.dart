// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../themes/folder_view_scrollbar_theme.dart';

class FolderViewHorizontalScrollbar extends StatelessWidget {
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
              scrollbarTheme: ScrollbarThemeData(
                thumbColor: WidgetStateProperty.all(scrollbarTheme.thumbColor),
                radius: Radius.circular(scrollbarTheme.radius),
                thickness: WidgetStateProperty.all(scrollbarTheme.thickness),
              ),
            ),
            child: Scrollbar(
              controller: horizontalScrollbarController,
              thumbVisibility: scrollbarTheme.thumbVisibility,
              trackVisibility: scrollbarTheme.trackVisibility,
              child: SingleChildScrollView(
                controller: horizontalScrollbarController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: contentWidth,
                  height: scrollbarTheme.trackWidth,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
