import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fossling_magnifier/l10n/generated/app_localizations.dart';

Future<void> pumpLocalized(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
}) {
  return tester.pumpWidget(MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  ));
}
