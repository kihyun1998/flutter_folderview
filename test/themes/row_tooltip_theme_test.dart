import 'package:flutter/widgets.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RowTooltipTheme defaults', () {
    test('a card is interactive, immediate, and draws no surface', () {
      const t = RowTooltipTheme();
      expect(t.interactive, isTrue);
      expect(t.waitDuration, isNull);
      expect(t.surface.padding, EdgeInsets.zero);
      expect(t.surface.elevation, 0.0);
    });
  });

  group('RowTooltipTheme.copyWith', () {
    test('replaces one field and preserves the rest', () {
      const base = RowTooltipTheme(offset: 8, interactive: true);
      final copy = base.copyWith(offset: 20);
      expect(copy.offset, 20);
      expect(copy.interactive, isTrue);
    });

    test('no-arg copyWith preserves values', () {
      const base = RowTooltipTheme(
        interactive: false,
        waitDuration: Duration(milliseconds: 300),
        offset: 12,
      );
      final copy = base.copyWith();
      expect(copy.interactive, isFalse);
      expect(copy.waitDuration, const Duration(milliseconds: 300));
      expect(copy.offset, 12);
    });
  });

  group('RowTooltipTheme.lerp', () {
    test('interpolates continuous fields at the midpoint', () {
      const a = RowTooltipTheme(offset: 10, screenMargin: 0);
      const b = RowTooltipTheme(offset: 20, screenMargin: 4);
      final m = RowTooltipTheme.lerp(a, b, 0.5);
      expect(m.offset, 15);
      expect(m.screenMargin, 2);
    });

    test('snaps non-interpolable fields at t = 0.5', () {
      const a =
          RowTooltipTheme(interactive: false, direction: TooltipDirection.top);
      const b = RowTooltipTheme(
          interactive: true, direction: TooltipDirection.bottom);
      expect(RowTooltipTheme.lerp(a, b, 0.49).interactive, isFalse);
      expect(RowTooltipTheme.lerp(a, b, 0.5).interactive, isTrue);
      expect(RowTooltipTheme.lerp(a, b, 0.49).direction, TooltipDirection.top);
      expect(
          RowTooltipTheme.lerp(a, b, 0.5).direction, TooltipDirection.bottom);
    });

    test('handles null a / null b / both null', () {
      const t = RowTooltipTheme(offset: 9);
      expect(RowTooltipTheme.lerp(null, t, 0.5).offset, 9);
      expect(RowTooltipTheme.lerp(t, null, 0.5).offset, 9);
      expect(RowTooltipTheme.lerp(null, null, 0.5).interactive, isTrue);
    });
  });
}
