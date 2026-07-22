import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';

import '../types.dart';
import 'magnifier_camera.dart';

class PluginMagnifierCamera implements MagnifierCamera {
  CameraController? _controller;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  bool _hasTorch = false;

  @override
  double get minZoom => _minZoom;
  @override
  double get maxZoom => _maxZoom;
  @override
  bool get hasTorch => _hasTorch;

  @override
  Future<void> initialize() async {
    try {
      final cameras = await availableCameras();
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.isEmpty ? throw const CameraUnavailableException('no cameras') : cameras.first,
      );
      final controller = CameraController(back, ResolutionPreset.max, enableAudio: false);
      try {
        await controller.initialize();
        _minZoom = await controller.getMinZoomLevel();
        _maxZoom = await controller.getMaxZoomLevel();
        // The plugin has no torch-capability query; probing is the only way.
        try {
          await controller.setFlashMode(FlashMode.off);
          _hasTorch = true;
        } on CameraException {
          _hasTorch = false;
        }
        _controller = controller;
      } catch (_) {
        // Don't leak the native session when a post-init probe fails.
        await controller.dispose();
        rethrow;
      }
    } on CameraException catch (e) {
      if (e.code == 'CameraAccessDenied' || e.code == 'CameraAccessDeniedWithoutPrompt') {
        throw const CameraPermissionDeniedException();
      }
      throw CameraUnavailableException(e.code);
    }
  }

  CameraController get _ready {
    final controller = _controller;
    if (controller == null) throw const CameraUnavailableException('not initialized');
    return controller;
  }

  @override
  Widget buildPreview(BuildContext context) => CameraPreview(_ready);

  @override
  Future<void> setZoom(double zoom) => _ready.setZoomLevel(zoom.clamp(_minZoom, _maxZoom));

  @override
  Future<void> setTorch(bool on) =>
      _ready.setFlashMode(on ? FlashMode.torch : FlashMode.off);

  @override
  Future<void> setFocusPoint(Offset normalized) async {
    await _ready.setFocusPoint(normalized);
    await _ready.setExposurePoint(normalized);
  }

  @override
  Future<String> takePicture() async {
    final file = await _ready.takePicture();
    return file.path;
  }

  @override
  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}
