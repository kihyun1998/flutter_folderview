import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A Folder with [count] parents; expand it so all parents are rows. A large
  // count makes the content taller than the viewport, so vertical scrolling is
  // observable.
  List<Node<String>> data({int count = 1}) => [
        Node<String>(
          id: 'f',
          label: 'folder',
          type: NodeType.folder,
          children: List.generate(
            count,
            (i) => Node<String>(id: 'p$i', label: 'p$i', type: NodeType.parent),
          ),
        ),
      ];

  Future<void> pumpFV(
    WidgetTester tester, {
    required List<Node<String>> nodes,
    ValueChanged<double>? onScaleChanged,
    double scale = 1.0,
    double scaleStep = 0.05,
    bool? blockModifierScroll,
    Size size = const Size(400, 160),
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: FolderView<String>(
              data: nodes,
              mode: ViewMode.folder,
              expandedNodeIds: const {'f'},
              onScaleChanged: onScaleChanged,
              scale: scale,
              scaleStep: scaleStep,
              blockModifierScroll: blockModifierScroll,
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  // Dispatches a mouse-wheel pointer signal over [at]. A positive [dy] is a
  // wheel-down (scroll content down); negative is a wheel-up.
  Future<void> sendWheel(WidgetTester tester, Offset at, double dy) async {
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(pointer.hover(at));
    await tester.sendEventToBinding(pointer.scroll(Offset(0, dy)));
    await tester.pump();
  }

  // The vertical ListView's own scroll offset. find.byType(ListView) matches
  // only the vertical list (the horizontal sync uses a SingleChildScrollView).
  double vOffset(WidgetTester tester) =>
      tester.widget<ListView>(find.byType(ListView)).controller!.offset;

  testWidgets('modifier+wheel fires onScaleChanged by ±scaleStep',
      (tester) async {
    // Windows -> the scale modifier is Ctrl (see isScaleModifierPressed).
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      final scales = <double>[];
      // Non-default step so the expected delta is an independent literal.
      await pumpFV(tester, nodes: data(), onScaleChanged: scales.add,
          scale: 1.0, scaleStep: 0.25);

      final center = tester.getCenter(find.byType(FolderView<String>));
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      try {
        await sendWheel(tester, center, -50); // wheel up -> zoom in
        await sendWheel(tester, center, 50); // wheel down -> zoom out
      } finally {
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      }

      expect(scales, [1.25, 0.75]);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('while blocking, modifier+wheel leaves the scroll offset put',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      // onScaleChanged non-null -> blocking derives to true.
      await pumpFV(tester, nodes: data(count: 30), onScaleChanged: (_) {});
      final center = tester.getCenter(find.byType(FolderView<String>));

      expect(vOffset(tester), 0);

      // Modifier held: the wheel is claimed for scaling, not scrolling.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      try {
        await sendWheel(tester, center, 300);
        expect(vOffset(tester), 0); // blocked
      } finally {
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      }

      // Same wheel without the modifier scrolls normally -> proves the block
      // above was the modifier's doing, not an inert wheel.
      await sendWheel(tester, center, 300);
      expect(vOffset(tester), greaterThan(0));
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('with onScaleChanged null, modifier+wheel scrolls (no intercept)',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      // No onScaleChanged -> blocking derives to false -> no interception.
      await pumpFV(tester, nodes: data(count: 30));
      final center = tester.getCenter(find.byType(FolderView<String>));

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      try {
        await sendWheel(tester, center, 300); // must not throw
        expect(vOffset(tester), greaterThan(0)); // scrolled normally
      } finally {
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      }
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('blockModifierScroll:false overrides a non-null onScaleChanged',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      final scales = <double>[];
      // Callback present would normally enable blocking; false forces it off.
      await pumpFV(tester, nodes: data(count: 30), onScaleChanged: scales.add,
          blockModifierScroll: false);
      final center = tester.getCenter(find.byType(FolderView<String>));

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      try {
        await sendWheel(tester, center, 300);
        expect(vOffset(tester), greaterThan(0)); // scrolls despite callback
      } finally {
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      }
      expect(scales, isEmpty); // not intercepted -> callback never fired
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('blockModifierScroll:true overrides a null onScaleChanged',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      // No callback would normally leave blocking off; true forces it on.
      await pumpFV(tester, nodes: data(count: 30), blockModifierScroll: true);
      final center = tester.getCenter(find.byType(FolderView<String>));

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      try {
        await sendWheel(tester, center, 300); // must not throw
        expect(vOffset(tester), 0); // blocked despite null callback
      } finally {
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      }
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
