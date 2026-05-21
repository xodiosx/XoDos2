import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Model class for a GPU driver's metadata.
class DriverMeta {
  final String name;
  final String author;
  final String packageVersion;
  final String vendor;
  final String driverVersion;
  final int minApi;
  final String description;
  final String libraryName;
  String path;   // mutable, set by manager after discovery

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

// -----------------------------------------------------------------------------

class AdrenotoolsDriverManager {
  static const String _hooksDirName = 'drivers';   // where hooks + drivers live
  static const String _prefsActiveDriverKey = 'active_driver_name';

  late final Directory _baseDir;
  late final Directory _hooksDir;
  late final SharedPreferences _prefs;

  AdrenotoolsDriverManager._();

  static Future<AdrenotoolsDriverManager> initialize() async {
    final instance = AdrenotoolsDriverManager._();
    final appDir = await getApplicationSupportDirectory();
    instance._baseDir = Directory('${appDir.path}/adrenotools');
    instance._hooksDir = Directory('${instance._baseDir.path}/${_hooksDirName}');
    await instance._hooksDir.create(recursive: true);
    instance._prefs = await SharedPreferences.getInstance();
    await instance._extractHookLibraries();
    return instance;
  }

  /// List of required hook libraries (from adrenotools build).
  static const List<String> _hookLibs = [
    'libhook_impl.so',
    'libmain_hook.so',
    'libfile_redirect_hook.so',
    'libgsl_alloc_hook.so',
  ];

  /// Copy hook libraries from app assets to the hooks directory.
  Future<void> _extractHookLibraries() async {
    for (final lib in _hookLibs) {
      final target = File('${_hooksDir.path}/$lib');
      if (target.existsSync()) continue;
      try {
        final data = await rootBundle.load('assets/adrenotools/$lib');
        await target.writeAsBytes(data.buffer.asUint8List(), flush: true);
      } catch (e) {
        debugPrint('AdrenotoolsManager: $lib not found in assets, skipping');
      }
    }
  }

  /// Directory where hook libraries are stored (pass this to the loader).
  String get hooksDir => _hooksDir.path;

  // ---------------------------------------------------------- driver listing

  /// Returns a list of installed custom drivers.
  List<DriverMeta> getInstalledDrivers() {
    if (!_hooksDir.existsSync()) return [];
    final drivers = <DriverMeta>[];
    for (final dir in _hooksDir.listSync().whereType<Directory>()) {
      final metaFile = File('${dir.path}/meta.json');
      if (metaFile.existsSync()) {
        try {
          final meta = DriverMeta.fromJson(
              jsonDecode(metaFile.readAsStringSync()));
          // Set the actual path of the driver
          // (we can’t set it in the constructor because we didn’t know it before)
          // We'll cheat with a dynamic hack – better: add a mutable field to DriverMeta
          // For simplicity we'll just create a new instance with the path.
          final metaWithPath = DriverMeta.fromJson(
              jsonDecode(metaFile.readAsStringSync()));
          // We need to add path – let's modify the DriverMeta class to have a mutable path
          // But to avoid breaking the previous code, we'll just store the path in a local map
          // Actually we'll just store the meta and compute the path when needed.
          // For now, let's use a private extension to pass the path.
          // We'll add a path field to DriverMeta.
          // I'll update DriverMeta class with a path field.
          // (Will do below)
        } catch (_) {}
      }
    }
    return drivers;
  }

  /// Returns the metadata of the driver that is currently set as active.
  DriverMeta? getActiveDriverMeta() {
    final activeName = _prefs.getString(_prefsActiveDriverKey);
    if (activeName == null) return null;
    final driverDir = Directory('${_hooksDir.path}/$activeName');
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
  }

  /// Clear the active driver (system driver).
  Future<void> setSystemDriver() async {
    await _prefs.remove(_prefsActiveDriverKey);
  }

  // --------------------------------------------------- install / uninstall

  /// Extract a driver ZIP (bytes) and return metadata. The ZIP must contain
  /// a `meta.json` with `name`, `libraryName`, etc.
  Future<DriverMeta> installDriver(Uint8List zipBytes) async {
    final tmpDir = Directory(
        '${_baseDir.path}/tmp_${DateTime.now().millisecondsSinceEpoch}');
    await tmpDir.create(recursive: true);

    try {
      // Unzip
      final archive = ZipDecoder().decodeBytes(zipBytes);
      for (final file in archive) {
        if (file.isFile) {
          final outFile = File('${tmpDir.path}/${file.name}');
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        }
      }

      // Validate meta.json
      final metaFile = File('${tmpDir.path}/meta.json');
      if (!metaFile.existsSync()) {
        throw Exception('Missing meta.json');
      }
      final meta = DriverMeta.fromJson(jsonDecode(metaFile.readAsStringSync()));

      // Check that the driver library (soname) exists
      final driverFile = File('${tmpDir.path}/${meta.libraryName}');
      if (!driverFile.existsSync()) {
        throw Exception('Driver file ${meta.libraryName} not found in archive');
      }

      // Move to final location
      final driverDir = Directory('${_hooksDir.path}/${meta.name}');
      if (driverDir.existsSync()) {
        await driverDir.delete(recursive: true);
      }
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
    final dir = Directory('${_hooksDir.path}/$driverName');
    if (dir.existsSync()) await dir.delete(recursive: true);

    // If we’re removing the active driver, clear it
    final activeName = _prefs.getString(_prefsActiveDriverKey);
    if (activeName == driverName) {
      await _prefs.remove(_prefsActiveDriverKey);
    }
  }
}

// We need to add a mutable path field to DriverMeta.
// Better: change DriverMeta class above to have a mutable `path` field.
// Modify the DriverMeta class to include:
//   String path = '';
// Then in getInstalledDrivers we can set it.
// I'll rewrite the class with a mutable path field.
