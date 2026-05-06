import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_tracking_plugin/live_tracking_plugin.dart';

/// Simple example of using Live Tracking Plugin
void main() async {
  // Initialize the plugin
  await LiveTrackingPlugin.initialize(apiBaseUrl: 'https://your-api.example.com', authToken: 'your-auth-token');

  runApp(const LiveTrackingExample());
}

class LiveTrackingExample extends StatelessWidget {
  const LiveTrackingExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Live Tracking Example',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const TrackingScreen(),
    );
  }
}

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({Key? key}) : super(key: key);

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late LiveTrackingService trackingService;
  late OfflineSyncManager syncManager;

  @override
  void initState() {
    super.initState();
    trackingService = LiveTrackingPlugin.trackingService;
    syncManager = LiveTrackingPlugin.syncManager;

    // Setup error handling
    trackingService.onError = (error) {
      print('Tracking error: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
    };

    trackingService.onLocationUpdate = (point) {
      print('Location: ${point.latitude}, ${point.longitude}');
    };

    trackingService.onTrackingStarted = () {
      print('Tracking started');
    };

    trackingService.onTrackingStopped = () {
      print('Tracking stopped');
    };
  }

  Future<void> _startTracking() async {
    final sessionId = await trackingService.startTracking(
      title: 'My Activity',
      description: 'Running in the park',
      accuracy: GPSAccuracy.high,
      updateIntervalSeconds: 5,
      minAccuracyThreshold: 20.0,
    );

    if (sessionId != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tracking started: $sessionId')));
    }
  }

  Future<void> _stopTracking() async {
    final sessionId = await trackingService.stopTracking();
    if (sessionId != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tracking stopped: $sessionId')));
    }
  }

  Future<void> _pauseTracking() async {
    final success = await trackingService.pauseTracking();
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tracking paused')));
    }
  }

  Future<void> _resumeTracking() async {
    final success = await trackingService.resumeTracking();
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tracking resumed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Tracking Example'), elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tracking Status Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tracking Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Obx(
                        () => _StatusRow(
                          label: 'Status',
                          value: trackingService.isTracking.value ? 'Tracking...' : 'Idle',
                          color: trackingService.isTracking.value ? Colors.green : Colors.grey,
                        ),
                      ),
                      Obx(
                        () => _StatusRow(
                          label: 'Total Distance',
                          value: '${(trackingService.totalDistance.value / 1000).toStringAsFixed(2)} km',
                        ),
                      ),
                      Obx(
                        () => _StatusRow(label: 'Points Recorded', value: trackingService.pointCount.value.toString()),
                      ),
                      Obx(
                        () => _StatusRow(
                          label: 'Connectivity',
                          value: syncManager.isOnline.value ? 'Online' : 'Offline',
                          color: syncManager.isOnline.value ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Control Buttons
              const Text('Tracking Controls', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _startTracking,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Tracking'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pauseTracking,
                      icon: const Icon(Icons.pause),
                      label: const Text('Pause'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _resumeTracking,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Resume'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _stopTracking,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                icon: const Icon(Icons.stop),
                label: const Text('Stop Tracking'),
              ),
              const SizedBox(height: 24),

              // Sync Status
              const Text('Sync Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StatusRow(label: 'Sync Status', value: syncManager.isSyncing.value ? 'Syncing...' : 'Idle'),
                        _StatusRow(label: 'Pending Items', value: syncManager.pendingItems.value.toString()),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Session History
              const Text('Session History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _showSessionHistory, child: const Text('View Sessions')),
            ],
          ),
        ),
      ),
    );
  }

  void _showSessionHistory() {
    showDialog(
      context: context,
      builder: (context) => _SessionHistoryDialog(trackingService: trackingService),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatusRow({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              if (color != null)
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  margin: const EdgeInsets.only(right: 8),
                ),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionHistoryDialog extends StatelessWidget {
  final LiveTrackingService trackingService;

  const _SessionHistoryDialog({required this.trackingService});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Session History'),
      content: SizedBox(
        width: double.maxFinite,
        child: FutureBuilder<List<TrackingSession>>(
          future: trackingService.getAllSessions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No sessions yet'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final session = snapshot.data![index];
                return ListTile(
                  title: Text(session.title),
                  subtitle: Text(
                    '${session.pointCount} points • ${(session.distanceMeters ?? 0 / 1000).toStringAsFixed(2)} km',
                  ),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.pop(context);
                    _showSessionDetails(context, session);
                  },
                );
              },
            );
          },
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
    );
  }

  void _showSessionDetails(BuildContext context, TrackingSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(session.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow(label: 'Duration', value: '${session.getDuration().inMinutes} minutes'),
              _DetailRow(label: 'Distance', value: '${(session.distanceMeters ?? 0 / 1000).toStringAsFixed(2)} km'),
              _DetailRow(label: 'Points', value: session.pointCount.toString()),
              _DetailRow(label: 'Status', value: session.status),
              _DetailRow(label: 'Synced', value: session.isSynced ? 'Yes' : 'No'),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label + ':'),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
