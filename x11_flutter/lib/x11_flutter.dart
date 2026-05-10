import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class X11Flutter {
  static const MethodChannel _channel = MethodChannel('x11_flutter');

  /// Launch X11, but first check if any termux-x11 process is already running.
  /// Retries up to 3 times with 2‑second pauses.
  static Future<int> launchXServer(
    String tmpdir,
    String xkb,
    List<String> xserverArgs,
  ) async {
    const int maxAttempts = 3;
    const Duration delay = Duration(seconds: 2);

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      // 1. Check if X11 is already running anywhere
      if (await isX11Running()) {
        print('✅ X11 already running, skipping launch');
        return 0; // Already running – success
      }

      print('🚀 Launching X11 (attempt ${attempt + 1}/$maxAttempts)');

      // 2. Call the platform channel (your original native method)
      try {
        final result = await _channel.invokeMethod('launchXServer', {
          'tmpdir': tmpdir,
          'xkb': xkb,
          'xserverArgs': xserverArgs,
        });

        // 3. Wait for the process to start
        await Future.delayed(delay);

        // 4. Verify a process now exists (any termux-x11)
        if (await isX11Running()) {
          print('🎯 X11 started successfully (channel returned: $result)');
          return result as int;
        } else {
          print('⚠️ Channel returned OK, but no X11 process found – retrying...');
        }
      } on PlatformException catch (e) {
        _logError('launchXServer attempt $attempt', e);
      }

      // Wait before next attempt (except after the last)
      if (attempt < maxAttempts - 1) {
        await Future.delayed(delay);
      }
    }

    throw Exception('❌ X11 failed to start after $maxAttempts attempts');
  }

  /// Returns `true` if *any* `termux-x11` process is currently running.
  static Future<bool> isX11Running() async {
    try {
      // Use pgrep first (cleanest)
      final result = await Process.run(
        '/data/data/com.xodos/files/usr/bin/sh',
        ['-c', 'pgrep -f termux-x11'],
        runInShell: true,
      );

      if (result.exitCode == 0 && result.stdout.toString().trim().isNotEmpty) {
        print('✅ X11 process found via pgrep');
        return true;
      }

      // Fallback: ps + grep
      final psResult = await Process.run(
        '/data/data/com.xodos/files/usr/bin/sh',
        ['-c', 'ps -A | grep termux-x11'],
        runInShell: true,
      );
      final output = psResult.stdout.toString();

      if (output.contains('termux-x11') && !output.contains('grep')) {
        print('✅ X11 process found via ps/grep');
        return true;
      }

      print('❌ X11 not running');
      return false;
    } catch (e) {
      print('isX11Running error: $e');
      return false;
    }
  }

  // ---------- All other original methods (unchanged) ----------
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