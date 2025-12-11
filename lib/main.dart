import 'dart:async';

import 'dart:io';
import 'package:flutter/material.dart';
import 'spirited_mini_games.dart'; // 
import 'package:audioplayers/audioplayers.dart';
import 'dart:io'; // Add this line
import 'dart:math';
import 'package:flutter/services.dart'; // Add this import
import 'package:clipboard/clipboard.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/gestures.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:xterm/xterm.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:xodos/l10n/app_localizations.dart';

import 'package:xodos/workflow.dart';

import 'package:avnc_flutter/avnc_flutter.dart';
import 'package:x11_flutter/x11_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('pt'),
        Locale('ru'),
        Locale('fr'),
        Locale('ja'),
        Locale('hi'),
        Locale('ar'),
        Locale.fromSubtags(languageCode: 'zh'),
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN'),
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'HK'),
      ],
      theme: _buildDarkTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.dark,
      home: const MyHomePage(title: "XoDos"),
    );
  }

  ThemeData _buildDarkTheme() {
    final baseTheme = ThemeData.dark(useMaterial3: true);
    
    return baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: Colors.blue,
        secondary: Colors.green,
        surface: const Color(0xFF121212),
        background: const Color(0xFF121212),
        onBackground: Colors.white,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: baseTheme.cardTheme.copyWith(
        color: const Color(0xFF1E1E1E),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dialogTheme: baseTheme.dialogTheme.copyWith(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
}



// Add this AppColors class at the top of the file
class AppColors {
  static const Color primaryPurple = Color(0xFFBB86FC);
  static const Color primaryDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF252525);
  static const Color accentPurple = Color(0xFF9C27B0);
  static const Color textPrimary = Color(0xFFE1E1E1);
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color divider = Color(0xFF333333);
  static const Color hoverColor = Color(0xFF2D2D2D);
  static const Color pressedColor = Color(0xFF3A3A3A);
}

// Add this DxvkDialog class
// DxvkDialog class with HUD settings to /opt/hud and automatic vkd3d/d8vk extraction
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
      // Load saved HUD preferences
      _savedMangohudEnabled = G.prefs.getBool('mangohud_enabled') ?? false;
      _savedDxvkHudEnabled = G.prefs.getBool('dxvkhud_enabled') ?? false;
      
      // Load saved DXVK selection
      _savedSelectedDxvk = G.prefs.getString('selected_dxvk');
      
      // Set current states from saved values
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
    // Switch to terminal tab
    G.pageIndex.value = 0;
    
    // Wait a moment for tab switch
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Clear the hud file first
    Util.termWrite("echo '' > /opt/hud");
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Write HUD settings to /opt/hud
    Util.termWrite("echo '================================'");
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Apply MANGOHUD settings
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
    
    // Apply DXVK_HUD settings
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
    Util.termWrite("echo '================================'");
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
      
      // Check if file exists
      if (!await file.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File not found: $dxvkPath'),
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
      
      // First, save preferences
      await _savePreferences();
      
      // Write HUD settings if changed
      if (_hasHudChanged) {
        await _writeHudSettings();
      }
      
      // Close dialog
      Navigator.of(context).pop();
      
      // Switch to terminal tab
      G.pageIndex.value = 0;
      
      // Wait a moment for tab switch
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Extract DXVK and related files
      await _extractDxvkAndRelated();
      
    } catch (e) {
      print('Error in _extractDxvk: $e');
      // Ensure dialog closes even on error
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
  // Check if we need to extract DXVK
  if (_hasDxvkChanged && _selectedDxvk != null) {
    // Extract the main DXVK file
    await _extractSingleFile(_selectedDxvk!, 'DXVK');
    
    // Check if the selected file has "dxvk" in its name (case insensitive)
    bool isDxvkFile = _selectedDxvk!.toLowerCase().contains('dxvk');
    
    // Only extract vkd3d and d8vk if the main file is a DXVK file
    if (isDxvkFile) {
      // Check and extract vkd3d if available (any file with 'vkd3d' in the name)
      final vkd3dFiles = await _findRelatedFiles('vkd3d');
      for (final vkd3dFile in vkd3dFiles) {
        await _extractSingleFile(vkd3dFile, 'VKD3D');
      }
      
      // Check and extract d8vk if available (any file with 'd8vk' in the name)
      final d8vkFiles = await _findRelatedFiles('d8vk');
      for (final d8vkFile in d8vkFiles) {
        await _extractSingleFile(d8vkFile, 'D8VK');
      }
    }
  } else {
    Util.termWrite("echo 'DXVK already installed: $_selectedDxvk'");
    await Future.delayed(const Duration(milliseconds: 50));
    Util.termWrite("echo '================================'");
  }
}

  Future<void> _extractSingleFile(String fileName, String fileType) async {
    Util.termWrite("echo '================================'");
    await Future.delayed(const Duration(milliseconds: 50));
    
    Util.termWrite("echo 'Extracting $fileType: $fileName'");
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Create target directory if it doesn't exist
    Util.termWrite("mkdir -p /home/xodos/.wine/drive_c/windows");
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Extract based on file type
    String containerPath = "/wincomponents/d3d/$fileName";
    
    if (fileName.endsWith('.zip')) {
      Util.termWrite("unzip -o '$containerPath' -d '/home/xodos/.wine/drive_c/windows'");
    } else if (fileName.endsWith('.7z')) {
      Util.termWrite("7z x '$containerPath' -o'/home/xodos/.wine/drive_c/windows' -y");
    } else {
      // Assume it's a tar archive (most common for DXVK)
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
    // Save preferences first
    await _savePreferences();
    
    // Write HUD settings if changed
    if (_hasHudChanged) {
      await _writeHudSettings();
      
      // Show confirmation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('HUD settings saved to /opt/hud'),
            duration: const Duration(seconds: 2),
          ),
        );
      });
    }
    
    // Close dialog
    Navigator.of(context).pop();
  }

  Future<void> _loadDxvkFiles() async {
    try {
      // Look in the container's wincomponents directory
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
      
      // Accept various archive formats
      final dxvkFiles = files
          .where((file) => file is File && 
              RegExp(r'\.(tzst|tar\.gz|tgz|tar\.xz|txz|tar|zip|7z)$').hasMatch(file.path))
          .map((file) => file.path.split('/').last)
          .toList();
      
      setState(() {
        _dxvkFiles = dxvkFiles;
        if (dxvkFiles.isNotEmpty) {
          // Load saved DXVK selection or use first
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
                    
                    // HUD Settings Section
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
                          
                          // MANGOHUD Switch
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
                          
                          // DXVK HUD Switch
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
                    
                    // Auto-extraction info
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
                    
                    // Changes indicator
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


///env

// Add this after your DxvkDialog class
class EnvironmentDialog extends StatefulWidget {
  @override
  _EnvironmentDialogState createState() => _EnvironmentDialogState();
}

class _EnvironmentDialogState extends State<EnvironmentDialog> {
  // Box64 Dynarec variables (updated with new switches)
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
    // New switches
    {"name": "BOX64_MMAP32", "values": ["0", "1"], "toggleSwitch": true, "defaultValue": "0"},
    {"name": "BOX64_AVX", "values": ["0", "1"], "toggleSwitch": true, "defaultValue": "0"},
    {"name": "BOX64_UNITYPLAYER", "values": ["0", "1"], "toggleSwitch": true, "defaultValue": "0"},
  ];

  // Box64 presets
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

  // Core checkboxes - will be initialized with actual CPU count
  List<bool> _coreSelections = [];
  int _availableCores = 8; // Default, will be updated
  
  // Wine Esync switch
  bool _wineEsyncEnabled = false;
  
  // Custom variables
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
  
  // Debug settings
  bool _debugEnabled = false;
  String _winedebugValue = '-all'; // Default value
  final List<String> _winedebugOptions = [
    '-all', 'err', 'warn', 'fixme', 'all', 'trace', 'message', 'heap', 'fps'
  ];
  
  // Current custom variable being added
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
      // Get available processor count like Winlator does
      // We'll use Platform.numberOfProcessors for Dart
      _availableCores = Platform.numberOfProcessors;
      
      // Initialize core selections with actual available cores
      setState(() {
        _coreSelections = List.generate(_availableCores, (index) => true);
      });
    } catch (e) {
      print('Error getting CPU count: $e');
      // Fallback to 8 cores if we can't detect
      _availableCores = 8;
      _coreSelections = List.generate(8, (index) => true);
    }
  }

  Future<void> _loadSavedSettings() async {
    try {
      // Load core selections
      final savedCores = G.prefs.getString('environment_cores');
      if (savedCores != null && savedCores.isNotEmpty) {
        _parseCoreSelections(savedCores);
      } else {
        // Default: all cores selected
        setState(() {
          _coreSelections = List.generate(_availableCores, (index) => true);
        });
      }
      
      // Load wine esync
      _wineEsyncEnabled = G.prefs.getBool('environment_wine_esync') ?? false;
      
      // Load debug setting
      _debugEnabled = G.prefs.getBool('environment_debug') ?? false;
      
      // Load WINEDEBUG value
      _winedebugValue = G.prefs.getString('environment_winedebug') ?? '-all';
      
      // Load custom variables
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
      // Reset all cores to false
      _coreSelections = List.generate(_availableCores, (index) => false);
      
      if (coreString.contains(',')) {
        // Comma-separated list (like "0,1,3")
        final selectedIndices = coreString.split(',');
        for (final indexStr in selectedIndices) {
          final index = int.tryParse(indexStr);
          if (index != null && index < _availableCores) {
            _coreSelections[index] = true;
          }
        }
      } else if (coreString.contains('-')) {
        // Range format (like "0-7")
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
    // Winlator-style: comma-separated list of selected cores
    final selectedIndices = <int>[];
    for (int i = 0; i < _availableCores; i++) {
      if (_coreSelections[i]) {
        selectedIndices.add(i);
      }
    }
    
    if (selectedIndices.isEmpty) {
      return "0";
    }
    
    // Return comma-separated list
    return selectedIndices.join(',');
  }

  Future<void> _saveSettings() async {
    try {
      // Save to SharedPreferences
      await G.prefs.setString('environment_cores', _getCoreString());
      await G.prefs.setBool('environment_wine_esync', _wineEsyncEnabled);
      await G.prefs.setBool('environment_debug', _debugEnabled);
      await G.prefs.setString('environment_winedebug', _winedebugValue);
      
      // Save custom variables
      final varStrings = _customVariables.map((varMap) => '${varMap['name']}=${varMap['value']}').toList();
      await G.prefs.setStringList('environment_custom_vars', varStrings);
      
      // Save dynarec settings
      for (final variable in _dynarecVariables) {
        final name = variable['name'] as String;
        final currentValue = variable['currentValue'] ?? variable['defaultValue'];
        await G.prefs.setString('dynarec_$name', currentValue);
      }
      
      // Apply settings via terminal
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
    // Switch to terminal tab
    G.pageIndex.value = 0;
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Clear existing files
    Util.termWrite("echo '' > /opt/dyna");
    Util.termWrite("echo '' > /opt/sync");
    Util.termWrite("echo '' > /opt/cores");
    Util.termWrite("echo '' > /opt/env");
    Util.termWrite("echo '' > /opt/dbg");
    Util.termWrite("echo '' > /opt/hud");
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Apply Box64 Dynarec settings
    for (final variable in _dynarecVariables) {
      final name = variable['name'] as String;
      final defaultValue = variable['defaultValue'] as String;
      final savedValue = G.prefs.getString('dynarec_$name') ?? defaultValue;
      
      Util.termWrite("echo 'export $name=$savedValue' >> /opt/dyna");
      await Future.delayed(const Duration(milliseconds: 10));
    }
    
    // Apply Wine Esync settings
    if (_wineEsyncEnabled) {
      Util.termWrite("echo 'export WINEESYNC=1' >> /opt/sync");
      Util.termWrite("echo 'export WINEESYNC_TERMUX=1' >> /opt/sync");
    } else {
      Util.termWrite("echo 'export WINEESYNC=0' >> /opt/sync");
      Util.termWrite("echo 'export WINEESYNC_TERMUX=0' >> /opt/sync");
    }
    
    // Apply Core settings
    Util.termWrite("echo 'export PRIMARY_CORES=${_getCoreString()}' >> /opt/cores");
    
    // Apply custom variables
    for (final variable in _customVariables) {
      Util.termWrite("echo 'export ${variable['name']}=${variable['value']}' >> /opt/env");
      await Future.delayed(const Duration(milliseconds: 10));
    }
    
    // Apply Debug settings
    if (_debugEnabled) {
      // Debug ON (verbose mode)
      Util.termWrite("echo 'export MESA_NO_ERROR=0' >> /opt/dbg");
      Util.termWrite("echo 'export WINEDEBUG=$_winedebugValue' >> /opt/dbg");
      Util.termWrite("echo 'export BOX64_LOG=1' >> /opt/dbg");
      Util.termWrite("echo 'export BOX64_NOBANNER=0' >> /opt/dbg");
      Util.termWrite("echo 'export BOX64_SHOWSEGV=1' >> /opt/dbg");
      Util.termWrite("echo 'export BOX64_DLSYM_ERROR=1' >> /opt/dbg");
      Util.termWrite("echo 'export BOX64_DYNAREC_MISSING=1' >> /opt/dbg");
    } else {
      // Debug OFF (quiet mode)
      Util.termWrite("echo 'export MESA_NO_ERROR=1' >> /opt/dbg");
      Util.termWrite("echo 'export WINEDEBUG=$_winedebugValue' >> /opt/dbg");
      Util.termWrite("echo 'export BOX64_LOG=0' >> /opt/dbg");
      Util.termWrite("echo 'export BOX64_NOBANNER=1' >> /opt/dbg");
      Util.termWrite("echo 'export BOX64_SHOWSEGV=0' >> /opt/dbg");
      Util.termWrite("echo 'export BOX64_DLSYM_ERROR=0' >> /opt/dbg");
      Util.termWrite("echo 'export BOX64_DYNAREC_MISSING=0' >> /opt/dbg");
    }
    
    Util.termWrite("echo '================================'");
    Util.termWrite("echo 'Environment settings applied!'");
    Util.termWrite("echo '================================'");
  }

void _showDynarecDialog() {
  showDialog(
    context: context,
    builder: (context) {
      // Create a local copy of dynarec variables with current values
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
          // Function to check if current values match any preset
          void _updatePresetSelection() {
            // Check if current values match any preset
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

          // Initialize preset selection
          _updatePresetSelection();

          return AlertDialog(
            title: const Text('Box64 Dynarec Settings'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Preset dropdown
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
                    
                    // Dynarec variables
                    ...localVariables.map((variable) {
                      return _buildDynarecVariableWidget(
                        variable, 
                        setState,
                        localVariables, // Pass the localVariables list
                        onVariableChanged: () {
                          // When any variable changes manually, set preset to Custom
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
                  // Save all dynarec settings
                  for (final variable in localVariables) {
                    final name = variable['name'] as String;
                    final currentValue = variable['currentValue'] as String;
                    await G.prefs.setString('dynarec_$name', currentValue);
                  }
                  
                  // Also update the main list
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

// Update the function signature to include optional callback
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
                    duration: Duration(seconds: 2),
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
              // Box64 Dynarec Section
              Card(
                child: ListTile(
                  title: const Text('Box64 Dynarec'),
                  subtitle: const Text('Advanced emulation settings'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: _showDynarecDialog,
                ),
              ),
              const SizedBox(height: 8),
              
              // Wine Esync Section
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
              
              // Cores Section
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
              
              // Custom Variables Section
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
              
              // Debug Section
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


//// GPU drivers

// GPU Drivers Dialog - Complete Fixed Version
class GpuDriversDialog extends StatefulWidget {
  @override
  _GpuDriversDialogState createState() => _GpuDriversDialogState();
}

class _GpuDriversDialogState extends State<GpuDriversDialog> {
  // Driver types
  String _selectedDriverType = 'virgl';
  String? _selectedDriverFile;
  List<String> _driverFiles = [];
  String? _driversDirectory;
  bool _isLoading = true;
  
  // Turnip options
  bool _useBuiltInTurnip = true;
  bool _driEnabled = false;
  
  // Settings
  bool _virglEnabled = false;
  bool _turnipEnabled = false;
  bool _dri3Enabled = false;
  String _defaultTurnipOpt = 'MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform';

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
    _loadDriverFiles();
  }

  Future<void> _loadSavedSettings() async {
    try {
      // Load existing graphics settings
      _virglEnabled = G.prefs.getBool('virgl') ?? false;
      _turnipEnabled = G.prefs.getBool('turnip') ?? false;
      _dri3Enabled = G.prefs.getBool('dri3') ?? false;
      
      // Load the default turnip opt
      String savedTurnipOpt = G.prefs.getString('defaultTurnipOpt') ?? 'MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform';
      _defaultTurnipOpt = _removeVkIcdFromEnvString(savedTurnipOpt);
      
      // If it's empty after cleaning, set a default
      if (_defaultTurnipOpt.isEmpty) {
        _defaultTurnipOpt = 'MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform';
      }
      
      // Load GPU driver specific settings
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
    // Remove VK_ICD_FILENAMES variable from the environment string
    // Split by space to separate environment variables
    List<String> envVars = envString.split(' ');
    
    // Filter out any variable that starts with VK_ICD_FILENAMES
    envVars.removeWhere((varStr) => varStr.trim().startsWith('VK_ICD_FILENAMES='));
    
    // Join back together
    return envVars.join(' ').trim();
  }


Future<void> _saveAndExtract() async {
  try {
    // Save settings first
    await G.prefs.setString('gpu_driver_type', _selectedDriverType);
    if (_selectedDriverFile != null) {
      await G.prefs.setString('selected_gpu_driver', _selectedDriverFile!);
    }
    await G.prefs.setBool('use_builtin_turnip', _useBuiltInTurnip);
    await G.prefs.setBool('gpu_dri_enabled', _driEnabled);
    
    // Save existing graphics settings
    await G.prefs.setBool('virgl', _virglEnabled);
    await G.prefs.setBool('turnip', _turnipEnabled);
    await G.prefs.setBool('dri3', _dri3Enabled);
    
    // Clean and save the turnip opt
    String cleanTurnipOpt = _removeVkIcdFromEnvString(_defaultTurnipOpt);
    if (cleanTurnipOpt.isEmpty) {
      cleanTurnipOpt = 'MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform';
    }
    await G.prefs.setString('defaultTurnipOpt', cleanTurnipOpt);
    
    // Switch to terminal tab
    G.pageIndex.value = 0;
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Extract driver if needed (custom driver selected)
    if (!(_selectedDriverType == 'turnip' && _useBuiltInTurnip) && 
        _selectedDriverFile != null) {
      await _extractDriver();
    } else {
      // Just apply settings without extraction
      await _applyGpuSettings();
    }
    
    // If VirGL is enabled, start the server
    if (_virglEnabled && _selectedDriverType == 'virgl') {
      final virglCommand = G.prefs.getString('defaultVirglCommand') ?? '--use-egl-surfaceless --use-gles --socket-path=\$CONTAINER_DIR/tmp/.virgl_test';
      await _startVirglServer(virglCommand);
    }
    
    // Close dialog
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
    // Switch to terminal tab
    G.pageIndex.value = 0;
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Clear existing driver file
    Util.termWrite("echo '' > /opt/drv");
    
    // Apply settings based on driver type
    if (_selectedDriverType == 'turnip') {
      await _applyTurnipSettings();
    } else if (_selectedDriverType == 'virgl') {
      await _applyVirglSettings();
    } else if (_selectedDriverType == 'wrapper') {
      await _applyWrapperSettings();
    }
    
    Util.termWrite("echo '================================'");
    Util.termWrite("echo 'GPU driver settings applied!'");
    Util.termWrite("echo '================================'");
  }

  Future<void> _applyTurnipSettings() async {
    if (_useBuiltInTurnip) {
      // Built-in turnip - use the bundled driver
      Util.termWrite("echo 'export VK_ICD_FILENAMES=/home/tiny/.local/share/tiny/extra/freedreno_icd.aarch64.json' >> /opt/drv");
    } else if (_selectedDriverFile != null) {
      // Custom turnip driver - use the extracted driver
      Util.termWrite("echo 'export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/freedreno_icd.aarch64.json' >> /opt/drv");
    }
    
    // Set turnip environment if enabled
    if (_turnipEnabled) {
      // Clean the turnip opt to remove any VK_ICD_FILENAMES
      String cleanTurnipOpt = _removeVkIcdFromEnvString(_defaultTurnipOpt);
      
      if (cleanTurnipOpt.isNotEmpty) {
        Util.termWrite("echo 'export $cleanTurnipOpt' >> /opt/drv");
      }
      
      // Add DRI3 debug if DRI3 is disabled
      if (!_dri3Enabled) {
        Util.termWrite("echo 'export MESA_VK_WSI_DEBUG=sw' >> /opt/drv");
      }
    }
  }

Future<void> _applyVirglSettings() async {
  if (_virglEnabled) {
    // Get VirGL server parameters
    final virglCommand = G.prefs.getString('defaultVirglCommand') ?? '--use-egl-surfaceless --use-gles --socket-path=\$CONTAINER_DIR/tmp/.virgl_test';
    final virglEnv = G.prefs.getString('defaultVirglOpt') ?? 'GALLIUM_DRIVER=virpipe';
    
    // Write VirGL environment to /opt/drv
    Util.termWrite("echo 'export $virglEnv' >> /opt/drv");
    await Future.delayed(const Duration(milliseconds: 50));
    
    // If we have a custom virgl driver file, we might need to set additional env vars
    if (_selectedDriverFile != null) {
      Util.termWrite("echo '# Custom VirGL driver: $_selectedDriverFile' >> /opt/drv");
    }
  }
}

Future<void> _startVirglServer(String virglCommand) async {
  // Switch to terminal tab first
  G.pageIndex.value = 0;
  await Future.delayed(const Duration(milliseconds: 300));
  
  // First, kill any existing virgl_test_server
  Util.termWrite("pkill -f virgl_test_server");
  await Future.delayed(const Duration(milliseconds: 100));
  
  // Start the VirGL server
  Util.termWrite("echo '================================'");
  await Future.delayed(const Duration(milliseconds: 50));
  
  Util.termWrite("echo 'Starting VirGL server...'");
  await Future.delayed(const Duration(milliseconds: 50));
  
  // Create the socket directory
  Util.termWrite("mkdir -p /tmp/.virgl_test");
  await Future.delayed(const Duration(milliseconds: 50));
  
  // Get the correct paths for the virgl_test_server binary
  // The binary is in the host's data directory, not in the container
  String dataDir = G.dataPath;
  String containerDir = "$dataDir/containers/${G.currentContainer}";
  
  // Replace $CONTAINER_DIR variable in the command
  String processedCommand = virglCommand.replaceAll('\$CONTAINER_DIR', containerDir);
  
  // Start the VirGL server from the host's binary location
  Util.termWrite("echo 'Using data directory: $dataDir'");
  await Future.delayed(const Duration(milliseconds: 50));
  
  Util.termWrite("echo 'Container directory: $containerDir'");
  await Future.delayed(const Duration(milliseconds: 50));
  
  // This will be executed on the host, not in the container
  // We need to use the host's virgl_test_server binary
  Util.termWrite("$dataDir/bin/virgl_test_server $processedCommand &");
  
  await Future.delayed(const Duration(milliseconds: 50));
  
  // Check if server started successfully
  Util.termWrite("sleep 1 && if pgrep -f virgl_test_server > /dev/null; then echo 'VirGL server started successfully'; else echo 'Failed to start VirGL server'; fi");
  
  await Future.delayed(const Duration(milliseconds: 50));
  Util.termWrite("echo '================================'");
}




  Future<void> _applyWrapperSettings() async {
    // Wrapper drivers (like wine wrapper)
    if (_selectedDriverFile != null) {
      Util.termWrite("echo '# Using wrapper driver: $_selectedDriverFile' >> /opt/drv");
    }
  }

  Future<void> _extractDriver() async {
    try {
      if (_selectedDriverFile == null || _driversDirectory == null) {
        throw Exception('Please select a driver file');
      }
      
      final driverPath = '$_driversDirectory/$_selectedDriverFile';
      final file = File(driverPath);
      
      // Check if file exists
      if (!await file.exists()) {
        throw Exception('File not found: $driverPath');
      }
      
      // Switch to terminal tab
      G.pageIndex.value = 0;
      
      // Wait a moment for tab switch
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Extract driver
      Util.termWrite("echo '================================'");
      await Future.delayed(const Duration(milliseconds: 50));
      
      Util.termWrite("echo 'Extracting GPU driver: $_selectedDriverFile'");
      await Future.delayed(const Duration(milliseconds: 50));
      
      Util.termWrite("echo '================================'");
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Create target directory if it doesn't exist
      Util.termWrite("mkdir -p /usr/share/vulkan/icd.d");
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Extract based on file type
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
        // Assume it's a tar archive
        Util.termWrite("tar -xf '$containerPath' -C '/usr'");
      }
      
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Apply GPU settings after extraction
      await _applyGpuSettings();
      
    } catch (e) {
      print('Error in _extractDriver: $e');
      // Show error but don't rethrow - let the dialog close
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
      // Look in the container's drivers directory
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
      
      // Accept various archive formats
      final allDriverFiles = files
          .where((file) => file is File && 
              RegExp(r'\.(tzst|tar\.gz|tgz|tar\.xz|txz|tar|zip|7z|json|so|ko)$').hasMatch(file.path))
          .map((file) => file.path.split('/').last)
          .toList();
      
      setState(() {
        _driverFiles = allDriverFiles;
        if (allDriverFiles.isNotEmpty) {
          // Load saved driver selection
          _selectedDriverFile = G.prefs.getString('selected_gpu_driver');
          
          // If no saved selection, try to find one matching current driver type
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
    // Filter files based on selected driver type
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
    
    // If we have filtered files, select the first one
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
        // Reset selection when type changes
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
              // Driver Type Selection
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
              
              // ADD THIS NEW CARD RIGHT HERE:
Card(
  child: ListTile(
    title: const Text('VirGL Server Status'),
    subtitle: FutureBuilder<String>(
      future: _checkVirglServerStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Checking...');
        }
        return Text(snapshot.data ?? 'Unknown');
      },
    ),
    trailing: IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: () {
        if (_virglEnabled && _selectedDriverType == 'virgl') {
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
                          
              // Driver Settings Section
              if (_selectedDriverType == 'turnip') _buildTurnipSettings(),
              if (_selectedDriverType == 'virgl') _buildVirglSettings(),
              if (_selectedDriverType == 'wrapper') _buildWrapperSettings(),
              
              // Driver Files Selection (if not using built-in turnip)
              if (!(_selectedDriverType == 'turnip' && _useBuiltInTurnip))
                _buildDriverFileSelection(),
              
              // DRI Switch (for Turnip/VirGL)
              if (_selectedDriverType == 'turnip' || _selectedDriverType == 'virgl')
                Card(
                  child: SwitchListTile(
                    title: const Text('Enable DRI3'),
                    subtitle: const Text('Direct Rendering Infrastructure v3'),
                    value: _driEnabled,
                    onChanged: (value) {
                      setState(() {
                        _driEnabled = value;
                        if (_selectedDriverType == 'turnip') {
                          _dri3Enabled = value;
                        }
                      });
                    },
                  ),
                ),
              
              // Graphics Acceleration Toggles
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
                          });
                        } : null,
                      ),
                      SwitchListTile(
                        title: const Text('Enable Turnip/Zink'),
                        subtitle: const Text('Vulkan via Zink driver'),
                        value: _turnipEnabled,
                        onChanged: _selectedDriverType == 'turnip' ? (value) {
                          setState(() {
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
            // Horizontal radio buttons
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
              'Wrapper Settings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Wrapper drivers provide compatibility layers for different GPU architectures.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverFileSelection() {
    // Filter files based on selected driver type
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
}

// Update your Setting





class RTLWrapper extends StatelessWidget {
  final Widget child;
  
  const RTLWrapper({super.key, required this.child});
  
  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isRTL = _isRTL(locale);
    
    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: child,
    );
  }
  
  bool _isRTL(Locale locale) {
    return locale.languageCode == 'ar' || 
           locale.languageCode == 'he' || 
           locale.languageCode == 'fa' ||
           locale.languageCode == 'ur';
  }
}





//Limit maximum aspect ratio to 1:1
class AspectRatioMax1To1 extends StatelessWidget {
  final Widget child;
  //final double aspectRatio;

  const AspectRatioMax1To1({super.key, required this.child/*, required this.aspectRatio*/});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final s = MediaQuery.of(context).size;
        //double size = (s.width < s.height * aspectRatio) ? s.width : (s.height * aspectRatio);
        double size = s.width < s.height ? constraints.maxWidth : s.height;

        return Center(
          child: SizedBox(
            width: size,
            height: constraints.maxHeight,
            child: child,
          ),
        );
      },
    );
  }
}


// In main.dart - Update the FakeLoadingStatus class
// In main.dart - Update FakeLoadingStatus
class FakeLoadingStatus extends StatefulWidget {
  const FakeLoadingStatus({super.key});

  @override
  State<FakeLoadingStatus> createState() => _FakeLoadingStatusState();
}

class _FakeLoadingStatusState extends State<FakeLoadingStatus> {
  double _progressT = 0;
  Timer? _timer;
  bool _extractionComplete = false;

  @override
  void initState() {
    super.initState();
    _loadInitialProgress();
  }

  void _loadInitialProgress() async {
    // Load any existing progress
    final savedProgressT = await ExtractionManager.getExtractionProgressT();
    final savedComplete = await ExtractionManager.isExtractionComplete();
    
    if (mounted) {
      setState(() {
        _progressT = savedProgressT;
        _extractionComplete = savedComplete;
      });
    }

    // Only start timer if not already complete
    if (!_extractionComplete) {
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
        if (_extractionComplete) {
          timer.cancel();
          return;
        }

        setState(() {
          _progressT += 0.1;
        });
        
        // Save progress to SharedPreferences
        await ExtractionManager.setExtractionProgressT(_progressT);
        
        // Check if complete
        final progress = 1 - pow(10, _progressT / -300).toDouble();
        if (progress >= 0.999 && !_extractionComplete) {
          _extractionComplete = true;
          await ExtractionManager.setExtractionComplete();
          timer.cancel();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(value: 1 - pow(10, _progressT / -300).toDouble());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}


class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  final List<bool> _expandState = [false, false, false, false, false, false];

  double _avncScaleFactor = Util.getGlobal("avncScaleFactor") as double;

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      elevation: 1,
      expandedHeaderPadding: const EdgeInsets.all(0),
      expansionCallback: (panelIndex, isExpanded) {
      setState(() {
        _expandState[panelIndex] = isExpanded;
      });
    },children: [
      ExpansionPanel(
        isExpanded: _expandState[0],
        headerBuilder: ((context, isExpanded) {
          return ListTile(title: Text(AppLocalizations.of(context)!.advancedSettings), subtitle: Text(AppLocalizations.of(context)!.restartAfterChange));
        }), body: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
          Wrap(alignment: WrapAlignment.center, spacing: 4.0, runSpacing: 4.0, children: [
            OutlinedButton(style: D.commandButtonStyle, child: Text(AppLocalizations.of(context)!.resetStartupCommand), onPressed: () {
              showDialog(context: context, builder: (context) {
                return AlertDialog(title: Text(AppLocalizations.of(context)!.attention), content: Text(AppLocalizations.of(context)!.confirmResetCommand), actions: [
                  TextButton(onPressed:() {
                    Navigator.of(context).pop();
                  }, child: Text(AppLocalizations.of(context)!.cancel)),
                  TextButton(onPressed:() async {
                    await Util.setCurrentProp("boot", Localizations.localeOf(context).languageCode == 'zh' ? D.boot : D.boot.replaceFirst('LANG=zh_CN.UTF-8', 'LANG=en_US.UTF-8').replaceFirst('公共', 'Public').replaceFirst('图片', 'Pictures').replaceFirst('音乐', 'Music').replaceFirst('视频', 'Videos').replaceFirst('下载', 'Downloads').replaceFirst('文档', 'Documents').replaceFirst('照片', 'Photos'));
                    G.bootTextChange.value = !G.bootTextChange.value;
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  }, child: Text(AppLocalizations.of(context)!.yes)),
                ]);
              });
            }),
            OutlinedButton(style: D.commandButtonStyle, child: Text(AppLocalizations.of(context)!.signal9ErrorPage), onPressed: () async {
              await D.androidChannel.invokeMethod("launchSignal9Page", {});
            }),
          ]),
          const SizedBox.square(dimension: 8),
          TextFormField(maxLines: null, initialValue: Util.getCurrentProp("name"), decoration: InputDecoration(border: OutlineInputBorder(), labelText: AppLocalizations.of(context)!.containerName), onChanged: (value) async {
            await Util.setCurrentProp("name", value);
          }),
          const SizedBox.square(dimension: 8),
          ValueListenableBuilder(valueListenable: G.bootTextChange, builder:(context, v, child) {
            return TextFormField(maxLines: null, initialValue: Util.getCurrentProp("boot"), decoration: InputDecoration(border: OutlineInputBorder(), labelText: AppLocalizations.of(context)!.startupCommand), onChanged: (value) async {
              await Util.setCurrentProp("boot", value);
            });
          }),
          const SizedBox.square(dimension: 8),
          TextFormField(maxLines: null, initialValue: Util.getCurrentProp("vnc"), decoration: InputDecoration(border: OutlineInputBorder(), labelText: AppLocalizations.of(context)!.vncStartupCommand), onChanged: (value) async {
            await Util.setCurrentProp("vnc", value);
          }),
          const SizedBox.square(dimension: 8),
          const Divider(height: 2, indent: 8, endIndent: 8),
          const SizedBox.square(dimension: 16),
          Text(AppLocalizations.of(context)!.shareUsageHint),
          const SizedBox.square(dimension: 16),
          Wrap(alignment: WrapAlignment.center, spacing: 4.0, runSpacing: 4.0, children: [
            OutlinedButton(style: D.commandButtonStyle, child: Text(AppLocalizations.of(context)!.copyShareLink), onPressed: () async {
              final String? ip = await NetworkInfo().getWifiIP();
              if (!context.mounted) return;
              if (G.wasX11Enabled) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.x11InvalidHint))
                );
                return;
              }
              if (ip == null) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.cannotGetIpAddress))
                );
                return;
              }
              FlutterClipboard.copy((Util.getCurrentProp("vncUrl") as String).replaceAll(RegExp.escape("localhost"), ip)).then((value) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.shareLinkCopied))
                );
              });
            }),
          ]),
          const SizedBox.square(dimension: 16),
          TextFormField(maxLines: null, initialValue: Util.getCurrentProp("vncUrl"), decoration: InputDecoration(border: OutlineInputBorder(), labelText: AppLocalizations.of(context)!.webRedirectUrl), onChanged: (value) async {
            await Util.setCurrentProp("vncUrl", value);
          }),
          const SizedBox.square(dimension: 8),
          TextFormField(maxLines: null, initialValue: Util.getCurrentProp("vncUri"), decoration: InputDecoration(border: OutlineInputBorder(), labelText: AppLocalizations.of(context)!.vncLink), onChanged: (value) async {
            await Util.setCurrentProp("vncUri", value);
          }),
          const SizedBox.square(dimension: 8),
        ],))),
      ExpansionPanel(
        isExpanded: _expandState[1],
        headerBuilder: ((context, isExpanded) {
          return ListTile(title: Text(AppLocalizations.of(context)!.globalSettings), subtitle: Text(AppLocalizations.of(context)!.enableTerminalEditing));
        }), body: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
          TextFormField(autovalidateMode: AutovalidateMode.onUserInteraction, initialValue: (Util.getGlobal("termMaxLines") as int).toString(), decoration: InputDecoration(border: OutlineInputBorder(), labelText: AppLocalizations.of(context)!.terminalMaxLines),
            keyboardType: TextInputType.number,
            validator: (value) {
              return Util.validateBetween(value, 1024, 2147483647, () async {
                await G.prefs.setInt("termMaxLines", int.parse(value!));
              });
            },),
          const SizedBox.square(dimension: 16),
          TextFormField(autovalidateMode: AutovalidateMode.onUserInteraction, initialValue: (Util.getGlobal("defaultAudioPort") as int).toString(), decoration: InputDecoration(border: OutlineInputBorder(), labelText: AppLocalizations.of(context)!.pulseaudioPort),
            keyboardType: TextInputType.number,
            validator: (value) {
              return Util.validateBetween(value, 0, 65535, () async {
                await G.prefs.setInt("defaultAudioPort", int.parse(value!));
              });
            }
          ),
          const SizedBox.square(dimension: 16),
          SwitchListTile(title: Text(AppLocalizations.of(context)!.enableTerminal), value: Util.getGlobal("isTerminalWriteEnabled") as bool, onChanged:(value) {
            G.prefs.setBool("isTerminalWriteEnabled", value);
            setState(() {});
          },),
          const SizedBox.square(dimension: 8),
          SwitchListTile(title: Text(AppLocalizations.of(context)!.enableTerminalKeypad), value: Util.getGlobal("isTerminalCommandsEnabled") as bool, onChanged:(value) {
            G.prefs.setBool("isTerminalCommandsEnabled", value);
            setState(() {
              G.terminalPageChange.value = !G.terminalPageChange.value;
            });
          },),
          const SizedBox.square(dimension: 8),
          SwitchListTile(title: Text(AppLocalizations.of(context)!.terminalStickyKeys), value: Util.getGlobal("isStickyKey") as bool, onChanged:(value) {
            G.prefs.setBool("isStickyKey", value);
            setState(() {});
          },),
          const SizedBox.square(dimension: 8),
          SwitchListTile(title: Text(AppLocalizations.of(context)!.keepScreenOn), value: Util.getGlobal("wakelock") as bool, onChanged:(value) {
            G.prefs.setBool("wakelock", value);
            WakelockPlus.toggle(enable: value);
            setState(() {});
          },),
          const SizedBox.square(dimension: 8),
          const Divider(height: 2, indent: 8, endIndent: 8),
          const SizedBox.square(dimension: 16),
          Text(AppLocalizations.of(context)!.restartRequiredHint),
          const SizedBox.square(dimension: 8),
          SwitchListTile(title: Text(AppLocalizations.of(context)!.startWithGUI), value: Util.getGlobal("autoLaunchVnc") as bool, onChanged:(value) {
            G.prefs.setBool("autoLaunchVnc", value);
            setState(() {});
          },),
          const SizedBox.square(dimension: 8),
          SwitchListTile(title: Text(AppLocalizations.of(context)!.reinstallBootPackage), value: Util.getGlobal("reinstallBootstrap") as bool, onChanged:(value) {
            G.prefs.setBool("reinstallBootstrap", value);
            setState(() {});
          },),
          const SizedBox.square(dimension: 8),
          SwitchListTile(title: Text(AppLocalizations.of(context)!.getifaddrsBridge), subtitle: Text(AppLocalizations.of(context)!.fixGetifaddrsPermission), value: Util.getGlobal("getifaddrsBridge") as bool, onChanged:(value) {
            G.prefs.setBool("getifaddrsBridge", value);
            setState(() {});
          },),
          const SizedBox.square(dimension: 8),
          SwitchListTile(title: Text(AppLocalizations.of(context)!.fakeUOSSystem), value: Util.getGlobal("uos") as bool, onChanged:(value) {
            G.prefs.setBool("uos", value);
            setState(() {});
          },),
        ],))),
      ExpansionPanel(
        isExpanded: _expandState[2],
        headerBuilder: ((context, isExpanded) {
          return ListTile(title: Text(AppLocalizations.of(context)!.displaySettings));
        }), body: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
          const SizedBox.square(dimension: 16),
          Text(AppLocalizations.of(context)!.hidpiAdvantages),
          const SizedBox.square(dimension: 16),
          TextFormField(maxLines: null, initialValue: Util.getGlobal("defaultHidpiOpt") as String, decoration: InputDecoration(border: OutlineInputBorder(), labelText: AppLocalizations.of(context)!.hidpiEnvVar),
            onChanged: (value) async {
              await G.prefs.setString("defaultHidpiOpt", value);
            },
          ),
          const SizedBox.square(dimension: 8),
          SwitchListTile(title: Text(AppLocalizations.of(context)!.hidpiSupport), subtitle: Text(AppLocalizations.of(context)!.applyOnNextLaunch), value: Util.getGlobal("isHidpiEnabled") as bool, onChanged:(value) {
            G.prefs.setBool("isHidpiEnabled", value);
            // 开启高分辨率后把缩放比调为原来的两倍 +log4(2) = 0.5
            _avncScaleFactor += value ? 0.5 : -0.5;
            _avncScaleFactor = _avncScaleFactor.clamp(-1, 1);
            G.prefs.setDouble("avncScaleFactor", _avncScaleFactor);
            // Termux:X11 并不是设置缩放比例本身，而是倍率
            X11Flutter.setX11ScaleFactor(value ? 0.5 : 2.0);
            setState(() {});
          },),
          const SizedBox.square(dimension: 16),
          const Divider(height: 2, indent: 8, endIndent: 8),
          const SizedBox.square(dimension: 16),
          Text(AppLocalizations.of(context)!.avncAdvantages),
          const SizedBox.square(dimension: 16),
          Wrap(alignment: WrapAlignment.center, spacing: 4.0, runSpacing: 4.0, children: [
            OutlinedButton(style: D.commandButtonStyle, child: Text(AppLocalizations.of(context)!.avncSettings), onPressed: () async {
              await AvncFlutter.launchPrefsPage();
            }),
            OutlinedButton(style: D.commandButtonStyle, child: Text(AppLocalizations.of(context)!.aboutAVNC), onPressed: () async {
              await AvncFlutter.launchAboutPage();
            }),
            OutlinedButton(style: D.commandButtonStyle, onPressed: Util.getGlobal("avncResizeDesktop") as bool ? null : () async {
              final s = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;
              final w0 = max(s.width, s.height);
              final h0 = min(s.width, s.height);
              String w = (w0 * 0.75).round().toString();
              String h = (h0 * 0.75).round().toString();
              showDialog(context: context, builder: (context) {
                return AlertDialog(title: Text(AppLocalizations.of(context)!.resolutionSettings), content: SingleChildScrollView(child: Column(children: [
                  Text("${AppLocalizations.of(context)!.deviceScreenResolution} ${w0.round()}x${h0.round()}"),
                  const SizedBox.square(dimension: 8),
                  TextFormField(autovalidateMode: AutovalidateMode.onUserInteraction, initialValue: w, decoration: InputDecoration(border: OutlineInputBorder(), labelText: AppLocalizations.of(context)!.width), keyboardType: TextInputType.number,
                    validator: (value) {
                      return Util.validateBetween(value, 200, 7680, () {
                        w = value!;
                      });
                    }
                  ),
                  const SizedBox.square(dimension: 8),
                  TextFormField(autovalidateMode: AutovalidateMode.onUserInteraction, initialValue: h, decoration: InputDecoration(border: OutlineInputBorder(), labelText: AppLocalizations.of(context)!.height), keyboardType: TextInputType.number,
                    validator: (value) {
                      return Util.validateBetween(value, 200, 7680, () {
                        h = value!;
                      });
                    }
                  ),
                ])), actions: [
                  TextButton(onPressed:() {
                    Navigator.of(context).pop();
                  }, child: Text(AppLocalizations.of(context)!.cancel)),
                  TextButton(onPressed:() async {
                    Util.termWrite("""sed -i -E "s@(geometry)=.*@\\1=${w}x${h}@" /etc/tigervnc/vncserver-config-tmoe
sed -i -E "s@^(VNC_RESOLUTION)=.*@\\1=${w}x${h}@" \$(command -v startvnc)""");
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${w}x${h}. ${AppLocalizations.of(context)!.applyOnNextLaunch}"))
                    );
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  }, child: Text(AppLocalizations.of(context)!.save)),
                ]);
              });
            }, child: Text(AppLocalizations.of(context)!.avncResolution)),
          ]),
          const SizedBox.square(dimension: 8),
          SwitchListTile(title: Text(AppLocalizations.of(context)!.useAVNCByDefault), subtitle: Text(AppLocalizations.of(context)!.applyOnNextLaunch), value: Util.getGlobal("useAvnc") as bool, onChanged:(value) {
            G.prefs.setBool("useAvnc", value);
            setState(() {});
          },),
          const SizedBox.square(dimension: 8),
          SwitchListTile(title: Text(AppLocalizations.of(context)!.avncScreenResize), value: Util.getGlobal("avncResizeDesktop") as bool, onChanged:(value) {
            G.prefs.setBool("avncResizeDesktop", value);
            setState(() {});
          },),
          const SizedBox.square(dimension: 8),
          ListTile(
            title: Text(AppLocalizations.of(context)!.avncResizeFactor),
            onTap: () {},
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Text('${AppLocalizations.of(context)!.avncResizeFactorValue} ${pow(4, _avncScaleFactor).toStringAsFixed(2)}x'),
                SizedBox(height: 12),
                Slider(
                  value: _avncScaleFactor,
                  min: -1,
                  max: 1,
                  divisions: 96,
                  onChangeEnd: (double value) {
                    G.prefs.setDouble("avncScaleFactor", value);
                  },
                  onChanged: Util.getGlobal("avncResizeDesktop") as bool ? (double value) {
                    _avncScaleFactor = value;
                    setState(() {});
                  } : null,
                ),
              ],
            ),
          ),
          const SizedBox.square(dimension: 16),
          const Divider(height: 2, indent: 8, endIndent: 8),
          const SizedBox.square(dimension: 16),
          Text(AppLocalizations.of(context)!.termuxX11Advantages),
          const SizedBox.square(dimension: 16),
          Wrap(alignment: WrapAlignment.center, spacing: 4.0, runSpacing: 4.0, children: [
            OutlinedButton(style: D.commandButtonStyle, child: Text(AppLocalizations.of(context)!.termuxX11Preferences), onPressed: () async {
              await X11Flutter.launchX11PrefsPage();
            }),
          ]),
          const SizedBox.square(dimension: 8),
          SwitchListTile(title: Text(AppLocalizations.of(context)!.useTermuxX11ByDefault), subtitle: Text(AppLocalizations.of(context)!.disableVNC), value: Util.getGlobal("useX11") as bool, onChanged:(value) {
            G.prefs.setBool("useX11", value);
            if (!value && Util.getGlobal("dri3")) {
              G.prefs.setBool("dri3", false);
            }
            setState(() {});
          },),
          const SizedBox.square(dimension: 16),
        ],))),
      ExpansionPanel(
        isExpanded: _expandState[3],
        headerBuilder: ((context, isExpanded) {
          return ListTile(title: Text(AppLocalizations.of(context)!.fileAccess));
        }), body: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
          Text(AppLocalizations.of(context)!.fileAccessHint),
          const SizedBox.square(dimension: 16),
          Wrap(alignment: WrapAlignment.center, spacing: 4.0, runSpacing: 4.0, children: [
            OutlinedButton(style: D.commandButtonStyle, child: Text(AppLocalizations.of(context)!.requestStoragePermission), onPressed: () {
              Permission.storage.request();
            }),
            OutlinedButton(style: D.commandButtonStyle, child: Text(AppLocalizations.of(context)!.requestAllFilesAccess), onPressed: () {
              Permission.manageExternalStorage.request();
            }),
            OutlinedButton(style: D.commandButtonStyle, child: Text(AppLocalizations.of(context)!.fileAccessGuide), onPressed: () {
              launchUrl(Uri.parse("https://github.com/xodiosx/XoDos2/blob/main/fileaccess.md"), mode: LaunchMode.externalApplication);
            }),
          ]),
          const SizedBox.square(dimension: 16),
        ],))),
      ExpansionPanel(
        isExpanded: _expandState[4],
        headerBuilder: ((context, isExpanded) {
          return ListTile(title: Text(AppLocalizations.of(context)!.graphicsAcceleration), subtitle: Text(AppLocalizations.of(context)!.experimentalFeature));
        }), body: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
          Text(AppLocalizations.of(context)!.graphicsAccelerationHint),
          const SizedBox.square(dimension: 16),
          TextFormField(maxLines: null, initialValue: Util.getGlobal("defaultVirglCommand") as String, decoration: InputDecoration(border: OutlineInputBorder(), labelText: AppLocalizations.of(context)!.virglServerParams),
            onChanged: (value) async {
              await G.prefs.setString("defaultVirglCommand", value);
            },
          ),
          const SizedBox.square(dimension: 8),
          TextFormField(maxLines: null, initialValue: Util.getGlobal("defaultVirglOpt") as String, decoration: InputDecoration(border: OutlineInputBorder(), labelText: AppLocalizations.of(context)!.virglEnvVar),
            onChanged: (value) async {
              await G.prefs.setString("defaultVirglOpt", value);
            },
          ),
          const SizedBox.square(dimension: 8),
          SwitchListTile(title: Text(AppLocalizations.of(context)!.enableVirgl), subtitle: Text(AppLocalizations.of(context)!.applyOnNextLaunch), value: Util.getGlobal("virgl") as bool, onChanged:(value) {
            G.prefs.setBool("virgl", value);
            setState(() {});
          },),
          const SizedBox.square(dimension: 16),
          const Divider(height: 2, indent: 8, endIndent: 8),
          const SizedBox.square(dimension: 16),
          Text(AppLocalizations.of(context)!.turnipAdvantages),
          const SizedBox.square(dimension: 8),
          TextFormField(maxLines: null, initialValue: Util.getGlobal("defaultTurnipOpt") as String, decoration: InputDecoration(border: OutlineInputBorder(), labelText: AppLocalizations.of(context)!.turnipEnvVar),
            onChanged: (value) async {
              await G.prefs.setString("defaultTurnipOpt", value);
            },
          ),
          const SizedBox.square(dimension: 8),
          SwitchListTile(title: Text(AppLocalizations.of(context)!.enableTurnipZink), subtitle: Text(AppLocalizations.of(context)!.applyOnNextLaunch), value: Util.getGlobal("turnip") as bool, onChanged:(value) async {
            G.prefs.setBool("turnip", value);
            if (!value && Util.getGlobal("dri3")) {
              G.prefs.setBool("dri3", false);
            }
            setState(() {});
          },),
          const SizedBox.square(dimension: 8),
          SwitchListTile(title: Text(AppLocalizations.of(context)!.enableDRI3), subtitle: Text(AppLocalizations.of(context)!.applyOnNextLaunch), value: Util.getGlobal("dri3") as bool, onChanged:(value) async {
            if (value && !(Util.getGlobal("turnip") && Util.getGlobal("useX11"))) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.dri3Requirement))
              );
              return;
            }
            G.prefs.setBool("dri3", value);
            setState(() {});
          },),
          const SizedBox.square(dimension: 16),
        ],))),
      ExpansionPanel(
        isExpanded: _expandState[5],
        headerBuilder: ((context, isExpanded) {
          return ListTile(title: Text(AppLocalizations.of(context)!.windowsAppSupport), subtitle: Text(AppLocalizations.of(context)!.experimentalFeature),);
        }), body: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
          Text(AppLocalizations.of(context)!.hangoverDescription),
          const SizedBox.square(dimension: 8),
          Wrap(alignment: WrapAlignment.center, spacing: 4.0, runSpacing: 4.0, children: [
  OutlinedButton(style: D.commandButtonStyle, child: Text("${AppLocalizations.of(context)!.installHangoverStable}（10.14）"), onPressed: () async {
    Util.termWrite("bash /home/tiny/.local/share/tiny/extra/install-hangover-stable");
    G.pageIndex.value = 0;
  }),
  OutlinedButton(style: D.commandButtonStyle, child: Text(AppLocalizations.of(context)!.installHangoverLatest), onPressed: () async {
    Util.termWrite("bash /home/tiny/.local/share/tiny/extra/install-hangover");
    G.pageIndex.value = 0;
  }),
  OutlinedButton(style: D.commandButtonStyle, child: Text(AppLocalizations.of(context)!.uninstallHangover), onPressed: () {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning, color: Colors.orange, size: 48),
        title: const Text('Delete Wine hangover?'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('This will delete:'),
            SizedBox(height: 8),
            Text('•❌Full Wine🍷 ', style: TextStyle(color: Colors.red)),
            Text('•with Windows support', style: TextStyle(color: Colors.red)),
            Text('• for wine hangover!', style: TextStyle(color: Colors.red)),
            SizedBox(height: 12),
            Text('This action cannot be undone!'),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();             
              G.pageIndex.value = 0;
              Util.termWrite("sudo apt autoremove --purge -y hangover*");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Wine hangover deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete Now'),
          ),
        ],
      ),
    );
  },
),
  OutlinedButton(
  style: D.commandButtonStyle,
  child: Text(AppLocalizations.of(context)!.clearWineData),
  onPressed: () {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning, color: Colors.orange, size: 48),
        title: const Text('Delete Wine Prefix?'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('This will delete:'),
            SizedBox(height: 8),
            Text('• All Wine configuration', style: TextStyle(color: Colors.red)),
            Text('• Installed Windows apps', style: TextStyle(color: Colors.red)),
            Text('• Registry and save games with settings', style: TextStyle(color: Colors.red)),
            SizedBox(height: 12),
            Text('This action cannot be undone!'),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
              G.pageIndex.value = 0;
              Util.termWrite("rm -rf ~/.wine");
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Wine prefix deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete Now'),
          ),
        ],
      ),
    );
  },
),

OutlinedButton(
  style: D.commandButtonStyle,
  child: Text('Environment Settings'),
  onPressed: () {
    showDialog(
      context: context,
      builder: (context) => EnvironmentDialog(),
    );
  },
),

OutlinedButton(
  style: D.commandButtonStyle,
  child: Text('GPU Drivers'),
  onPressed: () {
    showDialog(
      context: context,
      builder: (context) => GpuDriversDialog(),
    );
  },
),


  // ADD THIS NEW DXVK BUTTON:
  OutlinedButton(
    style: D.commandButtonStyle,
    child: Text('Install DXVK'),
    onPressed: () {
      showDialog(
        context: context,
        builder: (context) => DxvkDialog(),
      );
    },
  ),
]),
          const SizedBox.square(dimension: 16),
          const Divider(height: 2, indent: 8, endIndent: 8),
          const SizedBox.square(dimension: 16),
          Text(AppLocalizations.of(context)!.wineCommandsHint),
          const SizedBox.square(dimension: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4.0,
            runSpacing: 4.0,
            children: (Localizations.localeOf(context).languageCode == 'zh' 
                ? D.wineCommands 
                : D.wineCommands4En
            ).asMap().entries.map<Widget>((e) {
              return OutlinedButton(
                style: D.commandButtonStyle,
                child: Text(e.value["name"]!),
                onPressed: () {
                  Util.termWrite("${e.value["command"]!} &");
                  G.pageIndex.value = 0;
                },
              );
            }).toList(),
          ),
          const SizedBox.square(dimension: 16),
          const Divider(height: 2, indent: 8, endIndent: 8),
          const SizedBox.square(dimension: 16),
          Text(AppLocalizations.of(context)!.restartRequiredHint),
          const SizedBox.square(dimension: 8),
          SwitchListTile(title: Text(AppLocalizations.of(context)!.switchToJapanese), subtitle: const Text("システムを日本語に切り替える"), value: Util.getGlobal("isJpEnabled") as bool, onChanged:(value) async {
            if (value) {
                Util.termWrite("sudo localedef -c -i ja_JP -f UTF-8 ja_JP.UTF-8");
                G.pageIndex.value = 0;
            }
            G.prefs.setBool("isJpEnabled", value);
            setState(() {});
          },),
        ],))),
    ],);
  }
}

class InfoPage extends StatefulWidget {
  final bool openFirstInfo;

  const InfoPage({super.key, this.openFirstInfo=false});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final List<bool> _expandState = [false, false, false, false];
  late AudioPlayer _gamesMusicPlayer;
  bool _isGamesMusicPlaying = false;
  
  @override
  void initState() {
    super.initState();
    _expandState[0] = widget.openFirstInfo;
    _gamesMusicPlayer = AudioPlayer();
    _setupMusicPlayer();
  }

  void _setupMusicPlayer() async {
    try {
      await _gamesMusicPlayer.setReleaseMode(ReleaseMode.loop);
      await _gamesMusicPlayer.setVolume(0.6);
    } catch (_) {
      // ignore audio errors
    }
  }

  void _startGamesMusic() async {
    if (_isGamesMusicPlaying) return;
    
    try {
      await _gamesMusicPlayer.play(AssetSource('music.mp3'));
      setState(() {
        _isGamesMusicPlaying = true;
      });
    } catch (_) {
      // ignore audio errors
      setState(() {
        _isGamesMusicPlaying = true;
      });
    }
  }

  void _stopGamesMusic() async {
    if (!_isGamesMusicPlaying) return;
    
    try {
      await _gamesMusicPlayer.stop();
      setState(() {
        _isGamesMusicPlaying = false;
      });
    } catch (_) {
      setState(() {
        _isGamesMusicPlaying = false;
      });
    }
  }

  @override
  void dispose() {
    _stopGamesMusic();
    _gamesMusicPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      elevation: 1,
      expandedHeaderPadding: const EdgeInsets.all(0),
      expansionCallback: (panelIndex, isExpanded) {
        // Control music based on games panel expansion
        if (panelIndex == 1) {
          if (isExpanded) {
            _startGamesMusic();
          } else {
            _stopGamesMusic();
          }
        }
        
        setState(() {
          _expandState[panelIndex] = isExpanded;
        });
      },
      children: [
        ExpansionPanel(
          headerBuilder: (context, isExpanded) {
            return ListTile(title: Text(AppLocalizations.of(context)!.userManual));
          },
          body: Padding(padding: const EdgeInsets.all(8), child: Column(
            children: [
              Text(AppLocalizations.of(context)!.firstLoadInstructions),
              const SizedBox.square(dimension: 16),
              Wrap(alignment: WrapAlignment.center, spacing: 4.0, runSpacing: 4.0, children: [
                OutlinedButton(style: D.commandButtonStyle, child: Text(AppLocalizations.of(context)!.requestStoragePermission), onPressed: () {
                  Permission.storage.request();
                }),
                OutlinedButton(style: D.commandButtonStyle, child: Text(AppLocalizations.of(context)!.requestAllFilesAccess), onPressed: () {
                  Permission.manageExternalStorage.request();
                }),
                OutlinedButton(style: D.commandButtonStyle, child: Text(AppLocalizations.of(context)!.ignoreBatteryOptimization), onPressed: () {
                  Permission.ignoreBatteryOptimizations.request();
                }),
              ]),
              const SizedBox.square(dimension: 16),
              Text(AppLocalizations.of(context)!.updateRequest),
              const SizedBox.square(dimension: 16),
              Wrap(alignment: WrapAlignment.center, spacing: 4.0, runSpacing: 4.0, children: D.links
              .asMap().entries.map<Widget>((e) {
                return OutlinedButton(style: D.commandButtonStyle, child: Text(Util.getl10nText(e.value["name"]!, context)), onPressed: () {
                  launchUrl(Uri.parse(e.value["value"]!), mode: LaunchMode.externalApplication);
                });
              }).toList()),
            ],
          )),
          isExpanded: _expandState[0],
        ),
        // ========== MINI GAMES SECTION ==========
        ExpansionPanel(
          isExpanded: _expandState[1],
          headerBuilder: ((context, isExpanded) {
            return ListTile(
              title: Text(AppLocalizations.of(context)!.mindTwisterGames),
              subtitle: Text(_isGamesMusicPlaying 
                ? AppLocalizations.of(context)!.extractionInProgress 
                : AppLocalizations.of(context)!.playWhileWaiting),
            );
          }), 
          body: _buildGamesSection(),
        ),
        // ========== END MINI GAMES SECTION ==========
        ExpansionPanel(
          isExpanded: _expandState[2],
          headerBuilder: ((context, isExpanded) {
            return ListTile(title: Text(AppLocalizations.of(context)!.permissionUsage));
          }), body: Padding(padding: const EdgeInsets.all(8), child: Text(AppLocalizations.of(context)!.privacyStatement))),
        ExpansionPanel(
          isExpanded: _expandState[3],
          headerBuilder: ((context, isExpanded) {
            return ListTile(title: Text(AppLocalizations.of(context)!.supportAuthor));
          }), body: Column(
          children: [
            Padding(padding: const EdgeInsets.all(8), child: Text(AppLocalizations.of(context)!.recommendApp)),
            ElevatedButton(
              onPressed: () {
                launchUrl(Uri.parse("https://github.com/xodiosx/XoDos2"), mode: LaunchMode.externalApplication);
              },
              child: Text(AppLocalizations.of(context)!.projectUrl),
            ),
          ]
        )),
      ],
    );
  }

  Widget _buildGamesSection() {
    return Container(
      height: 600,
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Status indicator
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              children: [
                Text(
                  '🎮 ${AppLocalizations.of(context)!.gameModeActive}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    _isGamesMusicPlaying ? Icons.music_note : Icons.music_off,
                    color: _isGamesMusicPlaying ? const Color(0xFFBB86FC) : Colors.grey,
                  ),
                  onPressed: () {
                    if (_isGamesMusicPlaying) {
                      _stopGamesMusic();
                    } else {
                      _startGamesMusic();
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SpiritedMiniGamesView(),
          ),
        ],
      ),
    );
  }
}





class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: AspectRatioMax1To1(child:
        Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: FractionallySizedBox(
                widthFactor: 0.4,
                child: Image(
                  image: AssetImage("images/icon.png")
                )
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
              child: ValueListenableBuilder(valueListenable: G.updateText, builder:(context, value, child) {
                return Text(value, textScaler: const TextScaler.linear(2));
              }),
            ),
            const FakeLoadingStatus(),
            const Expanded(child: Padding(padding: EdgeInsets.all(8), child: Card(child: Padding(padding: EdgeInsets.all(8), child: 
              Scrollbar(child:
                SingleChildScrollView(
                  child: InfoPage(openFirstInfo: true)
                )
              )
            ))
            ,))
          ]
        )
      )
    );
  }
}

class ForceScaleGestureRecognizer extends ScaleGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    super.acceptGesture(pointer);
  }
}

RawGestureDetector forceScaleGestureDetector({
  GestureScaleUpdateCallback? onScaleUpdate,
  GestureScaleEndCallback? onScaleEnd,
  Widget? child,
}) {
  return RawGestureDetector(
    gestures: {
      ForceScaleGestureRecognizer:GestureRecognizerFactoryWithHandlers<ForceScaleGestureRecognizer>(() {
        return ForceScaleGestureRecognizer();
      }, (detector) {
        detector.onUpdate = onScaleUpdate;
        detector.onEnd = onScaleEnd;
      })
    },
    child: child,
  );
}




class TerminalPage extends StatefulWidget {
  const TerminalPage({super.key});

  @override
  State<TerminalPage> createState() => _TerminalPageState();
}

class _TerminalPageState extends State<TerminalPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopActionButtons(),
        Expanded(
          child: forceScaleGestureDetector(
            onScaleUpdate: (details) {
              G.termFontScale.value = (details.scale * (Util.getGlobal("termFontScale") as double)).clamp(0.2, 5);
            }, 
            onScaleEnd: (details) async {
              await G.prefs.setDouble("termFontScale", G.termFontScale.value);
            }, 
           child: ValueListenableBuilder(
  valueListenable: G.termFontScale, 
  builder: (context, value, child) {
    return TerminalView(
      G.termPtys[G.currentContainer]!.terminal, 
      controller: G.termPtys[G.currentContainer]!.controller, // Make sure to pass the controller
      textScaler: TextScaler.linear(G.termFontScale.value), 
      keyboardType: TextInputType.multiline,
    );
  },
),
          ),
        ), 
        ValueListenableBuilder(
          valueListenable: G.terminalPageChange, 
          builder: (context, value, child) {
            return (Util.getGlobal("isTerminalCommandsEnabled") as bool) 
              ? _buildTermuxStyleControlBar()
              : const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildTopActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surfaceDark,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Start GUI button
          _buildTopActionButton(
            Icons.play_arrow,
            'Start Desktop,',
            _startGUI,
          ),
          
          // Exit/Stop button
          _buildTopActionButton(
            Icons.stop,
            'Exit Desktop',
            _exitContainer,
          ),
        ],
      ),
    );
  }

  Widget _buildTopActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primaryPurple),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primaryPurple),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startGUI() {
    if (G.wasX11Enabled) {
      Workflow.launchX11();
    } else if (G.wasAvncEnabled) {
      Workflow.launchAvnc();
    } else {
      Workflow.launchBrowser();
    }
  }

  void _exitContainer() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit 🛑'),
        content: const Text('This will stop the current container and exit. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel❌'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _forceExitContainer();
            },
            child: const Text('Exit✅'),
          ),
        ],
      ),
    );
  }

  void _forceExitContainer() {
    // Send exit commands to stop the container
    Util.termWrite('stopvnc');
    Util.termWrite('exit');
    Util.termWrite('exit');
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Container stopped. Starting fresh terminal...'),
        duration: Duration(seconds: 3),
      ),
    );
  }



// Update your copy function
Future<void> _copyTerminalText() async {
  try {
    final termPty = G.termPtys[G.currentContainer]!;
    final selection = termPty.controller.selection;
    
    if (selection != null) {
      final selectedText = termPty.terminal.buffer.getText(selection);
      
      if (selectedText.isNotEmpty) {
        // Use Flutter's built-in clipboard - this shares with Android system
        await Clipboard.setData(ClipboardData(text: selectedText));
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selected text copied to clipboard (shared with Android)'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No text selected - please select text in the terminal first'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No text selected - please select text by long-pressing and dragging in the terminal'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (e) {
    print('Copy error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to copy selected text'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// Update your paste function too
Future<void> _pasteToTerminal() async {
  try {
    // Use Flutter's built-in clipboard to get data from Android system
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    final clipboardText = data?.text;
    
    if (clipboardText != null && clipboardText.isNotEmpty) {
      Util.termWrite(clipboardText);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Clipboard is empty'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to paste from clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}


  Widget _buildTermuxStyleControlBar() {
    return Container(
      color: AppColors.surfaceDark,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // First row: Modifier keys + Copy/Paste
          Row(
            children: [
              // Modifier keys
              Expanded(
                child: _buildModifierKeys(),
              ),
              const SizedBox(width: 8),
              // Copy/Paste buttons
              _buildCopyPasteButtons(),
            ],
          ),
          const SizedBox(height: 8),
          // Second row: Function keys
          _buildFunctionKeys(),
        ],
      ),
    );
  }

  Widget _buildCopyPasteButtons() {
    return Row(
      children: [
        _buildTermuxKey(
          'COPY',
          onTap: _copyTerminalText,
        ),
        const SizedBox(width: 4),
        _buildTermuxKey(
          'PASTE', 
          onTap: _pasteToTerminal,
        ),
      ],
    );
  }

  Widget _buildModifierKeys() {
    return AnimatedBuilder(
      animation: G.keyboard,
      builder: (context, child) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTermuxKey(
            'CTRL',
            isActive: G.keyboard.ctrl,
            onTap: () => G.keyboard.ctrl = !G.keyboard.ctrl,
          ),
          _buildTermuxKey(
            'ALT', 
            isActive: G.keyboard.alt,
            onTap: () => G.keyboard.alt = !G.keyboard.alt,
          ),
          _buildTermuxKey(
            'SHIFT',
            isActive: G.keyboard.shift, 
            onTap: () => G.keyboard.shift = !G.keyboard.shift,
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionKeys() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: D.termCommands.length,
        separatorBuilder: (context, index) => const SizedBox(width: 4),
        itemBuilder: (context, index) {
          return _buildTermuxKey(
            D.termCommands[index]["name"]! as String,
            onTap: () {
              G.termPtys[G.currentContainer]!.terminal.keyInput(
                D.termCommands[index]["key"]! as TerminalKey
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTermuxKey(String label, {bool isActive = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 40,
          maxWidth: 80,
          minHeight: 32,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryPurple : AppColors.cardDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppColors.primaryPurple : AppColors.divider,
            width: 1,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.black : AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}




class FastCommands extends StatefulWidget {
  const FastCommands({super.key});

  @override
  State<FastCommands> createState() => _FastCommandsState();
}

class _FastCommandsState extends State<FastCommands> {
  // We'll keep the old edit functionality but use grouped display
  final List<bool> _sectionExpanded = [false, false, false];

  @override
  Widget build(BuildContext context) {
    // Get commands directly instead of using grouped commands
    final commands = Util.getCurrentProp("commands") as List<dynamic>;
    
    // Manually separate commands into categories
    final installCommands = _getInstallCommands(commands);
    final otherCommands = _getOtherCommands(commands);
    final systemCommands = _getSystemCommands(commands);
    
    return Column(
      children: [
        // Install Commands Section
        if (installCommands.isNotEmpty)
          Card(
            child: ExpansionTile(
              title: Text(
                'Installation Commands',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              initiallyExpanded: _sectionExpanded[0],
              onExpansionChanged: (expanded) {
                setState(() {
                  _sectionExpanded[0] = expanded;
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4.0,
                    runSpacing: 4.0,
                    children: _buildCommandButtons(installCommands),
                  ),
                ),
              ],
            ),
          ),
        
        // Other Commands Section
        if (otherCommands.isNotEmpty)
          Card(
            child: ExpansionTile(
              title: Text(
                'Other Commands',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              initiallyExpanded: _sectionExpanded[1],
              onExpansionChanged: (expanded) {
                setState(() {
                  _sectionExpanded[1] = expanded;
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4.0,
                    runSpacing: 4.0,
                    children: _buildCommandButtons(otherCommands),
                  ),
                ),
              ],
            ),
          ),
        
        // System Commands Section
        if (systemCommands.isNotEmpty)
          Card(
            child: ExpansionTile(
              title: Text(
                'effects',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              initiallyExpanded: _sectionExpanded[2],
              onExpansionChanged: (expanded) {
                setState(() {
                  _sectionExpanded[2] = expanded;
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4.0,
                    runSpacing: 4.0,
                    children: _buildCommandButtons(systemCommands),
                  ),
                ),
              ],
            ),
          ),
        
        // Add Command Button (kept at the bottom)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Theme.of(context).textTheme.bodyLarge!.color,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey[700]!),
            ),
            onPressed: _addCommand,
            onLongPress: _resetCommands,
            child: Text(AppLocalizations.of(context)!.addShortcutCommand),
          ),
        ),
      ],
    );
  }

  List<Map<String, String>> _getInstallCommands(List<dynamic> commands) {
    return commands.where((cmd) {
      final name = cmd["name"]?.toString().toLowerCase() ?? "";
      final command = cmd["command"]?.toString().toLowerCase() ?? "";
      return name.contains("install") || 
             command.contains("install") || 
             name.contains("enable");
    }).map((cmd) => Map<String, String>.from(cmd)).toList();
  }

  List<Map<String, String>> _getOtherCommands(List<dynamic> commands) {
    return commands.where((cmd) {
      final name = cmd["name"]?.toString().toLowerCase() ?? "";
      final command = cmd["command"]?.toString().toLowerCase() ?? "";
      return !name.contains("install") && 
             !command.contains("install") && 
             !name.contains("enable") &&
             name != "???" &&
             !name.contains("shutdown");
    }).map((cmd) => Map<String, String>.from(cmd)).toList();
  }

  List<Map<String, String>> _getSystemCommands(List<dynamic> commands) {
    return commands.where((cmd) {
      final name = cmd["name"]?.toString().toLowerCase() ?? "";
      return name.contains("shutdown") || name == "???";
    }).map((cmd) => Map<String, String>.from(cmd)).toList();
  }

  List<Widget> _buildCommandButtons(List<Map<String, String>> commands) {
    return commands.asMap().entries.map<Widget>((e) {
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).textTheme.bodyLarge!.color,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: Colors.grey[700]!),
        ),
        child: Text(e.value["name"]!),
        onPressed: () {
          Util.termWrite(e.value["command"]!);
          G.pageIndex.value = 0;
        },
        onLongPress: () {
          _editCommand(e.key, e.value);
        },
      );
    }).toList();
  }

  void _editCommand(int index, Map<String, String> cmd) {
  String name = cmd["name"]!;
  String command = cmd["command"]!;
  
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.commandEdit),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.commandName,
                ),
                onChanged: (value) {
                  name = value;
                },
              ),
              const SizedBox.square(dimension: 8),
              TextFormField(
                maxLines: null,
                initialValue: command,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.commandContent,
                ),
                onChanged: (value) {
                  command = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                // Get current commands
                List<dynamic> currentCommands = Util.getCurrentProp("commands");
                
                // Find the index of the command to delete
                int commandIndex = currentCommands.indexWhere((c) => 
                  c["name"] == cmd["name"] && c["command"] == cmd["command"]);
                
                if (commandIndex != -1) {
                  // Remove the command
                  currentCommands.removeAt(commandIndex);
                  
                  // Update the commands
                  await Util.setCurrentProp("commands", currentCommands);
                  
                  // Update UI
                  setState(() {});
                  
                  // Close dialog
                  Navigator.of(context).pop();
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Command "${cmd["name"]}" deleted!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                print('Error deleting command: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting command: $e'),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: Text(AppLocalizations.of(context)!.deleteItem),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Get current commands
                List<dynamic> currentCommands = Util.getCurrentProp("commands");
                
                // Find the index of the command to update
                int commandIndex = currentCommands.indexWhere((c) => 
                  c["name"] == cmd["name"] && c["command"] == cmd["command"]);
                
                if (commandIndex != -1) {
                  // Update the command
                  currentCommands[commandIndex] = {"name": name, "command": command};
                  
                  // Update the commands
                  await Util.setCurrentProp("commands", currentCommands);
                  
                  // Update UI
                  setState(() {});
                  
                  // Close dialog
                  Navigator.of(context).pop();
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Command "$name" updated!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                print('Error updating command: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error updating command: $e'),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      );
    },
  );
}

  void _addCommand() {
  String name = "";
  String command = "";
  final BuildContext dialogContext = context; // Store context before showing dialog
  
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.commandEdit),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.commandName,
                ),
                onChanged: (value) {
                  name = value;
                },
              ),
              const SizedBox.square(dimension: 8),
              TextFormField(
                maxLines: null,
                initialValue: command,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.commandContent,
                ),
                onChanged: (value) {
                  command = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              launchUrl(Uri.parse("https://github.com/xodiosx/XoDos2/blob/main/extracommand.md"),
                  mode: LaunchMode.externalApplication);
            },
            child: Text(AppLocalizations.of(context)!.more),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Get current commands
                List<dynamic> currentCommands = Util.getCurrentProp("commands");
                
                // Create new command
                final newCommand = {"name": name, "command": command};
                
                // Create new list with added command
                List<dynamic> newCommands = [...currentCommands, newCommand];
                
                // Update the commands
                await Util.setCurrentProp("commands", newCommands);
                
                // Close dialog
                Navigator.of(context).pop();
                
                // Update UI
                setState(() {});
                
                // Show success message
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text('Command "$name" added successfully!'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                print('Error adding command: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error adding command: $e'),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: Text(AppLocalizations.of(context)!.add),
          ),
        ],
      );
    },
  );
}

  void _resetCommands() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.resetCommand),
          content: Text(AppLocalizations.of(context)!.confirmResetAllCommands),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () async {
                final commands = Localizations.localeOf(context).languageCode == 'zh' 
                    ? D.commands 
                    : D.commands4En;
                await Util.setCurrentProp("commands", commands);
                setState(() {});
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.yes),
            ),
          ],
        );
      },
    );
  }
}

// Add this to your main.dart file, near the top with other global variables
class ExtractionProgressState {
  static double _progressT = 0.0;
  static bool _extractionComplete = false;
  static final List<VoidCallback> _listeners = [];

  static double get progressT => _progressT;
  static bool get extractionComplete => _extractionComplete;

  static void updateProgress(double progressT, bool complete) {
    _progressT = progressT;
    _extractionComplete = complete;
    _notifyListeners();
  }

  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  static void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
}



class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool bannerAdsFailedToLoad = false;
  bool isLoadingComplete = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero,() {
      _initializeWorkflow();
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky, overlays: []);
  }

  Future<void> _initializeWorkflow() async {
    await Workflow.workflow();
    if (mounted) {
      setState(() {
        isLoadingComplete = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    G.homePageStateContext = context;

    return RTLWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text(isLoadingComplete ? Util.getCurrentProp("name") : widget.title),
        ),
        body: isLoadingComplete
            ? ValueListenableBuilder(
                valueListenable: G.pageIndex,
                builder: (context, value, child) {
                  return IndexedStack(
                    index: G.pageIndex.value,
                    children: const [
                      TerminalPage(),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: AspectRatioMax1To1(
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              restorationId: "control-scroll",
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(16),
                                    child: FractionallySizedBox(
                                      widthFactor: 0.4,
                                      child: Image(image: AssetImage("images/icon.png")),
                                    ),
                                  ),
                                  FastCommands(),
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Card(
                                      child: Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Column(
                                          children: [
                                            SettingPage(),
                                            SizedBox.square(dimension: 8),
                                            InfoPage(openFirstInfo: false),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              )
            : const LoadingPage(),
        bottomNavigationBar: ValueListenableBuilder(
          valueListenable: G.pageIndex,
          builder: (context, value, child) {
            return Visibility(
              visible: isLoadingComplete,
              child: NavigationBar(
                selectedIndex: G.pageIndex.value,
                destinations: [
                  NavigationDestination(icon: const Icon(Icons.monitor), label: AppLocalizations.of(context)!.terminal),
                  NavigationDestination(icon: const Icon(Icons.video_settings), label: AppLocalizations.of(context)!.control),
                ],
                onDestinationSelected: (index) {
                  G.pageIndex.value = index;
                },
              ),
            );
          },
        ),
      ),
    );
  }
}



Widget _buildTermuxKey(String label, {bool isActive = false, VoidCallback? onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      constraints: const BoxConstraints(
        minWidth: 40,
        maxWidth: 80, // Limit maximum width
        minHeight: 32,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryPurple : AppColors.cardDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? AppColors.primaryPurple : AppColors.divider,
          width: 1,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : AppColors.textPrimary,
            fontSize: 10, // Smaller font size
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
  );
}


// ========== ADD THIS FUNCTION ==========
Widget buildWaitingGamesSection(BuildContext context) {
  return Container(
    height: 600, // Fixed height for the games section
    margin: const EdgeInsets.all(8),
    child: const SpiritedMiniGamesView(),
  );
}





