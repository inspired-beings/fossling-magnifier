import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floss_magnifier/features/magnifier/components/control_bar.dart';
import 'package:floss_magnifier/features/magnifier/magnifier_state.dart';

import '../../../helpers/pump_localized.dart';

void main() {
  testWidgets('steppers change zoom by one step', (tester) async {
    final state = MagnifierState(minZoom: 1.0, maxZoom: 8.0);
    await pumpLocalized(tester, ControlBar(state: state, onFreeze: () {}));
    await tester.tap(find.byIcon(Icons.add));
    expect(state.zoom.value, 1.5);
    await tester.tap(find.byIcon(Icons.remove));
    expect(state.zoom.value, 1.0);
  });

  testWidgets('slider reflects and drives the same zoom value', (tester) async {
    final state = MagnifierState(minZoom: 1.0, maxZoom: 8.0);
    await pumpLocalized(tester, ControlBar(state: state, onFreeze: () {}));
    state.setZoom(8.0);
    await tester.pump();
    final slider = tester.widget<Slider>(find.byType(Slider));
    expect(slider.value, 8.0);
    expect(find.bySemanticsLabel('Zoom level'), findsOneWidget);
  });

  testWidgets('freeze button fires callback and has semantic label', (tester) async {
    final state = MagnifierState(minZoom: 1.0, maxZoom: 8.0);
    var frozen = false;
    await pumpLocalized(tester, ControlBar(state: state, onFreeze: () => frozen = true));
    await tester.tap(find.bySemanticsLabel('Freeze image'));
    expect(frozen, isTrue);
  });

  testWidgets('controls carry French semantic labels under fr locale', (tester) async {
    final state = MagnifierState(minZoom: 1.0, maxZoom: 8.0);
    await pumpLocalized(tester, ControlBar(state: state, onFreeze: () {}),
        locale: const Locale('fr'));
    expect(find.bySemanticsLabel("Figer l'image"), findsOneWidget);
    expect(find.bySemanticsLabel('Zoomer'), findsOneWidget);
    expect(find.bySemanticsLabel('Dézoomer'), findsOneWidget);
    expect(find.bySemanticsLabel('Niveau de zoom'), findsOneWidget);
  });

  testWidgets('all tap targets are at least 48dp', (tester) async {
    final state = MagnifierState(minZoom: 1.0, maxZoom: 8.0);
    await pumpLocalized(tester, ControlBar(state: state, onFreeze: () {}));
    final handle = tester.ensureSemantics();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    handle.dispose();
  });
}
