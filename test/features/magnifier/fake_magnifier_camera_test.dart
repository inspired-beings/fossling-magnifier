import 'package:flutter_test/flutter_test.dart';
import 'package:fossling_magnifier/features/magnifier/types.dart';

import '../../helpers/fake_magnifier_camera.dart';

void main() {
  test('fake records calls and returns a still path', () async {
    final camera = FakeMagnifierCamera();
    await camera.initialize();
    await camera.setZoom(2.0);
    expect(await camera.takePicture(), '/fake/still.jpg');
    expect(camera.log, ['initialize', 'setZoom 2.0', 'takePicture']);
  });

  test('fake throws configured init error once', () async {
    final camera = FakeMagnifierCamera(initError: const CameraPermissionDeniedException());
    await expectLater(camera.initialize, throwsA(isA<CameraPermissionDeniedException>()));
    await expectLater(camera.initialize(), completes);
  });
}
