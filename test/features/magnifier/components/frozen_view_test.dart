import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fossling_magnifier/features/magnifier/components/frozen_view.dart';

import '../../../helpers/pump_localized.dart';
import '../../../helpers/tiny_png.dart';

void main() {
  testWidgets('shows image in InteractiveViewer with resume button', (tester) async {
    var resumed = false;
    await pumpLocalized(
        tester,
        FrozenView(image: MemoryImage(kTinyPng), onResume: () => resumed = true));
    await tester.pump();
    expect(find.byType(InteractiveViewer), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Back to live view'));
    expect(resumed, isTrue);
  });

  testWidgets('resume button icon differs from the freeze icon', (tester) async {
    await pumpLocalized(
        tester, FrozenView(image: MemoryImage(kTinyPng), onResume: () {}));
    await tester.pump();
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.center_focus_strong), findsNothing);
  });

  testWidgets('still is cover-cropped like the live preview', (tester) async {
    await pumpLocalized(
        tester, FrozenView(image: MemoryImage(kTinyPng), onResume: () {}));
    await tester.pump();
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.fit, BoxFit.cover);
  });
}
