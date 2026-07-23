import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fossling_magnifier/features/magnifier/components/camera_view.dart';
import 'package:fossling_magnifier/features/magnifier/magnifier_state.dart';

import '../../../helpers/fake_magnifier_camera.dart';
import '../../../helpers/pump_localized.dart';

void main() {
  testWidgets('renders the camera preview', (tester) async {
    final camera = FakeMagnifierCamera();
    final state = MagnifierState(minZoom: 1.0, maxZoom: 8.0);
    await pumpLocalized(
        tester, CameraView(camera: camera, state: state, onFocus: (_) async {}));
    expect(find.byKey(const Key('fake-preview')), findsOneWidget);
  });

  testWidgets('tap reports normalized focus point and shows the ring', (tester) async {
    final camera = FakeMagnifierCamera();
    final state = MagnifierState(minZoom: 1.0, maxZoom: 8.0);
    Offset? focused;
    await pumpLocalized(
        tester,
        SizedBox(
          width: 200,
          height: 400,
          child: CameraView(camera: camera, state: state, onFocus: (p) async => focused = p),
        ));
    await tester.tapAt(tester.getTopLeft(find.byType(CameraView)) + const Offset(100, 100));
    await tester.pump();
    expect(focused, isNotNull);
    expect(focused!.dx, closeTo(0.5, 0.01));
    expect(focused!.dy, closeTo(0.25, 0.01));
    expect(find.byKey(const Key('focus-ring')), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.byKey(const Key('focus-ring')), findsNothing);
  });

  testWidgets('pinch drives zoom through state', (tester) async {
    final camera = FakeMagnifierCamera();
    final state = MagnifierState(minZoom: 1.0, maxZoom: 8.0);
    await pumpLocalized(
        tester,
        SizedBox(
          width: 400,
          height: 400,
          child: CameraView(camera: camera, state: state, onFocus: (_) async {}),
        ));

    final center = tester.getCenter(find.byType(CameraView));
    final g1 = await tester.startGesture(center - const Offset(40, 0));
    final g2 = await tester.startGesture(center + const Offset(40, 0));
    await tester.pump();
    await g1.moveBy(const Offset(-40, 0));
    await g2.moveBy(const Offset(40, 0));
    await tester.pump();

    // Observed via this test run: ScaleGestureRecognizer reports scale ~1.333
    // (not a naive 2.0 distance ratio) for this pinch-out, so zoom.value lands
    // at ~1.333.
    expect(state.zoom.value, greaterThan(1.0));
    expect(state.zoom.value, closeTo(4 / 3, 0.05));

    await g1.up();
    await g2.up();
    await tester.pumpAndSettle();
  });
}
