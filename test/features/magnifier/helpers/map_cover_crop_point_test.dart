import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:floss_magnifier/features/magnifier/helpers/map_cover_crop_point.dart';

void main() {
  group('mapCoverCropPoint', () {
    test('identical aspect ratios is identity', () {
      final result = mapCoverCropPoint(
        point: const Offset(0.25, 0.75),
        container: const Size(100, 100),
        content: const Size(200, 200),
      );

      expect(result.dx, closeTo(0.25, 1e-9));
      expect(result.dy, closeTo(0.75, 1e-9));
    });

    test('4:3 content into a portrait-style 9:20 container crops horizontally', () {
      // container 90x200, content 400x300.
      // cover scale = max(90/400, 200/300) = max(0.225, 0.6667) = 0.6667 -> height drives the fit.
      // visible fraction y = 200 / (300 * 0.6667) = 1 (fills vertically, no crop).
      // visible fraction x = 90 / (400 * 0.6667) = 90 / 266.667 = 0.3375 (cropped horizontally).
      // mapped x = 0.5 + (0.25 - 0.5) * 0.3375 = 0.5 - 0.084375 = 0.415625
      // mapped y = 0.75 (unchanged, visible fraction is 1)
      final result = mapCoverCropPoint(
        point: const Offset(0.25, 0.75),
        container: const Size(90, 200),
        content: const Size(400, 300),
      );

      expect(result.dx, closeTo(0.415625, 1e-6));
      expect(result.dy, closeTo(0.75, 1e-9));
    });

    test('symmetric landscape case crops vertically', () {
      // container 200x90, content 400x300.
      // cover scale = max(200/400, 90/300) = max(0.5, 0.3) = 0.5 -> width drives the fit.
      // visible fraction x = 200 / (400 * 0.5) = 1 (fills horizontally, no crop).
      // visible fraction y = 90 / (300 * 0.5) = 90 / 150 = 0.6 (cropped vertically).
      // mapped x = 0.25 (unchanged, visible fraction is 1)
      // mapped y = 0.5 + (0.75 - 0.5) * 0.6 = 0.5 + 0.15 = 0.65
      final result = mapCoverCropPoint(
        point: const Offset(0.25, 0.75),
        container: const Size(200, 90),
        content: const Size(400, 300),
      );

      expect(result.dx, closeTo(0.25, 1e-9));
      expect(result.dy, closeTo(0.65, 1e-6));
    });

    test('corners clamp to 0..1', () {
      final topLeft = mapCoverCropPoint(
        point: const Offset(0, 0),
        container: const Size(90, 200),
        content: const Size(400, 300),
      );
      final bottomRight = mapCoverCropPoint(
        point: const Offset(1, 1),
        container: const Size(90, 200),
        content: const Size(400, 300),
      );

      expect(topLeft.dx, greaterThanOrEqualTo(0.0));
      expect(topLeft.dx, lessThanOrEqualTo(1.0));
      expect(topLeft.dy, greaterThanOrEqualTo(0.0));
      expect(topLeft.dy, lessThanOrEqualTo(1.0));
      expect(bottomRight.dx, greaterThanOrEqualTo(0.0));
      expect(bottomRight.dx, lessThanOrEqualTo(1.0));
      expect(bottomRight.dy, greaterThanOrEqualTo(0.0));
      expect(bottomRight.dy, lessThanOrEqualTo(1.0));
    });

    test('center point always maps to center', () {
      final result = mapCoverCropPoint(
        point: const Offset(0.5, 0.5),
        container: const Size(90, 200),
        content: const Size(400, 300),
      );

      expect(result.dx, closeTo(0.5, 1e-9));
      expect(result.dy, closeTo(0.5, 1e-9));
    });
  });
}
