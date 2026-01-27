import 'package:flutter_folderview/flutter_folderview.dart';

List<Node<String>> getGovernmentData() {
  // Ministry of Interior
  final policeTasks = [
    const Node<String>(
      id: 'gov_police_1',
      label: 'Public Safety Initiative',
      type: NodeType.child,
    ),
    const Node<String>(
      id: 'gov_police_2',
      label: 'Traffic Management',
      type: NodeType.child,
    ),
  ];

  final policeProject = Node<String>(
    id: 'gov_police',
    label: 'National Police Agency',
    type: NodeType.parent,
    children: policeTasks,
  );

  final fireTasks = [
    const Node<String>(
      id: 'gov_fire_1',
      label: 'Emergency Response',
      type: NodeType.child,
    ),
  ];

  final fireProject = Node<String>(
    id: 'gov_fire',
    label: 'Fire Department',
    type: NodeType.parent,
    children: fireTasks,
  );

  final interiorFolder = Node<String>(
    id: 'gov_interior',
    label: 'Ministry of Interior',
    type: NodeType.folder,
    children: [policeProject, fireProject],
  );

  // Ministry of Education
  final educationTasks = [
    const Node<String>(
      id: 'gov_edu_1',
      label: 'Curriculum Reform',
      type: NodeType.child,
    ),
    const Node<String>(
      id: 'gov_edu_2',
      label: 'Digital Learning',
      type: NodeType.child,
    ),
  ];

  final educationProject = Node<String>(
    id: 'gov_edu_proj',
    label: 'Education Policy Bureau',
    type: NodeType.parent,
    children: educationTasks,
  );

  final educationFolder = Node<String>(
    id: 'gov_education',
    label: 'Ministry of Education',
    type: NodeType.folder,
    children: [educationProject],
  );

  // Ministry of Health
  final healthTasks = [
    const Node<String>(
      id: 'gov_health_1',
      label: 'Vaccination Program',
      type: NodeType.child,
    ),
    const Node<String>(
      id: 'gov_health_2',
      label: 'Healthcare Reform',
      type: NodeType.child,
    ),
  ];

  final healthProject = Node<String>(
    id: 'gov_health_proj',
    label: 'Disease Control Center',
    type: NodeType.parent,
    children: healthTasks,
  );

  final healthFolder = Node<String>(
    id: 'gov_health',
    label: 'Ministry of Health',
    type: NodeType.folder,
    children: [healthProject],
  );

  return [interiorFolder, educationFolder, healthFolder];
}
