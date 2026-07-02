import 'package:flutter/widgets.dart';
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
        identical(light.scale(factor: 1.0, defaultFontSize: defaultFontSize),
            light),
        isTrue,
      );
      // The two presets differ somewhere visible (line colour).
      expect(light.lineTheme.lineColor == dark.lineTheme.lineColor, isFalse);
    });
  });

  group('FolderViewTheme (InheritedWidget)', () {
    testWidgets('of() returns the ancestor theme, or the default when absent',
        (tester) async {
      final custom =
          FlutterFolderViewTheme<String>.light().copyWith(rowHeight: 77);
      late FlutterFolderViewTheme<String> found;
      late FlutterFolderViewTheme<String> fallback;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [
              FolderViewTheme<String>(
                data: custom,
                child: Builder(builder: (ctx) {
                  found = FolderViewTheme.of<String>(ctx);
                  return const SizedBox();
                }),
              ),
              Builder(builder: (ctx) {
                fallback = FolderViewTheme.of<String>(ctx);
                return const SizedBox();
              }),
            ],
          ),
        ),
      );

      expect(found.rowHeight, 77);
      expect(fallback.rowHeight, 40); // default light rowHeight
    });

    testWidgets('maybeOf() reads without registering a dependency',
        (tester) async {
      final custom =
          FlutterFolderViewTheme<String>.light().copyWith(rowHeight: 55);
      late FlutterFolderViewTheme<String> found;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FolderViewTheme<String>(
            data: custom,
            child: Builder(builder: (ctx) {
              found = FolderViewTheme.maybeOf<String>(ctx);
              return const SizedBox();
            }),
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
      final changed = FolderViewTheme<String>(data: t2, child: const SizedBox());
      expect(a.updateShouldNotify(same), isFalse); // identical data instance
      expect(a.updateShouldNotify(changed), isTrue);
    });
  });
}
