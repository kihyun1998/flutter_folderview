import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';

import '../../providers/theme_demo_provider.dart';

/// Assembles the `FlutterFolderViewTheme` the demo renders with, from the
/// ~100 knobs the control panel exposes.
///
/// It is this long because the three tier themes each repeat the full
/// `NodeTooltipTheme` field list. That duplication is deliberate in the
/// package -- see ADR-0005 -- and the demo mirrors it rather than hiding it.
FlutterFolderViewTheme<String> buildDemoTheme(ThemeDemoViewModel vm) {
  return FlutterFolderViewTheme<String>(
    lineTheme: FolderViewLineTheme(
      lineColor: vm.lineColor,
      lineWidth: vm.lineWidth,
      lineStyle: vm.lineStyle,
    ),
    folderTheme: FolderNodeTheme<String>(
      widget: Icon(
        Icons.folder,
        color: vm.folderIconColor,
        size: vm.folderIconSize,
      ),
      openWidget: Icon(
        Icons.folder_open,
        color: vm.folderIconColor,
        size: vm.folderIconSize,
      ),
      width: vm.folderIconSize,
      height: vm.folderIconSize,
      padding: EdgeInsets.symmetric(horizontal: vm.folderPadding),
      margin: EdgeInsets.symmetric(horizontal: vm.folderMargin),
      textStyle: TextStyle(
        color: vm.folderTextColor,
        fontSize: vm.folderFontSize,
      ),
      hoverColor: vm.folderHoverColor,
      splashColor: vm.folderSplashColor,
      highlightColor: vm.folderHighlightColor,
      tooltipTheme: NodeTooltipTheme<String>(
        useTooltip: vm.folderTooltipEnabled,
        message: 'Folder node',
        backgroundColor: vm.folderTooltipBgColor,
        direction: vm.tooltipDirection,
        anchor: vm.tooltipAnchor,
        alignment: vm.tooltipAlignment,
        offset: vm.tooltipOffset,
        elevation: vm.tooltipElevation,
        enableTap: vm.tooltipEnableTap,
        enableHover: vm.tooltipEnableHover,
        interactive: vm.tooltipInteractive,
        waitDuration: vm.tooltipWaitDuration > 0
            ? Duration(milliseconds: vm.tooltipWaitDuration.round())
            : null,
        showDuration: vm.tooltipShowDuration > 0
            ? Duration(milliseconds: vm.tooltipShowDuration.round())
            : null,
        boxShadow: vm.tooltipBoxShadowEnabled
            ? [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: vm.tooltipBoxShadowBlur,
                  spreadRadius: vm.tooltipBoxShadowSpread,
                ),
              ]
            : null,
        showArrow: vm.tooltipShowArrow,
        arrowBaseWidth: vm.tooltipArrowBaseWidth,
        arrowLength: vm.tooltipArrowLength,
        arrowPositionRatio: vm.tooltipArrowPositionRatio,
        borderWidth: vm.tooltipBorderWidth,
        borderColor: vm.tooltipBorderColor,
        screenMargin: vm.tooltipScreenMargin,
        animation: vm.tooltipAnimation,
        fadeBegin: vm.tooltipFadeBegin,
        scaleBegin: vm.tooltipScaleBegin,
        slideOffset: vm.tooltipSlideOffset,
        rotationBegin: vm.tooltipRotationBegin,
        animationDuration: Duration(
          milliseconds: vm.tooltipAnimationDuration.round(),
        ),
        hideOnEmptyMessage: vm.tooltipHideOnEmptyMessage,
      ),
    ),
    parentTheme: ParentNodeTheme<String>(
      widget: Icon(
        Icons.account_tree,
        color: vm.parentIconColor,
        size: vm.parentIconSize,
      ),
      width: vm.parentIconSize,
      height: vm.parentIconSize,
      padding: EdgeInsets.symmetric(horizontal: vm.parentPadding),
      margin: EdgeInsets.symmetric(horizontal: vm.parentMargin),
      textStyle: TextStyle(
        color: vm.parentTextColor,
        fontSize: vm.parentFontSize,
      ),
      hoverColor: vm.parentHoverColor,
      splashColor: vm.parentSplashColor,
      highlightColor: vm.parentHighlightColor,
      tooltipTheme: NodeTooltipTheme<String>(
        useTooltip: vm.parentTooltipEnabled,
        message: 'Parent node',
        backgroundColor: vm.parentTooltipBgColor,
        direction: vm.tooltipDirection,
        anchor: vm.tooltipAnchor,
        alignment: vm.tooltipAlignment,
        offset: vm.tooltipOffset,
        elevation: vm.tooltipElevation,
        enableTap: vm.tooltipEnableTap,
        enableHover: vm.tooltipEnableHover,
        interactive: vm.tooltipInteractive,
        waitDuration: vm.tooltipWaitDuration > 0
            ? Duration(milliseconds: vm.tooltipWaitDuration.round())
            : null,
        showDuration: vm.tooltipShowDuration > 0
            ? Duration(milliseconds: vm.tooltipShowDuration.round())
            : null,
        boxShadow: vm.tooltipBoxShadowEnabled
            ? [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: vm.tooltipBoxShadowBlur,
                  spreadRadius: vm.tooltipBoxShadowSpread,
                ),
              ]
            : null,
        showArrow: vm.tooltipShowArrow,
        arrowBaseWidth: vm.tooltipArrowBaseWidth,
        arrowLength: vm.tooltipArrowLength,
        arrowPositionRatio: vm.tooltipArrowPositionRatio,
        borderWidth: vm.tooltipBorderWidth,
        borderColor: vm.tooltipBorderColor,
        screenMargin: vm.tooltipScreenMargin,
        animation: vm.tooltipAnimation,
        fadeBegin: vm.tooltipFadeBegin,
        scaleBegin: vm.tooltipScaleBegin,
        slideOffset: vm.tooltipSlideOffset,
        rotationBegin: vm.tooltipRotationBegin,
        animationDuration: Duration(
          milliseconds: vm.tooltipAnimationDuration.round(),
        ),
        hideOnEmptyMessage: vm.tooltipHideOnEmptyMessage,
      ),
    ),
    childTheme: ChildNodeTheme<String>(
      widget: Icon(
        Icons.insert_drive_file,
        color: vm.childIconColor,
        size: vm.childIconSize,
      ),
      width: vm.childIconSize,
      height: vm.childIconSize,
      padding: EdgeInsets.symmetric(horizontal: vm.childPadding),
      margin: EdgeInsets.symmetric(horizontal: vm.childMargin),
      textStyle: TextStyle(
        color: vm.childTextColor,
        fontSize: vm.childFontSize,
      ),
      selectedTextStyle: const TextStyle(fontWeight: FontWeight.bold),
      selectedBackgroundColor: vm.childSelectedBg,
      hoverColor: vm.childHoverColor,
      splashColor: vm.childSplashColor,
      highlightColor: vm.childHighlightColor,
      clickInterval: vm.clickInterval.round(),
      tooltipTheme: NodeTooltipTheme<String>(
        useTooltip: vm.childTooltipEnabled,
        direction: vm.tooltipDirection,
        anchor: vm.tooltipAnchor,
        alignment: vm.tooltipAlignment,
        offset: vm.tooltipOffset,
        elevation: vm.tooltipElevation,
        enableTap: vm.tooltipEnableTap,
        enableHover: vm.tooltipEnableHover,
        interactive: vm.tooltipInteractive,
        waitDuration: vm.tooltipWaitDuration > 0
            ? Duration(milliseconds: vm.tooltipWaitDuration.round())
            : null,
        showDuration: vm.tooltipShowDuration > 0
            ? Duration(milliseconds: vm.tooltipShowDuration.round())
            : null,
        boxShadow: vm.tooltipBoxShadowEnabled
            ? [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: vm.tooltipBoxShadowBlur,
                  spreadRadius: vm.tooltipBoxShadowSpread,
                ),
              ]
            : null,
        tooltipBuilder: (_) => RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'Child: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: 'Click to select',
                style: TextStyle(color: Colors.grey.shade300),
              ),
            ],
          ),
        ),
        tooltipBuilderResolver: (node) =>
            (_) => RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Child: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: node.label,
                    style: TextStyle(color: Colors.grey.shade300),
                  ),
                ],
              ),
            ),
        backgroundColor: vm.childTooltipBgColor,
        showArrow: vm.tooltipShowArrow,
        arrowBaseWidth: vm.tooltipArrowBaseWidth,
        arrowLength: vm.tooltipArrowLength,
        arrowPositionRatio: vm.tooltipArrowPositionRatio,
        borderWidth: vm.tooltipBorderWidth,
        borderColor: vm.tooltipBorderColor,
        screenMargin: vm.tooltipScreenMargin,
        animation: vm.tooltipAnimation,
        fadeBegin: vm.tooltipFadeBegin,
        scaleBegin: vm.tooltipScaleBegin,
        slideOffset: vm.tooltipSlideOffset,
        rotationBegin: vm.tooltipRotationBegin,
        animationDuration: Duration(
          milliseconds: vm.tooltipAnimationDuration.round(),
        ),
        hideOnEmptyMessage: vm.tooltipHideOnEmptyMessage,
      ),
    ),
    expandIconTheme: ExpandIconTheme(
      widget: const Icon(Icons.chevron_right),
      width: vm.expandIconSize,
      height: vm.expandIconSize,
      padding: EdgeInsets.only(left: vm.expandPadding),
      margin: EdgeInsets.only(left: vm.expandMargin),
      color: vm.expandIconColor,
      expandedColor: vm.expandIconExpandedColor,
    ),
    scrollbarTheme: FolderViewScrollbarTheme(
      thumbColor: Colors.grey.shade600,
      trackColor: Colors.grey.shade200,
    ),
    nodeStyleTheme: FolderViewNodeStyleTheme(borderRadius: vm.borderRadius),
    animationDuration: vm.animationDuration.round(),
    rowHeight: vm.rowHeight,
    rowSpacing: vm.rowSpacing,
  );
}
