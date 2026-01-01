import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('ja'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'XoDos'**
  String get appTitle;

  /// No description provided for @advancedSettings.
  ///
  /// In en, this message translates to:
  /// **'Advanced Settings'**
  String get advancedSettings;

  /// No description provided for @restartAfterChange.
  ///
  /// In en, this message translates to:
  /// **'Changes take effect after restart'**
  String get restartAfterChange;

  /// No description provided for @resetStartupCommand.
  ///
  /// In en, this message translates to:
  /// **'Reset Startup Command'**
  String get resetStartupCommand;

  /// No description provided for @attention.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get attention;

  /// No description provided for @confirmResetCommand.
  ///
  /// In en, this message translates to:
  /// **'Reset startup command?'**
  String get confirmResetCommand;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @signal9ErrorPage.
  ///
  /// In en, this message translates to:
  /// **'Signal9 Error Page'**
  String get signal9ErrorPage;

  /// No description provided for @containerName.
  ///
  /// In en, this message translates to:
  /// **'Container Name'**
  String get containerName;

  /// No description provided for @startupCommand.
  ///
  /// In en, this message translates to:
  /// **'Startup Command'**
  String get startupCommand;

  /// No description provided for @vncStartupCommand.
  ///
  /// In en, this message translates to:
  /// **'VNC Startup Command'**
  String get vncStartupCommand;

  /// No description provided for @shareUsageHint.
  ///
  /// In en, this message translates to:
  /// **'You can use XoDos on all devices in the same network (e.g., phones, computers connected to the same WiFi).\n\nClick the button below to share the link with other devices and open it in a browser.'**
  String get shareUsageHint;

  /// No description provided for @copyShareLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Share Link'**
  String get copyShareLink;

  /// No description provided for @x11InvalidHint.
  ///
  /// In en, this message translates to:
  /// **'This feature is unavailable when using X11'**
  String get x11InvalidHint;

  /// No description provided for @cannotGetIpAddress.
  ///
  /// In en, this message translates to:
  /// **'Failed to get IP address'**
  String get cannotGetIpAddress;

  /// No description provided for @shareLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Share link copied'**
  String get shareLinkCopied;

  /// No description provided for @webRedirectUrl.
  ///
  /// In en, this message translates to:
  /// **'Web Redirect URL'**
  String get webRedirectUrl;

  /// No description provided for @vncLink.
  ///
  /// In en, this message translates to:
  /// **'VNC Link'**
  String get vncLink;

  /// No description provided for @globalSettings.
  ///
  /// In en, this message translates to:
  /// **'Global Settings'**
  String get globalSettings;

  /// No description provided for @enableTerminalEditing.
  ///
  /// In en, this message translates to:
  /// **'Enable terminal editing here'**
  String get enableTerminalEditing;

  /// No description provided for @terminalMaxLines.
  ///
  /// In en, this message translates to:
  /// **'Terminal max lines (requires restart)'**
  String get terminalMaxLines;

  /// No description provided for @pulseaudioPort.
  ///
  /// In en, this message translates to:
  /// **'PulseAudio receiving port'**
  String get pulseaudioPort;

  /// No description provided for @enableTerminal.
  ///
  /// In en, this message translates to:
  /// **'Enable Terminal'**
  String get enableTerminal;

  /// No description provided for @enableTerminalKeypad.
  ///
  /// In en, this message translates to:
  /// **'Enable Terminal Keypad'**
  String get enableTerminalKeypad;

  /// No description provided for @terminalStickyKeys.
  ///
  /// In en, this message translates to:
  /// **'Terminal Sticky Keys'**
  String get terminalStickyKeys;

  /// No description provided for @keepScreenOn.
  ///
  /// In en, this message translates to:
  /// **'Keep Screen On'**
  String get keepScreenOn;

  /// No description provided for @restartRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'The following options will take effect on next launch.'**
  String get restartRequiredHint;

  /// No description provided for @startWithGUI.
  ///
  /// In en, this message translates to:
  /// **'Launch with GUI enabled'**
  String get startWithGUI;

  /// No description provided for @reinstallBootPackage.
  ///
  /// In en, this message translates to:
  /// **'Reinstall Boot Package'**
  String get reinstallBootPackage;

  /// No description provided for @getifaddrsBridge.
  ///
  /// In en, this message translates to:
  /// **'getifaddrs Bridge'**
  String get getifaddrsBridge;

  /// No description provided for @fixGetifaddrsPermission.
  ///
  /// In en, this message translates to:
  /// **'Fix getifaddrs permission on Android 13'**
  String get fixGetifaddrsPermission;

  /// No description provided for @fakeUOSSystem.
  ///
  /// In en, this message translates to:
  /// **'Pretend System as UOS'**
  String get fakeUOSSystem;

  /// No description provided for @displaySettings.
  ///
  /// In en, this message translates to:
  /// **'Display Settings'**
  String get displaySettings;

  /// No description provided for @avncAdvantages.
  ///
  /// In en, this message translates to:
  /// **'AVNC provides better control experience than noVNC:\nTouchpad controls, two-finger tap for keyboard, auto clipboard, picture-in-picture mode, etc.'**
  String get avncAdvantages;

  /// No description provided for @avncSettings.
  ///
  /// In en, this message translates to:
  /// **'AVNC Settings'**
  String get avncSettings;

  /// No description provided for @aboutAVNC.
  ///
  /// In en, this message translates to:
  /// **'About AVNC'**
  String get aboutAVNC;

  /// No description provided for @avncResolution.
  ///
  /// In en, this message translates to:
  /// **'AVNC Startup Resolution'**
  String get avncResolution;

  /// No description provided for @resolutionSettings.
  ///
  /// In en, this message translates to:
  /// **'Resolution Settings'**
  String get resolutionSettings;

  /// No description provided for @deviceScreenResolution.
  ///
  /// In en, this message translates to:
  /// **'Your device screen resolution is'**
  String get deviceScreenResolution;

  /// No description provided for @width.
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get width;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @applyOnNextLaunch.
  ///
  /// In en, this message translates to:
  /// **'Apply on next launch'**
  String get applyOnNextLaunch;

  /// No description provided for @useAVNCByDefault.
  ///
  /// In en, this message translates to:
  /// **'Use AVNC by default'**
  String get useAVNCByDefault;

  /// No description provided for @termuxX11Advantages.
  ///
  /// In en, this message translates to:
  /// **'Termux:X11 may provide faster speeds than VNC in certain scenarios.\n\nNote that Termux:X11 operates slightly differently from AVNC:\n- A two-finger tap acts as a right mouse click\n- Pressing the back button reveals the additional keyboard\n\nIf you encounter a black screen, try completely closing and restarting the application.'**
  String get termuxX11Advantages;

  /// No description provided for @termuxX11Preferences.
  ///
  /// In en, this message translates to:
  /// **'Termux:X11 Preferences'**
  String get termuxX11Preferences;

  /// No description provided for @useTermuxX11ByDefault.
  ///
  /// In en, this message translates to:
  /// **'Use Termux:X11 by default'**
  String get useTermuxX11ByDefault;

  /// No description provided for @disableVNC.
  ///
  /// In en, this message translates to:
  /// **'Disable VNC. Requires restart'**
  String get disableVNC;

  /// No description provided for @hidpiAdvantages.
  ///
  /// In en, this message translates to:
  /// **'One-click to enable HiDPI mode for clearer display... at the cost of reduced speed.'**
  String get hidpiAdvantages;

  /// No description provided for @hidpiEnvVar.
  ///
  /// In en, this message translates to:
  /// **'HiDPI Environment Variables'**
  String get hidpiEnvVar;

  /// No description provided for @hidpiSupport.
  ///
  /// In en, this message translates to:
  /// **'HiDPI Support'**
  String get hidpiSupport;

  /// No description provided for @fileAccess.
  ///
  /// In en, this message translates to:
  /// **'File Access'**
  String get fileAccess;

  /// No description provided for @fileAccessGuide.
  ///
  /// In en, this message translates to:
  /// **'File Access Guide'**
  String get fileAccessGuide;

  /// No description provided for @fileAccessHint.
  ///
  /// In en, this message translates to:
  /// **'Request additional file permissions to access special directories.'**
  String get fileAccessHint;

  /// No description provided for @requestStoragePermission.
  ///
  /// In en, this message translates to:
  /// **'Request Storage Permission'**
  String get requestStoragePermission;

  /// No description provided for @requestAllFilesAccess.
  ///
  /// In en, this message translates to:
  /// **'Request All Files Access'**
  String get requestAllFilesAccess;

  /// No description provided for @ignoreBatteryOptimization.
  ///
  /// In en, this message translates to:
  /// **'Ignore Battery Optimization'**
  String get ignoreBatteryOptimization;

  /// No description provided for @graphicsAcceleration.
  ///
  /// In en, this message translates to:
  /// **'Graphics Acceleration'**
  String get graphicsAcceleration;

  /// No description provided for @experimentalFeature.
  ///
  /// In en, this message translates to:
  /// **'Experimental Feature'**
  String get experimentalFeature;

  /// No description provided for @graphicsAccelerationHint.
  ///
  /// In en, this message translates to:
  /// **'Utilizes device GPU to improve graphics performance, but may cause system instability due to device variations.\n\nVirgl provides acceleration for OpenGL ES applications.'**
  String get graphicsAccelerationHint;

  /// No description provided for @virglServerParams.
  ///
  /// In en, this message translates to:
  /// **'Virgl Server Parameters'**
  String get virglServerParams;

  /// No description provided for @virglEnvVar.
  ///
  /// In en, this message translates to:
  /// **'Virgl Environment Variables'**
  String get virglEnvVar;

  /// No description provided for @enableVirgl.
  ///
  /// In en, this message translates to:
  /// **'Enable Virgl Acceleration'**
  String get enableVirgl;

  /// No description provided for @turnipAdvantages.
  ///
  /// In en, this message translates to:
  /// **'Devices with Adreno GPU can use Turnip driver for Vulkan apps acceleration. Combined with Zink driver for OpenGL apps acceleration.\n(For devices with not-too-old Snapdragon processors)'**
  String get turnipAdvantages;

  /// No description provided for @turnipEnvVar.
  ///
  /// In en, this message translates to:
  /// **'Turnip Environment Variables'**
  String get turnipEnvVar;

  /// No description provided for @enableTurnipZink.
  ///
  /// In en, this message translates to:
  /// **'Enable Turnip+Zink Drivers'**
  String get enableTurnipZink;

  /// No description provided for @enableDRI3.
  ///
  /// In en, this message translates to:
  /// **'Enable DRI3'**
  String get enableDRI3;

  /// No description provided for @dri3Requirement.
  ///
  /// In en, this message translates to:
  /// **'DRI3 requires Termux:X11 and Turnip'**
  String get dri3Requirement;

  /// No description provided for @windowsAppSupport.
  ///
  /// In en, this message translates to:
  /// **'Windows App Support'**
  String get windowsAppSupport;

  /// No description provided for @hangoverDescription.
  ///
  /// In en, this message translates to:
  /// **'Run Windows apps using Hangover (running cross-arch apps on native Wine)!\n\nRunning Windows programs requires two layers of emulation (arch + system) - don\'t expect good performance!\n\nFor better speed, try enabling Graphics Acceleration. Crashes or failures are normal.\n\nRecommend moving Windows programs to desktop before running.\n\nBe patient. Even if GUI shows nothing. Check terminal - is it still running or stopped with error?\n\nOr check if the Windows app has official Linux arm64 version.'**
  String get hangoverDescription;

  /// No description provided for @installHangoverStable.
  ///
  /// In en, this message translates to:
  /// **'Install Hangover Stable'**
  String get installHangoverStable;

  /// No description provided for @installHangoverLatest.
  ///
  /// In en, this message translates to:
  /// **'Install Hangover Latest (may fail)'**
  String get installHangoverLatest;

  /// No description provided for @uninstallHangover.
  ///
  /// In en, this message translates to:
  /// **'Uninstall Hangover'**
  String get uninstallHangover;

  /// No description provided for @clearWineData.
  ///
  /// In en, this message translates to:
  /// **'Clear Wine Data'**
  String get clearWineData;

  /// No description provided for @wineCommandsHint.
  ///
  /// In en, this message translates to:
  /// **'Common Wine commands. Click to launch GUI and wait patiently.\n\nTypical launch times:\nTiger T7510 6GB: over 1 minute\nSnapdragon 870 12GB: ~10 seconds'**
  String get wineCommandsHint;

  /// No description provided for @switchToJapanese.
  ///
  /// In en, this message translates to:
  /// **'Switch System to Japanese'**
  String get switchToJapanese;

  /// No description provided for @userManual.
  ///
  /// In en, this message translates to:
  /// **'User Manual'**
  String get userManual;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get openSourceLicenses;

  /// No description provided for @permissionUsage.
  ///
  /// In en, this message translates to:
  /// **'Permission Usage'**
  String get permissionUsage;

  /// No description provided for @privacyStatement.
  ///
  /// In en, this message translates to:
  /// **'\nThis app does not collect your private information.\n\nHowever, I cannot control behaviors of apps you install/use inside the container system (including via shortcut commands).\n\nRequested permissions are used for:\nFile permissions: accessing phone directories\nNotifications & accessibility: Required by Termux:X11'**
  String get privacyStatement;

  /// No description provided for @supportAuthor.
  ///
  /// In en, this message translates to:
  /// **'Support Developers'**
  String get supportAuthor;

  /// No description provided for @recommendApp.
  ///
  /// In en, this message translates to:
  /// **'If you find it useful, please recommend to others!'**
  String get recommendApp;

  /// No description provided for @projectUrl.
  ///
  /// In en, this message translates to:
  /// **'Project URL'**
  String get projectUrl;

  /// No description provided for @commandEdit.
  ///
  /// In en, this message translates to:
  /// **'Command Edit'**
  String get commandEdit;

  /// No description provided for @commandName.
  ///
  /// In en, this message translates to:
  /// **'Command Name'**
  String get commandName;

  /// No description provided for @commandContent.
  ///
  /// In en, this message translates to:
  /// **'Command Content'**
  String get commandContent;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete Item'**
  String get deleteItem;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @resetCommand.
  ///
  /// In en, this message translates to:
  /// **'Reset Command'**
  String get resetCommand;

  /// No description provided for @confirmResetAllCommands.
  ///
  /// In en, this message translates to:
  /// **'Reset all shortcut commands?'**
  String get confirmResetAllCommands;

  /// No description provided for @addShortcutCommand.
  ///
  /// In en, this message translates to:
  /// **'Add Shortcut Command'**
  String get addShortcutCommand;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @terminal.
  ///
  /// In en, this message translates to:
  /// **'Terminal'**
  String get terminal;

  /// No description provided for @control.
  ///
  /// In en, this message translates to:
  /// **'Control'**
  String get control;

  /// No description provided for @enterGUI.
  ///
  /// In en, this message translates to:
  /// **'Enter GUI'**
  String get enterGUI;

  /// No description provided for @enterNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a number'**
  String get enterNumber;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get enterValidNumber;

  /// No description provided for @installingBootPackage.
  ///
  /// In en, this message translates to:
  /// **'Installing Boot Package'**
  String get installingBootPackage;

  /// No description provided for @copyingContainerSystem.
  ///
  /// In en, this message translates to:
  /// **'Copying System Files'**
  String get copyingContainerSystem;

  /// No description provided for @installingContainerSystem.
  ///
  /// In en, this message translates to:
  /// **'Installing System Files'**
  String get installingContainerSystem;

  /// No description provided for @installationComplete.
  ///
  /// In en, this message translates to:
  /// **'Installation Complete'**
  String get installationComplete;

  /// No description provided for @reinstallingBootPackage.
  ///
  /// In en, this message translates to:
  /// **'Reinstalling Boot Package'**
  String get reinstallingBootPackage;

  /// No description provided for @issueUrl.
  ///
  /// In en, this message translates to:
  /// **'Issue Report'**
  String get issueUrl;

  /// No description provided for @faqUrl.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faqUrl;

  /// No description provided for @solutionUrl.
  ///
  /// In en, this message translates to:
  /// **'Usage Guide'**
  String get solutionUrl;

  /// No description provided for @discussionUrl.
  ///
  /// In en, this message translates to:
  /// **'Discussion'**
  String get discussionUrl;

  /// No description provided for @firstLoadInstructions.
  ///
  /// In en, this message translates to:
  /// **'The first load takes about 5 to 10 minutes... and does not require an internet connection.\n\nNormally, the software will automatically redirect to the graphical interface after loading.\n\nIn the graphical interface:\n- Tap for left-click\n- Long press for right-click\n- Two-finger tap to open the keyboard\n- Two-finger swipe for mouse wheel\n\nPlease do not exit the software during installation.\n\nWhile waiting, you can click the button below to request permissions.\n\nMany folders in XoDos (e.g., Downloads, Documents, Pictures) are bound to the corresponding device folders. Without these permissions, access to these folders will be denied.\n\nIf you don\'t need to access these folders, you can skip granting file permissions (but this may cause Firefox to fail when downloading files due to denied access to the Downloads folder).'**
  String get firstLoadInstructions;

  /// No description provided for @updateRequest.
  ///
  /// In en, this message translates to:
  /// **'Please try to use the latest version. Visit the project address to check for the latest version.'**
  String get updateRequest;

  /// No description provided for @avncScreenResize.
  ///
  /// In en, this message translates to:
  /// **'Adaptive Screen Size'**
  String get avncScreenResize;

  /// No description provided for @avncResizeFactor.
  ///
  /// In en, this message translates to:
  /// **'Screen Scaling Ratio'**
  String get avncResizeFactor;

  /// No description provided for @avncResizeFactorValue.
  ///
  /// In en, this message translates to:
  /// **'Current scaling is'**
  String get avncResizeFactorValue;

  /// No description provided for @waitingGames.
  ///
  /// In en, this message translates to:
  /// **'gaming while Waiting'**
  String get waitingGames;

  /// No description provided for @extrusionProcess.
  ///
  /// In en, this message translates to:
  /// **'Extrusion Process'**
  String get extrusionProcess;

  /// No description provided for @gameTitleSnake.
  ///
  /// In en, this message translates to:
  /// **'Snake Game'**
  String get gameTitleSnake;

  /// No description provided for @gameTitleTetris.
  ///
  /// In en, this message translates to:
  /// **'Tetris'**
  String get gameTitleTetris;

  /// No description provided for @gameTitleFlappy.
  ///
  /// In en, this message translates to:
  /// **'Flappy Bird'**
  String get gameTitleFlappy;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String score(Object score);

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'Game Over! Tap to restart'**
  String get gameOver;

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'Tap to Start'**
  String get startGame;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @extractionCompleteExitGame.
  ///
  /// In en, this message translates to:
  /// **'Extraction complete! Exiting game mode.'**
  String get extractionCompleteExitGame;

  /// No description provided for @mindTwisterGames.
  ///
  /// In en, this message translates to:
  /// **'Mind Twister Games'**
  String get mindTwisterGames;

  /// No description provided for @extractionInProgress.
  ///
  /// In en, this message translates to:
  /// **'Playing - Extraction in progress...'**
  String get extractionInProgress;

  /// No description provided for @playWhileWaiting.
  ///
  /// In en, this message translates to:
  /// **'Play while waiting for system processes'**
  String get playWhileWaiting;

  /// No description provided for @gameModeActive.
  ///
  /// In en, this message translates to:
  /// **'Game Mode Active'**
  String get gameModeActive;

  /// No description provided for @simulateExtractionComplete.
  ///
  /// In en, this message translates to:
  /// **'Simulate Extraction Complete'**
  String get simulateExtractionComplete;

  /// No description provided for @installCommandsSection.
  ///
  /// In en, this message translates to:
  /// **'quick Commands'**
  String get installCommandsSection;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupRestore;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @backupSystem.
  ///
  /// In en, this message translates to:
  /// **'Backup System'**
  String get backupSystem;

  /// No description provided for @restoreSystem.
  ///
  /// In en, this message translates to:
  /// **'Restore System'**
  String get restoreSystem;

  /// No description provided for @systemBackupRestore.
  ///
  /// In en, this message translates to:
  /// **'System Backup & Restore'**
  String get systemBackupRestore;

  /// No description provided for @backupRestoreDescriptionShort.
  ///
  /// In en, this message translates to:
  /// **'Backup or restore your system'**
  String get backupRestoreDescriptionShort;

  /// No description provided for @backupRestoreDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a backup of your system or restore from a previous backup. Wine installations can also be restored.'**
  String get backupRestoreDescription;

  /// No description provided for @backupRestoreWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: Restoring a backup will overwrite existing system files. Make sure you have a current backup before proceeding.'**
  String get backupRestoreWarning;

  /// No description provided for @backupNote.
  ///
  /// In en, this message translates to:
  /// **'Note: Backup files are saved to /sdcard/xodos2backup.tar.xz'**
  String get backupNote;

  /// No description provided for @confirmBackup.
  ///
  /// In en, this message translates to:
  /// **'Confirm Backup'**
  String get confirmBackup;

  /// No description provided for @backupConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will backup the system to /sd/xodos2backup.tar.xz. Continue?'**
  String get backupConfirmation;

  /// No description provided for @backupInProgress.
  ///
  /// In en, this message translates to:
  /// **'Backup in progress...'**
  String get backupInProgress;

  /// No description provided for @backupComplete.
  ///
  /// In en, this message translates to:
  /// **'Backup completed successfully!'**
  String get backupComplete;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed'**
  String get backupFailed;

  /// No description provided for @systemRestore.
  ///
  /// In en, this message translates to:
  /// **'System Restore'**
  String get systemRestore;

  /// No description provided for @systemRestoreWarning.
  ///
  /// In en, this message translates to:
  /// **'This will restore the system from backup. This will overwrite existing system files. Are you sure?'**
  String get systemRestoreWarning;

  /// No description provided for @restoreInProgress.
  ///
  /// In en, this message translates to:
  /// **'Restore in progress...'**
  String get restoreInProgress;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed'**
  String get restoreFailed;

  /// No description provided for @installWine.
  ///
  /// In en, this message translates to:
  /// **'Install Wine'**
  String get installWine;

  /// No description provided for @wineInstallationWarning.
  ///
  /// In en, this message translates to:
  /// **'This will install Wine into the system x86_64 and replace if exists. Are you sure?'**
  String get wineInstallationWarning;

  /// No description provided for @installingWine.
  ///
  /// In en, this message translates to:
  /// **'Installing Wine...'**
  String get installingWine;

  /// No description provided for @wineInstallationFailed.
  ///
  /// In en, this message translates to:
  /// **'Wine installation failed'**
  String get wineInstallationFailed;

  /// No description provided for @fileSelectionFailed.
  ///
  /// In en, this message translates to:
  /// **'File selection failed'**
  String get fileSelectionFailed;

  /// No description provided for @restartRequired.
  ///
  /// In en, this message translates to:
  /// **'Restart Required'**
  String get restartRequired;

  /// No description provided for @restartAppToApply.
  ///
  /// In en, this message translates to:
  /// **'Please restart the app to apply changes.'**
  String get restartAppToApply;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @install.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get install;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @invalidPath.
  ///
  /// In en, this message translates to:
  /// **'Invalid path'**
  String get invalidPath;

  /// No description provided for @unsupportedFormat.
  ///
  /// In en, this message translates to:
  /// **'Unsupported file format'**
  String get unsupportedFormat;

  /// No description provided for @backupRestoreHint.
  ///
  /// In en, this message translates to:
  /// **'Backup creates /sdcard/xodos2backup.tar.xz\nRestore supports .tar, .tar.gz, .tar.xz files\nWine archives will be installed to /opt/wine'**
  String get backupRestoreHint;

  /// No description provided for @wineInstallationComplete.
  ///
  /// In en, this message translates to:
  /// **'Wine installation complete!'**
  String get wineInstallationComplete;

  /// No description provided for @restoreComplete.
  ///
  /// In en, this message translates to:
  /// **'System restore complete!'**
  String get restoreComplete;

  /// No description provided for @checkTerminalForProgress.
  ///
  /// In en, this message translates to:
  /// **'Check terminal for progress...'**
  String get checkTerminalForProgress;

  /// No description provided for @importantNote.
  ///
  /// In en, this message translates to:
  /// **'Important Note'**
  String get importantNote;

  /// No description provided for @enableAndroidVenus.
  ///
  /// In en, this message translates to:
  /// **'Enable ANDROID_VENUS=1'**
  String get enableAndroidVenus;

  /// No description provided for @androidVenusHint.
  ///
  /// In en, this message translates to:
  /// **'Add ANDROID_VENUS=1 environment variable to Venus server command'**
  String get androidVenusHint;

  /// No description provided for @venusSection.
  ///
  /// In en, this message translates to:
  /// **'Venus (Vulkan)'**
  String get venusSection;

  /// No description provided for @venusAdvantages.
  ///
  /// In en, this message translates to:
  /// **'Vulkan-based hardware acceleration using Android\'s Vulkan driver'**
  String get venusAdvantages;

  /// No description provided for @venusServerParams.
  ///
  /// In en, this message translates to:
  /// **'Venus server parameters'**
  String get venusServerParams;

  /// No description provided for @venusEnvVar.
  ///
  /// In en, this message translates to:
  /// **'Venus environment variables'**
  String get venusEnvVar;

  /// No description provided for @enableVenus.
  ///
  /// In en, this message translates to:
  /// **'Enable Venus (Android Vulkan)'**
  String get enableVenus;

  /// No description provided for @virglSection.
  ///
  /// In en, this message translates to:
  /// **'VirGL (OpenGL)'**
  String get virglSection;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'en',
        'es',
        'fr',
        'hi',
        'ja',
        'pt',
        'ru',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
