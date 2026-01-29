// core_classes.dart

// Keep ALL the original imports from the combined file
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:package_info_plus/package_info_plus.dart';
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
import 'debug.dart';
import 'constants.dart';
import 'default_values.dart';
// DXVK Installer Class

/////////

class AndroidAppState {
  static bool isForeground = true;
  static const MethodChannel _channel = MethodChannel('android');

  static void init() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'appBackground':
          isForeground = false;
          break;
        case 'appForeground':
          isForeground = true;
          break;
      }
    });
  }
}


class Util {

  static Future<void> copyAsset2(String src, String dst) async {
    ByteData data = await rootBundle.load(src);
    await File(dst).writeAsBytes(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }
  
  
  static Future<void> copyAsset(String src, String dst) async {
  final data = (await rootBundle.load(src)).buffer.asUint8List();
  final file = File(dst);
  await file.writeAsBytes(data, flush: true); // force disk flush

  // wait until file is actually ready
  while (!await file.exists() || (await file.length()) == 0) {
    await Future.delayed(const Duration(milliseconds: 200));
  }
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
      case "defaultVenusCommand" : return b ? G.prefs.getString(key)! : (value){G.prefs.setString(key, value); return value;}("--no-virgl --venus --socket-path=/data/data/com.xodos/files/containers/0/tmp/.virgl_test");
      case "defaultVenusOpt" : return b ? G.prefs.getString(key)! : (value){G.prefs.setString(key, value); return value;}(" VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/virtio_icd.json VN_DEBUG=vtest ");
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
      case "defaultVirglCommand" : return b ? G.prefs.getString(key)! : (value){G.prefs.setString(key, value); return value;}("--use-egl-surfaceless --use-gles --socket-path=/data/data/com.xodos/files/usr/tmp/.virgl_test");
      case "defaultVirglOpt" : return b ? G.prefs.getString(key)! : (value){G.prefs.setString(key, value); return value;}("GALLIUM_DRIVER=virpipe");
      case "defaultTurnipOpt" : return b ? G.prefs.getString(key)! : (value){G.prefs.setString(key, value); return value;}("MESA_LOADER_DRIVER_OVERRIDE=zink VK_ICD_FILENAMES=/home/tiny/.local/share/tiny/extra/freedreno_icd.aarch64.json TU_DEBUG=noconform");
      case "defaultHidpiOpt" : return b ? G.prefs.getString(key)! : (value){G.prefs.setString(key, value); return value;}("GDK_SCALE=2 QT_FONT_DPI=192");
      case "containersInfo" : return G.prefs.getStringList(key)!;
      case "logcatEnabled" : return b ? G.prefs.getBool(key)! : (value){G.prefs.setBool(key, value); return value;}(true);
 
      }
  }

  static dynamic getCurrentProp(String key) {
    dynamic m = jsonDecode(Util.getGlobal("containersInfo")[G.currentContainer]);
    if (m.containsKey(key)) {
      return m[key];
    }
    switch (key) {
      case "name" : return (value){addCurrentProp(key, value); return value;}("XoDos Debian");
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
//final prefs = await SharedPreferences.getInstance();
 // await prefs.remove('extractionProgressT');
    
        await Util.copyAsset(
    "assets/assets.zip",
    "${G.dataPath}/assets.zip",
    );
    // patch.tar.xz contains the xodos folder with bionic rootfs
    // These are some binaries to support wine bionic and patches that will be mounted to ~/.local/share/tiny
    await Util.copyAsset(
    "assets/patch.tar.xz",
    "${G.dataPath}/patch.tar.xz",
    );
    
  /*  */
    
    print("preparing system environment ");
    
    await Util.execute(
"""
export DATA_DIR=${G.dataPath}

export LD_LIBRARY_PATH=\$DATA_DIR/lib:\$DATA_DIR/usr/lib
export PATH=\$DATA_DIR/bin:\$PATH
export CONTAINER_DIR=\$DATA_DIR/containers/0
export PROOT_TMP_DIR=\$DATA_DIR/proot_tmp
export PROOT_LOADER=\$DATA_DIR/applib/libproot-loader.so
export PROOT_LOADER_32=\$DATA_DIR/applib/libproot-loader32.so
#export PROOT_L2S_DIR=\$CONTAINER_DIR/.l2s
cd \$DATA_DIR
ln -sf ../applib/libexec_busybox.so \$DATA_DIR/bin/busybox
ln -sf ../applib/libexec_busybox.so \$DATA_DIR/bin/sh
ln -sf ../applib/libexec_busybox.so \$DATA_DIR/bin/cat
ln -sf ../applib/libexec_busybox.so \$DATA_DIR/bin/xz
ln -sf ../applib/libexec_busybox.so \$DATA_DIR/bin/gzip
ln -sf ../applib/libexec_proot.so \$DATA_DIR/bin/proot
ln -sf ../applib/libexec_tar.so \$DATA_DIR/bin/tar
#ln -sf ../applib/libexec_virgl_test_server.so \$DATA_DIR/bin/virgl_test_servero
ln -sf ../applib/libexec_getifaddrs_bridge_server.so \$DATA_DIR/bin/getifaddrs_bridge_server
ln -sf ../applib/libexec_pulseaudio.so \$DATA_DIR/bin/pulseaudio
ln -sf ../applib/libbusybox.so \$DATA_DIR/lib/libbusybox.so.1.37.0
ln -sf ../applib/libtalloc.so \$DATA_DIR/lib/libtalloc.so.2
#ln -sf ../applib/libvirglrenderer.so \$DATA_DIR/lib/libvirglrenderer.so
#ln -sf ../applib/libepoxy.so \$DATA_DIR/lib/libepoxy.so
ln -sf ../applib/libproot-loader32.so \$DATA_DIR/lib/loader32
ln -sf ../applib/libproot-loader.so \$DATA_DIR/lib/loader

\$DATA_DIR/bin/busybox unzip -o assets.zip
chmod -R +x libexec/proot/*
chmod -R +x bin/*
chmod 1777 tmp
sleep 1
\$DATA_DIR/bin/tar x -J --delay-directory-restore --preserve-permissions -v -f patch.tar.xz -C /data/data/com.xodos/files/ && \$DATA_DIR/bin/busybox rm -rf assets.zip patch.tar.xz
#\$DATA_DIR/bin/proot --link2symlink sh -c "\$DATA_DIR/bin/tar x -J --delay-directory-restore --preserve-permissions -v -f patch.tar.xz -C  /data/data/com.xodos/files/" && \$DATA_DIR/bin/busybox rm -rf assets.zip patch.tar.xz

""");
print("patch and assets extracted,,,");
    
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

    // Get the list of xa files flutter won't support copying More then 1gb file
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

""");
    // Some data initialization
    // $DATA_DIR is the data folder, $CONTAINER_DIR is the container root directory
    // Termux:X11's startup command is not here, it's hardcoded. Now it's a pile of stuff code :P
    print("xodos proot is ready");
    
    // Use LanguageManager for proper language support
    final languageCode = Localizations.localeOf(G.homePageStateContext).languageCode;
    final groupedCommands = LanguageManager.getGroupedCommandsForLanguage(languageCode);
    final groupedWineCommands = LanguageManager.getGroupedWineCommandsForLanguage(languageCode);
    
    await G.prefs.setStringList("containersInfo", ["""{
"name":"XoDos Rebirth",
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('extractionProgressT');
    
    }
    
     
  }

  static Future<void> initData() async {

    G.dataPath = (await getApplicationSupportDirectory()).path;

    G.termPtys = {};

    G.keyboard = VirtualKeyboard(defaultInputHandler);
    
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
      await initForFirstTime();
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
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final versionName = packageInfo.version;   // "1.0.4"
    final versionCode = packageInfo.buildNumber; // "4"
    
    // Write environment variables at the very beginning
    String envCommands = """
export DATA_DIR=${G.dataPath}
export LD_LIBRARY_PATH=\$DATA_DIR/lib:\$DATA_DIR/usr/lib:\$LD_LIBRARY_PATH
export PATH=\$DATA_DIR/usr/bin:\$PATH:\$DATA_DIR/bin
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

  # Set environment variables
prefixsh="/data/data/com.xodos/files/usr/bin"
    
    if [ -d "\$prefixsh" ]; then
    export SHELL=/data/data/com.xodos/files/usr/bin/bash
    export COLORTERM=truecolor
    export TERMUX_APP__USER_ID=0
    export PREFIX=/data/data/com.xodos/files/usr   
    export SHELL_CMD__RUNNER_NAME=terminal-session
    export TERMUX_APP__PACKAGE_NAME=com.xodos
    export XCURSOR_PATH=/data/data/com.xodos/files/usr/share/icons   
    export XCURSOR_SIZE=45  
    export PWD=/data/data/com.xodos/files/home
    export DXVK_STATE_CACHE=1
    export TERMUX_APP__FILES_DIR=/data/user/0/com.xodos/files
    export BOX64_LOG=0
    export TERMUX_APP__VERSION_NAME=$versionName
    export TERMUX_APP__VERSION_CODE=$versionCode
    export TERMUX_VERSION=$versionName
    export EXTERNAL_STORAGE=/sdcard
    export LD_PRELOAD=/data/data/com.xodos/files/usr/lib/libtermux-exec-ld-preload.so
    export HOME=/data/data/com.xodos/files/home
    export LANG=en_US.UTF-8
    export SHELL_CMD__TERMINAL_SESSION_NUMBER_SINCE_BOOT=0    
    export ANDROID_RUNTIME_ROOT=/apex/com.android.runtime
    export TERMUX_APP__PACKAGE_MANAGER=apt
    export DEX2OATBOOTCLASSPATH=/apex/com.android.runtime/javalib/core-oj.jar:/apex/com.android.runtime/javalib/core-libart.jar:/apex/com.android.runtime/javalib/okhttp.jar:/apex/com.android.runtime/javalib/bouncycastle.jar:/apex/com.android.runtime/javalib/apache-xml.jar:/system/framework/framework.jar:/system/framework/ext.jar:/system/framework/telephony-common.jar:/system/framework/voip-common.jar:/system/framework/ims-common.jar:/system/framework/knoxsdk.jar:/system/framework/knoxanalyticssdk.jar:/system/framework/smartbondingservice.jar:/system/framework/securetimersdk.jar:/system/framework/fipstimakeystore.jar:/system/framework/timakeystore.jar:/system/framework/sec_sdp_sdk.jar:/system/framework/sec_sdp_hidden_sdk.jar:/system/framework/drutils.jar:/system/framework/android.test.base.jar:/system/framework/ucmopensslenginehelper.jar:/system/framework/esecomm.jar:/system/framework/tcmiface.jar:/system/framework/QPerformance.jar:/system/framework/UxPerformance.jar
    export TMPDIR=/data/data/com.xodos/files/usr/tmp
    export ANDROID_DATA=/data
    export TERMUX_APP__AM_SOCKET_SERVER_ENABLED=true
    export SHELL_CMD__SHELL_ID=0    
    export ANDROID_STORAGE=/storage
    export TERM=xterm-256color
    export TERMUX_APP__IS_DEBUGGABLE_BUILD=true
    export ASEC_MOUNTPOINT=/mnt/asec
    export DISPLAY=:4
    export SHLVL=1
    export ANDROID_ROOT=/system
    export SHELL_CMD__TERMINAL_SESSION_NUMBER_SINCE_APP_START=0
    export BOOTCLASSPATH=/apex/com.android.runtime/javalib/core-oj.jar:/apex/com.android.runtime/javalib/core-libart.jar:/apex/com.android.runtime/javalib/okhttp.jar:/apex/com.android.runtime/javalib/bouncycastle.jar:/apex/com.android.runtime/javalib/apache-xml.jar:/system/framework/framework.jar:/system/framework/ext.jar:/system/framework/telephony-common.jar:/system/framework/voip-common.jar:/system/framework/ims-common.jar:/system/framework/knoxsdk.jar:/system/framework/knoxanalyticssdk.jar:/system/framework/smartbondingservice.jar:/system/framework/securetimersdk.jar:/system/framework/fipstimakeystore.jar:/system/framework/timakeystore.jar:/system/framework/sec_sdp_sdk.jar:/system/framework/sec_sdp_hidden_sdk.jar:/system/framework/drutils.jar:/system/framework/android.test.base.jar:/system/framework/ucmopensslenginehelper.jar:/system/framework/esecomm.jar:/system/framework/tcmiface.jar:/system/framework/QPerformance.jar:/system/framework/UxPerformance.jar:/apex/com.android.conscrypt/javalib/conscrypt.jar:/apex/com.android.media/javalib/updatable-media.jar
    export TERMUX_APP__APK_RELEASE=GITHUB
    export XDG_RUNTIME_DIR=/data/data/com.xodos/files/usr/tmp
    export DXVK_LOG_PATH=/data/data/com.xodos/files/home/.cache
    export DXVK_STATE_CACHE_PATH=/data/data/com.xodos/files/home/.cache
    export ANDROID_TZDATA_ROOT=/apex/com.android.tzdata
    export SHELL_CMD__PACKAGE_NAME=com.xodos
    #export XCURSOR_THEME=gaming
    export PATH=/data/data/com.xodos/files/usr/bin:\$PATH
    export ANDROID_ASSETS=/system/app
    export _=/data/data/com.xodos/files/usr/bin/env
#export XDG_DATA_DIRS=\$PREFIX/usr/share
#export XDG_CONFIG_DIRS=\$PREFIX/etc/xdg
#export XDG_CONFIG_HOME=\$HOME/.config
#export XDG_DATA_HOME=\$HOME/.local/share
#export XDG_CACHE_HOME=\$HOME/.cache
unset VK_ICD_FILENAMES
ln -sf \$DATA_DIR/containers/0/tmp \$DATA_DIR/usr/
exec \$DATA_DIR/usr/bin/bash --login   
export LD_LIBRARY_PATH=\$DATA_DIR/lib:\$DATA_DIR/usr/lib:\$DATA_DIR/usr/libexec/:\$LD_LIBRARY_PATH
unset PATH
export PATH=\$DATA_DIR/usr/bin:\$DATA_DIR/bin:\$PATH
unset LD_LIBRARY_PATH
     if [ -d "\$prefixsh" ]; then
ln -sf \$DATA_DIR/containers/0/tmp \$DATA_DIR/usr/
exec \$DATA_DIR/usr/bin/bash --login   
fi
     fi
cd
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
export PREFIX=\$DATA_DIR/usr
export HOME=\$DATA_DIR/home
export TMPDIR=\$DATA_DIR/usr/tmp
mkdir -p \$HOME
mkdir -p \$TMPDIR
export PATH=\$DATA_DIR/bin:\$PATH
export LD_LIBRARY_PATH=\$DATA_DIR/lib
\$DATA_DIR/bin/busybox sed "s/4713/${Util.getGlobal("defaultAudioPort") as int}/g" \$DATA_DIR/bin/pulseaudio.conf > \$DATA_DIR/bin/pulseaudio.conf.tmp
rm -rf \$TMPDIR/*
TMPDIR=\$TMPDIR HOME=\$DATA_DIR/home XDG_CONFIG_HOME=\$TMPDIR LD_LIBRARY_PATH=\$DATA_DIR/bin:\$LD_LIBRARY_PATH \$DATA_DIR/bin/pulseaudio --daemonize=no --exit-idle-time=-1 -F \$DATA_DIR/bin/pulseaudio.conf.tmp

"""));
  //await G.audioPty?.exitCode;
  }
  static Future<void> launchCurrentContainer() async {
    String extraMount = ""; //mount options and other proot options
    String extraOpt = "";
    
  
      if (Util.getGlobal("getifaddrsBridge")) {
            
//   Util.execute("${G.dataPath}/bin/getifaddrs_bridge_server ${G.dataPath}/containers/${G.currentContainer}/tmp/.getifaddrs-bridge");
//Util.termWrite("getifaddrs_bridge_server /tmp/.getifaddrs-bridge &")
     // extraOpt += "LD_PRELOAD=/home/tiny/.local/share/tiny/extra/getifaddrs_bridge_client_lib.so ";
    }
  
  
    if (Util.getGlobal("isHidpiEnabled")) {
      extraOpt += "${Util.getGlobal("defaultHidpiOpt")} ";
    }
    if (Util.getGlobal("uos")) {
      extraMount += "--mount=\$DATA_DIR/tiny/wechat/uos-lsb:/etc/lsb-release --mount=\$DATA_DIR/tiny/wechat/uos-release:/usr/lib/os-release ";
      extraMount += "--mount=\$DATA_DIR/tiny/wechat/license/var/uos:/var/uos --mount=\$DATA_DIR/tiny/wechat/license/var/lib/uos-license:/var/lib/uos-license ";
    }
 
    // Hardware acceleration section - now includes Venus
bool virglEnabled = Util.getGlobal("virgl") as bool;
bool venusEnabled = Util.getGlobal("venus") as bool;
bool turnipEnabled = Util.getGlobal("turnip") as bool;

// Update the hardware acceleration section in Workflow.launchCurrentContainer():
if (Util.getGlobal("virgl")) {
  Util.execute("""
export DATA_DIR=${G.dataPath}

export PATH=\$DATA_DIR/usr/bin:\$DATA_DIR/bin:\$PATH
export LD_LIBRARY_PATH=\$DATA_DIR/lib:\$DATA_DIR/usr/lib
export CONTAINER_DIR=\$DATA_DIR/containers/${G.currentContainer}
#${G.dataPath}/usr/bin/virgl_test_server ${Util.getGlobal("defaultVirglCommand")} &
""");
  extraOpt += "${Util.getGlobal("defaultVirglOpt")} ";
} 
 if (Util.getGlobal("venus")) {
  // Venus hardware acceleration
  String venusCommand = Util.getGlobal("defaultVenusCommand") as String;
  String venusOpt = Util.getGlobal("defaultVenusOpt") as String;
  
  // Build the LD_PRELOAD path
  String ldPreload = "/system/lib64/libvulkan.so";
  
  // Check if ANDROID_VENUS should be added
  bool androidVenusEnabled = Util.getGlobal("androidVenus") as bool;
  String androidVenusEnv = androidVenusEnabled ? "ANDROID_VENUS=1 " : "";
  
  // Build the full command
  String fullCommand = "${androidVenusEnv} ${G.dataPath}/bin/virgl_test_server $venusCommand &";
  
  Util.execute("""
export DATA_DIR=${G.dataPath}
export PATH=\$DATA_DIR/usr/bin:\$DATA_DIR/bin:\$PATH
export LD_LIBRARY_PATH=\$DATA_DIR/lib:\$DATA_DIR/usr/lib:/system/lib64
export CONTAINER_DIR=\$DATA_DIR/containers/${G.currentContainer}

#$fullCommand

""");
  
  extraOpt += "$venusOpt ";
    if (!(Util.getGlobal("dri3"))) {
    extraOpt += "MESA_VK_WSI_DEBUG=sw ";
    extraOpt += "MESA_VK_WSI_PRESENT_MODE=mailbox ";
  }
}

if (Util.getGlobal("turnip")) {
 Util.termWrite("""
#. /data/data/com.xodos/files/usr/opt/drv
export MESA_VK_WSI_PRESENT_MODE=mailbox
""");
  extraOpt += "${Util.getGlobal("defaultTurnipOpt")} ";
  if (!(Util.getGlobal("dri3"))) {
    extraOpt += "MESA_VK_WSI_DEBUG=sw ";
    extraOpt += "MESA_VK_WSI_PRESENT_MODE=mailbox ";
  }
}
    if (Util.getGlobal("isJpEnabled")) {
      extraOpt += "LANG=ja_JP.UTF-8 ";
    }
    extraMount += "--mount=\$DATA_DIR/tiny/font:/usr/share/fonts/tiny ";
    extraMount += "--mount=\$DATA_DIR/tmp:/dev/dri ";
    extraMount += "--mount=\$DATA_DIR/tiny/extra/cmatrix:/home/tiny/.local/bin/cmatrix ";
  
    
        Util.termWrite(
"""
export DATA_DIR=${G.dataPath}
export PATH=\$DATA_DIR/bin:\$DATA_DIR/usr/bin:\$PATH
export LD_LIBRARY_PATH=\$DATA_DIR/lib:\$DATA_DIR/usr/lib
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


//
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
  // 
  // Util.termWrite("clear"); // 
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
  
static Future<void> workflow() async {
if (!AndroidAppState.isForeground) {
  return;
}
  grantPermissions();
  await initData();
  await initTerminalForCurrent();
  
  // Setup audio first
  setupAudio();
  
    if (Util.getGlobal("logcatEnabled") as bool) {
    LogcatManager().startCapture();
  }
  
  
  // Send virgl/venus server command to terminal BEFORE container starts
  await startGraphicsServerInTerminal();
  
  // Then launch container
  launchCurrentContainer();
  
  if (Util.getGlobal("autoLaunchVnc") as bool) {
    if (G.wasX11Enabled) {
      await Util.waitForXServer();
      launchGUIBackend();
      launchX11();
      return;
    }
    launchGUIBackend();
    waitForConnection().then((value) => G.wasAvncEnabled?launchAvnc():launchBrowser());
  }
}

// NEW METHOD: Send graphics server command to terminal
static Future<void> startGraphicsServerInTerminal() async {
  bool virglEnabled = Util.getGlobal("virgl") as bool;
  bool venusEnabled = Util.getGlobal("venus") as bool;
  
if (Util.getGlobal("getifaddrsBridge")) {
  print("Enabling getifaddrs bridge");

  Util.termWrite("""
export DATA_DIR=${G.dataPath}
export CONTAINER_DIR=\$DATA_DIR/containers/${G.currentContainer}
BASHRC="\$CONTAINER_DIR/home/xodos/.bashrc"

LD_LINE='export LD_PRELOAD=/home/tiny/.local/share/tiny/extra/getifaddrs_bridge_client_lib.so'

# Ensure bashrc exists
touch "\$BASHRC"

# Remove old entry if any (idempotent)
sed -i '\\|^export LD_PRELOAD=.*/getifaddrs_bridge_client_lib.so\$|d' "\$BASHRC"

# Append
echo "\$LD_LINE" >> "\$BASHRC"

# Start server
pkill -f getifaddrs_* 2>/dev/null || true
rm -f "\$CONTAINER_DIR/tmp/.getifaddrs-bridge" 2>/dev/null || true
\$DATA_DIR/bin/getifaddrs_bridge_server "\$CONTAINER_DIR/tmp/.getifaddrs-bridge" &

echo "getifaddrs bridge enabled"
""");

} else {
  print("Disabling getifaddrs bridge");

  Util.termWrite("""
export DATA_DIR=${G.dataPath}
export CONTAINER_DIR=\$DATA_DIR/containers/${G.currentContainer}
BASHRC="\$CONTAINER_DIR/home/xodos/.bashrc"

# Remove LD_PRELOAD line
sed -i '\\|^export LD_PRELOAD=.*/getifaddrs_bridge_client_lib.so\$|d' "\$BASHRC"

# Stop server
pkill -f getifaddrs_bridge_server 2>/dev/null || true
rm -f "\$CONTAINER_DIR/tmp/.getifaddrs-bridge" 2>/dev/null || true

echo "getifaddrs bridge disabled"
""");
}
  
  if (venusEnabled) {
    print("Sending Venus server command to terminal");
    
    // Build the command
    String venusCommand = Util.getGlobal("defaultVenusCommand") as String;
    bool androidVenusEnabled = Util.getGlobal("androidVenus") as bool;
    String androidVenusEnv = androidVenusEnabled ? "ANDROID_VENUS=1 " : "";
    
    // Send to terminal
    Util.termWrite("""
export DATA_DIR=${G.dataPath}
export PATH=\$DATA_DIR/usr/bin:\$DATA_DIR/bin:\$PATH
export LD_LIBRARY_PATH=\$DATA_DIR/lib:\$DATA_DIR/usr/lib
unset LD_LIBRARY_PATH
export CONTAINER_DIR=\$DATA_DIR/containers/${G.currentContainer}

pkill -f 'virgl_*'  2>/dev/null || true
rm -f \${CONTAINER_DIR}/tmp/.virgl_test 2>/dev/null || true
. /data/data/com.xodos/files/usr/opt/drv
VK_ICD_FILENAMES=\$DATA_DIR/usr/share/vulkan/icd.d/wrapper_icd.aarch64.json $androidVenusEnv virgl_test_server $venusCommand > \${CONTAINER_DIR}/venus.log 2>&1 &
export MESA_VK_WSI_PRESENT_MODE=mailbox
export VN_DEBUG=vtest
echo "Venus server started in background"
""");
    
  } else if (virglEnabled) {
    print("Sending Virgl server command to terminal");
    
    Util.termWrite("""
export DATA_DIR=${G.dataPath}
export PATH=\$DATA_DIR/usr/bin:\$DATA_DIR/bin:\$PATH
export LD_LIBRARY_PATH=\$DATA_DIR/lib:/data/data/com.xodos/files/usr/lib
unset LD_LIBRARY_PATH
export CONTAINER_DIR=\$DATA_DIR/containers/${G.currentContainer}

pkill -f 'virgl_*' 2>/dev/null || true
rm -f \${CONTAINER_DIR}/tmp/.virgl_test 2>/dev/null || true

virgl_test_server ${Util.getGlobal("defaultVirglCommand")} > \${CONTAINER_DIR}/virgl.log 2>&1 &

echo "Virgl server started in background"
""");
  }
}
  
  
  
}