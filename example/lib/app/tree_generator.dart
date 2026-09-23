import 'package:flutter_folderview/flutter_folderview.dart';

/// A tree of [folders] Folders, each holding [parentsPerFolder] Parents, each
/// holding [childrenPerParent] Children. Every Child carries its path as data.
List<Node<String>> generateTree({
  required int folders,
  required int parentsPerFolder,
  required int childrenPerParent,
}) {
  return [
    for (var f = 1; f <= folders; f++)
      Node<String>(
        id: 'f$f',
        label: 'Folder $f',
        type: NodeType.folder,
        children: [
          for (var p = 1; p <= parentsPerFolder; p++)
            Node<String>(
              id: 'f$f-p$p',
              label: 'Parent $f.$p',
              type: NodeType.parent,
              children: [
                for (var c = 1; c <= childrenPerParent; c++)
                  Node<String>(
                    id: 'f$f-p$p-c$c',
                    label: 'Child $f.$p.$c',
                    type: NodeType.child,
                    data: 'Folder $f / Parent $p / Child $c',
                  ),
              ],
            ),
        ],
      ),
  ];
}
