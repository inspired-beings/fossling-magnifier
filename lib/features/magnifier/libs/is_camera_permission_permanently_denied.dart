import 'package:flutter/services.dart';

const _channel = MethodChannel('com.inspiredbeings.flossmagnifier/settings');

/// Only meaningful right after a denied permission request; defaults to false
/// when the platform cannot answer.
Future<bool> isCameraPermissionPermanentlyDenied() async {
  try {
    return await _channel.invokeMethod<bool>('isCameraPermissionPermanentlyDenied') ?? false;
  } on PlatformException {
    return false;
  } on MissingPluginException {
    return false;
  }
}
