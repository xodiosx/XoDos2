import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core_classes.dart';  // so we can use Util.copyAsset



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
  static const String _prefsActiveDriverKey = 'active_driver_name';

  // Path inside the proot prefix (the rootfs)
  static const String _prefixPath = '/data/data/com.xodos/files/usr';
  static const String _driversDirName = 'drivers';   // relative to prefix
  static const String _optDrvFile = '/data/data/com.xodos/files/usr/opt/drv';

  late final Directory _baseDir;      // Android external dir, not used much
  late final Directory _driversDir;   // full path: prefix/drivers/
  late final SharedPreferences _prefs;

  AdrenotoolsDriverManager._();

  static Future<AdrenotoolsDriverManager> initialize() async {
    final instance = AdrenotoolsDriverManager._();
    final appDir = await getApplicationSupportDirectory();
    instance._baseDir = Directory('${appDir.path}/adrenotools');
    await instance._baseDir.create(recursive: true);

    // The actual drivers folder inside the proot rootfs
    instance._driversDir = Directory('$_prefixPath/$_driversDirName');
    await instance._driversDir.create(recursive: true);

    instance._prefs = await SharedPreferences.getInstance();
    return instance;
  }

  /// List installed custom drivers.
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

  /// Get the currently active driver metadata.
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

  /// Save the active driver name.
  Future<void> setActiveDriver(DriverMeta meta) async {
    await _prefs.setString(_prefsActiveDriverKey, meta.name);
    _writeEnvFile(meta);
  }

  /// Clear the active driver and write system defaults.
  Future<void> setSystemDriver() async {
    await _prefs.remove(_prefsActiveDriverKey);
    _clearEnvFile();
  }

  // --------------------------------------------------- install / uninstall

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

      // Ensure the driver library exists
      final driverFile = File('${tmpDir.path}/${meta.libraryName}');
      if (!driverFile.existsSync()) throw Exception('Driver file ${meta.libraryName} not found');

      // Move to the final location inside the prefix
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

  Future<void> uninstallDriver(String driverName) async {
    final dir = Directory('${_driversDir.path}/$driverName');
    if (dir.existsSync()) await dir.delete(recursive: true);

    final activeName = _prefs.getString(_prefsActiveDriverKey);
    if (activeName == driverName) {
      await _prefs.remove(_prefsActiveDriverKey);
      _clearEnvFile();
    }
  }

  // --------------------------------------------------- env file helpers

void _writeEnvFile(DriverMeta meta) {
  final block = '''
# Adrenotools custom driver
export ADRENOTOOLS_DRIVER_PATH="${meta.path}"
export ADRENOTOOLS_DRIVER_NAME="${meta.libraryName}"
export ADRENOTOOLS_HOOKS_PATH="${meta.path}"
export ADRENOTOOLS_FILE_REDIRECT_DIR="${meta.path}files"
export VK_ICD_FILENAMES=/data/data/com.xodos/files/usr/share/vulkan/icd.d/wrapper_icd.aarch64.json

# Performance / compatibility tweaks
export MESA_LOADER_DRIVER_OVERRIDE="zink"
export VKD3D_FEATURE_LEVEL="12_0"
export TU_DEBUG="noconform"
export GALLIUM_DRIVER="zink"
export MESA_VK_WSI_PRESENT_MODE="mailbox"
export vblank_mode=0
''';

  // Ensure the file-redirect directory exists
  Directory('${meta.path}files').createSync(recursive: true);

  final drvFile = File(_optDrvFile);
  String existing = '';
  if (drvFile.existsSync()) {
    existing = drvFile.readAsStringSync();
    // Remove any previous adrenotools block
    existing = existing.replaceAll(
      RegExp(r'^# Adrenotools custom driver.*?(?:\n\n|\n?$)', multiLine: true),
      '',
    );
  }
  drvFile.writeAsStringSync(existing + block);
}

  void _clearEnvFile() {
    final drvFile = File(_optDrvFile);
    if (!drvFile.existsSync()) return;
    String content = drvFile.readAsStringSync();
    content = content.replaceAll(
      RegExp(r'^# Adrenotools custom driver.*?(?:\n\n|\n?$)', multiLine: true),
      '',
    );
    drvFile.writeAsStringSync(content);
  }
}