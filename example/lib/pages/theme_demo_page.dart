import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';

import '../providers/theme_demo_provider.dart';
import 'panel/theme_builder.dart';
import 'panel/theme_controls.dart';

class ThemeDemoPage extends StatefulWidget {
  const ThemeDemoPage({super.key});

  @override
  State<ThemeDemoPage> createState() => _ThemeDemoPageState();
}

class _ThemeDemoPageState extends State<ThemeDemoPage> {
  final ThemeDemoState _notifier = ThemeDemoState();

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _notifier,
      builder: (context, _) => _build(context, _notifier.state, _notifier),
    );
  }

  Widget _build(
    BuildContext context,
    ThemeDemoViewModel vm,
    ThemeDemoState notifier,
  ) {
    final theme = buildDemoTheme(vm);

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
            child: ThemeControls(vm: vm, notifier: notifier),
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
                    scale: vm.scale,
                    // The row card is declared once for the whole view, unlike
                    // the per-Tier label tooltips above. It draws its own
                    // surface, so it gets a real Card rather than bare text.
                    rowTooltipBuilder: vm.rowTooltipEnabled
                        ? _buildRowCard
                        : null,
                    // Without a wait, sweeping the mouse across the tree pops a
                    // card on every row it crosses.
                    rowTooltipTheme: const RowTooltipTheme(
                      waitDuration: Duration(milliseconds: 300),
                    ),
                    onScaleChanged: (newScale) {
                      notifier.setScale(newScale.clamp(0.5, 3.0));
                    },
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

  /// The row card. Hovering anywhere on a row raises it — including the indent,
  /// the chevron, and the empty space beside a short label.
  ///
  /// Returning null for a Node opts it out; here, Folders get no card.
  ///
  /// Coexists with the per-Tier label tooltips: the innermost tooltip under the

  /// pointer wins, and a label tooltip claims only the glyphs it explains. So
  /// the label text keeps its own tooltip and the rest of the row keeps this
  /// card. Leave both on.
  Widget? _buildRowCard(BuildContext context, Node<String> node) {
    if (node.type == NodeType.folder) return null;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              node.label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('id: ${node.id}', style: const TextStyle(fontSize: 11)),
            Text(
              'tier: ${node.type.name}',
              style: const TextStyle(fontSize: 11),
            ),
            if (node.children.isNotEmpty)
              Text(
                'children: ${node.children.length}',
                style: const TextStyle(fontSize: 11),
              ),
          ],
        ),
      ),
    );
  }
}
