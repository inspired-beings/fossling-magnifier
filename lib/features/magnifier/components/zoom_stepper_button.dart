import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants.dart';

/// `enabled: false` dims the button and switches to the edge (medium) haptic; the `onStep`
/// callback still fires unconditionally — zoom clamping is `MagnifierState`'s job, not this
/// widget's.
class ZoomStepperButton extends StatefulWidget {
  const ZoomStepperButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onStep,
    required this.enabled,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onStep;
  final bool enabled;

  @override
  State<ZoomStepperButton> createState() => _ZoomStepperButtonState();
}

class _ZoomStepperButtonState extends State<ZoomStepperButton> {
  Timer? _repeat;

  void _step() {
    // `enabled` reflects the edge state as of the parent's last rebuild, which can lag
    // behind `state.zoom` when no frame has been pumped since the previous step (e.g. two
    // taps in a row in a test). MagnifierState.setZoom clamps internally, so calling
    // onStep unconditionally is safe at a true edge (no-op) and correct when `enabled` is
    // merely stale. Only the haptic choice depends on the (possibly stale) dimmed state.
    if (!widget.enabled) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
    widget.onStep();
  }

  void _stopRepeat() {
    _repeat?.cancel();
    _repeat = null;
  }

  @override
  void dispose() {
    _stopRepeat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTap: _step,
        onLongPressStart: (_) =>
            _repeat = Timer.periodic(const Duration(milliseconds: 150), (_) => _step()),
        onLongPressEnd: (_) => _stopRepeat(),
        onLongPressCancel: _stopRepeat,
        child: Container(
          width: kPrimaryControlSize,
          height: kPrimaryControlSize,
          decoration: BoxDecoration(
            color: widget.enabled
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(widget.icon, size: 36, color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
    );
  }
}
