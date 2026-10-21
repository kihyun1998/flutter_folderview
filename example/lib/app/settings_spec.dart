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
  _parentTier,
  _childTier,
  _nodeTooltips,
  _rowCard,
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
                'and borderRadius.',
            evidence:
                'lib/themes/flutter_folder_view_theme.dart: '
                'FlutterFolderViewTheme.scale multiplies rowHeight and '
                'rowSpacing and delegates to spacingTheme.scale and '
                'nodeStyleTheme.scale',
          ),
          Interaction(
            otherFeatureId: 'lines',
            effect:
                'rowSpacing adds to every row\'s height; the row\'s content '
                'and its tree lines stay centred in it.',
            evidence:
                'lib/widgets/tree_lines.dart: TreeLinesPainter draws the '
                'connector stub and a last child\'s end at half the size it '
                'paints, and the row is laid out at rowHeight + rowSpacing; '
                'test/widgets/tree_lines_row_spacing_test.dart',
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
              'The Scale multiplies the textStyle font size; an unset size '
              'starts from the ambient bodyMedium. A style returned by '
              'textStyleResolver is scaled by the same rule.',
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

const _parentTier = SettingGroup(
  id: 'parentTier',
  title: 'Parent tier',
  features: [
    SettingFeature(
      id: 'parentIcons',
      title: 'Parent icons',
      options: [
        'FlutterFolderViewTheme.parentTheme',
        'ParentNodeTheme.widget',
        'ParentNodeTheme.openWidget',
        'ParentNodeTheme.widgetResolver',
        'ParentNodeTheme.openWidgetResolver',
        'ParentNodeTheme.width',
        'ParentNodeTheme.height',
        'ParentNodeTheme.padding',
        'ParentNodeTheme.margin',
      ],
      interactions: [
        Interaction(
          otherFeatureId: 'viewMode',
          effect:
              'An expanded Parent shows openWidget only in Tree Mode; in Folder '
              'Mode it keeps its widget.',
          evidence:
              'lib/widgets/node_widget.dart: NodeWidget._content passes '
              'useOpenState: mode == ViewMode.tree for a Parent; '
              'lib/widgets/expandable_node_renderer.dart: the open icon is '
              'used only when useOpenState && isExpanded',
        ),
        Interaction(
          otherFeatureId: 'scale',
          effect:
              'The Scale multiplies width, height, padding and margin. At a '
              'Scale other than 1 the icon is fitted into the scaled box.',
          evidence:
              'lib/themes/parent_node_theme.dart: ParentNodeTheme.scale; '
              'lib/widgets/node_render_parts.dart: NodeIconBox',
        ),
      ],
    ),
    SettingFeature(
      id: 'parentLabel',
      title: 'Parent label',
      options: [
        'ParentNodeTheme.textStyle',
        'parentFontSize',
        'parentBold',
        'ParentNodeTheme.textStyleResolver',
        'ParentNodeTheme.labelResolver',
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
              'The Scale multiplies the textStyle font size; an unset size '
              'starts from the ambient bodyMedium. A style returned by '
              'textStyleResolver is scaled by the same rule.',
          evidence:
              'lib/themes/parent_node_theme.dart: ParentNodeTheme.scale; '
              'lib/themes/_scale_text_style.dart: scaleTextStyle',
        ),
      ],
    ),
    SettingFeature(
      id: 'parentInk',
      title: 'Parent ink',
      options: [
        'ParentNodeTheme.hoverColor',
        'ParentNodeTheme.splashColor',
        'ParentNodeTheme.highlightColor',
      ],
    ),
  ],
);

const _childTier = SettingGroup(
  id: 'childTier',
  title: 'Child tier',
  features: [
    SettingFeature(
      id: 'childIcons',
      title: 'Child icons',
      options: [
        'FlutterFolderViewTheme.childTheme',
        'ChildNodeTheme.widget',
        'ChildNodeTheme.widgetResolver',
        'ChildNodeTheme.width',
        'ChildNodeTheme.height',
        'ChildNodeTheme.padding',
        'ChildNodeTheme.margin',
      ],
      interactions: [
        Interaction(
          otherFeatureId: 'scale',
          effect:
              'The Scale multiplies width, height, padding and margin. At a '
              'Scale other than 1 the icon is fitted into the scaled box.',
          evidence:
              'lib/themes/child_node_theme.dart: ChildNodeTheme.scale; '
              'lib/widgets/node_render_parts.dart: NodeIconBox',
        ),
      ],
    ),
    SettingFeature(
      id: 'childLabel',
      title: 'Child label',
      options: [
        'ChildNodeTheme.textStyle',
        'childFontSize',
        'childBold',
        'ChildNodeTheme.textStyleResolver',
        'ChildNodeTheme.labelResolver',
      ],
      interactions: [
        Interaction(
          otherFeatureId: 'scale',
          effect:
              'The Scale multiplies the textStyle font size; an unset size '
              'starts from the ambient bodyMedium. A style returned by '
              'textStyleResolver is scaled by the same rule.',
          evidence:
              'lib/themes/child_node_theme.dart: ChildNodeTheme.scale; '
              'lib/themes/_scale_text_style.dart: scaleTextStyle',
        ),
      ],
    ),
    SettingFeature(
      id: 'childSelection',
      title: 'Child selection',
      options: [
        'ChildNodeTheme.selectedTextStyle',
        'childSelectedBold',
        'ChildNodeTheme.selectedTextStyleResolver',
        'ChildNodeTheme.selectedBackgroundColor',
      ],
      interactions: [
        Interaction(
          otherFeatureId: 'interaction',
          effect:
              'The selection styling shows on the Children in the Selected '
              'Set, which only the caller changes; tapping a Child selects it '
              'through the example handler. Folders and Parents never show it.',
          evidence:
              'docs/adr/0003-selection-is-tier-bound-to-child.md; '
              'lib/widgets/child_node_renderer.dart: ChildNodeRenderer.build '
              'merges selectedTextStyleResolver ?? selectedTextStyle over the '
              'label style when the Node is in selectedNodeIds',
        ),
        Interaction(
          otherFeatureId: 'scale',
          effect:
              'The Scale multiplies selectedTextStyle\'s sizes, and those of a '
              'style returned by selectedTextStyleResolver.',
          evidence:
              'lib/themes/child_node_theme.dart: ChildNodeTheme.scale scales '
              'selectedTextStyle and wraps selectedTextStyleResolver',
        ),
      ],
    ),
    SettingFeature(
      id: 'childInk',
      title: 'Child ink',
      options: [
        'ChildNodeTheme.hoverColor',
        'ChildNodeTheme.splashColor',
        'ChildNodeTheme.highlightColor',
        'ChildNodeTheme.clickInterval',
      ],
      interactions: [
        Interaction(
          otherFeatureId: 'interaction',
          effect:
              'clickInterval is the double-tap window, and only with an '
              'onDoubleNodeTap handler: without one every tap is a single '
              'tap.',
          evidence:
              'lib/widgets/custom_ink_well.dart: CustomInkWell; CHANGELOG.md '
              '0.11.3: "without onDoubleNodeTap, every tap on a Child row '
              'fires onNodeTap" (#95)',
        ),
      ],
    ),
  ],
);

const _nodeTooltips = SettingGroup(
  id: 'nodeTooltips',
  title: 'Node tooltips',
  features: [
    SettingFeature(
      id: 'tooltipPlacement',
      title: 'Tooltip placement',
      options: [
        'tooltipTier',
        'FolderNodeTheme.tooltipTheme',
        'ParentNodeTheme.tooltipTheme',
        'ChildNodeTheme.tooltipTheme',
        'NodeTooltipTheme.useTooltip',
        'NodeTooltipTheme.direction',
        'NodeTooltipTheme.alignment',
        'NodeTooltipTheme.anchor',
        'NodeTooltipTheme.offset',
        'NodeTooltipTheme.crossAxisOffset',
        'NodeTooltipTheme.screenMargin',
        'NodeTooltipTheme.showArrow',
        'NodeTooltipTheme.arrowBaseWidth',
        'NodeTooltipTheme.arrowLength',
        'NodeTooltipTheme.arrowPositionRatio',
      ],
      interactions: [
        Interaction(
          otherFeatureId: 'scale',
          effect:
              'Tooltips keep their size at every Scale: no placement, arrow '
              'or margin setting is multiplied.',
          evidence:
              'docs/adr/0004-tooltips-excluded-from-scale.md; '
              'lib/themes/node_tooltip_theme.dart: NodeTooltipTheme has no '
              'scale method, and FolderNodeTheme.scale, ParentNodeTheme.scale '
              'and ChildNodeTheme.scale pass tooltipTheme through',
        ),
      ],
    ),
    SettingFeature(
      id: 'tooltipSurface',
      title: 'Tooltip content & surface',
      options: [
        'tooltipSurfaceTier',
        'NodeTooltipTheme.message',
        'NodeTooltipTheme.textStyle',
        'NodeTooltipTheme.tooltipBuilder',
        'NodeTooltipTheme.tooltipBuilderResolver',
        'NodeTooltipTheme.backgroundColor',
        'NodeTooltipTheme.elevation',
        'NodeTooltipTheme.boxShadow',
        'NodeTooltipTheme.borderRadius',
        'NodeTooltipTheme.padding',
        'NodeTooltipTheme.borderColor',
        'NodeTooltipTheme.borderWidth',
      ],
      interactions: [
        Interaction(
          otherFeatureId: 'tooltipPlacement',
          effect:
              'Nothing here is drawn until useTooltip is on for the Tier; '
              'with no builder and an empty or unset message the label gets '
              'no tooltip at all.',
          evidence:
              'lib/widgets/node_render_parts.dart: wrapWithNodeTooltip returns '
              'the child unwrapped when useTooltip is off, or when no builder '
              'resolves and message is null or empty',
        ),
        Interaction(
          otherFeatureId: 'tooltipPlacement',
          effect:
              'With showArrow on, the background, border and shadow are '
              'painted as one shape with the arrow instead of a Material '
              'box, and textStyle becomes the default style of '
              'tooltipBuilder content too.',
          evidence:
              'just_tooltip 0.4.4 just_tooltip_overlay.dart: build picks '
              '_buildArrowBox over _buildMaterialBox when theme.showArrow, '
              'and _buildArrowBox wraps the content in DefaultTextStyle; '
              'tooltip_shape_painter.dart paints boxShadow, elevation and '
              'border',
        ),
        Interaction(
          otherFeatureId: 'scale',
          effect:
              'The surface keeps its size at every Scale: padding, radius, '
              'border and text are not multiplied.',
          evidence:
              'docs/adr/0004-tooltips-excluded-from-scale.md; '
              'lib/themes/node_tooltip_theme.dart: NodeTooltipTheme has no '
              'scale method',
        ),
      ],
    ),
    SettingFeature(
      id: 'tooltipBehaviour',
      title: 'Tooltip behaviour & animation',
      options: [
        'tooltipBehaviourTier',
        'NodeTooltipTheme.enableTap',
        'NodeTooltipTheme.enableHover',
        'NodeTooltipTheme.interactive',
        'NodeTooltipTheme.waitDuration',
        'NodeTooltipTheme.showDuration',
        'NodeTooltipTheme.onShow',
        'NodeTooltipTheme.onHide',
        'NodeTooltipTheme.controllerResolver',
        'NodeTooltipTheme.animation',
        'NodeTooltipTheme.animationCurve',
        'NodeTooltipTheme.animationDuration',
        'NodeTooltipTheme.fadeBegin',
        'NodeTooltipTheme.scaleBegin',
        'NodeTooltipTheme.slideOffset',
        'NodeTooltipTheme.rotationBegin',
      ],
      interactions: [
        Interaction(
          otherFeatureId: 'tooltipPlacement',
          effect:
              'Nothing here acts until useTooltip is on for the Tier and the '
              'Tier has content; a slide animation starts further out in the '
              'Direction, the flipped one where the tooltip flipped, and '
              'slides in toward the label.',
          evidence:
              'lib/widgets/node_render_parts.dart: wrapWithNodeTooltip returns '
              'the child unwrapped when useTooltip is off or there is no '
              'content; just_tooltip 0.4.4 tooltip_transitions.dart: '
              '_slideOffset picks its begin offset from spec.direction, which '
              'just_tooltip.dart passes as _resolvedDirection ?? direction',
        ),
        Interaction(
          otherFeatureId: 'tooltipSurface',
          effect:
              'With no builder and an empty or unset message there is no '
              'tooltip, so no timing, animation or callback here has anything '
              'to act on.',
          evidence:
              'lib/widgets/node_render_parts.dart: wrapWithNodeTooltip returns '
              'the child unwrapped when no builder resolves and message is '
              'null or empty',
        ),
        Interaction(
          otherFeatureId: 'interaction',
          effect:
              'onShow and onHide write to the same event log as the tap '
              'callbacks.',
          evidence:
              'lib/widgets/node_render_parts.dart: wrapWithNodeTooltip passes '
              'onShow and onHide to JustTooltip unchanged; just_tooltip 0.4.4 '
              'just_tooltip.dart: _show calls onShow, _onAnimationStatus '
              'calls onHide once the reverse animation is dismissed',
        ),
        Interaction(
          otherFeatureId: 'interaction',
          effect:
              'With enableTap on, a tap on the label opens the tooltip and '
              'never reaches onNodeTap, so a Child is not selected from its '
              'label; a tap elsewhere on the row still is.',
          evidence:
              'just_tooltip 0.4.4 just_tooltip.dart: build wraps the child in '
              'a GestureDetector with onTap when enableTap; as the innermost '
              'tap recognizer it wins the gesture arena over the row; lib/widgets/node_render_parts.dart: '
              'wrapWithNodeTooltip wraps only the label',
        ),
      ],
    ),
  ],
);

const _rowCard = SettingGroup(
  id: 'rowCard',
  title: 'Row card',
  features: [
    SettingFeature(
      id: 'rowCardPlacement',
      title: 'Row card placement & surface',
      options: [
        'FolderView.rowTooltipBuilder',
        'FolderView.rowTooltipTheme',
        'RowTooltipTheme.direction',
        'RowTooltipTheme.alignment',
        'RowTooltipTheme.offset',
        'RowTooltipTheme.crossAxisOffset',
        'RowTooltipTheme.screenMargin',
        'RowTooltipTheme.surface',
      ],
      interactions: [
        Interaction(
          otherFeatureId: 'scale',
          effect:
              'The row card keeps its size at every Scale: no placement or '
              'surface setting is multiplied.',
          evidence:
              'docs/adr/0004-tooltips-excluded-from-scale.md; '
              'lib/themes/row_tooltip_theme.dart: RowTooltipTheme has no '
              'scale method',
        ),
        Interaction(
          otherFeatureId: 'tooltipPlacement',
          effect:
              'Where the Node\'s label tooltip has content, the label tooltip '
              'shows and the row card is hidden while the pointer is on the '
              'label; elsewhere on the row the card shows.',
          evidence:
              'lib/widgets/folder_view_content.dart: _wrapWithRowTooltip wraps '
              'the NodeWidget, so the label tooltip nests inside the card; '
              'just_tooltip 0.4.4 just_tooltip.dart: _syncSuppression claims '
              'every ancestor while the pointer is inside a tooltip that '
              '_hasContent',
        ),
      ],
    ),
    SettingFeature(
      id: 'rowCardBehaviour',
      title: 'Row card behaviour & animation',
      options: [
        'RowTooltipTheme.interactive',
        'RowTooltipTheme.waitDuration',
        'RowTooltipTheme.showDuration',
        'RowTooltipTheme.enableHover',
        'RowTooltipTheme.onShow',
        'RowTooltipTheme.onHide',
        'RowTooltipTheme.animation',
        'RowTooltipTheme.animationCurve',
        'RowTooltipTheme.animationDuration',
        'RowTooltipTheme.fadeBegin',
        'RowTooltipTheme.scaleBegin',
        'RowTooltipTheme.slideOffset',
        'RowTooltipTheme.rotationBegin',
      ],
      interactions: [
        Interaction(
          otherFeatureId: 'rowCardPlacement',
          effect:
              'Nothing here acts until rowTooltipBuilder builds a card for '
              'the row.',
          evidence:
              'lib/widgets/folder_view_content.dart: _wrapWithRowTooltip '
              'returns the row unwrapped when rowTooltipBuilder is null or '
              'returns null',
        ),
        Interaction(
          otherFeatureId: 'interaction',
          effect:
              'onShow and onHide write to the same event log as the tap '
              'callbacks; the card never takes a row tap.',
          evidence:
              'lib/widgets/folder_view_content.dart: _wrapWithRowTooltip '
              'passes onShow and onHide and no enableTap, so JustTooltip '
              'keeps its enableTap default of false and adds no '
              'GestureDetector',
        ),
        Interaction(
          otherFeatureId: 'tooltipBehaviour',
          effect:
              'A label tooltip with enableHover off never sees the pointer, '
              'so it does not hide the card on the label.',
          evidence:
              'just_tooltip 0.4.4 just_tooltip.dart: build adds the '
              'MouseRegion that sets _pointerInside only when enableHover, '
              'and _syncSuppression claims ancestors only with '
              '_pointerInside',
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
