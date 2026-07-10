/// The small sections: View Mode, Line, Expand Icon, Node Style, Layout, and
/// Interaction. Together they are shorter than either of the two big ones.
library;

import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';

import '../../../providers/theme_demo_provider.dart';
import '../panel_widgets.dart';

Widget buildViewMode(
  BuildContext context,
  ThemeDemoViewModel vm,
  ThemeDemoState notifier,
) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'View Mode',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SegmentedButton<ViewMode>(
            segments: const [
              ButtonSegment(value: ViewMode.folder, label: Text('Folder')),
              ButtonSegment(value: ViewMode.tree, label: Text('Tree')),
            ],
            selected: {vm.viewMode},
            onSelectionChanged: (s) => notifier.setViewMode(s.first),
          ),
        ],
      ),
    ),
  );
}

Widget buildLineControls(
  BuildContext context,
  ThemeDemoViewModel vm,
  ThemeDemoState notifier,
) {
  return panelSection(
    title: 'Line',
    children: [
      slider('Width', vm.lineWidth, 0.5, 5, notifier.setLineWidth),
      colorRow(context, 'Color', vm.lineColor, notifier.setLineColor),
      Wrap(
        spacing: 4,
        children: [
          ChoiceChip(
            label: const Text('Connect', style: TextStyle(fontSize: 12)),
            selected: vm.lineStyle == LineStyle.connector,
            onSelected: (s) =>
                s ? notifier.setLineStyle(LineStyle.connector) : null,
          ),
          ChoiceChip(
            label: const Text('Scope', style: TextStyle(fontSize: 12)),
            selected: vm.lineStyle == LineStyle.scope,
            onSelected: (s) =>
                s ? notifier.setLineStyle(LineStyle.scope) : null,
          ),
          ChoiceChip(
            label: const Text('None', style: TextStyle(fontSize: 12)),
            selected: vm.lineStyle == LineStyle.none,
            onSelected: (s) => s ? notifier.setLineStyle(LineStyle.none) : null,
          ),
        ],
      ),
    ],
  );
}

Widget buildExpandIconControls(
  BuildContext context,
  ThemeDemoViewModel vm,
  ThemeDemoState notifier,
) {
  return panelSection(
    title: 'Expand Icon',
    children: [
      slider('Size', vm.expandIconSize, 12, 32, notifier.setExpandIconSize),
      colorRow(
        context,
        'Collapsed Color',
        vm.expandIconColor,
        notifier.setExpandIconColor,
      ),
      colorRow(
        context,
        'Expanded Color',
        vm.expandIconExpandedColor,
        notifier.setExpandIconExpandedColor,
      ),
      slider('Padding', vm.expandPadding, 0, 8, notifier.setExpandPadding),
      slider('Margin', vm.expandMargin, 0, 8, notifier.setExpandMargin),
    ],
  );
}

Widget buildNodeStyleControls(
  BuildContext context,
  ThemeDemoViewModel vm,
  ThemeDemoState notifier,
) {
  return panelSection(
    title: 'Node Style',
    children: [
      slider('Border Radius', vm.borderRadius, 0, 20, notifier.setBorderRadius),
    ],
  );
}

Widget buildLayoutControls(
  BuildContext context,
  ThemeDemoViewModel vm,
  ThemeDemoState notifier,
) {
  return panelSection(
    title: 'Layout',
    children: [
      slider('Scale', vm.scale, 0.5, 3.0, notifier.setScale),
      const SizedBox(height: 4),
      Text(
        'Content scale (Ctrl/Cmd + Scroll)',
        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
      ),
      const SizedBox(height: 12),
      slider('Row Height', vm.rowHeight, 20, 80, notifier.setRowHeight),
      const SizedBox(height: 4),
      Text(
        'Height of each row/node',
        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
      ),
      const SizedBox(height: 12),
      slider('Row Spacing', vm.rowSpacing, 0, 20, notifier.setRowSpacing),
      const SizedBox(height: 4),
      Text(
        'Vertical spacing between rows',
        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
      ),
    ],
  );
}

Widget buildInteractionControls(
  BuildContext context,
  ThemeDemoViewModel vm,
  ThemeDemoState notifier,
) {
  return panelSection(
    title: 'Interaction',
    children: [
      slider(
        'Click Interval (ms)',
        vm.clickInterval,
        100,
        1000,
        notifier.setClickInterval,
      ),
      const SizedBox(height: 4),
      Text(
        'Double-click detection time for child nodes',
        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
      ),
      const SizedBox(height: 12),
      slider(
        'Animation Duration (ms)',
        vm.animationDuration,
        50,
        800,
        notifier.setAnimationDuration,
      ),
      const SizedBox(height: 4),
      Text(
        'Expand/collapse animation speed',
        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
      ),
    ],
  );
}
