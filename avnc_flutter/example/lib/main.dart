import 'package:flutter/material.dart';
import 'dart:async';

import 'package:avnc_flutter/avnc_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> _launchAvnc() async {
    try {
      await AvncFlutter.launchUsingUri("vnc://127.0.0.1:5904?VncPassword=12345678&SecurityType=2", resizeRemoteDesktop: true, resizeRemoteDesktopScaleFactor: 0.5);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  Future<void> _launchPrefs() async {
    try {
      await AvncFlutter.launchPrefsPage();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  Future<void> _launchAbout() async {
    try {
      await AvncFlutter.launchAboutPage();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('AVNC Plugin Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _launchAvnc,
                child: const Text('Launch AVNC'),
              ),
              ElevatedButton(
                onPressed: _launchPrefs,
                child: const Text('Launch Prefs'),
              ),
              ElevatedButton(
                onPressed: _launchAbout,
                child: const Text('Launch About'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
