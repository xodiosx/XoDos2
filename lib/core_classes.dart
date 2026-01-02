// core_classes.dart

// Keep ALL the original imports from the combined file
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:xterm/xterm.dart';
import 'package:flutter_pty/flutter_pty.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:xodos/l10n/app_localizations.dart';

import 'package:avnc_flutter/avnc_flutter.dart';
import 'package:x11_flutter/x11_flutter.dart';

// Import the mini games
import 'spirited_mini_games.dart';

// Import the split files
import 'constants.dart';
import 'default_values.dart';
// DXVK Installer Class

class Util {

  static Future<void> copyAsset(String src, String dst) async {
    await File(dst).writeAsBytes((await rootBundle.load(src)).buffer.asUint8List());
  }
  static Future<void> copyAsset2(String src, String dst) async {
    ByteData data = await rootBundle.load(src);
    await File(dst).writeAsBytes(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }
  static void createDirFromString(String dir) {
    Directory.fromRawPath(const Utf8Encoder().convert(dir)).createSync(recursive: true);
  }

  static Future<int> execute(String str) async {
    Pty pty = Pty.start(
      "/system/bin/sh"
    );
    pty.write(const Utf8Encoder().convert("$str\nexit \$?\n"));
    return await pty.exitCode;
  }

  static void termWrite(String str) {
    G.termPtys[G.currentContainer]!.pty.write(const Utf8Encoder().convert("$str\n"));
  }

  // All keys
  // int defaultContainer = 0: Default start the 0th container
  // int defaultAudioPort = 4718: Default pulseaudio port (changed to 4718 to avoid conflicts with other software, original default was 4713)
  // bool autoLaunchVnc = true: Whether to automatically start the graphical interface and jump (previously only supported VNC, hence the name)
  // String lastDate: Last startup date of the software, yyyy-MM-dd
  // bool isTerminalWriteEnabled = false
  // bool isTerminalCommandsEnabled = false 
  // int termMaxLines = 4095 Terminal maximum lines
  // double termFontScale = 1 Terminal font size
  // bool isStickyKey = true Whether terminal ctrl, shift, alt keys are sticky
  // String defaultFFmpegCommand Default streaming command
  // String defaultVirglCommand Default virgl parameters
  // String defaultVirglOpt Default virgl environment variables
  // bool reinstallBootstrap = false Whether to reinstall the bootstrap package on next startup
  // bool getifaddrsBridge = false Whether to bridge getifaddrs on next startup
  // bool uos = false Whether to disguise as UOS on next startup
  // bool virgl = false Whether to enable virgl on next startup
  // bool wakelock = false Keep screen on
  // bool isHidpiEnabled = false Whether to enable high DPI
  // bool isJpEnabled = false Whether to switch system to Japanese
  // bool useAvnc = false Whether to use AVNC by default
  // bool avncResizeDesktop = true Whether AVNC adjusts resolution based on current screen size by default
  // double avncScaleFactor = -0.5 AVNC: Adjust scaling factor based on current screen size. Range -1~1, corresponding to ratio 4^-1~4^1
  // String defaultHidpiOpt Default HiDPI environment variables
  // ? int bootstrapVersion: Bootstrap package version
  // String[] containersInfo: All container information (json)
  // {name, boot:"\$DATA_DIR/bin/proot ...", vnc:"startnovnc", vncUrl:"...", commands:[{name:"Update and upgrade", command:"apt update -y && apt upgrade -y"},
  // bind:[{name:"USB Drive", src:"/storage/xxxx", dst:"/media/meow"}]...]}
  // TODO: Is this way of writing still not right? Try changing to class when have time?
  static dynamic getGlobal(String key) {
    bool b = G.prefs.containsKey(key);
    switch (key) {
      case "defaultContainer" : return b ? G.prefs.getInt(key)! : (value){G.prefs.setInt(key, value); return value;}(0);
      case "defaultAudioPort" : return b ? G.prefs.getInt(key)! : (value){G.prefs.setInt(key, value); return value;}(4718);
      case "autoLaunchVnc" : return b ? G.prefs.getBool(key)! : (value){G.prefs.setBool(key, value); return value;}(true);
      case "lastDate" : return b ? G.prefs.getString(key)! : (value){G.prefs.setString(key, value); return value;}("1970-01-01");
      case "isTerminalWriteEnabled" : return b ? G.prefs.getBool(key)! : (value){G.prefs.setBool(key, value); return value;}(false);
      case "isTerminalCommandsEnabled" : return b ? G.prefs.getBool(key)! : (value){G.prefs.setBool(key, value); return value;}(false);
      case "termMaxLines" : return b ? G.prefs.getInt(key)! : (value){G.prefs.setInt(key, value); return value;}(4095);
      case "termFontScale" : return b ? G.prefs.getDouble(key)! : (value){G.prefs.setDouble(key, value); return value;}(1.0);
      case "isStickyKey" : return b ? G.prefs.getBool(key)! : (value){G.prefs.setBool(key, value); return value;}(true);
      case "reinstallBootstrap" : return b ? G.prefs.getBool(key)! : (value){G.prefs.setBool(key, value); return value;}(false);
      case "getifaddrsBridge" : return b ? G.prefs.getBool(key)! : (value){G.prefs.setBool(key, value); return value;}(false);
      case "uos" : return b ? G.prefs.getBool(key)! : (value){G.prefs.setBool(key, value); return value;}(false);
      case "virgl" : return b ? G.prefs.getBool(key)! : (value){G.prefs.setBool(key, value); return value;}(false);
      case "venus" : return b ? G.prefs.getBool(key)! : (value){G.prefs.setBool(key, value); return value;}(false);
      case "defaultVenusCommand" : return b ? G.prefs.getString(key)! : (value){G.prefs.setString(key, value); return value;}("--no-virgl --venus --socket-path=\$CONTAINER_DIR/tmp/.virgl_test");
      case "defaultVenusOpt" : return b ? G.prefs.getString(key)! : (value){G.prefs.setString(key, value); return value;}("GALLIUM_DRIVER=venus ANDROID_VENUS=1");
      case "androidVenus" : return b ? G.prefs.getBool(key)! : (value){G.prefs.setBool(key, value); return value;}(true);
      case "turnip" : return b ? G.prefs.getBool(key)! : (value){G.prefs.setBool(key, value); return value;}(false);
      case "dri3" : return b ? G.prefs.getBool(key)! : (value){G.prefs.setBool(key, value); return value;}(false);
      case "wakelock" : return b ? G.prefs.getBool(key)! : (value){G.prefs.setBool(key, value); return value;}(false);
      case "isHidpiEnabled" : return b ? G.prefs.getBool(key)! : (value){G.prefs.setBool(key, value); return value;}(false);
      case "isJpEnabled" : return b ? G.prefs.getBool(key)! : (value){G.prefs.setBool(key, value); return value;}(false);
      case "useAvnc" : return b ? G.prefs.getBool(key)! : (value){G.prefs.setBool(key, value); return value;}(true);
      case "avncResizeDesktop" : return b ? G.prefs.getBool(key)! : (value){G.prefs.setBool(key, value); return value;}(true);
      case "avncScaleFactor" : return b ? G.prefs.getDouble(key)!.clamp(-1.0, 1.0) : (value){G.prefs.setDouble(key, value); return value;}(-0.5);
      case "useX11" : return b ? G.prefs.getBool(key)! : (value){G.prefs.setBool(key, value); return value;}(false);
      case "defaultFFmpegCommand" : return b ? G.prefs.getString(key)! : (value){G.prefs.setString(key, value); return value;}("-hide_banner -an -max_delay 1000000 -r 30 -f android_camera -camera_index 0 -i 0:0 -vf scale=iw/2:-1 -rtsp_transport udp -f rtsp rtsp://127.0.0.1:8554/stream");
      case "defaultVirglCommand" : return b ? G.prefs.getString(key)! : (value){G.prefs.setString(key, value); return value;}("--use-egl-surfaceless --use-gles --socket-path=\$CONTAINER_DIR/tmp/.virgl_test");
      case "defaultVirglOpt" : return b ? G.prefs.getString(key)! : (value){G.prefs.setString(key, value); return value;}("GALLIUM_DRIVER=virpipe");
      case "defaultTurnipOpt" : return b ? G.prefs.getString(key)! : (value){G.prefs.setString(key, value); return value;}("MESA_LOADER_DRIVER_OVERRIDE=zink VK_ICD_FILENAMES=/home/tiny/.local/share/tiny/extra/freedreno_icd.aarch64.json TU_DEBUG=noconform");
      case "defaultHidpiOpt" : return b ? G.prefs.getString(key)! : (value){G.prefs.setString(key, value); return value;}("GDK_SCALE=2 QT_FONT_DPI=192");
      case "containersInfo" : return G.prefs.getStringList(key)!;
    }
  }

  static dynamic getCurrentProp(String key) {
    dynamic m = jsonDecode(Util.getGlobal("containersInfo")[G.currentContainer]);
    if (m.containsKey(key)) {
      return m[key];
    }
    switch (key) {
      case "name" : return (value){addCurrentProp(key, value); return value;}("XoDos Terminal");
      case "boot" : return (value){addCurrentProp(key, value); return value;}(D.boot);
      case "vnc" : return (value){addCurrentProp(key, value); return value;}("startnovnc &");
      case "vncUrl" : return (value){addCurrentProp(key, value); return value;}("http://localhost:36082/vnc.html?host=localhost&port=36082&autoconnect=true&resize=remote&password=12345678");
      case "vncUri" : return (value){addCurrentProp(key, value); return value;}("vnc://127.0.0.1:5904?VncPassword=12345678&SecurityType=2");
      case "commands" : return (value){addCurrentProp(key, value); return value;}(jsonDecode(jsonEncode(D.commands)));
      case "groupedCommands" : return (value){addCurrentProp(key, value); return value;}(jsonDecode(jsonEncode(LanguageManager.getGroupedCommandsForLanguage(Localizations.localeOf(G.homePageStateContext).languageCode))));
      case "groupedWineCommands" : return (value){addCurrentProp(key, value); return value;}(jsonDecode(jsonEncode(LanguageManager.getGroupedWineCommandsForLanguage(Localizations.localeOf(G.homePageStateContext).languageCode))));
    }
  }

  // Used to set name, boot, vnc, vncUrl, etc.
  static Future<void> setCurrentProp(String key, dynamic value) async {
    await G.prefs.setStringList("containersInfo",
      Util.getGlobal("containersInfo")..setAll(G.currentContainer,
        [jsonEncode((jsonDecode(
          Util.getGlobal("containersInfo")[G.currentContainer]
        ))..update(key, (v) => value))]
      )
    );
  }

  // Used to add non-existent keys, etc.
  static Future<void> addCurrentProp(String key, dynamic value) async {
    await G.prefs.setStringList("containersInfo",
      Util.getGlobal("containersInfo")..setAll(G.currentContainer,
        [jsonEncode((jsonDecode(
          Util.getGlobal("containersInfo")[G.currentContainer]
        ))..addAll({key : value}))]
      )
    );
  }

  // Limit string between min and max, for text box validator
  static String? validateBetween(String? value, int min, int max, Function opr) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(G.homePageStateContext)!.enterNumber;
    }
    int? parsedValue = int.tryParse(value);
    if (parsedValue == null) {
      return AppLocalizations.of(G.homePageStateContext)!.enterValidNumber;
    }
    if (parsedValue < min || parsedValue > max) {
      return "Please enter a number between $min and $max";
    }
    opr();
    return null;
  }

  static Future<bool> isXServerReady(String host, int port, {int timeoutSeconds = 5}) async {
    try {
      final socket = await Socket.connect(host, port, timeout: Duration(seconds: timeoutSeconds));
      await socket.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> waitForXServer() async {
    const host = '127.0.0.1';
    const port = 7897;
    
    while (true) {
      bool isReady = await isXServerReady(host, port);
      await Future.delayed(Duration(seconds: 1));
      if (isReady) {
        return;
      }
    }
  }

  static String getl10nText(String key, BuildContext context) {
    switch (key) {
      case 'projectUrl':
        return AppLocalizations.of(context)!.projectUrl;
      case 'issueUrl':
        return AppLocalizations.of(context)!.issueUrl;
      case 'faqUrl':
        return AppLocalizations.of(context)!.faqUrl;
      case 'solutionUrl':
        return AppLocalizations.of(context)!.solutionUrl;
      case 'discussionUrl':
        return AppLocalizations.of(context)!.discussionUrl;
      default:
        return AppLocalizations.of(context)!.projectUrl;
    }
  }

  // Helper methods for grouped commands
  static Map<String, dynamic> getGroupedCommands() {
    return getCurrentProp("groupedCommands");
  }

  static Map<String, dynamic> getGroupedWineCommands() {
    return getCurrentProp("groupedWineCommands");
  }

}

// From xterms example about handling ctrl, shift, alt keys
// This class should only have one instance G.keyboard
class VirtualKeyboard extends TerminalInputHandler with ChangeNotifier {
  final TerminalInputHandler _inputHandler;

  VirtualKeyboard(this._inputHandler);

  bool _ctrl = false;

  bool get ctrl => _ctrl;

  set ctrl(bool value) {
    if (_ctrl != value) {
      _ctrl = value;
      notifyListeners();
    }
  }

  bool _shift = false;

  bool get shift => _shift;

  set shift(bool value) {
    if (_shift != value) {
      _shift = value;
      notifyListeners();
    }
  }

  bool _alt = false;

  bool get alt => _alt;

  set alt(bool value) {
    if (_alt != value) {
      _alt = value;
      notifyListeners();
    }
  }

  @override
  String? call(TerminalKeyboardEvent event) {
    final ret = _inputHandler.call(event.copyWith(
      ctrl: event.ctrl || _ctrl,
      shift: event.shift || _shift,
      alt: event.alt || _alt,
    ));
    G.maybeCtrlJ = event.key.name == "keyJ"; // This is to distinguish whether the key pressed is Enter or Ctrl+J later
    if (!(Util.getGlobal("isStickyKey") as bool)) {
      G.keyboard.ctrl = false;
      G.keyboard.shift = false;
      G.keyboard.alt = false;
    }
    return ret;
  }
}

// A class combining terminal and pty
class TermPty{
  late final Terminal terminal;
  late final Pty pty;
  late final TerminalController controller;

  TermPty() {
    controller = TerminalController();
    terminal = Terminal(
      inputHandler: G.keyboard, 
      maxLines: Util.getGlobal("termMaxLines") as int,
    );
    pty = Pty.start(
      "/system/bin/sh",
      workingDirectory: G.dataPath,
      columns: terminal.viewWidth,
      rows: terminal.viewHeight,
    );
    pty.output
      .cast<List<int>>()
      .transform(const Utf8Decoder())
      .listen(terminal.write);
    pty.exitCode.then((code) {
      terminal.write('the process exited with exit code $code');
      if (code == 0) {
        SystemChannels.platform.invokeMethod("SystemNavigator.pop");
      }
      //Signal 9 hint
      if (code == -9) {
        D.androidChannel.invokeMethod("launchSignal9Page", {});
      }
    });
    terminal.onOutput = (data) {
      if (!(Util.getGlobal("isTerminalWriteEnabled") as bool)) {
        return;
      }
      // Due to apparent issues with handling carriage returns, handle them separately
      data.split("").forEach((element) {
        if (element == "\n" && !G.maybeCtrlJ) {
          terminal.keyInput(TerminalKey.enter);
          return;
        }
        G.maybeCtrlJ = false;
        pty.write(const Utf8Encoder().convert(element));
      });
    };
    terminal.onResize = (w, h, pw, ph) {
      pty.resize(h, w);
    };
  }
}

// Global variables
class G {

static VoidCallback? onExtractionComplete;
  
  static void handleHardwareKeyRepeat(RawKeyEvent event) {
  if (event is RawKeyDownEvent && event.repeat) {
    final term = G.termPtys[G.currentContainer]?.terminal;
    if (term == null) return;

    final String? char = event.character;
    if (char != null && char.isNotEmpty) {
  final key = TerminalKey.ofChar(char);
  term.keyInput(
    key,
    ctrl: G.keyboard.ctrl,
    alt: G.keyboard.alt,
    shift: G.keyboard.shift,
  );
}
    
    
  }
}
  
  
  
  
  
  static late final String dataPath;
  static Pty? audioPty;
  static late WebViewController controller;
  static late BuildContext homePageStateContext;
  static late int currentContainer; // Currently running which container
  static late Map<int, TermPty> termPtys; // Store TermPty data for container<int>
  static late VirtualKeyboard keyboard; // Store ctrl, shift, alt state
  static bool maybeCtrlJ = false; // Variable prepared to distinguish between pressed ctrl+J and enter
  static ValueNotifier<double> termFontScale = ValueNotifier(1); // Terminal font size, stored as G.prefs' termFontScale
  static bool isStreamServerStarted = false;
  static bool isStreaming = false;
  //static int? streamingPid;
  static String streamingOutput = "";
  static late Pty streamServerPty;
  //static int? virglPid;
  static ValueNotifier<int> pageIndex = ValueNotifier(0); // Main interface index
  static ValueNotifier<bool> terminalPageChange = ValueNotifier(true); // Change value, used to refresh numpad
  static ValueNotifier<bool> bootTextChange = ValueNotifier(true); // Change value, used to refresh boot command
  static ValueNotifier<String> updateText = ValueNotifier("xodos"); // Description text on loading screen
  static String postCommand = ""; // Additional command to run when first entering the container
  
  static bool wasAvncEnabled = false;
  static bool wasX11Enabled = false;

  static late SharedPreferences prefs;
}

class Workflow {

static Future<bool> showBootSelectionDialog(BuildContext context) async {
  int? dialogResult = await showDialog<int>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Select Desktop Environment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(1); // Native desktop
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Native Desktop'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(2); // Proot desktop
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Proot Desktop'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(3); // Kali Linux desktop
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Kali Linux Desktop'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(4); // Wine bionic desktop
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Wine Bionic Desktop'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(5); // Wine glibc desktop
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Wine Glibc Desktop'),
              ),
            ],
          ),
        ),
      );
    },
  );
  
  // Handle null result (dialog dismissed)
  int result = dialogResult ?? 2; // Default to Proot desktop if dialog dismissed
  
  // Execute the selected command
  switch (result) {
    case 1: // Native desktop
      Util.termWrite("\$DATA_DIR/usr/bin/xodos");
      break;
    case 2: // Proot desktop - continue with normal workflow
      // Don't write anything - will continue with normal boot
      break;
    case 3: // Kali Linux desktop
      Util.termWrite("\$DATA_DIR/usr/bin/Kalix");
      break;
    case 4: // Wine bionic desktop
      Util.termWrite("\$DATA_DIR/usr/bin/xodxx2");
      break;
    case 5: // Wine glibc desktop
      Util.termWrite("\$DATA_DIR/usr/bin/xodxx");
      break;
  }
  
  // Return true if Proot desktop was selected (to continue normal workflow)
  // Return false for other options (which run their own commands)
  return result == 2;
}


  static Future<void> grantPermissions() async {
    Permission.storage.request();
    //Permission.manageExternalStorage.request();
  }

  static Future<void> setupBootstrap() async {
    // Folder for sharing data files
    Util.createDirFromString("${G.dataPath}/share");
    // Folder for storing executable files
    Util.createDirFromString("${G.dataPath}/bin");
    // Folder for storing libraries
    Util.createDirFromString("${G.dataPath}/lib");
    // Folder to be mounted to /dev/shm
    Util.createDirFromString("${G.dataPath}/tmp");
    // tmp folder for proot, though I don't know why proot needs this
    Util.createDirFromString("${G.dataPath}/proot_tmp");
    // tmp folder for pulseaudio
    Util.createDirFromString("${G.dataPath}/pulseaudio_tmp");
    // After extraction, get bin folder and libexec folder
    // bin contains proot, pulseaudio, tar, etc.
    // libexec contains proot loader
    await Util.copyAsset(
    "assets/assets.zip",
    "${G.dataPath}/assets.zip",
    );
    // patch.tar.gz contains the xodos folder
    // These are some patches that will be mounted to ~/.local/share/tiny
    await Util.copyAsset(
    "assets/patch.tar.gz",
    "${G.dataPath}/patch.tar.gz",
    );
    await Util.execute(
"""
export DATA_DIR=${G.dataPath}
export LD_LIBRARY_PATH=\$DATA_DIR/lib:\$DATA_DIR/usr/lib:\$DATA_DIR/usr/libexec/:\$LD_LIBRARY_PATH:/system/lib64
export PATH=\$DATA_DIR/bin:\$PATH:\$DATA_DIR/usr/libexec:\$DATA_DIR/usr/bin:/system/bin:\$DATA_DIR/usr/libexec/binutils
export PREFIX=\$DATA_DIR/usr
export HOME=\$DATA_DIR/home
export TMPDIR=\$DATA_DIR/usr/tmp
export PATH=\$DATA_DIR/usr/bin:\$PATH:/system/bin
export LD_LIBRARY_PATH=\$DATA_DIR/usr/lib:/system/lib64
export FONTCONFIG_PATH=\$PREFIX/etc/fonts       
export FONTCONFIG_FILE=\$PREFIX/etc/fonts/fonts.conf 
mkdir -p \$TMPDIR
mkdir -p \$HOME
export DISPLAY=:4
export XDG_RUNTIME_DIR=\$DATA_DIR/usr/tmp/
export X11_UNIX_PATH=\$DATA_DIR/usr/tmp/.X11-unix
export VK_ICD_FILENAMES=\$DATA_DIR/usr/share/vulkan/icd.d/wrapper_icd.aarch64.json
export TMPDIR=\$DATA_DIR/usr/tmp
export XDG_RUNTIME_DIR=\$TMPDIR/runtime
cd 
export XDG_RUNTIME_DIR=\$TMPDIR/runtime
export XDG_CACHE_HOME=\$PREFIX/tmp/.cache
mkdir -p \$XDG_CACHE_HOME

cd \$DATA_DIR
ln -sf ../applib/libexec_busybox.so \$DATA_DIR/bin/busybox
ln -sf ../applib/libexec_busybox.so \$DATA_DIR/bin/sh
ln -sf ../applib/libexec_busybox.so \$DATA_DIR/bin/cat
ln -sf ../applib/libexec_busybox.so \$DATA_DIR/bin/xz
ln -sf ../applib/libexec_busybox.so \$DATA_DIR/bin/gzip
ln -sf ../applib/libexec_proot.so \$DATA_DIR/bin/proot
ln -sf ../applib/libexec_tar.so \$DATA_DIR/bin/tar
ln -sf ../applib/libexec_virgl_test_server.so \$DATA_DIR/bin/virgl_test_server
ln -sf ../applib/libexec_getifaddrs_bridge_server.so \$DATA_DIR/bin/getifaddrs_bridge_server
ln -sf ../applib/libexec_pulseaudio.so \$DATA_DIR/bin/pulseaudio
ln -sf ../applib/libbusybox.so \$DATA_DIR/lib/libbusybox.so.1.37.0
ln -sf ../applib/libtalloc.so \$DATA_DIR/lib/libtalloc.so.2
ln -sf ../applib/libvirglrenderer.so \$DATA_DIR/lib/libvirglrenderer.so
ln -sf ../applib/libepoxy.so \$DATA_DIR/lib/libepoxy.so
ln -sf ../applib/libproot-loader32.so \$DATA_DIR/lib/loader32
ln -sf ../applib/libproot-loader.so \$DATA_DIR/lib/loader

\$DATA_DIR/bin/busybox unzip -o assets.zip
chmod -R +x bin/*
chmod -R +x usr/bin/*
chmod -R +x libexec/proot/*
chmod -R +x usr/libexec/*
chmod 1777 tmp
\$DATA_DIR/bin/tar zxf patch.tar.gz
\$DATA_DIR/bin/busybox rm -rf assets.zip patch.tar.gz
""");
  }

  // Things to do on first startup
  static Future<void> initForFirstTime() async {
    // First set up bootstrap
    G.updateText.value = AppLocalizations.of(G.homePageStateContext)!.installingBootPackage;
    await setupBootstrap();
    
    G.updateText.value = AppLocalizations.of(G.homePageStateContext)!.copyingContainerSystem;
    // Folder 0 for storing containers and folder .l2s for storing hard links
    Util.createDirFromString("${G.dataPath}/containers/0/.l2s");
    // This is the container rootfs, split into xa* by split command, placed in assets
    // On first startup, use this, don't let the user choose another one

    // Load custom manifest for container files
    final manifestString = await rootBundle.loadString('assets/container_manifest.json');
    final Map<String, dynamic> manifest = json.decode(manifestString);

    // Get the list of xa files
    final List<String> xaFiles = List<String>.from(manifest['xaFiles']);

    for (String assetPath in xaFiles) {
      final fileName = assetPath.split('/').last;
      await Util.copyAsset(assetPath, "${G.dataPath}/$fileName");
    }

    G.updateText.value = AppLocalizations.of(G.homePageStateContext)!.installingContainerSystem;
    await Util.execute(
"""
export DATA_DIR=${G.dataPath}
export PATH=\$DATA_DIR/bin:\$PATH
export LD_LIBRARY_PATH=\$DATA_DIR/lib
export CONTAINER_DIR=\$DATA_DIR/containers/0
export EXTRA_OPT=""
cd \$DATA_DIR
export PATH=\$DATA_DIR/bin:\$PATH
export PROOT_TMP_DIR=\$DATA_DIR/proot_tmp
export PROOT_LOADER=\$DATA_DIR/applib/libproot-loader.so
export PROOT_LOADER_32=\$DATA_DIR/applib/libproot-loader32.so
#export PROOT_L2S_DIR=\$CONTAINER_DIR/.l2s
\$DATA_DIR/bin/proot --link2symlink sh -c "cat xa* | \$DATA_DIR/bin/tar x -J --delay-directory-restore --preserve-permissions -v -C containers/0"
#Script from proot-distro
chmod u+rw "\$CONTAINER_DIR/etc/passwd" "\$CONTAINER_DIR/etc/shadow" "\$CONTAINER_DIR/etc/group" "\$CONTAINER_DIR/etc/gshadow"
echo "aid_\$(id -un):x:\$(id -u):\$(id -g):Termux:/:/sbin/nologin" >> "\$CONTAINER_DIR/etc/passwd"
echo "aid_\$(id -un):*:18446:0:99999:7:::" >> "\$CONTAINER_DIR/etc/shadow"
id -Gn | tr ' ' '\\n' > tmp1
id -G | tr ' ' '\\n' > tmp2
\$DATA_DIR/bin/busybox paste tmp1 tmp2 > tmp3
local group_name group_id
cat tmp3 | while read -r group_name group_id; do
	echo "aid_\${group_name}:x:\${group_id}:root,aid_\$(id -un)" >> "\$CONTAINER_DIR/etc/group"
	if [ -f "\$CONTAINER_DIR/etc/gshadow" ]; then
		echo "aid_\${group_name}:*::root,aid_\$(id -un)" >> "\$CONTAINER_DIR/etc/gshadow"
	fi
done

\$DATA_DIR/bin/busybox rm -rf xa* tmp1 tmp2 tmp3
ln -sf \$DATA_DIR/containers/0/tmp \$DATA_DIR/usr/tmp
export LD_LIBRARY_PATH=\$DATA_DIR/lib:\$DATA_DIR/usr/lib:\$DATA_DIR/usr/libexec/:\$LD_LIBRARY_PATH
export PATH=\$DATA_DIR/bin:\$PATH:\$DATA_DIR/usr/libexec:\$DATA_DIR/usr/bin
export PREFIX=\$DATA_DIR/usr
export HOME=\$DATA_DIR/home
export TMPDIR=\$DATA_DIR/usr/tmp
export FONTCONFIG_PATH=\$PREFIX/etc/fonts        
export FONTCONFIG_FILE=\$PREFIX/etc/fonts/fonts.conf 
mkdir -p \$TMPDIR
mkdir -p \$HOME
export DISPLAY=:4
export XDG_RUNTIME_DIR=\$DATA_DIR/usr/tmp/
export X11_UNIX_PATH=\$DATA_DIR/usr/tmp/.X11-unix
export VK_ICD_FILENAMES=\$DATA_DIR/usr/share/vulkan/icd.d/wrapper_icd.aarch64.json
export TMPDIR=\$DATA_DIR/usr/tmp
export XDG_RUNTIME_DIR=\$TMPDIR/runtime
cd 
export XDG_RUNTIME_DIR=\$TMPDIR/runtime
export XDG_CACHE_HOME=\$PREFIX/tmp/.cache
mkdir -p \$XDG_CACHE_HOME

""");
    // Some data initialization
    // $DATA_DIR is the data folder, $CONTAINER_DIR is the container root directory
    // Termux:X11's startup command is not here, it's hardcoded. Now it's a pile of stuff code :P
    
    // Use LanguageManager for proper language support
    final languageCode = Localizations.localeOf(G.homePageStateContext).languageCode;
    final groupedCommands = LanguageManager.getGroupedCommandsForLanguage(languageCode);
    final groupedWineCommands = LanguageManager.getGroupedWineCommandsForLanguage(languageCode);
    
    await G.prefs.setStringList("containersInfo", ["""{
"name":"XoDos Terminal",
"boot":"${LanguageManager.getBootCommandForLanguage(languageCode)}",
"vnc":"startnovnc &",
"vncUrl":"http://localhost:36082/vnc.html?host=localhost&port=36082&autoconnect=true&resize=remote&password=12345678",
"commands":${jsonEncode(LanguageManager.getCommandsForLanguage(languageCode))},
"groupedCommands":${jsonEncode(groupedCommands)},
"groupedWineCommands":${jsonEncode(groupedWineCommands)}
}"""]);
    
    G.updateText.value = AppLocalizations.of(G.homePageStateContext)!.installationComplete;
    
       if (G.onExtractionComplete != null) {
      G.onExtractionComplete!();
    }
    
     
  }

  static Future<void> initData() async {

    G.dataPath = (await getApplicationSupportDirectory()).path;

    G.termPtys = {};

    G.keyboard = VirtualKeyboard(defaultInputHandler);
    
    RawKeyboard.instance.addListener(G.handleHardwareKeyRepeat);
    
    G.prefs = await SharedPreferences.getInstance();

    await Util.execute("ln -sf ${await D.androidChannel.invokeMethod("getNativeLibraryPath", {})} ${G.dataPath}/applib");

    // If this key doesn't exist, it means it's the first startup
    if (!G.prefs.containsKey("defaultContainer")) {
      await initForFirstTime();
      // Adjust resolution based on user's screen
      final s = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;
      final String w = (max(s.width, s.height) * 0.75).round().toString();
      final String h = (min(s.width, s.height) * 0.75).round().toString();
      G.postCommand = """sed -i -E "s@(geometry)=.*@\\\\1=${w}x${h}@" /etc/tigervnc/vncserver-config-tmoe
sed -i -E "s@^(VNC_RESOLUTION)=.*@\\\\1=${w}x${h}@" \$(command -v startvnc)

""";
      
      final languageCode = Localizations.localeOf(G.homePageStateContext).languageCode;
      if (languageCode != 'zh') {
        G.postCommand += "\nlocaledef -c -i en_US -f UTF-8 en_US.UTF-8";
        // For non-Chinese users, assume they need to enable terminal write
        await G.prefs.setBool("isTerminalWriteEnabled", true);
        await G.prefs.setBool("isTerminalCommandsEnabled", true);
        await G.prefs.setBool("isStickyKey", false);
        await G.prefs.setBool("wakelock", true);
      }
      await G.prefs.setBool("getifaddrsBridge", (await DeviceInfoPlugin().androidInfo).version.sdkInt >= 31);
    }
    G.currentContainer = Util.getGlobal("defaultContainer") as int;

    // Need to reinstall bootstrap package?
    if (Util.getGlobal("reinstallBootstrap")) {
      G.updateText.value = AppLocalizations.of(G.homePageStateContext)!.reinstallingBootPackage;
      await setupBootstrap();
      G.prefs.setBool("reinstallBootstrap", false);
    }

    // What graphical interface is enabled?
    if (Util.getGlobal("useX11")) {
      G.wasX11Enabled = true;
      Workflow.launchXServer();
    } else if (Util.getGlobal("useAvnc")) {
      G.wasAvncEnabled = true;
    }

    G.termFontScale.value = Util.getGlobal("termFontScale") as double;

    G.controller = WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted);

    // Set screen always on
    WakelockPlus.toggle(enable: Util.getGlobal("wakelock"));
  }

  static Future<void> initTerminalForCurrent() async {
  if (!G.termPtys.containsKey(G.currentContainer)) {
    G.termPtys[G.currentContainer] = TermPty();
    
    // Write environment variables at the very beginning
    String envCommands = """
export DATA_DIR=${G.dataPath}
export LD_LIBRARY_PATH=\$DATA_DIR/lib:\$DATA_DIR/usr/lib:\$DATA_DIR/usr/libexec/:\$LD_LIBRARY_PATH
export PATH=\$DATA_DIR/bin:\$PATH:\$DATA_DIR/usr/libexec:\$DATA_DIR/usr/bin
export PREFIX=\$DATA_DIR/usr
export HOME=\$DATA_DIR/home
export TMPDIR=\$DATA_DIR/usr/tmp
export FONTCONFIG_PATH=\$PREFIX/etc/fonts       
export FONTCONFIG_FILE=\$PREFIX/etc/fonts/fonts.conf 
mkdir -p \$TMPDIR
mkdir -p \$HOME
export DISPLAY=:4
export XDG_RUNTIME_DIR=\$DATA_DIR/usr/tmp/
export X11_UNIX_PATH=\$DATA_DIR/usr/tmp/.X11-unix

export TMPDIR=\$DATA_DIR/usr/tmp
export XDG_RUNTIME_DIR=\$TMPDIR/runtime
cd 
export XDG_RUNTIME_DIR=\$TMPDIR/runtime
export XDG_CACHE_HOME=\$PREFIX/tmp/.cache
mkdir -p \$XDG_CACHE_HOME
""";
    
    // Write the commands to the terminal
    G.termPtys[G.currentContainer]!.pty.write(const Utf8Encoder().convert(envCommands));
  }
}


  static Future<void> setupAudio() async {
    G.audioPty?.kill();
    G.audioPty = Pty.start(
      "/system/bin/sh"
    );
    G.audioPty!.write(const Utf8Encoder().convert("""
export DATA_DIR=${G.dataPath}
export PATH=\$DATA_DIR/bin:\$PATH
export LD_LIBRARY_PATH=\$DATA_DIR/lib
export LD_LIBRARY_PATH=\$DATA_DIR/lib:\$DATA_DIR/usr/lib:\$DATA_DIR/usr/libexec/:\$LD_LIBRARY_PATH
export PATH=\$DATA_DIR/bin:\$PATH:\$DATA_DIR/usr/libexec:\$DATA_DIR/usr/bin
export PREFIX=\$DATA_DIR/usr
export HOME=\$DATA_DIR/home
export TMPDIR=\$DATA_DIR/usr/tmp


\$DATA_DIR/bin/busybox sed "s/4713/${Util.getGlobal("defaultAudioPort") as int}/g" \$DATA_DIR/bin/pulseaudio.conf > \$DATA_DIR/bin/pulseaudio.conf.tmp
rm -rf \$DATA_DIR/pulseaudio_tmp/*
TMPDIR=\$DATA_DIR/pulseaudio_tmp HOME=\$DATA_DIR/pulseaudio_tmp XDG_CONFIG_HOME=\$DATA_DIR/pulseaudio_tmp LD_LIBRARY_PATH=\$DATA_DIR/bin:\$LD_LIBRARY_PATH \$DATA_DIR/bin/pulseaudio -F \$DATA_DIR/bin/pulseaudio.conf.tmp
exit
"""));
  await G.audioPty?.exitCode;
  }

  static Future<void> launchCurrentContainer() async {
    String extraMount = ""; //mount options and other proot options
    String extraOpt = "";
    
    if (Util.getGlobal("getifaddrsBridge")) {
      Util.execute("${G.dataPath}/bin/getifaddrs_bridge_server ${G.dataPath}/containers/${G.currentContainer}/tmp/.getifaddrs-bridge");
      extraOpt += "LD_PRELOAD=/home/tiny/.local/share/tiny/extra/getifaddrs_bridge_client_lib.so ";
    }
    if (Util.getGlobal("isHidpiEnabled")) {
      extraOpt += "${Util.getGlobal("defaultHidpiOpt")} ";
    }
    if (Util.getGlobal("uos")) {
      extraMount += "--mount=\$DATA_DIR/tiny/wechat/uos-lsb:/etc/lsb-release --mount=\$DATA_DIR/tiny/wechat/uos-release:/usr/lib/os-release ";
      extraMount += "--mount=\$DATA_DIR/tiny/wechat/license/var/uos:/var/uos --mount=\$DATA_DIR/tiny/wechat/license/var/lib/uos-license:/var/lib/uos-license ";
    }
    
 /*   GPU   */
    // Hardware acceleration section - now includes Venus
bool virglEnabled = Util.getGlobal("virgl") as bool;
bool venusEnabled = Util.getGlobal("venus") as bool;
bool turnipEnabled = Util.getGlobal("turnip") as bool;

// Update the hardware acceleration section in Workflow.launchCurrentContainer():
if (Util.getGlobal("virgl")) {
  Util.execute("""
export DATA_DIR=${G.dataPath}
export PATH=\$DATA_DIR/bin:\$PATH
export LD_LIBRARY_PATH=\$DATA_DIR/lib
export LD_LIBRARY_PATH=\$DATA_DIR/lib:\$DATA_DIR/usr/lib:\$DATA_DIR/usr/libexec/:\$LD_LIBRARY_PATH:/system/lib64
export PATH=\$DATA_DIR/bin:\$PATH:\$DATA_DIR/usr/libexec:\$DATA_DIR/usr/bin:/system/bin:\$DATA_DIR/usr/libexec/binutils
export CONTAINER_DIR=\$DATA_DIR/containers/${G.currentContainer}
${G.dataPath}/bin/virgl_test_server ${Util.getGlobal("defaultVirglCommand")} &
""");
  extraOpt += "${Util.getGlobal("defaultVirglOpt")} ";
} else if (Util.getGlobal("venus")) {
  // Venus hardware acceleration
  String venusCommand = Util.getGlobal("defaultVenusCommand") as String;
  String venusOpt = Util.getGlobal("defaultVenusOpt") as String;
  
  // Build the LD_PRELOAD path
  String ldPreload = "/system/lib64/libvulkan.so";
  
  // Check if ANDROID_VENUS should be added
  bool androidVenusEnabled = Util.getGlobal("androidVenus") as bool;
  String androidVenusEnv = androidVenusEnabled ? "ANDROID_VENUS=1 " : "";
  
  // Build the full command
  String fullCommand = "${androidVenusEnv} LD_PRELOAD=$ldPreload ${G.dataPath}/bin/virgl_test_server $venusCommand &";
  
  Util.execute("""
export DATA_DIR=${G.dataPath}
export PATH=\$DATA_DIR/bin:\$PATH
export LD_LIBRARY_PATH=\$DATA_DIR/lib
export CONTAINER_DIR=\$DATA_DIR/containers/${G.currentContainer}
$fullCommand
""");
  
  extraOpt += "$venusOpt ";
}

if (Util.getGlobal("turnip")) {
  extraOpt += "${Util.getGlobal("defaultTurnipOpt")} ";
  if (!(Util.getGlobal("dri3"))) {
    extraOpt += "MESA_VK_WSI_DEBUG=sw ";
  }
}
    if (Util.getGlobal("isJpEnabled")) {
      extraOpt += "LANG=ja_JP.UTF-8 ";
    }
    extraMount += "--mount=\$DATA_DIR/tiny/font:/usr/share/fonts/tiny ";
    extraMount += "--mount=\$DATA_DIR/tiny/extra/cmatrix:/home/tiny/.local/bin/cmatrix ";
  
    
        Util.termWrite(
"""
export DATA_DIR=${G.dataPath}
export PATH=\$DATA_DIR/bin:\$PATH
export LD_LIBRARY_PATH=\$DATA_DIR/lib
export CONTAINER_DIR=\$DATA_DIR/containers/${G.currentContainer}
export EXTRA_MOUNT="$extraMount"
export EXTRA_OPT="$extraOpt"
#export PROOT_L2S_DIR=\$DATA_DIR/containers/0/.l2s
cd \$DATA_DIR
export PROOT_TMP_DIR=\$DATA_DIR/proot_tmp
export PROOT_LOADER=\$DATA_DIR/applib/libproot-loader.so
export PROOT_LOADER_32=\$DATA_DIR/applib/libproot-loader32.so
${Util.getCurrentProp("boot")}

${G.postCommand} > /dev/null 2>&1

""");
// Remove the "clear" command at the end
  }

static Future<void> launchGUIBackend() async {
  if (Util.getGlobal("autoLaunchVnc") as bool) {
    if (Util.getGlobal("useX11") as bool) {
      // X11 already redirects to log file, keep as is
      Util.termWrite("""mkdir -p "\$HOME/.vnc" && bash /etc/X11/xinit/Xsession &> "\$HOME/.vnc/x.log" &""");
    } else {
      // Redirect VNC command output to /dev/null
      String vncCmd = Util.getCurrentProp("vnc");
      // Remove any existing & and add redirection
      vncCmd = vncCmd.replaceAll(RegExp(r'\s*&\s*$'), '');
      Util.termWrite("$vncCmd > /dev/null 2>&1 &");
    }
  }
  // Remove the clear command entirely
  // Util.termWrite("clear"); // DELETE THIS LINE
}

  static Future<void> waitForConnection() async {
    await retry(
      // Make a GET request
      () => http.get(Uri.parse(Util.getCurrentProp("vncUrl"))).timeout(const Duration(milliseconds: 250)),
      // Retry on SocketException or TimeoutException
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
  }

  static Future<void> launchBrowser() async {
    G.controller.loadRequest(Uri.parse(Util.getCurrentProp("vncUrl")));
    Navigator.push(G.homePageStateContext, MaterialPageRoute(builder: (context) {
      return Focus(
        onKeyEvent: (node, event) {
          // Allow webview to handle cursor keys. Without this, the
          // arrow keys seem to get "eaten" by Flutter and therefore
          // never reach the webview.
          // (https://github.com/flutter/flutter/issues/102505).
          if (!kIsWeb) {
            if ({
              LogicalKeyboardKey.arrowLeft,
              LogicalKeyboardKey.arrowRight,
              LogicalKeyboardKey.arrowUp,
              LogicalKeyboardKey.arrowDown,
              LogicalKeyboardKey.tab
            }.contains(event.logicalKey)) {
              return KeyEventResult.skipRemainingHandlers;
            }
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(onSecondaryTap: () {
        }, child: WebViewWidget(controller: G.controller))
      );
    }));
  }

  static Future<void> launchAvnc() async {
    await AvncFlutter.launchUsingUri(Util.getCurrentProp("vncUri") as String, resizeRemoteDesktop: Util.getGlobal("avncResizeDesktop") as bool, resizeRemoteDesktopScaleFactor: pow(4, Util.getGlobal("avncScaleFactor") as double).toDouble());
  }

  static Future<void> launchXServer() async {
    await X11Flutter.launchXServer("${G.dataPath}/containers/${G.currentContainer}/tmp", "${G.dataPath}/containers/${G.currentContainer}/usr/share/X11/xkb", [":4"]);
  }

  static Future<void> launchX11() async {
    await X11Flutter.launchX11Page();
  }

  // Modify the workflow() method to show the dialog before starting
static Future<void> workflow() async {
  grantPermissions();
  await initData();
  await initTerminalForCurrent();
  
  // Show boot selection dialog
  final bool shouldContinueWithProot = await showBootSelectionDialog(G.homePageStateContext);
  // Write environment variables to terminal
  String envCommands = """
export DATA_DIR=${G.dataPath}
export LD_LIBRARY_PATH=\$DATA_DIR/lib:\$DATA_DIR/usr/lib:\$DATA_DIR/usr/libexec/:\$LD_LIBRARY_PATH
export PATH=\$DATA_DIR/bin:\$PATH:\$DATA_DIR/usr/libexec:\$DATA_DIR/usr/bin:\$DATA_DIR/usr/libexec/binutils
export PREFIX=\$DATA_DIR/usr
export HOME=\$DATA_DIR/home
export TMPDIR=\$DATA_DIR/usr/tmp
export PATH=\$DATA_DIR/usr/bin:\$PATH:/system/bin
export LD_LIBRARY_PATH=\$DATA_DIR/usr/lib:/system/lib64
export FONTCONFIG_PATH=\$PREFIX/etc/fonts       
export FONTCONFIG_FILE=\$PREFIX/etc/fonts/fonts.conf 
mkdir -p \$TMPDIR
mkdir -p \$HOME
export DISPLAY=:4
export XDG_RUNTIME_DIR=\$DATA_DIR/usr/tmp/
export X11_UNIX_PATH=\$DATA_DIR/usr/tmp/.X11-unix
export VK_ICD_FILENAMES=\$DATA_DIR/usr/share/vulkan/icd.d/wrapper_icd.aarch64.json
export TMPDIR=\$DATA_DIR/usr/tmp
export XDG_RUNTIME_DIR=\$TMPDIR/runtime
cd 
export XDG_RUNTIME_DIR=\$TMPDIR/runtime
export XDG_CACHE_HOME=\$PREFIX/tmp/.cache
mkdir -p \$XDG_CACHE_HOME
""";
  
  // Write environment commands to terminal
  G.termPtys[G.currentContainer]!.pty.write(const Utf8Encoder().convert(envCommands));

  // If user selected Proot desktop (option 2), continue with normal workflow
  if (shouldContinueWithProot) {
    setupAudio();
    launchCurrentContainer();
    if (Util.getGlobal("autoLaunchVnc") as bool) {
      if (G.wasX11Enabled) {
        await Util.waitForXServer();
        launchGUIBackend();
        launchX11();
        return;
      }
      launchGUIBackend();
      waitForConnection().then((value) => G.wasAvncEnabled ? launchAvnc() : launchBrowser());
    }
  } else {
    // For other options, they've already run their commands via termWrite
    // We don't need to continue with the normal container setup
    // You might want to add additional setup here if needed
  }
}

  
  
}