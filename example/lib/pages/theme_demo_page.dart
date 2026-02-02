import 'package:flutter/material.dart' hide TooltipTheme;
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_demo_provider.dart';
import 'large_dataset_page.dart';

class ThemeDemoPage extends ConsumerWidget {
  const ThemeDemoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(themeDemoStateProvider);
    final notifier = ref.read(themeDemoStateProvider.notifier);

    final theme = FlutterFolderViewTheme<String>(
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
        textStyle: TextStyle(color: vm.childTextColor, fontSize: vm.childFontSize),
        selectedTextStyle: const TextStyle(fontWeight: FontWeight.bold),
        selectedBackgroundColor: vm.childSelectedBg,
        hoverColor: vm.childHoverColor,
        splashColor: vm.childSplashColor,
        highlightColor: vm.childHighlightColor,
        clickInterval: vm.clickInterval.round(),
        tooltipTheme: NodeTooltipTheme<String>(
          useTooltip: vm.childTooltipEnabled,
          richMessage: TextSpan(
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
          richMessageResolver: (node) => TextSpan(
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
          backgroundColor: vm.childTooltipBgColor,
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Demo'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.unfold_more),
            tooltip: 'Expand All',
            onPressed: notifier.expandAll,
          ),
          IconButton(
            icon: const Icon(Icons.unfold_less),
            tooltip: 'Collapse All',
            onPressed: notifier.collapseAll,
          ),
          IconButton(
            icon: const Icon(Icons.dataset_outlined),
            tooltip: 'Large Dataset Test',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LargeDatasetPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: 350,
            child: _ThemeControls(vm: vm, notifier: notifier),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FolderView<String>(
                    data: vm.nodes,
                    mode: vm.viewMode,
                    onNodeTap: (node) {
                      if (node.type == NodeType.child) {
                        notifier.selectNode(node.id);
                      } else if (node.canExpand) {
                        notifier.toggleNode(node.id);
                      }
                    },
                    onDoubleNodeTap: (node) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.mouse, color: Colors.white, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '더블클릭: ${node.label}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green.shade700,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    selectedNodeIds: vm.selectedIds,
                    expandedNodeIds: vm.expandedIds,
                    theme: theme,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeControls extends StatelessWidget {
  final ThemeDemoViewModel vm;
  final ThemeDemoState notifier;

  const _ThemeControls({required this.vm, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildViewMode(context),
        _buildLineControls(context),
        _buildExpandIconControls(context),
        _buildFolderControls(context),
        _buildParentControls(context),
        _buildChildControls(context),
        _buildTooltipControls(context),
        _buildNodeStyleControls(context),
        _buildLayoutControls(context),
        _buildInteractionControls(context),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: notifier.reset,
          icon: const Icon(Icons.refresh),
          label: const Text('Reset'),
        ),
      ],
    );
  }

  Widget _buildViewMode(BuildContext context) {
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

  Widget _buildLineControls(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Line', style: TextStyle(fontWeight: FontWeight.bold)),
            _slider('Width', vm.lineWidth, 0.5, 5, notifier.setLineWidth),
            _colorRow(context, 'Color', vm.lineColor, notifier.setLineColor),
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
                  onSelected: (s) =>
                      s ? notifier.setLineStyle(LineStyle.none) : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandIconControls(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expand Icon',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            _slider('Size', vm.expandIconSize, 12, 32, notifier.setExpandIconSize),
            _colorRow(
              context,
              'Collapsed Color',
              vm.expandIconColor,
              notifier.setExpandIconColor,
            ),
            _colorRow(
              context,
              'Expanded Color',
              vm.expandIconExpandedColor,
              notifier.setExpandIconExpandedColor,
            ),
            _slider('Padding', vm.expandPadding, 0, 8, notifier.setExpandPadding),
            _slider('Margin', vm.expandMargin, 0, 8, notifier.setExpandMargin),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderControls(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Folder', style: TextStyle(fontWeight: FontWeight.bold)),
            _slider(
              'Icon Size',
              vm.folderIconSize,
              12,
              32,
              notifier.setFolderIconSize,
            ),
            _colorRow(
              context,
              'Icon',
              vm.folderIconColor,
              notifier.setFolderIconColor,
            ),
            _slider('Padding', vm.folderPadding, 0, 8, notifier.setFolderPadding),
            _slider('Margin', vm.folderMargin, 0, 8, notifier.setFolderMargin),
            _colorRow(
              context,
              'Text',
              vm.folderTextColor,
              notifier.setFolderTextColor,
            ),
            _slider('Font', vm.folderFontSize, 10, 24, notifier.setFolderFontSize),
            const Divider(),
            const Text(
              'Interaction',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            _colorRow(
              context,
              'Hover',
              vm.folderHoverColor,
              notifier.setFolderHoverColor,
            ),
            _colorRow(
              context,
              'Splash',
              vm.folderSplashColor,
              notifier.setFolderSplashColor,
            ),
            _colorRow(
              context,
              'Highlight',
              vm.folderHighlightColor,
              notifier.setFolderHighlightColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentControls(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Parent', style: TextStyle(fontWeight: FontWeight.bold)),
            _slider(
              'Icon Size',
              vm.parentIconSize,
              12,
              32,
              notifier.setParentIconSize,
            ),
            _colorRow(
              context,
              'Icon',
              vm.parentIconColor,
              notifier.setParentIconColor,
            ),
            _slider('Padding', vm.parentPadding, 0, 8, notifier.setParentPadding),
            _slider('Margin', vm.parentMargin, 0, 8, notifier.setParentMargin),
            _colorRow(
              context,
              'Text',
              vm.parentTextColor,
              notifier.setParentTextColor,
            ),
            _slider('Font', vm.parentFontSize, 10, 24, notifier.setParentFontSize),
            const Divider(),
            const Text(
              'Interaction',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            _colorRow(
              context,
              'Hover',
              vm.parentHoverColor,
              notifier.setParentHoverColor,
            ),
            _colorRow(
              context,
              'Splash',
              vm.parentSplashColor,
              notifier.setParentSplashColor,
            ),
            _colorRow(
              context,
              'Highlight',
              vm.parentHighlightColor,
              notifier.setParentHighlightColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildControls(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Child', style: TextStyle(fontWeight: FontWeight.bold)),
            _slider(
              'Icon Size',
              vm.childIconSize,
              12,
              32,
              notifier.setChildIconSize,
            ),
            _colorRow(
              context,
              'Icon',
              vm.childIconColor,
              notifier.setChildIconColor,
            ),
            _slider('Padding', vm.childPadding, 0, 8, notifier.setChildPadding),
            _slider('Margin', vm.childMargin, 0, 8, notifier.setChildMargin),
            _colorRow(
              context,
              'Text',
              vm.childTextColor,
              notifier.setChildTextColor,
            ),
            _slider('Font', vm.childFontSize, 10, 24, notifier.setChildFontSize),
            const Divider(),
            _colorRow(
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
            _colorRow(
              context,
              'Hover',
              vm.childHoverColor,
              notifier.setChildHoverColor,
            ),
            _colorRow(
              context,
              'Splash',
              vm.childSplashColor,
              notifier.setChildSplashColor,
            ),
            _colorRow(
              context,
              'Highlight',
              vm.childHighlightColor,
              notifier.setChildHighlightColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTooltipControls(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tooltip',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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
                child: _colorRow(
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
                child: _colorRow(
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
              title:
                  const Text('Child Tooltip (Rich)', style: TextStyle(fontSize: 12)),
              value: vm.childTooltipEnabled,
              onChanged: notifier.setChildTooltipEnabled,
            ),
            if (vm.childTooltipEnabled)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: _colorRow(
                  context,
                  'BG Color',
                  vm.childTooltipBgColor,
                  notifier.setChildTooltipBgColor,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              'Hover over nodes to see tooltips',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNodeStyleControls(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Node Style',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            _slider('Border Radius', vm.borderRadius, 0, 20, notifier.setBorderRadius),
          ],
        ),
      ),
    );
  }

  Widget _buildLayoutControls(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Layout', style: TextStyle(fontWeight: FontWeight.bold)),
            _slider('Row Height', vm.rowHeight, 20, 80, notifier.setRowHeight),
            const SizedBox(height: 4),
            Text(
              'Height of each row/node',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            _slider('Row Spacing', vm.rowSpacing, 0, 20, notifier.setRowSpacing),
            const SizedBox(height: 4),
            Text(
              'Vertical spacing between rows',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionControls(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Interaction',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            _slider(
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
            _slider(
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
        ),
      ),
    );
  }

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChange,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: onChange,
              ),
            ),
            SizedBox(
              width: 40,
              child: Text(
                value.toStringAsFixed(1),
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _colorRow(
    BuildContext context,
    String label,
    Color value,
    ValueChanged<Color> onChange,
  ) {
    final colors = [
      const Color(0xFF2196F3),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFFF44336),
      const Color(0xFF9C27B0),
      const Color(0xFF616161),
      Colors.black87,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: colors.map((c) {
            return InkWell(
              onTap: () => onChange(c),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: c,
                  border: Border.all(
                    color: value == c
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                    width: value == c ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
