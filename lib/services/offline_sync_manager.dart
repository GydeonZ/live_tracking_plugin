import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../database/database_helper.dart';
import 'live_tracking_api_service.dart';

/// Manager untuk sinkronisasi offline/online
class OfflineSyncManager extends GetxService {
  final LiveTrackingApiService apiService;
  final DatabaseHelper dbHelper;

  final RxBool isOnline = false.obs;
  final RxBool isSyncing = false.obs;
  final RxInt pendingItems = 0.obs;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _syncTimer;

  OfflineSyncManager({required this.apiService, required this.dbHelper});

  @override
  void onInit() {
    super.onInit();
    _initConnectivityMonitoring();
  }

  /// Initialize connectivity monitoring
  void _initConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      isOnline.value = !results.contains(ConnectivityResult.none);

      if (isOnline.value) {
        _syncData();
        // Start periodic sync every 30 seconds
        _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
          _syncData();
        });
      } else {
        _syncTimer?.cancel();
      }
    });

    // Initial check
    Connectivity().checkConnectivity().then((results) {
      isOnline.value = !results.contains(ConnectivityResult.none);
    });
  }

  /// Sync all offline data ke server
  Future<void> _syncData() async {
    if (isSyncing.value) return;

    try {
      isSyncing.value = true;

      // Sync sessions
      final unsyncedSessions = await dbHelper.getUnsyncedSessions();
      for (final session in unsyncedSessions) {
        final success = await apiService.uploadSession(session);
        if (success) {
          await dbHelper.updateSessionSyncStatus(session.id, true);
        }
      }

      // Sync points
      final unsyncedPoints = await dbHelper.getUnsyncedPoints();
      if (unsyncedPoints.isNotEmpty) {
        // Batch upload dalam chunks
        const batchSize = 100;
        for (int i = 0; i < unsyncedPoints.length; i += batchSize) {
          final end = (i + batchSize > unsyncedPoints.length) ? unsyncedPoints.length : i + batchSize;
          final batch = unsyncedPoints.sublist(i, end);

          final success = await apiService.uploadLocationPoints(batch);
          if (success) {
            for (final point in batch) {
              await dbHelper.updatePointSyncStatus(point.id, true);
            }
          }
        }
      }

      // Update pending count
      _updatePendingCount();
    } finally {
      isSyncing.value = false;
    }
  }

  /// Trigger sync manually
  Future<void> syncNow() async {
    if (isOnline.value) {
      await _syncData();
    }
  }

  /// Update pending items count
  Future<void> _updatePendingCount() async {
    final sessions = await dbHelper.getUnsyncedSessions();
    final points = await dbHelper.getUnsyncedPoints();
    pendingItems.value = sessions.length + points.length;
  }

  /// Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    final sessions = await dbHelper.getUnsyncedSessions();
    final points = await dbHelper.getUnsyncedPoints();

    return {
      'isOnline': isOnline.value,
      'isSyncing': isSyncing.value,
      'pendingSessions': sessions.length,
      'pendingPoints': points.length,
      'totalPending': sessions.length + points.length,
    };
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    super.onClose();
  }
}
