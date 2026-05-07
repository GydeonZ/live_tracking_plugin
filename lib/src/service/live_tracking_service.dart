import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';
import 'package:live_tracking_plugin/live_tracking_plugin.dart';

/// Service untuk tracking GPS secara real-time
class LiveTrackingService extends GetxService {
  static const uuid = Uuid();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Reactive variables
  final Rx<TrackingSession?> currentSession = Rx<TrackingSession?>(null);
  final RxList<LocationPoint> currentPoints = <LocationPoint>[].obs;
  final RxBool isTracking = false.obs;
  final Rx<LocationPoint?> lastLocation = Rx<LocationPoint?>(null);
  final RxDouble totalDistance = 0.0.obs;
  final RxInt pointCount = 0.obs;

  // Settings
  final RxInt updateIntervalSeconds = 5.obs; // Default: update setiap 5 detik
  final Rx<GPSAccuracy> gpsAccuracy = GPSAccuracy.high.obs;
  final RxDouble minAccuracyThreshold = 20.0.obs; // Reject points lebih tidak akurat dari ini

  // Stream subscriptions
  StreamSubscription<Position>? _positionStream;

  // Callback functions
  Function(LocationPoint)? onLocationUpdate;
  Function(String)? onError;
  Function()? onTrackingStarted;
  Function()? onTrackingStopped;

  @override
  void onInit() {
    super.onInit();
    _requestLocationPermission();
  }

  /// Request location permission
  Future<bool> _requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
    } catch (e) {
      onError?.call('Permission error: $e');
      return false;
    }
  }

  /// Start new tracking session
  Future<String?> startTracking({
    required String title,
    String? description,
    GPSAccuracy accuracy = GPSAccuracy.high,
    int updateIntervalSeconds = 5,
    double minAccuracyThreshold = 20.0,
  }) async {
    try {
      // Check permission
      final hasPermission = await _requestLocationPermission();
      if (!hasPermission) {
        onError?.call('Location permission not granted');
        return null;
      }

      // Update settings
      gpsAccuracy.value = accuracy;
      this.updateIntervalSeconds.value = updateIntervalSeconds;
      this.minAccuracyThreshold.value = minAccuracyThreshold;

      // Create new session
      final sessionId = uuid.v4();
      final session = TrackingSession(
        id: sessionId,
        title: title,
        description: description,
        status: 'tracking',
        startTime: DateTime.now(),
        pointCount: 0,
        minAccuracy: minAccuracyThreshold,
      );

      // Save to database
      await _dbHelper.insertSession(session);
      currentSession.value = session;
      currentPoints.clear();
      totalDistance.value = 0.0;
      pointCount.value = 0;

      isTracking.value = true;
      _startLocationStream();

      onTrackingStarted?.call();

      return sessionId;
    } catch (e) {
      onError?.call('Error starting tracking: $e');
      return null;
    }
  }

  /// Pause current tracking
  Future<bool> pauseTracking() async {
    try {
      if (currentSession.value == null) return false;

      await _positionStream?.cancel();
      isTracking.value = false;

      // Update session status
      final updated = currentSession.value!.copyWith(status: 'paused');
      await _dbHelper.updateSession(updated);
      currentSession.value = updated;

      return true;
    } catch (e) {
      onError?.call('Error pausing tracking: $e');
      return false;
    }
  }

  /// Resume tracking
  Future<bool> resumeTracking() async {
    try {
      if (currentSession.value == null) return false;

      isTracking.value = true;
      _startLocationStream();

      // Update session status
      final updated = currentSession.value!.copyWith(status: 'tracking');
      await _dbHelper.updateSession(updated);
      currentSession.value = updated;

      return true;
    } catch (e) {
      onError?.call('Error resuming tracking: $e');
      return false;
    }
  }

  /// Stop tracking dan save session
  Future<String?> stopTracking() async {
    try {
      if (currentSession.value == null) return null;

      await _positionStream?.cancel();
      isTracking.value = false;

      final endTime = DateTime.now();
      final duration = endTime.difference(currentSession.value!.startTime);
      final avgSpeed = totalDistance.value > 0 ? totalDistance.value / duration.inSeconds : 0.0;

      // Update session
      final completed = currentSession.value!.copyWith(
        status: 'completed',
        endTime: endTime,
        durationSeconds: duration.inSeconds,
        distanceMeters: totalDistance.value,
        averageSpeed: avgSpeed,
        pointCount: pointCount.value,
      );

      await _dbHelper.updateSession(completed);
      currentSession.value = completed;

      onTrackingStopped?.call();

      return currentSession.value!.id;
    } catch (e) {
      onError?.call('Error stopping tracking: $e');
      return null;
    }
  }

  /// Start location streaming
  void _startLocationStream() {
    final desiredAccuracy = _gpsAccuracyToLocationAccuracy(gpsAccuracy.value);

    debugPrint('Starting location stream with accuracy: $desiredAccuracy');

    try {
      _positionStream =
          Geolocator.getPositionStream(
            locationSettings: LocationSettings(
              accuracy: desiredAccuracy,
              distanceFilter: 5, // Update setiap 5 meter
              // REMOVED timeLimit - ini menyebabkan stream berhenti setiap 5 detik!
              // timeLimit tidak boleh ada di sini
            ),
          ).listen(
            (Position position) {
              debugPrint(
                'Location received: ${position.latitude}, ${position.longitude}, accuracy: ${position.accuracy}',
              );
              _processLocation(position);
            },
            onError: (e) {
              final errorMsg = 'Location stream error: $e';
              debugPrint(errorMsg);
              onError?.call(errorMsg);

              // Try to restart stream setelah delay
              Future.delayed(const Duration(seconds: 2), () {
                if (isTracking.value && currentSession.value != null) {
                  debugPrint('Attempting to restart location stream...');
                  _startLocationStream();
                }
              });
            },
          );
    } catch (e) {
      final errorMsg = 'Error starting location stream: $e';
      debugPrint(errorMsg);
      onError?.call(errorMsg);
    }
  }

  /// Process location update
  Future<void> _processLocation(Position position) async {
    try {
      if (currentSession.value == null) {
        onError?.call('No active tracking session');
        return;
      }

      // Check accuracy threshold
      if (position.accuracy > minAccuracyThreshold.value) {
        debugPrint('Location rejected: accuracy ${position.accuracy} > threshold ${minAccuracyThreshold.value}');
        return; // Skip points dengan akurasi buruk
      }

      // Create location point with fallback timestamp
      final point = LocationPoint(
        id: uuid.v4(),
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        heading: position.heading,
        timestamp: position.timestamp ?? DateTime.now(), // Fallback to current time if null
        sessionId: currentSession.value!.id,
        isSynced: false,
      );

      // Save to database - DON'T return on error, stream must continue!
      try {
        await _dbHelper.insertPoint(point);
      } catch (dbError) {
        debugPrint('⚠️ Database error saving point: $dbError');
        // Don't return - stream continues even if DB has issues
        onError?.call('Database error: $dbError');
      }

      // Update distance jika ada previous point
      if (lastLocation.value != null) {
        try {
          final distance = lastLocation.value!.distanceTo(point);
          totalDistance.value += distance;
          debugPrint('Distance updated: ${totalDistance.value.toStringAsFixed(2)}m');
        } catch (distError) {
          debugPrint('⚠️ Distance calculation error: $distError');
          onError?.call('Distance calculation error: $distError');
        }
      }

      lastLocation.value = point;
      currentPoints.add(point);
      pointCount.value = currentPoints.length;

      debugPrint(
        '✅ Location point added: ${currentPoints.length} points, ${totalDistance.value.toStringAsFixed(2)}m distance',
      );

      // Callback
      onLocationUpdate?.call(point);
    } catch (e) {
      debugPrint('❌ Critical error processing location: $e');
      onError?.call('Error processing location: $e');
      // Don't rethrow - let stream continue
    }
  }

  /// Get LocationAccuracy dari GPSAccuracy enum
  LocationAccuracy _gpsAccuracyToLocationAccuracy(GPSAccuracy accuracy) {
    switch (accuracy) {
      case GPSAccuracy.low:
        return LocationAccuracy.low;
      case GPSAccuracy.medium:
        return LocationAccuracy.medium;
      case GPSAccuracy.high:
        return LocationAccuracy.high;
      case GPSAccuracy.best:
        return LocationAccuracy.best;
    }
  }

  /// Load session points dari database
  Future<List<LocationPoint>> loadSessionPoints(String sessionId) async {
    try {
      return await _dbHelper.getPointsBySession(sessionId);
    } catch (e) {
      onError?.call('Error loading session points: $e');
      return [];
    }
  }

  /// Get all sessions
  Future<List<TrackingSession>> getAllSessions() async {
    try {
      return await _dbHelper.getAllSessions();
    } catch (e) {
      onError?.call('Error getting sessions: $e');
      return [];
    }
  }

  /// Delete session
  Future<bool> deleteSession(String sessionId) async {
    try {
      await _dbHelper.deletePointsBySession(sessionId);
      await _dbHelper.deleteSession(sessionId);
      return true;
    } catch (e) {
      onError?.call('Error deleting session: $e');
      return false;
    }
  }

  /// Get unsync data untuk sync ke server
  Future<Map<String, dynamic>> getUnsyncedData() async {
    try {
      final unsyncedSessions = await _dbHelper.getUnsyncedSessions();
      final unsyncedPoints = await _dbHelper.getUnsyncedPoints();

      return {'sessions': unsyncedSessions, 'points': unsyncedPoints};
    } catch (e) {
      onError?.call('Error getting unsynced data: $e');
      return {'sessions': [], 'points': []};
    }
  }

  /// Mark session as synced
  Future<bool> markSessionAsSynced(String sessionId) async {
    try {
      await _dbHelper.updateSessionSyncStatus(sessionId, true);
      return true;
    } catch (e) {
      onError?.call('Error marking session as synced: $e');
      return false;
    }
  }

  /// Mark point as synced
  Future<bool> markPointAsSynced(String pointId) async {
    try {
      await _dbHelper.updatePointSyncStatus(pointId, true);
      return true;
    } catch (e) {
      onError?.call('Error marking point as synced: $e');
      return false;
    }
  }

  @override
  void onClose() {
    _positionStream?.cancel();
    _dbHelper.close();
    super.onClose();
  }
}
