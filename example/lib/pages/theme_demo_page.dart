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
                          data: getThemeDemoData(),
                          mode: ViewMode.folder,
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
                'Color: #${_lineColor.value.toRadixString(16).substring(2).toUpperCase()}',
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
    });
  }
}
