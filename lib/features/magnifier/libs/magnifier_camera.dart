import 'package:flutter/widgets.dart';

abstract interface class MagnifierCamera {
  double get minZoom;
  double get maxZoom;
  bool get hasTorch;

  Future<void> initialize();
  Widget buildPreview(BuildContext context);
  Future<void> setZoom(double zoom);
  Future<void> setTorch(bool on);
  Future<void> setFocusPoint(Offset normalized);
  Future<String> takePicture();
  Future<void> dispose();
}
