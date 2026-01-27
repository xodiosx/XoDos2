import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LogcatManager {
  static final LogcatManager _instance = LogcatManager._internal();
  factory LogcatManager() => _instance;
  LogcatManager._internal();

  Process? _logcatProcess;
  bool _isRunning = false;
  
  bool get isRunning => _isRunning;

  // Start logcat capture - EXACTLY LIKE KOTLIN
  Future<void> startCapture() async {
    if (_isRunning) {
      print("Logcat already running");
      return;
    }

    try {
      print("Starting logcat capture...");
      
      // Clear logcat buffer - EXACTLY LIKE KOTLIN
      await _clearLogcatBuffer();
      
      // Get directory for logs
      final appDocDir = await getApplicationDocumentsDirectory();
      final logDir = Directory('${appDocDir.path}/logs');
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }
      
      // Create log file
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final logFile = File('${logDir.path}/app_$timestamp.log');
      
      // Start logcat process - EXACTLY LIKE KOTLIN
      _logcatProcess = await Process.start(
        '/system/bin/logcat', 
        ['-v', 'time'],  // time format
        runInShell: true,
      );
      
      _isRunning = true;
      
      // Write to file - EXACTLY LIKE KOTLIN
      final file = await logFile.open(mode: FileMode.write);
      
      _logcatProcess!.stdout.listen(
        (data) {
          file.writeFrom(data);
        },
        onDone: () async {
          await file.close();
          _isRunning = false;
        },
        onError: (error) {
          print("Logcat stdout error: $error");
        },
      );
      
      _logcatProcess!.stderr.listen(
        (data) {
          print("Logcat stderr: ${String.fromCharCodes(data)}");
        },
      );
      
      print("Logcat capture started");
      
    } catch (e) {
      print("Failed to start logcat: $e");
      _isRunning = false;
    }
  }

  // Clear logcat buffer - EXACTLY LIKE KOTLIN
  Future<void> _clearLogcatBuffer() async {
    try {
      final clearProcess = await Process.run(
        '/system/bin/logcat', 
        ['-c'],
        runInShell: true,
      );
      if (clearProcess.exitCode == 0) {
        print("Logcat buffer cleared");
      } else {
        print("Failed to clear logcat buffer: ${clearProcess.stderr}");
      }
    } catch (e) {
      print("Error clearing logcat buffer: $e");
    }
  }

  // Stop logcat capture - EXACTLY LIKE KOTLIN
  Future<void> stopCapture() async {
    if (!_isRunning) return;
    
    print("Stopping logcat...");
    _isRunning = false;
    
    if (_logcatProcess != null) {
      _logcatProcess!.kill();
      _logcatProcess = null;
    }
    
    print("Logcat stopped");
  }

  // Clear all logs - EXACTLY LIKE KOTLIN
  Future<bool> clearLogs() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final logDir = Directory('${appDocDir.path}/logs');
      
      if (await logDir.exists()) {
        final files = await logDir.list().toList();
        for (var file in files) {
          if (file is File && file.path.endsWith('.log')) {
            await file.delete();
          }
        }
        return true;
      }
    } catch (e) {
      print("Failed to clear logs: $e");
    }
    return false;
  }

  // Get log files - EXACTLY LIKE KOTLIN
  Future<List<String>> getLogFiles() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final logDir = Directory('${appDocDir.path}/logs');
      
      if (await logDir.exists()) {
        final files = await logDir.list().toList();
        return files
            .where((file) => file is File && file.path.endsWith('.log'))
            .map((file) => file.path.split('/').last)
            .toList();
      }
    } catch (e) {
      print("Failed to get log files: $e");
    }
    return [];
  }

  Future<void> dispose() async {
    await stopCapture();
  }
}