import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'adrenotools_manager.dart';
import 'services/vulkan_loader.dart';   // 
import 'package:flutter/foundation.dart';

class AdrenotoolsSettingsPage extends StatefulWidget {
  @override
  _AdrenotoolsSettingsPageState createState() => _AdrenotoolsSettingsPageState();
}

class _AdrenotoolsSettingsPageState extends State<AdrenotoolsSettingsPage> {
  late AdrenotoolsDriverManager _manager;
  List<DriverMeta>? _drivers;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _manager = await AdrenotoolsDriverManager.initialize();
    await _refreshDrivers();
  }

  Future<void> _refreshDrivers() async {
    final list = _manager.getInstalledDrivers();
    setState(() {
      _drivers = list;
      _loading = false;
    });
  }

  Future<void> _installDriver() async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['zip']);
    if (result == null || result.files.isEmpty) return;

    setState(() => _loading = true);
    try {
      final bytes = await File(result.files.single.path!).readAsBytes();
      final meta = await _manager.installDriver(bytes);
      await _refreshDrivers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Driver ${meta.name} installed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Installation failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _uninstallDriver(DriverMeta meta) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Uninstall ${meta.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Uninstall')),
        ],
      ),
    );
    if (confirm != true) return;

    await _manager.uninstallDriver(meta.name);
    await _refreshDrivers();
  }

  Future<void> _activateDriver(DriverMeta meta) async {
    // 1. Save preference
    await _manager.setActiveDriver(meta);

    // 2. Immediately load the driver in this app process (if you have a Vulkan renderer)
    final success = await VulkanLoader.loadCustomDriver(
      driverDir: meta.path,
      driverName: meta.libraryName,
      hooksDir: _manager.hooksDir,
    );
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to activate driver in this process!')),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${meta.name} activated. Restart graphics if needed.')),
      );
    }
  }

  Future<void> _activateSystemDriver() async {
    await _manager.setSystemDriver();
    final success = await VulkanLoader.loadSystemDriver();
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to restore system driver')),
        );
      }
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('System driver activated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('GPU Drivers')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _installDriver,
        icon: Icon(Icons.add),
        label: Text('Install driver ZIP'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _drivers == null || _drivers!.isEmpty
              ? Center(child: Text('No custom drivers installed'))
              : ListView.builder(
                  itemCount: _drivers!.length + 1, // system driver
                  itemBuilder: (ctx, idx) {
                    if (idx == 0) {
                      return ListTile(
                        title: Text('System Driver'),
                        subtitle: Text('Built-in Qualcomm driver'),
                        leading: Icon(Icons.phone_android),
                        trailing: OutlinedButton(
                          onPressed: _activateSystemDriver,
                          child: Text('Activate'),
                        ),
                      );
                    }
                    final meta = _drivers![idx - 1];
                    return ListTile(
                      title: Text(meta.name),
                      subtitle: Text(
                          '${meta.driverVersion} by ${meta.author}'),
                      leading: Icon(Icons.memory),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.power_settings_new),
                            tooltip: 'Activate',
                            onPressed: () => _activateDriver(meta),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            tooltip: 'Uninstall',
                            onPressed: () => _uninstallDriver(meta),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}