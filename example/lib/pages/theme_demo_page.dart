import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_demo_provider.dart';

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
          direction: vm.tooltipDirection,
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
                              const Icon(
                                Icons.mouse,
                                color: Colors.white,
                                size: 20,
                              ),
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
        _buildDataGenerator(context),
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
          label: const Text('Reset Theme'),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        initiallyExpanded: initiallyExpanded,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: children,
      ),
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
    return _buildSection(
      title: 'Line',
      children: [
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
    );
  }

  Widget _buildExpandIconControls(BuildContext context) {
    return _buildSection(
      title: 'Expand Icon',
      children: [
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
    );
  }

  Widget _buildFolderControls(BuildContext context) {
    return _buildSection(
      title: 'Folder',
      children: [
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
    );
  }

  Widget _buildParentControls(BuildContext context) {
    return _buildSection(
      title: 'Parent',
      children: [
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
    );
  }

  Widget _buildChildControls(BuildContext context) {
    return _buildSection(
      title: 'Child',
      children: [
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
    );
  }

  Widget _buildTooltipControls(BuildContext context) {
    return _buildSection(
      title: 'Tooltip',
      children: [
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
            child: _colorRow(
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
              onSelected: (s) => s
                  ? notifier.setTooltipDirection(TooltipDirection.left)
                  : null,
            ),
            ChoiceChip(
              label: const Text('Right', style: TextStyle(fontSize: 12)),
              selected: vm.tooltipDirection == TooltipDirection.right,
              onSelected: (s) => s
                  ? notifier.setTooltipDirection(TooltipDirection.right)
                  : null,
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
              onSelected: (s) => s
                  ? notifier.setTooltipAlignment(TooltipAlignment.start)
                  : null,
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
          ],
        ),
        const SizedBox(height: 8),
        _slider('Offset', vm.tooltipOffset, 0, 30, notifier.setTooltipOffset),
        _slider(
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
        _slider(
          'Wait Duration (ms)',
          vm.tooltipWaitDuration,
          0,
          2000,
          notifier.setTooltipWaitDuration,
        ),
        _slider(
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
          _slider(
            'Shadow Blur',
            vm.tooltipBoxShadowBlur,
            0,
            20,
            notifier.setTooltipBoxShadowBlur,
          ),
          _slider(
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
          _slider(
            'Arrow Base Width',
            vm.tooltipArrowBaseWidth,
            4,
            30,
            notifier.setTooltipArrowBaseWidth,
          ),
          _slider(
            'Arrow Length',
            vm.tooltipArrowLength,
            2,
            20,
            notifier.setTooltipArrowLength,
          ),
          _slider(
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
        _slider(
          'Border Width',
          vm.tooltipBorderWidth,
          0,
          4,
          notifier.setTooltipBorderWidth,
        ),
        if (vm.tooltipBorderWidth > 0)
          _colorRow(
            context,
            'Border Color',
            vm.tooltipBorderColor,
            notifier.setTooltipBorderColor,
          ),
        const Divider(),
        _slider(
          'Screen Margin',
          vm.tooltipScreenMargin,
          0,
          30,
          notifier.setTooltipScreenMargin,
        ),
        const SizedBox(height: 4),
        Text(
          'Hover over nodes to see tooltips',
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildNodeStyleControls(BuildContext context) {
    return _buildSection(
      title: 'Node Style',
      children: [
        _slider(
          'Border Radius',
          vm.borderRadius,
          0,
          20,
          notifier.setBorderRadius,
        ),
      ],
    );
  }

  Widget _buildLayoutControls(BuildContext context) {
    return _buildSection(
      title: 'Layout',
      children: [
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
    );
  }

  Widget _buildInteractionControls(BuildContext context) {
    return _buildSection(
      title: 'Interaction',
      children: [
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
    );
  }

  Widget _buildDataGenerator(BuildContext context) {
    String formatNumber(int num) {
      if (num >= 1000000) {
        return '${(num / 1000000).toStringAsFixed(1)}M';
      } else if (num >= 1000) {
        return '${(num / 1000).toStringAsFixed(1)}K';
      }
      return num.toString();
    }

    final estimated = vm.estimatedNodeCount;
    final isLarge = estimated > 10000;
    final isHuge = estimated > 100000;

    return Card(
      color: isHuge
          ? Colors.red.shade50
          : isLarge
          ? Colors.orange.shade50
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Data Generator',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isHuge
                        ? Colors.red.shade100
                        : isLarge
                        ? Colors.orange.shade100
                        : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '~${formatNumber(estimated)} nodes',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isHuge
                          ? Colors.red.shade700
                          : isLarge
                          ? Colors.orange.shade700
                          : Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _intSlider(
              'Root Folders',
              vm.genRootCount,
              1,
              20,
              notifier.setGenRootCount,
            ),
            _intSlider(
              'Max Depth',
              vm.genMaxDepth,
              1,
              4,
              notifier.setGenMaxDepth,
            ),
            _intSlider(
              'Sub Folders',
              vm.genSubFolderCount,
              1,
              5,
              notifier.setGenSubFolderCount,
            ),
            _intSlider(
              'Parents',
              vm.genParentCount,
              1,
              10,
              notifier.setGenParentCount,
            ),
            _intSlider(
              'Children',
              vm.genChildCount,
              1,
              15,
              notifier.setGenChildCount,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: notifier.loadDemoData,
                    icon: const Icon(Icons.description, size: 18),
                    label: const Text('Demo'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: notifier.generateData,
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Generate'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _intSlider(
    String label,
    int value,
    int min,
    int max,
    ValueChanged<int> onChange,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value.toDouble(),
                min: min.toDouble(),
                max: max.toDouble(),
                divisions: max - min,
                onChanged: (v) => onChange(v.round()),
              ),
            ),
            SizedBox(
              width: 30,
              child: Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
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
