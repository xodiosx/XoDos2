import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DriverMeta {
  final String name;
  final String author;
  final String packageVersion;
  final String vendor;
  final String driverVersion;
  final int minApi;
  final String description;
  final String libraryName;
  String path = '';

  DriverMeta({
    required this.name,
    required this.author,
    required this.packageVersion,
    required this.vendor,
    required this.driverVersion,
    required this.minApi,
    required this.description,
    required this.libraryName,
    this.path = '',
  });

  factory DriverMeta.fromJson(Map<String, dynamic> json) {
    return DriverMeta(
      name: json['name'] as String,
      author: json['author'] as String? ?? '',
      packageVersion: json['packageVersion'] as String? ?? '',
      vendor: json['vendor'] as String? ?? '',
      driverVersion: json['driverVersion'] as String? ?? '',
      minApi: json['minApi'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      libraryName: json['libraryName'] as String,
    );
  }
}

class AdrenotoolsDriverManager {
  static const String _hooksDirName = 'drivers';   // for custom driver folders
  static const String _prefsActiveDriverKey = 'active_driver_name';
  static const MethodChannel _androidChannel = MethodChannel('android');

  late final Directory _baseDir;
  late final Directory _driversDir;          // where driver packages are stored
  late final String _hooksDir;               // nativeLibraryDir
  late final SharedPreferences _prefs;

  AdrenotoolsDriverManager._();

  static Future<AdrenotoolsDriverManager> initialize() async {
    final instance = AdrenotoolsDriverManager._();
    final appDir = await getApplicationSupportDirectory();
    instance._baseDir = Directory('${appDir.path}/adrenotools');
    instance._driversDir = Directory('${instance._baseDir.path}/${_hooksDirName}');
    await instance._driversDir.create(recursive: true);
    instance._prefs = await SharedPreferences.getInstance();

    // Get the native library directory where hook .so files are installed
    final nativeLibDir = await instance._getNativeLibraryDir();
    instance._hooksDir = nativeLibDir;
    return instance;
  }

  /// Queries the Android system for the native library directory
  Future<String> _getNativeLibraryDir() async {
    try {
      final result = await _androidChannel.invokeMethod('getNativeLibraryPath');
      if (result is String && result.isNotEmpty) return result;
    } catch (e) {
      debugPrint('Failed to get native library dir: $e');
    }
    // Fallback – unlikely to work but safe
    return '/data/app/${await getPackageName()}/lib/arm64';
  }

  Future<String> getPackageName() async {
    // Simple approach: read from /data/data/... or use a package_info plugin
    // For now we can just return the known package name
    return 'com.xodos';
  }

  /// Directory where hook libraries are installed (pass this to the loader).
  String get hooksDir => _hooksDir;

  /// Returns a list of installed custom drivers.
  List<DriverMeta> getInstalledDrivers() {
    if (!_driversDir.existsSync()) return [];
    final drivers = <DriverMeta>[];
    for (final dir in _driversDir.listSync().whereType<Directory>()) {
      final metaFile = File('${dir.path}/meta.json');
      if (metaFile.existsSync()) {
        try {
          final meta = DriverMeta.fromJson(jsonDecode(metaFile.readAsStringSync()));
          meta.path = dir.path + '/';
          drivers.add(meta);
        } catch (_) {}
      }
    }
    return drivers;
  }

  /// Returns the metadata of the currently active driver.
  DriverMeta? getActiveDriverMeta() {
    final activeName = _prefs.getString(_prefsActiveDriverKey);
    if (activeName == null) return null;
    final driverDir = Directory('${_driversDir.path}/$activeName');
    final metaFile = File('${driverDir.path}/meta.json');
    if (!metaFile.existsSync()) return null;
    try {
      final meta = DriverMeta.fromJson(jsonDecode(metaFile.readAsStringSync()));
      meta.path = driverDir.path + '/';
      return meta;
    } catch (_) {
      return null;
    }
  }

  /// Save the active driver name to preferences.
  Future<void> setActiveDriver(DriverMeta meta) async {
  await _prefs.setString(_prefsActiveDriverKey, meta.name);

  // Write the active driver file that JNI_OnLoad will read at process startup
  final file = File('/data/data/com.xodos/files/active_driver.txt');
  await file.parent.create(recursive: true);
  // Three lines: driverDir, libraryName, hooksDir
  await file.writeAsString('${meta.path}\n${meta.libraryName}\n$hooksDir');
}

  /// Clear the active driver (system driver).
  Future<void> setSystemDriver() async {
  await _prefs.remove(_prefsActiveDriverKey);
  final file = File('/data/data/com.xodos/files/active_driver.txt');
  if (await file.exists()) await file.delete();
}

  // --------------------------------------------------- install / uninstall

  /// Extract a driver ZIP (bytes) and return metadata.
  Future<DriverMeta> installDriver(Uint8List zipBytes) async {
    final tmpDir = Directory('${_baseDir.path}/tmp_${DateTime.now().millisecondsSinceEpoch}');
    await tmpDir.create(recursive: true);

    try {
      final archive = ZipDecoder().decodeBytes(zipBytes);
      for (final file in archive) {
        if (file.isFile) {
          final outFile = File('${tmpDir.path}/${file.name}');
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        }
      }

      final metaFile = File('${tmpDir.path}/meta.json');
      if (!metaFile.existsSync()) throw Exception('Missing meta.json');
      final meta = DriverMeta.fromJson(jsonDecode(metaFile.readAsStringSync()));

      final driverFile = File('${tmpDir.path}/${meta.libraryName}');
      if (!driverFile.existsSync()) throw Exception('Driver file ${meta.libraryName} not found');

      final driverDir = Directory('${_driversDir.path}/${meta.name}');
      if (driverDir.existsSync()) await driverDir.delete(recursive: true);
      await tmpDir.rename(driverDir.path);

      meta.path = driverDir.path + '/';
      return meta;
    } catch (e) {
      if (tmpDir.existsSync()) tmpDir.delete(recursive: true);
      rethrow;
    }
  }

  /// Remove a driver by its folder name.
  Future<void> uninstallDriver(String driverName) async {
    final dir = Directory('${_driversDir.path}/$driverName');
    if (dir.existsSync()) await dir.delete(recursive: true);

    final activeName = _prefs.getString(_prefsActiveDriverKey);
    if (activeName == driverName) {
      await _prefs.remove(_prefsActiveDriverKey);
    }
  }
}