/// The Tooltip section: the row card, the three per-Tier label tooltips, and
/// the ~30 knobs they share. The largest section by far, because
/// `NodeTooltipTheme` is the largest theme.
library;

import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';

import '../../../providers/theme_demo_provider.dart';
import '../panel_widgets.dart';

Widget buildTooltipControls(
  BuildContext context,
  ThemeDemoViewModel vm,
  ThemeDemoState notifier,
) {
  return panelSection(
    title: 'Tooltip',
    children: [
      // Declared once for the whole view, so it sits above the per-Tier
      // switches rather than among them.
      SwitchListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: const Text('Row Tooltip (card)', style: TextStyle(fontSize: 12)),
        subtitle: const Text(
          'Hover anywhere on a row except the label text, which keeps its '
          'own tooltip. Leave both on.',
          style: TextStyle(fontSize: 10),
        ),
        isThreeLine: true,
        value: vm.rowTooltipEnabled,
        onChanged: notifier.setRowTooltipEnabled,
      ),
      const Divider(),
      const Text(
        'Per-Tier label tooltips',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
      SwitchListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: const Text('Folder Tooltip', style: TextStyle(fontSize: 12)),
        value: vm.folderTooltipEnabled,
        onChanged: notifier.setFolderTooltipEnabled,
      ),
      if (vm.folderTooltipEnabled)
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: colorRow(
            context,
            'BG Color',
            vm.folderTooltipBgColor,
            notifier.setFolderTooltipBgColor,
          ),
        ),
      const Divider(),
      SwitchListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: const Text('Parent Tooltip', style: TextStyle(fontSize: 12)),
        value: vm.parentTooltipEnabled,
        onChanged: notifier.setParentTooltipEnabled,
      ),
      if (vm.parentTooltipEnabled)
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: colorRow(
            context,
            'BG Color',
            vm.parentTooltipBgColor,
            notifier.setParentTooltipBgColor,
          ),
        ),
      const Divider(),
      SwitchListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: const Text(
          'Child Tooltip (Rich)',
          style: TextStyle(fontSize: 12),
        ),
        value: vm.childTooltipEnabled,
        onChanged: notifier.setChildTooltipEnabled,
      ),
      if (vm.childTooltipEnabled)
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: colorRow(
            context,
            'BG Color',
            vm.childTooltipBgColor,
            notifier.setChildTooltipBgColor,
          ),
        ),
      const Divider(),
      const Text(
        'Common Settings',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 4),
      const Text('Direction', style: TextStyle(fontSize: 12)),
      Wrap(
        spacing: 4,
        children: [
          ChoiceChip(
            label: const Text('Top', style: TextStyle(fontSize: 12)),
            selected: vm.tooltipDirection == TooltipDirection.top,
            onSelected: (s) =>
                s ? notifier.setTooltipDirection(TooltipDirection.top) : null,
          ),
          ChoiceChip(
            label: const Text('Bottom', style: TextStyle(fontSize: 12)),
            selected: vm.tooltipDirection == TooltipDirection.bottom,
            onSelected: (s) => s
                ? notifier.setTooltipDirection(TooltipDirection.bottom)
                : null,
          ),
          ChoiceChip(
            label: const Text('Left', style: TextStyle(fontSize: 12)),
            selected: vm.tooltipDirection == TooltipDirection.left,
            onSelected: (s) =>
                s ? notifier.setTooltipDirection(TooltipDirection.left) : null,
          ),
          ChoiceChip(
            label: const Text('Right', style: TextStyle(fontSize: 12)),
            selected: vm.tooltipDirection == TooltipDirection.right,
            onSelected: (s) =>
                s ? notifier.setTooltipDirection(TooltipDirection.right) : null,
          ),
        ],
      ),
      const SizedBox(height: 8),
      const Text('Anchor', style: TextStyle(fontSize: 12)),
      Wrap(
        spacing: 4,
        children: [
          ChoiceChip(
            label: const Text('Child rect', style: TextStyle(fontSize: 12)),
            selected: vm.tooltipAnchor == TooltipAnchor.child,
            onSelected: (s) =>
                s ? notifier.setTooltipAnchor(TooltipAnchor.child) : null,
          ),
          ChoiceChip(
            label: const Text('Pointer', style: TextStyle(fontSize: 12)),
            selected: vm.tooltipAnchor == TooltipAnchor.pointer,
            onSelected: (s) =>
                s ? notifier.setTooltipAnchor(TooltipAnchor.pointer) : null,
          ),
        ],
      ),
      const SizedBox(height: 8),
      const Text('Alignment', style: TextStyle(fontSize: 12)),
      Wrap(
        spacing: 4,
        children: [
          ChoiceChip(
            label: const Text('Start', style: TextStyle(fontSize: 12)),
            selected: vm.tooltipAlignment == TooltipAlignment.start,
            onSelected: (s) =>
                s ? notifier.setTooltipAlignment(TooltipAlignment.start) : null,
          ),
          ChoiceChip(
            label: const Text('Center', style: TextStyle(fontSize: 12)),
            selected: vm.tooltipAlignment == TooltipAlignment.center,
            onSelected: (s) => s
                ? notifier.setTooltipAlignment(TooltipAlignment.center)
                : null,
          ),
          ChoiceChip(
            label: const Text('End', style: TextStyle(fontSize: 12)),
            selected: vm.tooltipAlignment == TooltipAlignment.end,
            onSelected: (s) =>
                s ? notifier.setTooltipAlignment(TooltipAlignment.end) : null,
          ),
          ChoiceChip(
            label: const Text('StartTC', style: TextStyle(fontSize: 12)),
            selected: vm.tooltipAlignment == TooltipAlignment.startTargetCenter,
            onSelected: (s) => s
                ? notifier.setTooltipAlignment(
                    TooltipAlignment.startTargetCenter,
                  )
                : null,
          ),
          ChoiceChip(
            label: const Text('EndTC', style: TextStyle(fontSize: 12)),
            selected: vm.tooltipAlignment == TooltipAlignment.endTargetCenter,
            onSelected: (s) => s
                ? notifier.setTooltipAlignment(TooltipAlignment.endTargetCenter)
                : null,
          ),
        ],
      ),
      const SizedBox(height: 8),
      slider('Offset', vm.tooltipOffset, 0, 30, notifier.setTooltipOffset),
      slider(
        'Elevation',
        vm.tooltipElevation,
        0,
        20,
        notifier.setTooltipElevation,
      ),
      SwitchListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: const Text('Enable Tap', style: TextStyle(fontSize: 12)),
        value: vm.tooltipEnableTap,
        onChanged: (v) => notifier.setTooltipEnableTap(v),
      ),
      SwitchListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: const Text('Enable Hover', style: TextStyle(fontSize: 12)),
        value: vm.tooltipEnableHover,
        onChanged: (v) => notifier.setTooltipEnableHover(v),
      ),
      SwitchListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: const Text('Interactive', style: TextStyle(fontSize: 12)),
        subtitle: const Text(
          'Keep tooltip visible on hover',
          style: TextStyle(fontSize: 10),
        ),
        value: vm.tooltipInteractive,
        onChanged: (v) => notifier.setTooltipInteractive(v),
      ),
      SwitchListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: const Text(
          'Hide On Empty Message',
          style: TextStyle(fontSize: 12),
        ),
        subtitle: const Text(
          'Suppress tooltip when message is empty',
          style: TextStyle(fontSize: 10),
        ),
        value: vm.tooltipHideOnEmptyMessage,
        onChanged: (v) => notifier.setTooltipHideOnEmptyMessage(v),
      ),
      slider(
        'Wait Duration (ms)',
        vm.tooltipWaitDuration,
        0,
        2000,
        notifier.setTooltipWaitDuration,
      ),
      slider(
        'Show Duration (ms)',
        vm.tooltipShowDuration,
        0,
        5000,
        notifier.setTooltipShowDuration,
      ),
      SwitchListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: const Text('Custom BoxShadow', style: TextStyle(fontSize: 12)),
        subtitle: const Text(
          'Override elevation with custom shadow',
          style: TextStyle(fontSize: 10),
        ),
        value: vm.tooltipBoxShadowEnabled,
        onChanged: (v) => notifier.setTooltipBoxShadowEnabled(v),
      ),
      if (vm.tooltipBoxShadowEnabled) ...[
        slider(
          'Shadow Blur',
          vm.tooltipBoxShadowBlur,
          0,
          20,
          notifier.setTooltipBoxShadowBlur,
        ),
        slider(
          'Shadow Spread',
          vm.tooltipBoxShadowSpread,
          0,
          10,
          notifier.setTooltipBoxShadowSpread,
        ),
      ],
      const Divider(),
      const Text(
        'Arrow',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 4),
      SwitchListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: const Text('Show Arrow', style: TextStyle(fontSize: 12)),
        value: vm.tooltipShowArrow,
        onChanged: (v) => notifier.setTooltipShowArrow(v),
      ),
      if (vm.tooltipShowArrow) ...[
        slider(
          'Arrow Base Width',
          vm.tooltipArrowBaseWidth,
          4,
          30,
          notifier.setTooltipArrowBaseWidth,
        ),
        slider(
          'Arrow Length',
          vm.tooltipArrowLength,
          2,
          20,
          notifier.setTooltipArrowLength,
        ),
        slider(
          'Arrow Position Ratio',
          vm.tooltipArrowPositionRatio,
          0,
          1,
          notifier.setTooltipArrowPositionRatio,
        ),
      ],
      const Divider(),
      const Text(
        'Border',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 4),
      slider(
        'Border Width',
        vm.tooltipBorderWidth,
        0,
        4,
        notifier.setTooltipBorderWidth,
      ),
      if (vm.tooltipBorderWidth > 0)
        colorRow(
          context,
          'Border Color',
          vm.tooltipBorderColor,
          notifier.setTooltipBorderColor,
        ),
      const Divider(),
      slider(
        'Screen Margin',
        vm.tooltipScreenMargin,
        0,
        30,
        notifier.setTooltipScreenMargin,
      ),
      const Divider(),
      const Text(
        'Animation',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 4),
      const Text('Type', style: TextStyle(fontSize: 12)),
      Wrap(
        spacing: 4,
        runSpacing: 4,
        children: TooltipAnimation.values.map((anim) {
          return ChoiceChip(
            label: Text(anim.name, style: const TextStyle(fontSize: 11)),
            selected: vm.tooltipAnimation == anim,
            onSelected: (s) => s ? notifier.setTooltipAnimation(anim) : null,
          );
        }).toList(),
      ),
      const SizedBox(height: 8),
      slider(
        'Animation Duration (ms)',
        vm.tooltipAnimationDuration,
        0,
        1000,
        notifier.setTooltipAnimationDuration,
      ),
      slider(
        'Fade Begin',
        vm.tooltipFadeBegin,
        0,
        1,
        notifier.setTooltipFadeBegin,
      ),
      slider(
        'Scale Begin',
        vm.tooltipScaleBegin,
        0,
        1,
        notifier.setTooltipScaleBegin,
      ),
      slider(
        'Slide Offset',
        vm.tooltipSlideOffset,
        0,
        1,
        notifier.setTooltipSlideOffset,
      ),
      slider(
        'Rotation Begin',
        vm.tooltipRotationBegin,
        -0.5,
        0.5,
        notifier.setTooltipRotationBegin,
      ),
      const SizedBox(height: 4),
      Text(
        'Hover over nodes to see tooltips',
        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
      ),
    ],
  );
}
