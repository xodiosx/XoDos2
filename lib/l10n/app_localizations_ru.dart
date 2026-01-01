// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'XoDos';

  @override
  String get advancedSettings => 'Расширенные настройки';

  @override
  String get restartAfterChange => 'Изменения вступят в силу после перезапуска';

  @override
  String get resetStartupCommand => 'Сбросить команду запуска';

  @override
  String get attention => 'Внимание';

  @override
  String get confirmResetCommand => 'Сбросить команду запуска?';

  @override
  String get cancel => 'Отмена';

  @override
  String get yes => 'Да';

  @override
  String get signal9ErrorPage => 'Страница ошибки Signal9';

  @override
  String get containerName => 'Имя контейнера';

  @override
  String get startupCommand => 'Команда запуска';

  @override
  String get vncStartupCommand => 'Команда запуска VNC';

  @override
  String get shareUsageHint =>
      'Вы можете использовать XoDos на всех устройствах в одной сети (например, телефонах и ПК в одной WiFi-сети).\n\nНажмите кнопку ниже, чтобы поделиться ссылкой.';

  @override
  String get copyShareLink => 'Копировать ссылку';

  @override
  String get x11InvalidHint => 'Функция недоступна при использовании X11';

  @override
  String get cannotGetIpAddress => 'Не удалось получить IP-адрес';

  @override
  String get shareLinkCopied => 'Ссылка скопирована';

  @override
  String get webRedirectUrl => 'URL перенаправления';

  @override
  String get vncLink => 'VNC ссылка';

  @override
  String get globalSettings => 'Глобальные настройки';

  @override
  String get enableTerminalEditing => 'Разрешить редактирование терминала';

  @override
  String get terminalMaxLines => 'Макс. строки терминала (нужен перезапуск)';

  @override
  String get pulseaudioPort => 'Порт PulseAudio';

  @override
  String get enableTerminal => 'Включить терминал';

  @override
  String get enableTerminalKeypad => 'Включить клавиатуру терминала';

  @override
  String get terminalStickyKeys => 'Залипающие клавиши';

  @override
  String get keepScreenOn => 'Не выключать экран';

  @override
  String get restartRequiredHint =>
      'Следующие параметры вступят в силу при следующем запуске.';

  @override
  String get startWithGUI => 'Запускать с GUI';

  @override
  String get reinstallBootPackage => 'Переустановить загрузочный пакет';

  @override
  String get getifaddrsBridge => 'Мост getifaddrs';

  @override
  String get fixGetifaddrsPermission =>
      'Исправить разрешение getifaddrs (Android 13)';

  @override
  String get fakeUOSSystem => 'Эмулировать систему UOS';

  @override
  String get displaySettings => 'Настройки дисплея';

  @override
  String get avncAdvantages =>
      'AVNC обеспечивает лучший контроль, чем noVNC:\nТачпад-режим, двойной тап для клавиатуры, буфер обмена, PiP и др.';

  @override
  String get avncSettings => 'Настройки AVNC';

  @override
  String get aboutAVNC => 'О AVNC';

  @override
  String get avncResolution => 'Начальное разрешение AVNC';

  @override
  String get resolutionSettings => 'Настройки разрешения';

  @override
  String get deviceScreenResolution => 'Разрешение экрана устройства:';

  @override
  String get width => 'Ширина';

  @override
  String get height => 'Высота';

  @override
  String get save => 'Сохранить';

  @override
  String get applyOnNextLaunch => 'Применится при следующем запуске';

  @override
  String get useAVNCByDefault => 'Использовать AVNC по умолчанию';

  @override
  String get termuxX11Advantages =>
      'Termux:X11 может быть быстрее VNC в некоторых случаях.\n\nОтличия от AVNC:\n- Два пальца = правый клик\n- Кнопка Назад = клавиатура\n\nЕсли экран черный — перезапустите приложение.';

  @override
  String get termuxX11Preferences => 'Настройки Termux:X11';

  @override
  String get useTermuxX11ByDefault => 'Использовать Termux:X11 по умолчанию';

  @override
  String get disableVNC => 'Отключить VNC (нужен перезапуск)';

  @override
  String get hidpiAdvantages =>
      'HiDPI даёт более четкое изображение… но снижает скорость.';

  @override
  String get hidpiEnvVar => 'Переменные HiDPI';

  @override
  String get hidpiSupport => 'Поддержка HiDPI';

  @override
  String get fileAccess => 'Доступ к файлам';

  @override
  String get fileAccessGuide => 'Гид по доступу к файлам';

  @override
  String get fileAccessHint =>
      'Запросите дополнительные разрешения для доступа к каталогам.';

  @override
  String get requestStoragePermission => 'Запросить доступ к хранилищу';

  @override
  String get requestAllFilesAccess => 'Запросить доступ ко всем файлам';

  @override
  String get ignoreBatteryOptimization => 'Игнорировать оптимизацию батареи';

  @override
  String get graphicsAcceleration => 'Графическое ускорение';

  @override
  String get experimentalFeature => 'Экспериментальная функция';

  @override
  String get graphicsAccelerationHint =>
      'Использует GPU для ускорения графики. Возможна нестабильность.\n\nVirgl ускоряет OpenGL ES.';

  @override
  String get virglServerParams => 'Параметры Virgl';

  @override
  String get virglEnvVar => 'Переменные Virgl';

  @override
  String get enableVirgl => 'Включить Virgl';

  @override
  String get turnipAdvantages =>
      'GPU Adreno могут использовать Turnip (Vulkan) и Zink (OpenGL).\n(Для Snapdragon не слишком старых)';

  @override
  String get turnipEnvVar => 'Переменные Turnip';

  @override
  String get enableTurnipZink => 'Включить Turnip+Zink';

  @override
  String get enableDRI3 => 'Включить DRI3';

  @override
  String get dri3Requirement => 'DRI3 требует Termux:X11 и Turnip';

  @override
  String get windowsAppSupport => 'Поддержка Windows-приложений';

  @override
  String get hangoverDescription =>
      'Запуск Windows приложений с Hangover!\n\nДве ступени эмуляции — низкая производительность.\n\nГрафическое ускорение может помочь.\n\nСбои нормальны.\n\nПереместите программы Windows на рабочий стол перед запуском.';

  @override
  String get installHangoverStable => 'Установить стабильный Hangover';

  @override
  String get installHangoverLatest =>
      'Установить последнюю версию Hangover (может не работать)';

  @override
  String get uninstallHangover => 'Удалить Hangover';

  @override
  String get clearWineData => 'Очистить данные Wine';

  @override
  String get wineCommandsHint =>
      'Команды Wine. Откройте GUI и ждите.\n\nОбычно:\nTiger T7510 6GB: >1 мин\nSnapdragon 870: ~10 сек';

  @override
  String get switchToJapanese => 'Сменить систему на японскую';

  @override
  String get userManual => 'Руководство пользователя';

  @override
  String get openSourceLicenses => 'Открытые лицензии';

  @override
  String get permissionUsage => 'Использование разрешений';

  @override
  String get privacyStatement =>
      '\nПриложение не собирает личные данные.\n\nОднако программы внутри контейнера могут это делать.\n\nРазрешения используются для:\nДоступа к файлам\nУведомлений и сервисов Termux:X11';

  @override
  String get supportAuthor => 'Поддержать разработчиков';

  @override
  String get recommendApp => 'Если приложение полезно — расскажите другим!';

  @override
  String get projectUrl => 'URL проекта';

  @override
  String get commandEdit => 'Редактировать команду';

  @override
  String get commandName => 'Имя команды';

  @override
  String get commandContent => 'Содержимое команды';

  @override
  String get deleteItem => 'Удалить';

  @override
  String get add => 'Добавить';

  @override
  String get resetCommand => 'Сбросить команду';

  @override
  String get confirmResetAllCommands => 'Сбросить все команды?';

  @override
  String get addShortcutCommand => 'Добавить быстрый команд';

  @override
  String get more => 'Еще';

  @override
  String get terminal => 'Терминал';

  @override
  String get control => 'Управление';

  @override
  String get enterGUI => 'Войти в GUI';

  @override
  String get enterNumber => 'Введите число';

  @override
  String get enterValidNumber => 'Введите правильное число';

  @override
  String get installingBootPackage => 'Установка загрузочного пакета';

  @override
  String get copyingContainerSystem => 'Копирование системных файлов';

  @override
  String get installingContainerSystem => 'Установка системы';

  @override
  String get installationComplete => 'Установка завершена';

  @override
  String get reinstallingBootPackage => 'Переустановка загрузочного пакета';

  @override
  String get issueUrl => 'Сообщить об ошибке';

  @override
  String get faqUrl => 'FAQ';

  @override
  String get solutionUrl => 'Инструкция';

  @override
  String get discussionUrl => 'Обсуждение';

  @override
  String get firstLoadInstructions =>
      'Первый запуск занимает 5–10 минут... без интернета.\n\nПосле загрузки откроется графический интерфейс.\n\nВ GUI:\n- Касание = левый клик\n- Долгое удержание = правый клик\n- Два пальца = клавиатура\n- Два пальца вверх/вниз = прокрутка\n\nНе закрывайте приложение во время установки.';

  @override
  String get updateRequest =>
      'Пожалуйста, используйте последнюю версию. Проверьте проект.';

  @override
  String get avncScreenResize => 'Адаптивный размер экрана';

  @override
  String get avncResizeFactor => 'Screen Scaling Ratio';

  @override
  String get avncResizeFactorValue => 'Current scaling is';

  @override
  String get waitingGames => 'Игра во время ожидания';

  @override
  String get extrusionProcess => 'Процесс экструзии';

  @override
  String get gameTitleSnake => 'Игра Змейка';

  @override
  String get gameTitleTetris => 'Тетрис';

  @override
  String get gameTitleFlappy => 'Flappy Bird';

  @override
  String score(Object score) {
    return 'Счёт: $score';
  }

  @override
  String get gameOver => 'Игра окончена! Нажмите, чтобы начать заново';

  @override
  String get startGame => 'Нажмите, чтобы начать';

  @override
  String get pause => 'Пауза';

  @override
  String get resume => 'Продолжить';

  @override
  String get extractionCompleteExitGame =>
      'Извлечение завершено! Выход из игрового режима.';

  @override
  String get mindTwisterGames => 'Игры для Ума';

  @override
  String get extractionInProgress =>
      'Воспроизведение - Извлечение в процессе...';

  @override
  String get playWhileWaiting => 'Играйте, пока ждете системные процессы';

  @override
  String get gameModeActive => 'Игровой Режим Активен';

  @override
  String get simulateExtractionComplete => 'Сымитировать Завершение Извлечения';

  @override
  String get installCommandsSection => 'Быстрые команды';

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
