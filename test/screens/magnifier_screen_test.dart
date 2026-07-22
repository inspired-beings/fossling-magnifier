import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floss_magnifier/features/magnifier/types.dart';
import 'package:floss_magnifier/l10n/generated/app_localizations.dart';
import 'package:floss_magnifier/screens/magnifier_screen.dart';

import '../helpers/fake_magnifier_camera.dart';

Future<void> pumpScreen(WidgetTester tester, FakeMagnifierCamera camera) async {
  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MagnifierScreen(createCamera: () => camera),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('initializes camera and shows live controls', (tester) async {
    final camera = FakeMagnifierCamera();
    await pumpScreen(tester, camera);
    expect(camera.log.first, 'initialize');
    expect(find.byKey(const Key('fake-preview')), findsOneWidget);
    expect(find.bySemanticsLabel('Freeze image'), findsOneWidget);
    expect(find.text('1.0×'), findsOneWidget);
  });

  testWidgets('permission denied shows explanation with retry', (tester) async {
    final camera = FakeMagnifierCamera(initError: const CameraPermissionDeniedException());
    await pumpScreen(tester, camera);
    expect(find.text('Camera access needed'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Allow camera access'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('fake-preview')), findsOneWidget);
  });

  testWidgets('camera failure shows generic error with retry', (tester) async {
    final camera = FakeMagnifierCamera(initError: const CameraUnavailableException('boom'));
    await pumpScreen(tester, camera);
    expect(find.text('The camera could not be started'), findsOneWidget);
  });

  testWidgets('zoom changes propagate to the camera', (tester) async {
    final camera = FakeMagnifierCamera();
    await pumpScreen(tester, camera);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(camera.log, contains('setZoom 1.5'));
  });

  testWidgets('torch button toggles the camera torch', (tester) async {
    final camera = FakeMagnifierCamera();
    await pumpScreen(tester, camera);
    await tester.tap(find.bySemanticsLabel('Torch, off'));
    await tester.pump();
    expect(camera.log, contains('setTorch true'));
    expect(find.bySemanticsLabel('Torch, on'), findsOneWidget);
  });

  testWidgets('no torch button when camera has no torch', (tester) async {
    final camera = FakeMagnifierCamera(hasTorch: false);
    await pumpScreen(tester, camera);
    expect(find.bySemanticsLabel('Torch, off'), findsNothing);
  });

  testWidgets('freeze switches to frozen view, resume returns to live', (tester) async {
    final camera = FakeMagnifierCamera();
    await pumpScreen(tester, camera);
    await tester.tap(find.bySemanticsLabel('Freeze image'));
    await tester.pump();
    expect(camera.log, contains('takePicture'));
    expect(find.bySemanticsLabel('Back to live view'), findsOneWidget);
    expect(find.bySemanticsLabel('Freeze image'), findsNothing);
    await tester.tap(find.bySemanticsLabel('Back to live view'));
    await tester.pump();
    expect(find.bySemanticsLabel('Freeze image'), findsOneWidget);
  });

  testWidgets('failed capture shows snackbar and stays live', (tester) async {
    final camera = FakeMagnifierCamera(takePictureError: Exception('nope'));
    await pumpScreen(tester, camera);
    await tester.tap(find.bySemanticsLabel('Freeze image'));
    await tester.pump();
    expect(find.text('Could not freeze the image'), findsOneWidget);
    expect(find.bySemanticsLabel('Freeze image'), findsOneWidget);
  });

  testWidgets('zoom badge resets zoom', (tester) async {
    final camera = FakeMagnifierCamera();
    await pumpScreen(tester, camera);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('1.5×'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Reset zoom to 1x'));
    await tester.pump();
    expect(find.text('1.0×'), findsOneWidget);
  });

  testWidgets('inactive keeps the camera alive', (tester) async {
    final camera = FakeMagnifierCamera();
    await pumpScreen(tester, camera);
    addTearDown(() => tester.binding
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();

    expect(camera.log, isNot(contains('dispose')));
    expect(find.bySemanticsLabel('Freeze image'), findsOneWidget);
  });

  testWidgets('paused releases camera, turns torch off and shows spinner',
      (tester) async {
    final camera = FakeMagnifierCamera();
    await pumpScreen(tester, camera);
    addTearDown(() => tester.binding
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed));

    await tester.tap(find.bySemanticsLabel('Torch, off'));
    await tester.pump();
    expect(find.bySemanticsLabel('Torch, on'), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();

    expect(camera.log, contains('dispose'));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('inactive then resumed does not re-initialize the camera',
      (tester) async {
    final camera = FakeMagnifierCamera();
    await pumpScreen(tester, camera);
    addTearDown(() => tester.binding
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(camera.log.where((entry) => entry == 'initialize').length, 1);
  });

  testWidgets('resume after pause re-initializes and restores live controls',
      (tester) async {
    final camera = FakeMagnifierCamera();
    await pumpScreen(tester, camera);
    addTearDown(() => tester.binding
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(camera.log.where((entry) => entry == 'initialize').length, 2);
    expect(find.bySemanticsLabel('Freeze image'), findsOneWidget);
  });

  testWidgets('frozen still survives pause and resume', (tester) async {
    final camera = FakeMagnifierCamera();
    await pumpScreen(tester, camera);
    addTearDown(() => tester.binding
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed));

    await tester.tap(find.bySemanticsLabel('Freeze image'));
    await tester.pump();
    expect(find.bySemanticsLabel('Back to live view'), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(find.bySemanticsLabel('Back to live view'), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Back to live view'), findsOneWidget);
  });

  testWidgets('resume deletes the outgoing frozen still', (tester) async {
    await tester.runAsync(() async {
      final file = File(
          '${Directory.systemTemp.path}/floss_magnifier_test_still_${DateTime.now().microsecondsSinceEpoch}.jpg');
      await file.writeAsBytes([0]);
      final camera = FakeMagnifierCamera(stillPath: file.path);
      await pumpScreen(tester, camera);

      await tester.tap(find.bySemanticsLabel('Freeze image'));
      await tester.pump();
      expect(find.bySemanticsLabel('Back to live view'), findsOneWidget);
      expect(await file.exists(), isTrue);

      await tester.tap(find.bySemanticsLabel('Back to live view'));
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(await file.exists(), isFalse);
    });
  });
}
