import 'package:flutter/widgets.dart';
import 'package:floss_magnifier/features/magnifier/libs/magnifier_camera.dart';

class FakeMagnifierCamera implements MagnifierCamera {
  FakeMagnifierCamera({
    this.minZoom = 1.0,
    this.maxZoom = 8.0,
    this.hasTorch = true,
    this.initError,
    this.takePictureError,
  });

  @override
  final double minZoom;
  @override
  final double maxZoom;
  @override
  final bool hasTorch;

  Object? initError;
  Object? takePictureError;
  final List<String> log = [];

  @override
  Future<void> initialize() async {
    log.add('initialize');
    final error = initError;
    if (error != null) {
      initError = null;
      throw error;
    }
  }

  @override
  Widget buildPreview(BuildContext context) =>
      const ColoredBox(key: Key('fake-preview'), color: Color(0xFF222222));

  @override
  Future<void> setZoom(double zoom) async => log.add('setZoom $zoom');

  @override
  Future<void> setTorch(bool on) async => log.add('setTorch $on');

  @override
  Future<void> setFocusPoint(Offset normalized) async =>
      log.add('setFocusPoint ${normalized.dx.toStringAsFixed(2)},${normalized.dy.toStringAsFixed(2)}');

  @override
  Future<String> takePicture() async {
    log.add('takePicture');
    final error = takePictureError;
    if (error != null) throw error;
    return '/fake/still.jpg';
  }

  @override
  Future<void> dispose() async => log.add('dispose');
}
