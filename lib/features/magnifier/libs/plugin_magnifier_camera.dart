import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';

import '../helpers/map_cover_crop_point.dart';
import '../types.dart';
import 'is_camera_permission_permanently_denied.dart';
import 'magnifier_camera.dart';

class PluginMagnifierCamera implements MagnifierCamera {
  CameraController? _controller;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  bool _hasTorch = false;
  Size? _cropContainer;
  Size? _cropContent;

  @override
  double get minZoom => _minZoom;
  @override
  double get maxZoom => _maxZoom;
  @override
  bool get hasTorch => _hasTorch;

  @override
  Future<void> initialize() async {
    // Defensive: never overwrite a live controller (also closes the
    // pause-during-in-flight-init race).
    await _controller?.dispose();
    _controller = null;
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
      if (e.code == 'CameraAccessDenied') {
        // camera_android_camerax never emits CameraAccessDeniedWithoutPrompt;
        // the platform side must be asked whether a prompt is still possible.
        throw CameraPermissionDeniedException(
            isPermanent: await isCameraPermissionPermanentlyDenied());
      }
      if (e.code == 'CameraAccessDeniedWithoutPrompt') {
        throw const CameraPermissionDeniedException(isPermanent: true);
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
  Widget buildPreview(BuildContext context) {
    final controller = _ready;
    return LayoutBuilder(builder: (context, constraints) {
      final preview = controller.value.previewSize;
      if (preview == null) return CameraPreview(controller);
      final isPortrait = MediaQuery.orientationOf(context) == Orientation.portrait;
      // previewSize is reported in landscape sensor coordinates; swap for portrait.
      final displayed = isPortrait ? Size(preview.height, preview.width) : preview;
      _updateCoverCrop(container: constraints.biggest, content: displayed);
      return ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: displayed.width,
            height: displayed.height,
            child: CameraPreview(controller),
          ),
        ),
      );
    });
  }

  // Runs during build (via LayoutBuilder) — must only assign fields, no
  // setState/notifications.
  void _updateCoverCrop({required Size container, required Size content}) {
    _cropContainer = container;
    _cropContent = content;
  }

  @override
  Future<void> setZoom(double zoom) => _ready.setZoomLevel(zoom.clamp(_minZoom, _maxZoom));

  @override
  Future<void> setTorch(bool on) =>
      _ready.setFlashMode(on ? FlashMode.torch : FlashMode.off);

  @override
  Future<void> setFocusPoint(Offset normalized) async {
    final container = _cropContainer;
    final content = _cropContent;
    final mapped = (container != null && content != null)
        ? mapCoverCropPoint(point: normalized, container: container, content: content)
        : normalized;
    await _ready.setFocusPoint(mapped);
    await _ready.setExposurePoint(mapped);
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
