import 'package:flutter/material.dart' hide TooltipTheme;
import 'package:flutter_folderview/flutter_folderview.dart';

import '../data/theme_demo_data.dart';

class ThemeDemoPage extends StatefulWidget {
  const ThemeDemoPage({super.key});

  @override
  State<ThemeDemoPage> createState() => _ThemeDemoPageState();
}

class _ThemeDemoPageState extends State<ThemeDemoPage> {
  // Line Theme
  Color _lineColor = const Color(0xFF2196F3);
  double _lineWidth = 1.5;
  LineStyle _lineStyle = LineStyle.connector;

  // Folder Theme
  double _folderIconSize = 20.0;
  Color _folderIconColor = const Color(0xFF616161);
  double _folderPadding = 0.0;
  double _folderMargin = 0.0;

  Color _folderTextColor = Colors.black87;
  double _folderFontSize = 14.0;

  // Folder Interaction Colors
  Color _folderHoverColor = const Color(0xFFEEEEEE);
  Color _folderSplashColor = const Color(0x4D2196F3);
  Color _folderHighlightColor = const Color(0x1A2196F3);

  // Parent Theme
  double _parentIconSize = 20.0;
  Color _parentIconColor = const Color(0xFF616161);
  double _parentPadding = 0.0;
  double _parentMargin = 0.0;

  Color _parentTextColor = Colors.black87;
  double _parentFontSize = 14.0;

  // Parent Interaction Colors
  Color _parentHoverColor = const Color(0xFFEEEEEE);
  Color _parentSplashColor = const Color(0x4D2196F3);
  Color _parentHighlightColor = const Color(0x1A2196F3);

  // Child Theme
  double _childIconSize = 20.0;
  Color _childIconColor = const Color(0xFF616161);
  double _childPadding = 0.0;
  double _childMargin = 0.0;

  Color _childTextColor = Colors.black87;
  double _childFontSize = 14.0;
  Color _childSelectedBg = const Color(0xFFE3F2FD);

  // Child Interaction Colors
  Color _childHoverColor = const Color(0xFFEEEEEE);
  Color _childSplashColor = const Color(0x4D2196F3);
  Color _childHighlightColor = const Color(0x1A2196F3);

  // Expand Icon
  double _expandIconSize = 20.0;
  Color _expandIconColor = const Color(0xFF616161);
  double _expandPadding = 0.0;
  double _expandMargin = 0.0;

  // Other
  ViewMode _viewMode = ViewMode.folder;
  double _borderRadius = 8.0;

  // Interaction
  double _clickInterval = 300.0;
  double _animationDuration = 200.0;

  // Layout
  double _rowHeight = 40.0;
  double _rowSpacing = 0.0;

  // Tooltip
  bool _folderTooltipEnabled = true;
  Color _folderTooltipBgColor = const Color(0xFF424242);
  bool _parentTooltipEnabled = true;
  Color _parentTooltipBgColor = const Color(0xFF424242);
  bool _childTooltipEnabled = true;
  Color _childTooltipBgColor = const Color(0xFF424242);

  late List<Node<String>> _data;
  Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _data = getThemeDemoData();
  }

  void _handleTap(Node<String> node) {
    setState(() {
      if (node.type == NodeType.child) {
        _selectedIds.contains(node.id)
            ? _selectedIds.remove(node.id)
            : _selectedIds.add(node.id);
      } else if (node.canExpand) {
        _data = _toggle(_data, node.id);
      }
    });
  }

  void _handleDoubleTap(Node<String> node) {
    if (!mounted) return;
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  List<Node<String>> _toggle(List<Node<String>> nodes, String id) {
    return nodes.map((n) {
      if (n.id == id) {
        return Node<String>(
          id: n.id,
          label: n.label,
          type: n.type,
          data: n.data,
          children: n.children,
          isExpanded: !n.isExpanded,
        );
      } else if (n.children.isNotEmpty) {
        return Node<String>(
          id: n.id,
          label: n.label,
          type: n.type,
          data: n.data,
          children: _toggle(n.children, id),
          isExpanded: n.isExpanded,
        );
      }
      return n;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFolderViewTheme<String>(
      lineTheme: FolderViewLineTheme(
        lineColor: _lineColor,
        lineWidth: _lineWidth,
        lineStyle: _lineStyle,
      ),
      folderTheme: FolderNodeTheme<String>(
        widget: Icon(
          Icons.folder,
          color: _folderIconColor,
          size: _folderIconSize,
        ),
        openWidget: Icon(
          Icons.folder_open,
          color: _folderIconColor,
          size: _folderIconSize,
        ),
        width: _folderIconSize,
        height: _folderIconSize,
        padding: EdgeInsets.symmetric(horizontal: _folderPadding),
        margin: EdgeInsets.symmetric(horizontal: _folderMargin),

        textStyle: TextStyle(
          color: _folderTextColor,
          fontSize: _folderFontSize,
        ),
        hoverColor: _folderHoverColor,
        splashColor: _folderSplashColor,
        highlightColor: _folderHighlightColor,
        tooltipTheme: NodeTooltipTheme<String>(
          useTooltip: _folderTooltipEnabled,
          message: 'Folder node',
          backgroundColor: _folderTooltipBgColor,
        ),
      ),
      parentTheme: ParentNodeTheme<String>(
        widget: Icon(
          Icons.account_tree,
          color: _parentIconColor,
          size: _parentIconSize,
        ),
        width: _parentIconSize,
        height: _parentIconSize,
        padding: EdgeInsets.symmetric(horizontal: _parentPadding),
        margin: EdgeInsets.symmetric(horizontal: _parentMargin),

        textStyle: TextStyle(
          color: _parentTextColor,
          fontSize: _parentFontSize,
        ),
        hoverColor: _parentHoverColor,
        splashColor: _parentSplashColor,
        highlightColor: _parentHighlightColor,
        tooltipTheme: NodeTooltipTheme<String>(
          useTooltip: _parentTooltipEnabled,
          message: 'Parent node',
          backgroundColor: _parentTooltipBgColor,
        ),
      ),
      childTheme: ChildNodeTheme<String>(
        widget: Icon(
          Icons.insert_drive_file,
          color: _childIconColor,
          size: _childIconSize,
        ),
        width: _childIconSize,
        height: _childIconSize,
        padding: EdgeInsets.symmetric(horizontal: _childPadding),
        margin: EdgeInsets.symmetric(horizontal: _childMargin),

        textStyle: TextStyle(color: _childTextColor, fontSize: _childFontSize),
        selectedTextStyle: const TextStyle(fontWeight: FontWeight.bold),
        selectedBackgroundColor: _childSelectedBg,
        hoverColor: _childHoverColor,
        splashColor: _childSplashColor,
        highlightColor: _childHighlightColor,
        clickInterval: _clickInterval.round(),
        tooltipTheme: NodeTooltipTheme<String>(
          useTooltip: _childTooltipEnabled,
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
          backgroundColor: _childTooltipBgColor,
        ),
      ),
      expandIconTheme: ExpandIconTheme(
        widget: Icon(
          Icons.chevron_right,
          color: _expandIconColor,
          size: _expandIconSize,
        ),
        width: _expandIconSize,
        height: _expandIconSize,
        padding: EdgeInsets.only(left: _expandPadding),
        margin: EdgeInsets.only(left: _expandMargin),
      ),
      scrollbarTheme: FolderViewScrollbarTheme(
        thumbColor: Colors.grey.shade600,
        trackColor: Colors.grey.shade200,
      ),
      nodeStyleTheme: FolderViewNodeStyleTheme(borderRadius: _borderRadius),
      animationDuration: _animationDuration.round(),
      rowHeight: _rowHeight,
      rowSpacing: _rowSpacing,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Theme Demo'), centerTitle: true),
      body: Row(
        children: [
          SizedBox(width: 350, child: _buildControls()),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FolderView<String>(
                    data: _data,
                    mode: _viewMode,
                    onNodeTap: _handleTap,
                    onDoubleNodeTap: _handleDoubleTap,
                    selectedNodeIds: _selectedIds,
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

  Widget _buildControls() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildViewMode(),
        _buildLineControls(),
        _buildExpandIconControls(),
        _buildFolderControls(),
        _buildParentControls(),
        _buildChildControls(),
        _buildTooltipControls(),
        _buildNodeStyleControls(),
        _buildLayoutControls(),
        _buildInteractionControls(),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => setState(() {
            _lineColor = const Color(0xFF2196F3);
            _lineWidth = 1.5;
            _lineStyle = LineStyle.connector;
            _folderIconSize = 20.0;
            _folderIconColor = const Color(0xFF616161);
            _folderPadding = 0.0;
            _folderMargin = 0.0;

            _folderTextColor = Colors.black87;
            _folderFontSize = 14.0;
            _folderHoverColor = const Color(0xFFEEEEEE);
            _folderSplashColor = const Color(0x4D2196F3);
            _folderHighlightColor = const Color(0x1A2196F3);
            _parentIconSize = 20.0;
            _parentIconColor = const Color(0xFF616161);
            _parentPadding = 0.0;
            _parentMargin = 0.0;

            _parentTextColor = Colors.black87;
            _parentFontSize = 14.0;
            _parentHoverColor = const Color(0xFFEEEEEE);
            _parentSplashColor = const Color(0x4D2196F3);
            _parentHighlightColor = const Color(0x1A2196F3);
            _childIconSize = 20.0;
            _childIconColor = const Color(0xFF616161);
            _childPadding = 0.0;
            _childMargin = 0.0;

            _childTextColor = Colors.black87;
            _childFontSize = 14.0;
            _childSelectedBg = const Color(0xFFE3F2FD);
            _childHoverColor = const Color(0xFFEEEEEE);
            _childSplashColor = const Color(0x4D2196F3);
            _childHighlightColor = const Color(0x1A2196F3);
            _expandIconSize = 20.0;
            _expandIconColor = const Color(0xFF616161);
            _expandPadding = 0.0;
            _expandMargin = 0.0;
            _viewMode = ViewMode.folder;
            _borderRadius = 8.0;
            _clickInterval = 300.0;
            _animationDuration = 200.0;
            _rowHeight = 40.0;
            _rowSpacing = 0.0;
            _folderTooltipEnabled = true;
            _folderTooltipBgColor = const Color(0xFF424242);
            _parentTooltipEnabled = true;
            _parentTooltipBgColor = const Color(0xFF424242);
            _childTooltipEnabled = true;
            _childTooltipBgColor = const Color(0xFF424242);
            _data = getThemeDemoData();
            _selectedIds = {};
          }),
          icon: const Icon(Icons.refresh),
          label: const Text('Reset'),
        ),
      ],
    );
  }

  Widget _buildViewMode() {
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
              selected: {_viewMode},
              onSelectionChanged: (s) => setState(() => _viewMode = s.first),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Line', style: TextStyle(fontWeight: FontWeight.bold)),
            _slider(
              'Width',
              _lineWidth,
              0.5,
              5,
              (v) => setState(() => _lineWidth = v),
            ),
            _colorRow(
              'Color',
              _lineColor,
              (c) => setState(() => _lineColor = c),
            ),
            Wrap(
              spacing: 4,
              children: [
                ChoiceChip(
                  label: const Text('Connect', style: TextStyle(fontSize: 12)),
                  selected: _lineStyle == LineStyle.connector,
                  onSelected: (s) => s
                      ? setState(() => _lineStyle = LineStyle.connector)
                      : null,
                ),
                ChoiceChip(
                  label: const Text('Scope', style: TextStyle(fontSize: 12)),
                  selected: _lineStyle == LineStyle.scope,
                  onSelected: (s) =>
                      s ? setState(() => _lineStyle = LineStyle.scope) : null,
                ),
                ChoiceChip(
                  label: const Text('None', style: TextStyle(fontSize: 12)),
                  selected: _lineStyle == LineStyle.none,
                  onSelected: (s) =>
                      s ? setState(() => _lineStyle = LineStyle.none) : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandIconControls() {
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
            _slider(
              'Size',
              _expandIconSize,
              12,
              32,
              (v) => setState(() => _expandIconSize = v),
            ),
            _colorRow(
              'Color',
              _expandIconColor,
              (c) => setState(() => _expandIconColor = c),
            ),
            _slider(
              'Padding',
              _expandPadding,
              0,
              8,
              (v) => setState(() => _expandPadding = v),
            ),
            _slider(
              'Margin',
              _expandMargin,
              0,
              8,
              (v) => setState(() => _expandMargin = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Folder', style: TextStyle(fontWeight: FontWeight.bold)),
            _slider(
              'Icon Size',
              _folderIconSize,
              12,
              32,
              (v) => setState(() => _folderIconSize = v),
            ),
            _colorRow(
              'Icon',
              _folderIconColor,
              (c) => setState(() => _folderIconColor = c),
            ),
            _slider(
              'Padding',
              _folderPadding,
              0,
              8,
              (v) => setState(() => _folderPadding = v),
            ),
            _slider(
              'Margin',
              _folderMargin,
              0,
              8,
              (v) => setState(() => _folderMargin = v),
            ),

            _colorRow(
              'Text',
              _folderTextColor,
              (c) => setState(() => _folderTextColor = c),
            ),
            _slider(
              'Font',
              _folderFontSize,
              10,
              24,
              (v) => setState(() => _folderFontSize = v),
            ),
            const Divider(),
            const Text(
              'Interaction',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            _colorRow(
              'Hover',
              _folderHoverColor,
              (c) => setState(() => _folderHoverColor = c),
            ),
            _colorRow(
              'Splash',
              _folderSplashColor,
              (c) => setState(() => _folderSplashColor = c),
            ),
            _colorRow(
              'Highlight',
              _folderHighlightColor,
              (c) => setState(() => _folderHighlightColor = c),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Parent', style: TextStyle(fontWeight: FontWeight.bold)),
            _slider(
              'Icon Size',
              _parentIconSize,
              12,
              32,
              (v) => setState(() => _parentIconSize = v),
            ),
            _colorRow(
              'Icon',
              _parentIconColor,
              (c) => setState(() => _parentIconColor = c),
            ),
            _slider(
              'Padding',
              _parentPadding,
              0,
              8,
              (v) => setState(() => _parentPadding = v),
            ),
            _slider(
              'Margin',
              _parentMargin,
              0,
              8,
              (v) => setState(() => _parentMargin = v),
            ),

            _colorRow(
              'Text',
              _parentTextColor,
              (c) => setState(() => _parentTextColor = c),
            ),
            _slider(
              'Font',
              _parentFontSize,
              10,
              24,
              (v) => setState(() => _parentFontSize = v),
            ),
            const Divider(),
            const Text(
              'Interaction',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            _colorRow(
              'Hover',
              _parentHoverColor,
              (c) => setState(() => _parentHoverColor = c),
            ),
            _colorRow(
              'Splash',
              _parentSplashColor,
              (c) => setState(() => _parentSplashColor = c),
            ),
            _colorRow(
              'Highlight',
              _parentHighlightColor,
              (c) => setState(() => _parentHighlightColor = c),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Child', style: TextStyle(fontWeight: FontWeight.bold)),
            _slider(
              'Icon Size',
              _childIconSize,
              12,
              32,
              (v) => setState(() => _childIconSize = v),
            ),
            _colorRow(
              'Icon',
              _childIconColor,
              (c) => setState(() => _childIconColor = c),
            ),
            _slider(
              'Padding',
              _childPadding,
              0,
              8,
              (v) => setState(() => _childPadding = v),
            ),
            _slider(
              'Margin',
              _childMargin,
              0,
              8,
              (v) => setState(() => _childMargin = v),
            ),

            _colorRow(
              'Text',
              _childTextColor,
              (c) => setState(() => _childTextColor = c),
            ),
            _slider(
              'Font',
              _childFontSize,
              10,
              24,
              (v) => setState(() => _childFontSize = v),
            ),
            const Divider(),
            _colorRow(
              'Selected BG',
              _childSelectedBg,
              (c) => setState(() => _childSelectedBg = c),
            ),
            const Divider(),
            const Text(
              'Interaction',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            _colorRow(
              'Hover',
              _childHoverColor,
              (c) => setState(() => _childHoverColor = c),
            ),
            _colorRow(
              'Splash',
              _childSplashColor,
              (c) => setState(() => _childSplashColor = c),
            ),
            _colorRow(
              'Highlight',
              _childHighlightColor,
              (c) => setState(() => _childHighlightColor = c),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTooltipControls() {
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
              title: const Text(
                'Folder Tooltip',
                style: TextStyle(fontSize: 12),
              ),
              value: _folderTooltipEnabled,
              onChanged: (v) => setState(() => _folderTooltipEnabled = v),
            ),
            if (_folderTooltipEnabled)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: _colorRow(
                  'BG Color',
                  _folderTooltipBgColor,
                  (c) => setState(() => _folderTooltipBgColor = c),
                ),
              ),
            const Divider(),
            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Parent Tooltip',
                style: TextStyle(fontSize: 12),
              ),
              value: _parentTooltipEnabled,
              onChanged: (v) => setState(() => _parentTooltipEnabled = v),
            ),
            if (_parentTooltipEnabled)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: _colorRow(
                  'BG Color',
                  _parentTooltipBgColor,
                  (c) => setState(() => _parentTooltipBgColor = c),
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
              value: _childTooltipEnabled,
              onChanged: (v) => setState(() => _childTooltipEnabled = v),
            ),
            if (_childTooltipEnabled)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: _colorRow(
                  'BG Color',
                  _childTooltipBgColor,
                  (c) => setState(() => _childTooltipBgColor = c),
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

  Widget _buildNodeStyleControls() {
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
            _slider(
              'Border Radius',
              _borderRadius,
              0,
              20,
              (v) => setState(() => _borderRadius = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayoutControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Layout', style: TextStyle(fontWeight: FontWeight.bold)),
            _slider(
              'Row Height',
              _rowHeight,
              20,
              80,
              (v) => setState(() => _rowHeight = v),
            ),
            const SizedBox(height: 4),
            Text(
              'Height of each row/node',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            _slider(
              'Row Spacing',
              _rowSpacing,
              0,
              20,
              (v) => setState(() => _rowSpacing = v),
            ),
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

  Widget _buildInteractionControls() {
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
              _clickInterval,
              100,
              1000,
              (v) => setState(() => _clickInterval = v),
            ),
            const SizedBox(height: 4),
            Text(
              'Double-click detection time for child nodes',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            _slider(
              'Animation Duration (ms)',
              _animationDuration,
              50,
              800,
              (v) => setState(() => _animationDuration = v),
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

  Widget _colorRow(String label, Color value, ValueChanged<Color> onChange) {
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
