// Cold-cost measurement for RowMetrics.maxWidth — the width precompute that
// runs on every data / scale / theme change and lays out a TextPainter per
// node across the WHOLE tree (including collapsed nodes).
//
// This is NOT part of the default test run (it lives under benchmark/, not
// test/). Run it explicitly:
//
//   flutter test benchmark/max_width_benchmark.dart
//
// Unlike the pure-path microbenchmarks, this needs a widget binding (TextPainter
// lays out real text) and is measured with a Stopwatch rather than
// benchmark_harness: maxWidth's cost is a COLD, one-shot layout of N labels.
// RowMetrics keeps a static (label, style) width cache, so a steady-state loop
// would only measure warm cache hits. Each trial therefore uses globally-unique
// labels (salted) so the cache can never hit — reproducing a data change where
// every label is new, the case that defeats the cache.
//
// Numbers are machine-dependent and are NOT a CI gate; they exist to confirm
// where the real per-data-change cost sits (see issue #35) and to baseline the
// maxWidth optimisation (#37).
//
// Recorded baseline (Windows dev machine, median of 5 trials; expect wide
// run-to-run variance from GC/TextPainter):
//   n=1000  (1012 nodes): COLD ~45-57 ms  | WARM (cache hit) ~1.3 ms
//   n=10000 (10028 nodes): COLD ~330-405 ms | WARM (cache hit) ~26 ms
// For contrast, the pure flatten path over the same node counts is ~22 us
// (1k) / ~275 us (10k) — so cold maxWidth is ~1000x+ the flatten cost and is
// the dominant per-data-change expense. Even the warm path stays O(nodes)
// because it builds a cache-key string per node.

import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_folderview/services/row_metrics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // A Folder > Parent > Child forest of ~[targetNodes] nodes. Every label is
  // unique and salted per trial, so the RowMetrics width cache never hits.
  List<Node<String>> buildForest(int targetNodes, int salt) {
    const parentsPerFolder = 5;
    const childrenPerParent = 8;
    const perRoot = 1 + parentsPerFolder * (1 + childrenPerParent); // 46
    final rootCount = (targetNodes / perRoot).ceil();
    var counter = 0;
    String uniqueLabel() =>
        'Department $salt / Category ${counter++} — Report Document.pdf';

    final roots = <Node<String>>[];
    for (var r = 0; r < rootCount; r++) {
      final parents = <Node<String>>[];
      for (var p = 0; p < parentsPerFolder; p++) {
        final children = <Node<String>>[
          for (var c = 0; c < childrenPerParent; c++)
            Node<String>(
                id: 's${salt}_r${r}_p${p}_c$c',
                label: uniqueLabel(),
                type: NodeType.child),
        ];
        parents.add(Node<String>(
            id: 's${salt}_r${r}_p$p',
            label: uniqueLabel(),
            type: NodeType.parent,
            children: children));
      }
      roots.add(Node<String>(
          id: 's${salt}_r$r',
          label: uniqueLabel(),
          type: NodeType.folder,
          children: parents));
    }
    return roots;
  }

  int nodeCount(List<Node<String>> roots) {
    var total = 0;
    void visit(List<Node<String>> ns) {
      for (final n in ns) {
        total++;
        visit(n.children);
      }
    }

    visit(roots);
    return total;
  }

  test('measure cold RowMetrics.maxWidth on unique-label data', () {
    final theme = FlutterFolderViewTheme<String>.light();
    RowMetrics<String> metrics() => RowMetrics<String>(
        theme: theme, baseTextStyle: const TextStyle(fontSize: 14));

    // Warm the text-layout engine once (first-ever layout pays a one-time init
    // cost we do not want to attribute to maxWidth).
    metrics().maxWidth(buildForest(50, -1));

    for (final n in [1000, 10000]) {
      const trials = 5;
      final micros = <int>[];
      var nodes = 0;
      List<Node<String>> lastRoots = const [];
      for (var t = 0; t < trials; t++) {
        final roots = buildForest(n, t); // fresh, unique labels -> cold cache
        nodes = nodeCount(roots);
        lastRoots = roots;
        final m = metrics();
        final sw = Stopwatch()..start();
        final width = m.maxWidth(roots);
        sw.stop();
        micros.add(sw.elapsedMicroseconds);
        // Guard against the call being optimised away.
        if (width <= 0) throw StateError('maxWidth returned $width');
      }
      micros.sort();
      final median = micros[micros.length ~/ 2];

      // Warm: re-measure the last trial's tree. Its labels are now cached, so
      // this is the cost when a data change reuses labels the cache has seen.
      final warmSw = Stopwatch()..start();
      metrics().maxWidth(lastRoots);
      warmSw.stop();

      // ignore: avoid_print
      print('maxWidth n=$n (nodes=$nodes): '
          'COLD median=${median}us (min=${micros.first} max=${micros.last}, '
          '$trials trials, unique labels) | '
          'WARM (cache hit)=${warmSw.elapsedMicroseconds}us');
    }
  }, timeout: const Timeout(Duration(minutes: 2)));
}
