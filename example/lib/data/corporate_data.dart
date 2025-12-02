import 'package:flutter_folderview/flutter_folderview.dart';

List<Node<String>> getCorporateData() {
  // Engineering Department
  final backendTasks = [
    Node<String>(
      id: 'corp_eng_backend_1',
      label: 'Authentication System',
      type: NodeType.child,
    ),
    Node<String>(
      id: 'corp_eng_backend_2',
      label: 'Database Migration',
      type: NodeType.child,
    ),
  ];

  final backendProject = Node<String>(
    id: 'corp_backend_proj',
    label: 'Backend Development',
    type: NodeType.parent,
    children: backendTasks,
  );

  final frontendTasks = [
    Node<String>(
      id: 'corp_eng_frontend_1',
      label: 'Dashboard UI',
      type: NodeType.child,
    ),
    Node<String>(
      id: 'corp_eng_frontend_2',
      label: 'Mobile Design',
      type: NodeType.child,
    ),
  ];

  final frontendProject = Node<String>(
    id: 'corp_frontend_proj',
    label: 'Frontend Development',
    type: NodeType.parent,
    children: frontendTasks,
  );

  final engineeringFolder = Node<String>(
    id: 'corp_engineering',
    label: 'Engineering',
    type: NodeType.folder,
    children: [backendProject, frontendProject],
  );

  // Marketing Department
  final marketingTasks = [
    Node<String>(
      id: 'corp_marketing_1',
      label: 'Q4 Campaign',
      type: NodeType.child,
    ),
    Node<String>(
      id: 'corp_marketing_2',
      label: 'Brand Redesign',
      type: NodeType.child,
    ),
  ];

  final marketingProject = Node<String>(
    id: 'corp_marketing_proj',
    label: 'Digital Marketing',
    type: NodeType.parent,
    children: marketingTasks,
  );

  final marketingFolder = Node<String>(
    id: 'corp_marketing',
    label: 'Marketing',
    type: NodeType.folder,
    children: [marketingProject],
  );

  // HR Department
  final hrTasks = [
    Node<String>(
      id: 'corp_hr_1',
      label: 'Onboarding Process',
      type: NodeType.child,
    ),
    Node<String>(
      id: 'corp_hr_2',
      label: 'Performance Review',
      type: NodeType.child,
    ),
  ];

  final hrProject = Node<String>(
    id: 'corp_hr_proj',
    label: 'Recruitment',
    type: NodeType.parent,
    children: hrTasks,
  );

  final hrFolder = Node<String>(
    id: 'corp_hr',
    label: 'Human Resources',
    type: NodeType.folder,
    children: [hrProject],
  );

  return [engineeringFolder, marketingFolder, hrFolder];
}
