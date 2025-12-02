// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class FolderViewVerticalScrollbar extends StatelessWidget {
  final bool isHover;
  final ScrollController verticalScrollbarController;
  final double contentHeight;
  final bool needsHorizontalScroll;

  const FolderViewVerticalScrollbar({
    super.key,
    required this.isHover,
    required this.verticalScrollbarController,
    required this.contentHeight,
    required this.needsHorizontalScroll,
  });

  static const double scrollbarTrackWidth = 16.0;
  static const double scrollbarWidth = 12.0;
  static const double scrollbarRadius = 4.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      bottom: needsHorizontalScroll ? scrollbarTrackWidth : 0,
      child: AnimatedOpacity(
        opacity: isHover ? 0.8 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: scrollbarTrackWidth,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              scrollbarTheme: ScrollbarThemeData(
                thumbColor: WidgetStateProperty.all(Colors.red),
                radius: const Radius.circular(scrollbarRadius),
                thickness: WidgetStateProperty.all(scrollbarWidth),
              ),
            ),
            child: Scrollbar(
              controller: verticalScrollbarController,
              thumbVisibility: true,
              trackVisibility: false,
              child: SingleChildScrollView(
                controller: verticalScrollbarController,
                scrollDirection: Axis.vertical,
                child: SizedBox(
                  width: scrollbarTrackWidth,
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
