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
    return Center(
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
              style: FilledButton.styleFrom(minimumSize: const Size(220, 64)),
              onPressed: onRetry,
              child: Text(buttonLabel, style: textTheme.titleLarge),
            ),
          ],
        ),
      ),
    );
  }
}
