/// The preset bar: named combinations of the demo's settings, one click each.
library;

import 'package:flutter/material.dart';

import '../../presets/demo_preset.dart';

/// Sits above the tree. Each chip applies a preset; the line beneath says where
/// to point the mouse once it has been applied.
class PresetBar extends StatelessWidget {
  const PresetBar({
    super.key,
    required this.presets,
    required this.selected,
    required this.onSelected,
  });

  final List<DemoPreset> presets;
  final DemoPreset selected;
  final ValueChanged<DemoPreset> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: presets.map((preset) {
              return ChoiceChip(
                label: Text(preset.title),
                selected: identical(preset, selected),
                onSelected: (isSelected) {
                  if (isSelected) onSelected(preset);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            selected.whatToLookFor,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
