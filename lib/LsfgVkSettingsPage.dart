import 'dart:io';
import 'package:flutter/material.dart';
import 'core_classes.dart'; // G, Util

// ---------- Model ----------
class GameProfile {
  String exe;
  int? multiplier;               // 1–10, null = disabled
  double? flowScale;             // 0.0–3.0, null = disabled
  bool? performanceMode;         // true/false, null = disabled
  bool? hdrMode;                 // true/false, null = disabled
  String? experimentalPresentMode; // "fifo" etc., null = disabled

  GameProfile({
    required this.exe,
    this.multiplier,
    this.flowScale,
    this.performanceMode,
    this.hdrMode,
    this.experimentalPresentMode,
  });

  factory GameProfile.defaults(String exe) => GameProfile(
        exe: exe,
        multiplier: 4,
        performanceMode: true,
      );
}

// ---------- Page ----------
class LsfgVkSettingsPage extends StatefulWidget {
  const LsfgVkSettingsPage({Key? key}) : super(key: key);

  @override
  _LsfgVkSettingsPageState createState() => _LsfgVkSettingsPageState();
}

class _LsfgVkSettingsPageState extends State<LsfgVkSettingsPage> {
  static final String _prefix = '/data/data/com.xodos/files/usr';
  static final File _drvFile = File('$_prefix/opt/drv');
  static final File _libFile = File('$_prefix/lib/liblsfg-vk-layer.so');
  static final File _libOffFile = File('$_prefix/lib/liblsfg-vk-layer.so.off');
  static final File _configFile = File('/data/data/com.xodos/files/home/.config/lsfg-vk/conf.toml');


  bool _lsfgEnabled = false;
  bool _loading = true;
  List<GameProfile> _games = [];
  List<String> _globalLines = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _lsfgEnabled = G.prefs.getBool('lsfg_enabled') ?? false;
    if (_configFile.existsSync()) {
      _parseConfig();
    }
    setState(() => _loading = false);
  }

  // ---------- Enable / Disable ----------
  Future<void> _toggleLsfg(bool value) async {
    if (value == _lsfgEnabled) return;

    if (value) {
      if (!_drvFile.existsSync() ||
          !_drvFile.readAsStringSync().contains('# Adrenotools custom driver')) {
        _showAlert(
          'LSFG-VK (Lossless Frame Generation) requires Android driver with AHB support.\n\n'
          'Please install Adrenotools custom drivers first.',
        );
        return;
      }

      try {
        if (_libOffFile.existsSync()) {
          _libOffFile.renameSync(_libFile.path);
        }
      } catch (e) {
        _showSnack('Failed to enable LSFG-VK: $e');
        return;
      }

      G.prefs.setBool('lsfg_enabled', true);
      setState(() => _lsfgEnabled = true);
      _showSnack('LSFG-VK enabled');
    } else {
      try {
        if (_libFile.existsSync()) {
          _libFile.renameSync(_libOffFile.path);
        }
      } catch (e) {
        _showSnack('Failed to disable LSFG-VK: $e');
        return;
      }

      G.prefs.setBool('lsfg_enabled', false);
      setState(() => _lsfgEnabled = false);
      _showSnack('LSFG-VK disabled');
    }
  }

  // ---------- Config file handling ----------
  void _parseConfig() {
    final content = _configFile.readAsStringSync();
    final lines = content.split('\n');
    _globalLines = [];
    _games = [];
    int? gameStart;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.startsWith('[[') && line.contains('game')) {
        if (gameStart != null) {
          _games.add(_parseGameBlock(lines.sublist(gameStart, i)));
        }
        gameStart = i;
      } else if (gameStart == null) {
        _globalLines.add(lines[i]);
      }
    }
    if (gameStart != null) {
      _games.add(_parseGameBlock(lines.sublist(gameStart)));
    }
  }

  GameProfile _parseGameBlock(List<String> block) {
    String exe = '';
    int? multiplier;
    double? flowScale;
    bool? perfMode;
    bool? hdrMode;
    String? presentMode;

    for (final line in block) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

      if (trimmed.startsWith('exe =')) {
        exe = _extractQuoted(trimmed) ?? '';
      } else if (trimmed.startsWith('multiplier =')) {
        final val = _extractValue(trimmed);
        multiplier = val != null ? int.tryParse(val) : null;
      } else if (trimmed.startsWith('flow_scale =')) {
        final val = _extractValue(trimmed);
        flowScale = val != null ? double.tryParse(val) : null;
      } else if (trimmed.startsWith('performance_mode =')) {
        final val = _extractValue(trimmed);
        perfMode = val == 'true' ? true : (val == 'false' ? false : null);
      } else if (trimmed.startsWith('hdr_mode =')) {
        final val = _extractValue(trimmed);
        hdrMode = val == 'true' ? true : (val == 'false' ? false : null);
      } else if (trimmed.startsWith('experimental_present_mode =')) {
        presentMode = _extractQuoted(trimmed);
      }
    }
    return GameProfile(
      exe: exe,
      multiplier: multiplier,
      flowScale: flowScale,
      performanceMode: perfMode,
      hdrMode: hdrMode,
      experimentalPresentMode: presentMode,
    );
  }

  String? _extractQuoted(String s) {
    final m = RegExp(r'"([^"]*)"').firstMatch(s);
    return m?.group(1);
  }

  String? _extractValue(String s) {
    final eq = s.indexOf('=');
    if (eq == -1) return null;
    return s.substring(eq + 1).trim();
  }

  void _saveConfig() {
    final buf = StringBuffer();
    for (final line in _globalLines) {
      buf.writeln(line);
    }
    if (buf.isNotEmpty && !buf.toString().endsWith('\n\n')) {
      buf.writeln();
    }

    for (final game in _games) {
      buf.writeln('[[game]]');
      buf.writeln('exe = "${game.exe}"');
      if (game.multiplier != null) buf.writeln('multiplier = ${game.multiplier}');
      if (game.flowScale != null) {
        buf.writeln('flow_scale = ${game.flowScale!.toStringAsFixed(2)}');
      }
      if (game.performanceMode != null) {
        buf.writeln('performance_mode = ${game.performanceMode}');
      }
      if (game.hdrMode != null) {
        buf.writeln('hdr_mode = ${game.hdrMode}');
      }
      if (game.experimentalPresentMode != null) {
        buf.writeln('experimental_present_mode = "${game.experimentalPresentMode}"');
      }
      buf.writeln();
    }
    _configFile.writeAsStringSync(buf.toString());
  }

  // ---------- Game actions ----------
  Future<void> _addGame() async {
    final controller = TextEditingController();
    final exe = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Game Profile'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'exe name, e.g. Game.exe'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text('Add'),
          ),
        ],
      ),
    );

    if (exe == null || exe.isEmpty) return;

    setState(() {
      _games.add(GameProfile.defaults(exe));
      _saveConfig();
    });
  }

  Future<void> _editGame(GameProfile game) async {
    final result = await _showEditDialog(game);
    if (result == null) return;

    final index = _games.indexOf(game);
    setState(() {
      _games[index] = result;
      _saveConfig();
    });
  }

  Future<GameProfile?> _showEditDialog(GameProfile game) async {
    int? multiplier = game.multiplier;
    double? flowScale = game.flowScale;
    bool? perfMode = game.performanceMode;
    bool? hdrMode = game.hdrMode;
    String? presentMode = game.experimentalPresentMode;

    bool multEnabled = multiplier != null;
    bool flowEnabled = flowScale != null;
    bool perfEnabled = perfMode != null;
    bool hdrEnabled = hdrMode != null;
    bool presEnabled = presentMode != null;

    return showDialog<GameProfile>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Edit ${game.exe}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Multiplier')),
                    Checkbox(
                      value: multEnabled,
                      onChanged: (v) {
                        setDialogState(() {
                          multEnabled = v!;
                          if (!v) multiplier = null;
                        });
                      },
                    ),
                    DropdownButton<int>(
                      value: (multiplier != null && multiplier! >= 1 && multiplier! <= 10)
                          ? multiplier
                          : 4,
                      items: List.generate(10, (i) => i + 1)
                          .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                          .toList(),
                      onChanged: multEnabled
                          ? (v) => setDialogState(() => multiplier = v)
                          : null,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: Text('Flow Scale')),
                    Checkbox(
                      value: flowEnabled,
                      onChanged: (v) {
                        setDialogState(() {
                          flowEnabled = v!;
                          if (!v) flowScale = null;
                        });
                      },
                    ),
                    Expanded(
                      child: Slider(
                        value: flowScale ?? 0.80,
                        min: 0.0,
                        max: 3.0,
                        divisions: 30,
                        label: (flowScale ?? 0.80).toStringAsFixed(2),
                        onChanged: flowEnabled
                            ? (v) => setDialogState(() => flowScale = v)
                            : null,
                      ),
                    ),
                    Text(flowScale?.toStringAsFixed(2) ?? 'off'),
                  ],
                ),
                SwitchListTile(
                  title: Text('Performance Mode'),
                  value: perfMode ?? false,
                  onChanged: perfEnabled
                      ? (v) => setDialogState(() => perfMode = v)
                      : null,
                  secondary: Checkbox(
                    value: perfEnabled,
                    onChanged: (v) {
                      setDialogState(() {
                        perfEnabled = v!;
                        if (!v) perfMode = null;
                      });
                    },
                  ),
                ),
                SwitchListTile(
                  title: Text('HDR Mode'),
                  value: hdrMode ?? false,
                  onChanged: hdrEnabled
                      ? (v) => setDialogState(() => hdrMode = v)
                      : null,
                  secondary: Checkbox(
                    value: hdrEnabled,
                    onChanged: (v) {
                      setDialogState(() {
                        hdrEnabled = v!;
                        if (!v) hdrMode = null;
                      });
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(child: Text('Present Mode')),
                    Checkbox(
                      value: presEnabled,
                      onChanged: (v) {
                        setDialogState(() {
                          presEnabled = v!;
                          if (!v) presentMode = null;
                        });
                      },
                    ),
                    DropdownButton<String>(
                      value: (presentMode != null &&
                              ['fifo', 'immediate', 'mailbox', 'relaxed']
                                  .contains(presentMode))
                          ? presentMode!
                          : 'fifo',
                      items: ['fifo', 'immediate', 'mailbox', 'relaxed']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: presEnabled
                          ? (v) => setDialogState(() => presentMode = v)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  ctx,
                  GameProfile(
                    exe: game.exe,
                    multiplier: multEnabled ? multiplier : null,
                    flowScale: flowEnabled ? flowScale : null,
                    performanceMode: perfEnabled ? perfMode : null,
                    hdrMode: hdrEnabled ? hdrMode : null,
                    experimentalPresentMode: presEnabled ? presentMode : null,
                  ),
                );
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeGame(GameProfile game) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove ${game.exe}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Remove')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() {
      _games.remove(game);
      _saveConfig();
    });
  }

  void _resetGameToDefault(GameProfile game) {
    final defaults = GameProfile.defaults(game.exe);
    final index = _games.indexOf(game);
    setState(() {
      _games[index] = defaults;
      _saveConfig();
    });
  }

  Future<void> _resetAllConfig() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reset all settings?'),
        content: Text('This will restore the default configuration, '
            'removing any custom game profiles.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Reset')),
        ],
      ),
    );
    if (confirm != true) return;

    const defaultConfig = '''
version = 1
[global]

# override the location of Lossless Scaling
 dll ="/data/data/com.xodos/files/usr/share/lsfg-vk/Lossless.dll"

# [[game]] # example entry
# exe = "Game.exe"
#
 multiplier = 2
 flow_scale = 0.80
 performance_mode = true
 hdr_mode = false
 experimental_present_mode = "fifo"

[[game]] # default vkcube entry
exe = "vkcube"

multiplier = 4
performance_mode = true

[[game]] # default benchmark entry
exe = "benchmark"

multiplier = 4
performance_mode = false

[[game]] # override Genshin Impact
exe = "glmark2"

multiplier = 3
performance_mode = true


[[game]] # default vkcube entry
exe = "vkmark"

multiplier = 4
performance_mode = true
''';

    _configFile.writeAsStringSync(defaultConfig);
    _parseConfig();
    setState(() {});
    _showSnack('LSFG-VK configuration reset');
  }

  // ---------- Helpers ----------
  void _showAlert(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cannot enable LSFG-VK'),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('OK')),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LSFG-VK'),
        actions: [
          IconButton(
            icon: Icon(Icons.restore),
            tooltip: 'Reset all',
            onPressed: _resetAllConfig,
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                SwitchListTile(
                  title: Text('Enable LSFG-VK'),
                  subtitle: Text('Requires Adrenotools custom driver with AHB'),
                  value: _lsfgEnabled,
                  onChanged: _toggleLsfg,
                ),
                Divider(),
                if (_lsfgEnabled) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Game Profiles', style: Theme.of(context).textTheme.titleMedium),
                        ElevatedButton.icon(
                          onPressed: _addGame,
                          icon: Icon(Icons.add),
                          label: Text('Add'),
                        ),
                      ],
                    ),
                  ),
                  if (_games.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('No game profiles configured.'),
                    )
                  else
                    ..._games.map((game) => Card(
                          child: ListTile(
                            title: Text(game.exe),
                            subtitle: Text([
                              if (game.multiplier != null) 'x${game.multiplier}',
                              if (game.performanceMode == true) 'perf',
                              if (game.hdrMode == true) 'HDR',
                              if (game.flowScale != null)
                                'flow ${game.flowScale!.toStringAsFixed(2)}',
                              if (game.experimentalPresentMode != null)
                                game.experimentalPresentMode!,
                            ].join(', ')),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.settings),
                                  tooltip: 'Edit',
                                  onPressed: () => _editGame(game),
                                ),
                                IconButton(
                                  icon: Icon(Icons.refresh),
                                  tooltip: 'Reset to default',
                                  onPressed: () => _resetGameToDefault(game),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  tooltip: 'Remove',
                                  onPressed: () => _removeGame(game),
                                ),
                              ],
                            ),
                          ),
                        )),
                ],
              ],
            ),
    );
  }
}