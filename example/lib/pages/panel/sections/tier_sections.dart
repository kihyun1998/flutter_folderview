/// The per-Tier sections: Folder, Parent, Child. Each exposes that tier's
/// icon, text style, ink colours, and its label tooltip's switch.
library;

import 'package:flutter/material.dart';

import '../../../providers/theme_demo_provider.dart';
import '../panel_widgets.dart';

Widget buildFolderControls(
  BuildContext context,
  ThemeDemoViewModel vm,
  ThemeDemoState notifier,
) {
  return panelSection(
    title: 'Folder',
    children: [
      slider(
        'Icon Size',
        vm.folderIconSize,
        12,
        32,
        notifier.setFolderIconSize,
      ),
      colorRow(
        context,
        'Icon',
        vm.folderIconColor,
        notifier.setFolderIconColor,
      ),
      slider('Padding', vm.folderPadding, 0, 8, notifier.setFolderPadding),
      slider('Margin', vm.folderMargin, 0, 8, notifier.setFolderMargin),
      colorRow(
        context,
        'Text',
        vm.folderTextColor,
        notifier.setFolderTextColor,
      ),
      slider('Font', vm.folderFontSize, 10, 24, notifier.setFolderFontSize),
      const Divider(),
      const Text(
        'Interaction',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 4),
      colorRow(
        context,
        'Hover',
        vm.folderHoverColor,
        notifier.setFolderHoverColor,
      ),
      colorRow(
        context,
        'Splash',
        vm.folderSplashColor,
        notifier.setFolderSplashColor,
      ),
      colorRow(
        context,
        'Highlight',
        vm.folderHighlightColor,
        notifier.setFolderHighlightColor,
      ),
    ],
  );
}

Widget buildParentControls(
  BuildContext context,
  ThemeDemoViewModel vm,
  ThemeDemoState notifier,
) {
  return panelSection(
    title: 'Parent',
    children: [
      slider(
        'Icon Size',
        vm.parentIconSize,
        12,
        32,
        notifier.setParentIconSize,
      ),
      colorRow(
        context,
        'Icon',
        vm.parentIconColor,
        notifier.setParentIconColor,
      ),
      slider('Padding', vm.parentPadding, 0, 8, notifier.setParentPadding),
      slider('Margin', vm.parentMargin, 0, 8, notifier.setParentMargin),
      colorRow(
        context,
        'Text',
        vm.parentTextColor,
        notifier.setParentTextColor,
      ),
      slider('Font', vm.parentFontSize, 10, 24, notifier.setParentFontSize),
      const Divider(),
      const Text(
        'Interaction',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 4),
      colorRow(
        context,
        'Hover',
        vm.parentHoverColor,
        notifier.setParentHoverColor,
      ),
      colorRow(
        context,
        'Splash',
        vm.parentSplashColor,
        notifier.setParentSplashColor,
      ),
      colorRow(
        context,
        'Highlight',
        vm.parentHighlightColor,
        notifier.setParentHighlightColor,
      ),
    ],
  );
}

Widget buildChildControls(
  BuildContext context,
  ThemeDemoViewModel vm,
  ThemeDemoState notifier,
) {
  return panelSection(
    title: 'Child',
    children: [
      slider('Icon Size', vm.childIconSize, 12, 32, notifier.setChildIconSize),
      colorRow(context, 'Icon', vm.childIconColor, notifier.setChildIconColor),
      slider('Padding', vm.childPadding, 0, 8, notifier.setChildPadding),
      slider('Margin', vm.childMargin, 0, 8, notifier.setChildMargin),
      colorRow(context, 'Text', vm.childTextColor, notifier.setChildTextColor),
      slider('Font', vm.childFontSize, 10, 24, notifier.setChildFontSize),
      const Divider(),
      colorRow(
        context,
        'Selected BG',
        vm.childSelectedBg,
        notifier.setChildSelectedBg,
      ),
      const Divider(),
      const Text(
        'Interaction',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 4),
      colorRow(
        context,
        'Hover',
        vm.childHoverColor,
        notifier.setChildHoverColor,
      ),
      colorRow(
        context,
        'Splash',
        vm.childSplashColor,
        notifier.setChildSplashColor,
      ),
      colorRow(
        context,
        'Highlight',
        vm.childHighlightColor,
        notifier.setChildHighlightColor,
      ),
    ],
  );
}
