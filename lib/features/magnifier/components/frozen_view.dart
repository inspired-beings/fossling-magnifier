import 'package:flutter/material.dart';
import 'package:fossling_magnifier/l10n/generated/app_localizations.dart';

import 'freeze_button.dart';

class FrozenView extends StatelessWidget {
  const FrozenView({super.key, required this.image, required this.onResume});

  final ImageProvider image;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        InteractiveViewer(
          maxScale: 10,
          child: Image(
            image: image,
            // Match the live preview's cover crop — contain caused a
            // letterbox jump on freeze.
            fit: BoxFit.cover,
            errorBuilder: (context, _, _) => const ColoredBox(color: Colors.black),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FreezeButton(
                icon: Icons.play_arrow,
                label: AppLocalizations.of(context).resume,
                onPressed: onResume,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
