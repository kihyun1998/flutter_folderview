import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const defaultFontSize = 14.0;

  group('FlutterFolderViewTheme factories', () {
    test('.light() and .dark() build valid, distinct themes', () {
      final light = FlutterFolderViewTheme<String>.light();
      final dark = FlutterFolderViewTheme<String>.dark();
      // Identity short-circuit still holds (sanity that they are well-formed).
      expect(
        identical(
          light.scale(factor: 1.0, defaultFontSize: defaultFontSize),
          light,
        ),
        isTrue,
      );
      // The two presets differ somewhere visible (line colour).
      expect(light.lineTheme.lineColor == dark.lineTheme.lineColor, isFalse);
    });
  });

  group('FolderViewTheme (InheritedWidget)', () {
    testWidgets('of() returns the ancestor theme, or the default when absent', (
      tester,
    ) async {
      final custom = FlutterFolderViewTheme<String>.light().copyWith(
        rowHeight: 77,
      );
      late FlutterFolderViewTheme<String> found;
      late FlutterFolderViewTheme<String> fallback;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [
              FolderViewTheme<String>(
                data: custom,
                child: Builder(
                  builder: (ctx) {
                    found = FolderViewTheme.of<String>(ctx);
                    return const SizedBox();
                  },
                ),
              ),
              Builder(
                builder: (ctx) {
                  fallback = FolderViewTheme.of<String>(ctx);
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      );

      expect(found.rowHeight, 77);
      expect(fallback.rowHeight, 40); // default light rowHeight
    });

    testWidgets('maybeOf() reads without registering a dependency', (
      tester,
    ) async {
      final custom = FlutterFolderViewTheme<String>.light().copyWith(
        rowHeight: 55,
      );
      late FlutterFolderViewTheme<String> found;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FolderViewTheme<String>(
            data: custom,
            child: Builder(
              builder: (ctx) {
                found = FolderViewTheme.maybeOf<String>(ctx);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(found.rowHeight, 55);
    });

    test('updateShouldNotify is true only when data changes', () {
      final t1 = FlutterFolderViewTheme<String>.light().copyWith(rowHeight: 10);
      final t2 = FlutterFolderViewTheme<String>.light().copyWith(rowHeight: 20);
      final a = FolderViewTheme<String>(data: t1, child: const SizedBox());
      final same = FolderViewTheme<String>(data: t1, child: const SizedBox());
      final changed = FolderViewTheme<String>(
        data: t2,
        child: const SizedBox(),
      );
      expect(a.updateShouldNotify(same), isFalse); // identical data instance
      expect(a.updateShouldNotify(changed), isTrue);
    });
  });

  group('FolderViewTheme type mismatch (#124)', () {
    setUp(FolderViewTheme.debugResetTypeMismatchWarnings);

    List<Node<String>> data() => [
      Node<String>(id: 'f', label: 'folder', type: NodeType.folder),
    ];

    /// Pumps [tree] [times] times and returns what `debugPrint` received.
    Future<List<String>> printed(
      WidgetTester tester,
      Widget Function(int pass) tree, {
      int times = 1,
    }) async {
      final logs = <String>[];
      final original = debugPrint;
      debugPrint = (message, {wrapWidth}) => logs.add(message ?? '');
      try {
        for (var i = 0; i < times; i++) {
          await tester.pumpWidget(MaterialApp(home: Scaffold(body: tree(i))));
        }
      } finally {
        debugPrint = original;
      }
      return logs;
    }

    Color labelColor(WidgetTester tester) =>
        tester.widget<Text>(find.text('folder')).style!.color!;

    testWidgets('an untyped ancestor is reported once, naming both types', (
      tester,
    ) async {
      final logs = await printed(
        tester,
        (_) => FolderViewTheme(
          data: FlutterFolderViewTheme.dark(),
          child: FolderView<String>(data: data(), mode: ViewMode.folder),
        ),
      );

      expect(logs, hasLength(1));
      expect(logs.single, contains('FolderViewTheme<dynamic>'));
      expect(logs.single, contains('FolderViewTheme<String>'));
      // The lookup is unchanged: the view still falls back to light().
      expect(
        labelColor(tester),
        FlutterFolderViewTheme<String>.light().folderTheme.textStyle!.color,
      );
    });

    testWidgets('rebuilding the mismatched tree reports nothing more', (
      tester,
    ) async {
      final logs = await printed(
        tester,
        (pass) => FolderViewTheme(
          data: FlutterFolderViewTheme.dark().copyWith(rowHeight: 30.0 + pass),
          child: FolderView<String>(data: data(), mode: ViewMode.folder),
        ),
        times: 3,
      );

      expect(logs, hasLength(1));
    });

    testWidgets('a matching ancestor reports nothing and is used', (
      tester,
    ) async {
      final logs = await printed(
        tester,
        (_) => FolderViewTheme<String>(
          data: FlutterFolderViewTheme<String>.dark(),
          child: FolderView<String>(data: data(), mode: ViewMode.folder),
        ),
      );

      expect(logs, isEmpty);
      expect(
        labelColor(tester),
        FlutterFolderViewTheme<String>.dark().folderTheme.textStyle!.color,
      );
    });

    testWidgets('no ancestor at all reports nothing', (tester) async {
      final logs = await printed(
        tester,
        (_) => FolderView<String>(data: data(), mode: ViewMode.folder),
      );

      expect(logs, isEmpty);
    });

    testWidgets('maybeOf reports a mismatch too', (tester) async {
      final logs = await printed(
        tester,
        (_) => FolderViewTheme(
          data: FlutterFolderViewTheme.dark(),
          child: Builder(
            builder: (ctx) {
              FolderViewTheme.maybeOf<String>(ctx);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(logs, hasLength(1));
    });
  });
}
