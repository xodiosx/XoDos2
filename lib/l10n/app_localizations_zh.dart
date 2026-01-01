// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'XoDos';

  @override
  String get advancedSettings => '高级设置';

  @override
  String get restartAfterChange => '修改后重启生效';

  @override
  String get resetStartupCommand => '重置启动命令';

  @override
  String get attention => '注意';

  @override
  String get confirmResetCommand => '是否重置启动命令？';

  @override
  String get cancel => '取消';

  @override
  String get yes => '是';

  @override
  String get signal9ErrorPage => 'Signal9错误页面';

  @override
  String get containerName => '容器名称';

  @override
  String get startupCommand => '启动命令';

  @override
  String get vncStartupCommand => 'vnc启动命令';

  @override
  String get shareUsageHint =>
      '你可以在当前所有同一网络下的设备（如：连接同一WiFi的手机，电脑等）里使用XoDos。\n\n点击下面的按钮分享链接到其他设备后使用浏览器打开即可。';

  @override
  String get copyShareLink => '复制分享链接';

  @override
  String get x11InvalidHint => '使用X11时此功能无效';

  @override
  String get cannotGetIpAddress => '无法获取IP地址';

  @override
  String get shareLinkCopied => '已复制分享链接';

  @override
  String get webRedirectUrl => '网页跳转地址';

  @override
  String get vncLink => 'vnc链接';

  @override
  String get globalSettings => '全局设置';

  @override
  String get enableTerminalEditing => '在这里开启终端编辑';

  @override
  String get terminalMaxLines => '终端最大行数(重启软件生效)';

  @override
  String get pulseaudioPort => 'pulseaudio接收端口';

  @override
  String get enableTerminal => '启用终端';

  @override
  String get enableTerminalKeypad => '启用终端小键盘';

  @override
  String get terminalStickyKeys => '终端粘滞键';

  @override
  String get keepScreenOn => '屏幕常亮';

  @override
  String get restartRequiredHint => '以下选项修改后将在下次启动软件时生效。';

  @override
  String get startWithGUI => '开启时启动图形界面';

  @override
  String get reinstallBootPackage => '重新安装引导包';

  @override
  String get getifaddrsBridge => 'getifaddrs桥接';

  @override
  String get fixGetifaddrsPermission => '修复安卓13设备getifaddrs无权限';

  @override
  String get fakeUOSSystem => '伪装系统为UOS';

  @override
  String get displaySettings => '显示设置';

  @override
  String get avncAdvantages =>
      'AVNC可以带来相比noVNC更好的操控体验；\n如触摸板触控，双指单击弹出键盘，自动剪切板，画中画模式等等。';

  @override
  String get avncSettings => 'AVNC设置';

  @override
  String get aboutAVNC => '关于AVNC';

  @override
  String get avncResolution => 'AVNC启动时分辨率设置';

  @override
  String get resolutionSettings => '分辨率设置';

  @override
  String get deviceScreenResolution => '你的设备屏幕分辨率是';

  @override
  String get width => '宽';

  @override
  String get height => '高';

  @override
  String get save => '保存';

  @override
  String get applyOnNextLaunch => '下次启动时生效';

  @override
  String get useAVNCByDefault => '默认使用AVNC';

  @override
  String get termuxX11Advantages =>
      'Termux:X11某些情况下可以带来比VNC更快的速度。\n\n注意Termux:X11的操作与AVNC略有不同。\n- 双指点击为鼠标右键\n- 返回弹出小键盘\n\n如果黑屏，请尝试彻底关闭本应用再重新启动。';

  @override
  String get termuxX11Preferences => 'Termux:X11偏好设置';

  @override
  String get useTermuxX11ByDefault => '默认使用Termux:X11';

  @override
  String get disableVNC => '不使用VNC。重启生效';

  @override
  String get hidpiAdvantages => '一键开启高清模式，显示更清晰的同时...速度会变慢。';

  @override
  String get hidpiEnvVar => 'HiDPI环境变量';

  @override
  String get hidpiSupport => '高分辨率支持';

  @override
  String get fileAccess => '文件访问';

  @override
  String get fileAccessGuide => '文件访问指南';

  @override
  String get fileAccessHint => '在这里获取更多文件权限，以实现对设备文件的访问。';

  @override
  String get requestStoragePermission => '申请存储权限';

  @override
  String get requestAllFilesAccess => '申请所有文件访问权限';

  @override
  String get ignoreBatteryOptimization => '忽略电池优化';

  @override
  String get graphicsAcceleration => '图形加速';

  @override
  String get experimentalFeature => '实验性功能';

  @override
  String get graphicsAccelerationHint =>
      '图形加速可部分利用设备GPU提升系统图形处理表现，但由于设备差异也可能导致容器系统及软件运行不稳定甚至异常退出。\n\nVirgl可为使用OpenGL ES的应用提供加速。';

  @override
  String get virglServerParams => 'Virgl服务器参数';

  @override
  String get virglEnvVar => 'Virgl环境变量';

  @override
  String get enableVirgl => '启用Virgl加速';

  @override
  String get turnipAdvantages =>
      '搭载Adreno GPU的设备通常可以使用Turnip驱动加速使用Vulkan的软件。配合Zink驱动可实现加速使用OpenGL的软件。\n（也就是搭载不太新也不太旧的骁龙处理器的设备）';

  @override
  String get turnipEnvVar => 'Turnip环境变量';

  @override
  String get enableTurnipZink => '启用Turnip+Zink驱动';

  @override
  String get enableDRI3 => '启用DRI3';

  @override
  String get dri3Requirement => 'DRI3必须配合Termux:X11和Turnip使用';

  @override
  String get windowsAppSupport => 'Windows应用支持';

  @override
  String get hangoverDescription =>
      '使用Hangover（在原生Wine运行跨架构应用）运行Windows应用！\n\n运行Windows程序需要经过架构和系统两层模拟，不要对运行速度抱有期待！\n\n需要速度可以尝试配合图形加速使用。当然程序崩溃甚至打不开也是正常的。\n\n建议将要运行的Windows程序连同程序文件夹移至桌面运行。\n\n你需要耐心。即使图形界面什么也没显示。看看终端，还在继续输出吗？还是停止在某个报错？\n\n或者寻找该Windows软件官方是否提供Linux arm64版本。';

  @override
  String get installHangoverStable => '安装Hangover稳定版';

  @override
  String get installHangoverLatest => '安装Hangover最新版（可能出错）';

  @override
  String get uninstallHangover => '卸载Hangover';

  @override
  String get clearWineData => '清空Wine数据';

  @override
  String get wineCommandsHint =>
      'Wine的常用指令。点击后前往图形界面耐心等待。\n\n任意程序启动参考时间：\n虎贲T7510 6GB 超过一分钟\n骁龙870 12GB 约10秒\n';

  @override
  String get switchToJapanese => '切换系统到日语';

  @override
  String get userManual => '使用说明';

  @override
  String get openSourceLicenses => '开源许可';

  @override
  String get permissionUsage => '权限使用说明';

  @override
  String get privacyStatement =>
      '\n本软件不会收集你的隐私信息。\n\n当然，你在容器系统内部安装或使用的软件行为（包括通过快捷指令）就不受我控制了，我不对其负责。\n\n本软件申请的权限用于以下目的：\n文件相关权限：用于系统访问手机目录；\n通知和无障碍：Termux:X11需要。';

  @override
  String get supportAuthor => '支持作者';

  @override
  String get recommendApp => '如果认为好用的话，可以推荐给其他人用噢！';

  @override
  String get projectUrl => '项目地址';

  @override
  String get commandEdit => '指令编辑';

  @override
  String get commandName => '指令名称';

  @override
  String get commandContent => '指令内容';

  @override
  String get deleteItem => '删除该项';

  @override
  String get add => '添加';

  @override
  String get resetCommand => '重置指令';

  @override
  String get confirmResetAllCommands => '是否重置所有快捷指令？';

  @override
  String get addShortcutCommand => '添加快捷指令';

  @override
  String get more => '更多';

  @override
  String get terminal => '终端';

  @override
  String get control => '控制';

  @override
  String get enterGUI => '进入图形界面';

  @override
  String get enterNumber => '请输入数字';

  @override
  String get enterValidNumber => '请输入有效的数字';

  @override
  String get installingBootPackage => '正在安装引导包';

  @override
  String get copyingContainerSystem => '正在复制容器系统';

  @override
  String get installingContainerSystem => '正在安装容器系统';

  @override
  String get installationComplete => '安装完成';

  @override
  String get reinstallingBootPackage => '正在重新安装引导包';

  @override
  String get issueUrl => '问题反馈';

  @override
  String get faqUrl => '常见问题';

  @override
  String get solutionUrl => '典型场景使用指南';

  @override
  String get discussionUrl => '论坛与讨论';

  @override
  String get firstLoadInstructions =>
      '第一次加载大概需要5到10分钟...并且不需要网络。\n\n正常情况下，加载完成后软件会自动跳转到图形界面。\n\n在图形界面时：\n- 点击为鼠标左键\n- 长按为鼠标右键\n- 双指点击可弹出键盘\n- 双指划动为鼠标滚轮\n\n请不要在安装时退出软件。\n\n在等待时，可以点击下面的按钮申请一下权限。\n\nXoDos的许多文件夹，比如下载、文档、图片等等都和设备的对应文件夹绑定，如果不授予这些权限会导致这些文件夹无权访问。\n\n但如果你不需要访问这些文件夹，也可以不授予文件权限（可能导致火狐浏览器下载文件失败，因为无权访问下载文件夹）。';

  @override
  String get updateRequest => '请尽量使用最新版本。前往项目地址可查看最新版本。';

  @override
  String get avncScreenResize => '自适应屏幕尺寸';

  @override
  String get avncResizeFactor => 'Screen Scaling Ratio';

  @override
  String get avncResizeFactorValue => 'Current scaling is';

  @override
  String get waitingGames => '等待时玩游戏';

  @override
  String get extrusionProcess => '挤出过程';

  @override
  String get gameTitleSnake => '贪吃蛇';

  @override
  String get gameTitleTetris => '俄罗斯方块';

  @override
  String get gameTitleFlappy => '飞翔小鸟';

  @override
  String score(Object score) {
    return '得分: $score';
  }

  @override
  String get gameOver => '游戏结束！点击重新开始';

  @override
  String get startGame => '点击开始';

  @override
  String get pause => '暂停';

  @override
  String get resume => '继续';

  @override
  String get extractionCompleteExitGame => '提取完成！退出游戏模式。';

  @override
  String get mindTwisterGames => '脑筋急转弯游戏';

  @override
  String get extractionInProgress => '播放中 - 提取进行中...';

  @override
  String get playWhileWaiting => '在等待系统进程时玩游戏';

  @override
  String get gameModeActive => '游戏模式激活';

  @override
  String get simulateExtractionComplete => '模拟提取完成';

  @override
  String get installCommandsSection => '快速命令';

  @override
  String get backupRestore => 'Backup & Restore';

  @override
  String get backup => 'Backup';

  @override
  String get restore => 'Restore';

  @override
  String get backupSystem => 'Backup System';

  @override
  String get restoreSystem => 'Restore System';

  @override
  String get systemBackupRestore => 'System Backup & Restore';

  @override
  String get backupRestoreDescriptionShort => 'Backup or restore your system';

  @override
  String get backupRestoreDescription =>
      'Create a backup of your system or restore from a previous backup. Wine installations can also be restored.';

  @override
  String get backupRestoreWarning =>
      'Warning: Restoring a backup will overwrite existing system files. Make sure you have a current backup before proceeding.';

  @override
  String get backupNote =>
      'Note: Backup files are saved to /sd/xodos2backup.tar.xz';

  @override
  String get confirmBackup => 'Confirm Backup';

  @override
  String get backupConfirmation =>
      'This will backup the system to /sd/xodos2backup.tar.xz. Continue?';

  @override
  String get backupInProgress => 'Backup in progress...';

  @override
  String get backupComplete => 'Backup completed successfully!';

  @override
  String get backupFailed => 'Backup failed';

  @override
  String get systemRestore => 'System Restore';

  @override
  String get systemRestoreWarning =>
      'This will restore the system from backup. This will overwrite existing system files. Are you sure?';

  @override
  String get restoreInProgress => 'Restore in progress...';

  @override
  String get restoreFailed => 'Restore failed';

  @override
  String get installWine => 'Install Wine';

  @override
  String get wineInstallationWarning =>
      'This will install Wine into the system x86_64 and replace if exists. Are you sure?';

  @override
  String get installingWine => 'Installing Wine...';

  @override
  String get wineInstallationFailed => 'Wine installation failed';

  @override
  String get fileSelectionFailed => 'File selection failed';

  @override
  String get restartRequired => 'Restart Required';

  @override
  String get restartAppToApply => 'Please restart the app to apply changes.';

  @override
  String get close => 'Close';

  @override
  String get install => 'Install';

  @override
  String get ok => 'OK';

  @override
  String get invalidPath => 'Invalid path';

  @override
  String get unsupportedFormat => 'Unsupported file format';

  @override
  String get backupRestoreHint =>
      'Backup creates /sd/xodos2backup.tar.xz\nRestore supports .tar, .tar.gz, .tar.xz files\nWine archives will be installed to /opt/wine';

  @override
  String get wineInstallationComplete => 'Wine installation complete!';

  @override
  String get restoreComplete => 'System restore complete!';

  @override
  String get checkTerminalForProgress => 'Check terminal for progress...';

  @override
  String get importantNote => 'Important Note';

  @override
  String get enableAndroidVenus => 'Enable ANDROID_VENUS=1';

  @override
  String get androidVenusHint =>
      'Add ANDROID_VENUS=1 environment variable to Venus server command';

  @override
  String get venusSection => 'Venus (Vulkan)';

  @override
  String get venusAdvantages =>
      'Vulkan-based hardware acceleration using Android\'s Vulkan driver';

  @override
  String get venusServerParams => 'Venus server parameters';

  @override
  String get venusEnvVar => 'Venus environment variables';

  @override
  String get enableVenus => 'Enable Venus (Android Vulkan)';

  @override
  String get virglSection => 'VirGL (OpenGL)';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => 'XoDos';

  @override
  String get advancedSettings => '進階設定';

  @override
  String get restartAfterChange => '修改後需重新啟動才會生效';

  @override
  String get resetStartupCommand => '重設啟動指令';

  @override
  String get attention => '注意';

  @override
  String get confirmResetCommand => '是否重設啟動指令？';

  @override
  String get cancel => '取消';

  @override
  String get yes => '是';

  @override
  String get signal9ErrorPage => 'Signal9 錯誤頁面';

  @override
  String get containerName => '容器名稱';

  @override
  String get startupCommand => '啟動指令';

  @override
  String get vncStartupCommand => 'vnc 啟動指令';

  @override
  String get shareUsageHint =>
      '你可以在當前所有同一網路下的裝置（如：連接同一 WiFi 的手機、電腦等）裡使用XoDos。\n\n點擊下面的按鈕分享連結到其他裝置。';

  @override
  String get copyShareLink => '複製分享連結';

  @override
  String get x11InvalidHint => '使用 X11 時此功能無效';

  @override
  String get cannotGetIpAddress => '無法取得 IP 位址';

  @override
  String get shareLinkCopied => '已複製分享連結';

  @override
  String get webRedirectUrl => '網頁跳轉位址';

  @override
  String get vncLink => 'vnc 連結';

  @override
  String get globalSettings => '全域設定';

  @override
  String get enableTerminalEditing => '在這裡開啟終端編輯';

  @override
  String get terminalMaxLines => '終端最大行數（重啟軟體生效）';

  @override
  String get pulseaudioPort => 'pulseaudio 接收端口';

  @override
  String get enableTerminal => '啟用終端';

  @override
  String get enableTerminalKeypad => '啟用終端小鍵盤';

  @override
  String get terminalStickyKeys => '終端黏滯鍵';

  @override
  String get keepScreenOn => '螢幕常亮';

  @override
  String get restartRequiredHint => '以下選項修改後將於下次啟動軟體時生效。';

  @override
  String get startWithGUI => '啟動時啟動圖形介面';

  @override
  String get reinstallBootPackage => '重新安裝啟動套件';

  @override
  String get getifaddrsBridge => 'getifaddrs 橋接';

  @override
  String get fixGetifaddrsPermission => '修復 Android 13 裝置 getifaddrs 無權限';

  @override
  String get fakeUOSSystem => '偽裝系統為 UOS';

  @override
  String get displaySettings => '顯示設定';

  @override
  String get avncAdvantages =>
      'AVNC 可帶來比 noVNC 更好的操作體驗；如觸控板觸控、雙指單擊喚出鍵盤、自動剪貼簿、畫中畫模式等。';

  @override
  String get avncSettings => 'AVNC 設定';

  @override
  String get aboutAVNC => '關於 AVNC';

  @override
  String get avncResolution => 'AVNC 啟動時解析度設定';

  @override
  String get resolutionSettings => '解析度設定';

  @override
  String get deviceScreenResolution => '你的裝置螢幕解析度為';

  @override
  String get width => '寬';

  @override
  String get height => '高';

  @override
  String get save => '儲存';

  @override
  String get applyOnNextLaunch => '下次啟動時生效';

  @override
  String get useAVNCByDefault => '預設使用 AVNC';

  @override
  String get termuxX11Advantages =>
      'Termux:X11 在某些情況下可能比 VNC 提供更快的速度。\n\n請注意 Termux:X11 的操作與 AVNC 略有不同：\n- 雙指點擊相當於滑鼠右鍵\n- 返回鍵可彈出小鍵盤\n若出現黑屏，請嘗試完全關閉本應用後重新啟動。';

  @override
  String get termuxX11Preferences => 'Termux:X11 偏好設定';

  @override
  String get useTermuxX11ByDefault => '預設使用 Termux:X11';

  @override
  String get disableVNC => '停用 VNC。重啟生效';

  @override
  String get hidpiAdvantages => '一鍵開啟高清模式，顯示更清晰的同時...速度會變慢。';

  @override
  String get hidpiEnvVar => 'HiDPI 環境變數';

  @override
  String get hidpiSupport => '高解析度支援';

  @override
  String get fileAccess => '檔案存取';

  @override
  String get fileAccessGuide => '檔案存取指南';

  @override
  String get fileAccessHint => '在此處取得更多檔案權限，以便存取特殊目錄。';

  @override
  String get requestStoragePermission => '申請儲存權限';

  @override
  String get requestAllFilesAccess => '申請所有檔案存取權限';

  @override
  String get ignoreBatteryOptimization => '忽略電池優化';

  @override
  String get graphicsAcceleration => '圖形加速';

  @override
  String get experimentalFeature => '實驗性功能';

  @override
  String get graphicsAccelerationHint =>
      '圖形加速可部分利用裝置 GPU 增強系統圖形效能，但因裝置差異可能導致容器系統與軟體執行不穩或異常退出。\n請酌情開啟。';

  @override
  String get virglServerParams => 'Virgl 伺服器參數';

  @override
  String get virglEnvVar => 'Virgl 環境變數';

  @override
  String get enableVirgl => '啟用 Virgl 加速';

  @override
  String get turnipAdvantages =>
      '搭載 Adreno GPU 的裝置通常可用 Turnip 驅動加速 Vulkan 軟體。配合 Zink 驅動可加速 OpenGL 軟體。\n（即搭載不是太新的 Adreno GPU 的裝置可用）';

  @override
  String get turnipEnvVar => 'Turnip 環境變數';

  @override
  String get enableTurnipZink => '啟用 Turnip+Zink 驅動';

  @override
  String get enableDRI3 => '啟用 DRI3';

  @override
  String get dri3Requirement => 'DRI3 必須配合 Termux:X11 與 Turnip 使用';

  @override
  String get windowsAppSupport => 'Windows 應用支援';

  @override
  String get hangoverDescription =>
      '使用 Hangover（於原生 Wine 執行跨架構應用）來執行 Windows 應用！\n\n執行 Windows 程式需經過架構與系統雙層模擬，請勿對速度抱太大期望。';

  @override
  String get installHangoverStable => '安裝 Hangover 穩定版';

  @override
  String get installHangoverLatest => '安裝 Hangover 最新版（可能有錯誤）';

  @override
  String get uninstallHangover => '解除安裝 Hangover';

  @override
  String get clearWineData => '清除 Wine 資料';

  @override
  String get wineCommandsHint =>
      'Wine 常用指令。點擊後進入圖形介面，請耐心等候。\n\n不同裝置啟動程式參考時間：\n虎賁 T7510 6GB 超過一分鐘\n驍龍 870 12GB 約 10 秒\n';

  @override
  String get switchToJapanese => '切換系統為日語';

  @override
  String get userManual => '使用說明';

  @override
  String get openSourceLicenses => '開源授權';

  @override
  String get permissionUsage => '權限使用說明';

  @override
  String get privacyStatement =>
      '\n本軟體不會收集你的隱私資訊。\n\n當然，你在容器系統內安裝或使用的軟體行為（包括快捷指令）不在本軟體控制範圍。';

  @override
  String get supportAuthor => '支持作者';

  @override
  String get recommendApp => '如果覺得好用，可以推薦給其他人哦！';

  @override
  String get projectUrl => '專案網址';

  @override
  String get commandEdit => '指令編輯';

  @override
  String get commandName => '指令名稱';

  @override
  String get commandContent => '指令內容';

  @override
  String get deleteItem => '刪除此項';

  @override
  String get add => '新增';

  @override
  String get resetCommand => '重設指令';

  @override
  String get confirmResetAllCommands => '是否重設所有快捷指令？';

  @override
  String get addShortcutCommand => '新增快捷指令';

  @override
  String get more => '更多';

  @override
  String get terminal => '終端';

  @override
  String get control => '控制';

  @override
  String get enterGUI => '進入圖形介面';

  @override
  String get enterNumber => '請輸入數字';

  @override
  String get enterValidNumber => '請輸入有效數字';

  @override
  String get installingBootPackage => '正在安裝啟動套件';

  @override
  String get copyingContainerSystem => '正在複製容器系統';

  @override
  String get installingContainerSystem => '正在安裝容器系統';

  @override
  String get installationComplete => '安裝完成';

  @override
  String get reinstallingBootPackage => '正在重新安裝啟動套件';

  @override
  String get issueUrl => '問題回報';

  @override
  String get faqUrl => '常見問題';

  @override
  String get solutionUrl => '操作指南';

  @override
  String get discussionUrl => '討論';

  @override
  String get firstLoadInstructions =>
      '第一次加載大概需要5到10分鐘...並且不需要網絡。\n\n正常情況下，載入完成後軟體會自動跳轉到圖形介面。\n\n在圖形介面時：\n- 點擊為滑鼠左鍵\n- 長按為滑鼠右鍵\n- 雙指點擊可彈出鍵盤\n- 雙指滑動為滑鼠滾輪\n\n請不要在安裝時退出軟體。\n\n在等待時，可以點擊下面的按鈕申請權限。\n\nXoDos的許多資料夾，比如下載、文件、圖片等等都和裝置的這些資料夾綁定，如果不授予這些權限會導致這些資料夾無權存取。\n\n但如果你不需要存取這些資料夾，也可以不授予檔案權限（可能導致火狐瀏覽器下載檔案失敗，因為無權存取下載資料夾）。';

  @override
  String get updateRequest => '請盡量使用最新版本。前往專案網址查看最新版本。';

  @override
  String get avncScreenResize => '自適應螢幕尺寸';

  @override
  String get avncResizeFactor => 'Screen Scaling Ratio';

  @override
  String get avncResizeFactorValue => 'Current scaling is';

  @override
  String get waitingGames => '等待时玩游戏';

  @override
  String get extrusionProcess => '挤出过程';

  @override
  String get gameTitleSnake => '贪吃蛇';

  @override
  String get gameTitleTetris => '俄罗斯方块';

  @override
  String get gameTitleFlappy => '飞翔小鸟';

  @override
  String score(Object score) {
    return '得分: $score';
  }

  @override
  String get gameOver => '游戏结束！点击重新开始';

  @override
  String get startGame => '点击开始';

  @override
  String get pause => '暂停';

  @override
  String get resume => '继续';

  @override
  String get extractionCompleteExitGame => '提取完成！退出游戏模式。';

  @override
  String get mindTwisterGames => '脑筋急转弯游戏';

  @override
  String get extractionInProgress => '播放中 - 提取进行中...';

  @override
  String get playWhileWaiting => '在等待系统进程时玩游戏';

  @override
  String get gameModeActive => '游戏模式激活';

  @override
  String get simulateExtractionComplete => '模拟提取完成';

  @override
  String get installCommandsSection => '快速命令';

  @override
  String get backupRestore => 'Backup & Restore';

  @override
  String get backup => 'Backup';

  @override
  String get restore => 'Restore';

  @override
  String get backupSystem => 'Backup System';

  @override
  String get restoreSystem => 'Restore System';

  @override
  String get systemBackupRestore => 'System Backup & Restore';

  @override
  String get backupRestoreDescriptionShort => 'Backup or restore your system';

  @override
  String get backupRestoreDescription =>
      'Create a backup of your system or restore from a previous backup. Wine installations can also be restored.';

  @override
  String get backupRestoreWarning =>
      'Warning: Restoring a backup will overwrite existing system files. Make sure you have a current backup before proceeding.';

  @override
  String get backupNote =>
      'Note: Backup files are saved to /sd/xodos2backup.tar.xz';

  @override
  String get confirmBackup => 'Confirm Backup';

  @override
  String get backupConfirmation =>
      'This will backup the system to /sd/xodos2backup.tar.xz. Continue?';

  @override
  String get backupInProgress => 'Backup in progress...';

  @override
  String get backupComplete => 'Backup completed successfully!';

  @override
  String get backupFailed => 'Backup failed';

  @override
  String get systemRestore => 'System Restore';

  @override
  String get systemRestoreWarning =>
      'This will restore the system from backup. This will overwrite existing system files. Are you sure?';

  @override
  String get restoreInProgress => 'Restore in progress...';

  @override
  String get restoreFailed => 'Restore failed';

  @override
  String get installWine => 'Install Wine';

  @override
  String get wineInstallationWarning =>
      'This will install Wine into the system x86_64 and replace if exists. Are you sure?';

  @override
  String get installingWine => 'Installing Wine...';

  @override
  String get wineInstallationFailed => 'Wine installation failed';

  @override
  String get fileSelectionFailed => 'File selection failed';

  @override
  String get restartRequired => 'Restart Required';

  @override
  String get restartAppToApply => 'Please restart the app to apply changes.';

  @override
  String get close => 'Close';

  @override
  String get install => 'Install';

  @override
  String get ok => 'OK';

  @override
  String get invalidPath => 'Invalid path';

  @override
  String get unsupportedFormat => 'Unsupported file format';

  @override
  String get backupRestoreHint =>
      'Backup creates /sd/xodos2backup.tar.xz\nRestore supports .tar, .tar.gz, .tar.xz files\nWine archives will be installed to /opt/wine';

  @override
  String get wineInstallationComplete => 'Wine installation complete!';

  @override
  String get restoreComplete => 'System restore complete!';

  @override
  String get checkTerminalForProgress => 'Check terminal for progress...';

  @override
  String get importantNote => 'Important Note';

  @override
  String get enableAndroidVenus => 'Enable ANDROID_VENUS=1';

  @override
  String get androidVenusHint =>
      'Add ANDROID_VENUS=1 environment variable to Venus server command';

  @override
  String get venusSection => 'Venus (Vulkan)';

  @override
  String get venusAdvantages =>
      'Vulkan-based hardware acceleration using Android\'s Vulkan driver';

  @override
  String get venusServerParams => 'Venus server parameters';

  @override
  String get venusEnvVar => 'Venus environment variables';

  @override
  String get enableVenus => 'Enable Venus (Android Vulkan)';

  @override
  String get virglSection => 'VirGL (OpenGL)';
}
