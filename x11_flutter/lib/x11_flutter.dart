import 'package:flutter/services.dart';

class X11Flutter {
  /// Envoie un événement de mouvement de souris/doigt
  static Future<void> sendPointerMove(double x, double y) async {
    await _channel.invokeMethod('injectInputEvent', {
      'type': 'move',
      'x': x,
      'y': y,
    });
  }

  /// Envoie un clic (appui)
  static Future<void> sendPointerDown(double x, double y, int button) async {
    await _channel.invokeMethod('injectInputEvent', {
      'type': 'down',
      'x': x,
      'y': y,
      'button': button, // 1 = gauche, 2 = milieu, 3 = droit
    });
  }

  /// Envoie un relâchement
  static Future<void> sendPointerUp(double x, double y, int button) async {
    await _channel.invokeMethod('injectInputEvent', {
      'type': 'up',
      'x': x,
      'y': y,
      'button': button,
    });
  }
  static const MethodChannel _channel = MethodChannel('x11_flutter');

  /// 启动X11服务器
  /// [tmpdir] 临时目录路径
  /// [xkb] XKB配置根目录路径
  /// [xserverArgs] X服务器命令行参数，例如 [":4", "-ac"]
  static Future<int> launchXServer(String tmpdir, String xkb, List<String> xserverArgs) async {
    try {
      final result = await _channel.invokeMethod('launchXServer', {
        'tmpdir': tmpdir,
        'xkb': xkb,
        'xserverArgs': xserverArgs,
      });
      return result as int;
    } on PlatformException catch (e) {
      _logError('launchXServer', e);
      rethrow;
    }
  }

  /// 启动X11首选项页面
  static Future<int> launchX11PrefsPage() async {
    try {
      final result = await _channel.invokeMethod('launchX11PrefsPage');
      return result as int;
    } on PlatformException catch (e) {
      _logError('launchX11PrefsPage', e);
      rethrow;
    }
  }

  /// 启动X11主页面
  static Future<int> launchX11Page() async {
    try {
      final result = await _channel.invokeMethod('launchX11Page');
      return result as int;
    } on PlatformException catch (e) {
      _logError('launchX11Page', e);
      rethrow;
    }
  }

  /// 在原有的缩放上设置缩放倍率
  static Future<int> setX11ScaleFactor(double scale) async {
    try {
      final result = await _channel.invokeMethod('setScale', {
        'scale': scale,
      });
      return result as int;
    } on PlatformException catch (e) {
      _logError('setScaleFactor', e);
      rethrow;
    }
  }

  static void _logError(String methodName, PlatformException e) {
    print('Failed to $methodName: ${e.message}. '
        'Details: ${e.details}, Code: ${e.code}');
  }
}