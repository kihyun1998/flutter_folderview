import 'package:example/presets/demo_preset.dart';
import 'package:example/providers/theme_demo_provider.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every switchable feature on.
///
/// `Bare` is asserted against this rather than against the view model's
/// defaults, where five of the ten switches are already off.
///
/// Measured, not assumed: with the defaults as the starting state, dropping
/// `rowTooltipEnabled: false` from `bare` left the suite green. Five of the ten
/// assertions were passing because the field was already `false`, not because
/// the preset had set it. Starting from the opposite state makes every
/// assertion require the preset to have moved something.
ThemeDemoViewModel _allSwitchesOn() => ThemeDemoViewModel(
  nodes: const [],
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
);

/// Every switchable feature off. The mirror of [_allSwitchesOn], and for the
/// same reason: `Everything` must be seen to turn each switch on.
ThemeDemoViewModel _allSwitchesOff() => ThemeDemoViewModel(
  nodes: const [],
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
);

/// Every Child label in the tree, at any depth.
List<String> _childLabels(List<Node<String>> nodes) => [
  for (final node in nodes)
    if (node.type == NodeType.child)
      node.label
    else
      ..._childLabels(node.children),
];

/// Every Tier present anywhere in the tree.
Set<NodeType> _tiersIn(List<Node<String>> nodes) => {
  for (final node in nodes) ...{node.type, ..._tiersIn(node.children)},
};

void main() {
  // Applying a preset is a pure function over the view model, so it is asserted
  // here rather than by pumping the demo. The expected values come from #61,
  // not from re-reading the implementation.

  group('Bare', () {
    test('turns every switchable feature off', () {
      final bare = DemoPreset.bare.apply(_allSwitchesOn());

      expect(bare.rowTooltipEnabled, isFalse);
      expect(bare.folderTooltipEnabled, isFalse);
      expect(bare.parentTooltipEnabled, isFalse);
      expect(bare.childTooltipEnabled, isFalse);
      expect(bare.tooltipEnableTap, isFalse);
      expect(bare.tooltipEnableHover, isFalse);
      expect(bare.tooltipInteractive, isFalse);
      expect(bare.tooltipHideOnEmptyMessage, isFalse);
      expect(bare.tooltipBoxShadowEnabled, isFalse);
      expect(bare.tooltipShowArrow, isFalse);
    });

    // Characterization, not red→green: `copyWith` preserves what it is not
    // given, so this passed the moment `bare` existed. It is kept because it
    // pins the behaviour against a future `bare` written as "reset to a fresh
    // view model". Confirmed to be a real guard: adding `genMaxDepth: 2` to
    // `bare` kills this test and leaves the switch test above green.
    test('leaves the generated tree alone', () {
      // The node count is not what makes a demo bare, and a tree with nothing
      // in it can demonstrate nothing.
      final tuned = ThemeDemoViewModel(
        nodes: [
          const Node<String>(id: 'f1', label: 'Folder', type: NodeType.folder),
        ],
        genRootCount: 7,
        genMaxDepth: 4,
        genSubFolderCount: 2,
        genParentCount: 6,
        genChildCount: 9,
        useLongChildNames: true,
      );

      final bare = DemoPreset.bare.apply(tuned);

      expect(bare.genRootCount, 7);
      expect(bare.genMaxDepth, 4);
      expect(bare.genSubFolderCount, 2);
      expect(bare.genParentCount, 6);
      expect(bare.genChildCount, 9);
      expect(bare.useLongChildNames, isTrue);
      expect(bare.nodes, same(tuned.nodes));
    });
  });

  group('Row card over a long label', () {
    test('turns on both tooltips that compete for the pointer', () {
      final vm = DemoPreset.rowCardOverLongLabel.apply(_allSwitchesOff());

      // The interaction is which tooltip wins where. Both have to be on for
      // there to be a contest at all.
      expect(vm.rowTooltipEnabled, isTrue);
      expect(vm.childTooltipEnabled, isTrue);
      expect(vm.tooltipEnableHover, isTrue);
    });

    test('produces the long labels its name promises', () {
      // A preset named for an interaction must reproduce the condition. Naming
      // it and leaving the tree full of short labels demonstrates nothing.
      final vm = DemoPreset.rowCardOverLongLabel.apply(_allSwitchesOff());

      expect(vm.useLongChildNames, isTrue);
      expect(_childLabels(vm.nodes), isNotEmpty);
      expect(
        _childLabels(vm.nodes).every((label) => label.length > 60),
        isTrue,
        reason: 'every Child carries a long label, not just the random 10%',
      );
    });

    test('says what to look for', () {
      expect(DemoPreset.rowCardOverLongLabel.whatToLookFor, isNotEmpty);
    });
  });

  group('Tree Mode over a deep hierarchy', () {
    test('switches the projection and deepens the tree', () {
      final vm = DemoPreset.treeModeOverDeepHierarchy.apply(_allSwitchesOff());

      expect(vm.viewMode, ViewMode.tree);
      expect(vm.genMaxDepth, greaterThan(2), reason: 'deeper than the default');
    });

    test('generates the Folders the projection will hide', () {
      // The interaction is that Tree Mode hides Folders and lifts Parents to
      // the root. A tree with no Folder in it cannot demonstrate that.
      final vm = DemoPreset.treeModeOverDeepHierarchy.apply(_allSwitchesOff());

      expect(vm.nodes.every((n) => n.type == NodeType.folder), isTrue);
      expect(_tiersIn(vm.nodes), contains(NodeType.parent));
    });

    test('says what to look for', () {
      expect(DemoPreset.treeModeOverDeepHierarchy.whatToLookFor, isNotEmpty);
    });
  });

  group('Everything', () {
    test('turns every switchable feature on', () {
      final all = DemoPreset.everything.apply(_allSwitchesOff());

      expect(all.rowTooltipEnabled, isTrue);
      expect(all.folderTooltipEnabled, isTrue);
      expect(all.parentTooltipEnabled, isTrue);
      expect(all.childTooltipEnabled, isTrue);
      expect(all.tooltipEnableTap, isTrue);
      expect(all.tooltipEnableHover, isTrue);
      expect(all.tooltipInteractive, isTrue);
      expect(all.tooltipHideOnEmptyMessage, isTrue);
      expect(all.tooltipBoxShadowEnabled, isTrue);
      expect(all.tooltipShowArrow, isTrue);
    });
  });
}
