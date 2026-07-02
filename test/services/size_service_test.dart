import 'package:flutter_folderview/services/size_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SizeService.clampContentWidth', () {
    // Spec: the content-width ceiling is 3× the viewport. Content is already
    // measured in the same (scaled) pixel space as the viewport, so the
    // ceiling must NOT be re-multiplied by any scale factor.
    test('caps content width at 3x the viewport', () {
      expect(
        SizeService.clampContentWidth(contentWidth: 1000, viewportWidth: 100),
        300,
      );
    });

    test('passes content through unchanged when under the ceiling', () {
      expect(
        SizeService.clampContentWidth(contentWidth: 50, viewportWidth: 100),
        50,
      );
    });
  });
}
