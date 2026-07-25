import 'package:flutter/material.dart';

class CameraErrorView extends StatelessWidget {
  const CameraErrorView({
    super.key,
    required this.title,
    this.body,
    required this.buttonLabel,
    required this.onRetry,
  });

  final String title;
  final String? body;
  final String buttonLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Scrollable so a large system font scale pushes content out of reach instead of
    // overflowing it off-screen — this screen is where a low-vision user is stuck.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: textTheme.headlineMedium, textAlign: TextAlign.center),
                if (body != null) ...[
                  const SizedBox(height: 16),
                  Text(body!, style: textTheme.bodyLarge, textAlign: TextAlign.center),
                ],
                const SizedBox(height: 32),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(220, 64),
                    // Via the button style, not the child Text: textTheme carries an
                    // onSurface color that would beat the button's own foreground.
                    textStyle: textTheme.titleLarge,
                  ),
                  onPressed: onRetry,
                  child: Text(buttonLabel, textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
