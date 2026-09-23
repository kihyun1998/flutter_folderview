import 'package:flutter_example_template/flutter_example_template.dart';

/// The "Every setting" panel, described in the shell's vocabulary.
///
/// An option or switch id of the form `Class.field` names that public field of
/// `flutter_folderview`; any other id is an example-only setting.
const settingsSpec = <SettingGroup>[
  SettingGroup(
    id: 'data',
    title: 'Data & View Mode',
    features: [
      SettingFeature(
        id: 'data',
        title: 'Data',
        options: [
          'FolderView.data',
          'folderCount',
          'parentsPerFolder',
          'childrenPerParent',
        ],
      ),
      SettingFeature(
        id: 'viewMode',
        title: 'View Mode',
        options: ['FolderView.mode'],
        interactions: [
          Interaction(
            otherFeatureId: 'data',
            effect:
                'Tree Mode hides every Folder and lifts the Parents it holds '
                'to the root, descending through Folders only. A Folder id in '
                'the Expanded Set has no effect there.',
            evidence:
                'lib/services/view_mode_projection.dart: '
                'ViewModeProjection._collectParents recurses into Folders '
                'only and returns the Parents it finds as the roots',
          ),
        ],
      ),
    ],
  ),
  _interaction,
];

const _interaction = SettingGroup(
  id: 'interaction',
  title: 'Interaction',
  features: [
    SettingFeature(
      id: 'interaction',
      title: 'Taps & state',
      options: [
        'FolderView.onNodeTap',
        'FolderView.onDoubleNodeTap',
        'FolderView.onSecondaryNodeTap',
        'FolderView.expandedNodeIds',
        'FolderView.selectedNodeIds',
        'selectionMode',
      ],
      interactions: [
        Interaction(
          otherFeatureId: 'viewMode',
          effect:
              'In Tree Mode a Folder is never rendered, so a Folder id in the '
              'Expanded Set changes nothing there.',
          evidence:
              'lib/services/view_mode_projection.dart: ViewModeProjection.'
              'project returns only Parents for ViewMode.tree',
        ),
      ],
    ),
  ],
);

/// Library options, as `Class.field`, that a recipe demonstrates rather than
/// the settings panel.
const recipeCoverage = <String>{
  'Node.id',
  'Node.label',
  'Node.type',
  'Node.data',
  'Node.children',
};
