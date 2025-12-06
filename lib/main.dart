
import 'dart:async';


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

// Add this DxvkDialog class after AppColors
// DxvkDialog class
class DxvkDialog extends StatefulWidget {
  @override
  _DxvkDialogState createState() => _DxvkDialogState();
}

class _DxvkDialogState extends State<DxvkDialog> {
  String? _selectedDxvk;
  List<String> _dxvkFiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDxvkFiles();
  }

  Future<void> _loadDxvkFiles() async {
    try {
      final dir = Directory('containers/0/wincomponents/d3d');
      if (!await dir.exists()) {
        setState(() {
          _dxvkFiles = [];
          _isLoading = false;
        });
        return;
      }
      
      final files = await dir.list().toList();
      final tzstFiles = files
          .where((file) => file is File && file.path.endsWith('.tzst'))
          .map((file) => file.path.split('/').last)
          .toList();
      
      setState(() {
        _dxvkFiles = tzstFiles;
        if (tzstFiles.isNotEmpty) {
          _selectedDxvk = tzstFiles.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _dxvkFiles = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _extractDxvk() async {
    if (_selectedDxvk == null) return;
    
    final homeDir = Directory('/home/xodos/.wine/drive_c/windows');
    if (!await homeDir.exists()) {
      await homeDir.create(recursive: true);
    }
    
    final dxvkPath = 'containers/0/wincomponents/d3d/$_selectedDxvk';
    
    Navigator.of(context).pop(); // Close dialog
    
    // Show progress
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Extracting $_selectedDxvk...'),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Execute extraction command
    Util.termWrite("tar -xaf '$dxvkPath' -C /home/xodos/.wine/drive_c/windows --strip-components=1");
    G.pageIndex.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Install DXVK'),
      content: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            if (!_isLoading && _dxvkFiles.isEmpty)
              Text('No DXVK files found in /wincomponents/d3d/ please install full version'),
            if (!_isLoading && _dxvkFiles.isNotEmpty)
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (_dxvkFiles.isNotEmpty && !_isLoading)
          ElevatedButton(
            onPressed: _selectedDxvk == null ? null : _extractDxvk,
            child: const Text('Install'),
          ),
      ],
    );
  }
}




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





//限制最大宽高比1:1
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
  OutlinedButton(style: D.commandButtonStyle, child: Text(AppLocalizations.of(context)!.uninstallHangover), onPressed: () async {
    Util.termWrite("sudo apt autoremove --purge -y hangover*");
    G.pageIndex.value = 0;
  }),
  OutlinedButton(style: D.commandButtonStyle, child: Text(AppLocalizations.of(context)!.clearWineData), onPressed: () async {
    Util.termWrite("rm -rf ~/.wine");
    G.pageIndex.value = 0;
  }),
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
  final List<bool> _sectionExpanded = [true, false, false];

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
                'System',
                style: TextStyle(
                  fontSize: 18,
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


        
        // Remove or comment out this floatingActionButton section from MyHomePage:
/*
floatingActionButton: ValueListenableBuilder(
  valueListenable: G.pageIndex,
  builder: (context, value, child) {
    return Visibility(
      visible: isLoadingComplete && (value == 0),
      child: FloatingActionButton(
        tooltip: AppLocalizations.of(context)!.enterGUI,
        onPressed: () {
          if (G.wasX11Enabled) {
            Workflow.launchX11();
          } else if (G.wasAvncEnabled) {
            Workflow.launchAvnc();
          } else {
            Workflow.launchBrowser();
          }
        },
        child: const Icon(Icons.play_arrow),
      ),
    );
  },
),
*/

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









