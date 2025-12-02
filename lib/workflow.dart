// main.dart - Fixed XoDos version
import 'dart:async';
import 'dart:io';
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

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/gestures.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:clipboard/clipboard.dart';

import 'package:audioplayers/audioplayers.dart';

import 'spirited_mini_games.dart';
import 'package:xodos/l10n/app_localizations.dart';

import 'package:avnc_flutter/avnc_flutter.dart';
import 'package:x11_flutter/x11_flutter.dart';

// ========== UTIL CLASS (CRITICAL - WAS MISSING) ==========
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
    Pty pty = Pty.start("/system/bin/sh");
    pty.write(const Utf8Encoder().convert("$str\nexit \$?\n"));
    return await pty.exitCode;
  }

  static void termWrite(String str) {
    if (G.termPtys.containsKey(G.currentContainer)) {
      G.termPtys[G.currentContainer]!.pty.write(const Utf8Encoder().convert("$str\n"));
    }
  }

  static dynamic getGlobal(String key) {
    bool b = G.prefs.containsKey(key);
    switch (key) {
      case "defaultContainer": return b ? G.prefs.getInt(key)! : (G.prefs.setInt(key, 0), 0);
      case "defaultAudioPort": return b ? G.prefs.getInt(key)! : (G.prefs.setInt(key, 4718), 4718);
      case "autoLaunchVnc": return b ? G.prefs.getBool(key)! : (G.prefs.setBool(key, true), true);
      case "lastDate": return b ? G.prefs.getString(key)! : (G.prefs.setString(key, "1970-01-01"), "1970-01-01");
      case "isTerminalWriteEnabled": return b ? G.prefs.getBool(key)! : (G.prefs.setBool(key, false), false);
      case "isTerminalCommandsEnabled": return b ? G.prefs.getBool(key)! : (G.prefs.setBool(key, false), false);
      case "termMaxLines": return b ? G.prefs.getInt(key)! : (G.prefs.setInt(key, 4095), 4095);
      case "termFontScale": return b ? G.prefs.getDouble(key)! : (G.prefs.setDouble(key, 1.0), 1.0);
      case "isStickyKey": return b ? G.prefs.getBool(key)! : (G.prefs.setBool(key, true), true);
      case "reinstallBootstrap": return b ? G.prefs.getBool(key)! : (G.prefs.setBool(key, false), false);
      case "getifaddrsBridge": return b ? G.prefs.getBool(key)! : (G.prefs.setBool(key, false), false);
      case "uos": return b ? G.prefs.getBool(key)! : (G.prefs.setBool(key, false), false);
      case "virgl": return b ? G.prefs.getBool(key)! : (G.prefs.setBool(key, false), false);
      case "turnip": return b ? G.prefs.getBool(key)! : (G.prefs.setBool(key, false), false);
      case "dri3": return b ? G.prefs.getBool(key)! : (G.prefs.setBool(key, false), false);
      case "wakelock": return b ? G.prefs.getBool(key)! : (G.prefs.setBool(key, false), false);
      case "isHidpiEnabled": return b ? G.prefs.getBool(key)! : (G.prefs.setBool(key, false), false);
      case "isJpEnabled": return b ? G.prefs.getBool(key)! : (G.prefs.setBool(key, false), false);
      case "useAvnc": return b ? G.prefs.getBool(key)! : (G.prefs.setBool(key, true), true);
      case "avncResizeDesktop": return b ? G.prefs.getBool(key)! : (G.prefs.setBool(key, true), true);
      case "avncScaleFactor": return b ? G.prefs.getDouble(key)!.clamp(-1.0, 1.0) : (G.prefs.setDouble(key, -0.5), -0.5);
      case "useX11": return b ? G.prefs.getBool(key)! : (G.prefs.setBool(key, false), false);
      case "defaultFFmpegCommand": return b ? G.prefs.getString(key)! : (G.prefs.setString(key, "-hide_banner -an -max_delay 1000000 -r 30 -f android_camera -camera_index 0 -i 0:0 -vf scale=iw/2:-1 -rtsp_transport udp -f rtsp rtsp://127.0.0.1:8554/stream"), "-hide_banner -an -max_delay 1000000 -r 30 -f android_camera -camera_index 0 -i 0:0 -vf scale=iw/2:-1 -rtsp_transport udp -f rtsp rtsp://127.0.0.1:8554/stream");
      case "defaultVirglCommand": return b ? G.prefs.getString(key)! : (G.prefs.setString(key, "--use-egl-surfaceless --use-gles --socket-path=\$CONTAINER_DIR/tmp/.virgl_test"), "--use-egl-surfaceless --use-gles --socket-path=\$CONTAINER_DIR/tmp/.virgl_test");
      case "defaultVirglOpt": return b ? G.prefs.getString(key)! : (G.prefs.setString(key, "GALLIUM_DRIVER=virpipe"), "GALLIUM_DRIVER=virpipe");
      case "defaultTurnipOpt": return b ? G.prefs.getString(key)! : (G.prefs.setString(key, "MESA_LOADER_DRIVER_OVERRIDE=zink VK_ICD_FILENAMES=/home/tiny/.local/share/tiny/extra/freedreno_icd.aarch64.json TU_DEBUG=noconform"), "MESA_LOADER_DRIVER_OVERRIDE=zink VK_ICD_FILENAMES=/home/tiny/.local/share/tiny/extra/freedreno_icd.aarch64.json TU_DEBUG=noconform");
      case "defaultHidpiOpt": return b ? G.prefs.getString(key)! : (G.prefs.setString(key, "GDK_SCALE=2 QT_FONT_DPI=192"), "GDK_SCALE=2 QT_FONT_DPI=192");
      case "containersInfo": return G.prefs.getStringList(key) ?? [];
    }
    return null;
  }

  static dynamic getCurrentProp(String key) {
    List<String> containers = getGlobal("containersInfo") as List<String>;
    if (containers.isEmpty) return null;
    
    dynamic m = jsonDecode(containers[G.currentContainer]);
    if (m.containsKey(key)) {
      return m[key];
    }
    
    switch (key) {
      case "name": return "Debian Bookworm";
      case "boot": return D.boot;
      case "vnc": return "startnovnc &";
      case "vncUrl": return "http://localhost:36082/vnc.html?host=localhost&port=36082&autoconnect=true&resize=remote&password=12345678";
      case "vncUri": return "vnc://127.0.0.1:5904?VncPassword=12345678&SecurityType=2";
      case "commands": return jsonDecode(jsonEncode(D.commands));
    }
    return null;
  }

  static Future<void> setCurrentProp(String key, dynamic value) async {
    List<String> containers = List.from(getGlobal("containersInfo") as List<String>);
    if (containers.isEmpty) {
      containers.add("{}");
    }
    
    dynamic m = jsonDecode(containers[G.currentContainer]);
    m[key] = value;
    containers[G.currentContainer] = jsonEncode(m);
    await G.prefs.setStringList("containersInfo", containers);
  }

  static Future<void> addCurrentProp(String key, dynamic value) async {
    List<String> containers = List.from(getGlobal("containersInfo") as List<String>);
    if (containers.isEmpty) {
      containers.add("{}");
    }
    
    dynamic m = jsonDecode(containers[G.currentContainer]);
    m[key] = value;
    containers[G.currentContainer] = jsonEncode(m);
    await G.prefs.setStringList("containersInfo", containers);
  }

  static String? validateBetween(String? value, int min, int max, Function opr) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(G.homePageStateContext)!.enterNumber;
    }
    int? parsedValue = int.tryParse(value);
    if (parsedValue == null) {
      return AppLocalizations.of(G.homePageStateContext)!.enterValidNumber;
    }
    if (parsedValue < min || parsedValue > max) {
      return "请输入$min到$max之间的数字";
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
      if (isReady) {
        return;
      }
      await Future.delayed(Duration(seconds: 1));
    }
  }

  static String getl10nText(String key, BuildContext context) {
    switch (key) {
      case 'projectUrl': return AppLocalizations.of(context)!.projectUrl;
      case 'issueUrl': return AppLocalizations.of(context)!.issueUrl;
      case 'faqUrl': return AppLocalizations.of(context)!.faqUrl;
      case 'solutionUrl': return AppLocalizations.of(context)!.solutionUrl;
      case 'discussionUrl': return AppLocalizations.of(context)!.discussionUrl;
      default: return AppLocalizations.of(context)!.projectUrl;
    }
  }
}

// ========== VIRTUAL KEYBOARD CLASS (CRITICAL - WAS MISSING) ==========
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
    G.maybeCtrlJ = event.key.name == "keyJ";
    if (!(Util.getGlobal("isStickyKey") as bool)) {
      G.keyboard.ctrl = false;
      G.keyboard.shift = false;
      G.keyboard.alt = false;
    }
    return ret;
  }
}

// ========== TERMPTY CLASS (CRITICAL - WAS MISSING) ==========
class TermPty {
  late final Terminal terminal;
  late final Pty pty;
  late final TerminalController controller;

  TermPty() {
    terminal = Terminal(inputHandler: G.keyboard, maxLines: Util.getGlobal("termMaxLines") as int);
    controller = TerminalController();
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
      if (code == -9) {
        D.androidChannel.invokeMethod("launchSignal9Page", {});
      }
    });
    
    terminal.onOutput = (data) {
      if (!(Util.getGlobal("isTerminalWriteEnabled") as bool)) {
        return;
      }
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

// ========== D CLASS (UPDATED WITH MISSING PARTS) ==========
class D {
  static const links = [
    {"name": "projectUrl", "value": "https://github.com/xodiosx/XoDos2"},
    {"name": "issueUrl", "value": "https://github.com/xodiosx/XoDos2/issues"},
    {"name": "faqUrl", "value": "https://github.com/xodiosx/XoDos2/blob/main/FAQ.md"},
    {"name": "solutionUrl", "value": "https://github.com/xodiosx/XoDos2/blob/main/SOLUTIONS.md"},
    {"name": "discussionUrl", "value": "https://github.com/xodiosx/XoDos2/discussions"},
  ];

  static const commands = [
    {"name":"检查更新并升级", "command":"sudo dpkg --configure -a && sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y"},
    {"name":"查看系统信息", "command":"neofetch -L && neofetch --off"},
    {"name":"清屏", "command":"clear"},
    {"name":"中断任务", "command":"\x03"},
    {"name":"安装图形处理软件Krita", "command":"sudo apt update && sudo apt install -y krita krita-l10n"},
    {"name":"卸载Krita", "command":"sudo apt autoremove --purge -y krita krita-l10n"},
    {"name":"安装视频剪辑软件Kdenlive", "command":"sudo apt update && sudo apt install -y kdenlive"},
    {"name":"卸载Kdenlive", "command":"sudo apt autoremove --purge -y kdenlive"},
    {"name":"安装科学计算软件Octave", "command":"sudo apt update && sudo apt install -y octave"},
    {"name":"卸载Octave", "command":"sudo apt autoremove --purge -y octave"},
    {"name":"安装WPS", "command":r"""cat << 'EOF' | sh && sudo dpkg --configure -a && sudo apt update && sudo apt install -y /tmp/wps.deb
wget https://github.akams.cn/https://github.com/tiny-computer/third-party-archives/releases/download/archives/wps-office_11.1.0.11720_arm64.deb -O /tmp/wps.deb
EOF
rm /tmp/wps.deb"""},
    {"name":"卸载WPS", "command":"sudo apt autoremove --purge -y wps-office"},
    {"name":"安装CAJViewer", "command":"wget https://download.cnki.net/net.cnki.cajviewer_1.3.20-1_arm64.deb -O /tmp/caj.deb && sudo apt update && sudo apt install -y /tmp/caj.deb && bash /home/tiny/.local/share/tiny/caj/postinst; rm /tmp/caj.deb"},
    {"name":"卸载CAJViewer", "command":"sudo apt autoremove --purge -y net.cnki.cajviewer && bash /home/tiny/.local/share/tiny/caj/postrm"},
    {"name":"安装亿图图示", "command":"wget https://cc-download.wondershare.cc/business/prd/edrawmax_13.1.0-1_arm64_binner.deb -O /tmp/edraw.deb && sudo apt update && sudo apt install -y /tmp/edraw.deb && bash /home/tiny/.local/share/tiny/edraw/postinst; rm /tmp/edraw.deb"},
    {"name":"卸载亿图图示", "command":"sudo apt autoremove --purge -y edrawmax libldap-2.4-2"},
    {"name":"安装QQ", "command":"""wget \$(curl -s https://im.qq.com/rainbow/linuxQQDownload | grep -oP '"armDownloadUrl":{[^}]*"deb":"\\K[^"]+') -O /tmp/qq.deb && sudo apt update && sudo apt install -y /tmp/qq.deb && sed -i 's#Exec=/opt/QQ/qq %U#Exec=/opt/QQ/qq --no-sandbox %U#g' /usr/share/applications/qq.desktop; rm /tmp/qq.deb"""},
    {"name":"卸载QQ", "command":"sudo apt autoremove --purge -y linuxqq"},
    {"name":"安装微信", "command":"wget https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_arm64.deb -O /tmp/wechat.deb && sudo apt update && sudo apt install -y /tmp/wechat.deb && echo '安装完成。如果你使用微信只是为了传输文件，那么可以考虑使用支持SAF的文件管理器（如：质感文件），直接访问小小电脑所有文件。'; rm /tmp/wechat.deb"},
    {"name":"卸载微信", "command":"sudo apt autoremove --purge -y wechat"},
    {"name":"安装钉钉", "command":"""wget \$(curl -sw %{redirect_url} https://www.dingtalk.com/win/d/qd=linux_arm64) -O /tmp/dingtalk.deb && sudo apt update && sudo apt install -y /tmp/dingtalk.deb libglut3.12 libglu1-mesa && sed -i 's#\\./com.alibabainc.dingtalk#\\./com.alibabainc.dingtalk --no-sandbox#g' /opt/apps/com.alibabainc.dingtalk/files/Elevator.sh; rm /tmp/dingtalk.deb"""},
    {"name":"卸载钉钉", "command":"sudo apt autoremove --purge -y com.alibabainc.dingtalk"},
    {"name":"启用回收站", "command":"sudo apt update && sudo apt install -y gvfs && echo '安装完成, 重启软件即可使用回收站。'"},
    {"name":"清理包管理器缓存", "command":"sudo apt clean"},
    {"name":"关机", "command":"stopvnc\nexit\nexit"},
    {"name":"???", "command":"timeout 8 cmatrix"}
  ];

  static const commands4En = [
    {"name":"Update Packages", "command":"sudo dpkg --configure -a && sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y"},
    {"name":"System Info", "command":"neofetch -L && neofetch --off"},
    {"name":"Clear", "command":"clear"},
    {"name":"Interrupt", "command":"\x03"},
    {"name":"Install Painting Program Krita", "command":"sudo apt update && sudo apt install -y krita krita-l10n"},
    {"name":"Uninstall Krita", "command":"sudo apt autoremove --purge -y krita krita-l10n"},
    {"name":"Install KDE Non-Linear Video Editor", "command":"sudo apt update && sudo apt install -y kdenlive"},
    {"name":"Uninstall Kdenlive", "command":"sudo apt autoremove --purge -y kdenlive"},
    {"name":"Install LibreOffice", "command":"sudo apt update && sudo apt install -y libreoffice"},
    {"name":"Uninstall LibreOffice", "command":"sudo apt autoremove --purge -y libreoffice"},
    {"name":"Install WPS", "command":r"""cat << 'EOF' | sh && sudo dpkg --configure -a && sudo apt update && sudo apt install -y /tmp/wps.deb
wget https://github.com/tiny-computer/third-party-archives/releases/download/archives/wps-office_11.1.0.11720_arm64.deb -O /tmp/wps.deb
EOF
rm /tmp/wps.deb"""},
    {"name":"Uninstall WPS", "command":"sudo apt autoremove --purge -y wps-office"},
    {"name":"Install EdrawMax", "command":"""wget https://cc-download.wondershare.cc/business/prd/edrawmax_13.1.0-1_arm64_binner.deb -O /tmp/edraw.deb && sudo apt update && sudo apt install -y /tmp/edraw.deb && bash /home/tiny/.local/share/tiny/edraw/postinst && sudo sed -i 's/<Language V="cn"\\/>/<Language V="en"\\/>/g' /opt/apps/edrawmax/config/settings.xml; rm /tmp/edraw.deb"""},
    {"name":"Uninstall EdrawMax", "command":"sudo apt autoremove --purge -y edrawmax libldap-2.4-2"},
    {"name":"Enable Recycle Bin", "command":"sudo apt update && sudo apt install -y gvfs && echo 'Restart the app to use Recycle Bin.'"},
    {"name":"Clean Package Cache", "command":"sudo apt clean"},
    {"name":"Power Off", "command":"stopvnc\nexit\nexit"},
    {"name":"???", "command":"timeout 8 cmatrix"}
  ];

  static const wineCommands = [
    {"name":"Wine配置", "command":"winecfg"},
    {"name":"修复方块字", "command":"regedit Z:\\\\home\\\\tiny\\\\.local\\\\share\\\\tiny\\\\extra\\\\chn_fonts.reg && wine reg delete \"HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows NT\\CurrentVersion\\FontSubstitutes\" /va /f"},
    {"name":"开始菜单文件夹", "command":"wine explorer \"C:\\\\ProgramData\\\\Microsoft\\\\Windows\\\\Start Menu\\\\Programs\""},
    {"name":"开启DXVK", "command":"""WINEDLLOVERRIDES="d3d8=n,d3d9=n,d3d10core=n,d3d11=n,dxgi=n" wine reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d8 /d native /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=n,d3d9=n,d3d10core=n,d3d11=n,dxgi=n" wine reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d9 /d native /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=n,d3d9=n,d3d10core=n,d3d11=n,dxgi=n" wine reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d10core /d native /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=n,d3d9=n,d3d10core=n,d3d11=n,dxgi=n" wine reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d11 /d native /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=n,d3d9=n,d3d10core=n,d3d11=n,dxgi=n" wine reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v dxgi /d native /f >/dev/null 2>&1"""},
    {"name":"关闭DXVK", "command":"""WINEDLLOVERRIDES="d3d8=b,d3d9=b,d3d10core=b,d3d11=b,dxgi=b" wine reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d8 /d builtin /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=b,d3d9=b,d3d10core=b,d3d11=b,dxgi=b" wine reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d9 /d builtin /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=b,d3d9=b,d3d10core=b,d3d11=b,dxgi=b" wine reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d10core /d builtin /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=b,d3d9=b,d3d10core=b,d3d11=b,dxgi=b" wine reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d11 /d builtin /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=b,d3d9=b,d3d10core=b,d3d11=b,dxgi=b" wine reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v dxgi /d builtin /f >/dev/null 2>&1"""},
    {"name":"我的电脑", "command":"wine explorer"},
    {"name":"记事本", "command":"notepad"},
    {"name":"扫雷", "command":"winemine"},
    {"name":"注册表", "command":"regedit"},
    {"name":"控制面板", "command":"wine control"},
    {"name":"文件管理器", "command":"winefile"},
    {"name":"任务管理器", "command":"wine taskmgr"},
    {"name":"IE浏览器", "command":"wine iexplore"},
    {"name":"强制关闭Wine", "command":"wineserver -k"}
  ];

  static const wineCommands4En = [
    {"name":"Wine Configuration", "command":"winecfg"},
    {"name":"Fix CJK Characters", "command":"regedit Z:\\\\home\\\\tiny\\\\.local\\\\share\\\\tiny\\\\extra\\\\chn_fonts.reg && wine reg delete \"HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows NT\\CurrentVersion\\FontSubstitutes\" /va /f"},
    {"name":"Start Menu Dir", "command":"wine explorer \"C:\\\\ProgramData\\\\Microsoft\\\\Windows\\\\Start Menu\\\\Programs\""},
    {"name":"Enable DXVK", "command":"""WINEDLLOVERRIDES="d3d8=n,d3d9=n,d3d10core=n,d3d11=n,dxgi=n" wine reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d8 /d native /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=n,d3d9=n,d3d10core=n,d3d11=n,dxgi=n" wine reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d9 /d native /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=n,d3d9=n,d3d10core=n,d3d11=n,dxgi=n" wine reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d10core /d native /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=n,d3d9=n,d3d10core=n,d3d11=n,dxgi=n" wine reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d11 /d native /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=n,d3d9=n,d3d10core=n,d3d11=n,dxgi=n" wine reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v dxgi /d native /f >/dev/null 2>&1"""},
    {"name":"Disable DXVK", "command":"""WINEDLLOVERRIDES="d3d8=b,d3d9=b,d3d10core=b,d3d11=b,dxgi=b" wine reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d8 /d builtin /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=b,d3d9=b,d3d10core=b,d3d11=b,dxgi=b" wine reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d9 /d builtin /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=b,d3d9=b,d3d10core=b,d3d11=b,dxgi=b" wine reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d10core /d builtin /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=b,d3d9=b,d3d10core=b,d3d11=b,dxgi=b" wine reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d11 /d builtin /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=b,d3d9=b,d3d10core=b,d3d11=b,dxgi=b" wine reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v dxgi /d builtin /f >/dev/null 2>&1"""},
    {"name":"Explorer", "command":"wine explorer"},
    {"name":"Notepad", "command":"notepad"},
    {"name":"Minesweeper", "command":"winemine"},
    {"name":"Regedit", "command":"regedit"},
    {"name":"Control Panel", "command":"wine control"},
    {"name":"File Manager", "command":"winefile"},
    {"name":"Task Manager", "command":"wine taskmgr"},
    {"name":"Internet Explorer", "command":"wine iexplore"},
    {"name":"Kill Wine Process", "command":"wineserver -k"}
  ];

  static const termCommands = [
    {"name": "Esc", "key": TerminalKey.escape},
    {"name": "Tab", "key": TerminalKey.tab},
    {"name": "↑", "key": TerminalKey.arrowUp},
    {"name": "↓", "key": TerminalKey.arrowDown},
    {"name": "←", "key": TerminalKey.arrowLeft},
    {"name": "→", "key": TerminalKey.arrowRight},
    {"name": "Del", "key": TerminalKey.delete},
    {"name": "PgUp", "key": TerminalKey.pageUp},
    {"name": "PgDn", "key": TerminalKey.pageDown},
    {"name": "Home", "key": TerminalKey.home},
    {"name": "End", "key": TerminalKey.end},
    {"name": "F1", "key": TerminalKey.f1},
    {"name": "F2", "key": TerminalKey.f2},
    {"name": "F3", "key": TerminalKey.f3},
    {"name": "F4", "key": TerminalKey.f4},
    {"name": "F5", "key": TerminalKey.f5},
    {"name": "F6", "key": TerminalKey.f6},
    {"name": "F7", "key": TerminalKey.f7},
    {"name": "F8", "key": TerminalKey.f8},
    {"name": "F9", "key": TerminalKey.f9},
    {"name": "F10", "key": TerminalKey.f10},
    {"name": "F11", "key": TerminalKey.f11},
    {"name": "F12", "key": TerminalKey.f12},
  ];

  static const String boot = "\$DATA_DIR/bin/proot -H --change-id=1000:1000 --pwd=/home/tiny --rootfs=\$CONTAINER_DIR --mount=/system --mount=/apex --mount=/sys --mount=/data --kill-on-exit --mount=/storage --sysvipc -L --link2symlink --mount=/proc --mount=/dev --mount=\$CONTAINER_DIR/tmp:/dev/shm --mount=/dev/urandom:/dev/random --mount=/proc/self/fd:/dev/fd --mount=/proc/self/fd/0:/dev/stdin --mount=/proc/self/fd/1:/dev/stdout --mount=/proc/self/fd/2:/dev/stderr --mount=/dev/null:/dev/tty0 --mount=/dev/null:/proc/sys/kernel/cap_last_cap --mount=/storage/self/primary:/media/sd --mount=\$DATA_DIR/share:/home/tiny/公共 --mount=\$DATA_DIR/tiny:/home/tiny/.local/share/tiny --mount=/storage/self/primary/Fonts:/usr/share/fonts/wpsm --mount=/storage/self/primary/AppFiles/Fonts:/usr/share/fonts/yozom --mount=/system/fonts:/usr/share/fonts/androidm --mount=/storage/self/primary/Pictures:/home/tiny/图片 --mount=/storage/self/primary/Music:/home/tiny/音乐 --mount=/storage/self/primary/Movies:/home/tiny/视频 --mount=/storage/self/primary/Download:/home/tiny/下载 --mount=/storage/self/primary/DCIM:/home/tiny/照片 --mount=/storage/self/primary/Documents:/home/tiny/文档 --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/.tmoe-container.stat:/proc/stat --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/.tmoe-container.version:/proc/version --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/bus:/proc/bus --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/buddyinfo:/proc/buddyinfo --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/cgroups:/proc/cgroups --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/consoles:/proc/consoles --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/crypto:/proc/crypto --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/devices:/proc/devices --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/diskstats:/proc/diskstats --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/execdomains:/proc/execdomains --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/fb:/proc/fb --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/filesystems:/proc/filesystems --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/interrupts:/proc/interrupts --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/iomem:/proc/iomem --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/ioports:/proc/ioports --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/kallsyms:/proc/kallsyms --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/keys:/proc/keys --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/key-users:/proc/key-users --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/kpageflags:/proc/kpageflags --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/loadavg:/proc/loadavg --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/locks:/proc/locks --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/misc:/proc/misc --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/modules:/proc/modules --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/pagetypeinfo:/proc/pagetypeinfo --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/partitions:/proc/partitions --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/sched_debug:/proc/sched_debug --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/softirqs:/proc/softirqs --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/timer_list:/proc/timer_list --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/uptime:/proc/uptime --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/vmallocinfo:/proc/vmallocinfo --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/vmstat:/proc/vmstat --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/zoneinfo:/proc/zoneinfo \$EXTRA_MOUNT /usr/bin/env -i HOSTNAME=TINY HOME=/home/tiny USER=tiny TERM=xterm-256color SDL_IM_MODULE=fcitx XMODIFIERS=@im=fcitx QT_IM_MODULE=fcitx GTK_IM_MODULE=fcitx TMOE_CHROOT=false TMOE_PROOT=true TMPDIR=/tmp MOZ_FAKE_NO_SANDBOX=1 QTWEBENGINE_DISABLE_SANDBOX=1 DISPLAY=:4 PULSE_SERVER=tcp:127.0.0.1:4718 LANG=zh_CN.UTF-8 SHELL=/bin/bash PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games \$EXTRA_OPT /bin/bash -l";

  static final ButtonStyle commandButtonStyle = OutlinedButton.styleFrom(
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    minimumSize: const Size(0, 0),
    padding: const EdgeInsets.fromLTRB(4, 2, 4, 2)
  );

  static final ButtonStyle controlButtonStyle = OutlinedButton.styleFrom(
    textStyle: const TextStyle(fontWeight: FontWeight.w400),
    side: const BorderSide(color: Color(0x1F000000)),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    minimumSize: const Size(0, 0),
    padding: const EdgeInsets.fromLTRB(8, 4, 8, 4)
  );

  static const MethodChannel androidChannel = MethodChannel("android");
}

// ========== G CLASS (UPDATED) ==========
class G {
  static late final String dataPath;
  static Pty? audioPty;
  static late WebViewController controller;
  static late BuildContext homePageStateContext;
  static late int currentContainer;
  static late Map<int, TermPty> termPtys;
  static late VirtualKeyboard keyboard;
  static bool maybeCtrlJ = false;
  static ValueNotifier<double> termFontScale = ValueNotifier(1.0);
  static bool isStreamServerStarted = false;
  static bool isStreaming = false;
  static String streamingOutput = "";
  static late Pty streamServerPty;
  static ValueNotifier<int> pageIndex = ValueNotifier(0);
  static ValueNotifier<bool> terminalPageChange = ValueNotifier(true);
  static ValueNotifier<bool> bootTextChange = ValueNotifier(true);
  static ValueNotifier<String> updateText = ValueNotifier("XoDos");
  static String postCommand = "";
  static bool wasAvncEnabled = false;
  static bool wasX11Enabled = false;
  static late SharedPreferences prefs;
}

// ========== WORKFLOW CLASS (CRITICAL - WAS MISSING) ==========
class Workflow {
  static Future<void> grantPermissions() async {
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }

  static Future<void> setupBootstrap() async {
    Util.createDirFromString("${G.dataPath}/share");
    Util.createDirFromString("${G.dataPath}/bin");
    Util.createDirFromString("${G.dataPath}/lib");
    Util.createDirFromString("${G.dataPath}/tmp");
    Util.createDirFromString("${G.dataPath}/proot_tmp");
    Util.createDirFromString("${G.dataPath}/pulseaudio_tmp");

    await Util.copyAsset("assets/assets.zip", "${G.dataPath}/assets.zip");
    await Util.copyAsset("assets/patch.tar.gz", "${G.dataPath}/patch.tar.gz");

    await Util.execute("""
export DATA_DIR=${G.dataPath}
export LD_LIBRARY_PATH=\$DATA_DIR/lib
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
chmod -R +x libexec/proot/*
chmod 1777 tmp
\$DATA_DIR/bin/tar zxf patch.tar.gz
\$DATA_DIR/bin/busybox rm -rf assets.zip patch.tar.gz
""");
  }

  static Future<void> initForFirstTime() async {
    G.updateText.value = "Installing boot package...";
    await setupBootstrap();
    
    G.updateText.value = "Copying container system...";
    Util.createDirFromString("${G.dataPath}/containers/0/.l2s");
    
    for (String name in jsonDecode(await rootBundle.loadString('AssetManifest.json')).keys.where((String e) => e.startsWith("assets/xa")).map((String e) => e.split("/").last).toList()) {
      await Util.copyAsset("assets/$name", "${G.dataPath}/$name");
    }
    
    G.updateText.value = "Installing container system...";
    await Util.execute("""
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
\$DATA_DIR/bin/proot --link2symlink sh -c "cat xa* | \$DATA_DIR/bin/tar x -J --delay-directory-restore --preserve-permissions -v -C containers/0"

chmod u+rw "\$CONTAINER_DIR/etc/passwd" "\$CONTAINER_DIR/etc/shadow" "\$CONTAINER_DIR/etc/group" "\$CONTAINER_DIR/etc/gshadow"
echo "aid_\$(id -un):x:\$(id -u):\$(id -g):Termux:/:/sbin/nologin" >> "\$CONTAINER_DIR/etc/passwd"
echo "aid_\$(id -un):*:18446:0:99999:7:::" >> "\$CONTAINER_DIR/etc/shadow"
id -Gn | tr ' ' '\\\\n' > tmp1
id -G | tr ' ' '\\\\n' > tmp2
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
    
    await G.prefs.setStringList("containersInfo", ["""{
"name":"Debian Bookworm",
"boot":"${D.boot}",
"vnc":"startnovnc &",
"vncUrl":"http://localhost:36082/vnc.html?host=localhost&port=36082&autoconnect=true&resize=remote&password=12345678",
"commands":${jsonEncode(D.commands)}
}"""]);
    
    G.updateText.value = "Installation complete!";
  }

  static Future<void> initData() async {
    G.dataPath = (await getApplicationSupportDirectory()).path;
    G.termPtys = {};
    G.keyboard = VirtualKeyboard(defaultInputHandler);
    G.prefs = await SharedPreferences.getInstance();
    
    await Util.execute("ln -sf ${await D.androidChannel.invokeMethod("getNativeLibraryPath", {})} ${G.dataPath}/applib");

    if (!G.prefs.containsKey("defaultContainer")) {
      await initForFirstTime();
      final s = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;
      final String w = (max(s.width, s.height) * 0.75).round().toString();
      final String h = (min(s.width, s.height) * 0.75).round().toString();
      G.postCommand = """sed -i -E "s@(geometry)=.*@\\1=${w}x${h}@" /etc/tigervnc/vncserver-config-tmoe
sed -i -E "s@^(VNC_RESOLUTION)=.*@\\1=${w}x${h}@" \$(command -v startvnc)""";
      
      if (Localizations.localeOf(G.homePageStateContext).languageCode != 'zh') {
        G.postCommand += "\nlocaledef -c -i en_US -f UTF-8 en_US.UTF-8";
        await G.prefs.setBool("isTerminalWriteEnabled", true);
        await G.prefs.setBool("isTerminalCommandsEnabled", true);
        await G.prefs.setBool("isStickyKey", false);
        await G.prefs.setBool("wakelock", true);
      }
      await G.prefs.setBool("getifaddrsBridge", (await DeviceInfoPlugin().androidInfo).version.sdkInt >= 31);
    }
    
    G.currentContainer = Util.getGlobal("defaultContainer") as int;

    if (Util.getGlobal("reinstallBootstrap")) {
      G.updateText.value = "Reinstalling boot package...";
      await setupBootstrap();
      G.prefs.setBool("reinstallBootstrap", false);
    }

    if (Util.getGlobal("useX11")) {
      G.wasX11Enabled = true;
      launchXServer();
    } else if (Util.getGlobal("useAvnc")) {
      G.wasAvncEnabled = true;
    }

    G.termFontScale.value = Util.getGlobal("termFontScale") as double;
    G.controller = WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted);
    WakelockPlus.toggle(enable: Util.getGlobal("wakelock"));
  }

  static Future<void> initTerminalForCurrent() async {
    if (!G.termPtys.containsKey(G.currentContainer)) {
      G.termPtys[G.currentContainer] = TermPty();
    }
  }

  static Future<void> setupAudio() async {
    G.audioPty?.kill();
    G.audioPty = Pty.start("/system/bin/sh");
    G.audioPty!.write(const Utf8Encoder().convert("""
export DATA_DIR=${G.dataPath}
export PATH=\$DATA_DIR/bin:\$PATH
export LD_LIBRARY_PATH=\$DATA_DIR/lib
\$DATA_DIR/bin/busybox sed "s/4713/${Util.getGlobal("defaultAudioPort") as int}/g" \$DATA_DIR/bin/pulseaudio.conf > \$DATA_DIR/bin/pulseaudio.conf.tmp
rm -rf \$DATA_DIR/pulseaudio_tmp/*
TMPDIR=\$DATA_DIR/pulseaudio_tmp HOME=\$DATA_DIR/pulseaudio_tmp XDG_CONFIG_HOME=\$DATA_DIR/pulseaudio_tmp LD_LIBRARY_PATH=\$DATA_DIR/bin:\$LD_LIBRARY_PATH \$DATA_DIR/bin/pulseaudio -F \$DATA_DIR/bin/pulseaudio.conf.tmp
exit
"""));
    await G.audioPty?.exitCode;
  }

  static Future<void> launchCurrentContainer() async {
    String extraMount = "";
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
    
    if (Util.getGlobal("virgl")) {
      Util.execute("""
export DATA_DIR=${G.dataPath}
export PATH=\$DATA_DIR/bin:\$PATH
export LD_LIBRARY_PATH=\$DATA_DIR/lib
export CONTAINER_DIR=\$DATA_DIR/containers/${G.currentContainer}
${G.dataPath}/bin/virgl_test_server ${Util.getGlobal("defaultVirglCommand")}""");
      extraOpt += "${Util.getGlobal("defaultVirglOpt")} ";
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
    
    Util.termWrite("""
export DATA_DIR=${G.dataPath}
export PATH=\$DATA_DIR/bin:\$PATH
export LD_LIBRARY_PATH=\$DATA_DIR/lib
export CONTAINER_DIR=\$DATA_DIR/containers/${G.currentContainer}
export EXTRA_MOUNT="$extraMount"
export EXTRA_OPT="$extraOpt"
cd \$DATA_DIR
export PROOT_TMP_DIR=\$DATA_DIR/proot_tmp
export PROOT_LOADER=\$DATA_DIR/applib/libproot-loader.so
export PROOT_LOADER_32=\$DATA_DIR/applib/libproot-loader32.so
${Util.getCurrentProp("boot")}
${G.postCommand}
clear""");
  }

  static Future<void> launchGUIBackend() async {
    Util.termWrite((Util.getGlobal("autoLaunchVnc") as bool) ? ((Util.getGlobal("useX11") as bool) ? """mkdir -p "\$HOME/.vnc" && bash /etc/X11/xinit/Xsession &> "\$HOME/.vnc/x.log" &""" : Util.getCurrentProp("vnc")) : "");
    Util.termWrite("clear");
  }

  static Future<void> waitForConnection() async {
    await retry(
      () => http.get(Uri.parse(Util.getCurrentProp("vncUrl"))).timeout(const Duration(milliseconds: 250)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
  }

  static Future<void> launchBrowser() async {
    G.controller.loadRequest(Uri.parse(Util.getCurrentProp("vncUrl")));
    Navigator.push(G.homePageStateContext, MaterialPageRoute(builder: (context) {
      return Focus(
        onKeyEvent: (node, event) {
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
        child: GestureDetector(onSecondaryTap: () {}, child: WebViewWidget(controller: G.controller))
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
    await grantPermissions();
    await initData();
    await initTerminalForCurrent();
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
  }
}

// ========== COLOR CONSTANTS (ADDED FOR UI) ==========
class AppColors {
  static const Color surfaceDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color primaryPurple = Color(0xFFBB86FC);
  static const Color textPrimary = Colors.white;
  static const Color divider = Color(0x1FFFFFFF);
}

// ========== EXTRACTION MANAGER (SIMPLIFIED) ==========
class ExtractionManager {
  static Future<double> getExtractionProgressT() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('extractionProgressT') ?? 0.0;
  }

  static Future<void> setExtractionProgressT(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('extractionProgressT', value);
  }

  static Future<bool> isExtractionComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('extractionComplete') ?? false;
  }

  static Future<void> setExtractionComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('extractionComplete', true);
  }
}

// ========== MAIN FUNCTION ==========
void main() {
  runApp(const MyApp());
}

// ========== MYAPP CLASS ==========
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

// ========== RTL WRAPPER ==========
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

// ========== ASPECT RATIO MAX 1:1 ==========
class AspectRatioMax1To1 extends StatelessWidget {
  final Widget child;

  const AspectRatioMax1To1({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final s = MediaQuery.of(context).size;
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

// ========== FAKE LOADING STATUS ==========
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
    final savedProgressT = await ExtractionManager.getExtractionProgressT();
    final savedComplete = await ExtractionManager.isExtractionComplete();
    
    if (mounted) {
      setState(() {
        _progressT = savedProgressT;
        _extractionComplete = savedComplete;
      });
    }

    if (!_extractionComplete) {
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
        if (_extractionComplete) {
          timer.cancel();
          return;
        }

        setState(() {
          _progressT += 0.1;
        });
        
        await ExtractionManager.setExtractionProgressT(_progressT);
        
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

// ========== SETTING PAGE ==========
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
      },
      children: [
        ExpansionPanel(
          isExpanded: _expandState[0],
          headerBuilder: ((context, isExpanded) {
            return ListTile(title: Text(AppLocalizations.of(context)!.advancedSettings), subtitle: Text(AppLocalizations.of(context)!.restartAfterChange));
          }), 
          body: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
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
            TextFormField(maxLines: null, initialValue: Util.getCurrentProp("name") as String, decoration: InputDecoration(border: OutlineInputBorder(), labelText: AppLocalizations.of(context)!.containerName), onChanged: (value) async {
              await Util.setCurrentProp("name", value);
            }),
            const SizedBox.square(dimension: 8),
            ValueListenableBuilder(valueListenable: G.bootTextChange, builder:(context, v, child) {
              return TextFormField(maxLines: null, initialValue: Util.getCurrentProp("boot") as String, decoration: InputDecoration(border: OutlineInputBorder(), labelText: AppLocalizations.of(context)!.startupCommand), onChanged: (value) async {
                await Util.setCurrentProp("boot", value);
              });
            }),
            const SizedBox.square(dimension: 8),
            TextFormField(maxLines: null, initialValue: Util.getCurrentProp("vnc") as String, decoration: InputDecoration(border: OutlineInputBorder(), labelText: AppLocalizations.of(context)!.vncStartupCommand), onChanged: (value) async {
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
            TextFormField(maxLines: null, initialValue: Util.getCurrentProp("vncUrl") as String, decoration: InputDecoration(border: OutlineInputBorder(), labelText: AppLocalizations.of(context)!.webRedirectUrl), onChanged: (value) async {
              await Util.setCurrentProp("vncUrl", value);
            }),
            const SizedBox.square(dimension: 8),
            TextFormField(maxLines: null, initialValue: Util.getCurrentProp("vncUri") as String, decoration: InputDecoration(border: OutlineInputBorder(), labelText: AppLocalizations.of(context)!.vncLink), onChanged: (value) async {
              await Util.setCurrentProp("vncUri", value);
            }),
            const SizedBox.square(dimension: 8),
          ]))),
        ExpansionPanel(
          isExpanded: _expandState[1],
          headerBuilder: ((context, isExpanded) {
            return ListTile(title: Text(AppLocalizations.of(context)!.globalSettings), subtitle: Text(AppLocalizations.of(context)!.enableTerminalEditing));
          }), 
          body: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
            TextFormField(autovalidateMode: AutovalidateMode.onUserInteraction, initialValue: (Util.getGlobal("termMaxLines") as int).toString(), decoration: InputDecoration(border: OutlineInputBorder(), labelText: AppLocalizations.of(context)!.terminalMaxLines),
              keyboardType: TextInputType.number,
              validator: (value) {
                return Util.validateBetween(value, 1024, 2147483647, () async {
                  await G.prefs.setInt("termMaxLines", int.parse(value!));
                });
              }),
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
            }),
            const SizedBox.square(dimension: 8),
            SwitchListTile(title: Text(AppLocalizations.of(context)!.enableTerminalKeypad), value: Util.getGlobal("isTerminalCommandsEnabled") as bool, onChanged:(value) {
              G.prefs.setBool("isTerminalCommandsEnabled", value);
              setState(() {
                G.terminalPageChange.value = !G.terminalPageChange.value;
              });
            }),
            const SizedBox.square(dimension: 8),
            SwitchListTile(title: Text(AppLocalizations.of(context)!.terminalStickyKeys), value: Util.getGlobal("isStickyKey") as bool, onChanged:(value) {
              G.prefs.setBool("isStickyKey", value);
              setState(() {});
            }),
            const SizedBox.square(dimension: 8),
            SwitchListTile(title: Text(AppLocalizations.of(context)!.keepScreenOn), value: Util.getGlobal("wakelock") as bool, onChanged:(value) {
              G.prefs.setBool("wakelock", value);
              WakelockPlus.toggle(enable: value);
              setState(() {});
            }),
            const SizedBox.square(dimension: 8),
            const Divider(height: 2, indent: 8, endIndent: 8),
            const SizedBox.square(dimension: 16),
            Text(AppLocalizations.of(context)!.restartRequiredHint),
            const SizedBox.square(dimension: 8),
            SwitchListTile(title: Text(AppLocalizations.of(context)!.startWithGUI), value: Util.getGlobal("autoLaunchVnc") as bool, onChanged:(value) {
              G.prefs.setBool("autoLaunchVnc", value);
              setState(() {});
            }),
            const SizedBox.square(dimension: 8),
            SwitchListTile(title: Text(AppLocalizations.of(context)!.reinstallBootPackage), value: Util.getGlobal("reinstallBootstrap") as bool, onChanged:(value) {
              G.prefs.setBool("reinstallBootstrap", value);
              setState(() {});
            }),
            const SizedBox.square(dimension: 8),
            SwitchListTile(title: Text(AppLocalizations.of(context)!.getifaddrsBridge), subtitle: Text(AppLocalizations.of(context)!.fixGetifaddrsPermission), value: Util.getGlobal("getifaddrsBridge") as bool, onChanged:(value) {
              G.prefs.setBool("getifaddrsBridge", value);
              setState(() {});
            }),
            const SizedBox.square(dimension: 8),
            SwitchListTile(title: Text(AppLocalizations.of(context)!.fakeUOSSystem), value: Util.getGlobal("uos") as bool, onChanged:(value) {
              G.prefs.setBool("uos", value);
              setState(() {});
            }),
          ]))),
        ExpansionPanel(
          isExpanded: _expandState[2],
          headerBuilder: ((context, isExpanded) {
            return ListTile(title: Text(AppLocalizations.of(context)!.displaySettings));
          }), 
          body: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
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
              _avncScaleFactor += value ? 0.5 : -0.5;
              _avncScaleFactor = _avncScaleFactor.clamp(-1, 1);
              G.prefs.setDouble("avncScaleFactor", _avncScaleFactor);
              X11Flutter.setX11ScaleFactor(value ? 0.5 : 2.0);
              setState(() {});
            }),
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
            }),
            const SizedBox.square(dimension: 8),
            SwitchListTile(title: Text(AppLocalizations.of(context)!.avncScreenResize), value: Util.getGlobal("avncResizeDesktop") as bool, onChanged:(value) {
              G.prefs.setBool("avncResizeDesktop", value);
              setState(() {});
            }),
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
            }),
            const SizedBox.square(dimension: 16),
          ]))),
        ExpansionPanel(
          isExpanded: _expandState[3],
          headerBuilder: ((context, isExpanded) {
            return ListTile(title: Text(AppLocalizations.of(context)!.fileAccess));
          }), 
          body: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
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
                launchUrl(Uri.parse("https://github.com/xodiosx/XoDos2/fileaccess.md"), mode: LaunchMode.externalApplication);
              }),
            ]),
            const SizedBox.square(dimension: 16),
          ]))),
        ExpansionPanel(
          isExpanded: _expandState[4],
          headerBuilder: ((context, isExpanded) {
            return ListTile(title: Text(AppLocalizations.of(context)!.graphicsAcceleration), subtitle: Text(AppLocalizations.of(context)!.experimentalFeature));
          }), 
          body: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
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
            }),
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
            }),
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
            }),
            const SizedBox.square(dimension: 16),
          ]))),
        ExpansionPanel(
          isExpanded: _expandState[5],
          headerBuilder: ((context, isExpanded) {
            return ListTile(title: Text(AppLocalizations.of(context)!.windowsAppSupport), subtitle: Text(AppLocalizations.of(context)!.experimentalFeature));
          }), 
          body: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
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
            }),
          ]))),
      ],
    );
  }
}

// ========== INFO PAGE ==========
class InfoPage extends StatefulWidget {
  final bool openFirstInfo;

  const InfoPage({super.key, this.openFirstInfo = false});

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

// ========== LOADING PAGE ==========
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

// ========== FORCE SCALE GESTURE RECOGNIZER ==========
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

// ========== TERMINAL PAGE ==========
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
                // FIXED: Use TerminalView WITHOUT controller parameter
                return TerminalView(
                  G.termPtys[G.currentContainer]!.terminal, 
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
            'Start Desktop',
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
    Util.termWrite('stopvnc');
    Util.termWrite('exit');
    Util.termWrite('exit');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Container stopped. Starting fresh terminal...'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _copyTerminalText() async {
    try {
      // Note: TerminalView doesn't have a controller in this version
      // You'll need to implement text selection differently
      // For now, we'll just copy the visible text
      final terminal = G.termPtys[G.currentContainer]!.terminal;
      final buffer = terminal.buffer;
      String text = "";
      
      // Extract text from terminal buffer
      for (int i = 0; i < buffer.lines.length; i++) {
        text += buffer.lines[i].content + "\n";
      }
      
      if (text.isNotEmpty) {
        await Clipboard.setData(ClipboardData(text: text));
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terminal text copied to clipboard'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No text to copy'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to copy text'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _pasteToTerminal() async {
    try {
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

// ========== FAST COMMANDS ==========
class FastCommands extends StatefulWidget {
  const FastCommands({super.key});

  @override
  State<FastCommands> createState() => _FastCommandsState();
}

class _FastCommandsState extends State<FastCommands> {
  @override
  Widget build(BuildContext context) {
    List<dynamic> commands = Util.getCurrentProp("commands") ?? [];
    
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4.0,
      runSpacing: 4.0,
      children: [
        ...commands.asMap().entries.map<Widget>((e) {
          return OutlinedButton(
            style: D.commandButtonStyle,
            child: Text(e.value["name"]!),
            onPressed: () {
              Util.termWrite(e.value["command"]!);
              G.pageIndex.value = 0;
            },
            onLongPress: () {
              String name = e.value["name"]!;
              String command = e.value["command"]!;
              showDialog(context: context, builder: (context) {
                return AlertDialog(
                  title: Text(AppLocalizations.of(context)!.commandEdit),
                  content: SingleChildScrollView(child: Column(children: [
                    TextFormField(
                      initialValue: name,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: AppLocalizations.of(context)!.commandName
                      ),
                      onChanged: (value) {
                        name = value;
                      }
                    ),
                    const SizedBox.square(dimension: 8),
                    TextFormField(
                      maxLines: null,
                      initialValue: command,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: AppLocalizations.of(context)!.commandContent
                      ),
                      onChanged: (value) {
                        command = value;
                      }
                    ),
                  ])),
                  actions: [
                    TextButton(
                      onPressed:() async {
                        List<dynamic> newCommands = List.from(commands);
                        newCommands.removeAt(e.key);
                        await Util.setCurrentProp("commands", newCommands);
                        setState(() {});
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                      },
                      child: Text(AppLocalizations.of(context)!.deleteItem)
                    ),
                    TextButton(
                      onPressed:() {
                        Navigator.of(context).pop();
                      },
                      child: Text(AppLocalizations.of(context)!.cancel)
                    ),
                    TextButton(
                      onPressed:() async {
                        List<dynamic> newCommands = List.from(commands);
                        newCommands[e.key] = {"name": name, "command": command};
                        await Util.setCurrentProp("commands", newCommands);
                        setState(() {});
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                      },
                      child: Text(AppLocalizations.of(context)!.save)
                    ),
                  ]
                );
              });
            },
          );
        }).toList(),
        OutlinedButton(
          style: D.commandButtonStyle,
          onPressed:() {
            String name = "";
            String command = "";
            showDialog(context: context, builder: (context) {
              return AlertDialog(
                title: Text(AppLocalizations.of(context)!.commandEdit),
                content: SingleChildScrollView(child: Column(children: [
                  TextFormField(
                    initialValue: name,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.commandName
                    ),
                    onChanged: (value) {
                      name = value;
                    }
                  ),
                  const SizedBox.square(dimension: 8),
                  TextFormField(
                    maxLines: null,
                    initialValue: command,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.commandContent
                    ),
                    onChanged: (value) {
                      command = value;
                    }
                  ),
                ])),
                actions: [
                  TextButton(
                    onPressed:() {
                      launchUrl(Uri.parse("https://github.com/xodiosx/XoDos2/extracommand.md"), mode: LaunchMode.externalApplication);
                    },
                    child: Text(AppLocalizations.of(context)!.more)
                  ),
                  TextButton(
                    onPressed:() {
                      Navigator.of(context).pop();
                    },
                    child: Text(AppLocalizations.of(context)!.cancel)
                  ),
                  TextButton(
                    onPressed:() async {
                      List<dynamic> newCommands = List.from(commands);
                      newCommands.add({"name": name, "command": command});
                      await Util.setCurrentProp("commands", newCommands);
                      setState(() {});
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                    },
                    child: Text(AppLocalizations.of(context)!.add)
                  ),
                ]
              );
            });
          },
          onLongPress: () {
            showDialog(context: context, builder: (context) {
              return AlertDialog(
                title: Text(AppLocalizations.of(context)!.resetCommand),
                content: Text(AppLocalizations.of(context)!.confirmResetAllCommands),
                actions: [
                  TextButton(
                    onPressed:() {
                      Navigator.of(context).pop();
                    },
                    child: Text(AppLocalizations.of(context)!.cancel)
                  ),
                  TextButton(
                    onPressed:() async {
                      await Util.setCurrentProp("commands", Localizations.localeOf(context).languageCode == 'zh' ? D.commands : D.commands4En);
                      setState(() {});
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                    },
                    child: Text(AppLocalizations.of(context)!.yes)
                  ),
                ]
              );
            });
          },
          child: Text(AppLocalizations.of(context)!.addShortcutCommand)
        )
      ]
    );
  }
}

// ========== MY HOME PAGE ==========
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
          title: Text(isLoadingComplete ? Util.getCurrentProp("name") as String : widget.title),
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
                  NavigationDestination(
                    icon: const Icon(Icons.monitor),
                    label: AppLocalizations.of(context)!.terminal
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.video_settings),
                    label: AppLocalizations.of(context)!.control
                  ),
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