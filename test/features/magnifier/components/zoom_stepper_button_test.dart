import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floss_magnifier/features/magnifier/components/zoom_stepper_button.dart';

import '../../../helpers/pump_localized.dart';

void main() {
  late List<String> hapticCalls;

  setUp(() {
    hapticCalls = <String>[];
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  tearDown(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  void mockHaptics(WidgetTester tester) {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (
      call,
    ) async {
      if (call.method == 'HapticFeedback.vibrate') {
        hapticCalls.add(call.arguments as String);
      }
      return null;
    });
  }

  testWidgets('tap fires onStep once and emits a light haptic when enabled', (tester) async {
    mockHaptics(tester);
    var stepCount = 0;
    await pumpLocalized(
      tester,
      ZoomStepperButton(
        icon: Icons.add,
        semanticLabel: 'Zoom in',
        onStep: () => stepCount++,
        enabled: true,
      ),
    );

    await tester.tap(find.bySemanticsLabel('Zoom in'));

    expect(stepCount, 1);
    expect(hapticCalls, contains('HapticFeedbackType.lightImpact'));
    expect(hapticCalls, isNot(contains('HapticFeedbackType.mediumImpact')));
  });

  testWidgets('tap while enabled:false emits a medium haptic (edge feedback)', (tester) async {
    mockHaptics(tester);
    // Current contract: onStep still fires unconditionally at the edge; MagnifierState.setZoom
    // clamps internally so this is a safe no-op there. Only the haptic distinguishes the edge.
    var stepCount = 0;
    await pumpLocalized(
      tester,
      ZoomStepperButton(
        icon: Icons.remove,
        semanticLabel: 'Zoom out',
        onStep: () => stepCount++,
        enabled: false,
      ),
    );

    await tester.tap(find.bySemanticsLabel('Zoom out'));

    expect(hapticCalls, contains('HapticFeedbackType.mediumImpact'));
    expect(hapticCalls, isNot(contains('HapticFeedbackType.lightImpact')));
    expect(stepCount, 1);
  });

  testWidgets('long-press repeats onStep and stops once the gesture ends', (tester) async {
    mockHaptics(tester);
    var stepCount = 0;
    await pumpLocalized(
      tester,
      ZoomStepperButton(
        icon: Icons.add,
        semanticLabel: 'Zoom in',
        onStep: () => stepCount++,
        enabled: true,
      ),
    );

    // Hold the gesture down manually (rather than tester.longPress, which presses AND releases
    // in one call) so repeat ticks can accumulate while the finger is still down.
    final gesture = await tester.startGesture(tester.getCenter(find.bySemanticsLabel('Zoom in')));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 450));

    expect(stepCount, greaterThanOrEqualTo(3));

    await gesture.up();
    await tester.pumpAndSettle();
    final countAtGestureEnd = stepCount;
    await tester.pump(const Duration(milliseconds: 450));

    expect(stepCount, countAtGestureEnd);
  });
}
