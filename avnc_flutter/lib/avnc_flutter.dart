import 'dart:ffi';

import 'package:flutter/services.dart';

class AvncFlutter {
  static const MethodChannel _channel = MethodChannel('avnc_flutter');

  /// 通过URI启动VNC连接
  /// [vncUri] VNC连接URI，例如 "vnc://host:port"
  static Future<int> launchUsingUri(String vncUri, {bool resizeRemoteDesktop = false, double resizeRemoteDesktopScaleFactor = 1}) async {
    try {
      final result = await _channel.invokeMethod('launchUsingUri', {
        'vncUri': vncUri,
        'resizeRemoteDesktop': resizeRemoteDesktop,
        'resizeRemoteDesktopScaleFactor': resizeRemoteDesktopScaleFactor,
      });
      return result as int;
    } on PlatformException catch (e) {
      _logError('launchUsingUri', e);
      rethrow;
    }
  }

  static Future<int> launchPrefsPage() async {
    try {
      final result = await _channel.invokeMethod('launchPrefsPage');
      return result as int;
    } on PlatformException catch (e) {
      _logError('launchPrefsPage', e);
      rethrow;
    }
  }

  static Future<int> launchAboutPage() async {
    try {
      final result = await _channel.invokeMethod('launchAboutPage');
      return result as int;
    } on PlatformException catch (e) {
      _logError('launchAboutPage', e);
      rethrow;
    }
  }

  static void _logError(String methodName, PlatformException e) {
    print('Failed to $methodName: ${e.message}. '
        'Details: ${e.details}, Code: ${e.code}');
  }
}