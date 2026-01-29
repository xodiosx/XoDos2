import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LogcatManager {
  static final LogcatManager _instance = LogcatManager._internal();
  factory LogcatManager() => _instance;
  LogcatManager._internal();

  Process? _logcatProcess;
  IOSink? _sink;
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  // Get EXTERNAL storage directory - PHONE STORAGE
  Future<Directory> getLogDirectory() async {
    try {
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final logDir = Directory('${externalDir.path}/logs');
        if (!await logDir.exists()) {
          await logDir.create(recursive: true);
        }
        return logDir;
      }
    } catch (e) {
      print("Failed to get external storage: $e");
    }

    final appDocDir = await getApplicationDocumentsDirectory();
    final logDir = Directory('${appDocDir.path}/logs');
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }
    return logDir;
  }

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

      await _clearLogcatBuffer();

      final logDir = await getLogDirectory();
      final now = DateTime.now();
      final timestamp =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}";
      final logFile = File('${logDir.path}/xodos_$timestamp.log');

      print("Saving logs to: ${logFile.path}");

      _logcatProcess = await Process.start(
        '/system/bin/logcat',
        ['-v', 'time', '*:V'],
        runInShell: true,
      );

      _isRunning = true;
      _sink = logFile.openWrite(mode: FileMode.write);

      // Write header
      _sink!.writeln('=== XoDos Logcat Capture ===');
      _sink!.writeln('Started: ${now.toIso8601String()}');
      _sink!.writeln('Device: ${Platform.localHostname}');
      _sink!.writeln('=================================\n');
      await _sink!.flush();

      // Handle stdout
      _logcatProcess!.stdout.listen(
        (data) {
          _sink?.add(data);
        },
        onError: (error) {
          print("Logcat stdout error: $error");
          _sink?.writeln('[ERROR] $error');
        },
      );

      // Handle stderr
      _logcatProcess!.stderr.listen(
        (data) {
          final error = String.fromCharCodes(data);
          print("Logcat stderr: $error");
          _sink?.writeln('[STDERR] $error');
        },
      );

      // Handle process exit
      _logcatProcess!.exitCode.then((code) async {
        print("Logcat process exited with code: $code");
        await _sink?.flush();
        await _sink?.close();
        _sink = null;
        _logcatProcess = null;
        _isRunning = false;
        print("Logcat capture completed");
      });

      print("Logcat capture started successfully");
    } catch (e) {
      print("Failed to start logcat: $e");
      _isRunning = false;
      await _sink?.close();
      _sink = null;
    }
  }

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

  Future<void> stopCapture() async {
    if (!_isRunning) return;

    print("Stopping logcat...");
    _isRunning = false;

    if (_logcatProcess != null) {
      _logcatProcess!.kill(ProcessSignal.sigkill);
      await _logcatProcess!.exitCode;
      _logcatProcess = null;
    }

    if (_sink != null) {
      await _sink!.flush();
      await _sink!.close();
      _sink = null;
    }

    print("Logcat stopped");
  }

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

  Future<List<String>> getLogFiles() async {
    try {
      final logDir = await getLogDirectory();
      if (await logDir.exists()) {
        final files = await logDir.list().toList();
        final fileList =
            files.whereType<File>().where((f) => f.path.endsWith('.log')).toList();
        fileList.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
        return fileList.map((file) => file.path.split('/').last).toList();
      }
    } catch (e) {
      print("Failed to get log files: $e");
    }
    return [];
  }

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