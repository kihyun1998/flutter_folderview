/// Named combinations of the demo's settings, applied in one click.
library;

import 'package:flutter_folderview/flutter_folderview.dart';

import '../providers/theme_demo_provider.dart';

/// Every Node that can be expanded, at any depth.
///
/// An interaction preset expands the tree it generates: a preset about Child
/// labels that leaves every Parent collapsed puts no Child on screen, and
/// demonstrates nothing. Expansion is the caller's to hold (ADR-0002), so the
/// preset hands back the set rather than asking the view to open anything.
Set<String> _expandableIds(List<Node<String>> nodes) => {
  for (final node in nodes) ...{
    if (node.canExpand) node.id,
    ..._expandableIds(node.children),
  },
};

/// A named set of settings, applied to the demo in one click.
///
/// Applying a preset is a pure function of the view model, so what a preset
/// does is asserted without pumping a widget.
///
/// A preset is named for the interaction it demonstrates, not for the features
/// it enables. `Row card` would say nothing a switch does not; `Row card over a
/// long label` answers which tooltip wins where the pointer is.
class DemoPreset {
  const DemoPreset({
    required this.title,
    required this.whatToLookFor,
    required this.apply,
  });

  final String title;

  /// One line telling the reader where to point the mouse once this preset is
  /// applied. A preset that demonstrates an interaction is useless if nobody
  /// knows where the interaction happens.
  final String whatToLookFor;

  /// Returns the view model this preset describes, given the current one.
  final ThemeDemoViewModel Function(ThemeDemoViewModel) apply;

  /// Every preset the bar offers, in the order it offers them.
  ///
  /// `Bare` first: it is what the demo opens on, and the zero the others are
  /// read against.
  static final List<DemoPreset> all = [
    bare,
    everything,
    rowCardOverLongLabel,
    treeModeOverDeepHierarchy,
  ];

  /// Every switchable feature off.
  ///
  /// The switches are turned off mechanically rather than selectively: with no
  /// tooltip rendering at all, the six that merely modify a tooltip are
  /// unreachable, and a symmetric `Bare`/`Everything` pair is easier to reason
  /// about than a clever one. The generated tree is left alone — the node count
  /// is not what makes a demo bare.
  static final DemoPreset bare = DemoPreset(
    title: 'Bare',
    whatToLookFor: 'Nothing but the tree. Add one feature at a time from here.',
    apply: (vm) => vm.copyWith(
      rowTooltipEnabled: false,
      folderTooltipEnabled: false,
      parentTooltipEnabled: false,
      childTooltipEnabled: false,
      tooltipEnableTap: false,
      tooltipEnableHover: false,
      tooltipInteractive: false,
      tooltipHideOnEmptyMessage: false,
      tooltipBoxShadowEnabled: false,
      tooltipShowArrow: false,
    ),
  );

  /// Every switchable feature on. The mirror of [bare]: the whole surface at
  /// once, for when that is what you want to see.
  static final DemoPreset everything = DemoPreset(
    title: 'Everything',
    whatToLookFor: 'The whole surface at once. Every switch is on.',
    apply: (vm) => vm.copyWith(
      rowTooltipEnabled: true,
      folderTooltipEnabled: true,
      parentTooltipEnabled: true,
      childTooltipEnabled: true,
      tooltipEnableTap: true,
      tooltipEnableHover: true,
      tooltipInteractive: true,
      tooltipHideOnEmptyMessage: true,
      tooltipBoxShadowEnabled: true,
      tooltipShowArrow: true,
    ),
  );

  /// The row card and the Child label tooltip, both live, over labels long
  /// enough that the label claims most of the row.
  ///
  /// The tree is regenerated: a preset named for long labels that leaves the
  /// tree full of short ones demonstrates nothing.
  static final DemoPreset rowCardOverLongLabel = DemoPreset(
    title: 'Row card over a long label',
    whatToLookFor:
        'Hover the label text, then the empty space beside it. The innermost '
        'tooltip under the pointer wins, so the label keeps its own and the '
        'rest of the row raises the card.',
    apply: (vm) {
      final next = vm.copyWith(
        rowTooltipEnabled: true,
        childTooltipEnabled: true,
        tooltipEnableHover: true,
        useLongChildNames: true,
      );
      final nodes = generateDataset(
        rootCount: next.genRootCount,
        maxDepth: next.genMaxDepth,
        subFolderCount: next.genSubFolderCount,
        parentCount: next.genParentCount,
        childCount: next.genChildCount,
        useLongFolderNames: next.useLongFolderNames,
        useLongParentNames: next.useLongParentNames,
        useLongChildNames: next.useLongChildNames,
      );
      return next.copyWith(
        nodes: nodes,
        selectedIds: {},
        expandedIds: _expandableIds(nodes),
      );
    },
  );

  /// The same hierarchy under both projections' difference: Folders exist in
  /// the data and vanish from the render.
  static final DemoPreset treeModeOverDeepHierarchy = DemoPreset(
    title: 'Tree Mode over a deep hierarchy',
    whatToLookFor:
        'Switch View Mode back to Folder. The Folders reappear at the root, '
        'and the Parents drop a level — Tree Mode lifts Parents to the root '
        'and hides the Folders that contained them.',
    apply: (vm) {
      final next = vm.copyWith(viewMode: ViewMode.tree, genMaxDepth: 3);
      final nodes = generateDataset(
        rootCount: next.genRootCount,
        maxDepth: next.genMaxDepth,
        subFolderCount: next.genSubFolderCount,
        parentCount: next.genParentCount,
        childCount: next.genChildCount,
        useLongFolderNames: next.useLongFolderNames,
        useLongParentNames: next.useLongParentNames,
        useLongChildNames: next.useLongChildNames,
      );
      return next.copyWith(
        nodes: nodes,
        selectedIds: {},
        expandedIds: _expandableIds(nodes),
      );
    },
  );
}
