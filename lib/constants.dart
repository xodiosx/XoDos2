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

  /// Returns the full list of quick commands for the given language.
  /// The list contains exactly the same commands as the English version,
  /// with names translated where available; missing translations fall back to English.
  static List<Map<String, String>> getCommandsForLanguage(String languageCode) {
    // Start with the English command list (full set)
    final List<Map<String, String>> englishCommands = D.commands4En;

    // If language is English, return as is
    if (languageCode == 'en') {
      return englishCommands;
    }

    // Get the translation map for this language (or empty if none)
    final Map<String, String> translationMap = _getTranslationMap(languageCode);

    // Build the translated list
    return englishCommands.map((cmd) {
      final String englishName = cmd['name']!;
      final String translatedName = translationMap[englishName] ?? englishName;
      return {
        'name': translatedName,
        'command': cmd['command']!,
      };
    }).toList();
  }

  /// Returns the full list of Wine commands for the given language.
  /// The list contains exactly the same commands as the English version,
  /// with names translated where available; missing translations fall back to English.
  static List<Map<String, String>> getWineCommandsForLanguage(String languageCode) {
    // Start with the English Wine command list (full set)
    final List<Map<String, String>> englishWineCommands = D.wineCommands4En;

    // If language is English, return as is
    if (languageCode == 'en') {
      return englishWineCommands;
    }

    // Get the translation map for Wine commands for this language
    final Map<String, String> wineTranslationMap = _getWineTranslationMap(languageCode);

    // Build the translated list
    return englishWineCommands.map((cmd) {
      final String englishName = cmd['name']!;
      final String translatedName = wineTranslationMap[englishName] ?? englishName;
      return {
        'name': translatedName,
        'command': cmd['command']!,
      };
    }).toList();
  }

  // ==================== Translation Maps ====================

  /// Returns a map from English command name to translated name for quick commands.
  static Map<String, String> _getTranslationMap(String languageCode) {
    switch (languageCode) {
      case 'zh':
        return _chineseTranslations;
      case 'ja':
        return _japaneseTranslations;
      case 'ar':
        return _arabicTranslations;
      case 'hi':
        return _hindiTranslations;
      case 'es':
        return _spanishTranslations;
      case 'pt':
        return _portugueseTranslations;
      case 'fr':
        return _frenchTranslations;
      case 'ru':
        return _russianTranslations;
      default:
        return {};
    }
  }

  /// Returns a map from English Wine command name to translated name.
  static Map<String, String> _getWineTranslationMap(String languageCode) {
    switch (languageCode) {
      case 'zh':
        return _chineseWineTranslations;
      case 'ja':
        return _japaneseWineTranslations;
      case 'ar':
        return _arabicWineTranslations;
      case 'hi':
        return _hindiWineTranslations;
      case 'es':
        return _spanishWineTranslations;
      case 'pt':
        return _portugueseWineTranslations;
      case 'fr':
        return _frenchWineTranslations;
      case 'ru':
        return _russianWineTranslations;
      default:
        return {};
    }
  }

  // ----- Quick Command Translations -----

  static const Map<String, String> _chineseTranslations = {
    'Update Packages': '检查更新并升级',
    'System Info': '显示系统信息',
    'Clear': '清屏',
    'Interrupt': '中断任务',
    'Install Painting Program Krita': '安装图形软件 Krita',
    'Uninstall Krita': '卸载 Krita',
    'Install KDE Non-Linear Video Editor': '安装视频编辑软件 Kdenlive',
    'Uninstall Kdenlive': '卸载 Kdenlive',
    'Install 3D Modeling Software Blender': '安装 3D 建模软件 Blender',
    'Uninstall Blender': '卸载 Blender',
    'Install Code Editor Visual Studio Code': '安装代码编辑器 Visual Studio Code',
    'Uninstall Visual Studio Code': '卸载 Visual Studio Code',
    'Install LibreOffice': '安装 LibreOffice',
    'Uninstall LibreOffice': '卸载 LibreOffice',
    'Install WPS': '安装 WPS',
    'Uninstall WPS': '卸载 WPS',
    'Install Legcord (Lightweight Discord)': '安装 Legcord (轻量级 Discord)',
    'Uninstall Legcord': '卸载 Legcord',
    'Install Dorion (Discord Lite)': '安装 Dorion (Discord Lite)',
    'Uninstall Dorion': '卸载 Dorion',
    'Install WhatsApp': '安装 WhatsApp',
    'Uninstall WhatsApp': '卸载 WhatsApp',
    'Install Telegram Desktop': '安装 Telegram Desktop',
    'Uninstall Telegram Desktop': '卸载 Telegram Desktop',
    'Install EdrawMax': '安装 EdrawMax',
    'Uninstall EdrawMax': '卸载 EdrawMax',
    // New commands
    'Install Antigravity': '安装 Antigravity',
    'Uninstall Antigravity': '卸载 Antigravity',
    'Install Brave Browser': '安装 Brave 浏览器',
    'Uninstall Brave Browser': '卸载 Brave 浏览器',
    'Install Cursor': '安装 Cursor',
    'Uninstall Cursor': '卸载 Cursor',
    'Enable Recycle Bin': '启用回收站',
    'Clean Package Cache': '清理包管理器缓存',
    'Power Off': '关机',
    'matrix': 'matrix',
  };

  static const Map<String, String> _japaneseTranslations = {
    'Update Packages': 'パッケージの更新とアップグレード',
    'System Info': 'システム情報を表示',
    'Clear': '画面をクリア',
    'Interrupt': 'タスクを中断',
    'Install Painting Program Krita': 'グラフィックソフトKritaをインストール',
    'Uninstall Krita': 'Kritaをアンインストール',
    'Install KDE Non-Linear Video Editor': '動画編集ソフトKdenliveをインストール',
    'Uninstall Kdenlive': 'Kdenliveをアンインストール',
    'Install 3D Modeling Software Blender': '3DモデリングソフトBlenderをインストール',
    'Uninstall Blender': 'Blenderをアンインストール',
    'Install Code Editor Visual Studio Code': 'コードエディタVisual Studio Codeをインストール',
    'Uninstall Visual Studio Code': 'Visual Studio Codeをアンインストール',
    'Install LibreOffice': 'LibreOfficeをインストール',
    'Uninstall LibreOffice': 'LibreOfficeをアンインストール',
    'Install WPS': 'WPSをインストール',
    'Uninstall WPS': 'WPSをアンインストール',
    'Install Legcord (Lightweight Discord)': 'Legcordをインストール',
    'Uninstall Legcord': 'Legcordをアンインストール',
    'Install Dorion (Discord Lite)': 'Dorionをインストール',
    'Uninstall Dorion': 'Dorionをアンインストール',
    'Install WhatsApp': 'WhatsAppをインストール',
    'Uninstall WhatsApp': 'WhatsAppをアンインストール',
    'Install Telegram Desktop': 'Telegram Desktopをインストール',
    'Uninstall Telegram Desktop': 'Telegram Desktopをアンインストール',
    'Install EdrawMax': 'EdrawMaxをインストール',
    'Uninstall EdrawMax': 'EdrawMaxをアンインストール',
    // New commands
    'Install Antigravity': 'Antigravityをインストール',
    'Uninstall Antigravity': 'Antigravityをアンインストール',
    'Install Brave Browser': 'Braveブラウザをインストール',
    'Uninstall Brave Browser': 'Braveブラウザをアンインストール',
    'Install Cursor': 'Cursorをインストール',
    'Uninstall Cursor': 'Cursorをアンインストール',
    'Enable Recycle Bin': 'ごみ箱を有効にする',
    'Clean Package Cache': 'パッケージキャッシュをクリーン',
    'Power Off': 'シャットダウン',
    'matrix': 'matrix',
  };

  static const Map<String, String> _arabicTranslations = {
    'Update Packages': 'تحديث الحزم والترقية',
    'System Info': 'معلومات النظام',
    'Clear': 'مسح الشاشة',
    'Interrupt': 'مقاطعة المهمة',
    'Install Painting Program Krita': 'تثبيت برنامج الرسم كريتا',
    'Uninstall Krita': 'إزالة كریتا',
    'Install KDE Non-Linear Video Editor': 'تثبيت برنامج تحرير الفيديو كدينلايف',
    'Uninstall Kdenlive': 'إزالة كدينلايف',
    'Install 3D Modeling Software Blender': 'تثبيت برنامج النمذجة ثلاثية الأبعاد بلندر',
    'Uninstall Blender': 'إزالة بلندر',
    'Install Code Editor Visual Studio Code': 'تثبيت محرر الأكواد فيجوال ستوديو كود',
    'Uninstall Visual Studio Code': 'إزالة فيجوال ستوديو كود',
    'Install LibreOffice': 'تثبيت ليبر أوفيس',
    'Uninstall LibreOffice': 'إزالة ليبر أوفيس',
    'Install WPS': 'تثبيت WPS',
    'Uninstall WPS': 'إزالة WPS',
    'Install Legcord (Lightweight Discord)': 'تثبيت Legcord',
    'Uninstall Legcord': 'إزالة Legcord',
    'Install Dorion (Discord Lite)': 'تثبيت Dorion',
    'Uninstall Dorion': 'إزالة Dorion',
    'Install WhatsApp': 'تثبيت WhatsApp',
    'Uninstall WhatsApp': 'إزالة WhatsApp',
    'Install Telegram Desktop': 'تثبيت Telegram Desktop',
    'Uninstall Telegram Desktop': 'إزالة Telegram Desktop',
    'Install EdrawMax': 'تثبيت EdrawMax',
    'Uninstall EdrawMax': 'إزالة EdrawMax',
    // New commands
    'Install Antigravity': 'تثبيت Antigravity',
    'Uninstall Antigravity': 'إزالة Antigravity',
    'Install Brave Browser': 'تثبيت متصفح Brave',
    'Uninstall Brave Browser': 'إزالة متصفح Brave',
    'Install Cursor': 'تثبيت Cursor',
    'Uninstall Cursor': 'إزالة Cursor',
    'Enable Recycle Bin': 'تفعيل سلة المهملات',
    'Clean Package Cache': 'تنظيف ذاكرة التخزين المؤقت',
    'Power Off': 'إيقاف التشغيل',
    'matrix': 'matrix',
  };

  static const Map<String, String> _hindiTranslations = {
    'Update Packages': 'पैकेज अपडेट और अपग्रेड',
    'System Info': 'सिस्टम जानकारी',
    'Clear': 'स्क्रीन साफ करें',
    'Interrupt': 'कार्य बाधित करें',
    'Install Painting Program Krita': 'ग्राफिक सॉफ्टवेयर क्रिता इंस्टॉल करें',
    'Uninstall Krita': 'क्रिता अनइंस्टॉल करें',
    'Install KDE Non-Linear Video Editor': 'वीडियो एडिटिंग सॉफ्टवेयर केडेनलाइव इंस्टॉल करें',
    'Uninstall Kdenlive': 'केडेनलाइव अनइंस्टॉल करें',
    'Install 3D Modeling Software Blender': '3D मॉडलिंग सॉफ्टवेयर ब्लेंडर इंस्टॉल करें',
    'Uninstall Blender': 'ब्लेंडर अनइंस्टॉल करें',
    'Install Code Editor Visual Studio Code': 'कोड एडिटर विजुअल स्टूडियो कोड इंस्टॉल करें',
    'Uninstall Visual Studio Code': 'विजुअल स्टूडियो कोड अनइंस्टॉल करें',
    'Install LibreOffice': 'LibreOffice इंस्टॉल करें',
    'Uninstall LibreOffice': 'LibreOffice अनइंस्टॉल करें',
    'Install WPS': 'WPS इंस्टॉल करें',
    'Uninstall WPS': 'WPS अनइंस्टॉल करें',
    'Install Legcord (Lightweight Discord)': 'Legcord इंस्टॉल करें',
    'Uninstall Legcord': 'Legcord अनइंस्टॉल करें',
    'Install Dorion (Discord Lite)': 'Dorion इंस्टॉल करें',
    'Uninstall Dorion': 'Dorion अनइंस्टॉल करें',
    'Install WhatsApp': 'WhatsApp इंस्टॉल करें',
    'Uninstall WhatsApp': 'WhatsApp अनइंस्टॉल करें',
    'Install Telegram Desktop': 'Telegram Desktop इंस्टॉल करें',
    'Uninstall Telegram Desktop': 'Telegram Desktop अनइंस्टॉल करें',
    'Install EdrawMax': 'EdrawMax इंस्टॉल करें',
    'Uninstall EdrawMax': 'EdrawMax अनइंस्टॉल करें',
    // New commands
    'Install Antigravity': 'Antigravity इंस्टॉल करें',
    'Uninstall Antigravity': 'Antigravity अनइंस्टॉल करें',
    'Install Brave Browser': 'Brave ब्राउज़र इंस्टॉल करें',
    'Uninstall Brave Browser': 'Brave ब्राउज़र अनइंस्टॉल करें',
    'Install Cursor': 'Cursor इंस्टॉल करें',
    'Uninstall Cursor': 'Cursor अनइंस्टॉल करें',
    'Enable Recycle Bin': 'रीसाइकिल बिन सक्षम करें',
    'Clean Package Cache': 'पैकेज कैश साफ करें',
    'Power Off': 'शटडाउन',
    'matrix': 'matrix',
  };

  static const Map<String, String> _spanishTranslations = {
    'Update Packages': 'Actualizar y mejorar paquetes',
    'System Info': 'Información del sistema',
    'Clear': 'Limpiar pantalla',
    'Interrupt': 'Interrumpir tarea',
    'Install Painting Program Krita': 'Instalar software gráfico Krita',
    'Uninstall Krita': 'Desinstalar Krita',
    'Install KDE Non-Linear Video Editor': 'Instalar editor de video Kdenlive',
    'Uninstall Kdenlive': 'Desinstalar Kdenlive',
    'Install 3D Modeling Software Blender': 'Instalar software de modelado 3D Blender',
    'Uninstall Blender': 'Desinstalar Blender',
    'Install Code Editor Visual Studio Code': 'Instalar editor de código Visual Studio Code',
    'Uninstall Visual Studio Code': 'Desinstalar Visual Studio Code',
    'Install LibreOffice': 'Instalar LibreOffice',
    'Uninstall LibreOffice': 'Desinstalar LibreOffice',
    'Install WPS': 'Instalar WPS',
    'Uninstall WPS': 'Desinstalar WPS',
    'Install Legcord (Lightweight Discord)': 'Instalar Legcord',
    'Uninstall Legcord': 'Desinstalar Legcord',
    'Install Dorion (Discord Lite)': 'Instalar Dorion',
    'Uninstall Dorion': 'Desinstalar Dorion',
    'Install WhatsApp': 'Instalar WhatsApp',
    'Uninstall WhatsApp': 'Desinstalar WhatsApp',
    'Install Telegram Desktop': 'Instalar Telegram Desktop',
    'Uninstall Telegram Desktop': 'Desinstalar Telegram Desktop',
    'Install EdrawMax': 'Instalar EdrawMax',
    'Uninstall EdrawMax': 'Desinstalar EdrawMax',
    // New commands
    'Install Antigravity': 'Instalar Antigravity',
    'Uninstall Antigravity': 'Desinstalar Antigravity',
    'Install Brave Browser': 'Instalar Brave Browser',
    'Uninstall Brave Browser': 'Desinstalar Brave Browser',
    'Install Cursor': 'Instalar Cursor',
    'Uninstall Cursor': 'Desinstalar Cursor',
    'Enable Recycle Bin': 'Habilitar papelera de reciclaje',
    'Clean Package Cache': 'Limpiar caché de paquetes',
    'Power Off': 'Apagar',
    'matrix': 'matrix',
  };

  static const Map<String, String> _portugueseTranslations = {
    'Update Packages': 'Atualizar e melhorar pacotes',
    'System Info': 'Informações do sistema',
    'Clear': 'Limpar tela',
    'Interrupt': 'Interromper tarefa',
    'Install Painting Program Krita': 'Instalar software gráfico Krita',
    'Uninstall Krita': 'Desinstalar Krita',
    'Install KDE Non-Linear Video Editor': 'Instalar editor de vídeo Kdenlive',
    'Uninstall Kdenlive': 'Desinstalar Kdenlive',
    'Install 3D Modeling Software Blender': 'Instalar software de modelagem 3D Blender',
    'Uninstall Blender': 'Desinstalar Blender',
    'Install Code Editor Visual Studio Code': 'Instalar editor de código Visual Studio Code',
    'Uninstall Visual Studio Code': 'Desinstalar Visual Studio Code',
    'Install LibreOffice': 'Instalar LibreOffice',
    'Uninstall LibreOffice': 'Desinstalar LibreOffice',
    'Install WPS': 'Instalar WPS',
    'Uninstall WPS': 'Desinstalar WPS',
    'Install Legcord (Lightweight Discord)': 'Instalar Legcord',
    'Uninstall Legcord': 'Desinstalar Legcord',
    'Install Dorion (Discord Lite)': 'Instalar Dorion',
    'Uninstall Dorion': 'Desinstalar Dorion',
    'Install WhatsApp': 'Instalar WhatsApp',
    'Uninstall WhatsApp': 'Desinstalar WhatsApp',
    'Install Telegram Desktop': 'Instalar Telegram Desktop',
    'Uninstall Telegram Desktop': 'Desinstalar Telegram Desktop',
    'Install EdrawMax': 'Instalar EdrawMax',
    'Uninstall EdrawMax': 'Desinstalar EdrawMax',
    // New commands
    'Install Antigravity': 'Instalar Antigravity',
    'Uninstall Antigravity': 'Desinstalar Antigravity',
    'Install Brave Browser': 'Instalar Brave Browser',
    'Uninstall Brave Browser': 'Desinstalar Brave Browser',
    'Install Cursor': 'Instalar Cursor',
    'Uninstall Cursor': 'Desinstalar Cursor',
    'Enable Recycle Bin': 'Habilitar lixeira',
    'Clean Package Cache': 'Limpar cache de pacotes',
    'Power Off': 'Desligar',
    'matrix': 'matrix',
  };

  static const Map<String, String> _frenchTranslations = {
    'Update Packages': 'Mettre à jour et améliorer les paquets',
    'System Info': 'Informations système',
    'Clear': 'Effacer l\'écran',
    'Interrupt': 'Interrompre la tâche',
    'Install Painting Program Krita': 'Installer le logiciel graphique Krita',
    'Uninstall Krita': 'Désinstaller Krita',
    'Install KDE Non-Linear Video Editor': 'Installer l\'éditeur vidéo Kdenlive',
    'Uninstall Kdenlive': 'Désinstaller Kdenlive',
    'Install 3D Modeling Software Blender': 'Installer le logiciel de modélisation 3D Blender',
    'Uninstall Blender': 'Désinstaller Blender',
    'Install Code Editor Visual Studio Code': 'Installer l\'éditeur de code Visual Studio Code',
    'Uninstall Visual Studio Code': 'Désinstaller Visual Studio Code',
    'Install LibreOffice': 'Installer LibreOffice',
    'Uninstall LibreOffice': 'Désinstaller LibreOffice',
    'Install WPS': 'Installer WPS',
    'Uninstall WPS': 'Désinstaller WPS',
    'Install Legcord (Lightweight Discord)': 'Installer Legcord',
    'Uninstall Legcord': 'Désinstaller Legcord',
    'Install Dorion (Discord Lite)': 'Installer Dorion',
    'Uninstall Dorion': 'Désinstaller Dorion',
    'Install WhatsApp': 'Installer WhatsApp',
    'Uninstall WhatsApp': 'Désinstaller WhatsApp',
    'Install Telegram Desktop': 'Installer Telegram Desktop',
    'Uninstall Telegram Desktop': 'Désinstaller Telegram Desktop',
    'Install EdrawMax': 'Installer EdrawMax',
    'Uninstall EdrawMax': 'Désinstaller EdrawMax',
    // New commands
    'Install Antigravity': 'Installer Antigravity',
    'Uninstall Antigravity': 'Désinstaller Antigravity',
    'Install Brave Browser': 'Installer Brave Browser',
    'Uninstall Brave Browser': 'Désinstaller Brave Browser',
    'Install Cursor': 'Installer Cursor',
    'Uninstall Cursor': 'Désinstaller Cursor',
    'Enable Recycle Bin': 'Activer la corbeille',
    'Clean Package Cache': 'Nettoyer le cache des paquets',
    'Power Off': 'Éteindre',
    'matrix': 'matrix',
  };

  static const Map<String, String> _russianTranslations = {
    'Update Packages': 'Обновить и улучшить пакеты',
    'System Info': 'Информация о системе',
    'Clear': 'Очистить экран',
    'Interrupt': 'Прервать задачу',
    'Install Painting Program Krita': 'Установить графическое ПО Krita',
    'Uninstall Krita': 'Удалить Krita',
    'Install KDE Non-Linear Video Editor': 'Установить видеоредактор Kdenlive',
    'Uninstall Kdenlive': 'Удалить Kdenlive',
    'Install 3D Modeling Software Blender': 'Установить 3D-моделирование Blender',
    'Uninstall Blender': 'Удалить Blender',
    'Install Code Editor Visual Studio Code': 'Установить редактор кода Visual Studio Code',
    'Uninstall Visual Studio Code': 'Удалить Visual Studio Code',
    'Install LibreOffice': 'Установить LibreOffice',
    'Uninstall LibreOffice': 'Удалить LibreOffice',
    'Install WPS': 'Установить WPS',
    'Uninstall WPS': 'Удалить WPS',
    'Install Legcord (Lightweight Discord)': 'Установить Legcord',
    'Uninstall Legcord': 'Удалить Legcord',
    'Install Dorion (Discord Lite)': 'Установить Dorion',
    'Uninstall Dorion': 'Удалить Dorion',
    'Install WhatsApp': 'Установить WhatsApp',
    'Uninstall WhatsApp': 'Удалить WhatsApp',
    'Install Telegram Desktop': 'Установить Telegram Desktop',
    'Uninstall Telegram Desktop': 'Удалить Telegram Desktop',
    'Install EdrawMax': 'Установить EdrawMax',
    'Uninstall EdrawMax': 'Удалить EdrawMax',
    // New commands
    'Install Antigravity': 'Установить Antigravity',
    'Uninstall Antigravity': 'Удалить Antigravity',
    'Install Brave Browser': 'Установить Brave Browser',
    'Uninstall Brave Browser': 'Удалить Brave Browser',
    'Install Cursor': 'Установить Cursor',
    'Uninstall Cursor': 'Удалить Cursor',
    'Enable Recycle Bin': 'Включить корзину',
    'Clean Package Cache': 'Очистить кэш пакетов',
    'Power Off': 'Выключить',
    'matrix': 'matrix',
  };

  // ----- Wine Command Translations -----

  static const Map<String, String> _chineseWineTranslations = {
    'wine Configuration': 'wine 配置',
    'Fix CJK Characters': '修复方块字符',
    'Start Menu Dir': '开始菜单文件夹',
    'Remove Wine': '删除 Wine',
    'Enable DXVK': '启用 DXVK',
    'Disable DXVK': '禁用 DXVK',
    'Explorer': '我的电脑',
    'Notepad': '记事本',
    'Minesweeper': '扫雷',
    'Regedit': '注册表编辑器',
    'Control Panel': '控制面板',
    'File Manager': '文件管理器',
    'Task Manager': '任务管理器',
    'Internet Explorer': 'IE 浏览器',
    'Kill wine Process': '强制关闭 Wine',
  };

  static const Map<String, String> _japaneseWineTranslations = {
    'wine Configuration': 'Wine設定',
    'Fix CJK Characters': '文字化け修正',
    'Start Menu Dir': 'スタートメニューフォルダ',
    'Remove Wine': 'Wineを削除',
    'Enable DXVK': 'DXVKを有効',
    'Disable DXVK': 'DXVKを無効',
    'Explorer': 'エクスプローラ',
    'Notepad': 'メモ帳',
    'Minesweeper': 'マインスイーパ',
    'Regedit': 'レジストリエディタ',
    'Control Panel': 'コントロールパネル',
    'File Manager': 'ファイルマネージャ',
    'Task Manager': 'タスクマネージャ',
    'Internet Explorer': 'インターネットエクスプローラ',
    'Kill wine Process': 'Wineプロセスを強制終了',
  };

  static const Map<String, String> _arabicWineTranslations = {
    'wine Configuration': 'إعدادات Wine',
    'Fix CJK Characters': 'إصلاح الأحرف',
    'Start Menu Dir': 'مجلد قائمة ابدأ',
    'Remove Wine': 'إزالة Wine',
    'Enable DXVK': 'تمكين DXVK',
    'Disable DXVK': 'تعطيل DXVK',
    'Explorer': 'المستكشف',
    'Notepad': 'المفكرة',
    'Minesweeper': 'الكانسة ألغام',
    'Regedit': 'محرر التسجيل',
    'Control Panel': 'لوحة التحكم',
    'File Manager': 'مدير الملفات',
    'Task Manager': 'مدير المهام',
    'Internet Explorer': 'إنترنت إكسبلورر',
    'Kill wine Process': 'إنهاء عملية Wine',
  };

  static const Map<String, String> _hindiWineTranslations = {
    'wine Configuration': 'Wine सेटिंग्स',
    'Fix CJK Characters': 'वर्ण सुधार',
    'Start Menu Dir': 'स्टार्ट मेनू फोल्डर',
    'Remove Wine': 'Wine हटाएं',
    'Enable DXVK': 'DXVK सक्षम करें',
    'Disable DXVK': 'DXVK अक्षम करें',
    'Explorer': 'एक्सप्लोरर',
    'Notepad': 'नोटपैड',
    'Minesweeper': 'माइनस्वीपर',
    'Regedit': 'रजिस्ट्री संपादक',
    'Control Panel': 'नियंत्रण कक्ष',
    'File Manager': 'फ़ाइल प्रबंधक',
    'Task Manager': 'कार्य प्रबंधक',
    'Internet Explorer': 'इंटरनेट एक्सप्लोरर',
    'Kill wine Process': 'Wine प्रक्रिया समाप्त करें',
  };

  static const Map<String, String> _spanishWineTranslations = {
    'wine Configuration': 'Configuración de Wine',
    'Fix CJK Characters': 'Reparar caracteres',
    'Start Menu Dir': 'Carpeta del menú Inicio',
    'Remove Wine': 'Eliminar Wine',
    'Enable DXVK': 'Habilitar DXVK',
    'Disable DXVK': 'Deshabilitar DXVK',
    'Explorer': 'Explorador',
    'Notepad': 'Bloc de notas',
    'Minesweeper': 'Buscaminas',
    'Regedit': 'Editor de registro',
    'Control Panel': 'Panel de control',
    'File Manager': 'Administrador de archivos',
    'Task Manager': 'Administrador de tareas',
    'Internet Explorer': 'Internet Explorer',
    'Kill wine Process': 'Matar proceso de Wine',
  };

  static const Map<String, String> _portugueseWineTranslations = {
    'wine Configuration': 'Configurações do Wine',
    'Fix CJK Characters': 'Reparar caracteres',
    'Start Menu Dir': 'Pasta do menu Iniciar',
    'Remove Wine': 'Remover Wine',
    'Enable DXVK': 'Habilitar DXVK',
    'Disable DXVK': 'Desabilitar DXVK',
    'Explorer': 'Explorador',
    'Notepad': 'Bloco de notas',
    'Minesweeper': 'Campo minado',
    'Regedit': 'Editor de registro',
    'Control Panel': 'Painel de controle',
    'File Manager': 'Gerenciador de arquivos',
    'Task Manager': 'Gerenciador de tarefas',
    'Internet Explorer': 'Internet Explorer',
    'Kill wine Process': 'Matar processo do Wine',
  };

  static const Map<String, String> _frenchWineTranslations = {
    'wine Configuration': 'Paramètres Wine',
    'Fix CJK Characters': 'Réparer les caractères',
    'Start Menu Dir': 'Dossier du menu Démarrer',
    'Remove Wine': 'Supprimer Wine',
    'Enable DXVK': 'Activer DXVK',
    'Disable DXVK': 'Désactiver DXVK',
    'Explorer': 'Explorateur',
    'Notepad': 'Bloc-notes',
    'Minesweeper': 'Démineur',
    'Regedit': 'Éditeur de registre',
    'Control Panel': 'Panneau de configuration',
    'File Manager': 'Gestionnaire de fichiers',
    'Task Manager': 'Gestionnaire de tâches',
    'Internet Explorer': 'Internet Explorer',
    'Kill wine Process': 'Tuer le processus Wine',
  };

  static const Map<String, String> _russianWineTranslations = {
    'wine Configuration': 'Настройки Wine',
    'Fix CJK Characters': 'Исправить символы',
    'Start Menu Dir': 'Папка меню Пуск',
    'Remove Wine': 'Удалить Wine',
    'Enable DXVK': 'Включить DXVK',
    'Disable DXVK': 'Отключить DXVK',
    'Explorer': 'Проводник',
    'Notepad': 'Блокнот',
    'Minesweeper': 'Сапёр',
    'Regedit': 'Редактор реестра',
    'Control Panel': 'Панель управления',
    'File Manager': 'Файловый менеджер',
    'Task Manager': 'Диспетчер задач',
    'Internet Explorer': 'Internet Explorer',
    'Kill wine Process': 'Завершить процесс Wine',
  };

  // ==================== Grouping Methods (unchanged except using new command sources) ====================

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
             !name.contains("shutdown") && !name.contains("power off") && !name.contains("关机");
    }).toList();
    
    final systemCommands = commands.where((cmd) {
      final name = cmd["name"]?.toLowerCase() ?? "";
      return name.contains("shutdown") || name.contains("power off") || name == "matrix" || name.contains("关机") || name.contains("シャットダウン") || name.contains("إيقاف التشغيل") || name.contains("शटडाउन") || name.contains("apagar") || name.contains("éteindre") || name.contains("выключить");
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
             name.contains("удалить wine") ||
             name.contains("إزالة wine") ||
             name.contains("wine हटाएं") ||
             name.contains("eliminar wine") ||
             name.contains("remover wine") ||
             name.contains("supprimer wine") ||
             name.contains("削除");
    }).toList();
    
    final configCommands = commands.where((cmd) {
      final name = cmd["name"]?.toLowerCase() ?? "";
      return !name.contains("remove wine") && 
             !name.contains("удалить wine") &&
             !name.contains("إزالة wine") &&
             !name.contains("wine हटाएं") &&
             !name.contains("eliminar wine") &&
             !name.contains("remover wine") &&
             !name.contains("supprimer wine") &&
             !name.contains("削除");
    }).toList();
    
    return {
      "install": installCommands,
      "config": configCommands,
    };
  }
}

// Android 10+ Modern Settings Button Styles (unchanged)
class AppButtonStyles {
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