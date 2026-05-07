import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../entities/location_point.dart';
import '../entities/tracking_session.dart';

class DatabaseHelper {
  static const String _databaseName = 'live_tracking.db';
  static const int _databaseVersion = 1;

  static const String tableTrackingSessions = 'tracking_sessions';
  static const String tableLocationPoints = 'location_points';

  // Tracking Sessions table columns
  static const String columnSessionId = 'id';
  static const String columnSessionTitle = 'title';
  static const String columnSessionDescription = 'description';
  static const String columnSessionStatus = 'status';
  static const String columnSessionStartTime = 'start_time';
  static const String columnSessionEndTime = 'end_time';
  static const String columnSessionDuration = 'duration_seconds';
  static const String columnSessionDistance = 'distance_meters';
  static const String columnSessionAvgSpeed = 'average_speed';
  static const String columnSessionPointCount = 'point_count';
  static const String columnSessionMinAccuracy = 'min_accuracy';
  static const String columnSessionMetadata = 'metadata';
  static const String columnSessionIsSynced = 'is_synced';
  static const String columnSessionCreatedAt = 'created_at';
  static const String columnSessionUpdatedAt = 'updated_at';

  // Location Points table columns
  static const String columnPointId = 'id';
  static const String columnPointLatitude = 'latitude';
  static const String columnPointLongitude = 'longitude';
  static const String columnPointAccuracy = 'accuracy';
  static const String columnPointAltitude = 'altitude';
  static const String columnPointSpeed = 'speed';
  static const String columnPointHeading = 'heading';
  static const String columnPointTimestamp = 'timestamp';
  static const String columnPointSessionId = 'session_id';
  static const String columnPointIsSynced = 'is_synced';
  static const String columnPointUpdatedAt = 'updated_at';

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create tracking sessions table
    await db.execute('''
      CREATE TABLE $tableTrackingSessions (
        $columnSessionId TEXT PRIMARY KEY,
        $columnSessionTitle TEXT NOT NULL,
        $columnSessionDescription TEXT,
        $columnSessionStatus TEXT NOT NULL,
        $columnSessionStartTime TEXT NOT NULL,
        $columnSessionEndTime TEXT,
        $columnSessionDuration INTEGER,
        $columnSessionDistance REAL,
        $columnSessionAvgSpeed REAL,
        $columnSessionPointCount INTEGER DEFAULT 0,
        $columnSessionMinAccuracy REAL DEFAULT 20.0,
        $columnSessionMetadata TEXT,
        $columnSessionIsSynced INTEGER DEFAULT 0,
        $columnSessionCreatedAt TEXT NOT NULL,
        $columnSessionUpdatedAt TEXT NOT NULL
      )
    ''');

    // Create location points table
    await db.execute('''
      CREATE TABLE $tableLocationPoints (
        $columnPointId TEXT PRIMARY KEY,
        $columnPointLatitude REAL NOT NULL,
        $columnPointLongitude REAL NOT NULL,
        $columnPointAccuracy REAL NOT NULL,
        $columnPointAltitude REAL NOT NULL,
        $columnPointSpeed REAL NOT NULL,
        $columnPointHeading REAL NOT NULL,
        $columnPointTimestamp TEXT NOT NULL,
        $columnPointSessionId TEXT NOT NULL,
        $columnPointIsSynced INTEGER DEFAULT 0,
        $columnPointUpdatedAt TEXT NOT NULL,
        FOREIGN KEY ($columnPointSessionId) REFERENCES $tableTrackingSessions($columnSessionId) ON DELETE CASCADE
      )
    ''');

    // Create index untuk query lebih cepat
    await db.execute('CREATE INDEX idx_point_session ON $tableLocationPoints($columnPointSessionId)');
    await db.execute('CREATE INDEX idx_point_timestamp ON $tableLocationPoints($columnPointTimestamp)');
    await db.execute('CREATE INDEX idx_session_status ON $tableTrackingSessions($columnSessionStatus)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migration logic
  }

  // ===== Tracking Session Methods =====

  Future<String> insertSession(TrackingSession session) async {
    final db = await database;
    await db.insert(
      tableTrackingSessions,
      _trackingSessionToMap(session),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return session.id;
  }

  Future<TrackingSession?> getSession(String sessionId) async {
    final db = await database;
    final maps = await db.query(tableTrackingSessions, where: '$columnSessionId = ?', whereArgs: [sessionId]);

    if (maps.isEmpty) return null;
    return _mapToTrackingSession(maps.first);
  }

  Future<List<TrackingSession>> getAllSessions() async {
    final db = await database;
    final maps = await db.query(tableTrackingSessions, orderBy: '$columnSessionCreatedAt DESC');
    return maps.map(_mapToTrackingSession).toList();
  }

  Future<List<TrackingSession>> getSessionsByStatus(String status) async {
    final db = await database;
    final maps = await db.query(
      tableTrackingSessions,
      where: '$columnSessionStatus = ?',
      whereArgs: [status],
      orderBy: '$columnSessionCreatedAt DESC',
    );
    return maps.map(_mapToTrackingSession).toList();
  }

  Future<List<TrackingSession>> getUnsyncedSessions() async {
    final db = await database;
    final maps = await db.query(tableTrackingSessions, where: '$columnSessionIsSynced = ?', whereArgs: [0]);
    return maps.map(_mapToTrackingSession).toList();
  }

  Future<int> updateSession(TrackingSession session) async {
    final db = await database;
    return await db.update(
      tableTrackingSessions,
      _trackingSessionToMap(session),
      where: '$columnSessionId = ?',
      whereArgs: [session.id],
    );
  }

  Future<int> deleteSession(String sessionId) async {
    final db = await database;
    return await db.delete(tableTrackingSessions, where: '$columnSessionId = ?', whereArgs: [sessionId]);
  }

  // ===== Location Point Methods =====

  Future<String> insertPoint(LocationPoint point) async {
    try {
      final db = await database;

      // Convert to map with error checking
      final pointMap = _locationPointToMap(point);
      if (pointMap.isEmpty) {
        throw Exception('Failed to convert location point to map');
      }

      // Insert with retry logic
      int retries = 3;
      while (retries > 0) {
        try {
          await db.insert(tableLocationPoints, pointMap, conflictAlgorithm: ConflictAlgorithm.replace);
          debugPrint('Location point inserted successfully: ${point.id}');
          return point.id;
        } catch (e) {
          retries--;
          if (retries > 0) {
            debugPrint('Retry insert point (${4 - retries}/3): $e');
            await Future.delayed(const Duration(milliseconds: 100));
          } else {
            throw Exception('Failed to insert point after 3 retries: $e');
          }
        }
      }

      return point.id;
    } catch (e) {
      debugPrint('Error inserting location point: $e');
      rethrow;
    }
  }

  Future<int> insertPoints(List<LocationPoint> points) async {
    final db = await database;
    int count = 0;

    final batch = db.batch();
    for (final point in points) {
      batch.insert(tableLocationPoints, _locationPointToMap(point), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    final results = await batch.commit();
    count = results.length;

    return count;
  }

  Future<LocationPoint?> getPoint(String pointId) async {
    final db = await database;
    final maps = await db.query(tableLocationPoints, where: '$columnPointId = ?', whereArgs: [pointId]);

    if (maps.isEmpty) return null;
    return _mapToLocationPoint(maps.first);
  }

  Future<List<LocationPoint>> getPointsBySession(String sessionId) async {
    final db = await database;
    final maps = await db.query(
      tableLocationPoints,
      where: '$columnPointSessionId = ?',
      whereArgs: [sessionId],
      orderBy: '$columnPointTimestamp ASC',
    );
    return maps.map(_mapToLocationPoint).toList();
  }

  Future<List<LocationPoint>> getUnsyncedPoints() async {
    final db = await database;
    final maps = await db.query(tableLocationPoints, where: '$columnPointIsSynced = ?', whereArgs: [0]);
    return maps.map(_mapToLocationPoint).toList();
  }

  Future<List<LocationPoint>> getUnsyncedPointsBySession(String sessionId) async {
    final db = await database;
    final maps = await db.query(
      tableLocationPoints,
      where: '$columnPointSessionId = ? AND $columnPointIsSynced = ?',
      whereArgs: [sessionId, 0],
      orderBy: '$columnPointTimestamp ASC',
    );
    return maps.map(_mapToLocationPoint).toList();
  }

  Future<int> deletePointsBySession(String sessionId) async {
    final db = await database;
    return await db.delete(tableLocationPoints, where: '$columnPointSessionId = ?', whereArgs: [sessionId]);
  }

  Future<int> updatePointSyncStatus(String pointId, bool isSynced) async {
    final db = await database;
    return await db.update(
      tableLocationPoints,
      {columnPointIsSynced: isSynced ? 1 : 0, columnPointUpdatedAt: DateTime.now().toIso8601String()},
      where: '$columnPointId = ?',
      whereArgs: [pointId],
    );
  }

  Future<int> updateSessionSyncStatus(String sessionId, bool isSynced) async {
    final db = await database;
    return await db.update(
      tableTrackingSessions,
      {columnSessionIsSynced: isSynced ? 1 : 0, columnSessionUpdatedAt: DateTime.now().toIso8601String()},
      where: '$columnSessionId = ?',
      whereArgs: [sessionId],
    );
  }

  // ===== Helper Methods =====

  Map<String, dynamic> _trackingSessionToMap(TrackingSession session) {
    return {
      columnSessionId: session.id,
      columnSessionTitle: session.title,
      columnSessionDescription: session.description,
      columnSessionStatus: session.status,
      columnSessionStartTime: session.startTime.toIso8601String(),
      columnSessionEndTime: session.endTime?.toIso8601String(),
      columnSessionDuration: session.durationSeconds,
      columnSessionDistance: session.distanceMeters,
      columnSessionAvgSpeed: session.averageSpeed,
      columnSessionPointCount: session.pointCount,
      columnSessionMinAccuracy: session.minAccuracy,
      columnSessionMetadata: session.metadata != null ? _jsonEncode(session.metadata!) : null,
      columnSessionIsSynced: session.isSynced ? 1 : 0,
      columnSessionCreatedAt: session.createdAt.toIso8601String(),
      columnSessionUpdatedAt: session.updatedAt.toIso8601String(),
    };
  }

  TrackingSession _mapToTrackingSession(Map<String, dynamic> map) {
    return TrackingSession(
      id: map[columnSessionId] as String,
      title: map[columnSessionTitle] as String,
      description: map[columnSessionDescription] as String?,
      status: map[columnSessionStatus] as String? ?? 'idle',
      startTime: DateTime.parse(map[columnSessionStartTime] as String),
      endTime: map[columnSessionEndTime] != null ? DateTime.parse(map[columnSessionEndTime] as String) : null,
      durationSeconds: map[columnSessionDuration] as int?,
      distanceMeters: map[columnSessionDistance] as double?,
      averageSpeed: map[columnSessionAvgSpeed] as double?,
      pointCount: map[columnSessionPointCount] as int? ?? 0,
      minAccuracy: map[columnSessionMinAccuracy] as double? ?? 20.0,
      metadata: map[columnSessionMetadata] != null ? _jsonDecode(map[columnSessionMetadata] as String) : null,
      isSynced: (map[columnSessionIsSynced] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map[columnSessionCreatedAt] as String),
      updatedAt: DateTime.parse(map[columnSessionUpdatedAt] as String),
    );
  }

  Map<String, dynamic> _locationPointToMap(LocationPoint point) {
    return {
      columnPointId: point.id,
      columnPointLatitude: point.latitude,
      columnPointLongitude: point.longitude,
      columnPointAccuracy: point.accuracy,
      columnPointAltitude: point.altitude,
      columnPointSpeed: point.speed,
      columnPointHeading: point.heading,
      columnPointTimestamp: point.timestamp.toIso8601String(),
      columnPointSessionId: point.sessionId,
      columnPointIsSynced: point.isSynced ? 1 : 0,
      columnPointUpdatedAt: point.updatedAt.toIso8601String(),
    };
  }

  LocationPoint _mapToLocationPoint(Map<String, dynamic> map) {
    return LocationPoint(
      id: map[columnPointId] as String,
      latitude: map[columnPointLatitude] as double,
      longitude: map[columnPointLongitude] as double,
      accuracy: map[columnPointAccuracy] as double,
      altitude: map[columnPointAltitude] as double,
      speed: map[columnPointSpeed] as double,
      heading: map[columnPointHeading] as double,
      timestamp: DateTime.parse(map[columnPointTimestamp] as String),
      sessionId: map[columnPointSessionId] as String,
      isSynced: (map[columnPointIsSynced] as int? ?? 0) == 1,
      updatedAt: DateTime.parse(map[columnPointUpdatedAt] as String),
    );
  }

  String _jsonEncode(Map<String, dynamic> map) {
    // Simple JSON encoding
    return map.toString();
  }

  Map<String, dynamic> _jsonDecode(String jsonString) {
    // Simple JSON decoding
    try {
      return jsonString as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
