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

  // Get EXTERNAL storage directory - PHONE STORAGE
  Future<Directory> getLogDirectory() async {
    try {
      // First try external storage (phone storage)
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        // Create path: /storage/emulated/0/Android/data/com.xodos/files/logs
        final logDir = Directory('${externalDir.path}/logs');
        if (!await logDir.exists()) {
          await logDir.create(recursive: true);
        }
        return logDir;
      }
    } catch (e) {
      print("Failed to get external storage: $e");
    }
    
    // Fallback to internal storage if external fails
    final appDocDir = await getApplicationDocumentsDirectory();
    final logDir = Directory('${appDocDir.path}/logs');
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }
    return logDir;
  }

  // Get the readable path for display
  Future<String> getLogPath() async {
    final dir = await getLogDirectory();
    return dir.path;
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
      
      // Create log file with timestamp
      final now = DateTime.now();
      final timestamp = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}";
      final logFile = File('${logDir.path}/xodos_$timestamp.log');
      
      print("Saving logs to: ${logFile.path}");
      
      // Start logcat process
      _logcatProcess = await Process.start(
        '/system/bin/logcat', 
        ['-v', 'time', '*:V'],  // time format, verbose
        runInShell: true,
      );
      
      _isRunning = true;
      
      // Write header to file
      final sink = logFile.openWrite(mode: FileMode.write);
      sink.write('=== XoDos Logcat Capture ===\n');
      sink.write('Started: ${now.toIso8601String()}\n');
      sink.write('Device: ${Platform.localHostname}\n');
      sink.write('=================================\n\n');
      await sink.flush();
      
      // Listen to stdout and write to file
      _logcatProcess!.stdout.listen(
        (data) {
          sink.add(data);
        },
        onDone: () async {
          await sink.flush();
          await sink.close();
          _isRunning = false;
          print("Logcat capture completed");
        },
        onError: (error) {
          print("Logcat stdout error: $error");
          sink.write('[ERROR] $error\n');
        },
      );
      
      // Listen to stderr
      _logcatProcess!.stderr.listen(
        (data) {
          final error = String.fromCharCodes(data);
          print("Logcat stderr: $error");
          sink.write('[STDERR] $error\n');
        },
      );
      
      // Check process health
      _logcatProcess!.exitCode.then((code) {
        print("Logcat process exited with code: $code");
        _isRunning = false;
      });
      
      print("Logcat capture started successfully");
      
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
      await _logcatProcess!.exitCode;
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
        print("Cleared $deletedCount log files from ${logDir.path}");
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
        // Sort by modification time (newest first)
        final fileList = files.whereType<File>().where((f) => f.path.endsWith('.log')).toList();
        fileList.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
        return fileList.map((file) => file.path.split('/').last).toList();
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