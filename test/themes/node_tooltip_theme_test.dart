import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NodeTooltipTheme.anchor', () {
    test('defaults to the child rect', () {
      const theme = NodeTooltipTheme<String>();
      expect(theme.anchor, TooltipAnchor.child);
    });
  });

  group('NodeTooltipTheme.copyWith', () {
    test('replaces one field and preserves the rest', () {
      const base = NodeTooltipTheme<String>(useTooltip: true, offset: 8);
      final copy = base.copyWith(offset: 20);
      expect(copy.offset, 20);
      expect(copy.useTooltip, isTrue); // preserved
    });

    test('replaces anchor and preserves it across a no-arg copy', () {
      const base = NodeTooltipTheme<String>();
      final copy = base.copyWith(anchor: TooltipAnchor.pointer);
      expect(copy.anchor, TooltipAnchor.pointer);
      expect(copy.copyWith().anchor, TooltipAnchor.pointer);
    });

    test('no-arg copyWith preserves values', () {
      const base = NodeTooltipTheme<String>(
        useTooltip: true,
        message: 'hi',
        offset: 12,
      );
      final copy = base.copyWith();
      expect(copy.useTooltip, isTrue);
      expect(copy.message, 'hi');
      expect(copy.offset, 12);
    });
  });

  group('NodeTooltipTheme.lerp', () {
    test('interpolates continuous fields at the midpoint', () {
      const a = NodeTooltipTheme<String>(offset: 10, crossAxisOffset: 0);
      const b = NodeTooltipTheme<String>(offset: 20, crossAxisOffset: 4);
      final m = NodeTooltipTheme.lerp(a, b, 0.5);
      expect(m.offset, 15);
      expect(m.crossAxisOffset, 2);
    });

    test('picks a-vs-b for non-interpolable fields by t', () {
      const a = NodeTooltipTheme<String>(message: 'A', useTooltip: false);
      const b = NodeTooltipTheme<String>(message: 'B', useTooltip: true);
      expect(NodeTooltipTheme.lerp(a, b, 0.25).message, 'A');
      expect(NodeTooltipTheme.lerp(a, b, 0.75).message, 'B');
      expect(NodeTooltipTheme.lerp(a, b, 0.75).useTooltip, isTrue);
    });

    test('snaps anchor at the midpoint rather than interpolating', () {
      const a = NodeTooltipTheme<String>(anchor: TooltipAnchor.child);
      const b = NodeTooltipTheme<String>(anchor: TooltipAnchor.pointer);
      expect(NodeTooltipTheme.lerp(a, b, 0.49).anchor, TooltipAnchor.child);
      expect(NodeTooltipTheme.lerp(a, b, 0.5).anchor, TooltipAnchor.pointer);
    });

    test('handles null a / null b / both null', () {
      const t = NodeTooltipTheme<String>(offset: 9);
      expect(NodeTooltipTheme.lerp<String>(null, t, 0.5).offset, 9);
      expect(NodeTooltipTheme.lerp<String>(t, null, 0.5).offset, 9);
      expect(
          NodeTooltipTheme.lerp<String>(null, null, 0.5).useTooltip, isFalse);
    });
  });
}
