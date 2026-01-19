import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this for Clipboard if needed
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'default_values.dart';
import 'core_classes.dart';
//import 'app_colors.dart'; // Add this
import 'main.dart'; // Remove if not needed


// DXVK Dialog
class DxvkDialog extends StatefulWidget {
  @override
  _DxvkDialogState createState() => _DxvkDialogState();
}

class _DxvkDialogState extends State<DxvkDialog> {
  String? _selectedDxvk;
  List<String> _dxvkFiles = [];
  String? _dxvkDirectory;
  bool _isLoading = true;
  
  // Current switch states
  bool _currentMangohudEnabled = false;
  bool _currentDxvkHudEnabled = false;
  
  // Saved states from SharedPreferences
  bool _savedMangohudEnabled = false;
  bool _savedDxvkHudEnabled = false;
  String? _savedSelectedDxvk;

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences();
    _loadDxvkFiles();
  }

  Future<void> _loadSavedPreferences() async {
    try {
      _savedMangohudEnabled = G.prefs.getBool('mangohud_enabled') ?? false;
      _savedDxvkHudEnabled = G.prefs.getBool('dxvkhud_enabled') ?? false;
      _savedSelectedDxvk = G.prefs.getString('selected_dxvk');
      
      setState(() {
        _currentMangohudEnabled = _savedMangohudEnabled;
        _currentDxvkHudEnabled = _savedDxvkHudEnabled;
      });
    } catch (e) {
      print('Error loading preferences: $e');
    }
  }

  Future<void> _savePreferences() async {
    await G.prefs.setBool('mangohud_enabled', _currentMangohudEnabled);
    await G.prefs.setBool('dxvkhud_enabled', _currentDxvkHudEnabled);
    if (_selectedDxvk != null) {
      await G.prefs.setString('selected_dxvk', _selectedDxvk!);
    }
  }

  bool get _hasHudChanged {
    return _currentMangohudEnabled != _savedMangohudEnabled ||
           _currentDxvkHudEnabled != _savedDxvkHudEnabled;
  }

  bool get _hasDxvkChanged {
    return _selectedDxvk != null && _selectedDxvk != _savedSelectedDxvk;
  }

  Future<void> _writeHudSettings() async {
    G.pageIndex.value = 0;
    await Future.delayed(const Duration(milliseconds: 300));
    
    Util.termWrite("echo '' > ${G.dataPath}/usr/opt/hud");
    await Future.delayed(const Duration(milliseconds: 50));
    
    Util.termWrite("echo '#================================'");
    await Future.delayed(const Duration(milliseconds: 50));
    
    if (_currentMangohudEnabled) {
      Util.termWrite("echo 'export MANGOHUD=1' >> ${G.dataPath}/usr/opt/hud");
      await Future.delayed(const Duration(milliseconds: 50));
      Util.termWrite("echo 'export MANGOHUD_DLSYM=1' >> ${G.dataPath}/usr/opt/hud");
      await Future.delayed(const Duration(milliseconds: 50));
      Util.termWrite("echo '# MANGOHUD enabled' >> ${G.dataPath}/usr/opt/hud");
    } else {
      Util.termWrite("echo 'export MANGOHUD=0' >> ${G.dataPath}/usr/opt/hud");
      await Future.delayed(const Duration(milliseconds: 50));
      Util.termWrite("echo 'export MANGOHUD_DLSYM=0' >> ${G.dataPath}/usr/opt/hud");
      await Future.delayed(const Duration(milliseconds: 50));
      Util.termWrite("echo '# MANGOHUD disabled' >> ${G.dataPath}/usr/opt/hud");
    }
    
    if (_currentDxvkHudEnabled) {
      Util.termWrite("echo 'export DXVK_HUD=fps,version,devinfo' >> ${G.dataPath}/usr/opt/hud");
      await Future.delayed(const Duration(milliseconds: 50));
      Util.termWrite("echo '# DXVK HUD enabled' >> ${G.dataPath}/usr/opt/hud");
    } else {
      Util.termWrite("echo 'export DXVK_HUD=0' >> ${G.dataPath}/usr/opt/hud");
      await Future.delayed(const Duration(milliseconds: 50));
      Util.termWrite("echo '# DXVK HUD disabled' >> ${G.dataPath}/usr/opt/hud");
    }
    
    Util.termWrite("echo 'HUD settings saved to ${G.dataPath}/usr/opt/hud'");
    await Future.delayed(const Duration(milliseconds: 50));
    Util.termWrite("echo '#================================'");
  }

  Future<void> _extractDxvk() async {
    try {
      if (_selectedDxvk == null || _dxvkDirectory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a DXVK version'),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }
      
      final dxvkPath = '$_dxvkDirectory/$_selectedDxvk';
      final file = File(dxvkPath);
      
      if (!await file.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File not found: $dxvkPath'),
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
      
      await _savePreferences();
      
      if (_hasHudChanged) {
        await _writeHudSettings();
      }
      
      Navigator.of(context).pop();
      
      G.pageIndex.value = 0;
      await Future.delayed(const Duration(milliseconds: 300));
      
      await _extractDxvkAndRelated();
      
    } catch (e) {
      print('Error in _extractDxvk: $e');
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during extraction: $e'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _extractDxvkAndRelated() async {
    if (_hasDxvkChanged && _selectedDxvk != null) {
      await _extractSingleFile(_selectedDxvk!, 'DXVK');
      
      bool isDxvkFile = _selectedDxvk!.toLowerCase().contains('dxvk');
      
      if (isDxvkFile) {
        final vkd3dFiles = await _findRelatedFiles('vkd3d');
        for (final vkd3dFile in vkd3dFiles) {
          await _extractSingleFile(vkd3dFile, 'VKD3D');
        }
        
        final d8vkFiles = await _findRelatedFiles('d8vk');
        for (final d8vkFile in d8vkFiles) {
          await _extractSingleFile(d8vkFile, 'D8VK');
        }
      }
    } else {
      Util.termWrite("echo 'DXVK already installed: $_selectedDxvk'");
      await Future.delayed(const Duration(milliseconds: 50));
      Util.termWrite("echo '#================================'");
    }
  }

  Future<void> _extractSingleFile(String fileName, String fileType) async {
    Util.termWrite("echo '#================================'");
    await Future.delayed(const Duration(milliseconds: 50));
    
    Util.termWrite("echo 'Extracting $fileType: $fileName'");
    await Future.delayed(const Duration(milliseconds: 50));
    
    Util.termWrite("mkdir -p ${G.dataPath}/home/.wine/drive_c/windows");
    await Future.delayed(const Duration(milliseconds: 50));
    
    String containerPath = "${G.dataPath}/usr/wincomponents/d3d/$fileName";
    
    if (fileName.endsWith('.zip')) {
      Util.termWrite("unzip -o '$containerPath' -d '${G.dataPath}/home/.wine/drive_c/windows'");
    } else if (fileName.endsWith('.7z')) {
      Util.termWrite("7z x '$containerPath' -o'${G.dataPath}/home/.wine/drive_c/windows' -y");
    } else {
      Util.termWrite("tar -xaf '$containerPath' -C '${G.dataPath}/home/.wine/drive_c/windows'");
    }
    
    await Future.delayed(const Duration(milliseconds: 50));
    
    Util.termWrite("echo '$fileType extraction complete!'");
    await Future.delayed(const Duration(milliseconds: 50));
  }

  Future<List<String>> _findRelatedFiles(String pattern) async {
    if (_dxvkDirectory == null) return [];
    
    try {
      final dir = Directory(_dxvkDirectory!);
      final files = await dir.list().toList();
      
      return files
          .where((file) => file is File)
          .map((file) => file.path.split('/').last)
          .where((fileName) => fileName.toLowerCase().contains(pattern.toLowerCase()))
          .where((fileName) => RegExp(r'\.(tzst|tar\.gz|tgz|tar\.xz|txz|tar|zip|7z)$').hasMatch(fileName))
          .toList();
    } catch (e) {
      print('Error finding related files: $e');
      return [];
    }
  }

  Future<void> _cancelDialog() async {
    await _savePreferences();
    
    if (_hasHudChanged) {
      await _writeHudSettings();
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('HUD settings saved to ${G.dataPath}/usr/opt/hud'),
            duration: const Duration(seconds: 2),
          ),
        );
      });
    }
    
    Navigator.of(context).pop();
  }

  Future<void> _loadDxvkFiles() async {
    try {
      String containerDir = "${G.dataPath}/containers/${G.currentContainer}";
      String hostDir = "${G.dataPath}/usr/wincomponents/d3d";
      
      final dir = Directory(hostDir);
      if (!await dir.exists()) {
        print('DXVK directory not found at: $hostDir');
        setState(() {
          _dxvkFiles = [];
          _isLoading = false;
        });
        return;
      }
      
      _dxvkDirectory = hostDir;
      print('Found DXVK directory at: $hostDir');
      
      final files = await dir.list().toList();
      
      final dxvkFiles = files
          .where((file) => file is File && 
              RegExp(r'\.(tzst|tar\.gz|tgz|tar\.xz|txz|tar|zip|7z)$').hasMatch(file.path))
          .map((file) => file.path.split('/').last)
          .toList();
      
      setState(() {
        _dxvkFiles = dxvkFiles;
        if (dxvkFiles.isNotEmpty) {
          _selectedDxvk = _savedSelectedDxvk ?? dxvkFiles.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading DXVK files: $e');
      setState(() {
        _dxvkFiles = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return AlertDialog(
      title: const Text('Install DXVK'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * (isLandscape ? 0.8 : 0.6),
          minWidth: MediaQuery.of(context).size.width * (isLandscape ? 0.6 : 0.8),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (!_isLoading && _dxvkFiles.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.orange, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'No DXVK files found',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please place DXVK files in:\n/wincomponents/d3d/',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      if (_dxvkDirectory != null)
                        Text(
                          'Directory: $_dxvkDirectory',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                    ],
                  ),
                ),
              if (!_isLoading && _dxvkFiles.isNotEmpty)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedDxvk,
                      decoration: const InputDecoration(
                        labelText: 'Select DXVK Version',
                        border: OutlineInputBorder(),
                      ),
                      items: _dxvkFiles.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedDxvk = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HUD Settings (Saved to Prefix/usr/opt/hud)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          
                          SwitchListTile(
                            dense: isLandscape,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                            title: const Text(
                              'MANGOHUD',
                              style: TextStyle(fontSize: 14),
                            ),
                            subtitle: const Text(
                              'Overlay for monitoring FPS, CPU, GPU, etc.',
                              style: TextStyle(fontSize: 12),
                            ),
                            value: _currentMangohudEnabled,
                            onChanged: (value) {
                              setState(() {
                                _currentMangohudEnabled = value;
                              });
                            },
                          ),
                          
                          SwitchListTile(
                            dense: isLandscape,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                            title: const Text(
                              'DXVK HUD',
                              style: TextStyle(fontSize: 14),
                            ),
                            subtitle: const Text(
                              'DXVK overlay showing FPS, version, device info',
                              style: TextStyle(fontSize: 12),
                            ),
                            value: _currentDxvkHudEnabled,
                            onChanged: (value) {
                              setState(() {
                                _currentDxvkHudEnabled = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'installing: DXVK, VKD3D, and D8VK files will be Installed together',
                              style: TextStyle(
                                fontSize: isLandscape ? 12 : 14,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    if (_hasHudChanged || _hasDxvkChanged)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _hasHudChanged && _hasDxvkChanged
                                    ? 'HUD settings and DXVK will be updated'
                                    : _hasHudChanged
                                        ? 'HUD settings will be saved to ${G.dataPath}/usr/opt/hud'
                                        : 'DXVK will be extracted',
                                style: TextStyle(
                                  fontSize: isLandscape ? 12 : 14,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cancelDialog,
          child: const Text('Cancel'),
        ),
        if (_dxvkFiles.isNotEmpty && !_isLoading && _selectedDxvk != null)
          ElevatedButton(
            onPressed: _extractDxvk,
            child: const Text('Install'),
          ),
      ],
      scrollable: true,
    );
  }
}

// Environment Dialog
class EnvironmentDialog extends StatefulWidget {
  @override
  _EnvironmentDialogState createState() => _EnvironmentDialogState();
}

class _EnvironmentDialogState extends State<EnvironmentDialog> {
  final List<Map<String, dynamic>> _dynarecVariables = [
    {"name": "BOX64_DYNAREC_SAFEFLAGS", "values": ["0", "1", "2"], "defaultValue": "2"},
    {"name": "BOX64_DYNAREC_FASTNAN", "values": ["0", "1"], "toggleSwitch": true, "defaultValue": "1"},
    {"name": "BOX64_DYNAREC_FASTROUND", "values": ["0", "1", "2"], "defaultValue": "1"},
    {"name": "BOX64_DYNAREC_X87DOUBLE", "values": ["0", "1"], "toggleSwitch": true, "defaultValue": "0"},
    {"name": "BOX64_DYNAREC_BIGBLOCK", "values": ["0", "1", "2", "3"], "defaultValue": "1"},
    {"name": "BOX64_DYNAREC_STRONGMEM", "values": ["0", "1", "2", "3"], "defaultValue": "0"},
    {"name": "BOX64_DYNAREC_FORWARD", "values": ["0", "128", "256", "512", "1024"], "defaultValue": "128"},
    {"name": "BOX64_DYNAREC_CALLRET", "values": ["0", "1"], "toggleSwitch": true, "defaultValue": "1"},
    {"name": "BOX64_DYNAREC_WAIT", "values": ["0", "1"], "toggleSwitch": true, "defaultValue": "1"},
    {"name": "BOX64_DYNAREC_NATIVEFLAGS", "values": ["0", "1"], "toggleSwitch": true, "defaultValue": "0"},
    {"name": "BOX64_DYNAREC_WEAKBARRIER", "values": ["0", "1", "2"], "defaultValue": "0"},
    {"name": "BOX64_MMAP32", "values": ["0", "1"], "toggleSwitch": true, "defaultValue": "0"},
    {"name": "BOX64_AVX", "values": ["0", "1"], "toggleSwitch": true, "defaultValue": "0"},
    {"name": "BOX64_UNITYPLAYER", "values": ["0", "1"], "toggleSwitch": true, "defaultValue": "0"},
  ];

  final Map<String, Map<String, String>> _box64Presets = {
    'Stability': {
      'BOX64_DYNAREC_SAFEFLAGS': '2',
      'BOX64_DYNAREC_FASTNAN': '0',
      'BOX64_DYNAREC_FASTROUND': '0',
      'BOX64_DYNAREC_X87DOUBLE': '1',
      'BOX64_DYNAREC_BIGBLOCK': '0',
      'BOX64_DYNAREC_STRONGMEM': '2',
      'BOX64_DYNAREC_FORWARD': '128',
      'BOX64_DYNAREC_CALLRET': '0',
      'BOX64_DYNAREC_WAIT': '0',
      'BOX64_AVX': '0',
      'BOX64_UNITYPLAYER': '1',
      'BOX64_MMAP32': '0',
    },
    'Compatibility': {
      'BOX64_DYNAREC_SAFEFLAGS': '2',
      'BOX64_DYNAREC_FASTNAN': '0',
      'BOX64_DYNAREC_FASTROUND': '0',
      'BOX64_DYNAREC_X87DOUBLE': '1',
      'BOX64_DYNAREC_BIGBLOCK': '0',
      'BOX64_DYNAREC_STRONGMEM': '1',
      'BOX64_DYNAREC_FORWARD': '128',
      'BOX64_DYNAREC_CALLRET': '0',
      'BOX64_DYNAREC_WAIT': '1',
      'BOX64_AVX': '0',
      'BOX64_UNITYPLAYER': '1',
      'BOX64_MMAP32': '0',
    },
    'Intermediate': {
      'BOX64_DYNAREC_SAFEFLAGS': '2',
      'BOX64_DYNAREC_FASTNAN': '1',
      'BOX64_DYNAREC_FASTROUND': '0',
      'BOX64_DYNAREC_X87DOUBLE': '1',
      'BOX64_DYNAREC_BIGBLOCK': '1',
      'BOX64_DYNAREC_STRONGMEM': '0',
      'BOX64_DYNAREC_FORWARD': '128',
      'BOX64_DYNAREC_CALLRET': '1',
      'BOX64_DYNAREC_WAIT': '1',
      'BOX64_AVX': '0',
      'BOX64_UNITYPLAYER': '0',
      'BOX64_MMAP32': '1',
    },
  };

  List<bool> _coreSelections = [];
  int _availableCores = 8;
  
  bool _wineEsyncEnabled = false;
  
  List<Map<String, String>> _customVariables = [];
  String _selectedKnownVariable = '';
  final List<String> _knownWineVariables = [
    'WINEARCH',
     'DXVK_ASYNC',
     'adrenotool',
     'GALLIUM_DRIVER',
   'MESA_LOADER_DRIVER_OVERRIDE',
    'VK_LOADER_DEBUG',
   'LD_DEBUG',
    'ZINK_DEBUG',
    'WINEDEBUG',
     'MESA_VK_WSI_PRESENT_MODE',
    'WINEPREFIX',
    'WINEESYNC',
    'WINEFSYNC',
    'WINE_NOBLOB',
    'WINE_NO_CRASH_DIALOG',
    'WINEDLLOVERRIDES',
    'WINEDLLPATH',
    'WINE_MONO_CACHE_DIR',
    'WINE_GECKO_CACHE_DIR',
    'WINEDISABLE',
    'WINE_ENABLE'
  ];
  
  bool _debugEnabled = false;
  String _winedebugValue = '-all';
  final List<String> _winedebugOptions = [
    '-all', 'err', 'warn', 'fixme', 'all', 'trace', 'message', 'heap', 'fps', 'dx9', 'dx8'
  ];
  
  String _newVarName = '';
  String _newVarValue = '';

  @override
  void initState() {
    super.initState();
    _initializeCores();
    _loadSavedSettings();
  }

  Future<void> _initializeCores() async {
    try {
      _availableCores = Platform.numberOfProcessors;
      
      setState(() {
        _coreSelections = List.generate(_availableCores, (index) => true);
      });
    } catch (e) {
      print('Error getting CPU count: $e');
      _availableCores = 8;
      _coreSelections = List.generate(8, (index) => true);
    }
  }

  Future<void> _loadSavedSettings() async {
    try {
      final savedCores = G.prefs.getString('environment_cores');
      if (savedCores != null && savedCores.isNotEmpty) {
        _parseCoreSelections(savedCores);
      } else {
        setState(() {
          _coreSelections = List.generate(_availableCores, (index) => true);
        });
      }
      
      _wineEsyncEnabled = G.prefs.getBool('environment_wine_esync') ?? false;
      _debugEnabled = G.prefs.getBool('environment_debug') ?? false;
      _winedebugValue = G.prefs.getString('environment_winedebug') ?? '-all';
      
      final savedVars = G.prefs.getStringList('environment_custom_vars') ?? [];
      _customVariables = savedVars.map((varStr) {
        final parts = varStr.split('=');
        return {'name': parts[0], 'value': parts.length > 1 ? parts[1] : ''};
      }).toList();
      
      setState(() {});
    } catch (e) {
      print('Error loading environment settings: $e');
    }
  }

  void _parseCoreSelections(String coreString) {
    try {
      _coreSelections = List.generate(_availableCores, (index) => false);
      
      if (coreString.contains(',')) {
        final selectedIndices = coreString.split(',');
        for (final indexStr in selectedIndices) {
          final index = int.tryParse(indexStr);
          if (index != null && index < _availableCores) {
            _coreSelections[index] = true;
          }
        }
      } else if (coreString.contains('-')) {
        final parts = coreString.split('-');
        final start = int.tryParse(parts[0]) ?? 0;
        final end = int.tryParse(parts[1]) ?? (_availableCores - 1);
        
        for (int i = start; i <= end && i < _availableCores; i++) {
          _coreSelections[i] = true;
        }
      }
    } catch (e) {
      print('Error parsing core selections: $e');
    }
  }

  String _getCoreString() {
    final selectedIndices = <int>[];
    for (int i = 0; i < _availableCores; i++) {
      if (_coreSelections[i]) {
        selectedIndices.add(i);
      }
    }
    
    if (selectedIndices.isEmpty) {
      return "0";
    }
    
    return selectedIndices.join(',');
  }

  Future<void> _saveSettings() async {
    try {
      await G.prefs.setString('environment_cores', _getCoreString());
      await G.prefs.setBool('environment_wine_esync', _wineEsyncEnabled);
      await G.prefs.setBool('environment_debug', _debugEnabled);
      await G.prefs.setString('environment_winedebug', _winedebugValue);
      
      final varStrings = _customVariables.map((varMap) => '${varMap['name']}=${varMap['value']}').toList();
      await G.prefs.setStringList('environment_custom_vars', varStrings);
      
      for (final variable in _dynarecVariables) {
        final name = variable['name'] as String;
        final currentValue = variable['currentValue'] ?? variable['defaultValue'];
        await G.prefs.setString('dynarec_$name', currentValue);
      }
      
      await _applyEnvironmentSettings();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Environment settings saved and applied!'),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
      
    } catch (e) {
      print('Error saving environment settings: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving settings: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _applyEnvironmentSettings() async {
    G.pageIndex.value = 0;
    await Future.delayed(const Duration(milliseconds: 300));
    
    Util.termWrite("echo '' > ${G.dataPath}/usr/opt/dyna");
    Util.termWrite("echo '' > ${G.dataPath}/usr/opt/sync");
    Util.termWrite("echo '' > ${G.dataPath}/usr/opt/cores");
    Util.termWrite("echo '' > ${G.dataPath}/usr/opt/env");
    Util.termWrite("echo '' > ${G.dataPath}/usr/opt/dbg");
    Util.termWrite("echo '' > ${G.dataPath}/usr/opt/hud");
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    for (final variable in _dynarecVariables) {
      final name = variable['name'] as String;
      final defaultValue = variable['defaultValue'] as String;
      final savedValue = G.prefs.getString('dynarec_$name') ?? defaultValue;
      
      Util.termWrite("echo 'export $name=$savedValue' >> ${G.dataPath}/usr/opt/dyna");
      await Future.delayed(const Duration(milliseconds: 10));
    }
    
    if (_wineEsyncEnabled) {
      Util.termWrite("echo 'export WINEESYNC=1' >> ${G.dataPath}/usr/opt/sync");
      Util.termWrite("echo 'export WINEESYNC_TERMUX=1' >> ${G.dataPath}/usr/opt/sync");
    } else {
      Util.termWrite("echo 'export WINEESYNC=0' >> ${G.dataPath}/usr/opt/sync");
      Util.termWrite("echo 'export WINEESYNC_TERMUX=0' >> ${G.dataPath}/usr/opt/sync");
    }
    
    Util.termWrite("echo 'export PRIMARY_CORES=${_getCoreString()}' >> ${G.dataPath}/usr/opt/cores");
    
    for (final variable in _customVariables) {
      Util.termWrite("echo 'export ${variable['name']}=${variable['value']}' >> ${G.dataPath}/usr/opt/env");
      await Future.delayed(const Duration(milliseconds: 10));
    }
    
    if (_debugEnabled) {
      Util.termWrite("echo 'export MESA_NO_ERROR=0' >> ${G.dataPath}/usr/opt/dbg");
      Util.termWrite("echo 'export WINEDEBUG=$_winedebugValue' >> ${G.dataPath}/usr/opt/dbg");
      Util.termWrite("echo 'export BOX64_LOG=1' >> ${G.dataPath}/usr/opt/dbg");
      Util.termWrite("echo 'export BOX64_NOBANNER=0' >> ${G.dataPath}/usr/opt/dbg");
      Util.termWrite("echo 'export BOX64_SHOWSEGV=1' >> ${G.dataPath}/usr/opt/dbg");
      Util.termWrite("echo 'export BOX64_DLSYM_ERROR=1' >> ${G.dataPath}/usr/opt/dbg");
      Util.termWrite("echo 'export BOX64_DYNAREC_MISSING=1' >> ${G.dataPath}/usr/opt/dbg");
    } else {
      Util.termWrite("echo 'export MESA_NO_ERROR=1' >> ${G.dataPath}/usr/opt/dbg");
      Util.termWrite("echo 'export WINEDEBUG=$_winedebugValue' >> ${G.dataPath}/usr/opt/dbg");
      Util.termWrite("echo 'export BOX64_LOG=0' >> ${G.dataPath}/usr/opt/dbg");
      Util.termWrite("echo 'export BOX64_NOBANNER=1' >> ${G.dataPath}/usr/opt/dbg");
      Util.termWrite("echo 'export BOX64_SHOWSEGV=0' >> ${G.dataPath}/usr/opt/dbg");
      Util.termWrite("echo 'export BOX64_DLSYM_ERROR=0' >> ${G.dataPath}/usr/opt/dbg");
      Util.termWrite("echo 'export BOX64_DYNAREC_MISSING=0' >> ${G.dataPath}/usr/opt/dbg");
    }
    
    Util.termWrite("echo '#================================'");
    Util.termWrite("echo 'Environment settings applied!'");
    Util.termWrite("echo '#================================'");
  }

  void _showDynarecDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final localVariables = _dynarecVariables.map((variable) {
          final name = variable['name'] as String;
          final defaultValue = variable['defaultValue'] as String;
          final savedValue = G.prefs.getString('dynarec_$name') ?? defaultValue;
          return {
            'name': name,
            'values': variable['values'],
            'defaultValue': defaultValue,
            'toggleSwitch': variable['toggleSwitch'] ?? false,
            'currentValue': savedValue,
          };
        }).toList();

        String selectedPreset = 'Custom';

        return StatefulBuilder(
          builder: (context, setState) {
            void _updatePresetSelection() {
              for (final presetName in _box64Presets.keys) {
                final preset = _box64Presets[presetName]!;
                bool matches = true;
                
                for (final variable in localVariables) {
                  final name = variable['name'] as String;
                  final currentValue = variable['currentValue'] as String;
                  
                  if (preset.containsKey(name) && preset[name] != currentValue) {
                    matches = false;
                    break;
                  }
                }
                
                if (matches) {
                  selectedPreset = presetName;
                  return;
                }
              }
              selectedPreset = 'Custom';
            }

            _updatePresetSelection();

            return AlertDialog(
              title: const Text('Box64 Dynarec Settings'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Preset',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              DropdownButton<String>(
                                value: selectedPreset,
                                isExpanded: true,
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: 'Custom',
                                    child: Text('Custom'),
                                  ),
                                  ..._box64Presets.keys.map((presetName) {
                                    return DropdownMenuItem<String>(
                                      value: presetName,
                                      child: Text(presetName),
                                    );
                                  }).toList(),
                                ],
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      selectedPreset = newValue;
                                      
                                      if (newValue != 'Custom') {
                                        final preset = _box64Presets[newValue]!;
                                        
                                        for (final variable in localVariables) {
                                          final name = variable['name'] as String;
                                          if (preset.containsKey(name)) {
                                            variable['currentValue'] = preset[name]!;
                                          }
                                        }
                                      }
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      ...localVariables.map((variable) {
                        return _buildDynarecVariableWidget(
                          variable, 
                          setState,
                          localVariables,
                          onVariableChanged: () {
                            setState(() {
                              selectedPreset = 'Custom';
                            });
                          }
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    for (final variable in localVariables) {
                      final name = variable['name'] as String;
                      final currentValue = variable['currentValue'] as String;
                      await G.prefs.setString('dynarec_$name', currentValue);
                    }
                    
                    for (final localVar in localVariables) {
                      final index = _dynarecVariables.indexWhere((v) => v['name'] == localVar['name']);
                      if (index != -1) {
                        _dynarecVariables[index]['currentValue'] = localVar['currentValue'];
                      }
                    }
                    
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Dynarec settings saved'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDynarecVariableWidget(
    Map<String, dynamic> variable, 
    StateSetter setState,
    List<Map<String, dynamic>> localVariables, {
    VoidCallback? onVariableChanged,
  }) {
    final name = variable['name'] as String;
    final values = variable['values'] as List<String>;
    final isToggle = variable['toggleSwitch'] == true;
    final currentValue = variable['currentValue'] as String;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (isToggle)
              SwitchListTile(
                title: Text('Enabled (${currentValue == "1" ? "ON" : "OFF"})'),
                value: currentValue == "1",
                onChanged: (value) {
                  setState(() {
                    variable['currentValue'] = value ? "1" : "0";
                    onVariableChanged?.call();
                  });
                },
              )
            else
              DropdownButton<String>(
                value: currentValue,
                isExpanded: true,
                items: values.map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      variable['currentValue'] = newValue;
                      onVariableChanged?.call();
                    });
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  void _addCustomVariable() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Environment Variable'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return _knownWineVariables.where(
                    (variable) => variable.toLowerCase().contains(textEditingValue.text.toLowerCase()),
                  );
                },
                fieldViewBuilder: (
                  context,
                  textEditingController,
                  focusNode,
                  onFieldSubmitted,
                ) {
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Variable Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _newVarName = value;
                    },
                  );
                },
                onSelected: (String selection) {
                  _newVarName = selection;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Value',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _newVarValue = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_newVarName.isNotEmpty && _newVarValue.isNotEmpty) {
                setState(() {
                  _customVariables.add({
                    'name': _newVarName,
                    'value': _newVarValue,
                  });
                  _newVarName = '';
                  _newVarValue = '';
                });
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter both variable name and value'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeCustomVariable(int index) {
    setState(() {
      _customVariables.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Environment Settings'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ListTile(
                  title: const Text('Box64 Dynarec'),
                  subtitle: const Text('Advanced emulation settings'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: _showDynarecDialog,
                ),
              ),
              const SizedBox(height: 8),
              
              Card(
                child: SwitchListTile(
                  title: const Text('Wine Esync'),
                  subtitle: const Text('Enable Wine Esync for better performance'),
                  value: _wineEsyncEnabled,
                  onChanged: (value) {
                    setState(() {
                      _wineEsyncEnabled = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CPU Cores',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Available CPUs: $_availableCores'),
                      Text('Selected: ${_getCoreString()}'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(_availableCores, (index) {
                          return FilterChip(
                            label: Text('CPU$index'),
                            selected: _coreSelections[index],
                            onSelected: (selected) {
                              setState(() {
                                _coreSelections[index] = selected;
                              });
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _coreSelections = List.generate(_availableCores, (index) => true);
                              });
                            },
                            child: const Text('Select All'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _coreSelections = List.generate(_availableCores, (index) => false);
                              });
                            },
                            child: const Text('Clear All'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Custom Variables',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ..._customVariables.asMap().entries.map((entry) {
                        final index = entry.key;
                        final variable = entry.value;
                        return ListTile(
                          title: Text(variable['name'] ?? ''),
                          subtitle: Text(variable['value'] ?? ''),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeCustomVariable(index),
                          ),
                          dense: true,
                        );
                      }),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: _addCustomVariable,
                        child: const Text('Add Variable'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        title: const Text('Debug Mode'),
                        subtitle: _debugEnabled
                            ? const Text('Verbose logging enabled')
                            : const Text('Quiet mode - minimal logging'),
                        value: _debugEnabled,
                        onChanged: (value) {
                          setState(() {
                            _debugEnabled = value;
                          });
                        },
                      ),
                      if (_debugEnabled) ...[
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text(
                          'WINEDEBUG Level',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _winedebugValue,
                          decoration: const InputDecoration(
                            labelText: 'WINEDEBUG',
                            border: OutlineInputBorder(),
                          ),
                          items: _winedebugOptions.map((option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _winedebugValue = value ?? '-all';
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveSettings,
          child: const Text('Save & Apply'),
        ),
      ],
    );
  }
}



// GPU Drivers Dialog


class GpuDriversDialog extends StatefulWidget {
  @override
  _GpuDriversDialogState createState() => _GpuDriversDialogState();
}

class _GpuDriversDialogState extends State<GpuDriversDialog> {
  String _selectedDriverType = 'wrapper';
  String? _selectedDriverFile;
  List<String> _driverFiles = [];
  String? _driversDirectory;
  bool _isLoading = true;
  
  // DRI3 switches
  bool _turnipDri3Enabled = false;
  bool _wrapperDri3Enabled = false;
  bool _venusDri3Enabled = false;
  bool _virglEnabled = false;
  
  // Venus settings
  bool _androidVenusEnabled = true;
  String _defaultTurnipOpt = 'MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform';
  String _defaultVenusCommand = '--no-virgl --venus --socket-path=\$CONTAINER_DIR/tmp/.virgl_test';
  String _defaultVenusOpt = '';
  String _defaultVirglCommand = '--use-egl-surfaceless --use-gles --socket-path=\$CONTAINER_DIR/tmp/.virgl_test';
  String _defaultVirglOpt = 'GALLIUM_DRIVER=virpipe';
  bool _isX11Enabled = false;
  
  // Server status
  bool _virglServerRunning = false;
  bool _venusServerRunning = false;

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
    _loadDriverFiles();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkServerStatus();
    });
  }

  Future<void> _checkServerStatus() async {
    await _updateVirglServerStatus();
    await _updateVenusServerStatus();
  }

  Future<void> _updateVirglServerStatus() async {
    try {
      final result = await Process.run(
        '${G.dataPath}/usr/bin/sh',
        [
          '-c',
          '${G.dataPath}/usr/bin/pgrep -a virgl_ |'
          ' grep use-'
        ],
      );

      final output = result.stdout.toString().trim();
      print('VirGL check output: "$output"');

      setState(() {
        _virglServerRunning = output.isNotEmpty;
      });
    } catch (e) {
      print('Error checking VirGL server status: $e');
      setState(() {
        _virglServerRunning = false;
      });
    }
  }

  Future<void> _updateVenusServerStatus() async {
    try {
      final result = await Process.run(
        '${G.dataPath}/usr/bin/sh',
        [
          '-c',
          '${G.dataPath}/usr/bin/pgrep -a virgl_ |'
          ' grep venus'
        ],
      );

      final output = result.stdout.toString().trim();
      print('Venus check output: "$output"');

      setState(() {
        _venusServerRunning = output.isNotEmpty;
      });
    } catch (e) {
      print('Error checking Venus server status: $e');
      setState(() {
        _venusServerRunning = false;
      });
    }
  }

  Future<void> _loadSavedSettings() async {
    try {
      _turnipDri3Enabled = G.prefs.getBool('turnip_dri3') ?? false;
      _wrapperDri3Enabled = G.prefs.getBool('wrapper_dri3') ?? false;
      _venusDri3Enabled = G.prefs.getBool('venus_dri3') ?? false;
      _virglEnabled = G.prefs.getBool('virgl') ?? false;
      _isX11Enabled = G.prefs.getBool('useX11') ?? false;
      _androidVenusEnabled = G.prefs.getBool('androidVenus') ?? true;
      
      String savedTurnipOpt = G.prefs.getString('defaultTurnipOpt') ?? 'MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform';
      _defaultTurnipOpt = _removeVkIcdFromEnvString(savedTurnipOpt);
      
      if (_defaultTurnipOpt.isEmpty) {
        _defaultTurnipOpt = 'MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform';
      }
      
      _defaultVenusCommand = G.prefs.getString('defaultVenusCommand') ?? '--no-virgl --venus --socket-path=\$CONTAINER_DIR/tmp/.virgl_test';
      _defaultVenusOpt = G.prefs.getString('defaultVenusOpt') ?? ' ANDROID_VENUS=1';
      _defaultVirglCommand = G.prefs.getString('defaultVirglCommand') ?? '--use-egl-surfaceless --use-gles --socket-path=\$CONTAINER_DIR/tmp/.virgl_test';
      _defaultVirglOpt = G.prefs.getString('defaultVirglOpt') ?? 'GALLIUM_DRIVER=virpipe';
      
      _selectedDriverType = G.prefs.getString('gpu_driver_type') ?? 'wrapper';
      _selectedDriverFile = G.prefs.getString('selected_gpu_driver');
      
      setState(() {});
    } catch (e) {
      print('Error loading GPU settings: $e');
    }
  }

  String _removeVkIcdFromEnvString(String envString) {
    List<String> envVars = envString.split(' ');
    envVars.removeWhere((varStr) => varStr.trim().startsWith('VK_ICD_FILENAMES='));
    return envVars.join(' ').trim();
  }

  Future<void> _saveAndExtract() async {
    try {
      await G.prefs.setString('gpu_driver_type', _selectedDriverType);
      if (_selectedDriverFile != null) {
        await G.prefs.setString('selected_gpu_driver', _selectedDriverFile!);
      }
      
      await G.prefs.setBool('turnip_dri3', _turnipDri3Enabled);
      await G.prefs.setBool('wrapper_dri3', _wrapperDri3Enabled);
      await G.prefs.setBool('venus_dri3', _venusDri3Enabled);
      await G.prefs.setBool('virgl', _virglEnabled);
      await G.prefs.setBool('androidVenus', _androidVenusEnabled);
      
      String cleanTurnipOpt = _removeVkIcdFromEnvString(_defaultTurnipOpt);
      if (cleanTurnipOpt.isEmpty) {
        cleanTurnipOpt = 'MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform';
      }
      await G.prefs.setString('defaultTurnipOpt', cleanTurnipOpt);
      
      await G.prefs.setString('defaultVenusCommand', _defaultVenusCommand);
      await G.prefs.setString('defaultVenusOpt', _defaultVenusOpt);
      await G.prefs.setString('defaultVirglCommand', _defaultVirglCommand);
      await G.prefs.setString('defaultVirglOpt', _defaultVirglOpt);
      
      G.pageIndex.value = 0;
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Handle both turnip and wrapper driver extraction
      if ((_selectedDriverType == 'turnip' || _selectedDriverType == 'wrapper') && 
          _selectedDriverFile != null) {
        await _extractDriver();
      } else {
        await _applyGpuSettings();
      }
      
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('GPU driver settings saved and applied!'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error saving GPU settings: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving settings: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _applyGpuSettings() async {
    G.pageIndex.value = 0;
    await Future.delayed(const Duration(milliseconds: 300));
    
    Util.termWrite("echo '' >${G.dataPath}/usr/opt/drv");
    
    if (_selectedDriverType == 'turnip') {
      await _applyTurnipSettings();
    } else if (_selectedDriverType == 'venus') {
      await _applyVenusSettings();
    } else if (_selectedDriverType == 'virgl') {
      await _applyVirglSettings();
    } else if (_selectedDriverType == 'wrapper') {
      await _applyWrapperSettings();
    }
    
    Util.termWrite("echo '#================================'");
    Util.termWrite("echo 'GPU driver settings applied!'");
    Util.termWrite("echo '#================================'");
  }

  Future<void> _applyTurnipSettings() async {
    Util.termWrite("echo 'export VK_ICD_FILENAMES=${G.dataPath}/usr/share/vulkan/icd.d/freedreno_icd.aarch64.json' >> ${G.dataPath}/usr/opt/drv");
    
    String cleanTurnipOpt = _removeVkIcdFromEnvString(_defaultTurnipOpt);
    if (cleanTurnipOpt.isNotEmpty) {
      Util.termWrite("echo 'export $cleanTurnipOpt' >> ${G.dataPath}/usr/opt/drv");
    }
    
    if (!_turnipDri3Enabled) {
      Util.termWrite("echo 'export MESA_VK_WSI_DEBUG=sw' >> ${G.dataPath}/usr/opt/drv");
    }
  }

  Future<void> _applyVenusSettings() async {
    String venusEnv = _defaultVenusOpt;
    
    if (_androidVenusEnabled) {
      venusEnv = venusEnv.replaceAll('ANDROID_VENUS=0', 'ANDROID_VENUS=1');
      if (!venusEnv.contains('ANDROID_VENUS=1')) {
        venusEnv = '$venusEnv ANDROID_VENUS=1';
      }
    } else {
      venusEnv = venusEnv.replaceAll('ANDROID_VENUS=1', 'ANDROID_VENUS=0');
    }
    
    Util.termWrite("echo 'export $venusEnv' >> ${G.dataPath}/usr/opt/drv");
    await Future.delayed(const Duration(milliseconds: 50));
    
    if (!_venusDri3Enabled) {
      Util.termWrite("echo 'export MESA_VK_WSI_DEBUG=sw' >> ${G.dataPath}/usr/opt/drv");
    }
  }

  Future<void> _applyVirglSettings() async {
    Util.termWrite("echo 'export $_defaultVirglOpt' >> ${G.dataPath}/usr/opt/drv");
    await Future.delayed(const Duration(milliseconds: 50));
  }

  Future<void> _applyWrapperSettings() async {
    Util.termWrite("echo '' > ${G.dataPath}/usr/opt/drv");
    await Future.delayed(const Duration(milliseconds: 50));
    
    Util.termWrite("echo '#================================' >> ${G.dataPath}/usr/opt/drv");
    await Future.delayed(const Duration(milliseconds: 50));
    
    Util.termWrite("echo '# Wrapper driver configuration' >> ${G.dataPath}/usr/opt/drv");
    await Future.delayed(const Duration(milliseconds: 50));
    
    Util.termWrite("echo 'export VK_ICD_FILENAMES=${G.dataPath}/usr/share/vulkan/icd.d/wrapper_icd.aarch64.json' >> ${G.dataPath}/usr/opt/drv");
    await Future.delayed(const Duration(milliseconds: 50));
    
    Util.termWrite("echo 'export TU_DEBUG=noconform' >> ${G.dataPath}/usr/opt/drv");
    await Future.delayed(const Duration(milliseconds: 50));
    
    if (!_wrapperDri3Enabled) {
      Util.termWrite("echo 'export MESA_VK_WSI_DEBUG=sw' >> ${G.dataPath}/usr/opt/drv");
    }
    
    Util.termWrite("echo '#================================' >> ${G.dataPath}/usr/opt/drv");
    await Future.delayed(const Duration(milliseconds: 50));
    
    Util.termWrite("echo 'Wrapper driver configuration complete'");
    await Future.delayed(const Duration(milliseconds: 50));
  }

  Future<void> _startVirglServer() async {
    G.pageIndex.value = 0;
    await Future.delayed(const Duration(milliseconds: 300));
    
    Util.termWrite("pkill -f virgl_test_server");
    await Future.delayed(const Duration(milliseconds: 100));
    
    Util.termWrite("echo '#================================'");
    await Future.delayed(const Duration(milliseconds: 50));
    
    Util.termWrite("echo 'Starting VirGL server...'");
    await Future.delayed(const Duration(milliseconds: 50));
    
    Util.termWrite("mkdir -p ${G.dataPath}/usr/tmp/.virgl_test");
    await Future.delayed(const Duration(milliseconds: 50));
    
    String containerDir = "${G.dataPath}/containers/${G.currentContainer}";
    
    String processedCommand = _defaultVirglCommand.replaceAll('\$CONTAINER_DIR', containerDir);
    
    Util.termWrite("echo 'Container directory: $containerDir'");
    await Future.delayed(const Duration(milliseconds: 50));
    
    Util.termWrite("${G.dataPath}/usr/bin/virgl_test_server $processedCommand &");    
    await Future.delayed(const Duration(milliseconds: 50));
    
    Util.termWrite("export GALLIUM_DRIVER=virpipe ");
    await Future.delayed(const Duration(milliseconds: 50));
    
    Util.termWrite("sleep 1 && if pgrep -f virgl_test_server > /dev/null; then echo 'VirGL server started successfully'; else echo 'Failed to start VirGL server'; fi");
    
    await Future.delayed(const Duration(milliseconds: 50));
    Util.termWrite("echo '#================================'");
    
    // Update status after starting
    await Future.delayed(const Duration(seconds: 1));
    await _updateVirglServerStatus();
  }

  Future<void> _startVenusServer() async {
    G.pageIndex.value = 0;
    await Future.delayed(const Duration(milliseconds: 300));
    
    Util.termWrite("pkill -f virgl_test_server");
    await Future.delayed(const Duration(milliseconds: 100));
    
    Util.termWrite("echo '#================================'");
    await Future.delayed(const Duration(milliseconds: 50));
    
    Util.termWrite("echo 'Starting Venus server...'");
    await Future.delayed(const Duration(milliseconds: 50));
    
    Util.termWrite("mkdir -p ${G.dataPath}/usr/tmp/");
    await Future.delayed(const Duration(milliseconds: 50));
    
    Util.termWrite("rm -rf ${G.dataPath}/usr/tmp/.virgl_test");
    await Future.delayed(const Duration(milliseconds: 50));
    
    String containerDir = "${G.dataPath}/containers/${G.currentContainer}";
    
    String processedCommand = _defaultVenusCommand.replaceAll('\$CONTAINER_DIR', containerDir);
    
    Util.termWrite("echo 'Container directory: $containerDir'");
    await Future.delayed(const Duration(milliseconds: 50));
    
    Util.termWrite("echo 'export VK_ICD_FILENAMES=${G.dataPath}/usr/share/vulkan/icd.d/wrapper_icd.aarch64.json' >> ${G.dataPath}/usr/opt/drv");
    await Future.delayed(const Duration(milliseconds: 50));

    String androidVenusEnv = _androidVenusEnabled ? "ANDROID_VENUS=1 " : "";
    String ldPreload = "LD_PRELOAD=/system/lib64/libvulkan.so";
 
    Util.termWrite(". /data/data/com.xodos/files/usr/opt/drv");    
    await Future.delayed(const Duration(milliseconds: 50));
    
    Util.termWrite("$androidVenusEnv ${G.dataPath}/usr/bin/virgl_test_server $processedCommand &");    
    await Future.delayed(const Duration(milliseconds: 50));
    
    Util.termWrite("echo 'export VK_ICD_FILENAMES=${G.dataPath}/usr/share/vulkan/icd.d/virtio_icd.aarch64.json' >> ${G.dataPath}/usr/opt/drv");
    await Future.delayed(const Duration(milliseconds: 50));
    
    Util.termWrite("export VN_DEBUG=vtest");  
    await Future.delayed(const Duration(milliseconds: 50));
  
    Util.termWrite("echo '#================================'");
          
    // Update status after starting
    await Future.delayed(const Duration(seconds: 1));
    await _updateVenusServerStatus();
  }

  Future<void> _extractDriver() async {
    try {
      if (_selectedDriverFile == null || _driversDirectory == null) {
        throw Exception('Please select a driver file');
      }
      
      final driverPath = '$_driversDirectory/$_selectedDriverFile';
      final file = File(driverPath);
      
      if (!await file.exists()) {
        throw Exception('File not found: $driverPath');
      }
      
      G.pageIndex.value = 0;
      
      await Future.delayed(const Duration(milliseconds: 300));
      
      Util.termWrite("echo '#================================'");
      await Future.delayed(const Duration(milliseconds: 50));
      
      Util.termWrite("echo 'Extracting GPU driver: $_selectedDriverFile'");
      await Future.delayed(const Duration(milliseconds: 50));
      
      Util.termWrite("echo '#================================'");
      await Future.delayed(const Duration(milliseconds: 50));
      
      Util.termWrite("mkdir -p ${G.dataPath}/usr/share/vulkan/icd.d");
      await Future.delayed(const Duration(milliseconds: 50));
      
      String containerPath = "${G.dataPath}/usr/drivers/files/$_selectedDriverFile";
      
      // Extract based on file extension
      if (_selectedDriverFile!.endsWith('.zip')) {
        Util.termWrite("unzip -o '$containerPath' -d '${G.dataPath}/usr'");
      } else if (_selectedDriverFile!.endsWith('.7z')) {
        Util.termWrite("7z x '$containerPath' -o'${G.dataPath}/usr' -y");
      } else if (_selectedDriverFile!.endsWith('.tar.gz') || _selectedDriverFile!.endsWith('.tgz')) {
        Util.termWrite("tar -xzf '$containerPath' -C '${G.dataPath}/usr'");
      } else if (_selectedDriverFile!.endsWith('.tar.xz') || _selectedDriverFile!.endsWith('.txz')) {
        Util.termWrite("tar -xJf '$containerPath' -C '${G.dataPath}/usr'");
      } else if (_selectedDriverFile!.endsWith('.json')) {
        // For JSON files (like turnip ICD files), copy to icd.d directory
        Util.termWrite("cp '$containerPath' '${G.dataPath}/usr/share/vulkan/icd.d/'");
      } else {
        Util.termWrite("tar -xf '$containerPath' -C '${G.dataPath}/usr'");
      }
      
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Special handling for turnip drivers
      if (_selectedDriverType == 'turnip' && _selectedDriverFile!.endsWith('.json')) {
        // Rename the turnip JSON file to the standard freedreno name
        Util.termWrite("mv '${G.dataPath}/usr/share/vulkan/icd.d/$_selectedDriverFile' "
                      "'${G.dataPath}/usr/share/vulkan/icd.d/freedreno_icd.aarch64.json'");
        await Future.delayed(const Duration(milliseconds: 50));
      }
      
      await _applyGpuSettings();
      
    } catch (e) {
      print('Error in _extractDriver: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error extracting driver: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _loadDriverFiles() async {
    try {
      String hostDir = "${G.dataPath}/usr/drivers/files";
      
      final dir = Directory(hostDir);
      if (!await dir.exists()) {
        print('Drivers directory not found at: $hostDir');
        setState(() {
          _driverFiles = [];
          _driversDirectory = hostDir;
          _isLoading = false;
        });
        return;
      }
      
      _driversDirectory = hostDir;
      print('Found drivers directory at: $hostDir');
      
      final files = await dir.list().toList();
      
      final allDriverFiles = files
          .where((file) => file is File && 
              RegExp(r'\.(tzst|tar\.gz|tgz|tar\.xz|txz|tar|zip|7z|json|so|ko)$').hasMatch(file.path))
          .map((file) => file.path.split('/').last)
          .toList();
      
      setState(() {
        _driverFiles = allDriverFiles;
        if (allDriverFiles.isNotEmpty) {
          _selectedDriverFile = G.prefs.getString('selected_gpu_driver');
          
          if (_selectedDriverFile == null) {
            _filterDriverFiles();
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading driver files: $e');
      setState(() {
        _driverFiles = [];
        _isLoading = false;
      });
    }
  }

  void _filterDriverFiles() {
    List<String> filteredFiles = [];
    
    if (_selectedDriverType == 'turnip') {
      filteredFiles = _driverFiles.where((file) => 
          file.toLowerCase().contains('turnip') ||
          file.toLowerCase().contains('freedreno') ||
          file.endsWith('.json')).toList();
    } else if (_selectedDriverType == 'wrapper') {
      filteredFiles = _driverFiles.where((file) => 
          file.toLowerCase().contains('wrapper')).toList();
    }
    
    if (filteredFiles.isNotEmpty) {
      setState(() {
        _selectedDriverFile = filteredFiles.first;
      });
    }
  }

  void _onDriverTypeChanged(String? newType) {
    if (newType != null) {
      setState(() {
        _selectedDriverType = newType;
        _selectedDriverFile = null;
        _filterDriverFiles();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('GPU Drivers'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Driver Type',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedDriverType,
                        decoration: const InputDecoration(
                          labelText: 'Select Driver Type',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'virgl',
                            child: Row(
                              children: [
                                Icon(Icons.hardware, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('VirGL (Virtual GL)'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'turnip',
                            child: Row(
                              children: [
                                Icon(Icons.grain, color: Colors.purple),
                                SizedBox(width: 8),
                                Text('Turnip (Vulkan)'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'venus',
                            child: Row(
                              children: [
                                Icon(Icons.hardware, color: Colors.orange),
                                SizedBox(width: 8),
                                Text('Venus (Vulkan)'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'wrapper',
                            child: Row(
                              children: [
                                Icon(Icons.wrap_text, color: Colors.green),
                                SizedBox(width: 8),
                                Text('Wrapper'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: _onDriverTypeChanged,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              if (_selectedDriverType == 'venus')
                Card(
                  color: Colors.orange[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange[800]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Experimental Feature Under Development',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[900],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Venus driver is currently in development. Features may be unstable or incomplete.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              if (_selectedDriverType == 'virgl')
                Card(
                  color: _virglServerRunning ? Colors.green[50] : Colors.red[50],
                  child: ListTile(
                    leading: Icon(
                      _virglServerRunning ? Icons.check_circle : Icons.error,
                      color: _virglServerRunning ? Colors.green : Colors.red,
                    ),
                    title: const Text('VirGL Server'),
                    subtitle: Text(
                      _virglServerRunning ? 'Running' : 'Not running',
                      style: TextStyle(
                        color: _virglServerRunning ? Colors.green : Colors.red,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            _startVirglServer();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Restarting VirGL server...'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.stop),
                          onPressed: _virglServerRunning ? () async {
                            Util.termWrite("pkill -f virgl_test_server");
                            await Future.delayed(const Duration(seconds: 1));
                            await _updateVirglServerStatus();
                          } : null,
                        ),
                      ],
                    ),
                  ),
                ),
              
              if (_selectedDriverType == 'venus')
                Card(
                  color: _venusServerRunning ? Colors.green[50] : Colors.red[50],
                  child: ListTile(
                    leading: Icon(
                      _venusServerRunning ? Icons.check_circle : Icons.error,
                      color: _venusServerRunning ? Colors.green : Colors.red,
                    ),
                    title: const Text('Venus Server'),
                    subtitle: Text(
                      _venusServerRunning ? 'Running' : 'Not running',
                      style: TextStyle(
                        color: _venusServerRunning ? Colors.green : Colors.red,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            _startVenusServer();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Restarting Venus server...'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.stop),
                          onPressed: _venusServerRunning ? () async {
                            Util.termWrite("pkill -f virgl_test_server");
                            await Future.delayed(const Duration(seconds: 1));
                            await _updateVenusServerStatus();
                          } : null,
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Add driver file selection for both turnip and wrapper
              if (_selectedDriverType == 'wrapper' || _selectedDriverType == 'turnip')
                _buildDriverFileSelection(),
              
              if (_selectedDriverType == 'turnip') _buildTurnipSettings(),
              if (_selectedDriverType == 'virgl') _buildVirglSettings(),
              if (_selectedDriverType == 'venus') _buildVenusSettings(),
              if (_selectedDriverType == 'wrapper') _buildWrapperSettings(),
              
              if (_selectedDriverType == 'turnip')
                Card(
                  child: SwitchListTile(
                    title: const Text('Enable DRI3 for Turnip'),
                    subtitle: const Text('Direct Rendering Infrastructure v3'),
                    value: _turnipDri3Enabled,
                    onChanged: _isX11Enabled 
                        ? (value) {
                            setState(() {
                              _turnipDri3Enabled = value;
                            });
                          }
                        : null,
                  ),
                ),
              
              if (_selectedDriverType == 'wrapper')
                Card(
                  child: SwitchListTile(
                    title: const Text('Enable DRI3 for Wrapper'),
                    subtitle: const Text('Direct Rendering Infrastructure v3'),
                    value: _wrapperDri3Enabled,
                    onChanged: _isX11Enabled 
                        ? (value) {
                            setState(() {
                              _wrapperDri3Enabled = value;
                            });
                          }
                        : null,
                  ),
                ),
              
              if (_selectedDriverType == 'venus')
                Card(
                  child: SwitchListTile(
                    title: const Text('Enable DRI3 for Venus'),
                    subtitle: const Text('Direct Rendering Infrastructure v3'),
                    value: _venusDri3Enabled,
                    onChanged: _isX11Enabled 
                        ? (value) {
                            setState(() {
                              _venusDri3Enabled = value;
                            });
                          }
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveAndExtract,
          child: const Text('Save & Apply'),
        ),
      ],
    );
  }

  Widget _buildTurnipSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Turnip Settings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_selectedDriverFile == null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Using built-in Turnip from: ${G.dataPath}/usr/share/vulkan/icd.d/freedreno_icd.aarch64.json',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_selectedDriverFile != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Using custom Turnip driver: $_selectedDriverFile',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            TextFormField(
              maxLines: 2,
              initialValue: _defaultTurnipOpt,
              decoration: const InputDecoration(
                labelText: 'Turnip Environment Variables (without VK_ICD_FILENAMES)',
                hintText: 'Example: MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _defaultTurnipOpt = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVirglSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'VirGL Settings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              maxLines: 2,
              initialValue: _defaultVirglCommand,
              decoration: const InputDecoration(
                labelText: 'VirGL Server Parameters',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) async {
                setState(() {
                  _defaultVirglCommand = value;
                });
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              maxLines: 2,
              initialValue: _defaultVirglOpt,
              decoration: const InputDecoration(
                labelText: 'VirGL Environment Variables',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) async {
                setState(() {
                  _defaultVirglOpt = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenusSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Venus Settings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              maxLines: 2,
              initialValue: _defaultVenusCommand,
              decoration: const InputDecoration(
                labelText: 'Venus Server Parameters',
                hintText: 'Example: --no-virgl --venus --socket-path=\$CONTAINER_DIR/tmp/.virgl_test',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _defaultVenusCommand = value;
                });
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              maxLines: 2,
              initialValue: _defaultVenusOpt,
              decoration: const InputDecoration(
                labelText: 'Venus Environment Variables',
                hintText: 'Example: ANDROID_VENUS=1',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _defaultVenusOpt = value;
                });
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Enable Android Venus'),
              subtitle: const Text('Use Android\'s Vulkan driver (requires Android 10+)'),
              value: _androidVenusEnabled,
              onChanged: (value) {
                setState(() {
                  _androidVenusEnabled = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWrapperSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wrapper Driver Settings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Wrapper driver provides compatibility layer for specific GPU architectures.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverFileSelection() {
    List<String> filteredFiles = _driverFiles.where((file) {
      if (_selectedDriverType == 'turnip') {
        return file.toLowerCase().contains('turnip') ||
               file.toLowerCase().contains('freedreno') ||
               file.endsWith('.json');
      } else if (_selectedDriverType == 'wrapper') {
        return file.toLowerCase().contains('wrapper');
      }
      return false;
    }).toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedDriverType == 'turnip' 
                ? 'Select Turnip Driver File'
                : 'Select Wrapper Driver File',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            
            if (!_isLoading && filteredFiles.isEmpty)
              Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.orange, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    _selectedDriverType == 'turnip'
                      ? 'No turnip driver files found'
                      : 'No wrapper driver files found',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedDriverType == 'turnip'
                      ? 'Please place turnip driver files in the drivers folder'
                      : 'Please place wrapper driver files in the drivers folder',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    onPressed: _loadDriverFiles,
                  ),
                ],
              ),
            
            if (!_isLoading && filteredFiles.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _selectedDriverFile,
                decoration: InputDecoration(
                  labelText: _selectedDriverType == 'turnip'
                    ? 'Turnip Driver File'
                    : 'Wrapper Driver File',
                  border: const OutlineInputBorder(),
                ),
                items: filteredFiles.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDriverFile = newValue;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}