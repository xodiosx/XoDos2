import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
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
  String path;

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
      name: json['name']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      packageVersion: json['packageVersion']?.toString() ?? '',
      vendor: json['vendor']?.toString() ?? '',
      driverVersion: json['driverVersion']?.toString() ?? '',
      minApi: json['minApi'] is int
          ? json['minApi'] as int
          : int.tryParse('${json['minApi']}') ?? 0,
      description: json['description']?.toString() ?? '',
      libraryName: json['libraryName']?.toString() ?? '',
    );
  }
}

class AdrenotoolsDriverManager {
  static const String _prefsActiveDriverKey = 'active_driver_name';

  // Path inside the proot prefix (the rootfs)
  static const String _prefixPath = '/data/data/com.xodos/files/usr';
  static const String _driversDirName = 'drivers';
  static const String _optDrvFile = '/data/data/com.xodos/files/usr/opt/drv';

  late final Directory _baseDir;
  late final Directory _driversDir;
  late final SharedPreferences _prefs;

  AdrenotoolsDriverManager._();

  static Future<AdrenotoolsDriverManager> initialize() async {
    final instance = AdrenotoolsDriverManager._();

    final appDir = await getApplicationSupportDirectory();
    instance._baseDir = Directory('${appDir.path}/adrenotools');
    await instance._baseDir.create(recursive: true);

    instance._driversDir = Directory('$_prefixPath/$_driversDirName');
    await instance._driversDir.create(recursive: true);

    instance._prefs = await SharedPreferences.getInstance();
    return instance;
  }

  List<DriverMeta> getInstalledDrivers() {
    if (!_driversDir.existsSync()) return [];

    final drivers = <DriverMeta>[];

    for (final dir in _driversDir.listSync().whereType<Directory>()) {
      final metaFile = File('${dir.path}/meta.json');
      if (!metaFile.existsSync()) continue;

      try {
        final meta = DriverMeta.fromJson(
          jsonDecode(metaFile.readAsStringSync()) as Map<String, dynamic>,
        );
        meta.path = _ensureTrailingSlash(dir.path);
        drivers.add(meta);
      } catch (_) {
        // Skip broken driver folders
      }
    }

    drivers.sort((a, b) => a.name.compareTo(b.name));
    return drivers;
  }

  DriverMeta? getActiveDriverMeta() {
    final activeName = _prefs.getString(_prefsActiveDriverKey);
    if (activeName == null || activeName.isEmpty) return null;

    final driverDir = Directory('${_driversDir.path}/$activeName');
    final metaFile = File('${driverDir.path}/meta.json');
    if (!metaFile.existsSync()) return null;

    try {
      final meta = DriverMeta.fromJson(
        jsonDecode(metaFile.readAsStringSync()) as Map<String, dynamic>,
      );
      meta.path = _ensureTrailingSlash(driverDir.path);
      return meta;
    } catch (_) {
      return null;
    }
  }

  Future<void> setActiveDriver(DriverMeta meta) async {
    await _prefs.setString(_prefsActiveDriverKey, meta.name);
    await _writeEnvFile(meta);
  }

  Future<void> setSystemDriver() async {
    await _prefs.remove(_prefsActiveDriverKey);
    await _writeSystemEnvFile();
  }

  Future<DriverMeta> installDriver(Uint8List zipBytes) async {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final tmpDir = Directory('${_baseDir.path}/tmp_$stamp');
    await tmpDir.create(recursive: true);

    try {
      final archive = ZipDecoder().decodeBytes(zipBytes);

      for (final entry in archive) {
        if (entry is! ArchiveFile) continue;

        final safeName = _sanitizeArchivePath(entry.name);
        if (safeName.isEmpty) continue;

        final outPath = '${tmpDir.path}/$safeName';

        if (entry.isFile) {
          final outFile = File(outPath);
          await outFile.parent.create(recursive: true);
          await outFile.writeAsBytes(
            _archiveFileBytes(entry.content),
            flush: true,
          );
        } else {
          await Directory(outPath).create(recursive: true);
        }
      }

      final metaFile = File('${tmpDir.path}/meta.json');
      if (!metaFile.existsSync()) {
        throw Exception('Missing meta.json');
      }

      final meta = DriverMeta.fromJson(
        jsonDecode(await metaFile.readAsString()) as Map<String, dynamic>,
      );

      if (meta.name.isEmpty) {
        throw Exception('meta.json has empty name');
      }
      if (meta.libraryName.isEmpty) {
        throw Exception('meta.json has empty libraryName');
      }

      final driverLibFile = File('${tmpDir.path}/${meta.libraryName}');
      if (!driverLibFile.existsSync()) {
        throw Exception('Driver file ${meta.libraryName} not found');
      }

      final finalDriverDir = Directory('${_driversDir.path}/${meta.name}');
      if (finalDriverDir.existsSync()) {
        await finalDriverDir.delete(recursive: true);
      }

      await _copyDirectory(tmpDir, finalDriverDir);

      meta.path = _ensureTrailingSlash(finalDriverDir.path);
      return meta;
    } catch (_) {
      rethrow;
    } finally {
      if (await tmpDir.exists()) {
        try {
          await tmpDir.delete(recursive: true);
        } catch (_) {
          // Ignore cleanup failure
        }
      }
    }
  }

  Future<void> uninstallDriver(String driverName) async {
    final dir = Directory('${_driversDir.path}/$driverName');
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }

    final activeName = _prefs.getString(_prefsActiveDriverKey);
    if (activeName == driverName) {
      await setSystemDriver();
    }
  }

  Future<void> _writeEnvFile(DriverMeta meta) async {
    final block = '''
# Adrenotools custom driver
export ADRENOTOOLS_DRIVER_PATH="${meta.path}"
export ADRENOTOOLS_DRIVER_NAME="${meta.libraryName}"
export ADRENOTOOLS_HOOKS_PATH="${_prefixPath}/lib/"

export VK_ICD_FILENAMES=/data/data/com.xodos/files/usr/share/vulkan/icd.d/wrapper_icd.aarch64.json

# Performance / compatibility tweaks
export MESA_LOADER_DRIVER_OVERRIDE="zink"
export VKD3D_FEATURE_LEVEL="12_0"
export TU_DEBUG="noconform"
export GALLIUM_DRIVER="zink"
export MESA_VK_WSI_PRESENT_MODE="mailbox"
export vblank_mode=0
''';

    await _writeOptDrv(block);
  }

  Future<void> _writeSystemEnvFile() async {
    const block = '''
# system driver env
unset ADRENOTOOLS_DRIVER_PATH
unset ADRENOTOOLS_DRIVER_NAME
unset ADRENOTOOLS_HOOKS_PATH

export VK_ICD_FILENAMES=/data/data/com.xodos/files/usr/share/vulkan/icd.d/wrapper_icd.aarch64.json

# Performance / compatibility tweaks
export MESA_LOADER_DRIVER_OVERRIDE="zink"
export VKD3D_FEATURE_LEVEL="12_0"
export TU_DEBUG="noconform"
export GALLIUM_DRIVER="zink"
export MESA_VK_WSI_PRESENT_MODE="mailbox"
export vblank_mode=0
''';

    await _writeOptDrv(block);
  }

  Future<void> _writeOptDrv(String contents) async {
    final drvFile = File(_optDrvFile);
    await drvFile.parent.create(recursive: true);
    await drvFile.writeAsString(contents, flush: true);
  }

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await destination.create(recursive: true);

    await for (final entity
        in source.list(recursive: false, followLinks: false)) {
      final name = _lastPathSegment(entity.path);
      final targetPath = '${destination.path}/$name';

      if (entity is File) {
        await entity.copy(targetPath);
      } else if (entity is Directory) {
        await _copyDirectory(entity, Directory(targetPath));
      }
    }
  }

  String _sanitizeArchivePath(String raw) {
    var path = raw.replaceAll('\\', '/').trim();

    if (path.isEmpty) return '';

    while (path.startsWith('/')) {
      path = path.substring(1);
    }

    final segments = path.split('/').where((s) => s.isNotEmpty).toList();

    if (segments.isEmpty) return '';
    if (segments.any((s) => s == '..')) {
      throw Exception('Unsafe zip entry path: $raw');
    }

    return segments.join('/');
  }

  List<int> _archiveFileBytes(dynamic content) {
    if (content is Uint8List) return content;
    if (content is List<int>) return Uint8List.fromList(content);
    if (content is String) return utf8.encode(content);

    throw Exception('Unsupported archive content type: ${content.runtimeType}');
  }

  String _ensureTrailingSlash(String path) {
    if (path.endsWith('/')) return path;
    return '$path/';
  }

  String _lastPathSegment(String path) {
    final parts = path.split(Platform.pathSeparator);
    return parts.isEmpty ? path : parts.last;
  }
}