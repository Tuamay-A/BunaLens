import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

import '../../core/utils/logger.dart';
import '../datasources/tflite_datasource.dart';
import '../models/coffee_class.dart';
import '../models/grade_result.dart';
import '../models/prediction.dart';
import '../local/database.dart';

class GradingRepository {
  final TFLiteDataSource _tflite;
  final AppDatabase _database;
  final Uuid _uuid = const Uuid();

  GradingRepository(this._tflite, this._database);

  // Grade a coffee bean image and save locally
  // Returns a sorted list of predictions (desc by probability).
  Future<GradeResult> grade(String imagePath, {String? userId}) async {
    final probs = await _tflite.predictFromPath(imagePath);
    final result = _buildResult(imagePath, probs);
    
    // Save to local database if userId is provided
    if (userId != null) {
      await _saveLocally(result, userId);
    }
    
    return result;
  }

  // Grade from bytes and save locally
  Future<GradeResult> gradeBytes(
    String path,
    Uint8List bytes, {
    String? userId,
  }) async {
    final probs = await _tflite.predictFromBytes(bytes);
    final result = _buildResult(path, probs);
    
    // Save to local database if userId is provided
    if (userId != null) {
      await _saveLocally(result, userId);
    }
    
    return result;
  }

  // Build GradeResult from predictions
  GradeResult _buildResult(String path, List<double> probs) {
    final preds = List.generate(
      probs.length,
      (i) => Prediction(label: CoffeeClass.fromIndex(i), probability: probs[i]),
    );
    preds.sort((a, b) => b.probability.compareTo(a.probability));

    // Generate UUID for client scan ID
    final clientScanId = _uuid.v4();

    return GradeResult(
      id: clientScanId,
      imagePath: path,
      predictions: preds,
      createdAt: DateTime.now(),
      // OOD detection: check if max probability is below threshold
      isOod: preds.first.probability < 0.7678, // From model spec
    );
  }

  // Save scan result to local database and enqueue for sync
  Future<void> _saveLocally(GradeResult result, String userId) async {
    try {
      // Insert into local scans table
      await _database.insertScan(
        LocalScansCompanion(
          id: drift.Value(result.id),
          userId: drift.Value(userId),
          predictedClass: drift.Value(result.topClass.name),
          confidence: drift.Value(result.topProbability),
          probabilityDefect: drift.Value(result.probabilityFor(CoffeeClass.defect)),
          probabilityLongberry: drift.Value(result.probabilityFor(CoffeeClass.longberry)),
          probabilityPeaberry: drift.Value(result.probabilityFor(CoffeeClass.peaberry)),
          probabilityPremium: drift.Value(result.probabilityFor(CoffeeClass.premium)),
          isOod: drift.Value(result.isOod),
          imageLocalPath: drift.Value(result.imagePath),
          notes: drift.Value(result.notes),
          createdAt: drift.Value(result.createdAt),
          syncState: const drift.Value('pending'), // Mark as pending sync
        ),
      );

      // Enqueue for cloud sync
      await _database.addToOutbox(
        SyncOutboxCompanion(
          scanId: drift.Value(result.id),
          operation: const drift.Value('insert'),
          createdAt: drift.Value(DateTime.now()),
        ),
      );
    } catch (e) {
      // Log error but don't fail the grading operation
      AppLogger.e('Failed to save scan locally', err: e);
    }
  }

  // Update scan notes (local + enqueue for sync)
  Future<void> updateNotes(String scanId, String newNotes) async {
    try {
      // Update local database
      await _database.updateScanNotes(scanId, newNotes);

      // Enqueue update operation so SyncService pushes it to cloud
      await _database.addToOutbox(
        SyncOutboxCompanion(
          scanId: drift.Value(scanId),
          operation: const drift.Value('update'),
          createdAt: drift.Value(DateTime.now()),
        ),
      );
    } catch (e) {
      throw Exception('Failed to update notes: $e');
    }
  }

  // Delete a scan (local + enqueue cloud delete)
  Future<void> deleteScan(String scanId) async {
    try {
      await _database.addToOutbox(
        SyncOutboxCompanion(
          scanId: drift.Value(scanId),
          operation: const drift.Value('delete'),
          createdAt: drift.Value(DateTime.now()),
        ),
      );

      // Now delete from local database
      await _database.deleteScan(scanId);
    } catch (e) {
      throw Exception('Failed to delete scan: $e');
    }
  }
}