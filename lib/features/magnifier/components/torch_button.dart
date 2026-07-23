import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fossling_magnifier/l10n/generated/app_localizations.dart';

import '../constants.dart';
import '../magnifier_state.dart';

class TorchButton extends StatelessWidget {
  const TorchButton({super.key, required this.state, required this.onChanged});

  final MagnifierState state;
  final Future<void> Function(bool on) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<bool>(
      valueListenable: state.isTorchOn,
      builder: (context, on, _) => Semantics(
        button: true,
        label: on ? l10n.torchOn : l10n.torchOff,
        child: SizedBox(
          width: kTorchButtonSize,
          height: kTorchButtonSize,
          child: IconButton.filledTonal(
            isSelected: on,
            icon: const Icon(Icons.flashlight_off),
            selectedIcon: const Icon(Icons.flashlight_on),
            onPressed: () async {
              HapticFeedback.lightImpact();
              state.toggleTorch();
              final requested = state.isTorchOn.value;
              try {
                await onChanged(requested);
              } catch (_) {
                // Hardware refused: don't let the UI lie about the torch.
                if (state.isTorchOn.value == requested) {
                  state.isTorchOn.value = !requested;
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
