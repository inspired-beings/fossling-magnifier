import 'package:flutter/material.dart';
import 'package:fossling_magnifier/l10n/generated/app_localizations.dart';

import 'libs/build_app_theme.dart';
import 'screens/magnifier_screen.dart';

class MagnifierApp extends StatelessWidget {
  const MagnifierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: buildAppTheme(),
      home: const MagnifierScreen(),
    );
  }
}
