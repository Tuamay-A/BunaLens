// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:io';

import '../../core/utils/logger.dart';
import '../local/database.dart';
import '../models/coffee_class.dart';
import '../datasources/supabase_scan_datasource.dart';
import '../datasources/supabase_storage_datasource.dart';
import '../repositories/auth_repository.dart';
import 'connectivity_service.dart';

// Service to sync local scans to cloud
// Processes the sync_outbox queue with retry logic
class SyncService {
  final AppDatabase _database;
  final SupabaseScanDatasource _scanDatasource;
  final SupabaseStorageDatasource _storageDatasource;
  final AuthRepository _authRepository;
  final ConnectivityService _connectivityService;

  // Sync state
  bool _isRunning = false;
  bool _isSyncing = false;
  Timer? _periodicTimer;
  StreamSubscription? _connectivitySubscription;

  // Configuration
  static const Duration _syncInterval = Duration(minutes: 5);
  static const int _maxRetries = 5;
  static const Duration _initialBackoff = Duration(seconds: 5);

  SyncService({
    required AppDatabase database,
    required SupabaseScanDatasource scanDatasource,
    required SupabaseStorageDatasource storageDatasource,
    required AuthRepository authRepository,
    required ConnectivityService connectivityService,
  })  : _database = database,
        _scanDatasource = scanDatasource,
        _storageDatasource = storageDatasource,
        _authRepository = authRepository,
        _connectivityService = connectivityService;

  // LIFECYCLE

  // Start the sync service
  // Called when user signs in
  void start() {
    if (_isRunning) return;
    
    AppLogger.d('[SyncService] Starting...');
    _isRunning = true;

    // Sync immediately on start
    _syncNow();

    // Set up periodic sync
    _periodicTimer = Timer.periodic(_syncInterval, (_) => _syncNow());

    // Listen to connectivity changes
    _connectivitySubscription = _connectivityService.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        AppLogger.d('[SyncService] Connectivity restored, syncing...');
        _syncNow();
      }
    });

    AppLogger.d('[SyncService] Started successfully');
  }

  // Stop the sync service
  // Called when user signs out
  void stop() {
    if (!_isRunning) return;
    
    AppLogger.d('[SyncService] Stopping...');
    _isRunning = false;

    _periodicTimer?.cancel();
    _periodicTimer = null;

    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;

    AppLogger.d('[SyncService] Stopped');
  }

  // Trigger immediate sync
  // Returns true if sync started, false if already syncing
  Future<bool> syncNow() async {
    return await _syncNow();
  }

  // SYNC LOGIC

  // Internal sync method
  Future<bool> _syncNow() async {
    // Check if already syncing
    if (_isSyncing) {
      AppLogger.d('[SyncService] Already syncing, skipping');
      return false;
    }

    // Check authentication
    if (!_authRepository.isAuthenticated) {
      AppLogger.d('[SyncService] Not authenticated, skipping sync');
      return false;
    }

    // Check connectivity
    if (!_connectivityService.isOnline) {
      AppLogger.d('[SyncService] Offline, skipping sync');
      return false;
    }

    _isSyncing = true;
    AppLogger.d('[SyncService] Starting sync...');

    try {
      await _processOutbox();
      AppLogger.d('[SyncService] Sync completed successfully');
      return true;
    } catch (e) {
      AppLogger.d('[SyncService] Sync failed: $e');
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  // Process all pending entries in the sync outbox
  Future<void> _processOutbox() async {
    final userId = _authRepository.currentUserId;
    if (userId == null) {
      AppLogger.d('[SyncService] No user ID, cannot sync');
      return;
    }

    // Get all pending outbox entries
    final entries = await _database.getPendingOutbox();
    
    if (entries.isEmpty) {
      AppLogger.d('[SyncService] Outbox is empty');
      return;
    }

    AppLogger.d('[SyncService] Processing ${entries.length} outbox entries');

    // Process each entry
    for (final entry in entries) {
      await _processOutboxEntry(entry, userId);
    }
  }

  /// Process a single outbox entry
  Future<void> _processOutboxEntry(dynamic entry, String userId) async {
    try {
      // Check if we should retry based on attempt count
      if (entry.attemptCount >= _maxRetries) {
        AppLogger.d('[SyncService] Max retries reached for scan ${entry.scanId}, skipping');
        return;
      }

      // Calculate backoff delay
      if (entry.attemptCount > 0 && entry.lastAttemptAt != null) {
        final backoffDuration = _calculateBackoff(entry.attemptCount);
        final nextAttempt = entry.lastAttemptAt!.add(backoffDuration);
        
        if (DateTime.now().isBefore(nextAttempt)) {
          AppLogger.d('[SyncService] Backoff not elapsed for scan ${entry.scanId}, skipping');
          return;
        }
      }

      AppLogger.d('[SyncService] Processing ${entry.operation} for scan ${entry.scanId}');

      // Get the local scan
      final localScan = await _database.getScanById(entry.scanId);
      
      if (localScan == null) {
        AppLogger.d('[SyncService] Scan ${entry.scanId} not found locally, removing from outbox');
        await _database.removeFromOutbox(entry.id);
        return;
      }

      // Process based on operation type
      switch (entry.operation) {
        case 'insert':
          await _syncInsert(localScan, userId);
          break;
        case 'update':
          await _syncUpdate(localScan, userId);
          break;
        case 'delete':
          await _syncDelete(localScan, userId);
          break;
        default:
          AppLogger.d('[SyncService] Unknown operation: ${entry.operation}');
      }

      // Remove from outbox on success
      await _database.removeFromOutbox(entry.id);
      AppLogger.d('[SyncService] Successfully synced ${entry.operation} for scan ${entry.scanId}');
      
    } catch (e) {
      AppLogger.d('[SyncService] Failed to process entry ${entry.id}: $e');

      // Use the typed helper — correctly increments the counter so
      // exponential backoff advances on every failed attempt.
      await _database.updateOutboxFailure(
        entry.id,
        entry.attemptCount,
        e.toString(),
      );
    }
  }

  // SYNC OPERATIONS

  // Sync insert operation (new scan)
  Future<void> _syncInsert(LocalScan scan, String userId) async {
    // Upload image first (if exists and not already uploaded)
    String? imageUrl = scan.imageUrl;
    
    if (scan.imageLocalPath != null && 
        scan.imageLocalPath!.isNotEmpty && 
        imageUrl == null) {
      try {
        imageUrl = await _uploadImage(scan.imageLocalPath!, userId, scan.id);
      } catch (e) {
        AppLogger.d('[SyncService] Image upload failed, will retry: $e');
        throw Exception('Image upload failed: $e');
      }
    }

    // Insert scan to cloud
    final serverId = await _scanDatasource.insertScan(
      userId: userId,
      clientScanId: scan.id,
      predictedClass: _parseClass(scan.predictedClass),
      confidence: scan.confidence,
      probabilityDefect: scan.probabilityDefect,
      probabilityLongberry: scan.probabilityLongberry,
      probabilityPeaberry: scan.probabilityPeaberry,
      probabilityPremium: scan.probabilityPremium,
      isOod: scan.isOod,
      imageUrl: imageUrl,
      notes: scan.notes,
      createdAt: scan.createdAt,
    );

    // Mark as synced locally
    await _database.markScanSynced(scan.id, serverId);
  }

  /// Sync update operation (edit scan)
  Future<void> _syncUpdate(LocalScan scan, String userId) async {
    if (scan.serverId == null) {
      AppLogger.d('[SyncService] Cannot update scan without server ID, treating as insert');
      await _syncInsert(scan, userId);
      return;
    }

    // Update notes in cloud
    if (scan.notes != null) {
      await _scanDatasource.updateScanNotes(scan.serverId!, scan.notes!);
    }

    // Update image URL if changed
    if (scan.imageUrl != null) {
      await _scanDatasource.updateImageUrl(scan.serverId!, scan.imageUrl!);
    }
  }

  // Sync delete operation
  Future<void> _syncDelete(LocalScan scan, String userId) async {
    if (scan.serverId == null) {
      AppLogger.d('[SyncService] Cannot delete scan without server ID, skipping');
      return;
    }

    // Delete from cloud
    await _scanDatasource.deleteScan(scan.serverId!);

    // Delete image from storage if exists
    if (scan.imageUrl != null) {
      try {
        final storagePath = _storageDatasource.extractStoragePathFromUrl(scan.imageUrl!);
        if (storagePath != null) {
          await _storageDatasource.deleteImage(storagePath);
        }
      } catch (e) {
        AppLogger.d('[SyncService] Failed to delete image: $e');
        // Continue anyway - scan is deleted
      }
    }
  }

  // HELPERS

  // Upload image to Supabase Storage
  Future<String> _uploadImage(String localPath, String userId, String scanId) async {
    final file = File(localPath);
    
    if (!await file.exists()) {
      throw Exception('Image file not found: $localPath');
    }

    AppLogger.d('[SyncService] Uploading image for scan $scanId');
    final imageUrl = await _storageDatasource.uploadImage(
      userId: userId,
      scanId: scanId,
      localFilePath: localPath,
    );
    
    AppLogger.d('[SyncService] Image uploaded: $imageUrl');
    return imageUrl;
  }

  // Parse coffee class string to [CoffeeClass] enum.
  CoffeeClass _parseClass(String className) {
    return CoffeeClass.values.byName(className.toLowerCase());
  }

  // Calculate exponential backoff duration
  Duration _calculateBackoff(int attemptCount) {
    final multiplier = (1 << attemptCount).clamp(1, 32); // 2^n, capped at 32
    return _initialBackoff * multiplier;
  }

  // STATUS

  // Check if sync service is running
  bool get isRunning => _isRunning;

  // Check if currently syncing
  bool get isSyncing => _isSyncing;

  // Get pending outbox count
  Future<int> getPendingCount() async {
    final entries = await _database.getPendingOutbox();
    return entries.length;
  }
}
