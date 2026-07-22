import 'dart:ui';

/// Maps a point normalized to a cover-cropped container back to the
/// content's own normalized coordinates.
Offset mapCoverCropPoint({
  required Offset point,
  required Size container,
  required Size content,
}) {
  final scale = [
    container.width / content.width,
    container.height / content.height,
  ].reduce((a, b) => a > b ? a : b);

  final visibleFractionX = (container.width / (content.width * scale)).clamp(0.0, 1.0);
  final visibleFractionY = (container.height / (content.height * scale)).clamp(0.0, 1.0);

  final mappedX = (0.5 + (point.dx - 0.5) * visibleFractionX).clamp(0.0, 1.0);
  final mappedY = (0.5 + (point.dy - 0.5) * visibleFractionY).clamp(0.0, 1.0);

  return Offset(mappedX, mappedY);
}
