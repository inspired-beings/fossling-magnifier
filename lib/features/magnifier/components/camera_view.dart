import 'dart:async';

import 'package:flutter/material.dart';

import '../libs/magnifier_camera.dart';
import '../magnifier_state.dart';

class CameraView extends StatefulWidget {
  const CameraView({
    super.key,
    required this.camera,
    required this.state,
    required this.onFocus,
  });

  final MagnifierCamera camera;
  final MagnifierState state;
  final Future<void> Function(Offset normalized) onFocus;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  Offset? _ringPosition;
  Timer? _ringTimer;
  double _pinchStartZoom = 1.0;

  void _handleTap(TapUpDetails details, Size size) {
    final local = details.localPosition;
    widget.onFocus(Offset(
      (local.dx / size.width).clamp(0.0, 1.0),
      (local.dy / size.height).clamp(0.0, 1.0),
    ));
    _ringTimer?.cancel();
    setState(() => _ringPosition = local);
    _ringTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) setState(() => _ringPosition = null);
    });
  }

  @override
  void dispose() {
    _ringTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (d) => _handleTap(d, constraints.biggest),
        onScaleStart: (_) => _pinchStartZoom = widget.state.zoom.value,
        onScaleUpdate: (d) {
          if (d.pointerCount >= 2) widget.state.setZoom(_pinchStartZoom * d.scale);
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            widget.camera.buildPreview(context),
            if (_ringPosition != null)
              Positioned(
                left: _ringPosition!.dx - 32,
                top: _ringPosition!.dy - 32,
                child: Container(
                  key: const Key('focus-ring'),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Theme.of(context).colorScheme.primary, width: 3),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
