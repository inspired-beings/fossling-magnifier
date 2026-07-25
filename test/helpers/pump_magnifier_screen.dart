import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fossling_magnifier/l10n/generated/app_localizations.dart';
import 'package:fossling_magnifier/libs/build_app_theme.dart';
import 'package:fossling_magnifier/screens/magnifier_screen.dart';

import 'fake_magnifier_camera.dart';

Future<void> pumpMagnifierScreen(
  WidgetTester tester,
  FakeMagnifierCamera camera, {
  Future<void> Function()? openAppSettings,
  Locale locale = const Locale('en'),
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  await tester.pumpWidget(MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: buildAppTheme(),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: child!,
    ),
    home: MagnifierScreen(
      createCamera: () => camera,
      openAppSettings: openAppSettings,
    ),
  ));
  await tester.pumpAndSettle();
}
