import 'package:flutter_test/flutter_test.dart';
import 'package:floss_magnifier/features/magnifier/magnifier_state.dart';
import 'package:floss_magnifier/features/magnifier/types.dart';

void main() {
  MagnifierState makeState() => MagnifierState(minZoom: 1.0, maxZoom: 8.0);

  test('starts at default zoom, live mode, torch off', () {
    final state = makeState();
    expect(state.zoom.value, 1.0);
    expect(state.mode.value, isA<LiveMode>());
    expect(state.isTorchOn.value, isFalse);
  });

  test('setZoom clamps to camera bounds', () {
    final state = makeState();
    state.setZoom(50.0);
    expect(state.zoom.value, 8.0);
    state.setZoom(0.1);
    expect(state.zoom.value, 1.0);
  });

  test('zoomIn/zoomOut step by kZoomStep and clamp at edges', () {
    final state = makeState();
    state.zoomIn();
    expect(state.zoom.value, 1.5);
    state.zoomOut();
    state.zoomOut();
    expect(state.zoom.value, 1.0);
    expect(state.isAtMinZoom, isTrue);
    state.setZoom(8.0);
    state.zoomIn();
    expect(state.zoom.value, 8.0);
    expect(state.isAtMaxZoom, isTrue);
  });

  test('resetZoom returns to default', () {
    final state = makeState();
    state.setZoom(4.0);
    state.resetZoom();
    expect(state.zoom.value, 1.0);
  });

  test('toggleTorch flips the flag', () {
    final state = makeState();
    state.toggleTorch();
    expect(state.isTorchOn.value, isTrue);
    state.toggleTorch();
    expect(state.isTorchOn.value, isFalse);
  });

  test('freeze stores the image path, resume returns to live', () {
    final state = makeState();
    state.freeze('/tmp/x.jpg');
    expect(state.mode.value, isA<FrozenMode>());
    expect((state.mode.value as FrozenMode).imagePath, '/tmp/x.jpg');
    state.resume();
    expect(state.mode.value, isA<LiveMode>());
  });
}
