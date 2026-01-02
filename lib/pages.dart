import 'dart:async';
import 'dart:io';
import 'dart:math';

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

//import 'app_colors.dart'; // Add this

import 'package:xodos/l10n/app_localizations.dart';

// Add the missing MyHomePage class at the TOP of the file:
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

// ... then continue with all the other classes from the original file:

// Setting Page
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
    // If enabling virgl, disable turnip
    G.prefs.setBool("turnip", false);
    // Also disable DRI3 if it was enabled (since it requires turnip)
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
              Text(AppLocalizations.of(context)!.turnipAdvantages),
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
                G.prefs.setBool("virgl", false);
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
                  if (value && !(Util.getGlobal("turnip") && Util.getGlobal("useX11"))) {
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
                    child: Text("${AppLocalizations.of(context)!.installHangoverStable}（10.14）"),
                    onPressed: () async {
                      Util.termWrite("bash /extra/install-hangover-stable");
                      G.pageIndex.value = 0;
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
                child: Text(AppLocalizations.of(context)!.installHangoverLatest),
                onPressed: () async {
                  Util.termWrite("bash /extra/install-hangover");
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
                            Util.termWrite("rm -rf /home/xodos/.wine");
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
                child: Text('Delete Wine x68_64🍷'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      icon: const Icon(Icons.warning, color: Colors.orange, size: 48),
                      title: const Text('Delete Wine x68_64?'),
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('This will delete:'),
                          SizedBox(height: 8),
                          Text('•❌Full Wine🍷 ', style: TextStyle(color: Colors.red)),
                          Text('•with Windows support', style: TextStyle(color: Colors.red)),
                          Text('• for wine x68_64!', style: TextStyle(color: Colors.red)),
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
                            Util.termWrite("rm -rf /home/xodos/.wine");
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

// Terminal Page (xterm 4.0.0 compatible)
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
              G.termFontScale.value =
                  (details.scale * (Util.getGlobal("termFontScale") as double))
                      .clamp(0.2, 5);
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
            'Start Desktop',
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
        content: const Text(
            'This will stop the current container and exit. Are you sure?'),
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
        content: Text('Session stopped. Closing app...'),
        duration: Duration(seconds: 3),
      ),
    );
    SystemNavigator.pop();
  }

  Future<void> _copyTerminalText() async {
    final termPty = G.termPtys[G.currentContainer]!;
    // xterm 4.0.0 no longer has terminal.selection
    // Use controller.buffer for copy logic if available
    final buffer = termPty.terminal.buffer;
    final lineCount = buffer.lines.length;
final textBuffer = StringBuffer();

for (int i = 0; i < lineCount; i++) {
  textBuffer.writeln(buffer.lines[i].string);
}

final text = textBuffer.toString();
    if (text.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Text copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _pasteToTerminal() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      Util.termWrite(data.text!);
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
              Expanded(child: _buildModifierKeys()),
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
        _buildTermuxKey('COPY', onTap: _copyTerminalText),
        const SizedBox(width: 4),
        _buildTermuxKey('PASTE', onTap: _pasteToTerminal),
      ],
    );
  }

  Widget _buildModifierKeys() {
    return AnimatedBuilder(
      animation: G.keyboard,
      builder: (context, child) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTermuxKey('CTRL',
              isActive: G.keyboard.ctrl,
              onTap: () => G.keyboard.ctrl = !G.keyboard.ctrl),
          _buildTermuxKey('ALT',
              isActive: G.keyboard.alt,
              onTap: () => G.keyboard.alt = !G.keyboard.alt),
          _buildTermuxKey('SHIFT',
              isActive: G.keyboard.shift,
              onTap: () => G.keyboard.shift = !G.keyboard.shift),
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
        separatorBuilder: (_, __) => const SizedBox(width: 4),
        itemBuilder: (context, index) {
          final cmd = D.termCommands[index];
          final key = cmd["key"];
          return _buildTermuxKey(cmd["name"]! as String, onTap: () {
            if (key is TerminalKey) {
              G.termPtys[G.currentContainer]!.terminal.keyInput(key);
            }
          });
        },
      ),
    );
  }

  Widget _buildTermuxKey(String label,
      {bool isActive = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 40, maxWidth: 80, minHeight: 32),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryPurple : AppColors.cardDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isActive ? AppColors.primaryPurple : AppColors.divider,
              width: 1),
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