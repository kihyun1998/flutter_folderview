/// The Data Generator section: builds synthetic trees of a chosen shape and
/// size, to see how the view behaves at scale.
library;

import 'package:flutter/material.dart';

import '../../../providers/theme_demo_provider.dart';
import '../panel_widgets.dart';

Widget buildDataGenerator(
  BuildContext context,
  ThemeDemoViewModel vm,
  ThemeDemoState notifier,
) {
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
              // The panel is a fixed 350px wide, so a long node count (e.g.
              // "~1,000,000 nodes") overflows this Row. Let the badge shrink.
              Flexible(
                child: Container(
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
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          intSlider(
            'Root Folders',
            vm.genRootCount,
            1,
            20,
            notifier.setGenRootCount,
          ),
          intSlider('Max Depth', vm.genMaxDepth, 1, 4, notifier.setGenMaxDepth),
          intSlider(
            'Sub Folders',
            vm.genSubFolderCount,
            1,
            5,
            notifier.setGenSubFolderCount,
          ),
          intSlider(
            'Parents',
            vm.genParentCount,
            1,
            10,
            notifier.setGenParentCount,
          ),
          intSlider(
            'Children',
            vm.genChildCount,
            1,
            15,
            notifier.setGenChildCount,
          ),
          const SizedBox(height: 8),
          const Text(
            'Long Name Test',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children: [
              FilterChip(
                label: const Text('Folder', style: TextStyle(fontSize: 11)),
                selected: vm.useLongFolderNames,
                onSelected: notifier.setUseLongFolderNames,
              ),
              FilterChip(
                label: const Text('Parent', style: TextStyle(fontSize: 11)),
                selected: vm.useLongParentNames,
                onSelected: notifier.setUseLongParentNames,
              ),
              FilterChip(
                label: const Text('Child', style: TextStyle(fontSize: 11)),
                selected: vm.useLongChildNames,
                onSelected: notifier.setUseLongChildNames,
              ),
            ],
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
