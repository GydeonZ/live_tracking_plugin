// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackingSession _$TrackingSessionFromJson(Map<String, dynamic> json) =>
    TrackingSession(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'idle',
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
      averageSpeed: (json['averageSpeed'] as num?)?.toDouble(),
      pointCount: (json['pointCount'] as num?)?.toInt() ?? 0,
      minAccuracy: (json['minAccuracy'] as num?)?.toDouble() ?? 20.0,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isSynced: json['isSynced'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TrackingSessionToJson(TrackingSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'status': instance.status,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'durationSeconds': instance.durationSeconds,
      'distanceMeters': instance.distanceMeters,
      'averageSpeed': instance.averageSpeed,
      'pointCount': instance.pointCount,
      'minAccuracy': instance.minAccuracy,
      'metadata': instance.metadata,
      'isSynced': instance.isSynced,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
