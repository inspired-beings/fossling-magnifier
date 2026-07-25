import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants.dart';

class FreezeButton extends StatelessWidget {
  const FreezeButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final size = kPrimaryControlSize + 4;
    // MergeSemantics: the button's own node carries the tap action, this one the label —
    // unmerged, a screen reader reads an unlabeled button.
    return MergeSemantics(
      child: Semantics(
        button: true,
        label: label,
        child: SizedBox(
          width: size,
          height: size,
          child: FilledButton(
            style: FilledButton.styleFrom(shape: const CircleBorder()),
            onPressed: () {
              HapticFeedback.heavyImpact();
              onPressed();
            },
            child: Icon(icon, size: 32),
          ),
        ),
      ),
    );
  }
}
