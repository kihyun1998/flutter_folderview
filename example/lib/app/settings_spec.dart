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
    ),
    SettingFeature(
      id: 'wheel',
      title: 'Smooth wheel',
      options: [
        'FolderView.wheelMotion',
        'wheelDurationMs',
        'wheelBounce',
        'wheelCurve',
        'wheelTimeConstantMs',
      ],
    ),
    SettingFeature(
      id: 'scale',
      title: 'Scale',
      options: [
        'FolderView.scale',
        'FolderView.onScaleChanged',
        'FolderView.scaleStep',
        'FolderView.blockModifierScroll',
      ],
      interactions: [
        Interaction(
          otherFeatureId: 'wheel',
          effect:
              'Ctrl+wheel (Cmd+wheel on macOS) proposes a Scale and, while '
              'blockModifierScroll is in effect, neither scrolls nor starts a '
              'wheel motion. With blockModifierScroll false, the same notch '
              'scrolls and proposes no Scale.',
          evidence:
              'test/widgets/folder_view_scale_gesture_test.dart: "while '
              'blocking, modifier+wheel leaves the scroll offset put" settles '
              'after each notch since 0.12.0, and "blockModifierScroll:false '
              'overrides a non-null onScaleChanged"',
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
