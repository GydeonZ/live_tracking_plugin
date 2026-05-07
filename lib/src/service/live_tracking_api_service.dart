import 'package:dio/dio.dart';
import '../entities/location_point.dart';
import '../entities/tracking_session.dart';

/// API service untuk sinkronisasi data ke backend
class LiveTrackingApiService {
  final Dio dio;
  final String baseUrl;
  String? endpointSessions;
  String? endpointPoints;

  LiveTrackingApiService({required this.baseUrl, Dio? dioClient}) : dio = dioClient ?? Dio() {
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 30);
  }

  /// Upload tracking session ke server
  Future<bool> uploadSession(TrackingSession session) async {
    try {
      final response = await dio.post(endpointSessions ?? '/api/v1/tracking/sessions', data: session.toJson());

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      print('Error uploading session: ${e.message}');
      return false;
    }
  }

  /// Upload batch location points ke server
  Future<bool> uploadLocationPoints(List<LocationPoint> points) async {
    try {
      if (points.isEmpty) return true;

      final data = points.map((p) => p.toJson()).toList();
      final response = await dio.post(endpointPoints ?? '/api/v1/tracking/points/batch', data: {'points': data});

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      print('Error uploading points: ${e.message}');
      return false;
    }
  }

  /// Get all sessions dari server
  Future<List<TrackingSession>> getSessions({int limit = 50, int offset = 0}) async {
    try {
      final response = await dio.get(
        endpointSessions ?? '/api/v1/tracking/sessions',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final sessions = (data['data'] as List).map((s) => TrackingSession.fromJson(s)).toList();
        return sessions;
      }

      return [];
    } on DioException catch (e) {
      print('Error fetching sessions: ${e.message}');
      return [];
    }
  }

  /// Get session details dari server
  Future<TrackingSession?> getSession(String sessionId) async {
    try {
      final response = await dio.get(endpointSessions ?? '/api/v1/tracking/sessions/$sessionId');

      if (response.statusCode == 200) {
        return TrackingSession.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      print('Error fetching session: ${e.message}');
      return null;
    }
  }

  /// Get location points untuk session dari server
  Future<List<LocationPoint>> getSessionPoints(String sessionId) async {
    try {
      final response = await dio.get(endpointSessions ?? '/api/v1/tracking/sessions/$sessionId/points');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final points = (data['data'] as List).map((p) => LocationPoint.fromJson(p)).toList();
        return points;
      }

      return [];
    } on DioException catch (e) {
      print('Error fetching points: ${e.message}');
      return [];
    }
  }

  /// Delete session di server
  Future<bool> deleteSession(String sessionId) async {
    try {
      final response = await dio.delete('/api/v1/tracking/sessions/$sessionId');
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Error deleting session: ${e.message}');
      return false;
    }
  }

  /// Update session di server
  Future<bool> updateSession(TrackingSession session) async {
    try {
      final response = await dio.put('/api/v1/tracking/sessions/${session.id}', data: session.toJson());

      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Error updating session: ${e.message}');
      return false;
    }
  }

  /// Check connectivity
  Future<bool> checkConnectivity() async {
    try {
      final response = await dio.get('/api/v1/health');
      return response.statusCode == 200;
    } on DioException {
      return false;
    }
  }

  /// Set authorization header
  void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear authorization header
  void clearAuthToken() {
    dio.options.headers.remove('Authorization');
  }

  /// Add custom header
  void addHeader(String key, String value) {
    dio.options.headers[key] = value;
  }
}
