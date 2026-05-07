import 'package:live_tracking_plugin/src/service/database_helper.dart';
import 'package:live_tracking_plugin/src/service/live_tracking_api_service.dart';
import 'package:live_tracking_plugin/src/service/live_tracking_service.dart';
import 'package:live_tracking_plugin/src/service/offline_sync_manager.dart';

/// Main plugin class untuk Live Tracking
class LiveTrackingPlugin {
  static late LiveTrackingService _trackingService;
  static late OfflineSyncManager _syncManager;
  static late LiveTrackingApiService _apiService;
  static late DatabaseHelper _dbHelper;

  static bool _initialized = false;

  /// Initialize plugin dengan configuration
  static Future<void> initialize({required String apiBaseUrl, String? authToken}) async {
    if (_initialized) return;

    // Initialize database
    _dbHelper = DatabaseHelper();

    // Initialize API service
    _apiService = LiveTrackingApiService(baseUrl: apiBaseUrl);
    if (authToken != null) {
      _apiService.setAuthToken(authToken);
    }

    // Initialize services
    _trackingService = LiveTrackingService();
    _syncManager = OfflineSyncManager(apiService: _apiService, dbHelper: _dbHelper);

    _initialized = true;
  }

  /// Get tracking service
  static LiveTrackingService get trackingService {
    _checkInitialized();
    return _trackingService;
  }

  /// Get sync manager
  static OfflineSyncManager get syncManager {
    _checkInitialized();
    return _syncManager;
  }

  /// Get API service
  static LiveTrackingApiService get apiService {
    _checkInitialized();
    return _apiService;
  }

  /// Get database helper
  static DatabaseHelper get dbHelper {
    _checkInitialized();
    return _dbHelper;
  }

  /// Check if plugin is initialized
  static bool get isInitialized => _initialized;

  static void _checkInitialized() {
    if (!_initialized) {
      throw Exception(
        'LiveTrackingPlugin is not initialized. '
        'Call LiveTrackingPlugin.initialize() first.',
      );
    }
  }

  /// Set authentication token
  static void setAuthToken(String token) {
    _checkInitialized();
    _apiService.setAuthToken(token);
  }

  /// Clear authentication token
  static void clearAuthToken() {
    _checkInitialized();
    _apiService.clearAuthToken();
  }

  /// Dispose plugin
  static Future<void> dispose() async {
    if (_initialized) {
      _trackingService.onClose();
      _syncManager.onClose();
      await _dbHelper.close();
      _initialized = false;
    }
  }
}
