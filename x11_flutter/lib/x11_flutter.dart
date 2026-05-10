import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class X11Flutter {
  static const MethodChannel _channel = MethodChannel('x11_flutter');

  static SharedPreferences? _prefs;

  /// Call this once during app init (e.g., after G.prefs is ready).
  static void init(SharedPreferences prefs) {
    _prefs = prefs;
  }

  /// Launch the X11 server **only if** the user has enabled it via the toggle.
  /// If the preference "Fix_x11" is false (or missing), the call is skipped.
  static Future<int> launchXServer(
    String tmpdir,
    String xkb,
    List<String> xserverArgs,
  ) async {
    final enabled = _prefs?.getBool("Fix_x11") ?? false;
    if (!enabled) {
      print('X11 launch skipped – Fix_x11 is disabled ❌');
      return 0; // Not launched, but not an error
    }

    try {
      final result = await _channel.invokeMethod('launchXServer', {
        'tmpdir': tmpdir,
        'xkb': xkb,
        'xserverArgs': xserverArgs,
      });
      print('X11 server launched via channel 🎯');
      return result as int;
    } on PlatformException catch (e) {
      _logError('launchXServer', e);
      rethrow;
    }
  }

  // ---- All other methods unchanged ----
  static Future<int> launchX11PrefsPage() async {
    try {
      final result = await _channel.invokeMethod('launchX11PrefsPage');
      return result as int;
    } on PlatformException catch (e) {
      _logError('launchX11PrefsPage', e);
      rethrow;
    }
  }

  static Future<int> launchX11Page() async {
    try {
      final result = await _channel.invokeMethod('launchX11Page');
      return result as int;
    } on PlatformException catch (e) {
      _logError('launchX11Page', e);
      rethrow;
    }
  }

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