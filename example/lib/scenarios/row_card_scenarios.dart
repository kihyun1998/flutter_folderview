import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';

/// The card both row-card scenarios build: the Node's type and label.
Widget _card(BuildContext context, Node<String> node) => Card(
  child: Padding(
    padding: const EdgeInsets.all(8),
    child: Text('Row card · ${node.label}'),
  ),
);

/// A caption over a scenario's tree.
class _Captioned extends StatelessWidget {
  const _Captioned({required this.caption, required this.child});

  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.all(12),
        child: Text(caption, style: const TextStyle(fontSize: 12)),
      ),
      Expanded(child: child),
    ],
  );
}

/// The row card and a label tooltip on the same rows: the label tooltip is
/// innermost, so it wins while the pointer is on the label.
class RowCardNestingStage extends StatelessWidget {
  const RowCardNestingStage({super.key});

  static const labelTooltip = 'Label tooltip';

  static final nodes = [
    const Node<String>(
      id: 'f',
      label: 'Projects',
      type: NodeType.folder,
      children: [
        Node<String>(
          id: 'p',
          label: 'Website',
          type: NodeType.parent,
          children: [
            Node<String>(id: 'c1', label: 'index.html', type: NodeType.child),
            Node<String>(id: 'c2', label: 'styles.css', type: NodeType.child),
          ],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) => _Captioned(
    caption:
        'Hover a Child\'s label: its label tooltip shows and the row card '
        'stays hidden. Hover the rest of the row: the row card shows. '
        'just_tooltip shows only the innermost tooltip under the pointer.',
    child: FolderView<String>(
      data: nodes,
      mode: ViewMode.folder,
      expandedNodeIds: const {'f', 'p'},
      rowTooltipBuilder: _card,
      theme: FlutterFolderViewTheme<String>.light().copyWith(
        childTheme: const ChildNodeTheme<String>(
          tooltipTheme: NodeTooltipTheme<String>(
            useTooltip: true,
            message: labelTooltip,
          ),
        ),
      ),
    ),
  );
}

/// A row wider than the viewport: the card anchors at the pointer, so it
/// shows beside the cursor wherever the view is scrolled.
class WideRowStage extends StatelessWidget {
  const WideRowStage({super.key});

  static final longLabel =
      '${'A label long enough to make its row wider than any viewport. ' * 6}'
      '— end';

  static final nodes = [
    Node<String>(
      id: 'f',
      label: 'Archive',
      type: NodeType.folder,
      children: [
        Node<String>(
          id: 'p',
          label: 'Reports',
          type: NodeType.parent,
          children: [
            Node<String>(id: 'wide', label: longLabel, type: NodeType.child),
            const Node<String>(
              id: 'short',
              label: 'summary.pdf',
              type: NodeType.child,
            ),
          ],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) => _Captioned(
    caption:
        'Every row is as wide as the longest one. Scroll right and hover '
        'any row: the card opens beside the pointer, not at the centre of '
        'what is visible of the row, which is the centre of the view.',
    child: FolderView<String>(
      data: nodes,
      mode: ViewMode.folder,
      expandedNodeIds: const {'f', 'p'},
      rowTooltipBuilder: _card,
    ),
  );
}
