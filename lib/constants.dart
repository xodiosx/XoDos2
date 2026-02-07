// constants.dart
import 'package:flutter/material.dart';

import 'default_values.dart';
import 'core_classes.dart';
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
        return _getFullCommandSet([
          _japaneseCommands[0],  // Update and upgrade
          _japaneseCommands[1],  // System info
          _japaneseCommands[2],  // Clear screen
          _japaneseCommands[3],  // Interrupt task
          _japaneseCommands[4],  // Install Krita
          _japaneseCommands[5],  // Uninstall Krita
          _japaneseCommands[6],  // Install Kdenlive
          _japaneseCommands[7],  // Uninstall Kdenlive
          _japaneseCommands[8],  // Install Blender
          _japaneseCommands[9],  // Uninstall Blender
          _japaneseCommands[10], // Install VS Code
          _japaneseCommands[11], // Uninstall VS Code
          _japaneseCommands[12], // Install LibreOffice
          _japaneseCommands[13], // Uninstall LibreOffice
          _japaneseCommands[14], // Install WPS
          _japaneseCommands[15], // Uninstall WPS
          _japaneseCommands[16], // Enable recycle bin
          _japaneseCommands[17], // Clean package cache
          _japaneseCommands[18], // Shutdown
          _japaneseCommands[19], // matrix
        ]);
      case 'ar':
        return _getFullCommandSet([
          _arabicCommands[0],    // Update and upgrade
          _arabicCommands[1],    // System info
          _arabicCommands[2],    // Clear screen
          _arabicCommands[3],    // Interrupt task
          _arabicCommands[4],    // Install Krita
          _arabicCommands[5],    // Uninstall Krita
          _arabicCommands[6],    // Install Kdenlive
          _arabicCommands[7],    // Uninstall Kdenlive
          _arabicCommands[8],    // Install Blender
          _arabicCommands[9],    // Uninstall Blender
          _arabicCommands[10],   // Install VS Code
          _arabicCommands[11],   // Uninstall VS Code
          _arabicCommands[12],   // Install LibreOffice
          _arabicCommands[13],   // Uninstall LibreOffice
          {"name":"تثبيت WPS", "command":r"""cat << 'EOF' | sh && sudo dpkg --configure -a && sudo apt update && sudo apt install -y /tmp/wps.deb
wget https://github.com/xodiosx/XoDos2/releases/download/v1.0.1/wps-office_11.1.0.11720_arm64.deb -O /tmp/wps.deb
EOF
rm /tmp/wps.deb"""},
          {"name":"إزالة WPS", "command":"sudo apt autoremove --purge -y wps-office"},
          _arabicCommands[14],   // Enable recycle bin
          _arabicCommands[15],   // Clean package cache
          _arabicCommands[16],   // Shutdown
          _arabicCommands[17],   // matrix
        ]);
      case 'hi':
        return _getFullCommandSet([
          _hindiCommands[0],     // Update and upgrade
          _hindiCommands[1],     // System info
          _hindiCommands[2],     // Clear screen
          _hindiCommands[3],     // Interrupt task
          _hindiCommands[4],     // Install Krita
          _hindiCommands[5],     // Uninstall Krita
          _hindiCommands[6],     // Install Kdenlive
          _hindiCommands[7],     // Uninstall Kdenlive
          _hindiCommands[8],     // Install Blender
          _hindiCommands[9],     // Uninstall Blender
          _hindiCommands[10],    // Install VS Code
          _hindiCommands[11],    // Uninstall VS Code
          {"name":"LibreOffice इंस्टॉल करें", "command":"sudo apt update && sudo apt install -y libreoffice"},
          {"name":"LibreOffice अनइंस्टॉल करें", "command":"sudo apt autoremove --purge -y libreoffice"},
          {"name":"WPS इंस्टॉल करें", "command":r"""cat << 'EOF' | sh && sudo dpkg --configure -a && sudo apt update && sudo apt install -y /tmp/wps.deb
wget https://github.com/xodiosx/XoDos2/releases/download/v1.0.1/wps-office_11.1.0.11720_arm64.deb -O /tmp/wps.deb
EOF
rm /tmp/wps.deb"""},
          {"name":"WPS अनइंस्टॉल करें", "command":"sudo apt autoremove --purge -y wps-office"},
          _hindiCommands[12],    // Enable recycle bin
          _hindiCommands[13],    // Clean package cache
          _hindiCommands[14],    // Shutdown
          _hindiCommands[15],    // matrix
        ]);
      case 'es':
        return _getFullCommandSet([
          _spanishCommands[0],   // Update and upgrade
          _spanishCommands[1],   // System info
          _spanishCommands[2],   // Clear screen
          _spanishCommands[3],   // Interrupt task
          _spanishCommands[4],   // Install Krita
          _spanishCommands[5],   // Uninstall Krita
          _spanishCommands[6],   // Install Kdenlive
          _spanishCommands[7],   // Uninstall Kdenlive
          _spanishCommands[8],   // Install Blender
          _spanishCommands[9],   // Uninstall Blender
          _spanishCommands[10],  // Install VS Code
          _spanishCommands[11],  // Uninstall VS Code
          {"name":"Instalar LibreOffice", "command":"sudo apt update && sudo apt install -y libreoffice"},
          {"name":"Desinstalar LibreOffice", "command":"sudo apt autoremove --purge -y libreoffice"},
          {"name":"Instalar WPS", "command":r"""cat << 'EOF' | sh && sudo dpkg --configure -a && sudo apt update && sudo apt install -y /tmp/wps.deb
wget https://github.com/xodiosx/XoDos2/releases/download/v1.0.1/wps-office_11.1.0.11720_arm64.deb -O /tmp/wps.deb
EOF
rm /tmp/wps.deb"""},
          {"name":"Desinstalar WPS", "command":"sudo apt autoremove --purge -y wps-office"},
          _spanishCommands[12],  // Enable recycle bin
          _spanishCommands[13],  // Clean package cache
          _spanishCommands[14],  // Shutdown
          _spanishCommands[15],  // matrix
        ]);
      case 'pt':
        return _getFullCommandSet([
          _portugueseCommands[0], // Update and upgrade
          _portugueseCommands[1], // System info
          _portugueseCommands[2], // Clear screen
          _portugueseCommands[3], // Interrupt task
          _portugueseCommands[4], // Install Krita
          _portugueseCommands[5], // Uninstall Krita
          _portugueseCommands[6], // Install Kdenlive
          _portugueseCommands[7], // Uninstall Kdenlive
          _portugueseCommands[8], // Install Blender
          _portugueseCommands[9], // Uninstall Blender
          _portugueseCommands[10], // Install VS Code
          _portugueseCommands[11], // Uninstall VS Code
          {"name":"Instalar LibreOffice", "command":"sudo apt update && sudo apt install -y libreoffice"},
          {"name":"Desinstalar LibreOffice", "command":"sudo apt autoremove --purge -y libreoffice"},
          {"name":"Instalar WPS", "command":r"""cat << 'EOF' | sh && sudo dpkg --configure -a && sudo apt update && sudo apt install -y /tmp/wps.deb
wget https://github.com/xodiosx/XoDos2/releases/download/v1.0.1/wps-office_11.1.0.11720_arm64.deb -O /tmp/wps.deb
EOF
rm /tmp/wps.deb"""},
          {"name":"Desinstalar WPS", "command":"sudo apt autoremove --purge -y wps-office"},
          _portugueseCommands[12], // Enable recycle bin
          _portugueseCommands[13], // Clean package cache
          _portugueseCommands[14], // Shutdown
          _portugueseCommands[15], // matrix
        ]);
      case 'fr':
        return _getFullCommandSet([
          _frenchCommands[0],    // Update and upgrade
          _frenchCommands[1],    // System info
          _frenchCommands[2],    // Clear screen
          _frenchCommands[3],    // Interrupt task
          _frenchCommands[4],    // Install Krita
          _frenchCommands[5],    // Uninstall Krita
          _frenchCommands[6],    // Install Kdenlive
          _frenchCommands[7],    // Uninstall Kdenlive
          _frenchCommands[8],    // Install Blender
          _frenchCommands[9],    // Uninstall Blender
          _frenchCommands[10],   // Install VS Code
          _frenchCommands[11],   // Uninstall VS Code
          {"name":"Installer LibreOffice", "command":"sudo apt update && sudo apt install -y libreoffice"},
          {"name":"Désinstaller LibreOffice", "command":"sudo apt autoremove --purge -y libreoffice"},
          {"name":"Installer WPS", "command":r"""cat << 'EOF' | sh && sudo dpkg --configure -a && sudo apt update && sudo apt install -y /tmp/wps.deb
wget https://github.com/xodiosx/XoDos2/releases/download/v1.0.1/wps-office_11.1.0.11720_arm64.deb -O /tmp/wps.deb
EOF
rm /tmp/wps.deb"""},
          {"name":"Désinstaller WPS", "command":"sudo apt autoremove --purge -y wps-office"},
          _frenchCommands[12],   // Enable recycle bin
          _frenchCommands[13],   // Clean package cache
          _frenchCommands[14],   // Shutdown
          _frenchCommands[15],   // matrix
        ]);
      case 'ru':
        return _getFullCommandSet([
          _russianCommands[0],   // Update and upgrade
          _russianCommands[1],   // System info
          _russianCommands[2],   // Clear screen
          _russianCommands[3],   // Interrupt task
          _russianCommands[4],   // Install Krita
          _russianCommands[5],   // Uninstall Krita
          _russianCommands[6],   // Install Kdenlive
          _russianCommands[7],   // Uninstall Kdenlive
          _russianCommands[8],   // Install Blender
          _russianCommands[9],   // Uninstall Blender
          _russianCommands[10],  // Install VS Code
          _russianCommands[11],  // Uninstall VS Code
          {"name":"Установить LibreOffice", "command":"sudo apt update && sudo apt install -y libreoffice"},
          {"name":"Удалить LibreOffice", "command":"sudo apt autoremove --purge -y libreoffice"},
          {"name":"Установить WPS", "command":r"""cat << 'EOF' | sh && sudo dpkg --configure -a && sudo apt update && sudo apt install -y /tmp/wps.deb
wget https://github.com/xodiosx/XoDos2/releases/download/v1.0.1/wps-office_11.1.0.11720_arm64.deb -O /tmp/wps.deb
EOF
rm /tmp/wps.deb"""},
          {"name":"Удалить WPS", "command":"sudo apt autoremove --purge -y wps-office"},
          _russianCommands[12],  // Enable recycle bin
          _russianCommands[13],  // Clean package cache
          _russianCommands[14],  // Shutdown
          _russianCommands[15],  // matrix
        ]);
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

  // Helper method to ensure all commands are present
  static List<Map<String, String>> _getFullCommandSet(List<Map<String, String>> commands) {
    // Ensure we have exactly 20 commands like the updated version
    if (commands.length >= 16) {
      return commands;
    }
    // If not, return the English commands as fallback
    return D.commands4En;
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
             name != "matrix" &&
             !name.contains("shutdown");
    }).toList();
    
    final systemCommands = commands.where((cmd) {
      final name = cmd["name"]?.toLowerCase() ?? "";
      return name.contains("shutdown") || name == "matrix";
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

  // Japanese commands - Updated with Blender and VS Code
  static const List<Map<String, String>> _japaneseCommands = [
    {"name":"パッケージの更新とアップグレード", "command":"sudo dpkg --configure -a && sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y"},
    {"name":"システム情報を表示", "command":"neofetch -L && neofetch --off"},
    {"name":"画面をクリア", "command":"clear"},
    {"name":"タスクを中断", "command":"\x03"},
    {"name":"グラフィックソフトKritaをインストール", "command":"sudo apt update && sudo apt install -y krita krita-l10n"},
    {"name":"Kritaをアンインストール", "command":"sudo apt autoremove --purge -y krita krita-l10n"},
    {"name":"動画編集ソフトKdenliveをインストール", "command":"sudo apt update && sudo apt install -y kdenlive"},
    {"name":"Kdenliveをアンインストール", "command":"sudo apt autoremove --purge -y kdenlive"},
    {"name":"3DモデリングソフトBlenderをインストール", "command":"sudo apt update && sudo apt install -y blender"},
    {"name":"Blenderをアンインストール", "command":"sudo apt autoremove --purge -y blender"},
    {"name":"コードエディタVisual Studio Codeをインストール", "command":r"""cat << 'EOF' | sh && sudo dpkg --configure -a && sudo apt update && sudo apt install -y /tmp/vscode.deb
wget https://update.code.visualstudio.com/latest/linux-deb-arm64/stable -O /tmp/vscode.deb
EOF
rm /tmp/vscode.deb"""},
    {"name":"Visual Studio Codeをアンインストール", "command":"sudo apt autoremove --purge -y code"},
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
    {"name":"matrix", "command":"timeout 8 cmatrix"}
  ];

  // Arabic commands - Updated with Blender and VS Code
  static const List<Map<String, String>> _arabicCommands = [
    {"name":"تحديث الحزم والترقية", "command":"sudo dpkg --configure -a && sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y"},
    {"name":"معلومات النظام", "command":"neofetch -L && neofetch --off"},
    {"name":"مسح الشاشة", "command":"clear"},
    {"name":"مقاطعة المهمة", "command":"\x03"},
    {"name":"تثبيت برنامج الرسم كريتا", "command":"sudo apt update && sudo apt install -y krita krita-l10n"},
    {"name":"إزالة كریتا", "command":"sudo apt autoremove --purge -y krita krita-l10n"},
    {"name":"تثبيت برنامج تحرير الفيديو كدينلايف", "command":"sudo apt update && sudo apt install -y kdenlive"},
    {"name":"إزالة كدينلايف", "command":"sudo apt autoremove --purge -y kdenlive"},
    {"name":"تثبيت برنامج النمذجة ثلاثية الأبعاد بلندر", "command":"sudo apt update && sudo apt install -y blender"},
    {"name":"إزالة بلندر", "command":"sudo apt autoremove --purge -y blender"},
    {"name":"تثبيت محرر الأكواد فيجوال ستوديو كود", "command":r"""cat << 'EOF' | sh && sudo dpkg --configure -a && sudo apt update && sudo apt install -y /tmp/vscode.deb
wget https://update.code.visualstudio.com/latest/linux-deb-arm64/stable -O /tmp/vscode.deb
EOF
rm /tmp/vscode.deb"""},
    {"name":"إزالة فيجوال ستوديو كود", "command":"sudo apt autoremove --purge -y code"},
    {"name":"تثبيت ليبر أوفيس", "command":"sudo apt update && sudo apt install -y libreoffice"},
    {"name":"إزالة ليبر أوفيس", "command":"sudo apt autoremove --purge -y libreoffice"},
    {"name":"تفعيل سلة المهملات", "command":"sudo apt update && sudo apt install -y gvfs && echo 'تم التثبيت، أعد تشغيل التطبيق لاستخدام سلة المهملات.'"},
    {"name":"تنظيف ذاكرة التخزين المؤقت", "command":"sudo apt clean"},
    {"name":"إيقاف التشغيل", "command":"stopvnc\nexit\nexit"},
    {"name":"matrix", "command":"timeout 8 cmatrix"}
  ];

  // Hindi commands - Updated with Blender and VS Code
  static const List<Map<String, String>> _hindiCommands = [
    {"name":"पैकेज अपडेट और अपग्रेड", "command":"sudo dpkg --configure -a && sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y"},
    {"name":"सिस्टम जानकारी", "command":"neofetch -L && neofetch --off"},
    {"name":"स्क्रीन साफ करें", "command":"clear"},
    {"name":"कार्य बाधित करें", "command":"\x03"},
    {"name":"ग्राफिक सॉफ्टवेयर क्रिता इंस्टॉल करें", "command":"sudo apt update && sudo apt install -y krita krita-l10n"},
    {"name":"क्रिता अनइंस्टॉल करें", "command":"sudo apt autoremove --purge -y krita krita-l10n"},
    {"name":"वीडियो एडिटिंग सॉफ्टवेयर केडेनलाइव इंस्टॉल करें", "command":"sudo apt update && sudo apt install -y kdenlive"},
    {"name":"केडेनलाइव अनइंस्टॉल करें", "command":"sudo apt autoremove --purge -y kdenlive"},
    {"name":"3D मॉडलिंग सॉफ्टवेयर ब्लेंडर इंस्टॉल करें", "command":"sudo apt update && sudo apt install -y blender"},
    {"name":"ब्लेंडर अनइंस्टॉल करें", "command":"sudo apt autoremove --purge -y blender"},
    {"name":"कोड एडिटर विजुअल स्टूडियो कोड इंस्टॉल करें", "command":r"""cat << 'EOF' | sh && sudo dpkg --configure -a && sudo apt update && sudo apt install -y /tmp/vscode.deb
wget https://update.code.visualstudio.com/latest/linux-deb-arm64/stable -O /tmp/vscode.deb
EOF
rm /tmp/vscode.deb"""},
    {"name":"विजुअल स्टूडियो कोड अनइंस्टॉल करें", "command":"sudo apt autoremove --purge -y code"},
    {"name":"रीसाइकिल बिन सक्षम करें", "command":"sudo apt update && sudo apt install -y gvfs && echo 'इंस्टॉलेशन पूर्ण, रीसाइकिल बिन का उपयोग करने के लिए ऐप को पुनरारंभ करें।'"},
    {"name":"पैकेज कैश साफ करें", "command":"sudo apt clean"},
    {"name":"शटडाउन", "command":"stopvnc\nexit\nexit"},
    {"name":"matrix", "command":"timeout 8 cmatrix"}
  ];

  // Spanish commands - Updated with Blender and VS Code
  static const List<Map<String, String>> _spanishCommands = [
    {"name":"Actualizar y mejorar paquetes", "command":"sudo dpkg --configure -a && sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y"},
    {"name":"Información del sistema", "command":"neofetch -L && neofetch --off"},
    {"name":"Limpiar pantalla", "command":"clear"},
    {"name":"Interrumpir tarea", "command":"\x03"},
    {"name":"Instalar software gráfico Krita", "command":"sudo apt update && sudo apt install -y krita krita-l10n"},
    {"name":"Desinstalar Krita", "command":"sudo apt autoremove --purge -y krita krita-l10n"},
    {"name":"Instalar editor de video Kdenlive", "command":"sudo apt update && sudo apt install -y kdenlive"},
    {"name":"Desinstalar Kdenlive", "command":"sudo apt autoremove --purge -y kdenlive"},
    {"name":"Instalar software de modelado 3D Blender", "command":"sudo apt update && sudo apt install -y blender"},
    {"name":"Desinstalar Blender", "command":"sudo apt autoremove --purge -y blender"},
    {"name":"Instalar editor de código Visual Studio Code", "command":r"""cat << 'EOF' | sh && sudo dpkg --configure -a && sudo apt update && sudo apt install -y /tmp/vscode.deb
wget https://update.code.visualstudio.com/latest/linux-deb-arm64/stable -O /tmp/vscode.deb
EOF
rm /tmp/vscode.deb"""},
    {"name":"Desinstalar Visual Studio Code", "command":"sudo apt autoremove --purge -y code"},
    {"name":"Habilitar papelera de reciclaje", "command":"sudo apt update && sudo apt install -y gvfs && echo 'Instalación completa, reinicie la aplicación para usar la papelera de reciclaje.'"},
    {"name":"Limpiar caché de paquetes", "command":"sudo apt clean"},
    {"name":"Apagar", "command":"stopvnc\nexit\nexit"},
    {"name":"matrix", "command":"timeout 8 cmatrix"}
  ];

  // Portuguese commands - Updated with Blender and VS Code
  static const List<Map<String, String>> _portugueseCommands = [
    {"name":"Atualizar y mejorar pacotes", "command":"sudo dpkg --configure -a && sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y"},
    {"name":"Informações do sistema", "command":"neofetch -L && neofetch --off"},
    {"name":"Limpar tela", "command":"clear"},
    {"name":"Interromper tarefa", "command":"\x03"},
    {"name":"Instalar software gráfico Krita", "command":"sudo apt update && sudo apt install -y krita krita-l10n"},
    {"name":"Desinstalar Krita", "command":"sudo apt autoremove --purge -y krita krita-l10n"},
    {"name":"Instalar editor de vídeo Kdenlive", "command":"sudo apt update && sudo apt install -y kdenlive"},
    {"name":"Desinstalar Kdenlive", "command":"sudo apt autoremove --purge -y kdenlive"},
    {"name":"Instalar software de modelagem 3D Blender", "command":"sudo apt update && sudo apt install -y blender"},
    {"name":"Desinstalar Blender", "command":"sudo apt autoremove --purge -y blender"},
    {"name":"Instalar editor de código Visual Studio Code", "command":r"""cat << 'EOF' | sh && sudo dpkg --configure -a && sudo apt update && sudo apt install -y /tmp/vscode.deb
wget https://update.code.visualstudio.com/latest/linux-deb-arm64/stable -O /tmp/vscode.deb
EOF
rm /tmp/vscode.deb"""},
    {"name":"Desinstalar Visual Studio Code", "command":"sudo apt autoremove --purge -y code"},
    {"name":"Habilitar lixeira", "command":"sudo apt update && sudo apt install -y gvfs && echo 'Instalação completa, reinicie o aplicativo para usar a lixeira.'"},
    {"name":"Limpar cache de pacotes", "command":"sudo apt clean"},
    {"name":"Desligar", "command":"stopvnc\nexit\nexit"},
    {"name":"matrix", "command":"timeout 8 cmatrix"}
  ];

  // French commands - Updated with Blender and VS Code
  static const List<Map<String, String>> _frenchCommands = [
    {"name":"Mettre à jour et améliorer les paquets", "command":"sudo dpkg --configure -a && sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y"},
    {"name":"Informations système", "command":"neofetch -L && neofetch --off"},
    {"name":"Effacer l'écran", "command":"clear"},
    {"name":"Interrompre la tâche", "command":"\x03"},
    {"name":"Installer le logiciel graphique Krita", "command":"sudo apt update && sudo apt install -y krita krita-l10n"},
    {"name":"Désinstaller Krita", "command":"sudo apt autoremove --purge -y krita krita-l10n"},
    {"name":"Installer l'éditeur vidéo Kdenlive", "command":"sudo apt update && sudo apt install -y kdenlive"},
    {"name":"Désinstaller Kdenlive", "command":"sudo apt autoremove --purge -y kdenlive"},
    {"name":"Installer le logiciel de modélisation 3D Blender", "command":"sudo apt update && sudo apt install -y blender"},
    {"name":"Désinstaller Blender", "command":"sudo apt autoremove --purge -y blender"},
    {"name":"Installer l'éditeur de code Visual Studio Code", "command":r"""cat << 'EOF' | sh && sudo dpkg --configure -a && sudo apt update && sudo apt install -y /tmp/vscode.deb
wget https://update.code.visualstudio.com/latest/linux-deb-arm64/stable -O /tmp/vscode.deb
EOF
rm /tmp/vscode.deb"""},
    {"name":"Désinstaller Visual Studio Code", "command":"sudo apt autoremove --purge -y code"},
    {"name":"Activer la corbeille", "command":"sudo apt update && sudo apt install -y gvfs && echo 'Installation terminée, redémarrez l\\'application pour utiliser la corbeille.'"},
    {"name":"Nettoyer le cache des paquets", "command":"sudo apt clean"},
    {"name":"Éteindre", "command":"stopvnc\nexit\nexit"},
    {"name":"matrix", "command":"timeout 8 cmatrix"}
  ];

  // Russian commands - Updated with Blender and VS Code
  static const List<Map<String, String>> _russianCommands = [
    {"name":"Обновить и улучшить пакеты", "command":"sudo dpkg --configure -a && sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y"},
    {"name":"Информация о системе", "command":"neofetch -L && neofetch --off"},
    {"name":"Очистить экран", "command":"clear"},
    {"name":"Прервать задачу", "command":"\x03"},
    {"name":"Установить графическое ПО Krita", "command":"sudo apt update && sudo apt install -y krita krita-l10n"},
    {"name":"Удалить Krita", "command":"sudo apt autoremove --purge -y krita krita-l10n"},
    {"name":"Установить видеоредактор Kdenlive", "command":"sudo apt update && sudo apt install -y kdenlive"},
    {"name":"Удалить Kdenlive", "command":"sudo apt autoremove --purge -y kdenlive"},
    {"name":"Установить 3D-моделирование Blender", "command":"sudo apt update && sudo apt install -y blender"},
    {"name":"Удалить Blender", "command":"sudo apt autoremove --purge -y blender"},
    {"name":"Установить редактор кода Visual Studio Code", "command":r"""cat << 'EOF' | sh && sudo dpkg --configure -a && sudo apt update && sudo apt install -y /tmp/vscode.deb
wget https://update.code.visualstudio.com/latest/linux-deb-arm64/stable -O /tmp/vscode.deb
EOF
rm /tmp/vscode.deb"""},
    {"name":"Удалить Visual Studio Code", "command":"sudo apt autoremove --purge -y code"},
    {"name":"Включить корзину", "command":"sudo apt update && sudo apt install -y gvfs && echo 'Установка завершена, перезапустите приложение для использования корзины.'"},
    {"name":"Очистить кэш пакетов", "command":"sudo apt clean"},
    {"name":"Выключить", "command":"stopvnc\nexit\nexit"},
    {"name":"matrix", "command":"timeout 8 cmatrix"}
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