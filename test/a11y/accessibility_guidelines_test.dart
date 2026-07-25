import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fossling_magnifier/features/magnifier/types.dart';

import '../helpers/fake_magnifier_camera.dart';
import '../helpers/pump_magnifier_screen.dart';

/// Every state the user can land on, in every shipped locale, must pass the Material
/// accessibility guidelines. A new screen that is not registered here is the failure
/// this suite exists to prevent — keep the map exhaustive.
final _screenStates = <String, Future<void> Function(WidgetTester, Locale)>{
  'live view': (tester, locale) =>
      pumpMagnifierScreen(tester, FakeMagnifierCamera(), locale: locale),
  'live view without torch': (tester, locale) => pumpMagnifierScreen(
        tester,
        FakeMagnifierCamera(hasTorch: false),
        locale: locale,
      ),
  'frozen view': (tester, locale) async {
    await pumpMagnifierScreen(tester, FakeMagnifierCamera(), locale: locale);
    await tester.tap(find.byIcon(Icons.center_focus_strong));
    await tester.pumpAndSettle();
  },
  'permission denied': (tester, locale) => pumpMagnifierScreen(
        tester,
        FakeMagnifierCamera(initError: const CameraPermissionDeniedException()),
        locale: locale,
      ),
  'permission permanently denied': (tester, locale) => pumpMagnifierScreen(
        tester,
        FakeMagnifierCamera(
            initError: const CameraPermissionDeniedException(isPermanent: true)),
        locale: locale,
        openAppSettings: () async {},
      ),
  'camera failure': (tester, locale) => pumpMagnifierScreen(
        tester,
        FakeMagnifierCamera(initError: const CameraUnavailableException('boom')),
        locale: locale,
      ),
};

void main() {
  for (final locale in const [Locale('en'), Locale('fr')]) {
    for (final state in _screenStates.entries) {
      testWidgets('${state.key} (${locale.languageCode}) meets a11y guidelines',
          (tester) async {
        final handle = tester.ensureSemantics();
        await state.value(tester, locale);

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));

        handle.dispose();
      });
    }
  }
}
