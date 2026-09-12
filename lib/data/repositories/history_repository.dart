// ignore_for_file: unused_local_variable, unnecessary_non_null_assertion

import 'package:drift/drift.dart' as drift;
import '../../core/utils/logger.dart';
import '../datasources/supabase_scan_datasource.dart';
import '../models/grade_result.dart';
import '../models/coffee_class.dart';
import '../models/prediction.dart';
import '../local/database.dart';
import '../services/sync_service.dart';

class HistoryRepository {
  final AppDatabase _database;
  final SupabaseScanDatasource? _supabaseScanDatasource;
  SyncService? _syncService;

  HistoryRepository(
    this._database, {
    SupabaseScanDatasource? supabaseScanDatasource,
  }) : _supabaseScanDatasource = supabaseScanDatasource;

  // Set sync service (called from InitialBinding after SyncService is created)
  void setSyncService(SyncService syncService) {
    _syncService = syncService;
  }

  // NEW: DATABASE OPERATIONS (local scans)

  // Get all scans from local database for a user
  Future<List<GradeResult>> getAllScans(String userId) async {
    try {
      final localScans = await _database.getAllScans(userId);
      return localScans.map(_localScanToGradeResult).toList();
    } catch (e) {
      throw Exception('Failed to get local scans: $e');
    }
  }

  // Get recent scans from local database
  Future<List<GradeResult>> getRecentScans(String userId, {int limit = 10}) async {
    try {
      final localScans = await _database.getRecentScans(userId, limit: limit);
      return localScans.map(_localScanToGradeResult).toList();
    } catch (e) {
      throw Exception('Failed to get recent scans: $e');
    }
  }

  // Get scans by class from local database
  Future<List<GradeResult>> getScansByClass(
    String userId,
    CoffeeClass coffeeClass,
  ) async {
    try {
      final localScans = await _database.getScansByClass(userId, coffeeClass.name);
      return localScans.map(_localScanToGradeResult).toList();
    } catch (e) {
      throw Exception('Failed to get scans by class: $e');
    }
  }

  // Get total scan count from local database
  Future<int> getScanCount(String userId) async {
    try {
      return await _database.countScans(userId);
    } catch (e) {
      throw Exception('Failed to count scans: $e');
    }
  }

  // Get a single scan by ID from local database
  Future<GradeResult?> getScanById(String scanId) async {
    try {
      final localScan = await _database.getScanById(scanId);
      if (localScan == null) return null;
      return _localScanToGradeResult(localScan);
    } catch (e) {
      throw Exception('Failed to get scan by ID: $e');
    }
  }


  // delete still succeeds and the user's data is cleared locally.
  Future<void> deleteAllScans(String userId) async {
    // 1. Delete from cloud first so sync can't re-download after local wipe
    if (_supabaseScanDatasource != null) {
      try {
        await _supabaseScanDatasource!.deleteAllUserScans(userId);
      } catch (e) {
        AppLogger.d('[HistoryRepository] Cloud delete failed, continuing with local: $e');
      }
    }

    // 2. Wipe local database
    try {
      await _database.deleteAllScans(userId);
      // Clear outbox too — nothing left to sync
      await _database.clearOutbox();
    } catch (e) {
      throw Exception('Failed to delete all scans: $e');
    }
  }

  // CLOUD SYNC OPERATIONS
  // Fetch remote scans and merge with local
  // This is called during pull-to-refresh or on app start
  Future<List<GradeResult>> syncAndGetAllScans(String userId) async {
    if (_supabaseScanDatasource == null) {
      // Cloud sync disabled - return local only
      return getAllScans(userId);
    }

    try {
      // Fetch remote scans
      final remoteScans = await _supabaseScanDatasource!.getUserScans(userId);

      // Merge with local database (server wins for conflicts)
      await _mergeRemoteScans(userId, remoteScans);

      // Return all scans from local database (now includes merged remote)
      return getAllScans(userId);
    } catch (e) {
      // On error, return local scans
      AppLogger.d('Warning: Failed to sync scans, returning local only: $e');
      return getAllScans(userId);
    }
  }

  // Fetch scans created after a specific timestamp (incremental sync)
  Future<void> syncScansSince(String userId, DateTime since) async {
    if (_supabaseScanDatasource == null) return;

    try {
      final remoteScans = await _supabaseScanDatasource!.getScansAfter(userId, since);
      await _mergeRemoteScans(userId, remoteScans);
    } catch (e) {
      AppLogger.d('Warning: Incremental sync failed: $e');
    }
  }

  // Trigger manual sync (for pull-to-refresh)
  // Forces immediate sync of outbox and fetches remote scans
  Future<bool> triggerManualSync(String userId) async {
    try {
      AppLogger.d('[HistoryRepository] Manual sync triggered');
      
      // Trigger SyncService to process outbox immediately
      final syncStarted = await _syncService?.syncNow() ?? false;
      
      // Also fetch remote scans to update local
      if (_supabaseScanDatasource != null) {
        final remoteScans = await _supabaseScanDatasource!.getUserScans(userId);
        await _mergeRemoteScans(userId, remoteScans);
      }
      
      AppLogger.d('[HistoryRepository] Manual sync completed');
      return true;
    } catch (e) {
      AppLogger.d('[HistoryRepository] Manual sync failed: $e');
      return false;
    }
  }

  // Get pending sync count (for UI)
  Future<int> getPendingSyncCount() async {
    try {
      return await _syncService?.getPendingCount() ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Merge remote scans into local database
  // Server wins for conflicts (same client_scan_id)
  Future<void> _mergeRemoteScans(String userId, List remoteScans) async {
    try {
      for (final remoteScan in remoteScans) {
        // Check if scan already exists locally
        final existingLocal = await _database.getScanById(remoteScan.clientScanId);

        if (existingLocal == null) {
          // New scan from server - insert
          await _database.insertScan(
            LocalScansCompanion.insert(
              id: remoteScan.clientScanId,
              serverId: drift.Value(remoteScan.id),
              userId: userId,
              predictedClass: remoteScan.predictedClass.name,
              confidence: remoteScan.confidence,
              probabilityDefect: remoteScan.probabilityDefect,
              probabilityLongberry: remoteScan.probabilityLongberry,
              probabilityPeaberry: remoteScan.probabilityPeaberry,
              probabilityPremium: remoteScan.probabilityPremium,
              isOod: remoteScan.isOod,
              imageUrl: drift.Value(remoteScan.imageUrl),
              notes: drift.Value(remoteScan.notes),
              createdAt: remoteScan.createdAt,
              syncedAt: drift.Value(remoteScan.syncedAt),
              syncState: const drift.Value('synced'),
            ),
          );
        } else {
          // Scan exists - update with server data (server wins)
          await _database.update(_database.localScans).replace(
            existingLocal.copyWith(
              serverId: remoteScan.id,
              notes: remoteScan.notes,
              imageUrl: remoteScan.imageUrl,
              syncedAt: remoteScan.syncedAt,
              syncState: 'synced',
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.d('Warning: Failed to merge remote scans: $e');
    }
  }

  // CONVERSION HELPERS

  // Convert LocalScan (drift) to GradeResult
  GradeResult _localScanToGradeResult(LocalScan scan) {
    // Build predictions from probabilities
    final predictions = [
      Prediction(
        label: CoffeeClass.defect,
        probability: scan.probabilityDefect,
      ),
      Prediction(
        label: CoffeeClass.longberry,
        probability: scan.probabilityLongberry,
      ),
      Prediction(
        label: CoffeeClass.peaberry,
        probability: scan.probabilityPeaberry,
      ),
      Prediction(
        label: CoffeeClass.premium,
        probability: scan.probabilityPremium,
      ),
    ];

    // Sort by probability descending
    predictions.sort((a, b) => b.probability.compareTo(a.probability));

    return GradeResult(
      id: scan.id,
      imagePath: scan.imageLocalPath ?? '',
      predictions: predictions,
      createdAt: scan.createdAt,
      serverId: scan.serverId,
      isOod: scan.isOod,
      notes: scan.notes,
      syncedAt: scan.syncedAt,
    );
  }
}

