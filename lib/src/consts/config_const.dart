enum GPSAccuracy {
  lowest, // ~100m
  low, // ~50m
  medium, // ~20m
  high, // ~10m
  best, // ~5m
  bestForNavigation, // ~3m
}

/// GPS Accuracy configuration constants
class GpsAccuracyConst {
  static const double low = 50.0; // ~50m
  static const double medium = 20.0; // ~20m
  static const double high = 10.0; // ~10m
  static const double best = 5.0; // ~5m
}

/// Tracking configuration constants
class TrackingConst {
  static const int defaultUpdateIntervalSeconds = 5;
  static const double defaultMinAccuracyThreshold = 20.0;
  static const int syncIntervalSeconds = 30;
  static const int locationStreamRestartDelaySeconds = 2;
  static const int batchUploadSize = 100;
}

/// API configuration constants
class ApiConst {
  static const int connectionTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
  static const int sendTimeoutSeconds = 30;
}

/// Database configuration constants
class DatabaseConst {
  static const String databaseName = 'live_tracking.db';
  static const int databaseVersion = 1;
  static const String tableTrackingSessions = 'tracking_sessions';
  static const String tableLocationPoints = 'location_points';
}
