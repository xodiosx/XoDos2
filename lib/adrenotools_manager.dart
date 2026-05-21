import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:archive/archive.dart'; // for ZIP extraction
import 'package:path_provider/path_provider.dart';

class AdrenotoolsDriverManager {
  static const String _hooksDirName = 'drivers'; // where hooks + drivers live
  static const String _optDrvPath = '/data/data/com.xodos/files/usr/opt/drv'; // GPU env file

  late final Directory _baseDir;
  late final Directory _hooksDir;

  AdrenotoolsDriverManager._(); // use factory

  /// Initialize the manager and ensure hook libraries are present.
  static Future<AdrenotoolsDriverManager> initialize() async {
    final instance = AdrenotoolsDriverManager._();
    final appDir = await getApplicationSupportDirectory();
    instance._baseDir = Directory('${appDir.path}/adrenotools');
    instance._hooksDir = Directory('${instance._baseDir.path}/${_hooksDirName}');
    await instance._hooksDir.create(recursive: true);
    await instance._extractHookLibraries();
    return instance;
  }

  // ------------------------------------------------------------------ helpers

  /// List of required hook .so files (from adrenotools build).
  static const List<String> _hookLibs = [
    'libhook_impl.so',
    'libmain_hook.so',
    'libfile_redirect_hook.so',   // optional but safe to include
    'libgsl_alloc_hook.so',
  ];

  /// Copy hook libraries from assets to the hooks directory.
  Future<void> _extractHookLibraries() async {
    for (final lib in _hookLibs) {
      final target = File('${_hooksDir.path}/$lib');
      if (target.existsSync()) continue; // skip if already present
      try {
        final data = await rootBundle.load('assets/adrenotools/$lib');
        await target.writeAsBytes(data.buffer.asUint8List(), flush: true);
      } catch (e) {
        // Some hook libs may not be needed (e.g., file_redirect_hook).
        debugPrint('AdrenotoolsManager: warning – $lib not found in assets, skipping');
      }
    }
  }

  // ---------------------------------------------------------- driver listing

  /// Returns a list of installed driver metadata.
  List<DriverMeta> getInstalledDrivers() {
    if (!_hooksDir.existsSync()) return [];
    final drivers = <DriverMeta>[];
    for (final dir in _hooksDir.listSync().whereType<Directory>()) {
      final metaFile = File('${dir.path}/meta.json');
      if (metaFile.existsSync()) {
        try {
          final meta = DriverMeta.fromJson(jsonDecode(metaFile.readAsStringSync()));
          drivers.add(meta);
        } catch (_) {}
      }
    }
    return drivers;
  }

  // --------------------------------------------------- install / uninstall

  /// Extract a driver ZIP (supplied as bytes) and return metadata.
  /// The ZIP must contain a `meta.json` with `name`, `libraryName`, etc.
  Future<DriverMeta> installDriver(Uint8List zipBytes) async {
    // Create a temporary folder for extraction
    final tmpDir = Directory('${_baseDir.path}/tmp_${DateTime.now().millisecondsSinceEpoch}');
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
        await driverDir.delete(recursive: true); // overwrite existing
      }
      await tmpDir.rename(driverDir.path);

      return meta;
    } catch (e) {
      // Clean up temp
      if (tmpDir.existsSync()) tmpDir.delete(recursive: true);
      rethrow;
    }
  }

  /// Remove a driver by its name (the folder name).
  Future<void> uninstallDriver(String driverName) async {
    final dir = Directory('${_hooksDir.path}/$driverName');
    if (dir.existsSync()) await dir.delete(recursive: true);
  }

  // ------------------------------------------------------ activation

  /// Set the given driver as active.
  /// This writes the necessary environment variables to the `opt/drv` file
  /// that your terminal scripts source before running Vulkan applications.
  /// Also creates a file‑redirect directory if needed.
  Future<void> setActiveDriver(DriverMeta meta) async {
    final driverPath = '${_hooksDir.path}/${meta.name}/';
    final hooksPath = _hooksDir.path;
    final libraryName = meta.libraryName;

    // File redirection directory (optional but recommended)
    final redirectDir = Directory('${_baseDir.path}/driver_files');
    if (!redirectDir.existsSync()) redirectDir.create(recursive: true);

    // Build the environment block for the opt/drv file
    final envBlock = '''
# Adrenotools custom driver
export ADRENOTOOLS_DRIVER_PATH="$driverPath"
export ADRENOTOOLS_DRIVER_NAME="$libraryName"
export ADRENOTOOLS_HOOKS_PATH="$hooksPath"
export ADRENOTOOLS_FILE_REDIRECT_DIR="${redirectDir.path}"
export VK_ICD_FILENAMES=/data/data/com.xodos/files/usr/share/vulkan/icd.d/wrapper_icd.aarch64.json
''';

    // Read existing opt/drv (if any) and replace or append
    final drvFile = File(_optDrvPath);
    String existing = '';
    if (drvFile.existsSync()) {
      existing = drvFile.readAsStringSync();
      // Remove any previous adrenotools block (from '# Adrenotools' to the next blank line or end)
      existing = existing.replaceAll(RegExp(r'^# Adrenotools custom driver.*?(?:\n\n|\n?$)', multiLine: true), '');
    }
    await drvFile.writeAsString(existing + envBlock);
  }

  /// Switch back to system driver (clears custom driver vars).
  Future<void> setSystemDriver() async {
    final drvFile = File(_optDrvPath);
    if (!drvFile.existsSync()) return;
    String content = drvFile.readAsStringSync();
    content = content.replaceAll(RegExp(r'^# Adrenotools custom driver.*?(?:\n\n|\n?$)', multiLine: true), '');
    await drvFile.writeAsString(content);
  }
}

/// Simple model for driver metadata (matches the meta.json format).
class DriverMeta {
  final String name;
  final String author;
  final String packageVersion;
  final String vendor;
  final String driverVersion;
  final int minApi;
  final String description;
  final String libraryName;

  DriverMeta({
    required this.name,
    required this.author,
    required this.packageVersion,
    required this.vendor,
    required this.driverVersion,
    required this.minApi,
    required this.description,
    required this.libraryName,
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