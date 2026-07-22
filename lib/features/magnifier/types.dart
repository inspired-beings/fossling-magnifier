import 'package:flutter/foundation.dart';

@immutable
sealed class MagnifierMode {
  const MagnifierMode();
}

@immutable
class LiveMode extends MagnifierMode {
  const LiveMode();
}

@immutable
class FrozenMode extends MagnifierMode {
  const FrozenMode(this.imagePath);

  final String imagePath;
}

class CameraPermissionDeniedException implements Exception {
  const CameraPermissionDeniedException({this.isPermanent = false});

  /// True when the OS will no longer show the permission prompt.
  final bool isPermanent;
}

class CameraUnavailableException implements Exception {
  const CameraUnavailableException([this.details]);

  final String? details;
}
