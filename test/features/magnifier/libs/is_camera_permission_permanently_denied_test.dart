import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fossling_magnifier/features/magnifier/libs/is_camera_permission_permanently_denied.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.fossling.magnifier/settings');

  void mockResponse(Future<Object?> Function(MethodCall call) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, handler);
  }

  test('returns the platform verdict from the settings channel', () async {
    final calls = <MethodCall>[];
    mockResponse((call) async {
      calls.add(call);
      return true;
    });

    expect(await isCameraPermissionPermanentlyDenied(), isTrue);
    expect(calls.single.method, 'isCameraPermissionPermanentlyDenied');

    mockResponse((call) async => false);
    expect(await isCameraPermissionPermanentlyDenied(), isFalse);
  });

  test('defaults to false when the channel is unavailable', () async {
    mockResponse((call) async => throw MissingPluginException());
    expect(await isCameraPermissionPermanentlyDenied(), isFalse);
  });

  test('defaults to false on a null platform response', () async {
    mockResponse((call) async => null);
    expect(await isCameraPermissionPermanentlyDenied(), isFalse);
  });
}
