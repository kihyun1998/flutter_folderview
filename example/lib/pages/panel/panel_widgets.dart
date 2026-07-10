import 'package:flutter/material.dart';

/// The control panel's shared primitives: a collapsible section card, two
/// sliders, and a colour picker row. Every section in `panel/sections/` is
/// built from these.

Widget panelSection({
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

Widget intSlider(
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
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ],
  );
}

Widget slider(
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

Widget colorRow(
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
            mouseCursor: SystemMouseCursors.click,
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
