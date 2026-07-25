import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fossling_magnifier/features/magnifier/types.dart';

import '../helpers/fake_magnifier_camera.dart';
import '../helpers/pump_magnifier_screen.dart';

/// Android's font-size setting goes to 2.0x, and low-vision users are the primary
/// audience — the UI must survive it on the smallest screen we support. Layout
/// overflow reports fail the test on their own; the expectations below additionally
/// pin that the controls are still reachable rather than merely not crashing.
void main() {
  const smallScreen = Size(320, 568);
  const scalers = [1.0, 1.3, 2.0];

  for (final scale in scalers) {
    testWidgets('live view survives a ${scale}x font scale', (tester) async {
      tester.view.physicalSize = smallScreen;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpMagnifierScreen(tester, FakeMagnifierCamera(),
          textScaler: TextScaler.linear(scale));

      expect(find.bySemanticsLabel('Freeze image'), findsOneWidget);
      expect(find.bySemanticsLabel('Zoom in'), findsOneWidget);
      expect(find.bySemanticsLabel('Zoom out'), findsOneWidget);
      expect(find.bySemanticsLabel('Reset zoom to 1x'), findsOneWidget);
    });

    testWidgets('permission screen survives a ${scale}x font scale', (tester) async {
      tester.view.physicalSize = smallScreen;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpMagnifierScreen(
        tester,
        FakeMagnifierCamera(initError: const CameraPermissionDeniedException()),
        textScaler: TextScaler.linear(scale),
      );

      expect(find.bySemanticsLabel('Allow camera access'), findsOneWidget);
    });
  }
}
