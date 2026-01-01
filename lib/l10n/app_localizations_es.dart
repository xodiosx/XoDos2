// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'XoDos';

  @override
  String get advancedSettings => 'Configuración avanzada';

  @override
  String get restartAfterChange =>
      'Los cambios surtirán efecto después de reiniciar';

  @override
  String get resetStartupCommand => 'Restablecer comando de inicio';

  @override
  String get attention => 'Aviso';

  @override
  String get confirmResetCommand => '¿Restablecer comando de inicio?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get yes => 'Sí';

  @override
  String get signal9ErrorPage => 'Página de error Signal9';

  @override
  String get containerName => 'Nombre del contenedor';

  @override
  String get startupCommand => 'Comando de inicio';

  @override
  String get vncStartupCommand => 'Comando de inicio VNC';

  @override
  String get shareUsageHint =>
      'Puedes usar XoDos en todos los dispositivos de la misma red (por ejemplo, teléfonos y computadoras conectados al mismo WiFi).\n\nHaz clic en el botón de abajo para compartir el enlace con otros dispositivos y abrirlo en un navegador.';

  @override
  String get copyShareLink => 'Copiar enlace de uso compartido';

  @override
  String get x11InvalidHint =>
      'Esta función no está disponible cuando usas X11';

  @override
  String get cannotGetIpAddress => 'No se pudo obtener la dirección IP';

  @override
  String get shareLinkCopied => 'Enlace copiado';

  @override
  String get webRedirectUrl => 'URL de redirección web';

  @override
  String get vncLink => 'Enlace VNC';

  @override
  String get globalSettings => 'Configuración global';

  @override
  String get enableTerminalEditing => 'Habilitar edición del terminal aquí';

  @override
  String get terminalMaxLines =>
      'Líneas máximas del terminal (requiere reinicio)';

  @override
  String get pulseaudioPort => 'Puerto de recepción PulseAudio';

  @override
  String get enableTerminal => 'Habilitar terminal';

  @override
  String get enableTerminalKeypad => 'Habilitar teclado del terminal';

  @override
  String get terminalStickyKeys => 'Teclas adhesivas del terminal';

  @override
  String get keepScreenOn => 'Mantener pantalla encendida';

  @override
  String get restartRequiredHint =>
      'Las siguientes opciones se aplicarán en el próximo inicio.';

  @override
  String get startWithGUI => 'Iniciar con GUI habilitada';

  @override
  String get reinstallBootPackage => 'Reinstalar paquete de arranque';

  @override
  String get getifaddrsBridge => 'Puente getifaddrs';

  @override
  String get fixGetifaddrsPermission =>
      'Arreglar permiso getifaddrs en Android 13';

  @override
  String get fakeUOSSystem => 'Simular sistema como UOS';

  @override
  String get displaySettings => 'Configuración de pantalla';

  @override
  String get avncAdvantages =>
      'AVNC ofrece mejor experiencia de control que noVNC:\nControles tipo touchpad, doble toque para teclado, portapapeles automático, modo imagen-en-imagen, etc.';

  @override
  String get avncSettings => 'Configuración AVNC';

  @override
  String get aboutAVNC => 'Acerca de AVNC';

  @override
  String get avncResolution => 'Resolución inicial de AVNC';

  @override
  String get resolutionSettings => 'Configuración de resolución';

  @override
  String get deviceScreenResolution =>
      'La resolución de la pantalla de tu dispositivo es';

  @override
  String get width => 'Ancho';

  @override
  String get height => 'Alto';

  @override
  String get save => 'Guardar';

  @override
  String get applyOnNextLaunch => 'Aplicar en el próximo inicio';

  @override
  String get useAVNCByDefault => 'Usar AVNC por defecto';

  @override
  String get termuxX11Advantages =>
      'Termux:X11 puede ofrecer mayor velocidad que VNC en algunos casos.\n\nTen en cuenta que Termux:X11 funciona diferente a AVNC:\n- Dos dedos: clic derecho\n- Botón atrás: abre teclado adicional\n\nSi ves pantalla negra, intenta cerrar la app completamente y volver a abrirla.';

  @override
  String get termuxX11Preferences => 'Preferencias de Termux:X11';

  @override
  String get useTermuxX11ByDefault => 'Usar Termux:X11 por defecto';

  @override
  String get disableVNC => 'Deshabilitar VNC. Requiere reinicio';

  @override
  String get hidpiAdvantages =>
      'Activa HiDPI con un clic para mayor nitidez... a costa de menor velocidad.';

  @override
  String get hidpiEnvVar => 'Variables de entorno HiDPI';

  @override
  String get hidpiSupport => 'Soporte HiDPI';

  @override
  String get fileAccess => 'Acceso a archivos';

  @override
  String get fileAccessGuide => 'Guía de acceso a archivos';

  @override
  String get fileAccessHint =>
      'Solicita permisos adicionales para acceder a directorios especiales.';

  @override
  String get requestStoragePermission => 'Solicitar permiso de almacenamiento';

  @override
  String get requestAllFilesAccess => 'Solicitar acceso a todos los archivos';

  @override
  String get ignoreBatteryOptimization => 'Ignorar optimización de batería';

  @override
  String get graphicsAcceleration => 'Aceleración gráfica';

  @override
  String get experimentalFeature => 'Función experimental';

  @override
  String get graphicsAccelerationHint =>
      'Usa la GPU para mejorar el rendimiento gráfico, pero puede causar inestabilidad según el dispositivo.\n\nVirgl proporciona aceleración para apps OpenGL ES.';

  @override
  String get virglServerParams => 'Parámetros del servidor Virgl';

  @override
  String get virglEnvVar => 'Variables de entorno Virgl';

  @override
  String get enableVirgl => 'Habilitar aceleración Virgl';

  @override
  String get turnipAdvantages =>
      'Los dispositivos con GPU Adreno pueden usar Turnip para acelerar Vulkan. Combinado con Zink para acelerar OpenGL.\n(Para procesadores Snapdragon no muy antiguos)';

  @override
  String get turnipEnvVar => 'Variables de entorno Turnip';

  @override
  String get enableTurnipZink => 'Habilitar Turnip+Zink';

  @override
  String get enableDRI3 => 'Habilitar DRI3';

  @override
  String get dri3Requirement => 'DRI3 requiere Termux:X11 y Turnip';

  @override
  String get windowsAppSupport => 'Soporte para aplicaciones Windows';

  @override
  String get hangoverDescription =>
      'Ejecuta apps Windows con Hangover (ejecución cruzada sobre Wine)!\n\nSe requieren dos capas de emulación —no esperes buen rendimiento—.\n\nPara mayor velocidad, intenta activar aceleración gráfica.\n\nEs normal que falle o se bloquee.\n\nMueve las apps Windows al escritorio antes de ejecutarlas.\n\nTen paciencia, incluso si la GUI no aparece.\n\nTambién verifica si existe versión Linux arm64 oficial.';

  @override
  String get installHangoverStable => 'Instalar Hangover estable';

  @override
  String get installHangoverLatest =>
      'Instalar Hangover más reciente (puede fallar)';

  @override
  String get uninstallHangover => 'Desinstalar Hangover';

  @override
  String get clearWineData => 'Borrar datos de Wine';

  @override
  String get wineCommandsHint =>
      'Comandos comunes de Wine. Haz clic para abrir la GUI y espera.\n\nTiempos típicos:\nTiger T7510 6GB: más de 1 min\nSnapdragon 870 12GB: ~10 s';

  @override
  String get switchToJapanese => 'Cambiar el sistema a japonés';

  @override
  String get userManual => 'Manual del usuario';

  @override
  String get openSourceLicenses => 'Licencias de código abierto';

  @override
  String get permissionUsage => 'Uso de permisos';

  @override
  String get privacyStatement =>
      '\nEsta app no recopila tu información privada.\n\nNo puedo controlar el comportamiento de las apps que instales dentro del sistema del contenedor.\n\nLos permisos son usados para:\nAcceso a archivos\nNotificaciones y accesibilidad para Termux:X11';

  @override
  String get supportAuthor => 'Apoyar a los desarrolladores';

  @override
  String get recommendApp => 'Si te resulta útil, ¡recomiéndala!';

  @override
  String get projectUrl => 'URL del proyecto';

  @override
  String get commandEdit => 'Editar comando';

  @override
  String get commandName => 'Nombre del comando';

  @override
  String get commandContent => 'Contenido del comando';

  @override
  String get deleteItem => 'Eliminar';

  @override
  String get add => 'Agregar';

  @override
  String get resetCommand => 'Restablecer comando';

  @override
  String get confirmResetAllCommands => '¿Restablecer todos los comandos?';

  @override
  String get addShortcutCommand => 'Agregar comando rápido';

  @override
  String get more => 'Más';

  @override
  String get terminal => 'Terminal';

  @override
  String get control => 'Control';

  @override
  String get enterGUI => 'Entrar a la GUI';

  @override
  String get enterNumber => 'Ingresa un número';

  @override
  String get enterValidNumber => 'Ingresa un número válido';

  @override
  String get installingBootPackage => 'Instalando paquete de arranque';

  @override
  String get copyingContainerSystem => 'Copiando archivos del sistema';

  @override
  String get installingContainerSystem => 'Instalando sistema';

  @override
  String get installationComplete => 'Instalación completa';

  @override
  String get reinstallingBootPackage => 'Reinstalando paquete de arranque';

  @override
  String get issueUrl => 'Reporte de problemas';

  @override
  String get faqUrl => 'FAQ';

  @override
  String get solutionUrl => 'Guía de uso';

  @override
  String get discussionUrl => 'Discusión';

  @override
  String get firstLoadInstructions =>
      'La primera carga tarda 5–10 minutos... no requiere internet.\n\nDespués, debería cambiar automáticamente a la interfaz gráfica.\n\nEn la interfaz gráfica:\n- Tocar = clic izquierdo\n- Mantener = clic derecho\n- Dos dedos = teclado\n- Dos dedos deslizar = rueda del ratón\n\nNo salgas de la app durante la instalación.\n\nPuedes solicitar permisos abajo.\n\nMuchas carpetas están vinculadas (Downloads, Pictures...). Sin permisos habrá errores.';

  @override
  String get updateRequest =>
      'Por favor usa la última versión. Revisa el proyecto para actualizaciones.';

  @override
  String get avncScreenResize => 'Tamaño adaptable de pantalla';

  @override
  String get avncResizeFactor => 'Screen Scaling Ratio';

  @override
  String get avncResizeFactorValue => 'Current scaling is';

  @override
  String get waitingGames => 'Jugando mientras esperas';

  @override
  String get extrusionProcess => 'Proceso de Extrusión';

  @override
  String get gameTitleSnake => 'Juego de la Serpiente';

  @override
  String get gameTitleTetris => 'Tetris';

  @override
  String get gameTitleFlappy => 'Flappy Bird';

  @override
  String score(Object score) {
    return 'Puntuación: $score';
  }

  @override
  String get gameOver => '¡Juego terminado! Toca para reiniciar';

  @override
  String get startGame => 'Toca para empezar';

  @override
  String get pause => 'Pausa';

  @override
  String get resume => 'Continuar';

  @override
  String get extractionCompleteExitGame =>
      '¡Extracción completada! Saliendo del modo juego.';

  @override
  String get mindTwisterGames => 'Juegos de Mente';

  @override
  String get extractionInProgress =>
      'Reproduciendo - Extracción en progreso...';

  @override
  String get playWhileWaiting =>
      'Juega mientras esperas los procesos del sistema';

  @override
  String get gameModeActive => 'Modo Juego Activo';

  @override
  String get simulateExtractionComplete => 'Simular Extracción Completada';

  @override
  String get installCommandsSection => 'Comandos rápidos';

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
      'This will backup the system to /sdcard/xodos2backup.tar.xz. Continue?';

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
