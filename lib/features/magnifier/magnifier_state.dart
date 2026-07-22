import 'package:flutter/foundation.dart';

import 'constants.dart';
import 'types.dart';

class MagnifierState {
  MagnifierState({required this.minZoom, required this.maxZoom})
      : zoom = ValueNotifier(kDefaultZoom.clamp(minZoom, maxZoom));

  final double minZoom;
  final double maxZoom;

  final ValueNotifier<double> zoom;
  final ValueNotifier<bool> isTorchOn = ValueNotifier(false);
  final ValueNotifier<MagnifierMode> mode = ValueNotifier(const LiveMode());

  bool get isAtMinZoom => zoom.value <= minZoom;
  bool get isAtMaxZoom => zoom.value >= maxZoom;

  void setZoom(double value) => zoom.value = value.clamp(minZoom, maxZoom);

  void zoomIn() => setZoom(zoom.value + kZoomStep);

  void zoomOut() => setZoom(zoom.value - kZoomStep);

  void resetZoom() => setZoom(kDefaultZoom);

  void toggleTorch() => isTorchOn.value = !isTorchOn.value;

  void freeze(String imagePath) => mode.value = FrozenMode(imagePath);

  void resume() => mode.value = const LiveMode();

  void dispose() {
    zoom.dispose();
    isTorchOn.dispose();
    mode.dispose();
  }
}
