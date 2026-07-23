import 'package:flutter/material.dart';
import 'package:fossling_magnifier/l10n/generated/app_localizations.dart';

import '../magnifier_state.dart';
import 'freeze_button.dart';
import 'zoom_slider.dart';
import 'zoom_stepper_button.dart';

class ControlBar extends StatelessWidget {
  const ControlBar({super.key, required this.state, required this.onFreeze});

  final MagnifierState state;
  final VoidCallback onFreeze;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.78),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ZoomSlider(state: state),
              const SizedBox(height: 4),
              ValueListenableBuilder<double>(
                valueListenable: state.zoom,
                builder: (context, _, _) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ZoomStepperButton(
                      icon: Icons.remove,
                      semanticLabel: l10n.zoomOut,
                      onStep: state.zoomOut,
                      enabled: !state.isAtMinZoom,
                    ),
                    FreezeButton(
                      icon: Icons.center_focus_strong,
                      label: l10n.freeze,
                      onPressed: onFreeze,
                    ),
                    ZoomStepperButton(
                      icon: Icons.add,
                      semanticLabel: l10n.zoomIn,
                      onStep: state.zoomIn,
                      enabled: !state.isAtMaxZoom,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
