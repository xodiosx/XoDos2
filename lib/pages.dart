import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter_pty/flutter_pty.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:xterm/xterm.dart';
import 'package:avnc_flutter/avnc_flutter.dart';
import 'package:x11_flutter/x11_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'backup_restore_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'constants.dart';
import 'default_values.dart';
import 'core_classes.dart';
import 'spirited_mini_games.dart';
import 'main.dart'; // For RTLWrapper, etc.
import 'dialogs.dart';
import 'debug.dart';
//import 'app_colors.dart'; // Add this

import 'package:xodos/l10n/app_localizations.dart';

// Add the missing MyHomePage class at the TOP of the file:
class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoadingComplete = false;
  bool isWorkflowRunning = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
  }

  Future<void> _startWorkflow() async {
    if (isWorkflowRunning) return;

    setState(() {
      isWorkflowRunning = true;
    });

    // init is sync
    AndroidAppState.init();

    await Workflow.workflow();

    if (!mounted) return;
    setState(() {
      isLoadingComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    G.homePageStateContext = context;

    return RTLWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isLoadingComplete
                ? Util.getCurrentProp("name")
                : widget.title,
          ),
        ),

        // ---------------- BODY ----------------
        body: isLoadingComplete
            ? ValueListenableBuilder<int>(
                valueListenable: G.pageIndex,
                builder: (context, value, child) {
                  return IndexedStack(
                    index: value,
                    children: [
                      TerminalPage(),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: AspectRatioMax1To1(
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              restorationId: "control-scroll",
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: FractionallySizedBox(
                                      widthFactor: 0.4,
                                      child: Image.asset("images/icon.png"),
                                    ),
                                  ),
                                  FastCommands(),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          children: [
                                            SettingPage(),
                                            const SizedBox.square(dimension: 8),
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
            : Center(
                child: SizedBox(
                  width: 260,
                  height: 80,
                  child: ElevatedButton(
                    onPressed: _startWorkflow,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: isWorkflowRunning
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("START"),
                  ),
                ),
              ),

        // ---------------- NAV BAR ----------------
        bottomNavigationBar: isLoadingComplete
            ? ValueListenableBuilder<int>(
                valueListenable: G.pageIndex,
                builder: (context, value, child) {
                  return NavigationBar(
                    selectedIndex: value,
                    onDestinationSelected: (index) {
                      G.pageIndex.value = index;
                    },
                    destinations: [
                      NavigationDestination(
                        icon: const Icon(Icons.monitor),
                        label: AppLocalizations.of(context)!.terminal,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.video_settings),
                        label: AppLocalizations.of(context)!.control,
                      ),
                    ],
                  );
                },
              )
            : null,
      ),
    );
  }
}
//
// Setting Page
class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  // Correct order: 6 panels
  final List<bool> _expandState = [false, false, false, false, false, false];
  double _avncScaleFactor = Util.getGlobal("avncScaleFactor") as double;

  void _showBackupRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) => const BackupRestoreDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      elevation: 1,
      expandedHeaderPadding: const EdgeInsets.all(0),
      expansionCallback: (panelIndex, isExpanded) {
        setState(() {
          _expandState[panelIndex] = isExpanded;
        });
      },
      children: [
        // Panel 0: Advanced Settings
        ExpansionPanel(
          isExpanded: _expandState[0],
          headerBuilder: (context, isExpanded) {
            return ListTile(
              title: Text(AppLocalizations.of(context)!.advancedSettings),
              subtitle: Text(AppLocalizations.of(context)!.restartAfterChange),
            );
          },
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 4.0,
                runSpacing: 4.0,
                children: [
                  OutlinedButton(
                    style: D.commandButtonStyle,
                    child: Text(AppLocalizations.of(context)!.resetStartupCommand),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(AppLocalizations.of(context)!.attention),
                            content: Text(AppLocalizations.of(context)!.confirmResetCommand),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(AppLocalizations.of(context)!.cancel),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await Util.setCurrentProp(
                                    "boot",
                                    Localizations.localeOf(context).languageCode == 'zh'
                                        ? D.boot
                                        : D.boot.replaceFirst('LANG=zh_CN.UTF-8', 'LANG=en_US.UTF-8')
                                            .replaceFirst('公共', 'Public')
                                            .replaceFirst('图片', 'Pictures')
                                            .replaceFirst('音乐', 'Music')
                                            .replaceFirst('视频', 'Videos')
                                            .replaceFirst('下载', 'Downloads')
                                            .replaceFirst('文档', 'Documents')
                                            .replaceFirst('照片', 'Photos'),
                                  );
                                  G.bootTextChange.value = !G.bootTextChange.value;
                                  if (!context.mounted) return;
                                  Navigator.of(context).pop();
                                },
                                child: Text(AppLocalizations.of(context)!.yes),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  OutlinedButton(
                    style: D.commandButtonStyle,
                    child: Text(AppLocalizations.of(context)!.signal9ErrorPage),
                    onPressed: () async {
                      await D.androidChannel.invokeMethod("launchSignal9Page", {});
                    },
                  ),
                ],
              ),
              const SizedBox.square(dimension: 8),
              TextFormField(
                maxLines: null,
                initialValue: Util.getCurrentProp("name"),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.containerName,
                ),
                onChanged: (value) async {
                  await Util.setCurrentProp("name", value);
                },
              ),
              const SizedBox.square(dimension: 8),
              ValueListenableBuilder(
                valueListenable: G.bootTextChange,
                builder: (context, v, child) {
                  return TextFormField(
                    maxLines: null,
                    initialValue: Util.getCurrentProp("boot"),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.startupCommand,
                    ),
                    onChanged: (value) async {
                      await Util.setCurrentProp("boot", value);
                    },
                  );
                },
              ),
              const SizedBox.square(dimension: 8),
              TextFormField(
                maxLines: null,
                initialValue: Util.getCurrentProp("vnc"),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.vncStartupCommand,
                ),
                onChanged: (value) async {
                  await Util.setCurrentProp("vnc", value);
                },
              ),
              const SizedBox.square(dimension: 8),
              const Divider(height: 2, indent: 8, endIndent: 8),
              const SizedBox.square(dimension: 16),
              Text(AppLocalizations.of(context)!.shareUsageHint),
              const SizedBox.square(dimension: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 4.0,
                runSpacing: 4.0,
                children: [
                  OutlinedButton(
                    style: D.commandButtonStyle,
                    child: Text(AppLocalizations.of(context)!.copyShareLink),
                    onPressed: () async {
                      final String? ip = await NetworkInfo().getWifiIP();
                      if (!context.mounted) return;
                      if (G.wasX11Enabled) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context)!.x11InvalidHint)),
                        );
                        return;
                      }
                      if (ip == null) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context)!.cannotGetIpAddress)),
                        );
                        return;
                      }
                      Clipboard.setData(
                        ClipboardData(
                          text: (Util.getCurrentProp("vncUrl") as String)
                              .replaceAll(RegExp.escape("localhost"), ip),
                        ),
                      ).then((value) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context)!.shareLinkCopied)),
                        );
                      });
                    },
                  ),
                ],
              ),
              const SizedBox.square(dimension: 16),
              TextFormField(
                maxLines: null,
                initialValue: Util.getCurrentProp("vncUrl"),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.webRedirectUrl,
                ),
                onChanged: (value) async {
                  await Util.setCurrentProp("vncUrl", value);
                },
              ),
              const SizedBox.square(dimension: 8),
              TextFormField(
                maxLines: null,
                initialValue: Util.getCurrentProp("vncUri"),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.vncLink,
                ),
                onChanged: (value) async {
                  await Util.setCurrentProp("vncUri", value);
                },
              ),
              const SizedBox.square(dimension: 8),
            ]),
          ),
        ),

// Panel 1: Global Settings
ExpansionPanel(
  isExpanded: _expandState[1],
  headerBuilder: (context, isExpanded) {
    return ListTile(
      title: Text(AppLocalizations.of(context)!.globalSettings),
      subtitle: Text(AppLocalizations.of(context)!.enableTerminalEditing),
    );
  },
  body: Padding(
    padding: const EdgeInsets.all(12),
    child: Column(children: [
      TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        initialValue: (Util.getGlobal("termMaxLines") as int).toString(),
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: AppLocalizations.of(context)!.terminalMaxLines,
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          return Util.validateBetween(value, 1024, 2147483647, () async {
            await G.prefs.setInt("termMaxLines", int.parse(value!));
          });
        },
      ),
      const SizedBox.square(dimension: 16),
      TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        initialValue: (Util.getGlobal("defaultAudioPort") as int).toString(),
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: AppLocalizations.of(context)!.pulseaudioPort,
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          return Util.validateBetween(value, 0, 65535, () async {
            await G.prefs.setInt("defaultAudioPort", int.parse(value!));
          });
        },
      ),
      const SizedBox.square(dimension: 16),
      SwitchListTile(
        title: Text(AppLocalizations.of(context)!.enableTerminal),
        value: Util.getGlobal("isTerminalWriteEnabled") as bool,
        onChanged: (value) {
          G.prefs.setBool("isTerminalWriteEnabled", value);
          setState(() {});
        },
      ),
      const SizedBox.square(dimension: 8),
      SwitchListTile(
        title: Text(AppLocalizations.of(context)!.enableTerminalKeypad),
        value: Util.getGlobal("isTerminalCommandsEnabled") as bool,
        onChanged: (value) {
          G.prefs.setBool("isTerminalCommandsEnabled", value);
          setState(() {
            G.terminalPageChange.value = !G.terminalPageChange.value;
          });
        },
      ),
      const SizedBox.square(dimension: 8),
      SwitchListTile(
        title: Text(AppLocalizations.of(context)!.terminalStickyKeys),
        value: Util.getGlobal("isStickyKey") as bool,
        onChanged: (value) {
          G.prefs.setBool("isStickyKey", value);
          setState(() {});
        },
      ),
      const SizedBox.square(dimension: 8),
      SwitchListTile(
        title: Text(AppLocalizations.of(context)!.keepScreenOn),
        value: Util.getGlobal("wakelock") as bool,
        onChanged: (value) {
          G.prefs.setBool("wakelock", value);
          WakelockPlus.toggle(enable: value);
          setState(() {});
        },
      ),
      const SizedBox.square(dimension: 8),
      const Divider(height: 2, indent: 8, endIndent: 8),
      const SizedBox.square(dimension: 16),
      Text(AppLocalizations.of(context)!.restartRequiredHint),
      const SizedBox.square(dimension: 8),
      SwitchListTile(
        title: Text(AppLocalizations.of(context)!.startWithGUI),
        value: Util.getGlobal("autoLaunchVnc") as bool,
        onChanged: (value) {
          G.prefs.setBool("autoLaunchVnc", value);
          setState(() {});
        },
      ),
      const SizedBox.square(dimension: 8),
      SwitchListTile(
        title: Text(AppLocalizations.of(context)!.reinstallBootPackage),
        value: Util.getGlobal("reinstallBootstrap") as bool,
        onChanged: (value) {
          G.prefs.setBool("reinstallBootstrap", value);
          setState(() {});
        },
      ),
      const SizedBox.square(dimension: 8),
      SwitchListTile(
        title: Text(AppLocalizations.of(context)!.getifaddrsBridge),
        subtitle: Text(AppLocalizations.of(context)!.fixGetifaddrsPermission),
        value: Util.getGlobal("getifaddrsBridge") as bool,
        onChanged: (value) {
          G.prefs.setBool("getifaddrsBridge", value);
          setState(() {});
        },
      ),
      const SizedBox.square(dimension: 8),
      // LOGCAT SWITCH - IMMEDIATE START/STOP
      SwitchListTile(
        title: Text('Logcat Capture'),
        subtitle: Text('Save system logs to app storage'),
        value: Util.getGlobal("logcatEnabled") as bool,
        onChanged: (value) async {
          await G.prefs.setBool("logcatEnabled", value);
          if (value) {
            LogcatManager().startCapture();
          } else {
            LogcatManager().stopCapture();
          }
          setState(() {});
        },
      ),
      // LOG MANAGEMENT BUTTONS
      const SizedBox.square(dimension: 8),
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: Icon(Icons.folder, size: 16),
              label: Text('View Logs'),
              onPressed: () async {
                final files = await LogcatManager().getLogFiles();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Log Files (${files.length})'),
                    content: Container(
                      width: double.maxFinite,
                      height: 300,
                      child: ListView.builder(
                        itemCount: files.length,
                        itemBuilder: (context, index) => ListTile(
                          title: Text(files[index]),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, size: 16),
                            onPressed: () async {
                              final logDir = await LogcatManager().getLogDirectory();
                              final file = File('${logDir.path}/${files[index]}');
                              await file.delete();
                              Navigator.pop(context);
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Deleted ${files[index]}')),
                              );
                            },
                          ),
                          onTap: () async {
                            final content = await LogcatManager().readLogFile(files[index]);
                            if (content != null) {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(files[index]),
                                  content: Container(
                                    width: double.maxFinite,
                                    height: 400,
                                    child: SingleChildScrollView(
                                      child: SelectableText(content),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              icon: Icon(Icons.delete, size: 16, color: Colors.red),
              label: Text('Clear All', style: TextStyle(color: Colors.red)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Clear All Logs?'),
                    content: Text('This will delete all log files. This cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final success = await LogcatManager().clearLogs();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success 
                                ? 'All logs cleared successfully'
                                : 'Failed to clear logs'),
                            ),
                          );
                        },
                        child: Text('Clear All', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      const SizedBox.square(dimension: 8),
      SwitchListTile(
        title: Text(AppLocalizations.of(context)!.fakeUOSSystem),
        value: Util.getGlobal("uos") as bool,
        onChanged: (value) {
          G.prefs.setBool("uos", value);
          setState(() {});
        },
      ),
    ]),
  ),
),
        // Panel 2: Display Settings
        ExpansionPanel(
          isExpanded: _expandState[2],
          headerBuilder: (context, isExpanded) {
            return ListTile(
              title: Text(AppLocalizations.of(context)!.displaySettings),
            );
          },
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              const SizedBox.square(dimension: 16),
              Text(AppLocalizations.of(context)!.hidpiAdvantages),
              const SizedBox.square(dimension: 16),
              TextFormField(
                maxLines: null,
                initialValue: Util.getGlobal("defaultHidpiOpt") as String,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.hidpiEnvVar,
                ),
                onChanged: (value) async {
                  await G.prefs.setString("defaultHidpiOpt", value);
                },
              ),
              const SizedBox.square(dimension: 8),
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.hidpiSupport),
                subtitle: Text(AppLocalizations.of(context)!.applyOnNextLaunch),
                value: Util.getGlobal("isHidpiEnabled") as bool,
                onChanged: (value) {
                  G.prefs.setBool("isHidpiEnabled", value);
                  _avncScaleFactor += value ? 0.5 : -0.5;
                  _avncScaleFactor = _avncScaleFactor.clamp(-1, 1);
                  G.prefs.setDouble("avncScaleFactor", _avncScaleFactor);
                  X11Flutter.setX11ScaleFactor(value ? 0.5 : 2.0);
                  setState(() {});
                },
              ),
              const SizedBox.square(dimension: 16),
              const Divider(height: 2, indent: 8, endIndent: 8),
              const SizedBox.square(dimension: 16),
              Text(AppLocalizations.of(context)!.avncAdvantages),
              const SizedBox.square(dimension: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 4.0,
                runSpacing: 4.0,
                children: [
                  OutlinedButton(
                    style: D.commandButtonStyle,
                    child: Text(AppLocalizations.of(context)!.avncSettings),
                    onPressed: () async {
                      await AvncFlutter.launchPrefsPage();
                    },
                  ),
                  OutlinedButton(
                    style: D.commandButtonStyle,
                    child: Text(AppLocalizations.of(context)!.aboutAVNC),
                    onPressed: () async {
                      await AvncFlutter.launchAboutPage();
                    },
                  ),
                  OutlinedButton(
                    style: D.commandButtonStyle,
                    onPressed: Util.getGlobal("avncResizeDesktop") as bool
                        ? null
                        : () async {
                            final s = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;
                            final w0 = max(s.width, s.height);
                            final h0 = min(s.width, s.height);
                            String w = (w0 * 0.75).round().toString();
                            String h = (h0 * 0.75).round().toString();
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(AppLocalizations.of(context)!.resolutionSettings),
                                  content: SingleChildScrollView(
                                    child: Column(children: [
                                      Text("${AppLocalizations.of(context)!.deviceScreenResolution} ${w0.round()}x${h0.round()}"),
                                      const SizedBox.square(dimension: 8),
                                      TextFormField(
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                        initialValue: w,
                                        decoration: InputDecoration(
                                          border: const OutlineInputBorder(),
                                          labelText: AppLocalizations.of(context)!.width,
                                        ),
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          return Util.validateBetween(value, 200, 7680, () {
                                            w = value!;
                                          });
                                        },
                                      ),
                                      const SizedBox.square(dimension: 8),
                                      TextFormField(
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                        initialValue: h,
                                        decoration: InputDecoration(
                                          border: const OutlineInputBorder(),
                                          labelText: AppLocalizations.of(context)!.height,
                                        ),
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          return Util.validateBetween(value, 200, 7680, () {
                                            h = value!;
                                          });
                                        },
                                      ),
                                    ]),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(AppLocalizations.of(context)!.cancel),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Util.termWrite("""sed -i -E "s@(geometry)=.*@\\1=${w}x${h}@" /etc/tigervnc/vncserver-config-tmoe
sed -i -E "s@^(VNC_RESOLUTION)=.*@\\1=${w}x${h}@" \$(command -v startvnc)""");
                                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                              content: Text("${w}x${h}. ${AppLocalizations.of(context)!.applyOnNextLaunch}")),
                                        );
                                        if (!context.mounted) return;
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(AppLocalizations.of(context)!.save),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                    child: Text(AppLocalizations.of(context)!.avncResolution),
                  ),
                ],
              ),
              const SizedBox.square(dimension: 8),
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.useAVNCByDefault),
                subtitle: Text(AppLocalizations.of(context)!.applyOnNextLaunch),
                value: Util.getGlobal("useAvnc") as bool,
                onChanged: (value) {
                  G.prefs.setBool("useAvnc", value);
                  setState(() {});
                },
              ),
              const SizedBox.square(dimension: 8),
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.avncScreenResize),
                value: Util.getGlobal("avncResizeDesktop") as bool,
                onChanged: (value) {
                  G.prefs.setBool("avncResizeDesktop", value);
                  setState(() {});
                },
              ),
              const SizedBox.square(dimension: 8),
              ListTile(
                title: Text(AppLocalizations.of(context)!.avncResizeFactor),
                onTap: () {},
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text('${AppLocalizations.of(context)!.avncResizeFactorValue} ${pow(4, _avncScaleFactor).toStringAsFixed(2)}x'),
                    const SizedBox(height: 12),
                    Slider(
                      value: _avncScaleFactor,
                      min: -1,
                      max: 1,
                      divisions: 96,
                      onChangeEnd: (double value) {
                        G.prefs.setDouble("avncScaleFactor", value);
                      },
                      onChanged: Util.getGlobal("avncResizeDesktop") as bool
                          ? (double value) {
                              _avncScaleFactor = value;
                              setState(() {});
                            }
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox.square(dimension: 16),
              const Divider(height: 2, indent: 8, endIndent: 8),
              const SizedBox.square(dimension: 16),
              Text(AppLocalizations.of(context)!.termuxX11Advantages),
              const SizedBox.square(dimension: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 4.0,
                runSpacing: 4.0,
                children: [
                  OutlinedButton(
                    style: D.commandButtonStyle,
                    child: Text(AppLocalizations.of(context)!.termuxX11Preferences),
                    onPressed: () async {
                      await X11Flutter.launchX11PrefsPage();
                    },
                  ),
                ],
              ),
              const SizedBox.square(dimension: 8),
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.useTermuxX11ByDefault),
                subtitle: Text(AppLocalizations.of(context)!.disableVNC),
                value: Util.getGlobal("useX11") as bool,
                onChanged: (value) {
                  G.prefs.setBool("useX11", value);
                  if (!value && Util.getGlobal("dri3")) {
                    G.prefs.setBool("dri3", false);
                  }
                  setState(() {});
                },
              ),
              const SizedBox.square(dimension: 16),
            ]),
          ),
        ),

        // Panel 3: Graphics Acceleration
// Panel 3: Graphics Acceleration
ExpansionPanel(
  isExpanded: _expandState[3],
  headerBuilder: (context, isExpanded) {
    return ListTile(
      title: Text(AppLocalizations.of(context)!.graphicsAcceleration),
      subtitle: Text(AppLocalizations.of(context)!.experimentalFeature),
    );
  },
  body: Padding(
    padding: const EdgeInsets.all(12),
    child: Column(children: [
      Text(AppLocalizations.of(context)!.graphicsAccelerationHint),
      const SizedBox.square(dimension: 16),
      
      // Virgl section
      Text(AppLocalizations.of(context)!.virglServerParams,
          style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox.square(dimension: 8),
      TextFormField(
        maxLines: null,
        initialValue: Util.getGlobal("defaultVirglCommand") as String,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: AppLocalizations.of(context)!.virglServerParams,
        ),
        onChanged: (value) async {
          await G.prefs.setString("defaultVirglCommand", value);
        },
      ),
      const SizedBox.square(dimension: 8),
      TextFormField(
        maxLines: null,
        initialValue: Util.getGlobal("defaultVirglOpt") as String,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: AppLocalizations.of(context)!.virglEnvVar,
        ),
        onChanged: (value) async {
          await G.prefs.setString("defaultVirglOpt", value);
        },
      ),
      const SizedBox.square(dimension: 8),
      SwitchListTile(
        title: Text(AppLocalizations.of(context)!.enableVirgl),
        subtitle: Text(AppLocalizations.of(context)!.applyOnNextLaunch),
        value: Util.getGlobal("virgl") as bool,
        onChanged: (value) {
          if (value) {
            // If enabling virgl, disable venus and turnip
            G.prefs.setBool("venus", false);
            G.prefs.setBool("turnip", false);
            // Also disable DRI3 if it was enabled
            if (Util.getGlobal("dri3")) {
              G.prefs.setBool("dri3", false);
            }
          }
          G.prefs.setBool("virgl", value);
          setState(() {});
        },
      ),
      
      const SizedBox.square(dimension: 16),
      const Divider(height: 2, indent: 8, endIndent: 8),
      const SizedBox.square(dimension: 16),
      
      // Venus section
      Text(AppLocalizations.of(context)!.venusAdvantages,
          style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox.square(dimension: 8),
      Text(AppLocalizations.of(context)!.venusAdvantages),
      const SizedBox.square(dimension: 8),
      TextFormField(
        maxLines: null,
        initialValue: Util.getGlobal("defaultVenusCommand") as String,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: AppLocalizations.of(context)!.venusServerParams,
        ),
        onChanged: (value) async {
          await G.prefs.setString("defaultVenusCommand", value);
        },
      ),
      const SizedBox.square(dimension: 8),
      TextFormField(
        maxLines: null,
        initialValue: Util.getGlobal("defaultVenusOpt") as String,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: AppLocalizations.of(context)!.venusEnvVar,
        ),
        onChanged: (value) async {
          await G.prefs.setString("defaultVenusOpt", value);
        },
      ),
      const SizedBox.square(dimension: 8),
      SwitchListTile(
        title: Text(AppLocalizations.of(context)!.enableVenus),
        subtitle: Text(AppLocalizations.of(context)!.applyOnNextLaunch),
        value: Util.getGlobal("venus") as bool,
        onChanged: (value) {
          if (value) {
            // If enabling venus, disable virgl and turnip
            G.prefs.setBool("virgl", false);
            G.prefs.setBool("turnip", false);

          }
          G.prefs.setBool("venus", value);
          
          if (!value && Util.getGlobal("dri3")) {
            G.prefs.setBool("dri3", false);
          }
          setState(() {});
        },
      ),
      const SizedBox.square(dimension: 8),
      SwitchListTile(
        title: Text(AppLocalizations.of(context)!.enableAndroidVenus),
        subtitle: Text(AppLocalizations.of(context)!.venusAdvantages),
        value: Util.getGlobal("androidVenus") as bool,
        onChanged: (value) async {
          await G.prefs.setBool("androidVenus", value);
          setState(() {});
        },
      ),
      
      const SizedBox.square(dimension: 16),
      const Divider(height: 2, indent: 8, endIndent: 8),
      const SizedBox.square(dimension: 16),
      
      // Turnip section
      Text(AppLocalizations.of(context)!.turnipAdvantages,
          style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox.square(dimension: 8),
      TextFormField(
        maxLines: null,
        initialValue: Util.getGlobal("defaultTurnipOpt") as String,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: AppLocalizations.of(context)!.turnipEnvVar,
        ),
        onChanged: (value) async {
          await G.prefs.setString("defaultTurnipOpt", value);
        },
      ),
      const SizedBox.square(dimension: 8),
      SwitchListTile(
        title: Text(AppLocalizations.of(context)!.enableTurnipZink),
        subtitle: Text(AppLocalizations.of(context)!.applyOnNextLaunch),
        value: Util.getGlobal("turnip") as bool,
        onChanged: (value) async {
          if (value) {
            // If enabling turnip, disable virgl and venus
            G.prefs.setBool("virgl", false);
            G.prefs.setBool("venus", false);
          }
          G.prefs.setBool("turnip", value);
          if (!value && Util.getGlobal("dri3")) {
            G.prefs.setBool("dri3", false);
          }
          setState(() {});
        },
      ),
      const SizedBox.square(dimension: 8),
      SwitchListTile(
        title: Text(AppLocalizations.of(context)!.enableDRI3),
        subtitle: Text(AppLocalizations.of(context)!.applyOnNextLaunch),
        value: Util.getGlobal("dri3") as bool,
        onChanged: (value) async {
        final bool useX11 = Util.getGlobal("useX11") == true;
  final bool turnip = Util.getGlobal("turnip") == true;
  final bool venus  = Util.getGlobal("venus") == true;
           if (value && !(useX11 && (turnip || venus))) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.dri3Requirement)),
            );
            return;
          }
          G.prefs.setBool("dri3", value);
          setState(() {});
        },
      ),
      const SizedBox.square(dimension: 16),
    ]),
  ),
),



        // Panel 4: Windows App Support (with backup/restore button added)
        ExpansionPanel(
          isExpanded: _expandState[4],
          headerBuilder: (context, isExpanded) {
            return ListTile(
              title: Text(AppLocalizations.of(context)!.windowsAppSupport),
              subtitle: Text(AppLocalizations.of(context)!.experimentalFeature),
            );
          },
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              Text(AppLocalizations.of(context)!.hangoverDescription),
              const SizedBox.square(dimension: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 4.0,
                runSpacing: 4.0,
                children: [
                 
                  
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
                  
                  
OutlinedButton(
            style: D.commandButtonStyle,
            child: Text('Wine bionic Settings🍷'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => WineSettingsDialog(),
              );
            },
          ),
        ],
      ),
              
              const SizedBox.square(dimension: 16),
              const Divider(height: 2, indent: 8, endIndent: 8),
              const SizedBox.square(dimension: 16),
              Text(AppLocalizations.of(context)!.wineCommandsHint),
              const SizedBox.square(dimension: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 4.0,
                runSpacing: 4.0,
                children: (Localizations.localeOf(context).languageCode == 'zh' ? D.wineCommands : D.wineCommands4En)
                    .asMap()
                    .entries
                    .map<Widget>((e) {
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
              OutlinedButton(
                    style: D.commandButtonStyle,
                    child: Text("${AppLocalizations.of(context)!.installHangoverStable}（10.14）"),
                    onPressed: () async {
                      Util.termWrite("bash /home/tiny/.local/share/tiny/extra/install-hangover-stable");
                      G.pageIndex.value = 0;
                    },
                  ),
              OutlinedButton(
                style: D.commandButtonStyle,
                child: Text(AppLocalizations.of(context)!.installHangoverLatest),
                onPressed: () async {
                  Util.termWrite("bash //extra/install-hangover");
                  G.pageIndex.value = 0;
                },
              ),
              OutlinedButton(
                style: D.commandButtonStyle,
                child: Text(AppLocalizations.of(context)!.uninstallHangover),
                onPressed: () {
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
                            Util.termWrite("rm -rf ~/.wine");
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
                child: Text('Delete Wine x86_64🍷'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      icon: const Icon(Icons.warning, color: Colors.orange, size: 48),
                      title: const Text('Delete Wine x86_64?'),
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('This will delete:'),
                          SizedBox(height: 8),
                          Text('•❌Full Wine🍷 ', style: TextStyle(color: Colors.red)),
                          Text('•with Windows support', style: TextStyle(color: Colors.red)),
                          Text('• for wine x86_64!', style: TextStyle(color: Colors.red)),
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
                            Util.termWrite("rm -rf /opt/wine");
                            Util.termWrite("rm -rf ~/.wine");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Wine deleted'),
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
                child: Text('Delete Wine Bionic🍷'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      icon: const Icon(Icons.warning, color: Colors.orange, size: 48),
                      title: const Text('Delete Wine bionic?'),
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('This will delete:'),
                          SizedBox(height: 8),
                          Text('•❌Full Wine🍷 ', style: TextStyle(color: Colors.red)),
                          Text('•with Windows support', style: TextStyle(color: Colors.red)),
                          Text('• for wine bionic!', style: TextStyle(color: Colors.red)),
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
                            Util.termWrite("rm -rf ${G.dataPath}/usr/opt/wine");
                            Util.termWrite("rm -rf ${G.dataPath}/home/.wine");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Wine deleted'),
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
              const SizedBox.square(dimension: 16),
              const Divider(height: 2, indent: 8, endIndent: 8),
              const SizedBox.square(dimension: 16),
              Text(AppLocalizations.of(context)!.restartRequiredHint),
              const SizedBox.square(dimension: 8),
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.switchToJapanese),
                subtitle: const Text("システムを日本語に切り替える"),
                value: Util.getGlobal("isJpEnabled") as bool,
                onChanged: (value) async {
                  if (value) {
                    Util.termWrite("sudo localedef -c -i ja_JP -f UTF-8 ja_JP.UTF-8");
                    G.pageIndex.value = 0;
                  }
                  G.prefs.setBool("isJpEnabled", value);
                  setState(() {});
                },
              ),
            ]),
          ),
        ),




        // Panel 5: System Backup & Restore (New panel)
        ExpansionPanel(
          isExpanded: _expandState[5],
          headerBuilder: (context, isExpanded) {
            return ListTile(
              title: Text(AppLocalizations.of(context)!.systemBackupRestore),
              subtitle: Text(AppLocalizations.of(context)!.backupRestoreDescriptionShort),
            );
          },
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(AppLocalizations.of(context)!.backupRestoreWarning),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.backup),
                      label: Text(AppLocalizations.of(context)!.backupSystem),
                      onPressed: _showBackupRestoreDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.restore),
                      label: Text(AppLocalizations.of(context)!.restoreSystem),
                      onPressed: _showBackupRestoreDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.backupNote,
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Info Page
class InfoPage extends StatefulWidget {
  final bool openFirstInfo;

  const InfoPage({super.key, this.openFirstInfo=false});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final List<bool> _expandState = [false, false, false, false, false];
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
        ExpansionPanel(
        isExpanded: _expandState[2],
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
          isExpanded: _expandState[3],
          headerBuilder: ((context, isExpanded) {
            return ListTile(title: Text(AppLocalizations.of(context)!.permissionUsage));
          }), body: Padding(padding: const EdgeInsets.all(8), child: Text(AppLocalizations.of(context)!.privacyStatement))),
        ExpansionPanel(
          isExpanded: _expandState[4],
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

// Loading Page
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

// Terminal Page
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
      controller: G.termPtys[G.currentContainer]!.controller,
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
          _buildTopActionButton(
            Icons.play_arrow,
            'Start Desktop,',
            _startGUI,
          ),
          
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
    Util.termWrite('stopvnc');
    Util.termWrite('pkill -f dbus');
    Util.termWrite('pkill -f wine');
    Util.termWrite('pkill -f virgl*');
    Util.termWrite('pkill -f lxqt');
    Util.termWrite('exit');
    Util.termWrite('exit');
    
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(' session stopped. closing app...'),
        duration: Duration(seconds: 3),
      ),
    );
    SystemNavigator.pop();
  }

// In the _copyTerminalText method:
Future<void> _copyTerminalText() async {
  try {
    final termPty = G.termPtys[G.currentContainer]!;
    final selection = termPty.controller.selection;
    
    if (selection != null) {
      final selectedText = termPty.terminal.buffer.getText(selection);
      
      if (selectedText.isNotEmpty) {
        // Use the correct Clipboard API
        await Clipboard.setData(ClipboardData(text: selectedText));
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selected text copied to clipboard'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No text selected'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No text selected - please select text by long-pressing and dragging'),
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

// In the _pasteToTerminal method:
Future<void> _pasteToTerminal() async {
  try {
    // Use the correct Clipboard API
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
          Row(
            children: [
              Expanded(
                child: _buildModifierKeys(),
              ),
              const SizedBox(width: 8),
              _buildCopyPasteButtons(),
            ],
          ),
          const SizedBox(height: 8),
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














// Fast Commands
class FastCommands extends StatefulWidget {
  const FastCommands({super.key});

  @override
  State<FastCommands> createState() => _FastCommandsState();
}

class _FastCommandsState extends State<FastCommands> {
  final List<bool> _sectionExpanded = [false, false, false];

  @override
  Widget build(BuildContext context) {
    final commands = Util.getCurrentProp("commands") as List<dynamic>;
    
    final installCommands = _getInstallCommands(commands);
    final otherCommands = _getOtherCommands(commands);
    final systemCommands = _getSystemCommands(commands);
    
    return Column(
      children: [
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
                List<dynamic> currentCommands = Util.getCurrentProp("commands");
                
                int commandIndex = currentCommands.indexWhere((c) => 
                  c["name"] == cmd["name"] && c["command"] == cmd["command"]);
                
                if (commandIndex != -1) {
                  currentCommands.removeAt(commandIndex);
                  
                  await Util.setCurrentProp("commands", currentCommands);
                  
                  setState(() {});
                  
                  Navigator.of(context).pop();
                  
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
                List<dynamic> currentCommands = Util.getCurrentProp("commands");
                
                int commandIndex = currentCommands.indexWhere((c) => 
                  c["name"] == cmd["name"] && c["command"] == cmd["command"]);
                
                if (commandIndex != -1) {
                  currentCommands[commandIndex] = {"name": name, "command": command};
                  
                  await Util.setCurrentProp("commands", currentCommands);
                  
                  setState(() {});
                  
                  Navigator.of(context).pop();
                  
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
  final BuildContext dialogContext = context;
  
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
                List<dynamic> currentCommands = Util.getCurrentProp("commands");
                
                final newCommand = {"name": name, "command": command};
                
                List<dynamic> newCommands = [...currentCommands, newCommand];
                
                await Util.setCurrentProp("commands", newCommands);
                
                Navigator.of(context).pop();
                
                setState(() {});
                
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

// Helper functions
Widget buildWaitingGamesSection(BuildContext context) {
  return Container(
    height: 600,
    margin: const EdgeInsets.all(8),
    child: const SpiritedMiniGamesView(),
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


// ============================================
// WINE SETTINGS DIALOG
// ============================================
// ============================================
// WINE SETTINGS DIALOG
// ============================================

class WineSettingsDialog extends StatefulWidget {
  const WineSettingsDialog({super.key});

  @override
  State<WineSettingsDialog> createState() => _WineSettingsDialogState();
}

class _WineSettingsDialogState extends State<WineSettingsDialog> {
  // Controllers for text fields
  final TextEditingController _displayController = TextEditingController();
  final TextEditingController _winePrefixController = TextEditingController();
  final TextEditingController _wineArchController = TextEditingController();
  final TextEditingController _wineCommandController = TextEditingController();
  
  // State variables
  bool _wineRunning = false;
  bool _isLoading = true;
  bool _initialized = false;
  bool _winePrefixExists = false;
  bool _creatingWinePrefix = false;
  bool _startingWine = false;
  bool _startingExplorer = false;
  late String _dataPath;
  late String _home;
  
  // PTY for Wine
  Pty? _winePty;
  
  // Timer variables for monitoring
  int _monitorLoopCount = 0;
  static const int _maxMonitorLoops = 10;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  @override
  void dispose() {
    _winePty?.kill();
    _displayController.dispose();
    _winePrefixController.dispose();
    _wineArchController.dispose();
    _wineCommandController.dispose();
    super.dispose();
  }
  
  // ==============================
  // LOAD SETTINGS
  // ==============================
  Future<void> _loadSettings() async {
    try {
      // Get data path from main.dart's G.dataPath
      final context = G.homePageStateContext;
      _dataPath = G.dataPath;
      _home = '$_dataPath/home';
      
      // Load saved settings or use defaults
      _displayController.text = ':4';
      _winePrefixController.text = '$_home/.wine';
      _wineArchController.text = 'win64';
      _wineCommandController.text = 'xodxx';
      
      // Check if Wine prefix exists
      await _checkWinePrefixExists();
      
      // Check if Wine is already running
      await _checkWineProcess();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // ==============================
  // CHECK IF WINE PREFIX EXISTS
  // ==============================
  Future<void> _checkWinePrefixExists() async {
    try {
      final winePrefix = _winePrefixController.text;
      final readyFile = File('$winePrefix/.ready');
      
      setState(() {
        _winePrefixExists = readyFile.existsSync();
      });
    } catch (_) {
      setState(() {
        _winePrefixExists = false;
      });
    }
  }
  
  // ==============================
  // CREATE WINE PREFIX
  // ==============================
  Future<void> _createWinePrefix() async {
    _creatingWinePrefix = true;
    _monitorLoopCount = 0;
    
    // Show creating wine prefix loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Creating Wine Prefix'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Creating Wine prefix, please wait...'),
            const SizedBox(height: 8),
            Text(
              'This may take a few minutes...',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
    
    try {
      // Initialize PTY if not already done
      if (!_initialized) {
        await _initWinePty();
      }
      
      // Send command to create wine prefix
      final createCommand = '''
# Create wine prefix
echo "Creating Wine prefix..."
export WINEPREFIX="${_winePrefixController.text}"
export WINEARCH="${_wineArchController.text}"

# Kill any existing wine processes
pkill -f "wine" 
pkill -f "winhandler.exe" 

# Create wine prefix using wineboot
#${_dataPath}/usr/opt/wine/bin/wineboot -i
xodxx
# Create .ready file to mark prefix as ready
mkdir -p "${_winePrefixController.text}"
#touch "${_winePrefixController.text}/.ready"
echo "Wine prefix created successfully!"
sleep 3
pkill -f "wine" 
pkill -f "winhandler.exe" 

# Start winhandler.exe to initialize
#${_dataPath}/usr/opt/wine/bin/wine winhandler.exe &
echo "WinHandler started"
''';
      
      _winePty!.write(Utf8Encoder().convert(createCommand));
      await Future.delayed(const Duration(seconds: 60)); //wait for wineboot
      // Monitor for winhandler.exe in a loop
      bool winHandlerStarted = await _monitorForWinHandler();
      
      if (mounted) {
        Navigator.of(context).pop(); // Close creating dialog
        
        if (winHandlerStarted) {
          setState(() {
            _winePrefixExists = true;
            _creatingWinePrefix = false;
            
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wine prefix created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          _creatingWinePrefix = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create Wine prefix'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        _creatingWinePrefix = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating Wine prefix: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // ==============================
  // MONITOR FOR WINHANDLER.EXE
  // ==============================
  Future<bool> _monitorForWinHandler() async {
    for (_monitorLoopCount = 0; _monitorLoopCount < _maxMonitorLoops; _monitorLoopCount++) {
      await Future.delayed(const Duration(seconds: 20)); // Check every minute
      
      try {
        final result = await Process.run(
          '/system/bin/sh',
          ['-c', 'pgrep -x "winhandler.exe" >/dev/null 2>&1 && echo "RUNNING"'],
          environment: _buildEnvironment(),
        );
        
        if (result.stdout.toString().contains('RUNNING')) {
          print('WinHandler.exe detected after $_monitorLoopCount minutes');
          return true;
        }
      } catch (_) {}
      
      // Also check if .ready file exists
      final readyFile = File('${_winePrefixController.text}/.ready');
      if (readyFile.existsSync()) {
        print('.ready file found after $_monitorLoopCount minutes');
        return true;
      }
    }
    
    return false; // WinHandler not started within timeout
  }
  
  // ==============================
  // SAVE SETTINGS
  // ==============================
  Future<void> _saveSettings() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // ==============================
  // BUILD ENVIRONMENT VARIABLES
  // ==============================
  Map<String, String> _buildEnvironment() {
    final env = <String, String>{};
    
    // Set up PATH and library paths
    env['PATH'] = '$_dataPath/bin:$_dataPath/usr/bin';
    env['LD_LIBRARY_PATH'] = '$_dataPath/lib:$_dataPath/usr/lib';
    
    // Core environment variables
    env['HOME'] = _home;
    env['DATA_DIR'] = _dataPath;
    env['PREFIX'] = '$_dataPath/usr';
    env['TMPDIR'] = '$_dataPath/usr/tmp';
    env['XDG_RUNTIME_DIR'] = '$_dataPath/usr/tmp/runtime';
    env['XDG_CACHE_HOME'] = '$_dataPath/usr/tmp/.cache';
    
    // Display and X11
    env['DISPLAY'] = _displayController.text;
    env['XDG_RUNTIME_DIR'] = '$_dataPath/usr/tmp';
    env['X11_UNIX_PATH'] = '$_dataPath/usr/tmp/.X11-unix';
    
    // Wine specific
    env['WINEPREFIX'] = _winePrefixController.text;
    env['WINEARCH'] = _wineArchController.text;
    env['WINE'] = '$_dataPath/usr/opt/wine/bin/wine';
    
    // Terminal and locale
    env['TERM'] = 'xterm-256color';
    env['LANG'] = 'en_US.UTF-8';
    env['SHELL'] = '$_dataPath/usr/bin/bash';
    
    // Performance and debugging
    env['BOX64_LOG'] = '0';
    env['DXVK_STATE_CACHE'] = '1';
    env['DXVK_LOG_PATH'] = '$_home/.cache';
    env['DXVK_STATE_CACHE_PATH'] = '$_home/.cache';
    
    // Android specific
    env['ANDROID_ROOT'] = '/system';
    env['ANDROID_DATA'] = '/data';
    env['ANDROID_STORAGE'] = '/storage';
    env['EXTERNAL_STORAGE'] = '/sdcard';
    
    return env;
  }
  
  // ==============================
  // BUILD FULL COMMAND
  // ==============================
  String _buildFullCommand() {
    final envVars = _buildEnvironment();
    final envString = envVars.entries.map((e) => 'export ${e.key}="${e.value}"').join('\n');
    
    return '''
$envString
[ -f $_dataPath/usr/opt/drv ] && . $_dataPath/usr/opt/drv
${_wineCommandController.text}
''';
  }
  
  // ==============================
  // INITIALIZE WINE PTY
  // ==============================
  Future<void> _initWinePty() async {
    if (_initialized && _winePty != null) {
      return;
    }
    
    final envVars = _buildEnvironment();
    
    // Create PTY with proper environment
    _winePty = Pty.start(
      '$_dataPath/usr/bin/sh',
      workingDirectory: _home,
      environment: envVars,
    );
    
    // Set up environment in the shell
    final setupCommands = '''
# Set up the shell environment
cd $_dataPath
export PATH=\${PATH}:$_dataPath/usr/bin:$_dataPath/bin
export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:$_dataPath/lib:$_dataPath/usr/lib
unset LD_LIBRARY_PATH

# Create necessary directories
mkdir -p $_home
mkdir -p $_dataPath/usr/tmp
mkdir -p \${WINEPREFIX}

# Set up X11 socket link
mkdir -p $_dataPath/usr/tmp/.X11-unix

# Source Settings  if available
[ -f $_dataPath/usr/opt/env ] && . $_dataPath/usr/opt/env
[ -f $_dataPath/usr/opt/drv ] && . $_dataPath/usr/opt/drv
[ -f $_dataPath/usr/opt/hud ] && . $_dataPath/usr/opt/hud
[ -f $_dataPath/usr/opt/dyna ] && . $_dataPath/usr/opt/dyna


echo "Wine environment initialized on ${_displayController.text}"
''';
    
    _winePty!.write(Utf8Encoder().convert(setupCommands));
    
    // Listen for output (for debugging)
    _winePty!.output.cast<List<int>>().transform(Utf8Decoder()).listen((data) {
      print('Wine PTY: $data');
    });
    
    _initialized = true;
  }
  
  // ==============================
  // DISMISS ALL DIALOGS
  // ==============================
  void _dismissAllDialogs() {
    Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
  }
  
  // ==============================
  // LAUNCH DESKTOP AFTER WINE
  // ==============================
  void _launchDesktopAfterWine() async {
    // Dismiss all dialogs first
   // _dismissAllDialogs();
    Navigator.of(context).pop(true);
    // Add a small delay to ensure dialog is fully dismissed
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Then launch desktop from the main context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (G.wasX11Enabled) {
        Workflow.launchX11();
      } else if (G.wasAvncEnabled) {
        Workflow.launchAvnc();
      } else {
        Workflow.launchBrowser();
      }
    });
  }
  
  // ==============================
  // START TASK MANAGER
  // ==============================
  Future<void> _startTaskManager() async {
    // Check if Wine is running
    await _checkWineProcess();
    Navigator.of(context).pop();

      if (_wineRunning) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wine is already running'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    
    try {
      // Initialize PTY if not already done
      if (!_initialized) {
        await _initWinePty();
      }
      
      // Send taskmgr command to the existing Wine PTY
      final taskMgrCommand = 'xod taskmgr\n';
      _winePty!.write(Utf8Encoder().convert(taskMgrCommand));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task Manager started'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start Task Manager: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // ==============================
  // START WINE
  // ==============================
  Future<void> _startWine() async {
    try {
      // Check if already running
      await _checkWineProcess();
      if (_wineRunning) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wine is already running'),
            backgroundColor: Colors.blue,
          ),
        );
        
        // If already running, still dismiss and launch desktop
        _launchDesktopAfterWine();
        return;
      }
      
      // Check if wine prefix exists
      await _checkWinePrefixExists();
      
      if (!_winePrefixExists) {
        // Show option to create wine prefix first
        bool createPrefix = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Wine Prefix Not Found'),
            content: const Text('Wine prefix does not exist. Create it now?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Create'),
              ),
            ],
          ),
        ) ?? false;
        
        if (createPrefix) {
          await _createWinePrefix();
          // After creating prefix, continue with starting wine
          if (!_winePrefixExists) {
            return; // Prefix creation failed
          }
        } else {
          return; // User cancelled
        }
      }
      
      // Show starting wine loading dialog
      _startingWine = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Starting Wine'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Launching Windows environment...'),
              const SizedBox(height: 8),
              Text(
                'Waiting for Wine to start...',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      );
      
      // Initialize PTY if not already done
      if (!_initialized) {
        await _initWinePty();
      }
      
      // Build and send command to Wine PTY using the user-editable command
      final command = '''
# Kill any existing Wine processes
pkill -f "wine" 2>/dev/null || true
pkill -f "winhandler.exe" 2>/dev/null || true
pkill -f ".exe" 2>/dev/null || true

# Run the Wine command (user-editable)
echo "Starting: ${_wineCommandController.text}"
${_wineCommandController.text} 
''';
      
      _winePty!.write(Utf8Encoder().convert(command));
      
      // Start monitoring for winhandler.exe
      _monitorLoopCount = 0;
      bool winHandlerStarted = await _monitorForWinHandler();
      
      if (mounted) {
        Navigator.of(context).pop(); // Close starting dialog
        
        if (winHandlerStarted) {
          _startingWine = false;
          await _checkWineProcess();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wine started successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          _launchDesktopAfterWine();
          
        } else {
          _startingWine = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to start Wine (timeout)'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Try to close any open dialogs
       if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        _startingWine = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start Wine: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error starting wine: $e');
    }
  }
  
  // ==============================
  // START EXPLORER
  // ==============================
  Future<void> _startExplorer() async {
    try {
      // Check if already running
      await _checkWineProcess();
      if (_wineRunning) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wine is already running'),
            backgroundColor: Colors.blue,
          ),
        );
      }
      
      // Check if wine prefix exists
      await _checkWinePrefixExists();
      
      if (!_winePrefixExists) {
        // Show option to create wine prefix first
        bool createPrefix = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Wine Prefix Not Found'),
            content: const Text('Wine prefix does not exist. Create it now?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Create'),
              ),
            ],
          ),
        ) ?? false;
        
        if (createPrefix) {
          await _createWinePrefix();
          // After creating prefix, continue with starting explorer
          if (!_winePrefixExists) {
            return; // Prefix creation failed
          }
        } else {
          return; // User cancelled
        }
      }
      
      // Show starting explorer loading dialog
      _startingExplorer = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Starting Explorer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Launching Windows Explorer...'),
              const SizedBox(height: 8),
              Text(
                'Waiting for Explorer to start...',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      );
      
      // Initialize PTY if not already done
      if (!_initialized) {
        await _initWinePty();
      }
      
      // Build and send command to Wine PTY for explorer
      final command = '''
# Kill any existing Wine processes


# Run the Explorer command
echo "Starting: xod explorer"
xod $_dataPath/usr/opt/apps/wfm.exe
''';
      
      _winePty!.write(Utf8Encoder().convert(command));
      
      // Start monitoring for winhandler.exe
      _monitorLoopCount = 0;
      bool winHandlerStarted = await _monitorForWinHandler();
      
      if (mounted) {
        Navigator.of(context).pop(); // Close starting dialog
        
        if (winHandlerStarted) {
          _startingExplorer = false;
          await _checkWineProcess();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Explorer started successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          _launchDesktopAfterWine();
        } else {
          _startingExplorer = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to start Explorer (timeout)'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Try to close any open dialogs
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        _startingExplorer = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start Explorer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error starting explorer: $e');
    }
  }
  
  // ==============================
  // STOP WINE
  // ==============================
  Future<void> _stopWine() async {
    try {
      // Show confirmation dialog
      bool confirmed = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Stop Wine?'),
          content: const Text('This will stop all Wine processes. Continue?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Stop'),
            ),
          ],
        ),
      ) ?? false;
      
      if (!confirmed) return;
      try {
        final result = await Process.run(
          '/system/bin/sh',
          ['-c', 'pkill -f "wine" && pkill -f "winhandler.exe" && pkill -f "*.exe"'],
          environment: _buildEnvironment(),
        );
        
        
      } catch (_) {}
      
      
      /*  
      // Send kill command to Wine PTY
      final killCommand = '''
# Kill Wine processes
pkill -f "wine" && pkill -f "winhandler.exe" && pkill -f "*.exe"
echo "Wine processes stopped"
''';
      
      _winePty?.write(Utf8Encoder().convert(killCommand));
      */
      await Future.delayed(const Duration(seconds: 1));
      await _checkWineProcess();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wine stopped'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (_) {}
  }
  
  // ==============================
  // CHECK WINE PROCESS
  // ==============================
  Future<void> _checkWineProcess() async {
    try {
      final result = await Process.run(
        '/system/bin/sh',
        ['-c', 'pgrep -x start.exe >/dev/null 2>&1 && echo RUNNING || echo STOPPED'],
        environment: _buildEnvironment(),
      );
      
      final isRunning = result.stdout.toString().trim() == 'RUNNING';
      
      if (mounted) {
        setState(() {
          _wineRunning = isRunning;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _wineRunning = false;
        });
      }
    }
  }
  
  // ==============================
  // RESET TO DEFAULT SETTINGS
  // ==============================
  void _resetToDefault() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Default?'),
        content: const Text('This will reset all settings to default values. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _displayController.text = ':4';
                _winePrefixController.text = '$_home/.wine';
                _wineArchController.text = 'win64';
                _wineCommandController.text = 'xodxx';
              });
              _saveSettings();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
  
  // ==============================
  // TEST WINE CONFIGURATION
  // ==============================
  Future<void> _testWineConfig() async {
    try {
      if (!_initialized) {
        await _initWinePty();
      }
      
      final testPty = Pty.start(
        '$_dataPath/usr/bin/sh',
        workingDirectory: _home,
        environment: _buildEnvironment(),
      );
      
      String output = '';
      
      testPty.output.cast<List<int>>().transform(Utf8Decoder()).listen((data) {
        output += data;
      });
      
      final cmd = '''
export PATH="$_dataPath/usr/bin:\$PATH"
export LD_LIBRARY_PATH="$_dataPath/usr/lib:\$LD_LIBRARY_PATH"
unset LD_LIBRARY_PATH
export WINEPREFIX="${_winePrefixController.text}"
export WINEARCH="${_wineArchController.text}"
echo "=== Wine Configuration Test ==="
echo "Wine Prefix: \$WINEPREFIX"
echo "Wine Arch: \$WINEARCH"
echo "Display: \$DISPLAY"
echo "\\n=== Checking Wine Prefix ==="
if [ -f "\$WINEPREFIX/.ready" ]; then
  echo "✓ Wine prefix exists and is ready"
else
  echo "✗ Wine prefix not found or not ready"
fi
echo "\\n=== Wine Version ==="
box64 "${_dataPath}/usr/opt/wine/bin/wine" --version 2>&1 || echo "Failed to get wine version"
cat "${_dataPath}/usr/opt/drv"
echo "\\n=== Test Complete ==="
''';
      
      testPty.write(Utf8Encoder().convert(cmd));
      
      await Future.delayed(const Duration(seconds: 3));
      testPty.kill();
      
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Wine Test Result'),
          content: SingleChildScrollView(
            child: Text(output.isEmpty ? 'No output' : output),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Wine test failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // ==============================
  // EDIT FULL COMMAND
  // ==============================
  void _editFullCommand() {
    final fullCommand = _buildFullCommand();
    final TextEditingController editController = TextEditingController(text: fullCommand);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.edit, size: 20),
                SizedBox(width: 8),
                Text('Edit Launcher Command'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edit the full launcher command below:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Note: The actual wine command is the last line',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      constraints: const BoxConstraints(minHeight: 200),
                      child: TextFormField(
                        controller: editController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(12),
                          hintText: 'Enter full launcher command...',
                        ),
                        style: const TextStyle(
                          fontFamily: 'Monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tip: The command will be saved and used when starting Wine',
                      style: TextStyle(fontSize: 11, color: Colors.blue),
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
                onPressed: () {
                  final editedCommand = editController.text;
                  // Extract the wine command (last non-empty line)
                  final lines = editedCommand.split('\n');
                  String wineCommand = '';
                  
                  // Find the last non-empty line (should be the wine command)
                  for (int i = lines.length - 1; i >= 0; i--) {
                    if (lines[i].trim().isNotEmpty) {
                      wineCommand = lines[i].trim();
                      break;
                    }
                  }
                  
                  // Update the wine command controller
                  _wineCommandController.text = wineCommand;
                  
                  // Save settings
                  _saveSettings();
                  
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Launcher command updated'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Save Command'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  // ==============================
  // SHOW FULL COMMAND PREVIEW
  // ==============================
  void _showCommandPreview() {
    final fullCommand = _buildFullCommand();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Full Command Preview'),
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            fullCommand,
            style: const TextStyle(
              fontFamily: 'Monospace',
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: fullCommand));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Command copied to clipboard')),
              );
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }
  
  // ==============================
  // UI
  // ==============================
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AlertDialog(
        title: Text('Loading Wine Settings...'),
        content: Center(child: CircularProgressIndicator()),
      );
    }
    
    return AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.wine_bar, color: Colors.deepPurple),
          SizedBox(width: 8),
          Text('Wine Launcher'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wine Prefix Status Card
              Card(
                color: _winePrefixExists ? Colors.green[900] : Colors.orange[900],
                child: ListTile(
                  leading: Icon(
                    _winePrefixExists ? Icons.check_circle : Icons.warning,
                    color: _winePrefixExists ? Colors.green : Colors.orange,
                  ),
                  title: const Text('Wine Prefix Status'),
                  subtitle: Text(_winePrefixExists ? 'Ready' : 'Not Created'),
                  trailing: !_winePrefixExists && !_creatingWinePrefix
                      ? IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.blue),
                          onPressed: _createWinePrefix,
                          tooltip: 'Create Wine Prefix',
                        )
                      : _creatingWinePrefix
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Wine Running Status Card - ORIGINAL LAYOUT
              Card(
                color: _wineRunning ? Colors.green[150] : Colors.red[150],
                child: ListTile(
                  leading: Icon(
                    _wineRunning ? Icons.check_circle : Icons.cancel,
                    color: _wineRunning ? Colors.green : Colors.red,
                  ),
                  title: const Text('Wine Status'),
                  subtitle: Text(_wineRunning ? 'Running' : 'Not Running'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _checkWineProcess,
                        tooltip: 'Refresh Status',
                      ),
                      if (_wineRunning)
                        IconButton(
                          icon: const Icon(Icons.stop, color: Colors.red),
                          onPressed: _stopWine,
                          tooltip: 'Stop Wine',
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Configuration Settings
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Wine Configuration',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _displayController,
                              decoration: const InputDecoration(
                                labelText: 'DISPLAY',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.display_settings),
                                hintText: ':4',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _wineArchController,
                              decoration: const InputDecoration(
                                labelText: 'Architecture',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.architecture),
                                hintText: 'win64',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      TextFormField(
                        controller: _winePrefixController,
                        decoration: const InputDecoration(
                          labelText: 'Wine Prefix',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.folder),
                          hintText: '/data/data/com.xodos/files/home/.wine',
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      TextFormField(
                        controller: _wineCommandController,
                        decoration: const InputDecoration(
                          labelText: 'Wine Command',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.terminal),
                          hintText: 'xod explorer.exe, xod notepad.exe, etc.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Quick Action Buttons
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Edit Command'),
                              onPressed: _editFullCommand,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(0, 40),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.visibility, size: 18),
                              label: const Text('Preview'),
                              onPressed: _showCommandPreview,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 40),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.bug_report, size: 18),
                        label: const Text('Test Configuration'),
                        onPressed: _testWineConfig,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 40),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Main Action Buttons
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // Start Wine Button
                      ElevatedButton.icon(
                        icon: _startingWine
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.play_arrow),
                        label: _startingWine
                            ? const Text('Starting Wine. Desktop..')
                            : const Text('Start Wine Desktop'),
                        onPressed: _startingWine ? null : _startWine,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Start Explorer Button
/*
                      
                      */
                      OutlinedButton.icon(
                        icon: const Icon(Icons.task, size: 20),
                        label: const Text('Start Explorer'),
                        onPressed: _startExplorer,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          side: BorderSide(
                            color: _wineRunning ? Colors.grey : Colors.purple,
                            width: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      
                      // Task Manager Button
                      OutlinedButton.icon(
                        icon: const Icon(Icons.task, size: 20),
                        label: const Text('Task Manager'),
                        onPressed: _startTaskManager,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          side: BorderSide(
                            color: _wineRunning ? Colors.blue : Colors.grey,
                            width: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.save),
                              label: const Text('Save'),
                              onPressed: _saveSettings,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 40),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.restart_alt),
                              label: const Text('Reset'),
                              onPressed: _resetToDefault,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 40),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Information
              Card(
                color: Colors.blue[900],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Wine Launcher Information',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• uses wine bionic arm64\n'
                        '• support for native vulkan wrapper/drivers \n'
                        '• support for gamepad using x11\n'
                        '• dri3 and touch controls only with x11 \n'
                        '• Uses X11 socket :4 for display\n'
                        '• More Settings can be adjusted on the Settings',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            label: const Text('wine'),
                            backgroundColor: Colors.deepPurple[700],
                          ),
                          Chip(
                            label: const Text('bionic'),
                            backgroundColor: Colors.green[700],
                          ),
                          Chip(
                            label: const Text('Box64'),
                            backgroundColor: Colors.purple[700],
                          ),
                          Chip(
                            label: const Text('windows'),
                            backgroundColor: Colors.orange[700],
                          ),
                        ],
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
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            _saveSettings();
            Navigator.pop(context);
          },
          child: const Text('Save & Close'),
        ),
      ],
    );
  }
}