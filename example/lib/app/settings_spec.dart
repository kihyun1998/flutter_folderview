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
  _folderTier,
  SettingGroup(
    id: 'layout',
    title: 'Layout',
    features: [
      SettingFeature(
        id: 'themeInjection',
        title: 'Theme injection',
        options: ['FolderView.theme', 'FolderViewTheme.data'],
        interactions: [
          Interaction(
            otherFeatureId: 'layout',
            effect:
                'Every theme setting reaches the view the same way on either '
                'path. The theme parameter wins over a FolderViewTheme '
                'ancestor, which is read only while the parameter is null.',
            evidence:
                'lib/widgets/folder_view.dart: _FolderViewState.build resolves '
                'widget.theme ?? FolderViewTheme.of<T>(context); '
                'lib/themes/folder_view_theme.dart: FolderViewTheme.of '
                'looks up FolderViewTheme<T> by exact type and falls back to '
                'FlutterFolderViewTheme.light()',
          ),
        ],
      ),
      SettingFeature(
        id: 'layout',
        title: 'Rows & padding',
        options: [
          'FlutterFolderViewTheme.rowHeight',
          'FlutterFolderViewTheme.rowSpacing',
          'FlutterFolderViewTheme.animationDuration',
          'FlutterFolderViewTheme.spacingTheme',
          'FolderViewSpacingTheme.contentPadding',
          'FlutterFolderViewTheme.nodeStyleTheme',
          'FolderViewNodeStyleTheme.borderRadius',
        ],
        interactions: [
          Interaction(
            otherFeatureId: 'scale',
            effect:
                'The Scale multiplies rowHeight, rowSpacing, contentPadding '
                'and borderRadius. animationDuration is not scaled.',
            evidence:
                'lib/themes/flutter_folder_view_theme.dart: '
                'FlutterFolderViewTheme.scale multiplies rowHeight and '
                'rowSpacing and delegates to spacingTheme.scale and '
                'nodeStyleTheme.scale',
          ),
        ],
      ),
      SettingFeature(
        id: 'expandIcon',
        title: 'Expand icon',
        options: [
          'FlutterFolderViewTheme.expandIconTheme',
          'ExpandIconTheme.widget',
          'ExpandIconTheme.width',
          'ExpandIconTheme.height',
          'ExpandIconTheme.padding',
          'ExpandIconTheme.margin',
          'ExpandIconTheme.color',
          'ExpandIconTheme.expandedColor',
        ],
        interactions: [
          Interaction(
            otherFeatureId: 'lines',
            effect:
                'Width plus horizontal padding and margin is the width of '
                'every tree-line column and of one indent level.',
            evidence:
                'lib/services/row_metrics.dart: RowMetrics.expandStripWidth '
                'and RowMetrics.indentWidth; lib/widgets/node_widget.dart '
                'passes expandStripWidth to TreeLines as its column width',
          ),
          Interaction(
            otherFeatureId: 'scale',
            effect:
                'The Scale multiplies width, height, padding and margin, and '
                'with them the indent unit. At a Scale other than 1 the widget '
                'is fitted into the scaled box. Colours are not scaled.',
            evidence:
                'lib/themes/expand_icon_theme.dart: ExpandIconTheme.scale; '
                'lib/widgets/node_render_parts.dart: NodeIconBox wraps the '
                'icon in a FittedBox when scale != 1.0',
          ),
        ],
      ),
      SettingFeature(
        id: 'scrollbars',
        title: 'Scrollbars',
        options: [
          'FlutterFolderViewTheme.scrollbarTheme',
          'FolderViewScrollbarTheme.thumbColor',
          'FolderViewScrollbarTheme.thickness',
          'FolderViewScrollbarTheme.radius',
          'FolderViewScrollbarTheme.thumbVisibility',
          'FolderViewScrollbarTheme.trackColor',
          'FolderViewScrollbarTheme.trackWidth',
          'FolderViewScrollbarTheme.trackRadius',
          'FolderViewScrollbarTheme.trackVisibility',
          'FolderViewScrollbarTheme.hoverOpacity',
          'FolderViewScrollbarTheme.nonHoverOpacity',
          'FolderViewScrollbarTheme.hoverAnimationDuration',
        ],
        interactions: [
          Interaction(
            otherFeatureId: 'scale',
            effect:
                'Scrollbars keep their size at every Scale: thickness, '
                'radius, trackWidth and trackRadius are never multiplied.',
            evidence:
                'docs/adr/0001-scrollbars-excluded-from-scale.md; '
                'lib/themes/flutter_folder_view_theme.dart: '
                'FlutterFolderViewTheme.scale does not delegate to '
                'scrollbarTheme; test/themes/scale_test.dart: '
                '"FlutterFolderViewTheme.scale passes scrollbarTheme through '
                'identical"; CHANGELOG.md: "Scrollbar appearance (thickness, '
                'track width, colors) is NOT affected by scale"',
          ),
        ],
      ),
      SettingFeature(
        id: 'lines',
        title: 'Tree lines',
        options: [
          'FlutterFolderViewTheme.lineTheme',
          'FolderViewLineTheme.lineStyle',
          'FolderViewLineTheme.lineColor',
          'FolderViewLineTheme.lineWidth',
        ],
        interactions: [
          Interaction(
            otherFeatureId: 'scale',
            effect:
                'The Scale multiplies lineWidth, and the column a line sits '
                'in, which is the expand icon strip.',
            evidence:
                'lib/themes/folder_view_line_theme.dart: '
                'FolderViewLineTheme.scale; lib/widgets/node_widget.dart: '
                'TreeLines takes metrics.expandStripWidth as its column width',
          ),
          Interaction(
            otherFeatureId: 'viewMode',
            effect:
                'Tree Mode draws the lines of the projected tree. Its root '
                'rows, the lifted Parents, get no connector, so only Children '
                'draw one.',
            evidence:
                'lib/services/view_mode_projection.dart: '
                'ViewModeProjection.project returns the lifted Parents as the '
                'roots; lib/services/flatten_service.dart flattens them with '
                'isRoot: true; lib/widgets/tree_lines.dart: '
                'TreeLinePlan.forRow gives a root row no connector',
          ),
        ],
      ),
    ],
  ),
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

const _folderTier = SettingGroup(
  id: 'folderTier',
  title: 'Folder tier',
  features: [
    SettingFeature(
      id: 'folderIcons',
      title: 'Folder icons',
      options: [
        'FlutterFolderViewTheme.folderTheme',
        'FolderNodeTheme.widget',
        'FolderNodeTheme.openWidget',
        'FolderNodeTheme.widgetResolver',
        'FolderNodeTheme.openWidgetResolver',
        'FolderNodeTheme.width',
        'FolderNodeTheme.height',
        'FolderNodeTheme.padding',
        'FolderNodeTheme.margin',
      ],
      interactions: [
        Interaction(
          otherFeatureId: 'viewMode',
          effect:
              'Tree Mode hides every Folder, so no Folder setting shows there.',
          evidence:
              'lib/services/view_mode_projection.dart: '
              'ViewModeProjection._collectParents lifts the Parents and drops '
              'the Folders',
        ),
        Interaction(
          otherFeatureId: 'scale',
          effect:
              'The Scale multiplies width, height, padding and margin. At a '
              'Scale other than 1 the icon is fitted into the scaled box.',
          evidence:
              'lib/themes/folder_node_theme.dart: FolderNodeTheme.scale; '
              'lib/widgets/node_render_parts.dart: NodeIconBox',
        ),
      ],
    ),
    SettingFeature(
      id: 'folderLabel',
      title: 'Folder label',
      options: [
        'FolderNodeTheme.textStyle',
        'folderFontSize',
        'folderBold',
        'FolderNodeTheme.textStyleResolver',
        'FolderNodeTheme.labelResolver',
      ],
      interactions: [
        Interaction(
          otherFeatureId: 'scrollbars',
          effect:
              'The resolved label and its resolved style are what the content '
              'width is measured with, so a longer or bolder label widens the '
              'content and can bring in the horizontal scrollbar, up to three '
              'times the view width.',
          evidence:
              'lib/services/row_metrics.dart: RowMetrics.label and '
              'RowMetrics.effectiveTextStyle feed _rowWidth; '
              'lib/services/size_service.dart: SizeService.clampContentWidth',
        ),
        Interaction(
          otherFeatureId: 'scale',
          effect:
              'The Scale multiplies the font size; an unset size starts from '
              'the ambient bodyMedium.',
          evidence:
              'lib/themes/folder_node_theme.dart: FolderNodeTheme.scale; '
              'lib/themes/_scale_text_style.dart: scaleTextStyle',
        ),
      ],
    ),
    SettingFeature(
      id: 'folderInk',
      title: 'Folder ink',
      options: [
        'FolderNodeTheme.hoverColor',
        'FolderNodeTheme.splashColor',
        'FolderNodeTheme.highlightColor',
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
