import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class LogcatManager {
  // Singleton instance
  static final LogcatManager _instance = LogcatManager._internal();
  factory LogcatManager() => _instance;
  LogcatManager._internal();

  // Variables similar to your Kotlin class
  static const String _tag = "LogcatManager";
  bool _isRunning = false;
  Process? _logcatProcess;
  IOSink? _logFileWriter;
  Timer? _healthCheckTimer;
  
  // File management
  Directory? _logDir;
  String? _currentLogFile;
  
  // For isolating heavy file operations
  final ReceivePort _receivePort = ReceivePort();
  Isolate? _logIsolate;
  
  // Public getter
  bool get isRunning => _isRunning;
  
  // Initialize - similar to Kotlin onCreate
  Future<void> initialize() async {
    print("[$_tag] Initializing LogcatManager...");
    
    // Get log directory
    _logDir = await getLogDirectory();
    
    // Log device info
    await _logDeviceInfo();
    
    // Clear old logs (optional)
    // await clearLogs();
    
    print("[$_tag] LogcatManager initialized. Log dir: ${_logDir?.path}");
  }
  
  // Get log directory - similar to Kotlin getLogDirectory()
  Future<Directory> getLogDirectory() async {
    try {
      // Try external storage first
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final logDir = Directory('${externalDir.path}/logs');
        if (!await logDir.exists()) {
          await logDir.create(recursive: true);
        }
        return logDir;
      }
    } catch (e) {
      print("[$_tag] Failed to get external storage: $e");
    }
    
    // Fall back to application documents
    final appDocDir = await getApplicationDocumentsDirectory();
    final logDir = Directory('${appDocDir.path}/logs');
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }
    return logDir;
  }
  
  // Log device info - similar to Kotlin logDeviceInfo()
  Future<void> _logDeviceInfo() async {
    try {
      final infoFile = File('${_logDir?.path}/device_info.txt');
      final sink = infoFile.openWrite(mode: FileMode.write);
      
      final now = DateTime.now();
      await sink.write('=== Device Information ===\n');
      await sink.write('Time: ${now.toIso8601String()}\n');
      await sink.write('Platform: ${Platform.operatingSystem}\n');
      await sink.write('OS Version: ${Platform.operatingSystemVersion}\n');
      await sink.write('Dart Version: ${Platform.version}\n');
      await sink.write('Local Hostname: ${Platform.localHostname}\n');
      await sink.write('Number of Processors: ${Platform.numberOfProcessors}\n');
      await sink.write('Executable: ${Platform.executable}\n');
      await sink.write('Resolved Executable: ${Platform.resolvedExecutable}\n');
      
      // Try to get Android-specific info if available
      if (Platform.isAndroid) {
        try {
          // You could run adb shell commands here if needed
          await sink.write('Is Android: true\n');
        } catch (e) {
          // Ignore if we can't get Android info
        }
      }
      
      await sink.close();
      print("[$_tag] Device info saved");
    } catch (e) {
      print("[$_tag] Failed to save device info: $e");
    }
  }
  
  // Start logcat capture - similar to Kotlin startLogcatCapture()
  Future<void> startCapture() async {
    if (_isRunning) {
      print("[$_tag] Logcat capture is already running");
      return;
    }
    
    try {
      print("[$_tag] Starting logcat capture...");
      
      // Create log file with timestamp
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      _currentLogFile = 'app_$timestamp.log';
      final logFile = File('${_logDir?.path}/$_currentLogFile');
      
      // Open file for writing
      _logFileWriter = logFile.openWrite(mode: FileMode.write);
      
      // Write header
      await _logFileWriter?.write('=== Logcat started at $timestamp ===\n');
      await _logFileWriter?.write('Device: ${Platform.localHostname}\n');
      await _logFileWriter?.write('=================================\n\n');
      await _logFileWriter?.flush();
      
      // Clear existing logs (optional)
      await _clearLogcatBuffer();
      
      // Start logcat process using PTY - JUST LIKE PULSEAUDIO!
      _logcatProcess = await Process.start(
        '/system/bin/logcat', 
        ['-v', 'time', '*:V'], // Format and verbosity
        runInShell: true,
      );
      
      // Set running flag
      _isRunning = true;
      
      // Listen to stdout (logcat output)
      _logcatProcess!.stdout.transform(utf8.decoder).listen(
        (data) {
          if (_isRunning && _logFileWriter != null) {
            _logFileWriter!.write(data);
            // Flush periodically
            if (data.contains('\n')) {
              _logFileWriter!.flush();
            }
          }
        },
        onError: (error) {
          print("[$_tag] Logcat stdout error: $error");
        },
        onDone: () {
          print("[$_tag] Logcat stdout stream closed");
        },
        cancelOnError: true,
      );
      
      // Listen to stderr
      _logcatProcess!.stderr.transform(utf8.decoder).listen(
        (data) {
          print("[$_tag] Logcat stderr: $data");
          if (_isRunning && _logFileWriter != null) {
            _logFileWriter!.write('[STDERR] $data');
          }
        },
      );
      
      // Check process health periodically
      _startHealthCheck();
      
      print("[$_tag] Logcat capture started successfully");
      
    } catch (e) {
      print("[$_tag] Failed to start logcat capture: $e");
      await _cleanup();
    }
  }
  
  // Clear logcat buffer - similar to Kotlin clearLogcat()
  Future<void> _clearLogcatBuffer() async {
    try {
      final clearProcess = await Process.run(
        '/system/bin/logcat', 
        ['-c'],
        runInShell: true,
      );
      if (clearProcess.exitCode == 0) {
        print("[$_tag] Logcat buffer cleared");
      } else {
        print("[$_tag] Failed to clear logcat buffer: ${clearProcess.stderr}");
      }
    } catch (e) {
      print("[$_tag] Error clearing logcat buffer: $e");
    }
  }
  
  // Health check timer
  void _startHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(Duration(seconds: 30), (timer) async {
      if (!_isRunning) {
        timer.cancel();
        return;
      }
      
      try {
        // Check if process is still alive
        final exitCode = await _logcatProcess?.exitCode.timeout(
          Duration(seconds: 1),
          onTimeout: () => null,
        );
        
        if (exitCode != null) {
          print("[$_tag] Logcat process died with exit code: $exitCode");
          await _cleanup();
          timer.cancel();
          
          // Optionally restart
          // await startCapture();
        }
      } catch (e) {
        print("[$_tag] Health check error: $e");
      }
    });
  }
  
  // Stop logcat capture - similar to Kotlin stopLogcatCapture()
  Future<void> stopCapture() async {
    if (!_isRunning) {
      return;
    }
    
    print("[$_tag] Stopping logcat capture...");
    
    // Set flag first to prevent new writes
    _isRunning = false;
    
    // Cancel health check
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
    
    // Kill process
    if (_logcatProcess != null) {
      try {
        _logcatProcess!.kill();
        await _logcatProcess!.exitCode.timeout(Duration(seconds: 2));
      } catch (e) {
        print("[$_tag] Error killing process: $e");
      }
      _logcatProcess = null;
    }
    
    // Close file writer
    if (_logFileWriter != null) {
      try {
        await _logFileWriter!.flush();
        await _logFileWriter!.close();
        _logFileWriter = null;
      } catch (e) {
        print("[$_tag] Error closing log file: $e");
      }
    }
    
    print("[$_tag] Logcat capture stopped");
  }
  
  // Cleanup resources
  Future<void> _cleanup() async {
    _isRunning = false;
    _healthCheckTimer?.cancel();
    
    if (_logcatProcess != null) {
      _logcatProcess!.kill();
      _logcatProcess = null;
    }
    
    if (_logFileWriter != null) {
      try {
        await _logFileWriter!.flush();
        await _logFileWriter!.close();
      } catch (e) {
        // Ignore errors during cleanup
      }
      _logFileWriter = null;
    }
  }
  
  // Clear logs - similar to Kotlin clearLogs()
  Future<bool> clearLogs() async {
    try {
      if (_logDir != null && await _logDir!.exists()) {
        final files = await _logDir!.list().toList();
        int deletedCount = 0;
        
        for (var file in files) {
          if (file is File && 
              (file.path.endsWith('.log') || file.path.endsWith('.txt'))) {
            await file.delete();
            deletedCount++;
          }
        }
        
        print("[$_tag] Cleared $deletedCount log files");
        return true;
      }
    } catch (e) {
      print("[$_tag] Failed to clear logs: $e");
    }
    return false;
  }
  
  // Get log files - similar to Kotlin getLogFiles()
  Future<List<String>> getLogFiles() async {
    try {
      if (_logDir != null && await _logDir!.exists()) {
        final files = await _logDir!.list().toList();
        return files
            .where((file) => file is File && 
                (file.path.endsWith('.log') || file.path.endsWith('.txt')))
            .map((file) => file.path.split('/').last)
            .toList();
      }
    } catch (e) {
      print("[$_tag] Failed to get log files: $e");
    }
    return [];
  }
  
  // Read log file - similar to Kotlin readLogFile()
  Future<String?> readLogFile(String filename) async {
    try {
      final file = File('${_logDir?.path}/$filename');
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (e) {
      print("[$_tag] Failed to read log file: $filename, error: $e");
    }
    return null;
  }
  
  // Cleanup on dispose
  Future<void> dispose() async {
    await stopCapture();
    _receivePort.close();
    _logIsolate?.kill(priority: Isolate.immediate);
    print("[$_tag] LogcatManager disposed");
  }
}