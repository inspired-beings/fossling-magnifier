import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floss_magnifier/features/magnifier/libs/open_app_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('invokes openAppSettings on the settings platform channel', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.inspiredbeings.flossmagnifier/settings'),
      (call) async {
        calls.add(call);
        return null;
      },
    );

    await openAppSettings();

    expect(calls, hasLength(1));
    expect(calls.single.method, 'openAppSettings');
  });
}
