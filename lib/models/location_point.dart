import 'dart:math';
import 'package:json_annotation/json_annotation.dart';

part 'location_point.g.dart';

/// Model untuk menyimpan titik lokasi GPS
@JsonSerializable()
class LocationPoint {
  /// ID unik untuk titik lokasi
  final String id;

  /// Latitude
  final double latitude;

  /// Longitude
  final double longitude;

  /// Akurasi dalam meter
  final double accuracy;

  /// Ketinggian (altitude) dalam meter
  final double altitude;

  /// Kecepatan dalam m/s
  final double speed;

  /// Heading/arah dalam derajat (0-360)
  final double heading;

  /// Timestamp ketika lokasi diambil
  final DateTime timestamp;

  /// ID sesi tracking
  final String sessionId;

  /// Apakah data sudah disinkronisasi ke server
  final bool isSynced;

  /// Timestamp data diupdate terakhir
  final DateTime updatedAt;

  LocationPoint({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.altitude,
    required this.speed,
    required this.heading,
    required this.timestamp,
    required this.sessionId,
    this.isSynced = false,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  /// Copy with method untuk update field tertentu
  LocationPoint copyWith({
    String? id,
    double? latitude,
    double? longitude,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    DateTime? timestamp,
    String? sessionId,
    bool? isSynced,
    DateTime? updatedAt,
  }) {
    return LocationPoint(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      timestamp: timestamp ?? this.timestamp,
      sessionId: sessionId ?? this.sessionId,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory LocationPoint.fromJson(Map<String, dynamic> json) => _$LocationPointFromJson(json);

  Map<String, dynamic> toJson() => _$LocationPointToJson(this);

  /// Hitung jarak dari titik lain (dalam meter) menggunakan Haversine formula
  double distanceTo(LocationPoint other) {
    const earthRadiusMeters = 6371000.0;

    final dLat = _toRadian(other.latitude - latitude);
    final dLon = _toRadian(other.longitude - longitude);

    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_toRadian(latitude)) * cos(_toRadian(other.latitude)) * sin(dLon / 2) * sin(dLon / 2));

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusMeters * c;
  }

  static double _toRadian(double degree) {
    return degree * (3.14159265359 / 180.0);
  }
}
