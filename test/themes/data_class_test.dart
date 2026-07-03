import 'package:flutter/widgets.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FolderNodeTheme copyWith/lerp', () {
    test('copyWith replaces one field, preserves the rest', () {
      const t = FolderNodeTheme<String>(width: 10, height: 5);
      final c = t.copyWith(width: 20);
      expect(c.width, 20);
      expect(c.height, 5);
      expect(t.copyWith().width, 10);
    });
    test('lerp interpolates and handles nulls', () {
      const a = FolderNodeTheme<String>(width: 10);
      const b = FolderNodeTheme<String>(width: 20);
      expect(FolderNodeTheme.lerp(a, b, 0.5).width, 15);
      expect(FolderNodeTheme.lerp<String>(null, b, 0.5).width, 20);
      expect(FolderNodeTheme.lerp<String>(a, null, 0.5).width, 10);
      expect(FolderNodeTheme.lerp<String>(null, null, 0.5).width, 20.0);
    });
  });

  group('ParentNodeTheme copyWith/lerp', () {
    test('copyWith + lerp', () {
      const t = ParentNodeTheme<String>(width: 10, height: 5);
      expect(t.copyWith(width: 20).width, 20);
      expect(t.copyWith().height, 5);
      const a = ParentNodeTheme<String>(width: 10);
      const b = ParentNodeTheme<String>(width: 20);
      expect(ParentNodeTheme.lerp(a, b, 0.5).width, 15);
      expect(ParentNodeTheme.lerp<String>(null, null, 0.5).width, 20.0);
    });
  });

  group('ChildNodeTheme copyWith/lerp', () {
    test('copyWith replaces child-only fields', () {
      const t = ChildNodeTheme<String>(width: 10, clickInterval: 300);
      final c = t.copyWith(clickInterval: 500, width: 20);
      expect(c.clickInterval, 500);
      expect(c.width, 20);
      expect(t.copyWith().clickInterval, 300);
    });
    test('lerp interpolates width and clickInterval', () {
      const a = ChildNodeTheme<String>(width: 10, clickInterval: 200);
      const b = ChildNodeTheme<String>(width: 20, clickInterval: 400);
      final m = ChildNodeTheme.lerp(a, b, 0.5);
      expect(m.width, 15);
      expect(m.clickInterval, 300);
      expect(ChildNodeTheme.lerp<String>(null, null, 0.5).clickInterval, 300);
    });
  });

  group('ExpandIconTheme copyWith/lerp/==', () {
    test('copyWith + lerp', () {
      const t = ExpandIconTheme(width: 10, height: 6);
      expect(t.copyWith(width: 20).width, 20);
      expect(t.copyWith().height, 6);
      const a = ExpandIconTheme(width: 10);
      const b = ExpandIconTheme(width: 20);
      expect(ExpandIconTheme.lerp(a, b, 0.5).width, 15);
      expect(ExpandIconTheme.lerp(null, null, 0.5).width, 20.0);
    });
    test('== / hashCode', () {
      // Non-const so the instances differ by identity — forces == to evaluate
      // the field comparisons rather than short-circuiting on identical().
      final a =
          ExpandIconTheme(width: 10, height: 6, color: const Color(0xFF000001));
      final b =
          ExpandIconTheme(width: 10, height: 6, color: const Color(0xFF000001));
      final differHeight = ExpandIconTheme(width: 10, height: 9);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == differHeight, isFalse); // differs on a field after width
    });
  });

  group('FolderViewSpacingTheme copyWith/lerp/==', () {
    test('copyWith + lerp + ==', () {
      const t = FolderViewSpacingTheme(contentPadding: EdgeInsets.all(4));
      expect(t.copyWith(contentPadding: const EdgeInsets.all(8)).contentPadding,
          const EdgeInsets.all(8));
      expect(t.copyWith().contentPadding, const EdgeInsets.all(4));
      const a = FolderViewSpacingTheme(contentPadding: EdgeInsets.all(10));
      const b = FolderViewSpacingTheme(contentPadding: EdgeInsets.all(20));
      expect(FolderViewSpacingTheme.lerp(a, b, 0.5).contentPadding,
          const EdgeInsets.all(15));
      expect(FolderViewSpacingTheme.lerp(null, null, 0.5).contentPadding,
          EdgeInsets.zero);
      final a2 =
          FolderViewSpacingTheme(contentPadding: const EdgeInsets.all(10));
      final a3 =
          FolderViewSpacingTheme(contentPadding: const EdgeInsets.all(10));
      expect(a2, a3); // non-const: exercises == field comparison
      expect(a2.hashCode, a3.hashCode);
      expect(a2 == b, isFalse);
    });
  });

  group('FolderViewScrollbarTheme copyWith/==', () {
    const base = FolderViewScrollbarTheme(
      thumbColor: Color(0xFF000000),
      trackColor: Color(0xFFEEEEEE),
      thickness: 12,
    );
    test('copyWith replaces one field, preserves rest', () {
      final c = base.copyWith(thickness: 20);
      expect(c.thickness, 20);
      expect(c.trackColor, const Color(0xFFEEEEEE));
    });
    test('== / hashCode', () {
      expect(base, base.copyWith());
      expect(base.hashCode, base.copyWith().hashCode);
      expect(base == base.copyWith(thickness: 99), isFalse);
    });
  });

  group('FlutterFolderViewTheme copyWith/lerp/==', () {
    test('copyWith replaces a top-level scalar', () {
      final t = FlutterFolderViewTheme<String>.light();
      expect(t.copyWith(rowHeight: 99).rowHeight, 99);
    });
    test('lerp picks rowHeight by t threshold (not interpolated)', () {
      final a = FlutterFolderViewTheme<String>.light().copyWith(rowHeight: 10);
      final b = FlutterFolderViewTheme<String>.light().copyWith(rowHeight: 20);
      // rowHeight/rowSpacing/animationDuration are t<0.5 ? a : b, not lerped.
      expect(FlutterFolderViewTheme.lerp(a, b, 0.25).rowHeight, 10);
      expect(FlutterFolderViewTheme.lerp(a, b, 0.75).rowHeight, 20);
    });
    test('== is value-based for a no-op copyWith and unequal on change', () {
      final t = FlutterFolderViewTheme<String>.light();
      expect(t.copyWith(), t); // same nested instances + same scalars
      expect(t.copyWith(rowHeight: 99) == t, isFalse);
    });
  });
}
