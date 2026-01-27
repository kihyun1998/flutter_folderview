import 'package:flutter_folderview/flutter_folderview.dart';

List<Node<String>> getSoftwareComponentData() {
  // Frontend
  const frontend = Node<String>(
    id: 'sw_frontend',
    label: 'Frontend Layer',
    type: NodeType.parent,
    children: [
      Node<String>(id: 'sw_ui_1', label: 'LoginScreen', type: NodeType.child),
      Node<String>(
        id: 'sw_ui_2',
        label: 'DashboardWidget',
        type: NodeType.child,
      ),
      Node<String>(id: 'sw_ui_3', label: 'NavigationBar', type: NodeType.child),
    ],
  );

  // Backend
  const backend = Node<String>(
    id: 'sw_backend',
    label: 'Backend Services',
    type: NodeType.parent,
    children: [
      Node<String>(
        id: 'sw_api_1',
        label: 'AuthenticationAPI',
        type: NodeType.child,
      ),
      Node<String>(
        id: 'sw_api_2',
        label: 'DatabaseService',
        type: NodeType.child,
      ),
      Node<String>(id: 'sw_api_3', label: 'CacheManager', type: NodeType.child),
    ],
  );

  // Data Layer
  const data = Node<String>(
    id: 'sw_data',
    label: 'Data Layer',
    type: NodeType.parent,
    children: [
      Node<String>(id: 'sw_model_1', label: 'UserModel', type: NodeType.child),
      Node<String>(
        id: 'sw_model_2',
        label: 'ProductModel',
        type: NodeType.child,
      ),
    ],
  );

  // Utilities
  const utils = Node<String>(
    id: 'sw_utils',
    label: 'Utilities',
    type: NodeType.parent,
    children: [
      Node<String>(
        id: 'sw_util_1',
        label: 'DateFormatter',
        type: NodeType.child,
      ),
      Node<String>(id: 'sw_util_2', label: 'Validator', type: NodeType.child),
    ],
  );

  return [frontend, backend, data, utils];
}
