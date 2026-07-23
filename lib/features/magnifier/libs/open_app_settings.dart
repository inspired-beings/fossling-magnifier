import 'package:flutter/services.dart';

const _channel = MethodChannel('com.fossling.magnifier/settings');

Future<void> openAppSettings() => _channel.invokeMethod<void>('openAppSettings');
