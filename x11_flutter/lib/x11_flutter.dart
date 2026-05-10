import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class X11Flutter {
  static const MethodChannel _channel = MethodChannel('x11_flutter');

  /// Check if termux-x11 process is running using shell
  static Future<bool> isX11Running() async {
    try {
      // Try pgrep first (cleanest)
      final result = await Process.run(
        '/data/data/com.xodos/files/usr/bin/sh',
        ['-c', 'pgrep -f termux-x11'],
        runInShell: true,
      );

      if (result.exitCode == 0 && result.stdout.toString().trim().isNotEmpty) {
        print("X11 process found via pgrep ✅");
        return true;
      }

      // Fallback: use ps + grep
      final psResult = await Process.run(
        '/data/data/com.xodos/files/usr/bin/sh',
        ['-c', 'ps -A | grep termux-x11'],
        runInShell: true,
      );

      final output = psResult.stdout.toString();

      if (output.contains('termux-x11') && !output.contains('grep')) {
        print("X11 process found via ps/grep ✅");
        return true;
      }

      print("X11 not running ❌");
      return false;
    } catch (e) {
      print("Process check failed: $e");
      return false;
    }
  }


static Future<int> launchXServer(
  String tmpdir,
  String xkb,
  List<String> xserverArgs,
) async {
  return await launchXServerSafe(tmpdir, xkb, xserverArgs);
}
  /// Launch X11 safely with retry logic
  static Future<int> launchXServerSafe(
    String tmpdir,
    String xkb,
    List<String> xserverArgs,
  ) async {
    const int maxAttempts = 3; // ~6 sec
    const Duration delay = Duration(seconds: 2);

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final running = await isX11Running();

      if (running) {
        print("X11 already running, skipping 🚫");
        return 0;
      }

      print("Launching X11 (attempt ${attempt + 1}) 🚀");

      try {
        final result = await _channel.invokeMethod('launchXServer', {
          'tmpdir': tmpdir,
          'xkb': xkb,
          'xserverArgs': xserverArgs,
        });

        // Give it time to spawn
        await Future.delayed(delay);

        if (await isX11Running()) {
          print("X11 started successfully 🎯");
          return result as int;
        }
      } on PlatformException catch (e) {
        _logError('launchXServer', e);
      }

      await Future.delayed(delay);
    }

    throw Exception("X11 failed to start after timeout ❌");
  }

  /// Optional: direct shell launcher (if you want to bypass MethodChannel)
  static Future<void> launchXServerViaShell() async {
    try {
      final process = await Process.start(
        '/data/data/com.xodos/files/usr/bin/sh',
        ['-c', 'termux-x11 :4 -ac &'],
        runInShell: true,
      );

      print("Shell X11 launch started (PID: ${process.pid})");
    } catch (e) {
      print("Shell launch failed: $e");
    }
  }

  /// Existing methods
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