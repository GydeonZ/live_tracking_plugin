// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationPoint _$LocationPointFromJson(Map<String, dynamic> json) =>
    LocationPoint(
      id: json['id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      altitude: (json['altitude'] as num).toDouble(),
      speed: (json['speed'] as num).toDouble(),
      heading: (json['heading'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      sessionId: json['sessionId'] as String,
      isSynced: json['isSynced'] as bool? ?? false,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LocationPointToJson(LocationPoint instance) =>
    <String, dynamic>{
      'id': instance.id,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'accuracy': instance.accuracy,
      'altitude': instance.altitude,
      'speed': instance.speed,
      'heading': instance.heading,
      'timestamp': instance.timestamp.toIso8601String(),
      'sessionId': instance.sessionId,
      'isSynced': instance.isSynced,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
