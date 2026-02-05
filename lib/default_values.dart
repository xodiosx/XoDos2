// default_values.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xterm/xterm.dart';
import 'constants.dart';  // For AppButtonStyles
import 'core_classes.dart';


class D {
  // Common links
  static const links = [
    {"name": "projectUrl", "value": "https://github.com/xodiosx/XoDos2"},
    {"name": "issueUrl", "value": "https://github.com/xodiosx/XoDos2/issues"},
    {"name": "faqUrl", "value": "https://github.com/xodiosx/XoDos2/blob/main/faq.md"},
    {"name": "solutionUrl", "value": "https://github.com/xodiosx/XoDos2/blob/main/fix.md"},
    {"name": "discussionUrl", "value": "https://t.me/xodemulatorr"},
  ];

  // Default quick commands
  static const commands = [
    {"name":"检查更新并升级", "command":"sudo dpkg --configure -a && sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y"},
    {"name":"显示系统信息", "command":"neofetch -L && neofetch --off"},
    {"name":"清屏", "command":"clear"},
    {"name":"中断任务", "command":"\x03"},
    {"name":"安装图形软件 Krita", "command":"sudo apt update && sudo apt install -y krita krita-l10n"},
    {"name":"卸载 Krita", "command":"sudo apt autoremove --purge -y krita krita-l10n"},
    {"name":"安装视频编辑软件 Kdenlive", "command":"sudo apt update && sudo apt install -y kdenlive"},
    {"name":"卸载 Kdenlive", "command":"sudo apt autoremove --purge -y kdenlive"},
    {"name":"安装科学计算软件 Octave", "command":"sudo apt update && sudo apt install -y octave"},
    {"name":"卸载 Octave", "command":"sudo apt autoremove --purge -y octave"},
    {"name":"安装 WPS", "command":r"""cat << 'EOF' | sh && sudo dpkg --configure -a && sudo apt update && sudo apt install -y /tmp/wps.deb
wget https://github.com/xodiosx/XoDos2/releases/download/v1.0.1/wps-office_11.1.0.11720_arm64.deb -O /tmp/wps.deb
EOF
rm /tmp/wps.deb"""},
    {"name":"卸载 WPS", "command":"sudo apt autoremove --purge -y wps-office"},
    {"name":"安装 Legcord (轻量级 Discord)", "command":r"""cat << 'EOF' | sh && sudo dpkg --configure -a && sudo apt update && sudo apt install -y /tmp/legcord.deb
wget https://github.com/Legcord/Legcord/releases/download/v1.2.1/Legcord-1.2.1-linux-arm64.deb -O /tmp/legcord.deb
EOF
rm /tmp/legcord.deb"""},
    {"name":"卸载 Legcord", "command":"sudo apt autoremove --purge -y legcord"},
    {"name":"安装 Dorion (Discord Lite)", "command":r"""cat << 'EOF' | sh && sudo dpkg --configure -a && sudo apt update && sudo apt install -y /tmp/dorion.deb
wget https://github.com/xodiosx/XoDos2/releases/download/discord-lite-1.0.0/Dorion_6.12.0_arm64.deb -O /tmp/dorion.deb
EOF
rm /tmp/dorion.deb"""},
    {"name":"卸载 Dorion", "command":"sudo apt autoremove --purge -y dorion"},
    {"name":"安装 WhatsApp", "command":r"""cat << 'EOF' | sh && sudo dpkg --configure -a && sudo apt update && sudo apt install -y /tmp/whatsapp.deb
wget https://github.com/cycool29/whatsapp-for-linux/releases/download/47.0/whatsapp_47.0_arm64.deb -O /tmp/whatsapp.deb
EOF
rm /tmp/whatsapp.deb"""},
    {"name":"卸载 WhatsApp", "command":"sudo apt autoremove --purge -y whatsapp"},
    {"name":"安装 Telegram Desktop", "command":"sudo apt update && sudo apt install -y telegram-desktop"},
    {"name":"卸载 Telegram Desktop", "command":"sudo apt autoremove --purge -y telegram-desktop"},
    {"name":"安装 CAJViewer", "command":"wget https://download.cnki.net/net.cnki.cajviewer_1.3.20-1_arm64.deb -O /tmp/caj.deb && sudo apt update && sudo apt install -y /tmp/caj.deb && bash /home/tiny/.local/share/tiny/caj/postinst; rm /tmp/caj.deb"},
    {"name":"卸载 CAJViewer", "command":"sudo apt autoremove --purge -y net.cnki.cajviewer && bash /home/tiny/.local/share/tiny/caj/postrm"},
    {"name":"安装 EdrawMax", "command":"wget https://cc-download.wondershare.cc/business/prd/edrawmax_13.1.0-1_arm64_binner.deb -O /tmp/edraw.deb && sudo apt update && sudo apt install -y /tmp/edraw.deb && bash /home/tiny/.local/share/tiny/edraw/postinst; rm /tmp/edraw.deb"},
    {"name":"卸载 EdrawMax", "command":"sudo apt autoremove --purge -y edrawmax libldap-2.4-2"},
    {"name":"安装 QQ", "command":"""wget \$(curl -s https://im.qq.com/rainbow/linuxQQDownload | grep -oP '"armDownloadUrl":{[^}]*"deb":"\\K[^"]+') -O /tmp/qq.deb && sudo apt update && sudo apt install -y /tmp/qq.deb && sed -i 's#Exec=/opt/QQ/qq %U#Exec=/opt/QQ/qq --no-sandbox %U#g' /usr/share/applications/qq.desktop; rm /tmp/qq.deb"""},
    {"name":"卸载 QQ", "command":"sudo apt autoremove --purge -y linuxqq"},
    {"name":"安装 WeChat", "command":"wget https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_arm64.deb -O /tmp/wechat.deb && sudo apt update && sudo apt install -y /tmp/wechat.deb && echo 'Installation complete. If you only use WeChat for file transfer, consider using a file manager that supports SAF (e.g., Material Files) to directly access all files in xodos.'; rm /tmp/wechat.deb"},
    {"name":"卸载 WeChat", "command":"sudo apt autoremove --purge -y wechat"},
    {"name":"安装 DingTalk", "command":"""wget \$(curl -sw %{redirect_url} https://www.dingtalk.com/win/d/qd=linux_arm64) -O /tmp/dingtalk.deb && sudo apt update && sudo apt install -y /tmp/dingtalk.deb libglut3.12 libglu1-mesa && sed -i 's#\\./com.alibabainc.dingtalk#\\./com.alibabainc.dingtalk --no-sandbox#g' /opt/apps/com.alibabainc.dingtalk/files/Elevator.sh; rm /tmp/dingtalk.deb"""},
    {"name":"卸载 DingTalk", "command":"sudo apt autoremove --purge -y com.alibabainc.dingtalk"},
    {"name":"启用回收站", "command":"sudo apt update && sudo apt install -y gvfs && echo '安装完成，重启应用以使用回收站。'"},
    {"name":"清理包管理器缓存", "command":"sudo apt clean"},
    {"name":"关机", "command":"stopvnc\nexit\nexit"},
    {"name":"matrix", "command":"timeout 8 cmatrix"}
  ];

  // Default quick commands, English version
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
wget https://github.com/xodiosx/XoDos2/releases/download/v1.0.1/wps-office_11.1.0.11720_arm64.deb -O /tmp/wps.deb
EOF
rm /tmp/wps.deb"""},
    {"name":"Uninstall WPS", "command":"sudo apt autoremove --purge -y wps-office"},
    {"name":"Install Legcord (Lightweight Discord)", "command":r"""cat << 'EOF' | sh && sudo dpkg --configure -a && sudo apt update && sudo apt install -y /tmp/legcord.deb
wget https://github.com/Legcord/Legcord/releases/download/v1.2.1/Legcord-1.2.1-linux-arm64.deb -O /tmp/legcord.deb
EOF
rm /tmp/legcord.deb"""},
    {"name":"Uninstall Legcord", "command":"sudo apt autoremove --purge -y legcord"},
    {"name":"Install Dorion (Discord Lite)", "command":r"""cat << 'EOF' | sh && sudo dpkg --configure -a && sudo apt update && sudo apt install -y /tmp/dorion.deb
wget https://github.com/xodiosx/XoDos2/releases/download/discord-lite-1.0.0/Dorion_6.12.0_arm64.deb -O /tmp/dorion.deb
EOF
rm /tmp/dorion.deb"""},
    {"name":"Uninstall Dorion", "command":"sudo apt autoremove --purge -y dorion"},
    {"name":"Install WhatsApp", "command":r"""cat << 'EOF' | sh && sudo dpkg --configure -a && sudo apt update && sudo apt install -y /tmp/whatsapp.deb
wget https://github.com/cycool29/whatsapp-for-linux/releases/download/47.0/whatsapp_47.0_arm64.deb -O /tmp/whatsapp.deb
EOF
rm /tmp/whatsapp.deb"""},
    {"name":"Uninstall WhatsApp", "command":"sudo apt autoremove --purge -y whatsapp"},
    {"name":"Install Telegram Desktop", "command":"sudo apt update && sudo apt install -y telegram-desktop"},
    {"name":"Uninstall Telegram Desktop", "command":"sudo apt autoremove --purge -y telegram-desktop"},
    {"name":"Install EdrawMax", "command":"""wget https://cc-download.wondershare.cc/business/prd/edrawmax_13.1.0-1_arm64_binner.deb -O /tmp/edraw.deb && sudo apt update && sudo apt install -y /tmp/edraw.deb && bash /home/tiny/.local/share/tiny/edraw/postinst && sudo sed -i 's/<Language V="cn"\\/>/<Language V="en"\\/>/g' /opt/apps/edrawmax/config/settings.xml; rm /tmp/edraw.deb"""},
    {"name":"Uninstall EdrawMax", "command":"sudo apt autoremove --purge -y edrawmax libldap-2.4-2"},
    {"name":"Enable Recycle Bin", "command":"sudo apt update && sudo apt install -y gvfs && echo 'Restart the app to use Recycle Bin.'"},
    {"name":"Clean Package Cache", "command":"sudo apt clean"},
    {"name":"Power Off", "command":"stopvnc\nexit\nexit"},
    {"name":"matrix", "command":"timeout 8 cmatrix"}
  ];

  // Default wine quick commands
  static const wineCommands = [
    {"name":"wine 配置", "command":"winecfg"},
    {"name":"修复方块字符", "command":"regedit Z:\\\\home\\\\tiny\\\\.local\\\\share\\\\tiny\\\\extra\\\\chn_fonts.reg && wine  reg delete \"HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows NT\\CurrentVersion\\FontSubstitutes\" /va /f"},
    {"name":"开始菜单文件夹", "command":"wine  explorer \"C:\\\\ProgramData\\\\Microsoft\\\\Windows\\\\Start Menu\\\\Programs\""},
    {"name":"删除 Wine", "command":"rm -rf /opt/wine"},
    {"name":"启用 DXVK", "command":"""WINEDLLOVERRIDES="d3d8=n,d3d9=n,d3d10core=n,d3d11=n,dxgi=n" wine  reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d8 /d native /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=n,d3d9=n,d3d10core=n,d3d11=n,dxgi=n" wine  reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d9 /d native /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=n,d3d9=n,d3d10core=n,d3d11=n,dxgi=n" wine  reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d10core /d native /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=n,d3d9=n,d3d10core=n,d3d11=n,dxgi=n" wine  reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d11 /d native /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=n,d3d9=n,d3d10core=n,d3d11=n,dxgi=n" wine  reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v dxgi /d native /f >/dev/null 2>&1"""},
    {"name":"禁用 DXVK", "command":"""WINEDLLOVERRIDES="d3d8=b,d3d9=b,d3d10core=b,d3d11=b,dxgi=b" wine  reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d8 /d builtin /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=b,d3d9=b,d3d10core=b,d3d11=b,dxgi=b" wine  reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d9 /d builtin /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=b,d3d9=b,d3d10core=b,d3d11=b,dxgi=b" wine  reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d10core /d builtin /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=b,d3d9=b,d3d10core=b,d3d11=b,dxgi=b" wine  reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d11 /d builtin /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=b,d3d9=b,d3d10core=b,d3d11=b,dxgi=b" wine  reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v dxgi /d builtin /f >/dev/null 2>&1"""},
    {"name":"我的电脑", "command":"wine  explorer"},
    {"name":"记事本", "command":"notepad"},
    {"name":"扫雷", "command":"winemine"},
    {"name":"注册表编辑器", "command":"regedit"},
    {"name":"控制面板", "command":"wine  control"},
    {"name":"文件管理器", "command":"winefile"},
    {"name":"任务管理器", "command":"wine  taskmgr"},
    {"name":"IE 浏览器", "command":"wine  iexplore"},
    {"name":"强制关闭 Wine", "command":"wine server -k"}
  ];

  // Default box64 /wine quick commands, English version
  static const wineCommands4En = [
    {"name":"wine Configuration", "command":"winecfg"},
    {"name":"Fix CJK Characters", "command":"regedit Z:\\\\home\\\\tiny\\\\.local\\\\share\\\\tiny\\\\extra\\\\chn_fonts.reg && wine  reg delete \"HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows NT\\CurrentVersion\\FontSubstitutes\" /va /f"},
    {"name":"Start Menu Dir", "command":"wine  explorer \"C:\\\\ProgramData\\\\Microsoft\\\\Windows\\\\Start Menu\\\\Programs\""},
    {"name":"Remove Wine", "command":"rm -rf /opt/wine"},
    {"name":"Enable DXVK", "command":"""WINEDLLOVERRIDES="d3d8=n,d3d9=n,d3d10core=n,d3d11=n,dxgi=n" wine  reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d8 /d native /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=n,d3d9=n,d3d10core=n,d3d11=n,dxgi=n" wine  reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d9 /d native /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=n,d3d9=n,d3d10core=n,d3d11=n,dxgi=n" wine  reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d10core /d native /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=n,d3d9=n,d3d10core=n,d3d11=n,dxgi=n" wine  reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d11 /d native /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=n,d3d9=n,d3d10core=n,d3d11=n,dxgi=n" wine  reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v dxgi /d native /f >/dev/null 2>&1"""},
    {"name":"Disable DXVK", "command":"""WINEDLLOVERRIDES="d3d8=b,d3d9=b,d3d10core=b,d3d11=b,dxgi=b" wine  reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d8 /d builtin /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=b,d3d9=b,d3d10core=b,d3d11=b,dxgi=b" wine  reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d9 /d builtin /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=b,d3d9=b,d3d10core=b,d3d11=b,dxgi=b" wine  reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d10core /d builtin /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=b,d3d9=b,d3d10core=b,d3d11=b,dxgi=b" wine  reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v d3d11 /d builtin /f >/dev/null 2>&1
WINEDLLOVERRIDES="d3d8=b,d3d9=b,d3d10core=b,d3d11=b,dxgi=b" wine  reg add 'HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides' /v dxgi /d builtin /f >/dev/null 2>&1"""},
    {"name":"Explorer", "command":"wine  explorer"},
    {"name":"Notepad", "command":"notepad"},
    {"name":"Minesweeper", "command":"winemine"},
    {"name":"Regedit", "command":"regedit"},
    {"name":"Control Panel", "command":"wine  control"},
    {"name":"File Manager", "command":"winefile"},
    {"name":"Task Manager", "command":"wine  taskmgr"},
    {"name":"Internet Explorer", "command":"wine  iexplore"},
    {"name":"Kill wine Process", "command":"wineserver -k"}
  ];

  // Default numpad
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

  // Add this missing boot constant
  static const String boot = "\$DATA_DIR/bin/proot -H --change-id=1000:1000 --pwd=/home/xodos --rootfs=\$CONTAINER_DIR --mount=/system --mount=/apex --mount=/sys --mount=/data --kill-on-exit --mount=/storage --sysvipc -L --link2symlink --mount=/proc --mount=/dev --mount=\$CONTAINER_DIR/tmp:/dev/shm --mount=/dev/urandom:/dev/random --mount=/proc/self/fd:/dev/fd --mount=/proc/self/fd/0:/dev/stdin --mount=\$DATA_DIR/tmp:/dev/dri --mount=/proc/self/fd/1:/dev/stdout --mount=/proc/self/fd/2:/dev/stderr --mount=/dev/null:/dev/tty0 --mount=/dev/null:/proc/sys/kernel/cap_last_cap --mount=/storage/self/primary:/media/sd --mount=\$DATA_DIR/share:/home/xodos/Public --mount=\$DATA_DIR/tiny:/home/tiny/.local/share/tiny --mount=/storage/self/primary/Fonts:/usr/share/fonts/wpsm --mount=/storage/self/primary/AppFiles/Fonts:/usr/share/fonts/yozom --mount=/system/fonts:/usr/share/fonts/androidm --mount=/storage/self/primary/Pictures:/home/xodos/Pictures --mount=/storage/self/primary/Music:/home/xodos/Music --mount=/storage/self/primary/Movies:/home/xodos/Videos --mount=/storage/self/primary/Download:/home/xodos/Downloads --mount=/storage/self/primary/Documents:/home/xodos/Documents --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/.tmoe-container.stat:/proc/stat --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/.tmoe-container.version:/proc/version --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/bus:/proc/bus --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/buddyinfo:/proc/buddyinfo --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/cgroups:/proc/cgroups --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/consoles:/proc/consoles --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/crypto:/proc/crypto --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/devices:/proc/devices --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/diskstats:/proc/diskstats --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/execdomains:/proc/execdomains --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/fb:/proc/fb --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/filesystems:/proc/filesystems --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/interrupts:/proc/interrupts --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/iomem:/proc/iomem --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/ioports:/proc/ioports --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/kallsyms:/proc/kallsyms --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/keys:/proc/keys --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/key-users:/proc/key-users --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/kpageflags:/proc/kpageflags --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/loadavg:/proc/loadavg --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/locks:/proc/locks --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/misc:/proc/misc --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/modules:/proc/modules --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/pagetypeinfo:/proc/pagetypeinfo --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/partitions:/proc/partitions --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/sched_debug:/proc/sched_debug --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/softirqs:/proc/softirqs --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/timer_list:/proc/timer_list --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/uptime:/proc/uptime --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/vmallocinfo:/proc/vmallocinfo --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/vmstat:/proc/vmstat --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/zoneinfo:/proc/zoneinfo \$EXTRA_MOUNT /usr/bin/env -i HOSTNAME=xodos HOME=/home/xodos USER=xodos TERM=xterm-256color SDL_IM_MODULE=fcitx XMODIFIERS=@im=fcitx QT_IM_MODULE=fcitx GTK_IM_MODULE=fcitx TMOE_CHROOT=false TMOE_PROOT=true TMPDIR=/tmp MOZ_FAKE_NO_SANDBOX=1 QTWEBENGINE_DISABLE_SANDBOX=1 DISPLAY=:4 PULSE_SERVER=tcp:127.0.0.1:4718 LANG=zh_CN.UTF-8 SHELL=/bin/bash PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games \$EXTRA_OPT /bin/bash -l";

  // Modern Android 10+ button styles
  static final ButtonStyle commandButtonStyle = AppButtonStyles.modernSettingsButton;
  
  static const MethodChannel androidChannel = MethodChannel("android");
}