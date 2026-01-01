// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'XoDos';

  @override
  String get advancedSettings => '詳細設定';

  @override
  String get restartAfterChange => '変更は再起動後に有効になります';

  @override
  String get resetStartupCommand => '起動コマンドをリセット';

  @override
  String get attention => '注意';

  @override
  String get confirmResetCommand => '起動コマンドをリセットしますか？';

  @override
  String get cancel => 'キャンセル';

  @override
  String get yes => 'はい';

  @override
  String get signal9ErrorPage => 'Signal9 エラーページ';

  @override
  String get containerName => 'コンテナ名';

  @override
  String get startupCommand => '起動コマンド';

  @override
  String get vncStartupCommand => 'VNC 起動コマンド';

  @override
  String get shareUsageHint =>
      '同じネットワーク内（同じWiFiに接続されたスマホ・PCなど）で XoDos を利用できます。\n\n以下のボタンを押してリンクを共有し、ブラウザで開いてください。';

  @override
  String get copyShareLink => '共有リンクをコピー';

  @override
  String get x11InvalidHint => 'X11 使用時、この機能は利用できません';

  @override
  String get cannotGetIpAddress => 'IPアドレスを取得できません';

  @override
  String get shareLinkCopied => '共有リンクをコピーしました';

  @override
  String get webRedirectUrl => 'Web リダイレクト URL';

  @override
  String get vncLink => 'VNC リンク';

  @override
  String get globalSettings => 'グローバル設定';

  @override
  String get enableTerminalEditing => 'ここでターミナル編集を有効化';

  @override
  String get terminalMaxLines => 'ターミナル最大行数（再起動が必要）';

  @override
  String get pulseaudioPort => 'PulseAudio 受信ポート';

  @override
  String get enableTerminal => 'ターミナルを有効化';

  @override
  String get enableTerminalKeypad => 'ターミナルキーパッドを有効化';

  @override
  String get terminalStickyKeys => 'ターミナルスティッキーキー';

  @override
  String get keepScreenOn => '画面を常にオンにする';

  @override
  String get restartRequiredHint => '以下の設定は次回起動時に有効になります。';

  @override
  String get startWithGUI => 'GUI を有効にして起動';

  @override
  String get reinstallBootPackage => 'ブートパッケージを再インストール';

  @override
  String get getifaddrsBridge => 'getifaddrs ブリッジ';

  @override
  String get fixGetifaddrsPermission => 'Android 13 の getifaddrs 権限を修正';

  @override
  String get fakeUOSSystem => 'UOS システムとして偽装する';

  @override
  String get displaySettings => 'ディスプレイ設定';

  @override
  String get avncAdvantages =>
      'AVNC は noVNC より優れた操作性を提供します：\nタッチパッド操作、2本指タップでキーボード、自動クリップボード、PiPモードなど';

  @override
  String get avncSettings => 'AVNC 設定';

  @override
  String get aboutAVNC => 'AVNC について';

  @override
  String get avncResolution => 'AVNC 起動解像度';

  @override
  String get resolutionSettings => '解像度設定';

  @override
  String get deviceScreenResolution => 'この端末の画面解像度は';

  @override
  String get width => '幅';

  @override
  String get height => '高さ';

  @override
  String get save => '保存';

  @override
  String get applyOnNextLaunch => '次回起動時に適用';

  @override
  String get useAVNCByDefault => 'デフォルトで AVNC を使用';

  @override
  String get termuxX11Advantages =>
      'Termux:X11 は状況によって VNC より高速になることがあります。\n\nTermux:X11 の主な操作:\n- 2本指タップ → 右クリック\n- 戻るボタン → 追加キーボードを表示\n\n黒い画面になった場合はアプリを完全に再起動してください。';

  @override
  String get termuxX11Preferences => 'Termux:X11 設定';

  @override
  String get useTermuxX11ByDefault => 'デフォルトで Termux:X11 を使用';

  @override
  String get disableVNC => 'VNC を無効化（再起動が必要）';

  @override
  String get hidpiAdvantages =>
      'ワンクリックで HiDPI を有効化してより鮮明な表示を実現します（速度低下の可能性あり）。';

  @override
  String get hidpiEnvVar => 'HiDPI 環境変数';

  @override
  String get hidpiSupport => 'HiDPI サポート';

  @override
  String get fileAccess => 'ファイルアクセス';

  @override
  String get fileAccessGuide => 'ファイルアクセスガイド';

  @override
  String get fileAccessHint => '特別なディレクトリにアクセスするため追加権限が必要です。';

  @override
  String get requestStoragePermission => 'ストレージ権限を要求';

  @override
  String get requestAllFilesAccess => '全ファイルアクセス権を要求';

  @override
  String get ignoreBatteryOptimization => 'バッテリー最適化を無視';

  @override
  String get graphicsAcceleration => 'グラフィックアクセラレーション';

  @override
  String get experimentalFeature => '実験的機能';

  @override
  String get graphicsAccelerationHint =>
      'GPU を利用して描画性能を向上しますが、端末によっては不安定になる可能性があります。\n\nVirgl は OpenGL ES アプリに加速を提供します。';

  @override
  String get virglServerParams => 'Virgl サーバーパラメータ';

  @override
  String get virglEnvVar => 'Virgl 環境変数';

  @override
  String get enableVirgl => 'Virgl アクセラレーションを有効化';

  @override
  String get turnipAdvantages =>
      'Adreno GPU を搭載した端末では Turnip ドライバを使用して Vulkan を高速化できます。\nOpenGL には Zink ドライバを併用します。\n（比較的新しい Snapdragon 端末向け）';

  @override
  String get turnipEnvVar => 'Turnip 環境変数';

  @override
  String get enableTurnipZink => 'Turnip + Zink を有効化';

  @override
  String get enableDRI3 => 'DRI3 を有効化';

  @override
  String get dri3Requirement => 'DRI3 には Termux:X11 と Turnip が必要です';

  @override
  String get windowsAppSupport => 'Windows アプリのサポート';

  @override
  String get hangoverDescription =>
      'Hangover を使用して Windows アプリを実行！\n\n2層のエミュレーションが必要なため、性能は期待できません。\n\nグラフィックアクセラレーションを有効化すると高速化できます。\nクラッシュは正常です。\n\n実行前に Windows プログラムをデスクトップへ移動してください。\n\n何も表示されなくても処理が続いている場合があります。ターミナルを確認してください。\n\nまたは、アプリに公式 arm64 Linux 版があるか確認してください。';

  @override
  String get installHangoverStable => 'Hangover 安定版をインストール';

  @override
  String get installHangoverLatest => 'Hangover 最新版をインストール（失敗する可能性あり）';

  @override
  String get uninstallHangover => 'Hangover をアンインストール';

  @override
  String get clearWineData => 'Wine データをクリア';

  @override
  String get wineCommandsHint =>
      'よく使う Wine コマンド。クリックして GUI を起動します。時間がかかる場合があります。\n\n典型的な起動時間：\nTiger T7510 6GB: 1分以上\nSnapdragon 870 12GB: 約10秒';

  @override
  String get switchToJapanese => 'システム言語を日本語に切り替え';

  @override
  String get userManual => 'ユーザーマニュアル';

  @override
  String get openSourceLicenses => 'オープンソースライセンス';

  @override
  String get permissionUsage => '権限の使用について';

  @override
  String get privacyStatement =>
      '\nこのアプリはあなたの個人情報を収集しません。\n\nただし、コンテナ内で実行されるアプリの挙動は保証できません。\n\n要求される権限は次の用途です：\nファイル権限：端末ディレクトリへのアクセス\n通知・アクセシビリティ：Termux:X11 に必要';

  @override
  String get supportAuthor => '開発者を支援';

  @override
  String get recommendApp => '役に立ったら、ぜひ他の人にも紹介してください！';

  @override
  String get projectUrl => 'プロジェクト URL';

  @override
  String get commandEdit => 'コマンド編集';

  @override
  String get commandName => 'コマンド名';

  @override
  String get commandContent => 'コマンド内容';

  @override
  String get deleteItem => '削除';

  @override
  String get add => '追加';

  @override
  String get resetCommand => 'コマンドをリセット';

  @override
  String get confirmResetAllCommands => 'すべてのコマンドをリセットしますか？';

  @override
  String get addShortcutCommand => 'ショートカットコマンドを追加';

  @override
  String get more => 'もっと見る';

  @override
  String get terminal => 'ターミナル';

  @override
  String get control => 'コントロール';

  @override
  String get enterGUI => 'GUI に入る';

  @override
  String get enterNumber => '数字を入力してください';

  @override
  String get enterValidNumber => '有効な数字を入力してください';

  @override
  String get installingBootPackage => 'ブートパッケージをインストール中';

  @override
  String get copyingContainerSystem => 'システムファイルをコピー中';

  @override
  String get installingContainerSystem => 'システムをインストール中';

  @override
  String get installationComplete => 'インストール完了';

  @override
  String get reinstallingBootPackage => 'ブートパッケージを再インストール中';

  @override
  String get issueUrl => '問題を報告';

  @override
  String get faqUrl => 'FAQ';

  @override
  String get solutionUrl => '使用ガイド';

  @override
  String get discussionUrl => 'ディスカッション';

  @override
  String get firstLoadInstructions =>
      '初回ロードには約5〜10分かかります…インターネット接続は不要です。\n\n通常、完了後に自動でGUIに移動します。\n\nGUI内の操作:\n- タップ → 左クリック\n- 長押し → 右クリック\n- 2本指タップ → キーボード\n- 2本指スワイプ → ホイール\n\nインストール中は終了しないでください。\n\n必要であれば下のボタンで権限を要求してください。\n\n多くのフォルダ（Downloads, Documents, Pictures）は端末のフォルダにリンクされています。権限がないとアクセスが拒否されます。\n\n必要ない場合は権限をスキップできます。';

  @override
  String get updateRequest => '最新バージョンを使用してください。プロジェクトページで確認できます。';

  @override
  String get avncScreenResize => '画面サイズを自動調整';

  @override
  String get avncResizeFactor => 'Screen Scaling Ratio';

  @override
  String get avncResizeFactorValue => 'Current scaling is';

  @override
  String get waitingGames => '待機中にゲームをプレイ';

  @override
  String get extrusionProcess => '押出プロセス';

  @override
  String get gameTitleSnake => 'スネークゲーム';

  @override
  String get gameTitleTetris => 'テトリス';

  @override
  String get gameTitleFlappy => 'フラッピーバード';

  @override
  String score(Object score) {
    return 'スコア: $score';
  }

  @override
  String get gameOver => 'ゲームオーバー！タップして再開';

  @override
  String get startGame => 'タップして開始';

  @override
  String get pause => '一時停止';

  @override
  String get resume => '再開';

  @override
  String get extractionCompleteExitGame => '抽出が完了しました！ゲームモードを終了します。';

  @override
  String get mindTwisterGames => 'マインドツイスタゲーム';

  @override
  String get extractionInProgress => '再生中 - 抽出進行中...';

  @override
  String get playWhileWaiting => 'システムプロセス待機中にプレイ';

  @override
  String get gameModeActive => 'ゲームモードアクティブ';

  @override
  String get simulateExtractionComplete => '抽出完了をシミュレート';

  @override
  String get installCommandsSection => 'クイックコマンド';

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
