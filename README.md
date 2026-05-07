# Live Tracking Plugin

A comprehensive Flutter plugin for real-time GPS tracking with offline support, high accuracy location monitoring, and seamless backend synchronization. Perfect for building Strava-like tracking applications, delivery tracking systems, and location-based services.

## Features

✨ **Core Features:**
- 🎯 Real-time GPS tracking with configurable accuracy levels
- 📍 Activity tracking (recording path/route from start to end)
- 💾 Local SQLite database for offline storage
- 🔄 Automatic offline/online synchronization
- 🗺️ Built-in Google Maps widget with polyline visualization
- 📊 Comprehensive tracking statistics (distance, duration, speed)
- 📲 Cross-platform support (iOS 12.0+, Android 5.0+)
- 🚀 High performance with minimal battery drain
- 🔐 Secure data handling and privacy-first design

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  live_tracking_plugin: ^0.1.0
```

Then run:

```bash
flutter pub get
```

### iOS Setup

1. Update your `ios/Podfile` to set a minimum deployment target of iOS 12.0 or higher.
2. Add location permissions to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to your location for tracking.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs access to your location for tracking in the background.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs access to your location for tracking in the background.</string>
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.pravera.flutter_foreground_task.refresh</string>
</array>
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
</array>
```

### Android Setup

1. Update `compileSdkVersion` to 34+ in `android/app/build.gradle`.
2. The plugin automatically handles location permissions via `geolocator` package.
3. For background tracking, add to `AndroidManifest.xml` and add [flutter_foreground_task](https://pub.dev/packages/flutter_foreground_task):

```xml
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

<!-- required -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />

<!-- foregroundServiceType: dataSync -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />

<!-- foregroundServiceType: remoteMessaging -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_REMOTE_MESSAGING" />

<!-- Warning: Do not change service name. -->
<service 
    android:name="com.pravera.flutter_foreground_task.service.ForegroundService"
    android:foregroundServiceType="dataSync|remoteMessaging"
    android:exported="false" />
```

## Quick Start

### Initialize the Plugin

```dart
import 'package:live_tracking_plugin/live_tracking_plugin.dart';

void main() async {
  // Initialize the plugin
  await LiveTrackingPlugin.initialize(
    apiBaseUrl: 'https://your-api.com',
    authToken: 'your-auth-token', // Optional
  );
  
  runApp(const MyApp());
}
```

### Start Tracking

```dart
import 'package:live_tracking_plugin/live_tracking_plugin.dart';

class TrackingScreen extends StatefulWidget {
  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late LiveTrackingService trackingService;

  @override
  void initState() {
    super.initState();
    trackingService = LiveTrackingPlugin.trackingService;
    
    // Setup callbacks
    trackingService.onLocationUpdate = (point) {
      debugPrint('Location updated: ${point.latitude}, ${point.longitude}');
    };
    
    trackingService.onError = (error) {
      debugPrint('Tracking error: $error');
    };
    
    trackingService.onTrackingStarted = () {
      debugPrint('Tracking session started');
    };
    
    trackingService.onTrackingStopped = () {
      debugPrint('Tracking session stopped');
    };
  }

  Future<void> startTracking() async {
    final sessionId = await trackingService.startTracking(
      title: 'My Activity',
      description: 'Running in the park',
      accuracy: GPSAccuracy.high,
      updateIntervalSeconds: 5,
      minAccuracyThreshold: 20.0, // Reject points with accuracy > 20m
    );
    
    if (sessionId != null) {
      debugPrint('Tracking started: $sessionId');
    }
  }

  Future<void> pauseTracking() async {
    final success = await trackingService.pauseTracking();
    if (success) {
      debugPrint('Tracking paused');
    }
  }

  Future<void> resumeTracking() async {
    final success = await trackingService.resumeTracking();
    if (success) {
      debugPrint('Tracking resumed');
    }
  }

  Future<void> stopTracking() async {
    final sessionId = await trackingService.stopTracking();
    if (sessionId != null) {
      debugPrint('Tracking stopped: $sessionId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Tracking')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: startTracking,
              child: const Text('Start Tracking'),
            ),
            ElevatedButton(
              onPressed: pauseTracking,
              child: const Text('Pause Tracking'),
            ),
            ElevatedButton(
              onPressed: resumeTracking,
              child: const Text('Resume Tracking'),
            ),
            ElevatedButton(
              onPressed: stopTracking,
              child: const Text('Stop Tracking'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Usage Guide

### Foreground Service (Automatic)

When you call `startTracking()`, the plugin automatically:
1. Initializes the foreground task with Android and iOS notification options
2. Registers the task handler for GPS location tracking
3. Enables auto-run on device boot
4. Acquires wake lock to prevent device sleep during tracking

No additional setup is required - the foreground service is configured internally with sensible defaults:
- Android notification channel: `live_tracking` (LOW priority)
- Event repeat interval: 1000ms
- Auto-run on boot: Enabled
- Wake lock: Enabled

### Tracking Accuracy Levels

```dart
enum GPSAccuracy {
  low,      // ~50m accuracy, best battery life
  medium,   // ~20m accuracy, balanced
  high,     // ~10m accuracy, good precision
  best,     // ~5m accuracy, highest precision, drains battery faster
}

await trackingService.startTracking(
  title: 'My Activity',
  accuracy: GPSAccuracy.high,
);
```

### Pause and Resume Tracking

```dart
// Pause current tracking session
final paused = await trackingService.pauseTracking();
if (paused) {
  print('Tracking paused successfully');
}

// Resume paused tracking session
final resumed = await trackingService.resumeTracking();
if (resumed) {
  print('Tracking resumed successfully');
}

// Stop and save the session
final sessionId = await trackingService.stopTracking();
if (sessionId != null) {
  print('Tracking session stopped and saved: $sessionId');
}
```

**Note:** Pausing tracking suspends location updates without ending the session, allowing you to resume later. Stopping the session finalizes it with complete statistics (duration, distance, average speed, etc.).

### Display Tracking on Map

```dart
class MapScreen extends StatelessWidget {
  final TrackingSession session;
  final List<LocationPoint> points;

  const MapScreen({
    required this.session,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tracking Map')),
      body: Column(
        children: [
          Expanded(
            child: LiveTrackingMapWidget(
              session: session,
              points: points,
              polylineColor: Colors.blue,
              initialZoom: 15.0,
            ),
          ),
          TrackingStatsWidget(session: session),
        ],
      ),
    );
  }
}
```

### Offline Sync Management

```dart
final syncManager = LiveTrackingPlugin.syncManager;

// Check sync status
final status = await syncManager.getSyncStatus();
debugPrint('Pending items: ${status['totalPending']}');
debugPrint('Is online: ${status['isOnline']}');

// Manually trigger sync
await syncManager.syncNow();

// Listen to connectivity changes
syncManager.isOnline.listen((isOnline) {
  debugPrint('Connection status: ${isOnline ? 'Online' : 'Offline'}');
});

// Get unsynced data
final unsyncedData = await trackingService.getUnsyncedData();
debugPrint('Unsynced sessions: ${unsyncedData['sessions'].length}');
debugPrint('Unsynced points: ${unsyncedData['points'].length}');
```

### Get Recorded Sessions

```dart
final allSessions = await trackingService.getAllSessions();

for (final session in allSessions) {
  debugPrint('Session: ${session.title}');
  debugPrint('Distance: ${session.distanceMeters} meters');
  debugPrint('Duration: ${session.durationSeconds} seconds');
  debugPrint('Average Speed: ${session.averageSpeed} m/s');
  
  // Load points for this session
  final points = await trackingService.loadSessionPoints(session.id);
  debugPrint('Points recorded: ${points.length}');
}
```

### Sync Data to Backend

The plugin automatically syncs data when online. To customize sync behavior:

```dart
final apiService = LiveTrackingPlugin.apiService;

// Upload specific session
final success = await apiService.uploadSession(session);
if (success) {
  debugPrint('Session uploaded successfully');
}

// Upload batch of points
final pointsSuccess = await apiService.uploadLocationPoints(points);
if (pointsSuccess) {
  debugPrint('Points uploaded successfully');
}

// Set authentication token
LiveTrackingPlugin.setAuthToken('Bearer your-auth-token');

// Clear authentication
LiveTrackingPlugin.clearAuthToken();

// Mark data as synced
await trackingService.markSessionAsSynced(sessionId);
await trackingService.markPointAsSynced(pointId);
```

## Backend API Requirements

For the plugin to work with your backend, implement these endpoints:

### POST `/api/v1/tracking/sessions`
Upload a new tracking session.

**Request Body:**
```json
{
  "id": "uuid",
  "title": "My Activity",
  "description": "Running in the park",
  "status": "completed",
  "startTime": "2024-01-01T10:00:00Z",
  "endTime": "2024-01-01T11:00:00Z",
  "durationSeconds": 3600,
  "distanceMeters": 5000.0,
  "averageSpeed": 1.39,
  "pointCount": 100,
  "minAccuracy": 20.0,
  "metadata": {}
}
```

### POST `/api/v1/tracking/points/batch`
Upload batch of location points.

**Request Body:**
```json
{
  "points": [
    {
      "id": "uuid",
      "latitude": -6.2088,
      "longitude": 106.8456,
      "accuracy": 15.5,
      "altitude": 50.0,
      "speed": 2.5,
      "heading": 180.0,
      "timestamp": "2024-01-01T10:00:00Z",
      "sessionId": "session-uuid"
    }
  ]
}
```

### GET `/api/v1/health`
Health check endpoint.

### GET `/api/v1/tracking/sessions`
Query parameters: `limit=50&offset=0`

### GET `/api/v1/tracking/sessions/{sessionId}`
Get specific session.

### GET `/api/v1/tracking/sessions/{sessionId}/points`
Get points for a session.

### PUT `/api/v1/tracking/sessions/{sessionId}`
Update a session.

### DELETE `/api/v1/tracking/sessions/{sessionId}`
Delete a session.

## Advanced Features

### Custom Headers and Authentication

```dart
// Add custom header
LiveTrackingPlugin.apiService.addHeader('X-Custom-Header', 'value');

// Set auth token
LiveTrackingPlugin.setAuthToken('Bearer your-token');

// Configure Dio client with custom settings
final customDio = Dio(BaseOptions(
  connectTimeout: Duration(seconds: 30),
  receiveTimeout: Duration(seconds: 30),
));

final apiService = LiveTrackingApiService(
  baseUrl: 'https://your-api.com',
  dioClient: customDio,
);
```

### Real-time Location Updates with GetX

```dart
// Listen to location updates in real-time
Obx(() {
  final lastLocation = trackingService.lastLocation.value;
  if (lastLocation != null) {
    return Text('Lat: ${lastLocation.latitude}, Lng: ${lastLocation.longitude}');
  }
  return const Text('No location yet');
});

// Listen to total distance
Obx(() => Text('Distance: ${trackingService.totalDistance.value.toStringAsFixed(2)}m'));

// Listen to tracking state
Obx(() => Text(trackingService.isTracking.value ? 'Tracking...' : 'Idle'));

// Listen to point count
Obx(() => Text('Points: ${trackingService.pointCount.value}'));

// Setup event callbacks
trackingService.onLocationUpdate = (point) {
  debugPrint('New location: ${point.latitude}, ${point.longitude}');
};

trackingService.onTrackingStarted = () {
  debugPrint('Tracking session started');
};

trackingService.onTrackingStopped = () {
  debugPrint('Tracking session completed');
};

trackingService.onError = (error) {
  debugPrint('Error occurred: $error');
};
```

### Database Access

```dart
final dbHelper = LiveTrackingPlugin.dbHelper;

// Get all points from a session
final points = await dbHelper.getPointsBySession(sessionId);

// Get unsynced data
final unsyncedSessions = await dbHelper.getUnsyncedSessions();
final unsyncedPoints = await dbHelper.getUnsyncedPoints();

// Mark data as synced
await dbHelper.updateSessionSyncStatus(sessionId, true);
await dbHelper.updatePointSyncStatus(pointId, true);
```

## Battery Optimization

The plugin is designed to be battery-efficient:

- Use `GPSAccuracy.low` for non-critical tracking
- Increase `updateIntervalSeconds` for slower movement tracking
- Use `minAccuracyThreshold` to filter out bad GPS readings
- Enable sync only when online

```dart
await trackingService.startTracking(
  title: 'Low Power Mode',
  accuracy: GPSAccuracy.low,
  updateIntervalSeconds: 30,  // Update every 30 seconds
  minAccuracyThreshold: 50.0,  // Only accept accuracy ≤ 50m
);
```

## Error Handling

```dart
trackingService.onError = (errorMessage) {
  debugPrint('Tracking error: $errorMessage');
  // Handle error - show user notification
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Tracking error: $errorMessage')),
  );
};

// Check location permissions
LocationPermission permission = await Geolocator.checkPermission();
if (permission == LocationPermission.denied) {
  permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied) {
    debugPrint('Location permission denied');
    return;
  }
}

if (permission == LocationPermission.deniedForever) {
  // Open app settings
  await Geolocator.openAppSettings();
}

// Check location services
final locationEnabled = await Geolocator.isLocationServiceEnabled();
if (!locationEnabled) {
  debugPrint('Location services are disabled');
  // Show dialog to enable location services
  await Geolocator.openLocationSettings();
}
```

## Platform Specific Notes

### iOS
- Minimum deployment target: iOS 12.0
- Requires location permission prompts in Info.plist
- Background location tracking requires "Always" permission
- Privacy manifest may be required for App Store submission

### Android
- Minimum API level: 21 (Android 5.0)
- Requires runtime permissions for Android 6.0+
- Background tracking supported on Android 8.0+
- High accuracy GPS requires ACCESS_FINE_LOCATION permission

## Troubleshooting

### Location not being tracked
- ✅ Check if location permissions are granted (use `Geolocator.checkPermission()`)
- ✅ Verify location services are enabled on device
- ✅ Try a different accuracy level (start with `GPSAccuracy.high`)
- ✅ Ensure you have internet connection for sync
- ✅ Check device's GPS is working (test with Google Maps)
- ✅ Verify `startTracking()` returns a valid sessionId

### Data not syncing
- ✅ Verify backend API endpoint is accessible
- ✅ Check network connectivity with `syncManager.isOnline`
- ✅ Review sync status with `syncManager.getSyncStatus()`
- ✅ Verify auth token is valid: `LiveTrackingPlugin.setAuthToken()`
- ✅ Check backend API response format matches requirements
- ✅ Review unsynced data: `trackingService.getUnsyncedData()`

### High battery drain
- ✅ Use lower accuracy level: `GPSAccuracy.low` or `GPSAccuracy.medium`
- ✅ Increase update interval: `updateIntervalSeconds: 30` or higher
- ✅ Increase accuracy threshold: `minAccuracyThreshold: 50.0`
- ✅ Limit tracking sessions duration
- ✅ Check for location stream errors in logs

### Foreground service not running
- ✅ Ensure location permissions are granted
- ✅ Verify notification channel is properly configured
- ✅ Check Android OS version (requires 5.0+)
- ✅ Review device notification settings
- ✅ Check app battery optimization settings

### Database errors
- ✅ Ensure write permissions are granted
- ✅ Check available storage space
- ✅ Verify database file is not corrupted
- ✅ Clear app cache if persistent issues occur

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues and questions, please visit:
- GitHub Issues: [Click Here](https://github.com/GydeonZ/live_tracking_plugin/issues)
- Documentation: [Click Here](https://github.com/GydeonZ/live_tracking_plugin)

## Acknowledgments

Built with ❤️ using:
- [flutter_foreground_task](https://pub.dev/packages/flutter_foreground_task) - Foreground task management
- [geolocator](https://pub.dev/packages/geolocator) - GPS location
- [google_maps_flutter](https://pub.dev/packages/google_maps_flutter) - Map widget
- [sqflite](https://pub.dev/packages/sqflite) - Local database
- [dio](https://pub.dev/packages/dio) - HTTP client
- [get](https://pub.dev/packages/get) - State management
