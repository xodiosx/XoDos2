import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:xodos/l10n/app_localizations.dart';
import 'package:flutter/services.dart'; // For SystemNavigator
import 'constants.dart';
import 'default_values.dart';
import 'core_classes.dart';

class BackupRestoreDialog extends StatefulWidget {
  const BackupRestoreDialog({super.key});

  @override
  State<BackupRestoreDialog> createState() => _BackupRestoreDialogState();
}

class _BackupRestoreDialogState extends State<BackupRestoreDialog> {
  bool _isProcessing = false;
  String _statusMessage = '';

  Future<void> _backupSystem() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirmBackup),
        content: Text(AppLocalizations.of(context)!.backupConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() {
                _isProcessing = true;
                _statusMessage = AppLocalizations.of(context)!.backupInProgress;
              });

              try {
                // Execute backup command using termWrite
                Util.termWrite(
                  'cd / && ./busybox tar -Jcpvf /sd/xodos2backup.tar.xz '
                  '--exclude=".l2s.*" bin boot etc home/xodos/.config/ lib mnt opt '
                  'root run sbin srv tmp usr var drivers scripts wincomponents busybox'
                );
                
                // Show completion message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.backupComplete),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${AppLocalizations.of(context)!.backupFailed}: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() {
                    _isProcessing = false;
                  });
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.backup),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreSystem() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
  type: FileType.any, // <-- IMPORTANT
  allowMultiple: false,
);

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileName = result.files.single.name.toLowerCase();

final file = result.files.single;
//final fileName = file.name.toLowerCase();

if (!fileName.endsWith('.tar') &&
    !fileName.endsWith('.tar.gz') &&
    !fileName.endsWith('.tar.xz')) {

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.unsupportedFormat),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  return; // STOP here
}

        // Convert the file path to a path accessible in the container
final result2 = filePath;
if (filePath == null) return;

final prootPath = fixProotPath(filePath);
//THIS is the path you must use from now on
        String containerPath = prootPath;
        
      //  final filePath = file.path;
if (filePath == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(AppLocalizations.of(context)!.invalidPath),
      backgroundColor: Colors.red,
    ),
  );
  return;
}



        if (fileName.contains('wine')) {
          // Wine installation
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(AppLocalizations.of(context)!.installWine),
              content: Text(AppLocalizations.of(context)!.wineInstallationWarning),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _installWine(containerPath, fileName);
                  },
                  child: Text(AppLocalizations.of(context)!.install),
                ),
              ],
            ),
          );
        } else {
          // System restore
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(AppLocalizations.of(context)!.systemRestore),
              content: Text(AppLocalizations.of(context)!.systemRestoreWarning),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _restoreBackup(containerPath, fileName);
                  },
                  child: Text(AppLocalizations.of(context)!.restore),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.fileSelectionFailed}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _installWine(String filePath, String fileName) async {
    setState(() {
      _isProcessing = true;
      _statusMessage = AppLocalizations.of(context)!.installingWine;
    });

    try {
    final result2 = filePath;
if (filePath == null) return;

final prootPath = fixProotPath(filePath);
//THIS is the path you must use from now on
        String containerPath = prootPath;
        
      // Escape the file path for shell (handle spaces and special characters)
      final escapedPath = containerPath;
      
      // Run wine installation commands using termWrite
      Util.termWrite('echo "=== STARTING WINE INSTALLATION FROM: $fileName ==="');
      Util.termWrite('echo "Removing existing wine installation..."');
      Util.termWrite('rm -rf /opt/wine');
      
      Util.termWrite('echo "Extracting wine archive..."');
      Util.termWrite('tar -xf "$escapedPath" -C /opt/');
      
      Util.termWrite('echo "Renaming extracted directory to wine..."');
      Util.termWrite('mv /opt/*wine* /opt/wine 2>/dev/null || true');
      Util.termWrite('mv /opt/Wine* /opt/wine 2>/dev/null || true');
      Util.termWrite('mv /opt/wine* /opt/wine 2>/dev/null || true');
      
      Util.termWrite('echo "Setting executable permissions..."');
      Util.termWrite('chmod +x /opt/wine/bin/* 2>/dev/null || true');
      
    //  Util.termWrite('echo "Cleaning up..."');
     // Util.termWrite('find /opt/wine -name "*.so" -exec chmod +x {} \\; 2>/dev/null || true');
      
      Util.termWrite('echo "=== WINE INSTALLATION COMPLETE ==="');
      Util.termWrite('echo "Wine installed to /opt/wine"');
      
      // Show success message
      if (mounted) {
        await Future.delayed(const Duration(seconds: 1));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.wineInstallationComplete),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      // Ask to restart
      if (mounted) {
        await Future.delayed(const Duration(seconds: 1));
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.restartRequired),
            content: Text(AppLocalizations.of(context)!.restartAppToApply),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Close the app
                  SystemNavigator.pop();
                },
                child: Text(AppLocalizations.of(context)!.ok),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.wineInstallationFailed}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _restoreBackup(String filePath, String fileName) async {
  setState(() {
    _isProcessing = true;
    _statusMessage = AppLocalizations.of(context)!.restoreInProgress;
  });

  try {
  final result2 = filePath;
if (filePath == null) return;

final prootPath = fixProotPath(filePath);
//THIS is the path you must use from now on
        String containerPath = prootPath;
        
    // Escape the file path for shell

    final escapedPath = containerPath;
    
    // Switch to terminal page (index 0)
 G.pageIndex.value = 0;
    // Show source and destination information
    Util.termWrite('echo "=== STARTING SYSTEM RESTORE ==="');
    Util.termWrite('echo "Source file: $escapedPath"');
    Util.termWrite('echo "Destination: /data/data/com.xodos/files/containers/0/"');
    Util.termWrite('echo ""');
    
    String extractCommand;
    
    // Determine extraction command based on file extension
    if (fileName.endsWith('.tar.xz')) {
      // Check if tar command is available, fallback to busybox if not
      Util.termWrite('echo "Checking for tar command..."');
      Util.termWrite('if command -v tar >/dev/null 2>&1; then');
      Util.termWrite('  echo "Using system tar command"');
      Util.termWrite('  tar -xJv --delay-directory-restore --preserve-permissions -f "$escapedPath" -C /data/data/com.xodos/files/containers/0/');
      Util.termWrite('else');
      Util.termWrite('  echo "Using busybox tar command"');
      Util.termWrite('  /data/data/com.xodos/files/bin/busybox tar -xJv --delay-directory-restore --preserve-permissions -f "$escapedPath" -C /data/data/com.xodos/files/containers/0/');
      Util.termWrite('fi');
    } else if (fileName.endsWith('.tar.gz')) {
      Util.termWrite('echo "Checking for tar command..."');
      Util.termWrite('if command -v tar >/dev/null 2>&1; then');
      Util.termWrite('  echo "Using system tar command"');
      Util.termWrite('  tar -xzv --delay-directory-restore --preserve-permissions -f "$escapedPath" -C /data/data/com.xodos/files/containers/0/');
      Util.termWrite('else');
      Util.termWrite('  echo "Using busybox tar command"');
      Util.termWrite('  /data/data/com.xodos/files/bin/busybox tar -xzv --delay-directory-restore --preserve-permissions -f "$escapedPath" -C /data/data/com.xodos/files/containers/0/');
      Util.termWrite('fi');
    } else if (fileName.endsWith('.tar')) {
      Util.termWrite('echo "Checking for tar command..."');
      Util.termWrite('if command -v tar >/dev/null 2>&1; then');
      Util.termWrite('  echo "Using system tar command"');
      Util.termWrite('  tar -xv --delay-directory-restore --preserve-permissions -f "$escapedPath" -C /data/data/com.xodos/files/containers/0/');
      Util.termWrite('else');
      Util.termWrite('  echo "Using busybox tar command"');
      Util.termWrite('  /data/data/com.xodos/files/bin/busybox tar -xv --delay-directory-restore --preserve-permissions -f "$escapedPath" -C /data/data/com.xodos/files/containers/0/');
      Util.termWrite('fi');
    } else {
      throw Exception('${AppLocalizations.of(context)!.unsupportedFormat}: $fileName');
    }
    
    Util.termWrite('echo ""');
    Util.termWrite('echo "=== SYSTEM RESTORE COMPLETE ==="');
    Util.termWrite('echo "Please restart the app for changes to take effect."');
    
    // Show success message
    if (mounted) {
      await Future.delayed(const Duration(seconds: 1));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.restoreComplete),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
    
    // Ask to restart
    if (mounted) {
      await Future.delayed(const Duration(seconds: 1));
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.restartRequired),
          content: Text(AppLocalizations.of(context)!.restartAppToApply),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Close the app
                SystemNavigator.pop();
              },
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.restoreFailed}: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }
}
String fixProotPath(String androidPath) {
  if (androidPath.startsWith('/data/user/0/')) {
    return androidPath.replaceFirst('/data/user/0/', '/data/data/');
  }
  return androidPath;
}
  // Helper function to escape shell arguments
  String _escapeShellArgument(String argument) {
    // Replace single quotes with '"'"' to escape them in shell
    return "'${argument.replaceAll("'", "'\"'\"'")}'";
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 500,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                AppLocalizations.of(context)!.backupRestore,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              if (_isProcessing) ...[
                // Processing state
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.checkTerminalForProgress,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(AppLocalizations.of(context)!.close),
                  ),
                ),
              ] else ...[
                // Normal state
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Description
                        Text(
                          AppLocalizations.of(context)!.backupRestoreDescription,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        
                        // Info Card - made more compact
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[100]!),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.info, color: Colors.blue, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(context)!.importantNote,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(context)!.backupRestoreHint,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[800], // Fixed: removed const
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                
                // Buttons
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.backup, size: 20),
                            label: Text(
                              AppLocalizations.of(context)!.backupSystem,
                              style: const TextStyle(fontSize: 14),
                            ),
                            onPressed: _backupSystem,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.restore, size: 20),
                            label: Text(
                              AppLocalizations.of(context)!.restoreSystem,
                              style: const TextStyle(fontSize: 14),
                            ),
                            onPressed: _restoreSystem,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.close,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}