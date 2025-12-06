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

// Modern color scheme with dark purple theme
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

class LanguageManager {
  static const Map<String, Map<String, String>> _languageConfigs = {
    'en': {
      'lang': 'en_US.UTF-8',
      'public': 'Public',
      'pictures': 'Pictures',
      'music': 'Music',
      'videos': 'Videos',
      'downloads': 'Downloads',
      'documents': 'Documents',
      'photos': 'Photos',
    },
    'zh': {
      'lang': 'zh_CN.UTF-8',
      'public': '公共',
      'pictures': '图片',
      'music': '音乐',
      'videos': '视频',
      'downloads': '下载',
      'documents': '文档',
      'photos': '照片',
    },
    'ja': {
      'lang': 'ja_JP.UTF-8',
      'public': '公開',
      'pictures': '画像',
      'music': '音楽',
      'videos': 'ビデオ',
      'downloads': 'ダウンロード',
      'documents': '書類',
      'photos': '写真',
    },
    'ar': {
      'lang': 'ar_SA.UTF-8',
      'public': 'عام',
      'pictures': 'الصور',
      'music': 'الموسيقى',
      'videos': 'الفيديو',
      'downloads': 'التنزيلات',
      'documents': 'المستندات',
      'photos': 'الصور',
    },
    'hi': {
      'lang': 'hi_IN.UTF-8',
      'public': 'सार्वजनिक',
      'pictures': 'चित्र',
      'music': 'संगीत',
      'videos': 'वीडियो',
      'downloads': 'डाउनलोड',
      'documents': 'दस्तावेज़',
      'photos': 'तस्वीरें',
    },
    'es': {
      'lang': 'es_ES.UTF-8',
      'public': 'Público',
      'pictures': 'Imágenes',
      'music': 'Música',
      'videos': 'Vídeos',
      'downloads': 'Descargas',
      'documents': 'Documentos',
      'photos': 'Fotos',
    },
    'pt': {
      'lang': 'pt_BR.UTF-8',
      'public': 'Público',
      'pictures': 'Imagens',
      'music': 'Música',
      'videos': 'Vídeos',
      'downloads': 'Downloads',
      'documents': 'Documentos',
      'photos': 'Fotos',
    },
    'fr': {
      'lang': 'fr_FR.UTF-8',
      'public': 'Public',
      'pictures': 'Images',
      'music': 'Musique',
      'videos': 'Vidéos',
      'downloads': 'Téléchargements',
      'documents': 'Documents',
      'photos': 'Photos',
    },
    'ru': {
      'lang': 'ru_RU.UTF-8',
      'public': 'Общедоступные',
      'pictures': 'Изображения',
      'music': 'Музыка',
      'videos': 'Видео',
      'downloads': 'Загрузки',
      'documents': 'Документы',
      'photos': 'Фотографии',
    },
  };

  static String getBootCommandForLanguage(String languageCode) {
    final config = _languageConfigs[languageCode] ?? _languageConfigs['en']!;
    
    String baseBoot = D.boot;
    
    // Replace the LANG environment variable
    baseBoot = baseBoot.replaceFirst('LANG=zh_CN.UTF-8', 'LANG=${config['lang']}');
    
    // Replace folder names
    baseBoot = baseBoot.replaceFirst('公共', config['public']!);
    baseBoot = baseBoot.replaceFirst('图片', config['pictures']!);
    baseBoot = baseBoot.replaceFirst('音乐', config['music']!);
    baseBoot = baseBoot.replaceFirst('视频', config['videos']!);
    baseBoot = baseBoot.replaceFirst('下载', config['downloads']!);
    baseBoot = baseBoot.replaceFirst('文档', config['documents']!);
    baseBoot = baseBoot.replaceFirst('照片', config['photos']!);
    
    return baseBoot;
  }

  static List<Map<String, String>> getCommandsForLanguage(String languageCode) {
    switch (languageCode) {
      case 'zh':
        return D.commands;
      case 'ja':
        return _japaneseCommands;
      case 'ar':
        return _arabicCommands;
      case 'hi':
        return _hindiCommands;
      case 'es':
        return _spanishCommands;
      case 'pt':
        return _portugueseCommands;
      case 'fr':
        return _frenchCommands;
      case 'ru':
        return _russianCommands;
      default:
        return D.commands4En;
    }
  }

  static List<Map<String, String>> getWineCommandsForLanguage(String languageCode) {
    switch (languageCode) {
      case 'zh':
        return D.wineCommands;
      case 'ja':
        return _japaneseWineCommands;
      case 'ar':
        return _arabicWineCommands;
      case 'hi':
        return _hindiWineCommands;
      case 'es':
        return _spanishWineCommands;
      case 'pt':
        return _portugueseWineCommands;
      case 'fr':
        return _frenchWineCommands;
      case 'ru':
        return _russianWineCommands;
      default:
        return D.wineCommands4En;
    }
  }





static Map<String, dynamic> getGroupedCommandsForLanguage(String languageCode) {
  final commands = getCommandsForLanguage(languageCode);
  
  // Separate install commands from other commands
  final installCommands = commands.where((cmd) { 
    final name = cmd["name"]?.toLowerCase() ?? "";
    final command = cmd["command"]?.toLowerCase() ?? "";
    return name.contains("install") || 
           command.contains("install") || 
           name.contains("enable");
  }).toList();
  
  final otherCommands = commands.where((cmd) {
    final name = cmd["name"]?.toLowerCase() ?? "";
    final command = cmd["command"]?.toLowerCase() ?? "";
    return !name.contains("install") && 
           !command.contains("install") && 
           !name.contains("enable") &&
           name != "???" &&
           !name.contains("shutdown");
  }).toList();
  
  final systemCommands = commands.where((cmd) {
    final name = cmd["name"]?.toLowerCase() ?? "";
    return name.contains("shutdown") || name == "???";
  }).toList();
  
  return {
    "install": installCommands,
    "other": otherCommands,
    "system": systemCommands,
  };
}

static Map<String, dynamic> getGroupedWineCommandsForLanguage(String languageCode) {
  final commands = getWineCommandsForLanguage(languageCode);
  
  // Separate Wine install/remove commands from configuration commands
  final installCommands = commands.where((cmd) {
    final name = cmd["name"]?.toLowerCase() ?? "";
    return name.contains("remove wine") || 
           name.contains("remove");
  }).toList();
  
  final configCommands = commands.where((cmd) {
    final name = cmd["name"]?.toLowerCase() ?? "";
    return !name.contains("remove wine") && 
           !name.contains("remove");
  }).toList();
  
  return {
    "install": installCommands,
    "config": configCommands,
  };
}

  // Japanese commands
  static const List<Map<String, String>> _japaneseCommands = [
    {"name":"パッケージの更新とアップグレード", "command":"sudo dpkg --configure -a && sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y"},
    {"name":"システム情報を表示", "command":"neofetch -L && neofetch --off"},
    {"name":"画面をクリア", "command":"clear"},
    {"name":"タスクを中断", "command":"\x03"},
    {"name":"グラフィックソフトKritaをインストール", "command":"sudo apt update && sudo apt install -y krita krita-l10n"},
    {"name":"Kritaをアンインストール", "command":"sudo apt autoremove --purge -y krita krita-l10n"},
    {"name":"動画編集ソフトKdenliveをインストール", "command":"sudo apt update && sudo apt install -y kdenlive"},
    {"name":"Kdenliveをアンインストール", "command":"sudo apt autoremove --purge -y kdenlive"},
    {"name":"LibreOfficeをインストール", "command":"sudo apt update && sudo apt install -y libreoffice"},
    {"name":"LibreOfficeをアンインストール", "command":"sudo apt autoremove --purge -y libreoffice"},
    {"name":"WPSをインストール", "command":r"""cat << 'EOF' | sh && sudo dpkg --configure -a && sudo apt update && sudo apt install -y /tmp/wps.deb
wget https://github.com/xodiosx/XoDos2/releases/download/v1.0.1/wps-office_11.1.0.11720_arm64.deb -O /tmp/wps.deb
EOF
rm /tmp/wps.deb"""},
    {"name":"WPSをアンインストール", "command":"sudo apt autoremove --purge -y wps-office"},
    {"name":"ごみ箱を有効にする", "command":"sudo apt update && sudo apt install -y gvfs && echo 'インストール完了、アプリを再起動してごみ箱を使用してください。'"},
    {"name":"パッケージキャッシュをクリーン", "command":"sudo apt clean"},
    {"name":"シャットダウン", "command":"stopvnc\nexit\nexit"},
    {"name":"???", "command":"timeout 8 cmatrix"}
  ];

  // Arabic commands
  static const List<Map<String, String>> _arabicCommands = [
    {"name":"تحديث الحزم والترقية", "command":"sudo dpkg --configure -a && sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y"},
    {"name":"معلومات النظام", "command":"neofetch -L && neofetch --off"},
    {"name":"مسح الشاشة", "command":"clear"},
    {"name":"مقاطعة المهمة", "command":"\x03"},
    {"name":"تثبيت برنامج الرسم كريتا", "command":"sudo apt update && sudo apt install -y krita krita-l10n"},
    {"name":"إزالة كریتا", "command":"sudo apt autoremove --purge -y krita krita-l10n"},
    {"name":"تثبيت برنامج تحرير الفيديو كدينلايف", "command":"sudo apt update && sudo apt install -y kdenlive"},
    {"name":"إزالة كدينلايف", "command":"sudo apt autoremove --purge -y kdenlive"},
    {"name":"تثبيت ليبر أوفيس", "command":"sudo apt update && sudo apt install -y libreoffice"},
    {"name":"إزالة ليبر أوفيس", "command":"sudo apt autoremove --purge -y libreoffice"},
    {"name":"تفعيل سلة المهملات", "command":"sudo apt update && sudo apt install -y gvfs && echo 'تم التثبيت، أعد تشغيل التطبيق لاستخدام سلة المهملات.'"},
    {"name":"تنظيف ذاكرة التخزين المؤقت", "command":"sudo apt clean"},
    {"name":"إيقاف التشغيل", "command":"stopvnc\nexit\nexit"},
    {"name":"???", "command":"timeout 8 cmatrix"}
  ];

  // Hindi commands
  static const List<Map<String, String>> _hindiCommands = [
    {"name":"पैकेज अपडेट और अपग्रेड", "command":"sudo dpkg --configure -a && sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y"},
    {"name":"सिस्टम जानकारी", "command":"neofetch -L && neofetch --off"},
    {"name":"स्क्रीन साफ करें", "command":"clear"},
    {"name":"कार्य बाधित करें", "command":"\x03"},
    {"name":"ग्राफिक सॉफ्टवेयर क्रिता इंस्टॉल करें", "command":"sudo apt update && sudo apt install -y krita krita-l10n"},
    {"name":"क्रिता अनइंस्टॉल करें", "command":"sudo apt autoremove --purge -y krita krita-l10n"},
    {"name":"वीडियो एडिटिंग सॉफ्टवेयर केडेनलाइव इंस्टॉल करें", "command":"sudo apt update && sudo apt install -y kdenlive"},
    {"name":"केडेनलाइव अनइंस्टॉल करें", "command":"sudo apt autoremove --purge -y kdenlive"},
    {"name":"रीसाइकिल बिन सक्षम करें", "command":"sudo apt update && sudo apt install -y gvfs && echo 'इंस्टॉलेशन पूर्ण, रीसाइकिल बिन का उपयोग करने के लिए ऐप को पुनरारंभ करें।'"},
    {"name":"पैकेज कैश साफ करें", "command":"sudo apt clean"},
    {"name":"शटडाउन", "command":"stopvnc\nexit\nexit"},
    {"name":"???", "command":"timeout 8 cmatrix"}
  ];

  // Spanish commands
  static const List<Map<String, String>> _spanishCommands = [
    {"name":"Actualizar y mejorar paquetes", "command":"sudo dpkg --configure -a && sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y"},
    {"name":"Información del sistema", "command":"neofetch -L && neofetch --off"},
    {"name":"Limpiar pantalla", "command":"clear"},
    {"name":"Interrumpir tarea", "command":"\x03"},
    {"name":"Instalar software gráfico Krita", "command":"sudo apt update && sudo apt install -y krita krita-l10n"},
    {"name":"Desinstalar Krita", "command":"sudo apt autoremove --purge -y krita krita-l10n"},
    {"name":"Instalar editor de video Kdenlive", "command":"sudo apt update && sudo apt install -y kdenlive"},
    {"name":"Desinstalar Kdenlive", "command":"sudo apt autoremove --purge -y kdenlive"},
    {"name":"Habilitar papelera de reciclaje", "command":"sudo apt update && sudo apt install -y gvfs && echo 'Instalación completa, reinicie la aplicación para usar la papelera de reciclaje.'"},
    {"name":"Limpiar caché de paquetes", "command":"sudo apt clean"},
    {"name":"Apagar", "command":"stopvnc\nexit\nexit"},
    {"name":"???", "command":"timeout 8 cmatrix"}
  ];

  // Portuguese commands
  static const List<Map<String, String>> _portugueseCommands = [
    {"name":"Atualizar y mejorar pacotes", "command":"sudo dpkg --configure -a && sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y"},
    {"name":"Informações do sistema", "command":"neofetch -L && neofetch --off"},
    {"name":"Limpar tela", "command":"clear"},
    {"name":"Interromper tarefa", "command":"\x03"},
    {"name":"Instalar software gráfico Krita", "command":"sudo apt update && sudo apt install -y krita krita-l10n"},
    {"name":"Desinstalar Krita", "command":"sudo apt autoremove --purge -y krita krita-l10n"},
    {"name":"Instalar editor de vídeo Kdenlive", "command":"sudo apt update && sudo apt install -y kdenlive"},
    {"name":"Desinstalar Kdenlive", "command":"sudo apt autoremove --purge -y kdenlive"},
    {"name":"Habilitar lixeira", "command":"sudo apt update && sudo apt install -y gvfs && echo 'Instalação completa, reinicie o aplicativo para usar a lixeira.'"},
    {"name":"Limpar cache de pacotes", "command":"sudo apt clean"},
    {"name":"Desligar", "command":"stopvnc\nexit\nexit"},
    {"name":"???", "command":"timeout 8 cmatrix"}
  ];

  // French commands
  static const List<Map<String, String>> _frenchCommands = [
    {"name":"Mettre à jour et améliorer les paquets", "command":"sudo dpkg --configure -a && sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y"},
    {"name":"Informations système", "command":"neofetch -L && neofetch --off"},
    {"name":"Effacer l'écran", "command":"clear"},
    {"name":"Interrompre la tâche", "command":"\x03"},
    {"name":"Installer le logiciel graphique Krita", "command":"sudo apt update && sudo apt install -y krita krita-l10n"},
    {"name":"Désinstaller Krita", "command":"sudo apt autoremove --purge -y krita krita-l10n"},
    {"name":"Installer l'éditeur vidéo Kdenlive", "command":"sudo apt update && sudo apt install -y kdenlive"},
    {"name":"Désinstaller Kdenlive", "command":"sudo apt autoremove --purge -y kdenlive"},
    {"name":"Activer la corbeille", "command":"sudo apt update && sudo apt install -y gvfs && echo 'Installation terminée, redémarrez l\\'application pour utiliser la corbeille.'"},
    {"name":"Nettoyer le cache des paquets", "command":"sudo apt clean"},
    {"name":"Éteindre", "command":"stopvnc\nexit\nexit"},
    {"name":"???", "command":"timeout 8 cmatrix"}
  ];

  // Russian commands
  static const List<Map<String, String>> _russianCommands = [
    {"name":"Обновить и улучшить пакеты", "command":"sudo dpkg --configure -a && sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y"},
    {"name":"Информация о системе", "command":"neofetch -L && neofetch --off"},
    {"name":"Очистить экран", "command":"clear"},
    {"name":"Прервать задачу", "command":"\x03"},
    {"name":"Установить графическое ПО Krita", "command":"sudo apt update && sudo apt install -y krita krita-l10n"},
    {"name":"Удалить Krita", "command":"sudo apt autoremove --purge -y krita krita-l10n"},
    {"name":"Установить видеоредактор Kdenlive", "command":"sudo apt update && sudo apt install -y kdenlive"},
    {"name":"Удалить Kdenlive", "command":"sudo apt autoremove --purge -y kdenlive"},
    {"name":"Включить корзину", "command":"sudo apt update && sudo apt install -y gvfs && echo 'Установка завершена, перезапустите приложение для использования корзины.'"},
    {"name":"Очистить кэш пакетов", "command":"sudo apt clean"},
    {"name":"Выключить", "command":"stopvnc\nexit\nexit"},
    {"name":"???", "command":"timeout 8 cmatrix"}
  ];

  // Wine commands for different languages (simplified versions)
  static const List<Map<String, String>> _japaneseWineCommands = [
    {"name":"Wine設定", "command":"winecfg"},
    {"name":"文字化け修正", "command":"regedit Z:\\\\home\\\\tiny\\\\.local\\\\share\\\\tiny\\\\extra\\\\chn_fonts.reg && wine reg delete \"HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows NT\\CurrentVersion\\FontSubstitutes\" /va /f"},
    {"name":"スタートメニューフォルダ", "command":"wine explorer \"C:\\\\ProgramData\\\\Microsoft\\\\Windows\\\\Start Menu\\\\Programs\""},
    {"name":"Remove Wine", "command":"rm -rf /opt/wine"},
  ];

  static const List<Map<String, String>> _arabicWineCommands = [
    {"name":"إعدادات Wine", "command":"winecfg"},
    {"name":"إصلاح الأحرف", "command":"regedit Z:\\\\home\\\\tiny\\\\.local\\\\share\\\\tiny\\\\extra\\\\chn_fonts.reg && wine reg delete \"HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows NT\\CurrentVersion\\FontSubstitutes\" /va /f"},
    {"name":"مجلد قائمة ابدأ", "command":"wine explorer \"C:\\\\ProgramData\\\\Microsoft\\\\Windows\\\\Start Menu\\\\Programs\""},
    {"name":"Remove Wine", "command":"rm -rf /opt/wine"},
  ];

  static const List<Map<String, String>> _hindiWineCommands = [
    {"name":"Wine सेटिंग्स", "command":"winecfg"},
    {"name":"वर्ण सुधार", "command":"regedit Z:\\\\home\\\\tiny\\\\.local\\\\share\\\\tiny\\\\extra\\\\chn_fonts.reg && wine reg delete \"HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows NT\\CurrentVersion\\FontSubstitutes\" /va /f"},
    {"name":"स्टार्ट मेनू फोल्डर", "command":"wine explorer \"C:\\\\ProgramData\\\\Microsoft\\\\Windows\\\\Start Menu\\\\Programs\""},
    {"name":"Remove Wine", "command":"rm -rf /opt/wine"},
  ];

  static const List<Map<String, String>> _spanishWineCommands = [
    {"name":"Configuración de Wine", "command":"winecfg"},
    {"name":"Reparar caracteres", "command":"regedit Z:\\\\home\\\\tiny\\\\.local\\\\share\\\\tiny\\\\extra\\\\chn_fonts.reg && wine reg delete \"HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows NT\\CurrentVersion\\FontSubstitutes\" /va /f"},
    {"name":"Carpeta del menú Inicio", "command":"wine explorer \"C:\\\\ProgramData\\\\Microsoft\\\\Windows\\\\Start Menu\\\\Programs\""},
    {"name":"Remove Wine", "command":"rm -rf /opt/wine"},
  ];

  static const List<Map<String, String>> _portugueseWineCommands = [
    {"name":"Configurações do Wine", "command":"winecfg"},
    {"name":"Reparar caracteres", "command":"regedit Z:\\\\home\\\\tiny\\\\.local\\\\share\\\\tiny\\\\extra\\\\chn_fonts.reg && wine reg delete \"HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows NT\\CurrentVersion\\FontSubstitutes\" /va /f"},
    {"name":"Pasta do menu Iniciar", "command":"wine explorer \"C:\\\\ProgramData\\\\Microsoft\\\\Windows\\\\Start Menu\\\\Programs\""},
    {"name":"Remove Wine", "command":"rm -rf /opt/wine"},
  ];

  static const List<Map<String, String>> _frenchWineCommands = [
    {"name":"Paramètres Wine", "command":"winecfg"},
    {"name":"Réparer les caractères", "command":"regedit Z:\\\\home\\\\tiny\\\\.local\\\\share\\\\tiny\\\\extra\\\\chn_fonts.reg && wine reg delete \"HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows NT\\CurrentVersion\\FontSubstitutes\" /va /f"},
    {"name":"Dossier du menu Démarrer", "command":"wine explorer \"C:\\\\ProgramData\\\\Microsoft\\\\Windows\\\\Start Menu\\\\Programs\""},
    {"name":"Remove Wine", "command":"rm -rf /opt/wine"},
  ];

  static const List<Map<String, String>> _russianWineCommands = [
    {"name":"Настройки Wine", "command":"winecfg"},
    {"name":"Исправить символы", "command":"regedit Z:\\\\home\\\\tiny\\\\.local\\\\share\\\\tiny\\\\extra\\\\chn_fonts.reg && wine reg delete \"HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows NT\\CurrentVersion\\FontSubstitutes\" /va /f"},
    {"name":"Папка меню Пуск", "command":"wine explorer \"C:\\\\ProgramData\\\\Microsoft\\\\Windows\\\\Start Menu\\\\Programs\""},
    {"name":"Remove Wine", "command":"rm -rf /opt/wine"},
  ];
}

// DXVK Installer Class
class DxvkInstaller {
  static Future<List<String>> getDxvkFiles() async {
    try {
      final dir = Directory('/wincomponents/d3d');
      if (!await dir.exists()) {
        // Try to create directory if it doesn't exist
        await dir.create(recursive: true);
        return [];
      }
      
      final files = await dir.list().toList();
      return files
          .where((file) => file is File && (file.path.endsWith('.tzst') || file.path.endsWith('.tar.zst')))
          .map((file) => file.path.split('/').last)
          .toList();
    } catch (e) {
      print('Error getting DXVK files: $e');
      return [];
    }
  }
  
  static Future<void> extractDxvk(String fileName, BuildContext context) async {
    final homeDir = Directory('/home/xodos/.wine/drive_c/windows');
    if (!await homeDir.exists()) {
      await homeDir.create(recursive: true);
    }
    
    final dxvkPath = '/wincomponents/d3d/$fileName';
    final dxvkFile = File(dxvkPath);
    if (!await dxvkFile.exists()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('DXVK file not found: $fileName')),
        );
      }
      return;
    }
    
    try {
      // Show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('Installing DXVK'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Extracting $fileName...'),
            ],
          ),
        ),
      );
      
      // Extract tzst file using tar
      final result = await Process.run('tar', [
        '-xaf',
        dxvkPath,
        '-C',
        '/home/xodos/.wine',
        '--strip-components=1'
      ]);
      
      // Close progress dialog
      Navigator.of(context, rootNavigator: true).pop();
      
      if (result.exitCode == 0) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('DXVK installed successfully to ~/.wine!'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to extract DXVK: ${result.stderr}')),
          );
        }
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error installing DXVK: $e')),
        );
      }
    }
  }
}

// DXVK Dialog Widget


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
      case "name" : return (value){addCurrentProp(key, value); return value;}("Debian Bookworm");
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

// Android 10+ Modern Settings Button Styles
class AppButtonStyles {
  // Modern Android 10+ Settings Button Style (for command buttons)
  static final ButtonStyle modernSettingsButton = TextButton.styleFrom(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.textPrimary,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    alignment: Alignment.centerLeft,
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    minimumSize: const Size(double.infinity, 56),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  ).copyWith(
    overlayColor: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.pressed)) {
          return AppColors.pressedColor;
        }
        if (states.contains(MaterialState.hovered)) {
          return AppColors.hoverColor;
        }
        return null;
      },
    ),
    side: MaterialStateProperty.all<BorderSide>(
      const BorderSide(color: AppColors.divider, width: 0.5),
    ),
  );

  // Compact Settings Button Style (for smaller buttons)
  static final ButtonStyle compactSettingsButton = TextButton.styleFrom(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.textPrimary,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    alignment: Alignment.centerLeft,
    textStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    minimumSize: const Size(double.infinity, 48),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  ).copyWith(
    overlayColor: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.pressed)) {
          return AppColors.pressedColor;
        }
        if (states.contains(MaterialState.hovered)) {
          return AppColors.hoverColor;
        }
        return null;
      },
    ),
    side: MaterialStateProperty.all<BorderSide>(
      const BorderSide(color: AppColors.divider, width: 0.5),
    ),
  );

  // Primary Action Button (for important actions)
  static final ButtonStyle primaryActionButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryPurple,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 2,
    shadowColor: Colors.black.withOpacity(0.2),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    minimumSize: const Size(double.infinity, 56),
  );

  // Danger Action Button (for destructive actions)
  static final ButtonStyle dangerActionButton = ElevatedButton.styleFrom(
    backgroundColor: Colors.red.withOpacity(0.1),
    foregroundColor: Colors.red,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 0,
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    minimumSize: const Size(double.infinity, 56),
  ).copyWith(
    overlayColor: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return Colors.red.withOpacity(0.2);
      },
    ),
    side: MaterialStateProperty.all<BorderSide>(
      BorderSide(color: Colors.red.withOpacity(0.3), width: 1),
    ),
  );
}

// default values
class D {

  // Common links
  static const links = [
    {"name": "projectUrl", "value": "https://github.com/xodiosx/XoDos2"},
    {"name": "issueUrl", "value": "https://github.com/xodiosx/XoDos2/issues"},
    {"name": "faqUrl", "value": "https://github.com/xodiosx/XoDos2blob/main/faq.md"},
    {"name": "solutionUrl", "value": "https://github.com/xodiosx/XoDos2blob/main/fix.md"},
    {"name": "discussionUrl", "value": "https://t.me/xodemulatorr"},
  ];

  // Default quick commands
  static const commands = [{"name":"Check for updates and upgrade", "command":"sudo dpkg --configure -a && sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y"},
    {"name":"View system information", "command":"neofetch -L && neofetch --off"},
    {"name":"Clear screen", "command":"clear"},
    {"name":"Interrupt task", "command":"\x03"},
    {"name":"Install graphics software Krita", "command":"sudo apt update && sudo apt install -y krita krita-l10n"},
    {"name":"Uninstall Krita", "command":"sudo apt autoremove --purge -y krita krita-l10n"},
    {"name":"Install video editing software Kdenlive", "command":"sudo apt update && sudo apt install -y kdenlive"},
    {"name":"Uninstall Kdenlive", "command":"sudo apt autoremove --purge -y kdenlive"},
    {"name":"Install scientific computing software Octave", "command":"sudo apt update && sudo apt install -y octave"},
    {"name":"Uninstall Octave", "command":"sudo apt autoremove --purge -y octave"},
    {"name":"Install WPS", "command":r"""cat << 'EOF' | sh && sudo dpkg --configure -a && sudo apt update && sudo apt install -y /tmp/wps.deb
wget https://github.com/xodiosx/XoDos2/releases/download/v1.0.1/wps-office_11.1.0.11720_arm64.deb -O /tmp/wps.deb
EOF
rm /tmp/wps.deb"""},
    {"name":"Uninstall WPS", "command":"sudo apt autoremove --purge -y wps-office"},
    {"name":"Install CAJViewer", "command":"wget https://download.cnki.net/net.cnki.cajviewer_1.3.20-1_arm64.deb -O /tmp/caj.deb && sudo apt update && sudo apt install -y /tmp/caj.deb && bash /home/tiny/.local/share/tiny/caj/postinst; rm /tmp/caj.deb"},
    {"name":"Uninstall CAJViewer", "command":"sudo apt autoremove --purge -y net.cnki.cajviewer && bash /home/tiny/.local/share/tiny/caj/postrm"},
    {"name":"Install EdrawMax", "command":"wget https://cc-download.wondershare.cc/business/prd/edrawmax_13.1.0-1_arm64_binner.deb -O /tmp/edraw.deb && sudo apt update && sudo apt install -y /tmp/edraw.deb && bash /home/tiny/.local/share/tiny/edraw/postinst; rm /tmp/edraw.deb"},
    {"name":"Uninstall EdrawMax", "command":"sudo apt autoremove --purge -y edrawmax libldap-2.4-2"},
    {"name":"Install QQ", "command":"""wget \$(curl -s https://im.qq.com/rainbow/linuxQQDownload | grep -oP '"armDownloadUrl":{[^}]*"deb":"\\K[^"]+') -O /tmp/qq.deb && sudo apt update && sudo apt install -y /tmp/qq.deb && sed -i 's#Exec=/opt/QQ/qq %U#Exec=/opt/QQ/qq --no-sandbox %U#g' /usr/share/applications/qq.desktop; rm /tmp/qq.deb"""},
    {"name":"Uninstall QQ", "command":"sudo apt autoremove --purge -y linuxqq"},
    {"name":"Install WeChat", "command":"wget https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_arm64.deb -O /tmp/wechat.deb && sudo apt update && sudo apt install -y /tmp/wechat.deb && echo 'Installation complete. If you only use WeChat for file transfer, consider using a file manager that supports SAF (e.g., Material Files) to directly access all files in xodos.'; rm /tmp/wechat.deb"},
    {"name":"Uninstall WeChat", "command":"sudo apt autoremove --purge -y wechat"},
    {"name":"Install DingTalk", "command":"""wget \$(curl -sw %{redirect_url} https://www.dingtalk.com/win/d/qd=linux_arm64) -O /tmp/dingtalk.deb && sudo apt update && sudo apt install -y /tmp/dingtalk.deb libglut3.12 libglu1-mesa && sed -i 's#\\./com.alibabainc.dingtalk#\\./com.alibabainc.dingtalk --no-sandbox#g' /opt/apps/com.alibabainc.dingtalk/files/Elevator.sh; rm /tmp/dingtalk.deb"""},
    {"name":"Uninstall DingTalk", "command":"sudo apt autoremove --purge -y com.alibabainc.dingtalk"},
    {"name":"Enable Recycle Bin", "command":"sudo apt update && sudo apt install -y gvfs && echo 'Installation complete, restart the app to use Recycle Bin.'"},
    {"name":"Clean package manager cache", "command":"sudo apt clean"},
    {"name":"Shutdown", "command":"stopvnc\nexit\nexit"},
    {"name":"???", "command":"timeout 8 cmatrix"}
  ];

  // Default quick commands, English version
  static const commands4En = [{"name":"Update Packages", "command":"sudo dpkg --configure -a && sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y"},
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
    {"name":"Install EdrawMax", "command":"""wget https://cc-download.wondershare.cc/business/prd/edrawmax_13.1.0-1_arm64_binner.deb -O /tmp/edraw.deb && sudo apt update && sudo apt install -y /tmp/edraw.deb && bash /home/tiny/.local/share/tiny/edraw/postinst && sudo sed -i 's/<Language V="cn"\\/>/<Language V="en"\\/>/g' /opt/apps/edrawmax/config/settings.xml; rm /tmp/edraw.deb"""},
    {"name":"Uninstall EdrawMax", "command":"sudo apt autoremove --purge -y edrawmax libldap-2.4-2"},
    {"name":"Enable Recycle Bin", "command":"sudo apt update && sudo apt install -y gvfs && echo 'Restart the app to use Recycle Bin.'"},
    {"name":"Clean Package Cache", "command":"sudo apt clean"},
    {"name":"Power Off", "command":"stopvnc\nexit\nexit"},
    {"name":"???", "command":"timeout 8 cmatrix"}
  ];

  // Default wine quick commands
  static const wineCommands = [{"name":"Wine Configuration", "command":"winecfg"},
    {"name":"Fix square characters", "command":"regedit Z:\\\\home\\\\tiny\\\\.local\\\\share\\\\tiny\\\\extra\\\\chn_fonts.reg && wine reg delete \"HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows NT\\CurrentVersion\\FontSubstitutes\" /va /f"},
    {"name":"Start Menu folder", "command":"wine explorer \"C:\\\\ProgramData\\\\Microsoft\\\\Windows\\\\Start Menu\\\\Programs\""},
    {"name":"Remove Wine", "command":"rm -rf /opt/wine"},
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
    {"name":"My Computer", "command":"wine explorer"},
    {"name":"Notepad", "command":"notepad"},
    {"name":"Minesweeper", "command":"winemine"},
    {"name":"Registry Editor", "command":"regedit"},
    {"name":"Control Panel", "command":"wine control"},
    {"name":"File Manager", "command":"winefile"},
    {"name":"Task Manager", "command":"wine taskmgr"},
    {"name":"IE Browser", "command":"wine iexplore"},
    {"name":"Force close Wine", "command":"wineserver -k"}
  ];

  // Default wine quick commands, English version
  static const wineCommands4En = [{"name":"Wine Configuration", "command":"winecfg"},
    {"name":"Fix CJK Characters", "command":"regedit Z:\\\\home\\\\tiny\\\\.local\\\\share\\\\tiny\\\\extra\\\\chn_fonts.reg && wine reg delete \"HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows NT\\CurrentVersion\\FontSubstitutes\" /va /f"},
    {"name":"Start Menu Dir", "command":"wine explorer \"C:\\\\ProgramData\\\\Microsoft\\\\Windows\\\\Start Menu\\\\Programs\""},
    {"name":"Remove Wine", "command":"rm -rf /opt/wine"},
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
  static const String boot = "\$DATA_DIR/bin/proot -H --change-id=1000:1000 --pwd=/home/xodos --rootfs=\$CONTAINER_DIR --mount=/system --mount=/apex --mount=/sys --mount=/data --kill-on-exit --mount=/storage --sysvipc -L --link2symlink --mount=/proc --mount=/dev --mount=\$CONTAINER_DIR/tmp:/dev/shm --mount=/dev/urandom:/dev/random --mount=/proc/self/fd:/dev/fd --mount=/proc/self/fd/0:/dev/stdin --mount=/proc/self/fd/1:/dev/stdout --mount=/proc/self/fd/2:/dev/stderr --mount=/dev/null:/dev/tty0 --mount=/dev/null:/proc/sys/kernel/cap_last_cap --mount=/storage/self/primary:/media/sd --mount=\$DATA_DIR/share:/home/xodos/Public --mount=\$DATA_DIR/tiny:/home/tiny/.local/share/tiny --mount=/storage/self/primary/Fonts:/usr/share/fonts/wpsm --mount=/storage/self/primary/AppFiles/Fonts:/usr/share/fonts/yozom --mount=/system/fonts:/usr/share/fonts/androidm --mount=/storage/self/primary/Pictures:/home/xodos/Pictures --mount=/storage/self/primary/Music:/home/xodos/Music --mount=/storage/self/primary/Movies:/home/xodos/Videos --mount=/storage/self/primary/Download:/home/xodos/Downloads --mount=/storage/self/primary/Documents:/home/xodos/Documents --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/.tmoe-container.stat:/proc/stat --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/.tmoe-container.version:/proc/version --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/bus:/proc/bus --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/buddyinfo:/proc/buddyinfo --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/cgroups:/proc/cgroups --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/consoles:/proc/consoles --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/crypto:/proc/crypto --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/devices:/proc/devices --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/diskstats:/proc/diskstats --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/execdomains:/proc/execdomains --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/fb:/proc/fb --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/filesystems:/proc/filesystems --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/interrupts:/proc/interrupts --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/iomem:/proc/iomem --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/ioports:/proc/ioports --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/kallsyms:/proc/kallsyms --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/keys:/proc/keys --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/key-users:/proc/key-users --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/kpageflags:/proc/kpageflags --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/loadavg:/proc/loadavg --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/locks:/proc/locks --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/misc:/proc/misc --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/modules:/proc/modules --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/pagetypeinfo:/proc/pagetypeinfo --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/partitions:/proc/partitions --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/sched_debug:/proc/sched_debug --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/softirqs:/proc/softirqs --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/timer_list:/proc/timer_list --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/uptime:/proc/uptime --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/vmallocinfo:/proc/vmallocinfo --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/vmstat:/proc/vmstat --mount=\$CONTAINER_DIR/usr/local/etc/tmoe-linux/proot_proc/zoneinfo:/proc/zoneinfo \$EXTRA_MOUNT /usr/bin/env -i HOSTNAME=xodos HOME=/home/xodos USER=xodos TERM=xterm-256color SDL_IM_MODULE=fcitx XMODIFIERS=@im=fcitx QT_IM_MODULE=fcitx GTK_IM_MODULE=fcitx TMOE_CHROOT=false TMOE_PROOT=true TMPDIR=/tmp MOZ_FAKE_NO_SANDBOX=1 QTWEBENGINE_DISABLE_SANDBOX=1 DISPLAY=:4 PULSE_SERVER=tcp:127.0.0.1:4718 LANG=zh_CN.UTF-8 SHELL=/bin/bash PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games \$EXTRA_OPT /bin/bash -l";

  // Modern Android 10+ button styles
  static final ButtonStyle commandButtonStyle = AppButtonStyles.modernSettingsButton;
  
  static const MethodChannel androidChannel = MethodChannel("android");

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
""");
    // Some data initialization
    // $DATA_DIR is the data folder, $CONTAINER_DIR is the container root directory
    // Termux:X11's startup command is not here, it's hardcoded. Now it's a pile of stuff code :P
    
    // Use LanguageManager for proper language support
    final languageCode = Localizations.localeOf(G.homePageStateContext).languageCode;
    final groupedCommands = LanguageManager.getGroupedCommandsForLanguage(languageCode);
    final groupedWineCommands = LanguageManager.getGroupedWineCommandsForLanguage(languageCode);
    
    await G.prefs.setStringList("containersInfo", ["""{
"name":"Debian Bookworm",
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
    
    G.prefs = await SharedPreferences.getInstance();

    await Util.execute("ln -sf ${await D.androidChannel.invokeMethod("getNativeLibraryPath", {})} ${G.dataPath}/applib");

    // If this key doesn't exist, it means it's the first startup
    if (!G.prefs.containsKey("defaultContainer")) {
      await initForFirstTime();
      // Adjust resolution based on user's screen
      final s = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;
      final String w = (max(s.width, s.height) * 0.75).round().toString();
      final String h = (min(s.width, s.height) * 0.75).round().toString();
      G.postCommand = """sed -i -E "s@(geometry)=.*@\\1=${w}x${h}@" /etc/tigervnc/vncserver-config-tmoe
sed -i -E "s@^(VNC_RESOLUTION)=.*@\\1=${w}x${h}@" \$(command -v startvnc)""";
      
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
# Run post-command silently
(${G.postCommand}) > /dev/null 2>&1""");
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

  static Future<void> workflow() async {
    grantPermissions();
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
      waitForConnection().then((value) => G.wasAvncEnabled?launchAvnc():launchBrowser());
    }
  }
}

// UI Widgets for displaying grouped commands and DXVK installation
class GroupedCommandsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final groupedCommands = Util.getGroupedCommands();
    
    return Column(
      children: [
        // Install Commands Section (Collapsible)
        if ((groupedCommands["install"] as List).isNotEmpty)
          ExpansionTile(
            title: Text(
              AppLocalizations.of(context)!.installCommandsSection,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            initiallyExpanded: true,
            backgroundColor: AppColors.surfaceDark,
            collapsedBackgroundColor: AppColors.surfaceDark,
            children: [
              ...(groupedCommands["install"] as List).map((cmd) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextButton(
                    style: AppButtonStyles.modernSettingsButton,
                    onPressed: () => Util.termWrite(cmd["command"]),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        cmd["name"],
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        
        // Other Commands Section
        if ((groupedCommands["other"] as List).isNotEmpty)
          ExpansionTile(
            title: Text(
              'Other Commands',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            backgroundColor: AppColors.surfaceDark,
            collapsedBackgroundColor: AppColors.surfaceDark,
            children: [
              ...(groupedCommands["other"] as List).map((cmd) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextButton(
                    style: AppButtonStyles.modernSettingsButton,
                    onPressed: () => Util.termWrite(cmd["command"]),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        cmd["name"],
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        
        // System Commands Section
        if ((groupedCommands["system"] as List).isNotEmpty)
          ExpansionTile(
            title: Text(
              'System',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            backgroundColor: AppColors.surfaceDark,
            collapsedBackgroundColor: AppColors.surfaceDark,
            children: [
              ...(groupedCommands["system"] as List).map((cmd) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextButton(
                    style: AppButtonStyles.modernSettingsButton,
                    onPressed: () => Util.termWrite(cmd["command"]),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        cmd["name"],
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
      ],
    );
  }
}





