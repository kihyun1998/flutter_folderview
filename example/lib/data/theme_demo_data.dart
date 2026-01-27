import 'package:flutter_folderview/flutter_folderview.dart';

List<Node<String>> getThemeDemoData() {
  return [
    Node<String>(
      id: '1',
      label: 'Theme System Architecture',
      type: NodeType.folder,

      children: [
        Node<String>(
          id: '1-1',
          label: 'FlutterFolderViewTheme (Master Class)',
          type: NodeType.parent,
    
          children: [
            Node<String>(
              id: '1-1-1',
              label: 'FolderViewLineTheme',
              type: NodeType.child,
            ),
            Node<String>(
              id: '1-1-2',
              label: 'FolderViewNodeTheme (Future)',
              type: NodeType.child,
            ),
            Node<String>(
              id: '1-1-3',
              label: 'FolderViewTextTheme (Future)',
              type: NodeType.child,
            ),
          ],
        ),
        Node<String>(
          id: '1-2',
          label: 'FolderViewTheme (InheritedWidget)',
          type: NodeType.parent,

          children: [
            Node<String>(
              id: '1-2-1',
              label: 'of(context) method',
              type: NodeType.child,
            ),
            Node<String>(
              id: '1-2-2',
              label: 'maybeOf(context) method',
              type: NodeType.child,
            ),
          ],
        ),
      ],
    ),
    Node<String>(
      id: '2',
      label: 'Line Theme Properties',
      type: NodeType.folder,

      children: [
        Node<String>(
          id: '2-1',
          label: 'Visual Properties',
          type: NodeType.parent,
    
          children: [
            Node<String>(
              id: '2-1-1',
              label: 'lineColor - Color of connection lines',
              type: NodeType.child,
            ),
            Node<String>(
              id: '2-1-2',
              label: 'lineWidth - Thickness of lines (0.5-5.0)',
              type: NodeType.child,
            ),
            Node<String>(
              id: '2-1-3',
              label: 'strokeCap - Line endpoint style',
              type: NodeType.child,
            ),
          ],
        ),
        Node<String>(
          id: '2-2',
          label: 'Connection Styles',
          type: NodeType.parent,
    
          children: [
            Node<String>(
              id: '2-2-1',
              label: 'Straight - Direct lines',
              type: NodeType.child,
            ),
            Node<String>(
              id: '2-2-2',
              label: 'Curved - Smooth bezier curves',
              type: NodeType.child,
            ),
            Node<String>(
              id: '2-2-3',
              label: 'Stepped - Horizontal then vertical',
              type: NodeType.child,
            ),
          ],
        ),
      ],
    ),
    Node<String>(
      id: '3',
      label:
          'Usage Example with really long long long long label to test horizontal scroll',
      type: NodeType.folder,

      children: [
        Node<String>(
          id: '3-1',
          label: 'Apply theme to widget tree',
          type: NodeType.parent,

          children: [
            Node<String>(
              id: '3-1-1',
              label: 'Wrap with FolderViewTheme',
              type: NodeType.child,
            ),
            Node<String>(
              id: '3-1-2',
              label: 'Pass theme to FolderView',
              type: NodeType.child,
            ),
          ],
        ),
      ],
    ),
  ];
}
