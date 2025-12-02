import 'package:flutter_folderview/flutter_folderview.dart';

List<Node<String>> getCorporateData() {
  // Engineering Department - Backend Team
  final authTeamMembers = [
    Node<String>(
      id: 'corp_eng_auth_member_1',
      label: 'Kihyun Kim - Senior Authentication Systems Engineer (Team Lead)',
      type: NodeType.child,
    ),
    Node<String>(
      id: 'corp_eng_auth_member_2',
      label: 'Sarah Johnson - OAuth 2.0 Security Specialist and Implementation Engineer',
      type: NodeType.child,
    ),
    Node<String>(
      id: 'corp_eng_auth_member_3',
      label: 'Michael Chen - JWT Token Architecture Developer',
      type: NodeType.child,
    ),
  ];

  final authTeam = Node<String>(
    id: 'corp_eng_backend_auth_team',
    label: 'Authentication System Implementation Team - OAuth 2.0 & JWT',
    type: NodeType.parent,
    children: authTeamMembers,
  );

  final dbTeamMembers = [
    Node<String>(
      id: 'corp_eng_db_member_1',
      label: 'Emily Rodriguez - Database Architecture and Performance Optimization Lead',
      type: NodeType.child,
    ),
    Node<String>(
      id: 'corp_eng_db_member_2',
      label: 'David Park - Migration Strategy and Schema Design Specialist',
      type: NodeType.child,
    ),
  ];

  final dbTeam = Node<String>(
    id: 'corp_eng_backend_db_team',
    label: 'Database Migration and Schema Refactoring Team',
    type: NodeType.parent,
    children: dbTeamMembers,
  );

  final backendProject = Node<String>(
    id: 'corp_backend_proj',
    label: 'Backend API Development and Microservices Architecture',
    type: NodeType.parent,
    children: [authTeam, dbTeam],
  );

  // Engineering Department - Frontend Team
  final dashboardTeamMembers = [
    Node<String>(
      id: 'corp_eng_dash_member_1',
      label: 'Jessica Williams - Senior UI/UX Developer and Design Systems Lead',
      type: NodeType.child,
    ),
    Node<String>(
      id: 'corp_eng_dash_member_2',
      label: 'Robert Taylor - Real-time Analytics and Data Visualization Engineer',
      type: NodeType.child,
    ),
    Node<String>(
      id: 'corp_eng_dash_member_3',
      label: 'Lisa Anderson - Frontend Performance Optimization Specialist',
      type: NodeType.child,
    ),
  ];

  final dashboardTeam = Node<String>(
    id: 'corp_eng_frontend_dashboard_team',
    label: 'Responsive Dashboard with Real-time Analytics Implementation Team',
    type: NodeType.parent,
    children: dashboardTeamMembers,
  );

  final mobileTeamMembers = [
    Node<String>(
      id: 'corp_eng_mobile_member_1',
      label: 'Christopher Lee - Mobile-First Design and Responsive Layout Expert',
      type: NodeType.child,
    ),
    Node<String>(
      id: 'corp_eng_mobile_member_2',
      label: 'Amanda Martinez - Cross-Platform Flutter Development Specialist',
      type: NodeType.child,
    ),
  ];

  final mobileTeam = Node<String>(
    id: 'corp_eng_frontend_mobile_team',
    label: 'Mobile-First Design and Cross-Platform Development Team',
    type: NodeType.parent,
    children: mobileTeamMembers,
  );

  final frontendProject = Node<String>(
    id: 'corp_frontend_proj',
    label: 'Frontend User Interface Modernization and Component Library Development',
    type: NodeType.parent,
    children: [dashboardTeam, mobileTeam],
  );

  final engineeringFolder = Node<String>(
    id: 'corp_engineering',
    label: 'Engineering Department - Software Development Division',
    type: NodeType.folder,
    children: [backendProject, frontendProject],
  );

  // Marketing Department
  final campaignTeamMembers = [
    Node<String>(
      id: 'corp_marketing_campaign_member_1',
      label: 'Jennifer Thompson - Social Media Strategy and Content Marketing Director',
      type: NodeType.child,
    ),
    Node<String>(
      id: 'corp_marketing_campaign_member_2',
      label: 'Daniel White - Digital Campaign Analytics and ROI Optimization Manager',
      type: NodeType.child,
    ),
  ];

  final campaignTeam = Node<String>(
    id: 'corp_marketing_campaign_team',
    label: 'Q4 Social Media Campaign Strategy and Customer Engagement Initiative',
    type: NodeType.parent,
    children: campaignTeamMembers,
  );

  final brandTeamMembers = [
    Node<String>(
      id: 'corp_marketing_brand_member_1',
      label: 'Sophia Garcia - Creative Director and Brand Identity Design Specialist',
      type: NodeType.child,
    ),
  ];

  final brandTeam = Node<String>(
    id: 'corp_marketing_brand_team',
    label: 'Brand Identity Redesign and Visual Communications Project',
    type: NodeType.parent,
    children: brandTeamMembers,
  );

  final marketingProject = Node<String>(
    id: 'corp_marketing_proj',
    label: 'Digital Marketing and Brand Development Strategic Initiatives',
    type: NodeType.parent,
    children: [campaignTeam, brandTeam],
  );

  final marketingFolder = Node<String>(
    id: 'corp_marketing',
    label: 'Marketing & Communications Department - Strategic Planning Division',
    type: NodeType.folder,
    children: [marketingProject],
  );

  // HR Department
  final recruitmentTeamMembers = [
    Node<String>(
      id: 'corp_hr_recruit_member_1',
      label: 'Matthew Brown - Talent Acquisition Manager and Recruitment Pipeline Coordinator',
      type: NodeType.child,
    ),
    Node<String>(
      id: 'corp_hr_recruit_member_2',
      label: 'Olivia Davis - Employee Onboarding and Training Program Development Specialist',
      type: NodeType.child,
    ),
  ];

  final recruitmentTeam = Node<String>(
    id: 'corp_hr_recruitment_team',
    label: 'Talent Acquisition, Onboarding Process, and Employee Integration Program',
    type: NodeType.parent,
    children: recruitmentTeamMembers,
  );

  final performanceTeamMembers = [
    Node<String>(
      id: 'corp_hr_perf_member_1',
      label: 'William Wilson - Performance Review System Administrator and HR Analytics Lead',
      type: NodeType.child,
    ),
  ];

  final performanceTeam = Node<String>(
    id: 'corp_hr_performance_team',
    label: 'Annual Performance Review and Employee Development Assessment Program',
    type: NodeType.parent,
    children: performanceTeamMembers,
  );

  final hrProject = Node<String>(
    id: 'corp_hr_proj',
    label: 'Human Resources Management and Employee Relations Strategic Division',
    type: NodeType.parent,
    children: [recruitmentTeam, performanceTeam],
  );

  final hrFolder = Node<String>(
    id: 'corp_hr',
    label: 'Human Resources - People Operations, Culture, and Organizational Development',
    type: NodeType.folder,
    children: [hrProject],
  );

  return [engineeringFolder, marketingFolder, hrFolder];
}
