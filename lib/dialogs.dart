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
    
    Util.termWrite("echo '' > /opt/hud");
    await Future.delayed(const Duration(milliseconds: 50));
    
    Util.termWrite("echo '#================================'");
    await Future.delayed(const Duration(milliseconds: 50));
    
    if (_currentMangohudEnabled) {
      Util.termWrite("echo 'export MANGOHUD=1' >> /opt/hud");
      await Future.delayed(const Duration(milliseconds: 50));
      Util.termWrite("echo 'export MANGOHUD_DLSYM=1' >> /opt/hud");
      await Future.delayed(const Duration(milliseconds: 50));
      Util.termWrite("echo '# MANGOHUD enabled' >> /opt/hud");
    } else {
      Util.termWrite("echo 'export MANGOHUD=0' >> /opt/hud");
      await Future.delayed(const Duration(milliseconds: 50));
      Util.termWrite("echo 'export MANGOHUD_DLSYM=0' >> /opt/hud");
      await Future.delayed(const Duration(milliseconds: 50));
      Util.termWrite("echo '# MANGOHUD disabled' >> /opt/hud");
    }
    
    if (_currentDxvkHudEnabled) {
      Util.termWrite("echo 'export DXVK_HUD=fps,version,devinfo' >> /opt/hud");
      await Future.delayed(const Duration(milliseconds: 50));
      Util.termWrite("echo '# DXVK HUD enabled' >> /opt/hud");
    } else {
      Util.termWrite("echo 'export DXVK_HUD=0' >> /opt/hud");
      await Future.delayed(const Duration(milliseconds: 50));
      Util.termWrite("echo '# DXVK HUD disabled' >> /opt/hud");
    }
    
    Util.termWrite("echo 'HUD settings saved to /opt/hud'");
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
    
    Util.termWrite("mkdir -p /home/xodos/.wine/drive_c/windows");
    await Future.delayed(const Duration(milliseconds: 50));
    
    String containerPath = "/wincomponents/d3d/$fileName";
    
    if (fileName.endsWith('.zip')) {
      Util.termWrite("unzip -o '$containerPath' -d '/home/xodos/.wine/drive_c/windows'");
    } else if (fileName.endsWith('.7z')) {
      Util.termWrite("7z x '$containerPath' -o'/home/xodos/.wine/drive_c/windows' -y");
    } else {
      Util.termWrite("tar -xaf '$containerPath' -C '/home/xodos/.wine/drive_c/windows'");
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
            content: Text('HUD settings saved to /opt/hud'),
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
      String hostDir = "$containerDir/wincomponents/d3d";
      
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
                            'HUD Settings (Saved to /opt/hud)',
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
                                        ? 'HUD settings will be saved to /opt/hud'
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
    'WINEDEBUG',
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
    '-all', 'err', 'warn', 'fixme', 'all', 'trace', 'message', 'heap', 'fps'
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
    
    Util.termWrite("echo '' > /opt/dyna");
    Util.termWrite("echo '' > /opt/sync");
    Util.termWrite("echo '' > /opt/cores");
    Util.termWrite("echo '' > /opt/env");
    Util.termWrite("echo '' > /opt/dbg");
    Util.termWrite("echo '' > /opt/hud");
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    for (final variable in _dynarecVariables) {
      final name = variable['name'] as String;
      final defaultValue = variable['defaultValue'] as String;
      final savedValue = G.prefs.getString('dynarec_$name') ?? defaultValue;
      
      Util.termWrite("echo 'export $name=$savedValue' >> /opt/dyna");
      await Future.delayed(const Duration(milliseconds: 10));
    }
    
    if (_wineEsyncEnabled) {
      Util.termWrite("echo 'export WINEESYNC=1' >> /opt/sync");
      Util.termWrite("echo 'export WINEESYNC_TERMUX=1' >> /opt/sync");
    } else {
      Util.termWrite("echo 'export WINEESYNC=0' >> /opt/sync");
      Util.termWrite("echo 'export WINEESYNC_TERMUX=0' >> /opt/sync");
    }
    
    Util.termWrite("echo 'export PRIMARY_CORES=${_getCoreString()}' >> /opt/cores");
    
    for (final variable in _customVariables) {
      Util.termWrite("echo 'export ${variable['name']}=${variable['value']}' >> /opt/env");
      await Future.delayed(const Duration(milliseconds: 10));
    }
    
    if (_debugEnabled) {
      Util.termWrite("echo 'export MESA_NO_ERROR=0' >> /opt/dbg");
      Util.termWrite("echo 'export WINEDEBUG=$_winedebugValue' >> /opt/dbg");
      Util.termWrite("echo 'export BOX64_LOG=1' >> /opt/dbg");
      Util.termWrite("echo 'export BOX64_NOBANNER=0' >> /opt/dbg");
      Util.termWrite("echo 'export BOX64_SHOWSEGV=1' >> /opt/dbg");
      Util.termWrite("echo 'export BOX64_DLSYM_ERROR=1' >> /opt/dbg");
      Util.termWrite("echo 'export BOX64_DYNAREC_MISSING=1' >> /opt/dbg");
    } else {
      Util.termWrite("echo 'export MESA_NO_ERROR=1' >> /opt/dbg");
      Util.termWrite("echo 'export WINEDEBUG=$_winedebugValue' >> /opt/dbg");
      Util.termWrite("echo 'export BOX64_LOG=0' >> /opt/dbg");
      Util.termWrite("echo 'export BOX64_NOBANNER=1' >> /opt/dbg");
      Util.termWrite("echo 'export BOX64_SHOWSEGV=0' >> /opt/dbg");
      Util.termWrite("echo 'export BOX64_DLSYM_ERROR=0' >> /opt/dbg");
      Util.termWrite("echo 'export BOX64_DYNAREC_MISSING=0' >> /opt/dbg");
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
  String _selectedDriverType = 'virgl';
  String? _selectedDriverFile;
  List<String> _driverFiles = [];
  String? _driversDirectory;
  bool _isLoading = true;
  
  bool _useBuiltInTurnip = true;
  bool _driEnabled = false;
  
  bool _virglEnabled = false;
  bool _turnipEnabled = false;
  bool _dri3Enabled = false;
  String _defaultTurnipOpt = 'MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform';
bool _isX11Enabled = false;

@override
void initState() {
  super.initState();
  _loadSavedSettings();
  _loadDriverFiles();
  // Add mutual exclusivity check
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _ensureMutualExclusivity();
  });
}

void _ensureMutualExclusivity() {
  // If both are enabled from saved settings, disable one
  if (_virglEnabled && _turnipEnabled) {
    setState(() {
      _turnipEnabled = false;
      _dri3Enabled = false; // DRI3 requires turnip
    });
  }
}

  Future<void> _loadSavedSettings() async {
    try {
      _virglEnabled = G.prefs.getBool('virgl') ?? false;
      _turnipEnabled = G.prefs.getBool('turnip') ?? false;
      _dri3Enabled = G.prefs.getBool('dri3') ?? false;
      _isX11Enabled = G.prefs.getBool('useX11') ?? false; // termux x11
      String savedTurnipOpt = G.prefs.getString('defaultTurnipOpt') ?? 'MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform';
      _defaultTurnipOpt = _removeVkIcdFromEnvString(savedTurnipOpt);
      
      if (_defaultTurnipOpt.isEmpty) {
        _defaultTurnipOpt = 'MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform';
      }
      
      _selectedDriverType = G.prefs.getString('gpu_driver_type') ?? 'virgl';
      _selectedDriverFile = G.prefs.getString('selected_gpu_driver');
      _useBuiltInTurnip = G.prefs.getBool('use_builtin_turnip') ?? true;
      _driEnabled = G.prefs.getBool('gpu_dri_enabled') ?? false;
      
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
      // Enforce mutual exclusivity one more time before saving
    if (_virglEnabled && _turnipEnabled) {
      // If somehow both are enabled, disable turnip (virgl takes precedence in this dialog)
      _turnipEnabled = false;
      _dri3Enabled = false;
      _driEnabled = false;
    }
    
    // If DRI3 is enabled but requirements aren't met, disable it
    if (_dri3Enabled && !(_turnipEnabled && _isX11Enabled)) {
      _dri3Enabled = false;
      _driEnabled = false;
    }
    try {
      await G.prefs.setString('gpu_driver_type', _selectedDriverType);
      if (_selectedDriverFile != null) {
        await G.prefs.setString('selected_gpu_driver', _selectedDriverFile!);
      }
      await G.prefs.setBool('use_builtin_turnip', _useBuiltInTurnip);
      await G.prefs.setBool('gpu_dri_enabled', _driEnabled);
      
      await G.prefs.setBool('virgl', _virglEnabled);
      await G.prefs.setBool('turnip', _turnipEnabled);
      await G.prefs.setBool('dri3', _dri3Enabled);
      
      String cleanTurnipOpt = _removeVkIcdFromEnvString(_defaultTurnipOpt);
      if (cleanTurnipOpt.isEmpty) {
        cleanTurnipOpt = 'MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform';
      }
      await G.prefs.setString('defaultTurnipOpt', cleanTurnipOpt);
      
      G.pageIndex.value = 0;
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (!(_selectedDriverType == 'turnip' && _useBuiltInTurnip) && 
          _selectedDriverFile != null) {
        await _extractDriver();
      } else {
        await _applyGpuSettings();
      }
      
      if (_virglEnabled && _selectedDriverType == 'virgl') {
        final virglCommand = G.prefs.getString('defaultVirglCommand') ?? '--use-egl-surfaceless --use-gles --socket-path=\$CONTAINER_DIR/tmp/.virgl_test';
        await _startVirglServer(virglCommand);
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
    
    Util.termWrite("echo '' > /opt/drv");
    
    if (_selectedDriverType == 'turnip') {
      await _applyTurnipSettings();
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
  String dataDir = G.dataPath;
  String containerDir = "$dataDir/containers/${G.currentContainer}";
  
  // remove the .vdrv file using 
  Util.termWrite("rm -rf '$containerDir/.vdrv'");
  await Future.delayed(const Duration(milliseconds: 50));
  
    if (_useBuiltInTurnip) {
      Util.termWrite("echo 'export VK_ICD_FILENAMES=/home/tiny/.local/share/tiny/extra/freedreno_icd.aarch64.json' >> /opt/drv");
    } else if (_selectedDriverFile != null) {
      Util.termWrite("echo 'export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/freedreno_icd.aarch64.json' >> /opt/drv");
    }
    
    if (_turnipEnabled) {
      String cleanTurnipOpt = _removeVkIcdFromEnvString(_defaultTurnipOpt);
      
      if (cleanTurnipOpt.isNotEmpty) {
        Util.termWrite("echo 'export $cleanTurnipOpt' >> /opt/drv");
      }
      
      if (!_dri3Enabled) {
        Util.termWrite("echo 'export MESA_VK_WSI_DEBUG=sw' >> /opt/drv");
      }
    }
  }

  Future<void> _applyVirglSettings() async {
  String dataDir = G.dataPath;
  String containerDir = "$dataDir/containers/${G.currentContainer}";
  
  // remove the .vdrv file using 
  Util.termWrite("rm -rf '$containerDir/.vdrv'");
  await Future.delayed(const Duration(milliseconds: 50));
  
    if (_virglEnabled) {
      final virglCommand = G.prefs.getString('defaultVirglCommand') ?? '--use-egl-surfaceless --use-gles --socket-path=\$CONTAINER_DIR/tmp/.virgl_test';
      final virglEnv = G.prefs.getString('defaultVirglOpt') ?? 'GALLIUM_DRIVER=virpipe';
      
      Util.termWrite("echo 'export $virglEnv' >> /opt/drv");
      await Future.delayed(const Duration(milliseconds: 50));
      
      if (_selectedDriverFile != null) {
        Util.termWrite("echo '# Custom VirGL driver: $_selectedDriverFile' >> /opt/drv");
      }
    }
  }

  Future<void> _startVirglServer(String virglCommand) async {
    G.pageIndex.value = 0;
    await Future.delayed(const Duration(milliseconds: 300));
    
    Util.termWrite("pkill -f virgl_test_server");
    await Future.delayed(const Duration(milliseconds: 100));
    
    Util.termWrite("echo '#================================'");
    await Future.delayed(const Duration(milliseconds: 50));
    
    Util.termWrite("echo 'Starting VirGL server...'");
    await Future.delayed(const Duration(milliseconds: 50));
    
    Util.termWrite("mkdir -p /tmp/.virgl_test");
    await Future.delayed(const Duration(milliseconds: 50));
    
    String dataDir = G.dataPath;
    String containerDir = "$dataDir/containers/${G.currentContainer}";
    
    String processedCommand = virglCommand.replaceAll('\$CONTAINER_DIR', containerDir);
    
    Util.termWrite("echo 'Using data directory: $dataDir'");
    await Future.delayed(const Duration(milliseconds: 50));
    
    Util.termWrite("echo 'Container directory: $containerDir'");
    await Future.delayed(const Duration(milliseconds: 50));
    
    Util.termWrite("$dataDir/bin/virgl_test_server $processedCommand &");
    
    await Future.delayed(const Duration(milliseconds: 50));
    
    Util.termWrite("sleep 1 && if pgrep -f virgl_test_server > /dev/null; then echo 'VirGL server started successfully'; else echo 'Failed to start VirGL server'; fi");
    
    await Future.delayed(const Duration(milliseconds: 50));
    Util.termWrite("echo '#================================'");
  }

  Future<void> _applyWrapperSettings() async {
  // Clear the drv file first
  Util.termWrite("echo '' > /opt/drv");
  await Future.delayed(const Duration(milliseconds: 50));
  
  // Create .vdrv file in the container directory
  String dataDir = G.dataPath;
  String containerDir = "$dataDir/containers/${G.currentContainer}";
  
  // Create the .vdrv file using touch command
  Util.termWrite("touch '$containerDir/.vdrv'");
  await Future.delayed(const Duration(milliseconds: 50));
  
  // Write environment variables to /opt/drv
  Util.termWrite("echo '#================================' >> /opt/drv");
  await Future.delayed(const Duration(milliseconds: 50));
  
  Util.termWrite("echo '# Wrapper driver configuration' >> /opt/drv");
  await Future.delayed(const Duration(milliseconds: 50));
  
  Util.termWrite("echo 'export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/virtio_icd.aarch64.json' >> /opt/drv");
  await Future.delayed(const Duration(milliseconds: 50));
  
  Util.termWrite("echo 'export VORTEK_SERVER_PATH=/tmp/.vortek/V0' >> /opt/drv");
  await Future.delayed(const Duration(milliseconds: 50));
  
  Util.termWrite("echo 'export GALLIUM_DRIVER=zink' >> /opt/drv");
  await Future.delayed(const Duration(milliseconds: 50));
  
  // Additional wrapper-specific environment variables

  Util.termWrite("echo 'export TU_DEBUG=noconform' >> /opt/drv");
  await Future.delayed(const Duration(milliseconds: 50));
  
  Util.termWrite("7z x '/drivers/vortex' -o'/usr/lib' -y");
  await Future.delayed(const Duration(milliseconds: 50));
  
  Util.termWrite("echo '#================================' >> /opt/drv");
  await Future.delayed(const Duration(milliseconds: 50));
  
  // Verify the files were created
  Util.termWrite("echo 'Wrapper driver configuration complete'");
  await Future.delayed(const Duration(milliseconds: 50));
  
  Util.termWrite("if [ -f '$containerDir/.vdrv' ]; then echo '.vdrv file created successfully'; else echo 'Failed to create .vdrv file'; fi");
  await Future.delayed(const Duration(milliseconds: 50));
  
  Util.termWrite("if [ -s /opt/drv ]; then echo '/opt/drv file updated successfully'; else echo 'Failed to update /opt/drv file'; fi");
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
      
      Util.termWrite("mkdir -p /usr/share/vulkan/icd.d");
      await Future.delayed(const Duration(milliseconds: 50));
      
      String containerPath = "/drivers/$_selectedDriverFile";
      
      if (_selectedDriverFile!.endsWith('.zip')) {
        Util.termWrite("unzip -o '$containerPath' -d '/usr'");
      } else if (_selectedDriverFile!.endsWith('.7z')) {
        Util.termWrite("7z x '$containerPath' -o'/usr' -y");
      } else if (_selectedDriverFile!.endsWith('.tar.gz') || _selectedDriverFile!.endsWith('.tgz')) {
        Util.termWrite("tar -xzf '$containerPath' -C '/usr'");
      } else if (_selectedDriverFile!.endsWith('.tar.xz') || _selectedDriverFile!.endsWith('.txz')) {
        Util.termWrite("tar -xJf '$containerPath' -C '/usr'");
      } else {
        Util.termWrite("tar -xf '$containerPath' -C '/usr'");
      }
      
      await Future.delayed(const Duration(milliseconds: 50));
      
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
      String containerDir = "${G.dataPath}/containers/${G.currentContainer}";
      String hostDir = "$containerDir/drivers";
      
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
          file.toLowerCase().contains('freedreno')).toList();
    } else if (_selectedDriverType == 'virgl') {
      filteredFiles = _driverFiles.where((file) => 
          file.toLowerCase().contains('virgl') || 
          file.toLowerCase().contains('virtio')).toList();
    } else if (_selectedDriverType == 'wrapper') {
      filteredFiles = _driverFiles.where((file) => 
          file.toLowerCase().contains('wrapper') || 
          file.toLowerCase().contains('wine')).toList();
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
        _useBuiltInTurnip = (newType == 'turnip');
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
              
              if (_selectedDriverType == 'virgl')
                Card(
                  child: ListTile(
                    title: const Text('VirGL Server'),
                    subtitle: Text(_virglEnabled ? 'Enabled - Click restart to start server' : 'Disabled - Enable VirGL above'),
                    trailing: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        if (_virglEnabled) {
                          final virglCommand = G.prefs.getString('defaultVirglCommand') ?? '--use-egl-surfaceless --use-gles --socket-path=\$CONTAINER_DIR/tmp/.virgl_test';
                          _startVirglServer(virglCommand);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Restarting VirGL server...'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 16),
                          
              if (_selectedDriverType == 'turnip') _buildTurnipSettings(),
              if (_selectedDriverType == 'virgl') _buildVirglSettings(),
              if (_selectedDriverType == 'wrapper') _buildWrapperSettings(),
              
              if (!(_selectedDriverType == 'turnip' && _useBuiltInTurnip))
                _buildDriverFileSelection(),
              
              if (_selectedDriverType == 'turnip' || _selectedDriverType == 'virgl')
  Card(
    child: SwitchListTile(
      title: const Text('Enable DRI3'),
      subtitle: const Text('Direct Rendering Infrastructure v3'),
      value: _driEnabled,
      onChanged: (_selectedDriverType == 'turnip' && _turnipEnabled && _isX11Enabled) 
          ? (value) {
              setState(() {
                _driEnabled = value;
                _dri3Enabled = value;
              });
            }
          : null,
    ),
  ),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Graphics Acceleration',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('Enable VirGL'),
                        subtitle: const Text('Virtual OpenGL acceleration'),
                        value: _virglEnabled,
                        onChanged: _selectedDriverType == 'virgl' ? (value) {
                          setState(() {
                            _virglEnabled = value;
                              if (value) {
        // If enabling virgl, disable turnip and DRI3
        _turnipEnabled = false;
        _dri3Enabled = false;
        _driEnabled = false;
      }
                          });
                        } : null,
                      ),
                      SwitchListTile(
                        title: const Text('Enable Turnip/Zink'),
                        subtitle: const Text('Vulkan via Zink driver'),
                        value: _turnipEnabled,
                        onChanged: _selectedDriverType == 'turnip' ? (value) {
                          setState(() {
                          if (value) {
        // If enabling turnip, disable virgl
        _virglEnabled = false;
      } else {
        // If disabling turnip, also disable DRI3
        _dri3Enabled = false;
        _driEnabled = false;
      }
                            _turnipEnabled = value;
                            if (!value && _dri3Enabled) {
                              _dri3Enabled = false;
                            }
                          });
                        } : null,
                      ),
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
          onPressed: _saveAndExtract,
          child: const Text('Save & Apply'),
        ),
      ],
    );
  }

  Widget _buildTurnipSettings() {
  //G.prefs.setBool("virgl", false);
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: _useBuiltInTurnip ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _useBuiltInTurnip ? Colors.blue : Colors.grey,
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _useBuiltInTurnip = true;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Radio<bool>(
                              value: true,
                              groupValue: _useBuiltInTurnip,
                              onChanged: (value) {
                                setState(() {
                                  _useBuiltInTurnip = value ?? true;
                                });
                              },
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Built-in Turnip',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _useBuiltInTurnip ? Colors.blue : Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    'Use bundled driver',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _useBuiltInTurnip ? Colors.blue : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: !_useBuiltInTurnip ? Colors.purple.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: !_useBuiltInTurnip ? Colors.purple : Colors.grey,
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _useBuiltInTurnip = false;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Radio<bool>(
                              value: false,
                              groupValue: _useBuiltInTurnip,
                              onChanged: (value) {
                                setState(() {
                                  _useBuiltInTurnip = value ?? false;
                                });
                              },
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Custom Driver',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: !_useBuiltInTurnip ? Colors.purple : Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    'Extract from drivers folder',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: !_useBuiltInTurnip ? Colors.purple : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (!_useBuiltInTurnip) ...[
              const SizedBox(height: 8),
              const Divider(),
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
          ],
        ),
      ),
    );
  }

  Widget _buildVirglSettings() {
    final defaultVirglCommand = G.prefs.getString('defaultVirglCommand') ?? '--use-egl-surfaceless --use-gles --socket-path=\$CONTAINER_DIR/tmp/.virgl_test';
    final defaultVirglOpt = G.prefs.getString('defaultVirglOpt') ?? 'GALLIUM_DRIVER=virpipe';
  //  G.prefs.setBool("turnip", false);
    // Also disable DRI3 if it was enabled (since it requires turnip)
//    if (Util.getGlobal("dri3")) {
//      G.prefs.setBool("dri3", false);
//    }
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
              initialValue: defaultVirglCommand,
              decoration: const InputDecoration(
                labelText: 'VirGL Server Parameters',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) async {
                await G.prefs.setString('defaultVirglCommand', value);
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              maxLines: 2,
              initialValue: defaultVirglOpt,
              decoration: const InputDecoration(
                labelText: 'VirGL Environment Variables',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) async {
                await G.prefs.setString('defaultVirglOpt', value);
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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Note:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '• Creates .vdrv marker file in container directory',
                  style: TextStyle(fontSize: 12),
                ),
                const Text(
                  '• Exports environment variables to /opt/drv',
                  style: TextStyle(fontSize: 12),
                ),
                const Text(
                  '• Sets up wrapper-specific environment variables',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildDriverFileSelection() {
    List<String> filteredFiles = [];
    
    if (_selectedDriverType == 'turnip') {
      filteredFiles = _driverFiles.where((file) => 
          file.toLowerCase().contains('turnip') || 
          file.toLowerCase().contains('freedreno')).toList();
    } else if (_selectedDriverType == 'virgl') {
      filteredFiles = _driverFiles.where((file) => 
          file.toLowerCase().contains('virgl') || 
          file.toLowerCase().contains('virtio')).toList();
    } else if (_selectedDriverType == 'wrapper') {
      filteredFiles = _driverFiles.where((file) => 
          file.toLowerCase().contains('wrapper') || 
          file.toLowerCase().contains('wine')).toList();
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Driver File',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            
            if (!_isLoading && filteredFiles.isEmpty)
              const Column(
                children: [
                  Icon(Icons.error_outline, color: Colors.orange, size: 48),
                  SizedBox(height: 8),
                  Text(
                    'No driver files found',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Please place driver files in the drivers folder',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            
            if (!_isLoading && filteredFiles.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _selectedDriverFile,
                decoration: const InputDecoration(
                  labelText: 'Driver File',
                  border: OutlineInputBorder(),
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

  Future<String> _checkVirglServerStatus() async {
    try {
      final result = await Process.run('sh', ['-c', 'pgrep -f virgl_test_server']);
      final isRunning = result.stdout.toString().trim().isNotEmpty;
      
      return isRunning ? 'Running' : 'Not running';
    } catch (e) {
      if (_virglEnabled && _selectedDriverType == 'virgl') {
        return 'Enabled (status unknown)';
      }
      return 'Disabled';
    }
  }
}