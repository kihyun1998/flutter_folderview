// Heap-footprint measurement for the flattened list — the O(nodes) structure
// FlattenService.flatten produces for virtualized rendering.
//
// This is NOT part of the default test run (it lives under benchmark/, not
// test/). Run it explicitly:
//
//   flutter test benchmark/flat_list_memory_benchmark.dart
//
// Dart exposes no allocation counter, so this uses a coarse but repeatable
// RSS-delta-with-retention method: build many flat lists, KEEP references so
// nothing is collected, and read ProcessInfo.currentRss before/after. The
// delta divided by the retained node count approximates bytes-per-FlatNode.
// Numbers are approximate and machine-dependent; this is NOT a CI gate.
//
// It also quantifies what #33 (int ancestorIsLastMask instead of a per-node
// List<bool>) saved: after measuring the current lean list (A), it retains, for
// the same nodes, a List<bool> of length == depth per node (B) — the old
// ancestorIsLastFlags representation. B - A is the per-node heap #33 removed.
//
// Recorded baseline (Windows dev machine, ~1M retained nodes per phase, stable
// across runs; RSS is coarse so treat as approximate):
//   n=1000  (1012 nodes/list): FlatNode ~80 B/node | removed List<bool> ~44 B/node
//   n=10000 (10028 nodes/list): FlatNode ~58 B/node | removed List<bool> ~53 B/node
// The per-node List<bool> #33 eliminated (~44-53 B/node) is comparable to the
// whole FlatNode object, so #33 roughly HALVED the flat-list heap footprint at
// typical depths — the memory counterpart of its ~3x time win.

import 'dart:io' show ProcessInfo;

import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_folderview/models/flat_node.dart';
import 'package:flutter_folderview/services/flatten_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A Folder > Parent > Child forest of ~[targetNodes] nodes, all expanded.
  ({List<Node<String>> roots, Set<String> expanded}) buildForest(
      int targetNodes) {
    const parentsPerFolder = 5;
    const childrenPerParent = 8;
    const perRoot = 1 + parentsPerFolder * (1 + childrenPerParent); // 46
    final rootCount = (targetNodes / perRoot).ceil();
    final expanded = <String>{};
    final roots = <Node<String>>[];
    for (var r = 0; r < rootCount; r++) {
      final fId = 'f$r';
      expanded.add(fId);
      final parents = <Node<String>>[];
      for (var p = 0; p < parentsPerFolder; p++) {
        final pId = '${fId}_p$p';
        expanded.add(pId);
        parents.add(Node<String>(
          id: pId,
          label: pId,
          type: NodeType.parent,
          children: [
            for (var c = 0; c < childrenPerParent; c++)
              Node<String>(
                  id: '${pId}_c$c', label: '${pId}_c$c', type: NodeType.child),
          ],
        ));
      }
      roots.add(Node<String>(
          id: fId, label: fId, type: NodeType.folder, children: parents));
    }
    return (roots: roots, expanded: expanded);
  }

  test('measure flattened-list heap footprint (and the #33 saving)', () {
    for (final n in [1000, 10000]) {
      final forest = buildForest(n);
      List<FlatNode<String>> flatten() => FlattenService.flatten<String>(
          nodes: forest.roots, expandedNodeIds: forest.expanded);

      // Retain a warmup set so the VM's heap arenas are already grown before we
      // baseline — otherwise collectable warmup garbage inflates rss0 and later
      // GC makes the delta unreliable (even negative).
      final warmup = <List<FlatNode<String>>>[flatten()];
      final nodesPerList = warmup.first.length;
      for (var i = 1; i < (200000 / nodesPerList).ceil(); i++) {
        warmup.add(flatten());
      }

      // Each measured phase allocates ~1M nodes (~tens of MB) so RSS growth
      // clearly exceeds the VM's arena granularity.
      final phaseCopies = (1000000 / nodesPerList).ceil();
      final phaseNodes = phaseCopies * nodesPerList;

      // (A) Current lean flat lists (FlatNode carries an int mask).
      final rss0 = ProcessInfo.currentRss;
      final listsA = <List<FlatNode<String>>>[];
      for (var i = 0; i < phaseCopies; i++) {
        listsA.add(flatten());
      }
      final rssA = ProcessInfo.currentRss;
      final bytesPerNodeA = (rssA - rss0) / phaseNodes;

      // (B) Simulate the pre-#33 representation: a List<bool> of length == depth
      // per node, retained alongside.
      List<List<bool>> flagsFor(List<FlatNode<String>> list) =>
          [for (final fn in list) List<bool>.filled(fn.depth, false)];
      final listsB = <List<List<bool>>>[];
      for (var i = 0; i < phaseCopies; i++) {
        listsB.add(flagsFor(listsA[i]));
      }
      final rssB = ProcessInfo.currentRss;
      final bytesPerNodeListBool = (rssB - rssA) / phaseNodes;

      // Keep everything retained until after the final measurement.
      if (warmup.isEmpty ||
          listsA.length != phaseCopies ||
          listsB.length != phaseCopies) {
        throw StateError('retention failed');
      }

      // ignore: avoid_print
      print('flat-list heap n=$n (nodesPerList=$nodesPerList, '
          'measured phase=$phaseNodes nodes): '
          'FlatNode ~${bytesPerNodeA.toStringAsFixed(1)} B/node | '
          'simulated per-node List<bool> (removed by #33) '
          '~${bytesPerNodeListBool.toStringAsFixed(1)} B/node');
    }
  }, timeout: const Timeout(Duration(minutes: 2)));
}
