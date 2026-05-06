import 'package:json_annotation/json_annotation.dart';

part 'tracking_session.g.dart';

/// Status tracking session
enum TrackingStatus { idle, tracking, paused, completed, error }

/// Model untuk sesi tracking
@JsonSerializable()
class TrackingSession {
  /// ID unik untuk sesi
  final String id;

  /// Nama/judul sesi
  final String title;

  /// Deskripsi sesi
  final String? description;

  /// Status tracking
  @JsonKey(defaultValue: 'idle')
  final String status;

  /// Timestamp mulai tracking
  final DateTime startTime;

  /// Timestamp selesai tracking
  final DateTime? endTime;

  /// Total durasi dalam detik
  final int? durationSeconds;

  /// Total jarak dalam meter
  final double? distanceMeters;

  /// Kecepatan rata-rata dalam m/s
  final double? averageSpeed;

  /// Jumlah data point
  final int pointCount;

  /// Akurasi minimal yang dipakai
  final double minAccuracy;

  /// Metadata custom
  final Map<String, dynamic>? metadata;

  /// Apakah sesi sudah disinkronisasi
  final bool isSynced;

  /// Timestamp dibuat
  final DateTime createdAt;

  /// Timestamp diupdate terakhir
  final DateTime updatedAt;

  TrackingSession({
    required this.id,
    required this.title,
    this.description,
    this.status = 'idle',
    required this.startTime,
    this.endTime,
    this.durationSeconds,
    this.distanceMeters,
    this.averageSpeed,
    this.pointCount = 0,
    this.minAccuracy = 20.0,
    this.metadata,
    this.isSynced = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Copy with method
  TrackingSession copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    double? distanceMeters,
    double? averageSpeed,
    int? pointCount,
    double? minAccuracy,
    Map<String, dynamic>? metadata,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrackingSession(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      averageSpeed: averageSpeed ?? this.averageSpeed,
      pointCount: pointCount ?? this.pointCount,
      minAccuracy: minAccuracy ?? this.minAccuracy,
      metadata: metadata ?? this.metadata,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory TrackingSession.fromJson(Map<String, dynamic> json) => _$TrackingSessionFromJson(json);

  Map<String, dynamic> toJson() => _$TrackingSessionToJson(this);

  /// Hitung durasi dari sekarang
  Duration getDuration() {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }
}
