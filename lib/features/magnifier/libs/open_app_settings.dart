import 'package:flutter/services.dart';

const _channel = MethodChannel('com.inspiredbeings.flossmagnifier/settings');

Future<void> openAppSettings() => _channel.invokeMethod<void>('openAppSettings');
