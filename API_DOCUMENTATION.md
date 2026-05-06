# Live Tracking Plugin - API Documentation

## Table of Contents

1. [LiveTrackingPlugin](#livetrackingplugin)
2. [LiveTrackingService](#livetrackerservice)
3. [LocationPoint](#locationpoint)
4. [TrackingSession](#trackingsession)
5. [OfflineSyncManager](#offlinesyncmanager)
6. [LiveTrackingApiService](#livetrackingapiservice)
7. [Widgets](#widgets)
8. [Enums](#enums)

---

## LiveTrackingPlugin

Main entry point for the Live Tracking Plugin.

### Static Methods

#### `initialize()`

Initializes the plugin with the necessary configuration.

```dart
static Future<void> initialize({
  required String apiBaseUrl,
  String? authToken,
})
```

**Parameters:**
- `apiBaseUrl` - Base URL of your backend API
- `authToken` - Optional authentication token

**Example:**
```dart
await LiveTrackingPlugin.initialize(
  apiBaseUrl: 'https://api.example.com',
  authToken: 'your-token',
);
```

#### `setAuthToken()`

Updates the authentication token after initialization.

```dart
static void setAuthToken(String token)
```

#### `clearAuthToken()`

Clears the current authentication token.

```dart
static void clearAuthToken()
```

#### `dispose()`

Cleans up resources and closes the plugin.

```dart
static Future<void> dispose()
```

### Properties

#### `trackingService`

Get the tracking service instance.

```dart
static LiveTrackingService get trackingService
```

#### `syncManager`

Get the offline sync manager instance.

```dart
static OfflineSyncManager get syncManager
```

#### `apiService`

Get the API service instance.

```dart
static LiveTrackingApiService get apiService
```

#### `dbHelper`

Get the database helper instance.

```dart
static DatabaseHelper get dbHelper
```

#### `isInitialized`

Check if the plugin is initialized.

```dart
static bool get isInitialized
```

---

## LiveTrackingService

Manages GPS tracking and location recording.

### Properties (Reactive with GetX)

- `currentSession: Rx<TrackingSession?>` - Current active session
- `currentPoints: RxList<LocationPoint>` - All points in current session
- `isTracking: RxBool` - Whether tracking is active
- `lastLocation: Rx<LocationPoint?>` - Most recent location
- `totalDistance: RxDouble` - Total distance traveled (in meters)
- `pointCount: RxInt` - Number of points recorded
- `updateIntervalSeconds: RxInt` - Update interval (default: 5)
- `gpsAccuracy: Rx<GPSAccuracy>` - Current GPS accuracy setting
- `minAccuracyThreshold: RxDouble` - Minimum acceptable accuracy

### Callbacks

```dart
Function(LocationPoint)? onLocationUpdate;
Function(String)? onError;
Function()? onTrackingStarted;
Function()? onTrackingStopped;
```

### Methods

#### `startTracking()`

Start a new tracking session.

```dart
Future<String?> startTracking({
  required String title,
  String? description,
  GPSAccuracy accuracy = GPSAccuracy.high,
  int updateIntervalSeconds = 5,
  double minAccuracyThreshold = 20.0,
})
```

**Returns:** Session ID if successful, null otherwise

**Example:**
```dart
final sessionId = await trackingService.startTracking(
  title: 'My Run',
  description: 'Morning run',
  accuracy: GPSAccuracy.high,
);
```

#### `pauseTracking()`

Pause the current tracking session.

```dart
Future<bool> pauseTracking()
```

**Returns:** True if successful

#### `resumeTracking()`

Resume a paused tracking session.

```dart
Future<bool> resumeTracking()
```

**Returns:** True if successful

#### `stopTracking()`

Stop the current tracking session.

```dart
Future<String?> stopTracking()
```

**Returns:** Session ID if successful

#### `loadSessionPoints()`

Load all location points for a session.

```dart
Future<List<LocationPoint>> loadSessionPoints(String sessionId)
```

**Returns:** List of LocationPoint objects

#### `getAllSessions()`

Get all tracked sessions.

```dart
Future<List<TrackingSession>> getAllSessions()
```

**Returns:** List of TrackingSession objects

#### `deleteSession()`

Delete a tracking session and its data.

```dart
Future<bool> deleteSession(String sessionId)
```

**Returns:** True if successful

#### `getUnsyncedData()`

Get data that hasn't been synced to the server yet.

```dart
Future<Map<String, dynamic>> getUnsyncedData()
```

**Returns:** Map with 'sessions' and 'points' keys

#### `markSessionAsSynced()`

Mark a session as synced.

```dart
Future<bool> markSessionAsSynced(String sessionId)
```

#### `markPointAsSynced()`

Mark a location point as synced.

```dart
Future<bool> markPointAsSynced(String pointId)
```

---

## LocationPoint

Represents a single GPS location point.

### Properties

- `id: String` - Unique identifier
- `latitude: double` - Latitude coordinate
- `longitude: double` - Longitude coordinate
- `accuracy: double` - Accuracy in meters
- `altitude: double` - Altitude in meters
- `speed: double` - Speed in m/s
- `heading: double` - Direction in degrees (0-360)
- `timestamp: DateTime` - When location was recorded
- `sessionId: String` - Associated session ID
- `isSynced: bool` - Whether synced to server
- `updatedAt: DateTime` - Last update time

### Methods

#### `distanceTo()`

Calculate distance to another location point.

```dart
double distanceTo(LocationPoint other)
```

**Returns:** Distance in meters

**Example:**
```dart
final distance = point1.distanceTo(point2);
print('Distance: ${distance}m');
```

#### `copyWith()`

Create a modified copy of this point.

```dart
LocationPoint copyWith({
  String? id,
  double? latitude,
  double? longitude,
  // ... other properties
})
```

#### `toJson()` / `fromJson()`

JSON serialization methods.

```dart
Map<String, dynamic> toJson()
factory LocationPoint.fromJson(Map<String, dynamic> json)
```

---

## TrackingSession

Represents a tracking session.

### Properties

- `id: String` - Unique session identifier
- `title: String` - Session title
- `description: String?` - Optional description
- `status: String` - Session status ('idle', 'tracking', 'paused', 'completed')
- `startTime: DateTime` - When session started
- `endTime: DateTime?` - When session ended
- `durationSeconds: int?` - Total duration in seconds
- `distanceMeters: double?` - Total distance in meters
- `averageSpeed: double?` - Average speed in m/s
- `pointCount: int` - Number of GPS points
- `minAccuracy: double` - Minimum accuracy threshold
- `metadata: Map?` - Custom metadata
- `isSynced: bool` - Whether synced to server
- `createdAt: DateTime` - Creation time
- `updatedAt: DateTime` - Last update time

### Methods

#### `getDuration()`

Get the duration of this session.

```dart
Duration getDuration()
```

**Returns:** Duration object

**Example:**
```dart
final duration = session.getDuration();
print('Session lasted ${duration.inMinutes} minutes');
```

#### `copyWith()`

Create a modified copy.

```dart
TrackingSession copyWith({
  String? id,
  String? title,
  // ... other properties
})
```

#### `toJson()` / `fromJson()`

JSON serialization methods.

---

## OfflineSyncManager

Manages offline/online synchronization.

### Properties (Reactive)

- `isOnline: RxBool` - Current connectivity status
- `isSyncing: RxBool` - Whether currently syncing
- `pendingItems: RxInt` - Number of items pending sync

### Methods

#### `syncNow()`

Manually trigger synchronization.

```dart
Future<void> syncNow()
```

#### `getSyncStatus()`

Get detailed sync status.

```dart
Future<Map<String, dynamic>> getSyncStatus()
```

**Returns:** Map with sync information

**Example:**
```dart
final status = await syncManager.getSyncStatus();
print('Pending: ${status['totalPending']}');
print('Online: ${status['isOnline']}');
```

---

## LiveTrackingApiService

Handles backend API communication.

### Constructor

```dart
LiveTrackingApiService({
  required String baseUrl,
  Dio? dioClient,
})
```

### Methods

#### `uploadSession()`

Upload a tracking session to the server.

```dart
Future<bool> uploadSession(TrackingSession session)
```

#### `uploadLocationPoints()`

Upload batch of location points.

```dart
Future<bool> uploadLocationPoints(List<LocationPoint> points)
```

#### `getSessions()`

Fetch sessions from server.

```dart
Future<List<TrackingSession>> getSessions({
  int limit = 50,
  int offset = 0,
})
```

#### `getSession()`

Get a specific session from server.

```dart
Future<TrackingSession?> getSession(String sessionId)
```

#### `getSessionPoints()`

Get location points for a session from server.

```dart
Future<List<LocationPoint>> getSessionPoints(String sessionId)
```

#### `deleteSession()`

Delete a session on the server.

```dart
Future<bool> deleteSession(String sessionId)
```

#### `updateSession()`

Update a session on the server.

```dart
Future<bool> updateSession(TrackingSession session)
```

#### `checkConnectivity()`

Check if server is reachable.

```dart
Future<bool> checkConnectivity()
```

#### `setAuthToken()`

Set or update authentication token.

```dart
void setAuthToken(String token)
```

#### `clearAuthToken()`

Clear authentication token.

```dart
void clearAuthToken()
```

#### `addHeader()`

Add custom HTTP header.

```dart
void addHeader(String key, String value)
```

---

## Widgets

### LiveTrackingMapWidget

Displays tracking data on a Google Map.

```dart
LiveTrackingMapWidget(
  session: TrackingSession,
  points: List<LocationPoint>,
  currentLocation: LocationPoint?,
  onMapCreated: Function(GoogleMapController)?,
  polylineColor: Color = Colors.blue,
  startMarkerIcon: BitmapDescriptor?,
  endMarkerIcon: BitmapDescriptor?,
  currentMarkerIcon: BitmapDescriptor?,
  showPolyline: bool = true,
  showMarkers: bool = true,
  initialZoom: double = 15.0,
)
```

**Example:**
```dart
LiveTrackingMapWidget(
  session: session,
  points: points,
  currentLocation: trackingService.lastLocation.value,
  polylineColor: Colors.blue,
)
```

### TrackingStatsWidget

Displays tracking statistics summary.

```dart
TrackingStatsWidget(
  session: TrackingSession,
  currentLocation: LocationPoint?,
)
```

**Example:**
```dart
TrackingStatsWidget(
  session: session,
  currentLocation: lastLocation,
)
```

---

## Enums

### GPSAccuracy

GPS accuracy levels:

```dart
enum GPSAccuracy {
  low,      // ~50m, best battery life
  medium,   // ~20m, balanced
  high,     // ~10m, good precision
  best,     // ~5m, highest precision
}
```

### TrackingStatus

Tracking session status:

```dart
enum TrackingStatus {
  idle,       // Not tracking
  tracking,   // Currently tracking
  paused,     // Tracking paused
  completed,  // Tracking finished
  error,      // Error occurred
}
```

---

## Examples

### Complete Tracking Flow

```dart
// Initialize
await LiveTrackingPlugin.initialize(
  apiBaseUrl: 'https://api.example.com',
);

final trackingService = LiveTrackingPlugin.trackingService;
final syncManager = LiveTrackingPlugin.syncManager;

// Setup callbacks
trackingService.onLocationUpdate = (point) {
  print('Location: ${point.latitude}, ${point.longitude}');
};

trackingService.onError = (error) {
  print('Error: $error');
};

// Start tracking
final sessionId = await trackingService.startTracking(
  title: 'My Activity',
  accuracy: GPSAccuracy.high,
);

// Wait and observe
await Future.delayed(Duration(seconds: 60));

// Get stats
print('Distance: ${trackingService.totalDistance.value}m');
print('Points: ${trackingService.pointCount.value}');

// Stop tracking
await trackingService.stopTracking();

// Wait for sync
await syncManager.syncNow();

// Cleanup
await LiveTrackingPlugin.dispose();
```

### Reactive UI Update

```dart
class TrackingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final trackingService = LiveTrackingPlugin.trackingService;

    return Column(
      children: [
        Obx(() => Text('Status: ${trackingService.isTracking.value}')),
        Obx(() => Text('Distance: ${trackingService.totalDistance.value}m')),
        Obx(() => Text('Points: ${trackingService.pointCount.value}')),
      ],
    );
  }
}
```

---

## Error Handling

All methods may throw exceptions. Always wrap in try-catch:

```dart
try {
  await trackingService.startTracking(title: 'My Activity');
} catch (e) {
  print('Error: $e');
}
```

---

## Thread Safety

- All location updates happen on the main thread
- Database operations are automatically handled
- API calls use Dio's default thread pool

---

## Memory Management

- Always call `LiveTrackingPlugin.dispose()` when done
- Use Obx listeners carefully to avoid memory leaks
- Remove callbacks when no longer needed

---

For more information, see the [README](README.md) and [Examples](example/).
