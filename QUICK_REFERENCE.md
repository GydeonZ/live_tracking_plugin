# Live Tracking Plugin - Quick Reference Guide

## 🚀 5-Minute Quick Start

### Step 1: Add to pubspec.yaml
```yaml
dependencies:
  live_tracking_plugin: ^0.1.0
```

### Step 2: Initialize in main()
```dart
void main() async {
  await LiveTrackingPlugin.initialize(
    apiBaseUrl: 'https://your-api.com',
  );
  runApp(MyApp());
}
```

### Step 3: Start Tracking
```dart
final service = LiveTrackingPlugin.trackingService;

// Start
await service.startTracking(
  title: 'My Activity',
  accuracy: GPSAccuracy.high,
);

// Stop
await service.stopTracking();
```

### Step 4: Display on Map
```dart
LiveTrackingMapWidget(
  session: session,
  points: points,
  polylineColor: Colors.blue,
)
```

---

## 🎛️ Common Operations

### Get Current Stats
```dart
trackingService.totalDistance.value    // meters
trackingService.pointCount.value       // number of points
trackingService.isTracking.value       // bool
```

### Listen to Updates (Reactive)
```dart
Obx(() => Text('Distance: ${trackingService.totalDistance.value}m'));
```

### Load Session Points
```dart
final points = await trackingService.loadSessionPoints(sessionId);
```

### Check Sync Status
```dart
final status = await syncManager.getSyncStatus();
print('Pending: ${status['totalPending']}');
```

### Pause/Resume
```dart
await trackingService.pauseTracking();
await trackingService.resumeTracking();
```

---

## ⚙️ Configuration Options

### Accuracy Levels
```dart
GPSAccuracy.low     // ~50m, best battery
GPSAccuracy.medium  // ~20m, balanced
GPSAccuracy.high    // ~10m, good precision
GPSAccuracy.best    // ~5m, highest precision
```

### Start Tracking with Options
```dart
await trackingService.startTracking(
  title: 'Run',
  accuracy: GPSAccuracy.high,
  updateIntervalSeconds: 5,
  minAccuracyThreshold: 20.0,  // Reject worse accuracy
);
```

---

## 🗺️ Map Widget Usage

### Basic Map
```dart
LiveTrackingMapWidget(
  session: session,
  points: points,
)
```

### With Callbacks
```dart
LiveTrackingMapWidget(
  session: session,
  points: points,
  onMapCreated: (controller) {
    // Map initialized
  },
)
```

### Display Stats
```dart
TrackingStatsWidget(
  session: session,
  currentLocation: lastLocation,
)
```

---

## 🔄 Offline Sync

### Manual Sync
```dart
await syncManager.syncNow();
```

### Check Status
```dart
syncManager.isOnline.value           // bool
syncManager.isSyncing.value          // bool
syncManager.pendingItems.value       // int
```

### Listen to Connectivity
```dart
syncManager.isOnline.listen((online) {
  print('Online: $online');
});
```

---

## 🔐 Authentication

### Set Token
```dart
LiveTrackingPlugin.setAuthToken('your-token');
```

### Custom Header
```dart
LiveTrackingPlugin.apiService.addHeader('X-Key', 'value');
```

### Clear Token
```dart
LiveTrackingPlugin.clearAuthToken();
```

---

## 📊 Database Operations

### Get All Sessions
```dart
final sessions = await trackingService.getAllSessions();
```

### Delete Session
```dart
await trackingService.deleteSession(sessionId);
```

### Get Unsynced Data
```dart
final data = await trackingService.getUnsyncedData();
print('Sessions: ${data['sessions'].length}');
print('Points: ${data['points'].length}');
```

---

## ❌ Error Handling

### Setup Error Callback
```dart
trackingService.onError = (error) {
  print('Error: $error');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(error)),
  );
};
```

### Try-Catch
```dart
try {
  await trackingService.startTracking(title: 'Activity');
} catch (e) {
  print('Error: $e');
}
```

---

## 🔔 Callbacks

### Location Update
```dart
trackingService.onLocationUpdate = (point) {
  print('Lat: ${point.latitude}');
};
```

### Tracking Started
```dart
trackingService.onTrackingStarted = () {
  print('Tracking started!');
};
```

### Tracking Stopped
```dart
trackingService.onTrackingStopped = () {
  print('Tracking stopped!');
};
```

---

## 📱 Platform Specifics

### iOS Setup
Add to `Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location for tracking</string>
```

### Android Setup
Uses automatic permission handling via geolocator.

---

## 🎨 Customization

### Custom Polyline Color
```dart
LiveTrackingMapWidget(
  session: session,
  points: points,
  polylineColor: Colors.red,
)
```

### Custom Markers
```dart
LiveTrackingMapWidget(
  session: session,
  points: points,
  startMarkerIcon: customIcon,
  endMarkerIcon: customIcon,
)
```

---

## 💾 Database

All data is automatically stored in SQLite locally. No manual setup needed.

### Accessed via
```dart
LiveTrackingPlugin.dbHelper
```

---

## 🚨 Troubleshooting

### Location not updating?
- Check permissions granted
- Verify location services enabled
- Check GPS accuracy threshold
- Try different accuracy level

### Data not syncing?
- Check internet connection
- Verify API endpoint
- Check auth token
- Review backend logs

### High battery drain?
- Use lower accuracy
- Increase update interval
- Reduce tracking time
- Check for stuck GPS

---

## 📚 Documentation Links

- **Full README:** See README.md
- **API Reference:** See API_DOCUMENTATION.md
- **Publishing:** See PUB_DEV_PUBLISHING_GUIDE.md
- **Examples:** See example/ folder

---

## 🎯 Typical Flow

```dart
// 1. Initialize
await LiveTrackingPlugin.initialize(apiBaseUrl: 'https://api.com');

// 2. Setup callbacks
trackingService.onError = (err) => print(err);

// 3. Start tracking
final sessionId = await trackingService.startTracking(
  title: 'Activity',
);

// 4. Display on map
LiveTrackingMapWidget(
  session: session,
  points: trackingService.currentPoints,
);

// 5. Stop tracking
await trackingService.stopTracking();

// 6. Sync
await syncManager.syncNow();

// 7. Cleanup
await LiveTrackingPlugin.dispose();
```

---

## ⚡ Performance Tips

1. Use appropriate accuracy level
2. Increase update interval for slower movement
3. Use minAccuracyThreshold to filter bad data
4. Batch database operations
5. Monitor device resources

---

## 🆘 Getting Help

1. Check the example app
2. Read API_DOCUMENTATION.md
3. Check README.md troubleshooting
4. Create GitHub issue
5. Review backend API requirements

---

## 📞 API Endpoints Template

Your backend should implement:

```
POST   /api/v1/tracking/sessions
POST   /api/v1/tracking/points/batch
GET    /api/v1/tracking/sessions
GET    /api/v1/tracking/sessions/{id}
GET    /api/v1/tracking/sessions/{id}/points
PUT    /api/v1/tracking/sessions/{id}
DELETE /api/v1/tracking/sessions/{id}
GET    /api/v1/health
```

---

## 🎓 Learning Path

1. **Start:** Quick start section above
2. **Basic:** Use example app as reference
3. **Advanced:** Read API_DOCUMENTATION.md
4. **Customize:** Explore callback options
5. **Deploy:** Follow PUB_DEV_PUBLISHING_GUIDE.md

---

## ✅ Checklist Before Going Live

- [ ] API endpoints implemented
- [ ] Tested on iOS device
- [ ] Tested on Android device
- [ ] Offline sync working
- [ ] Error handling implemented
- [ ] Permissions requested properly
- [ ] Backend authentication working
- [ ] Map displaying correctly
- [ ] Stats calculating correctly
- [ ] Battery optimization checked

---

## 📖 Quick Links

| Resource | Location |
|----------|----------|
| Installation | README.md - Installation |
| Usage | README.md - Usage Guide |
| API Reference | API_DOCUMENTATION.md |
| Examples | example/ folder |
| Publishing | PUB_DEV_PUBLISHING_GUIDE.md |
| Contributing | CONTRIBUTING.md |

---

## 🚀 You're Ready!

With this quick reference, you should be able to get started in minutes. For detailed information, refer to the full documentation.

**Happy tracking! 📍**
