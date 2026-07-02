import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';
import 'package:flutter_test/flutter_test.dart';

// Characterization tests for the double-field interpolation in theme lerp().
// These lock the observable behavior so the three hand-rolled lerpDouble
// helpers can be replaced with dart:ui's without changing results. Expected
// values are linear-interpolation midpoints (an independent fact), not values
// recomputed from the implementation.
void main() {
  group('Theme lerp interpolates double fields', () {
    test('FolderViewLineTheme.lerp interpolates lineWidth', () {
      const a = FolderViewLineTheme(lineColor: Color(0xFF000000), lineWidth: 2);
      const b = FolderViewLineTheme(lineColor: Color(0xFF000000), lineWidth: 4);
      expect(FolderViewLineTheme.lerp(a, b, 0.5).lineWidth, 3);
      expect(FolderViewLineTheme.lerp(a, b, 0.25).lineWidth, 2.5);
    });

    test('FolderViewNodeStyleTheme.lerp interpolates borderRadius', () {
      const a = FolderViewNodeStyleTheme(borderRadius: 4);
      const b = FolderViewNodeStyleTheme(borderRadius: 8);
      expect(FolderViewNodeStyleTheme.lerp(a, b, 0.5).borderRadius, 6);
    });

    test('FolderViewScrollbarTheme.lerp interpolates double fields', () {
      const a = FolderViewScrollbarTheme(
        thumbColor: Color(0xFF000000),
        trackColor: Color(0xFF000000),
        thickness: 10,
        trackWidth: 10,
        hoverOpacity: 0.2,
      );
      const b = FolderViewScrollbarTheme(
        thumbColor: Color(0xFF000000),
        trackColor: Color(0xFF000000),
        thickness: 20,
        trackWidth: 30,
        hoverOpacity: 0.6,
      );
      final m = FolderViewScrollbarTheme.lerp(a, b, 0.5);
      expect(m.thickness, 15);
      expect(m.trackWidth, 20);
      expect(m.hoverOpacity, closeTo(0.4, 1e-9));
    });
  });
}
