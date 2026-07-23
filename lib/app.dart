import 'package:flutter/material.dart';
import 'package:fossling_magnifier/l10n/generated/app_localizations.dart';

import 'screens/magnifier_screen.dart';

class MagnifierApp extends StatelessWidget {
  const MagnifierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.amber,
        useMaterial3: true,
      ),
      home: const MagnifierScreen(),
    );
  }
}
