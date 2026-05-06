import 'package:flutter/material.dart';

import 'package:live_tracking_plugin/live_tracking_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize plugin
    initPlugin();
  }

  Future<void> initPlugin() async {
    try {
      await LiveTrackingPlugin.initialize(apiBaseUrl: 'https://api.example.com');
    } on Exception catch (e) {
      debugPrint('Failed to initialize: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Live Tracking Plugin Example')),
        body: const Center(child: Text('Live Tracking Plugin Initialized')),
      ),
    );
  }
}
