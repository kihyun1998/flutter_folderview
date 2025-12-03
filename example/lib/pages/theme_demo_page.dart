import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';

import '../data/theme_demo_data.dart';

class ThemeDemoPage extends StatefulWidget {
  const ThemeDemoPage({super.key});

  @override
  State<ThemeDemoPage> createState() => _ThemeDemoPageState();
}

class _ThemeDemoPageState extends State<ThemeDemoPage> {
  // Line Theme State
  Color _lineColor = const Color(0xFF2196F3); // Blue
  double _lineWidth = 1.5;
  LineStyle _lineStyle = LineStyle.connector;

  // Scrollbar Theme State
  Color _scrollbarThumbColor = Colors.grey.shade600;
  Color _scrollbarTrackColor = Colors.grey.shade200;
  double _scrollbarThickness = 12.0;
  double _scrollbarRadius = 4.0;
  double _scrollbarHoverOpacity = 0.8;
  double _scrollbarTrackWidth = 16.0;
  double _scrollbarTrackRadius = 8.0;
  bool _scrollbarAlwaysVisible = false;

  // Text Theme State
  Color _textColor = Colors.black87;
  double _fontSize = 14.0;
  Color _folderTextColor = Colors.black87;
  Color _parentTextColor = Colors.black87;
  Color _childTextColor = Colors.black87;

  // FolderView State
  late List<Node<String>> _treeData;
  Set<String> _selectedNodeIds = {};

  @override
  void initState() {
    super.initState();
    _treeData = getThemeDemoData();
  }

  void _handleNodeTap(Node<String> node) {
    setState(() {
      if (node.type == NodeType.child) {
        // Toggle selection for child nodes
        if (_selectedNodeIds.contains(node.id)) {
          _selectedNodeIds.remove(node.id);
        } else {
          _selectedNodeIds.add(node.id);
        }
      } else if (node.canExpand) {
        // Toggle expansion for parent and folder nodes
        _treeData = _toggleNodeRecursive(_treeData, node.id);
      }
    });
  }

  List<Node<String>> _toggleNodeRecursive(
    List<Node<String>> nodes,
    String targetId,
  ) {
    return nodes.map((node) {
      if (node.id == targetId) {
        return Node<String>(
          id: node.id,
          label: node.label,
          type: node.type,
          data: node.data,
          children: node.children,
          isExpanded: !node.isExpanded,
        );
      } else if (node.children.isNotEmpty) {
        return Node<String>(
          id: node.id,
          label: node.label,
          type: node.type,
          data: node.data,
          children: _toggleNodeRecursive(node.children, targetId),
          isExpanded: node.isExpanded,
        );
      }
      return node;
    }).toList();
  }

  // Predefined colors for quick selection
  final List<Color> _presetColors = [
    const Color(0xFF2196F3), // Blue
    const Color(0xFF4CAF50), // Green
    const Color(0xFFFF9800), // Orange
    const Color(0xFFF44336), // Red
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF607D88), // Grey
  ];

  @override
  Widget build(BuildContext context) {
    // Build the theme from current state
    final theme = FlutterFolderViewTheme(
      lineTheme: FolderViewLineTheme(
        lineColor: _lineColor,
        lineWidth: _lineWidth,
        lineStyle: _lineStyle,
      ),
      scrollbarTheme: FolderViewScrollbarTheme(
        thumbColor: _scrollbarThumbColor,
        trackColor: _scrollbarTrackColor,
        thickness: _scrollbarThickness,
        radius: _scrollbarRadius,
        hoverOpacity: _scrollbarHoverOpacity,
        nonHoverOpacity: _scrollbarAlwaysVisible ? 1.0 : 0.0,
        trackWidth: _scrollbarTrackWidth,
        trackRadius: _scrollbarTrackRadius,
      ),
      textTheme: FolderViewTextTheme(
        textStyle: TextStyle(color: _textColor, fontSize: _fontSize),
        folderTextStyle: TextStyle(
          color: _folderTextColor,
          fontWeight: FontWeight.bold,
        ),
        parentTextStyle: TextStyle(
          color: _parentTextColor,
          fontWeight: FontWeight.w500,
        ),
        childTextStyle: TextStyle(
          color: _childTextColor,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Customization Demo'),
        centerTitle: true,
      ),
      body: Row(
        children: [
          // Left side: Control Panel
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: _buildControlPanel(),
          ),

          // Right side: Live Preview
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Preview',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: FolderView<String>(
                          data: _treeData,
                          mode: ViewMode.folder,
                          onNodeTap: _handleNodeTap,
                          selectedNodeIds: _selectedNodeIds,
                          theme: theme,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          'Line Theme Controls',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),

        // Line Color
        _buildSection(
          title: 'Line Color',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presetColors.map((color) {
                  final isSelected = _lineColor == color;
                  return InkWell(
                    onTap: () => setState(() => _lineColor = color),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Text(
                'Color: #${_lineColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Line Width
        _buildSection(
          title: 'Line Width',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Slider(
                value: _lineWidth,
                min: 0.5,
                max: 5.0,
                divisions: 18,
                label: _lineWidth.toStringAsFixed(1),
                onChanged: (value) => setState(() => _lineWidth = value),
              ),
              Text(
                'Width: ${_lineWidth.toStringAsFixed(1)}px',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Line Style
        _buildSection(
          title: 'Line Style',
          child: Column(
            children: [
              RadioListTile<LineStyle>(
                title: const Text('Connector'),
                subtitle: const Text('Traditional tree lines ├─ and └─'),
                value: LineStyle.connector,
                groupValue: _lineStyle,
                onChanged: (value) => setState(() => _lineStyle = value!),
              ),
              RadioListTile<LineStyle>(
                title: const Text('Scope'),
                subtitle: const Text('Vertical indent guide (like VS Code)'),
                value: LineStyle.scope,
                groupValue: _lineStyle,
                onChanged: (value) => setState(() => _lineStyle = value!),
              ),
              RadioListTile<LineStyle>(
                title: const Text('None'),
                subtitle: const Text('No connection lines'),
                value: LineStyle.none,
                groupValue: _lineStyle,
                onChanged: (value) => setState(() => _lineStyle = value!),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Divider
        const Divider(height: 32),

        Text(
          'Scrollbar Theme Controls',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),

        // Scrollbar Thumb Color
        _buildSection(
          title: 'Thumb Color',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presetColors.map((color) {
                  final isSelected = _scrollbarThumbColor == color;
                  return InkWell(
                    onTap: () => setState(() => _scrollbarThumbColor = color),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Text(
                'Color: #${_scrollbarThumbColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Scrollbar Track Color
        _buildSection(
          title: 'Track Color',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Colors.grey.shade200,
                  Colors.grey.shade300,
                  Colors.blue.shade100,
                  Colors.green.shade100,
                  Colors.orange.shade100,
                  Colors.purple.shade100,
                ].map((color) {
                  final isSelected = _scrollbarTrackColor == color;
                  return InkWell(
                    onTap: () => setState(() => _scrollbarTrackColor = color),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Text(
                'Color: #${_scrollbarTrackColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Scrollbar Thickness
        _buildSection(
          title: 'Thumb Thickness',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Slider(
                value: _scrollbarThickness,
                min: 8.0,
                max: 20.0,
                divisions: 12,
                label: _scrollbarThickness.toStringAsFixed(0),
                onChanged: (value) => setState(() => _scrollbarThickness = value),
              ),
              Text(
                'Thickness: ${_scrollbarThickness.toStringAsFixed(0)}px',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Scrollbar Radius
        _buildSection(
          title: 'Thumb Radius',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Slider(
                value: _scrollbarRadius,
                min: 0.0,
                max: 10.0,
                divisions: 20,
                label: _scrollbarRadius.toStringAsFixed(1),
                onChanged: (value) => setState(() => _scrollbarRadius = value),
              ),
              Text(
                'Radius: ${_scrollbarRadius.toStringAsFixed(1)}px',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Hover Opacity
        _buildSection(
          title: 'Hover Opacity',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Slider(
                value: _scrollbarHoverOpacity,
                min: 0.0,
                max: 1.0,
                divisions: 20,
                label: _scrollbarHoverOpacity.toStringAsFixed(2),
                onChanged: (value) => setState(() => _scrollbarHoverOpacity = value),
              ),
              Text(
                'Opacity: ${_scrollbarHoverOpacity.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Track Width
        _buildSection(
          title: 'Track Width',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Slider(
                value: _scrollbarTrackWidth,
                min: 12.0,
                max: 24.0,
                divisions: 12,
                label: _scrollbarTrackWidth.toStringAsFixed(0),
                onChanged: (value) => setState(() => _scrollbarTrackWidth = value),
              ),
              Text(
                'Width: ${_scrollbarTrackWidth.toStringAsFixed(0)}px',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Track Radius
        _buildSection(
          title: 'Track Radius',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Slider(
                value: _scrollbarTrackRadius,
                min: 0.0,
                max: 12.0,
                divisions: 24,
                label: _scrollbarTrackRadius.toStringAsFixed(1),
                onChanged: (value) =>
                    setState(() => _scrollbarTrackRadius = value),
              ),
              Text(
                'Radius: ${_scrollbarTrackRadius.toStringAsFixed(1)}px',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Always Visible Toggle
        _buildSection(
          title: 'Always Visible',
          child: SwitchListTile(
            title: const Text('Show scrollbar without hover'),
            subtitle: const Text('Keep scrollbar visible at all times'),
            value: _scrollbarAlwaysVisible,
            onChanged: (value) => setState(() => _scrollbarAlwaysVisible = value),
            contentPadding: EdgeInsets.zero,
          ),
        ),

        const SizedBox(height: 24),

        // Divider
        const Divider(height: 32),

        Text(
          'Text Theme Controls',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),

        // Text Color
        _buildSection(
          title: 'Base Text Color',
          child: _buildColorPicker(
            _textColor,
            (color) => setState(() => _textColor = color),
          ),
        ),

        const SizedBox(height: 24),

        // Font Size
        _buildSection(
          title: 'Font Size',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Slider(
                value: _fontSize,
                min: 10.0,
                max: 24.0,
                divisions: 14,
                label: _fontSize.toStringAsFixed(1),
                onChanged: (value) => setState(() => _fontSize = value),
              ),
              Text(
                'Size: ${_fontSize.toStringAsFixed(1)}px',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Folder Text Color
        _buildSection(
          title: 'Folder Text Color',
          child: _buildColorPicker(
            _folderTextColor,
            (color) => setState(() => _folderTextColor = color),
          ),
        ),

        const SizedBox(height: 24),

        // Parent Text Color
        _buildSection(
          title: 'Parent Text Color',
          child: _buildColorPicker(
            _parentTextColor,
            (color) => setState(() => _parentTextColor = color),
          ),
        ),

        const SizedBox(height: 24),

        // Child Text Color
        _buildSection(
          title: 'Child Text Color',
          child: _buildColorPicker(
            _childTextColor,
            (color) => setState(() => _childTextColor = color),
          ),
        ),

        const SizedBox(height: 24),

        const SizedBox(height: 24),

        // Reset Button
        FilledButton.icon(
          onPressed: _resetToDefaults,
          icon: const Icon(Icons.refresh),
          label: const Text('Reset to Default'),
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  void _resetToDefaults() {
    setState(() {
      _lineColor = const Color(0xFF2196F3);
      _lineWidth = 1.5;
      _lineStyle = LineStyle.connector;
      _scrollbarThumbColor = Colors.grey.shade600;
      _scrollbarTrackColor = Colors.grey.shade200;
      _scrollbarThickness = 12.0;
      _scrollbarRadius = 4.0;
      _scrollbarHoverOpacity = 0.8;
      _scrollbarTrackWidth = 16.0;
      _scrollbarTrackRadius = 8.0;
      _scrollbarAlwaysVisible = false;
      _textColor = Colors.black87;
      _fontSize = 14.0;
      _folderTextColor = Colors.black87;
      _parentTextColor = Colors.black87;
      _childTextColor = Colors.black87;
      _treeData = getThemeDemoData();
      _selectedNodeIds = {};
    });
  }

  Widget _buildColorPicker(Color currentColor, ValueChanged<Color> onColorChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._presetColors,
            Colors.black87,
            Colors.white,
          ].map((color) {
            final isSelected = currentColor == color;
            return InkWell(
              onTap: () => onColorChanged(color),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                    width: 3,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          'Color: #${currentColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
