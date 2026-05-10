import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class X11Flutter {
  static const MethodChannel _channel = MethodChannel('x11_flutter');

  // ---- Preferences & Idempotent Guard ----
  static SharedPreferences? _prefs;
  static bool _serverLaunched = false;

  /// Call this **once** after your SharedPreferences instance is ready.
  /// (e.g., in Workflow.initData())
  static void init(SharedPreferences prefs) {
    _prefs = prefs;
  }

  /// Launch the X11 server **only if** the user has enabled the
  /// "Fix_x11" toggle AND it hasn't been launched already.
  ///
  /// If the toggle is off, the call is skipped entirely.
  /// If the toggle is on but already launched, it's a safe no‑op.
  static Future<int> launchXServer(
    String tmpdir,
    String xkb,
    List<String> xserverArgs,
  ) async {
    // 1. Respect the toggle
    final enabled = _prefs?.getBool("Fix_x11") ?? false;
    if (!enabled) {
      print('X11 launch skipped – Fix_x11 is disabled ❌');
      return 0;
    }

    // 2. Already launched in this session → nothing to do
    if (_serverLaunched) {
      print('X11 server already launched, skipping 👌');
      return 0;
    }

    // 3. Call the platform channel
    try {
      final result = await _channel.invokeMethod('launchXServer', {
        'tmpdir': tmpdir,
        'xkb': xkb,
        'xserverArgs': xserverArgs,
      });
      _serverLaunched = true;
      print('X11 server launched successfully 🎯');
      return result as int;
    } on PlatformException catch (e) {
      _logError('launchXServer', e);
      rethrow; // Do NOT set _serverLaunched – allows retry on failure
    }
  }

  // ---- Reset helpers (optional) ----
  /// Reset the guard so the X server can be re‑launched later.
  static void resetXServerState() {
    _serverLaunched = false;
  }

  // ---- All other methods (unchanged) ----
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