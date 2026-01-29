// main_app.dart
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:clipboard/clipboard.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:xterm/xterm.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:avnc_flutter/avnc_flutter.dart';
import 'package:x11_flutter/x11_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:audioplayers/audioplayers.dart';

import 'constants.dart';
import 'default_values.dart';
import 'core_classes.dart';
import 'spirited_mini_games.dart';
import 'pages.dart';  // ← ADD THIS IMPORT
import 'dialogs.dart'; // ← ADD THIS IMPORT
import 'package:xodos/l10n/app_localizations.dart';
import 'backup_restore_dialog.dart';

void main() {
AndroidAppState.init(); 
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
      home: MyHomePage(title: "XoDos"), // REMOVED const
    );
  }

  ThemeData _buildDarkTheme() {
    final baseTheme = ThemeData.dark(useMaterial3: true);
    
    return baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: Colors.blue,
        secondary: Colors.green,
        surface: AppColors.surfaceDark,
        background: AppColors.primaryDark,
        onBackground: Colors.white,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.primaryDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: baseTheme.cardTheme.copyWith(
        color: AppColors.surfaceDark,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dialogTheme: baseTheme.dialogTheme.copyWith(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
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

// Remove AppColors class from here - it's now in app_colors.dart

// Keep RTLWrapper, AspectRatioMax1To1, FakeLoadingStatus, etc. classes
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
      _timer = Timer.periodic(const Duration(milliseconds: 135), (timer) async {
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