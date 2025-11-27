// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'XoDos';

  @override
  String get advancedSettings => 'Advanced Settings';

  @override
  String get restartAfterChange => 'Changes take effect after restart';

  @override
  String get resetStartupCommand => 'Reset Startup Command';

  @override
  String get attention => 'Notice';

  @override
  String get confirmResetCommand => 'Reset startup command?';

  @override
  String get cancel => 'Cancel';

  @override
  String get yes => 'Yes';

  @override
  String get signal9ErrorPage => 'Signal9 Error Page';

  @override
  String get containerName => 'Container Name';

  @override
  String get startupCommand => 'Startup Command';

  @override
  String get vncStartupCommand => 'VNC Startup Command';

  @override
  String get shareUsageHint =>
      'You can use XoDos on all devices in the same network (e.g., phones, computers connected to the same WiFi).\n\nClick the button below to share the link with other devices and open it in a browser.';

  @override
  String get copyShareLink => 'Copy Share Link';

  @override
  String get x11InvalidHint => 'This feature is unavailable when using X11';

  @override
  String get cannotGetIpAddress => 'Failed to get IP address';

  @override
  String get shareLinkCopied => 'Share link copied';

  @override
  String get webRedirectUrl => 'Web Redirect URL';

  @override
  String get vncLink => 'VNC Link';

  @override
  String get globalSettings => 'Global Settings';

  @override
  String get enableTerminalEditing => 'Enable terminal editing here';

  @override
  String get terminalMaxLines => 'Terminal max lines (requires restart)';

  @override
  String get pulseaudioPort => 'PulseAudio receiving port';

  @override
  String get enableTerminal => 'Enable Terminal';

  @override
  String get enableTerminalKeypad => 'Enable Terminal Keypad';

  @override
  String get terminalStickyKeys => 'Terminal Sticky Keys';

  @override
  String get keepScreenOn => 'Keep Screen On';

  @override
  String get restartRequiredHint =>
      'The following options will take effect on next launch.';

  @override
  String get startWithGUI => 'Launch with GUI enabled';

  @override
  String get reinstallBootPackage => 'Reinstall Boot Package';

  @override
  String get getifaddrsBridge => 'getifaddrs Bridge';

  @override
  String get fixGetifaddrsPermission =>
      'Fix getifaddrs permission on Android 13';

  @override
  String get fakeUOSSystem => 'Pretend System as UOS';

  @override
  String get displaySettings => 'Display Settings';

  @override
  String get avncAdvantages =>
      'AVNC provides better control experience than noVNC:\nTouchpad controls, two-finger tap for keyboard, auto clipboard, picture-in-picture mode, etc.';

  @override
  String get avncSettings => 'AVNC Settings';

  @override
  String get aboutAVNC => 'About AVNC';

  @override
  String get avncResolution => 'AVNC Startup Resolution';

  @override
  String get resolutionSettings => 'Resolution Settings';

  @override
  String get deviceScreenResolution => 'Your device screen resolution is';

  @override
  String get width => 'Width';

  @override
  String get height => 'Height';

  @override
  String get save => 'Save';

  @override
  String get applyOnNextLaunch => 'Apply on next launch';

  @override
  String get useAVNCByDefault => 'Use AVNC by default';

  @override
  String get termuxX11Advantages =>
      'Termux:X11 may provide faster speeds than VNC in certain scenarios.\n\nNote that Termux:X11 operates slightly differently from AVNC:\n- A two-finger tap acts as a right mouse click\n- Pressing the back button reveals the additional keyboard\n\nIf you encounter a black screen, try completely closing and restarting the application.';

  @override
  String get termuxX11Preferences => 'Termux:X11 Preferences';

  @override
  String get useTermuxX11ByDefault => 'Use Termux:X11 by default';

  @override
  String get disableVNC => 'Disable VNC. Requires restart';

  @override
  String get hidpiAdvantages =>
      'One-click to enable HiDPI mode for clearer display... at the cost of reduced speed.';

  @override
  String get hidpiEnvVar => 'HiDPI Environment Variables';

  @override
  String get hidpiSupport => 'HiDPI Support';

  @override
  String get fileAccess => 'File Access';

  @override
  String get fileAccessGuide => 'File Access Guide';

  @override
  String get fileAccessHint =>
      'Request additional file permissions to access special directories.';

  @override
  String get requestStoragePermission => 'Request Storage Permission';

  @override
  String get requestAllFilesAccess => 'Request All Files Access';

  @override
  String get ignoreBatteryOptimization => 'Ignore Battery Optimization';

  @override
  String get graphicsAcceleration => 'Graphics Acceleration';

  @override
  String get experimentalFeature => 'Experimental Feature';

  @override
  String get graphicsAccelerationHint =>
      'Utilizes device GPU to improve graphics performance, but may cause system instability due to device variations.\n\nVirgl provides acceleration for OpenGL ES applications.';

  @override
  String get virglServerParams => 'Virgl Server Parameters';

  @override
  String get virglEnvVar => 'Virgl Environment Variables';

  @override
  String get enableVirgl => 'Enable Virgl Acceleration';

  @override
  String get turnipAdvantages =>
      'Devices with Adreno GPU can use Turnip driver for Vulkan apps acceleration. Combined with Zink driver for OpenGL apps acceleration.\n(For devices with not-too-old Snapdragon processors)';

  @override
  String get turnipEnvVar => 'Turnip Environment Variables';

  @override
  String get enableTurnipZink => 'Enable Turnip+Zink Drivers';

  @override
  String get enableDRI3 => 'Enable DRI3';

  @override
  String get dri3Requirement => 'DRI3 requires Termux:X11 and Turnip';

  @override
  String get windowsAppSupport => 'Windows App Support';

  @override
  String get hangoverDescription =>
      'Run Windows apps using Hangover (running cross-arch apps on native Wine)!\n\nRunning Windows programs requires two layers of emulation (arch + system) - don\'t expect good performance!\n\nFor better speed, try enabling Graphics Acceleration. Crashes or failures are normal.\n\nRecommend moving Windows programs to desktop before running.\n\nBe patient. Even if GUI shows nothing. Check terminal - is it still running or stopped with error?\n\nOr check if the Windows app has official Linux arm64 version.';

  @override
  String get installHangoverStable => 'Install Hangover Stable';

  @override
  String get installHangoverLatest => 'Install Hangover Latest (may fail)';

  @override
  String get uninstallHangover => 'Uninstall Hangover';

  @override
  String get clearWineData => 'Clear Wine Data';

  @override
  String get wineCommandsHint =>
      'Common Wine commands. Click to launch GUI and wait patiently.\n\nTypical launch times:\nTiger T7510 6GB: over 1 minute\nSnapdragon 870 12GB: ~10 seconds';

  @override
  String get switchToJapanese => 'Switch System to Japanese';

  @override
  String get userManual => 'User Manual';

  @override
  String get openSourceLicenses => 'Open Source Licenses';

  @override
  String get permissionUsage => 'Permission Usage';

  @override
  String get privacyStatement =>
      '\nThis app does not collect your private information.\n\nHowever, I cannot control behaviors of apps you install/use inside the container system (including via shortcut commands).\n\nRequested permissions are used for:\nFile permissions: accessing phone directories\nNotifications & accessibility: Required by Termux:X11';

  @override
  String get supportAuthor => 'Support Developers';

  @override
  String get recommendApp =>
      'If you find it useful, please recommend to others!';

  @override
  String get projectUrl => 'Project URL';

  @override
  String get commandEdit => 'Command Edit';

  @override
  String get commandName => 'Command Name';

  @override
  String get commandContent => 'Command Content';

  @override
  String get deleteItem => 'Delete Item';

  @override
  String get add => 'Add';

  @override
  String get resetCommand => 'Reset Command';

  @override
  String get confirmResetAllCommands => 'Reset all shortcut commands?';

  @override
  String get addShortcutCommand => 'Add Shortcut Command';

  @override
  String get more => 'More';

  @override
  String get terminal => 'Terminal';

  @override
  String get control => 'Control';

  @override
  String get enterGUI => 'Enter GUI';

  @override
  String get enterNumber => 'Please enter a number';

  @override
  String get enterValidNumber => 'Please enter a valid number';

  @override
  String get installingBootPackage => 'Installing Boot Package';

  @override
  String get copyingContainerSystem => 'Copying System Files';

  @override
  String get installingContainerSystem => 'Installing System Files';

  @override
  String get installationComplete => 'Installation Complete';

  @override
  String get reinstallingBootPackage => 'Reinstalling Boot Package';

  @override
  String get issueUrl => 'Issue Report';

  @override
  String get faqUrl => 'FAQ';

  @override
  String get solutionUrl => 'Usage Guide';

  @override
  String get discussionUrl => 'Discussion';

  @override
  String get firstLoadInstructions =>
      'The first load takes about 5 to 10 minutes... and does not require an internet connection.\n\nNormally, the software will automatically redirect to the graphical interface after loading.\n\nIn the graphical interface:\n- Tap for left-click\n- Long press for right-click\n- Two-finger tap to open the keyboard\n- Two-finger swipe for mouse wheel\n\nPlease do not exit the software during installation.\n\nWhile waiting, you can click the button below to request permissions.\n\nMany folders in XoDos (e.g., Downloads, Documents, Pictures) are bound to the corresponding device folders. Without these permissions, access to these folders will be denied.\n\nIf you don\'t need to access these folders, you can skip granting file permissions (but this may cause Firefox to fail when downloading files due to denied access to the Downloads folder).';

  @override
  String get updateRequest =>
      'Please try to use the latest version. Visit the project address to check for the latest version.';

  @override
  String get avncScreenResize => 'Adaptive Screen Size';

  @override
  String get avncResizeFactor => 'Screen Scaling Ratio';

  @override
  String get avncResizeFactorValue => 'Current scaling is';

  @override
  String get waitingGames => 'gaming while Waiting';

  @override
  String get extrusionProcess => 'Extrusion Process';

  @override
  String get gameTitleSnake => 'Snake Game';

  @override
  String get gameTitleTetris => 'Tetris';

  @override
  String get gameTitleFlappy => 'Flappy Bird';

  @override
  String score(Object score) {
    return 'Score: $score';
  }

  @override
  String get gameOver => 'Game Over! Tap to restart';

  @override
  String get startGame => 'Tap to Start';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get extractionCompleteExitGame =>
      'Extraction complete! Exiting game mode.';

  @override
  String get mindTwisterGames => 'Mind Twister Games';

  @override
  String get extractionInProgress => 'Playing - Extraction in progress...';

  @override
  String get playWhileWaiting => 'Play while waiting for system processes';

  @override
  String get gameModeActive => 'Game Mode Active';

  @override
  String get simulateExtractionComplete => 'Simulate Extraction Complete';
}
