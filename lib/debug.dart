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

  // Get log directory
  Future<Directory> getLogDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final logDir = Directory('${appDocDir.path}/logs');
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }
    return logDir;
  }

  // Start logcat capture
  Future<void> startCapture() async {
    if (_isRunning) {
      print("Logcat already running");
      return;
    }

    try {
      print("Starting logcat capture...");
      
      // Clear logcat buffer
      await _clearLogcatBuffer();
      
      // Get directory
      final logDir = await getLogDirectory();
      
      // Create log file
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final logFile = File('${logDir.path}/app_$timestamp.log');
      
      // Start process
      _logcatProcess = await Process.start(
        '/system/bin/logcat', 
        ['-v', 'time'],
        runInShell: true,
      );
      
      _isRunning = true;
      
      // Write to file
      final file = await logFile.open(mode: FileMode.write);
      
      _logcatProcess!.stdout.listen(
        (data) {
          file.writeFromSync(data);
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

  // Clear logcat buffer
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

  // Stop logcat capture
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

  // Clear all logs
  Future<bool> clearLogs() async {
    try {
      final logDir = await getLogDirectory();
      if (await logDir.exists()) {
        final files = await logDir.list().toList();
        int deletedCount = 0;
        for (var file in files) {
          if (file is File && file.path.endsWith('.log')) {
            await file.delete();
            deletedCount++;
          }
        }
        print("Cleared $deletedCount log files");
        return deletedCount > 0;
      }
    } catch (e) {
      print("Failed to clear logs: $e");
    }
    return false;
  }

  // Get log files
  Future<List<String>> getLogFiles() async {
    try {
      final logDir = await getLogDirectory();
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

  // Read log file
  Future<String?> readLogFile(String filename) async {
    try {
      final logDir = await getLogDirectory();
      final file = File('${logDir.path}/$filename');
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (e) {
      print("Failed to read log file: $filename, error: $e");
    }
    return null;
  }

  Future<void> dispose() async {
    await stopCapture();
  }
}