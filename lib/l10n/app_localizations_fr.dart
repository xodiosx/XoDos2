// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'XoDos';

  @override
  String get advancedSettings => 'Paramètres avancés';

  @override
  String get restartAfterChange =>
      'Les changements prendront effet après redémarrage';

  @override
  String get resetStartupCommand => 'Réinitialiser la commande de démarrage';

  @override
  String get attention => 'Attention';

  @override
  String get confirmResetCommand => 'Réinitialiser la commande de démarrage ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get yes => 'Oui';

  @override
  String get signal9ErrorPage => 'Page d’erreur Signal9';

  @override
  String get containerName => 'Nom du conteneur';

  @override
  String get startupCommand => 'Commande de démarrage';

  @override
  String get vncStartupCommand => 'Commande de démarrage VNC';

  @override
  String get shareUsageHint =>
      'Vous pouvez utiliser XoDos sur tous les appareils du même réseau (ex. téléphones, ordinateurs connectés au même WiFi).\n\nCliquez sur le bouton ci-dessous pour partager le lien avec d’autres appareils et l’ouvrir dans un navigateur.';

  @override
  String get copyShareLink => 'Copier le lien de partage';

  @override
  String get x11InvalidHint =>
      'Cette fonctionnalité n’est pas disponible lorsque vous utilisez X11';

  @override
  String get cannotGetIpAddress => 'Impossible d’obtenir l’adresse IP';

  @override
  String get shareLinkCopied => 'Lien de partage copié';

  @override
  String get webRedirectUrl => 'URL de redirection Web';

  @override
  String get vncLink => 'Lien VNC';

  @override
  String get globalSettings => 'Paramètres globaux';

  @override
  String get enableTerminalEditing => 'Activer l’édition du terminal ici';

  @override
  String get terminalMaxLines => 'Lignes max du terminal (redémarrage requis)';

  @override
  String get pulseaudioPort => 'Port de réception PulseAudio';

  @override
  String get enableTerminal => 'Activer le terminal';

  @override
  String get enableTerminalKeypad => 'Activer le pavé numérique du terminal';

  @override
  String get terminalStickyKeys => 'Touches collantes du terminal';

  @override
  String get keepScreenOn => 'Garder l\'écran allumé';

  @override
  String get restartRequiredHint =>
      'Les options suivantes prendront effet au prochain lancement.';

  @override
  String get startWithGUI => 'Démarrer avec l’interface graphique activée';

  @override
  String get reinstallBootPackage => 'Réinstaller le package de démarrage';

  @override
  String get getifaddrsBridge => 'Passerelle getifaddrs';

  @override
  String get fixGetifaddrsPermission =>
      'Corriger les permissions getifaddrs sur Android 13';

  @override
  String get fakeUOSSystem => 'Simuler un système UOS';

  @override
  String get displaySettings => 'Paramètres d\'affichage';

  @override
  String get avncAdvantages =>
      'AVNC offre une meilleure expérience que noVNC:\nContrôle type pavé tactile, toucher à deux doigts pour clavier, presse-papiers automatique, mode image-dans-image, etc.';

  @override
  String get avncSettings => 'Paramètres AVNC';

  @override
  String get aboutAVNC => 'À propos d’AVNC';

  @override
  String get avncResolution => 'Résolution de démarrage AVNC';

  @override
  String get resolutionSettings => 'Paramètres de résolution';

  @override
  String get deviceScreenResolution => 'La résolution de votre écran est';

  @override
  String get width => 'Largeur';

  @override
  String get height => 'Hauteur';

  @override
  String get save => 'Enregistrer';

  @override
  String get applyOnNextLaunch => 'S’appliquera au prochain lancement';

  @override
  String get useAVNCByDefault => 'Utiliser AVNC par défaut';

  @override
  String get termuxX11Advantages =>
      'Termux:X11 peut offrir une vitesse plus rapide que VNC dans certains cas.\n\nNotez que Termux:X11 fonctionne légèrement différemment d’AVNC:\n- Le toucher à deux doigts effectue un clic droit\n- Appuyer sur Retour affiche le clavier supplémentaire\n\nSi un écran noir apparaît, essayez de fermer et de redémarrer complètement l’application.';

  @override
  String get termuxX11Preferences => 'Préférences Termux:X11';

  @override
  String get useTermuxX11ByDefault => 'Utiliser Termux:X11 par défaut';

  @override
  String get disableVNC => 'Désactiver VNC. Requiert un redémarrage';

  @override
  String get hidpiAdvantages =>
      'Activez HiDPI en un clic pour un affichage plus net… au prix d’une vitesse réduite.';

  @override
  String get hidpiEnvVar => 'Variables d’environnement HiDPI';

  @override
  String get hidpiSupport => 'Support HiDPI';

  @override
  String get fileAccess => 'Accès aux fichiers';

  @override
  String get fileAccessGuide => 'Guide d’accès aux fichiers';

  @override
  String get fileAccessHint =>
      'Demandez des permissions supplémentaires pour accéder à des répertoires spéciaux.';

  @override
  String get requestStoragePermission => 'Demander la permission de stockage';

  @override
  String get requestAllFilesAccess => 'Demander l’accès à tous les fichiers';

  @override
  String get ignoreBatteryOptimization =>
      'Ignorer l’optimisation de la batterie';

  @override
  String get graphicsAcceleration => 'Accélération graphique';

  @override
  String get experimentalFeature => 'Fonction expérimentale';

  @override
  String get graphicsAccelerationHint =>
      'Utilise le GPU de l’appareil pour améliorer la performance graphique mais peut causer une instabilité selon le modèle.\n\nVirgl fournit une accélération pour les applications OpenGL ES.';

  @override
  String get virglServerParams => 'Paramètres du serveur Virgl';

  @override
  String get virglEnvVar => 'Variables d’environnement Virgl';

  @override
  String get enableVirgl => 'Activer l’accélération Virgl';

  @override
  String get turnipAdvantages =>
      'Les appareils avec GPU Adreno peuvent utiliser le driver Turnip pour l’accélération Vulkan. Combiné avec Zink pour l’accélération OpenGL.\n(Pour les appareils Snapdragon récents)';

  @override
  String get turnipEnvVar => 'Variables d’environnement Turnip';

  @override
  String get enableTurnipZink => 'Activer les drivers Turnip+Zink';

  @override
  String get enableDRI3 => 'Activer DRI3';

  @override
  String get dri3Requirement => 'DRI3 requiert Termux:X11 et Turnip';

  @override
  String get windowsAppSupport => 'Support des applications Windows';

  @override
  String get hangoverDescription =>
      'Exécutez des applications Windows avec Hangover (exécution d’apps cross-architecture sous Wine)!\n\nDeux couches d’émulation sont nécessaires — ne vous attendez pas à des performances élevées.\n\nPour de meilleures performances, essayez l’accélération graphique. Les crashs sont normaux.\n\nDéplacez les programmes Windows sur le bureau avant de les lancer.\n\nSoyez patient — même si l’interface ne montre rien.\n\nOu vérifiez si l’application Windows a une version Linux arm64 officielle.';

  @override
  String get installHangoverStable => 'Installer Hangover Stable';

  @override
  String get installHangoverLatest =>
      'Installer Hangover Latest (peut échouer)';

  @override
  String get uninstallHangover => 'Désinstaller Hangover';

  @override
  String get clearWineData => 'Effacer les données Wine';

  @override
  String get wineCommandsHint =>
      'Commandes Wine courantes. Cliquez pour lancer l’interface graphique et patientez.\n\nTemps de lancement typiques:\nTiger T7510 6GB : plus de 1 minute\nSnapdragon 870 12GB : ~10 secondes';

  @override
  String get switchToJapanese => 'Passer le système en japonais';

  @override
  String get userManual => 'Manuel utilisateur';

  @override
  String get openSourceLicenses => 'Licences open source';

  @override
  String get permissionUsage => 'Utilisation des permissions';

  @override
  String get privacyStatement =>
      '\nCette application ne collecte pas vos informations privées.\n\nCependant, je ne peux pas contrôler les comportements des applications installées/utilisées dans le conteneur.\n\nLes permissions demandées sont utilisées pour :\nPermissions de fichiers : accès aux répertoires du téléphone\nNotifications & accessibilité : requis par Termux:X11';

  @override
  String get supportAuthor => 'Soutenir les développeurs';

  @override
  String get recommendApp =>
      'Si vous trouvez l’application utile, recommandez-la !';

  @override
  String get projectUrl => 'URL du projet';

  @override
  String get commandEdit => 'Éditer la commande';

  @override
  String get commandName => 'Nom de la commande';

  @override
  String get commandContent => 'Contenu de la commande';

  @override
  String get deleteItem => 'Supprimer l’élément';

  @override
  String get add => 'Ajouter';

  @override
  String get resetCommand => 'Réinitialiser la commande';

  @override
  String get confirmResetAllCommands => 'Réinitialiser toutes les commandes ?';

  @override
  String get addShortcutCommand => 'Ajouter une commande raccourcie';

  @override
  String get more => 'Plus';

  @override
  String get terminal => 'Terminal';

  @override
  String get control => 'Contrôle';

  @override
  String get enterGUI => 'Entrer dans l’interface graphique';

  @override
  String get enterNumber => 'Veuillez entrer un nombre';

  @override
  String get enterValidNumber => 'Veuillez entrer un nombre valide';

  @override
  String get installingBootPackage => 'Installation du package de démarrage';

  @override
  String get copyingContainerSystem => 'Copie du système de fichiers';

  @override
  String get installingContainerSystem => 'Installation du système';

  @override
  String get installationComplete => 'Installation terminée';

  @override
  String get reinstallingBootPackage =>
      'Réinstallation du package de démarrage';

  @override
  String get issueUrl => 'Signaler un problème';

  @override
  String get faqUrl => 'FAQ';

  @override
  String get solutionUrl => 'Guide d’utilisation';

  @override
  String get discussionUrl => 'Discussion';

  @override
  String get firstLoadInstructions =>
      'Le premier chargement prend environ 5 à 10 minutes... et ne nécessite pas Internet.\n\nL’application redirige normalement vers l’interface graphique.\n\nDans l’interface graphique:\n- Appui simple : clic gauche\n- Appui long : clic droit\n- Deux doigts : clavier\n- Glisser à deux doigts : molette\n\nNe quittez pas l’application pendant l’installation.\n\nVous pouvez demander les permissions ci-dessous.\n\nDe nombreux dossiers (Downloads, Documents, Pictures) sont liés à ceux du téléphone. Sans permissions, l’accès sera refusé.\n\nSi vous n’en avez pas besoin, ignorez la demande de permissions.';

  @override
  String get updateRequest =>
      'Veuillez utiliser la dernière version. Consultez l’adresse du projet.';

  @override
  String get avncScreenResize => 'Ajustement automatique de l’écran';

  @override
  String get avncResizeFactor => 'Screen Scaling Ratio';

  @override
  String get avncResizeFactorValue => 'Current scaling is';

  @override
  String get waitingGames => 'Jouer en attendant';

  @override
  String get extrusionProcess => 'Processus d\'extrusion';

  @override
  String get gameTitleSnake => 'Jeu du Serpent';

  @override
  String get gameTitleTetris => 'Tetris';

  @override
  String get gameTitleFlappy => 'Flappy Bird';

  @override
  String score(Object score) {
    return 'Score : $score';
  }

  @override
  String get gameOver => 'Jeu terminé ! Appuyez pour recommencer';

  @override
  String get startGame => 'Appuyez pour démarrer';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Reprendre';

  @override
  String get extractionCompleteExitGame =>
      'Extraction terminée ! Sortie du mode jeu.';

  @override
  String get mindTwisterGames => 'Jeux de Réflexion';

  @override
  String get extractionInProgress =>
      'En cours de lecture - Extraction en cours...';

  @override
  String get playWhileWaiting => 'Jouer en attendant les processus système';

  @override
  String get gameModeActive => 'Mode Jeu Actif';

  @override
  String get simulateExtractionComplete => 'Simuler l\'Extraction Terminée';
}
