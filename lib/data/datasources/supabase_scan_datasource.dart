import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/scan_record.dart';
import '../models/coffee_class.dart';
import '../models/prediction.dart';
import '../models/grade_result.dart';

// Datasource for cloud scan operations via Supabase
// Handles CRUD operations for the `scans` table
class SupabaseScanDatasource {
  final SupabaseClient _client;

  SupabaseScanDatasource({required SupabaseClient client}) : _client = client;

  // CREATE

  // Insert a new scan to cloud
  // Returns the server-generated UUID
  Future<String> insertScan({
    required String userId,
    required String clientScanId,
    required CoffeeClass predictedClass,
    required double confidence,
    required double probabilityDefect,
    required double probabilityLongberry,
    required double probabilityPeaberry,
    required double probabilityPremium,
    required bool isOod,
    String? imageUrl,
    String? notes,
    required DateTime createdAt,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'client_scan_id': clientScanId,
        'predicted_class': predictedClass.name,
        'confidence': confidence,
        'probability_defect': probabilityDefect,
        'probability_longberry': probabilityLongberry,
        'probability_peaberry': probabilityPeaberry,
        'probability_premium': probabilityPremium,
        'is_ood': isOod,
        'image_url': imageUrl,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
        'synced_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('scans')
          .insert(data)
          .select('id')
          .single();

      return response['id'] as String;
    } catch (e) {
      throw Exception('Failed to insert scan: $e');
    }
  }

  // Bulk insert scans (for initial sync)
  Future<void> insertScans(List<Map<String, dynamic>> scans) async {
    try {
      await _client.from('scans').insert(scans);
    } catch (e) {
      throw Exception('Failed to bulk insert scans: $e');
    }
  }

  // READ

  // Get all scans for a user
  Future<List<ScanRecord>> getUserScans(String userId) async {
    try {
      final response = await _client
          .from('scans')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ScanRecord.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user scans: $e');
    }
  }

  // Get scans created after a specific timestamp (for incremental sync)
  Future<List<ScanRecord>> getScansAfter(
    String userId,
    DateTime after,
  ) async {
    try {
      final response = await _client
          .from('scans')
          .select()
          .eq('user_id', userId)
          .gt('created_at', after.toIso8601String())
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ScanRecord.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch scans after timestamp: $e');
    }
  }

  // Get a single scan by server ID
  Future<ScanRecord?> getScanById(String scanId) async {
    try {
      final response = await _client
          .from('scans')
          .select()
          .eq('id', scanId)
          .maybeSingle();

      if (response == null) return null;
      return ScanRecord.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch scan by ID: $e');
    }
  }

  // Get a single scan by client scan ID (for deduplication)
  Future<ScanRecord?> getScanByClientId(
    String userId,
    String clientScanId,
  ) async {
    try {
      final response = await _client
          .from('scans')
          .select()
          .eq('user_id', userId)
          .eq('client_scan_id', clientScanId)
          .maybeSingle();

      if (response == null) return null;
      return ScanRecord.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch scan by client ID: $e');
    }
  }

  // Get scan count for a user
  Future<int> getScanCount(String userId) async {
    try {
      final response = await _client
          .from('scans')
          .select('id')
          .eq('user_id', userId)
          .count();

      return response.count;
    } catch (e) {
      throw Exception('Failed to count scans: $e');
    }
  }

  // Get scans by predicted class
  Future<List<ScanRecord>> getScansByClass(
    String userId,
    CoffeeClass coffeeClass,
  ) async {
    try {
      final response = await _client
          .from('scans')
          .select()
          .eq('user_id', userId)
          .eq('predicted_class', coffeeClass.name)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ScanRecord.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch scans by class: $e');
    }
  }

  // UPDATE

  // Update scan notes
  Future<void> updateScanNotes(String scanId, String notes) async {
    try {
      await _client
          .from('scans')
          .update({'notes': notes})
          .eq('id', scanId);
    } catch (e) {
      throw Exception('Failed to update scan notes: $e');
    }
  }

  // Update image URL after upload
  Future<void> updateImageUrl(String scanId, String imageUrl) async {
    try {
      await _client
          .from('scans')
          .update({'image_url': imageUrl})
          .eq('id', scanId);
    } catch (e) {
      throw Exception('Failed to update image URL: $e');
    }
  }

  // DELETE

  // Delete a single scan
  Future<void> deleteScan(String scanId) async {
    try {
      await _client.from('scans').delete().eq('id', scanId);
    } catch (e) {
      throw Exception('Failed to delete scan: $e');
    }
  }

  // Delete all scans for a user (on account deletion)
  Future<void> deleteAllUserScans(String userId) async {
    try {
      await _client.from('scans').delete().eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to delete all user scans: $e');
    }
  }

  // CONVERSION HELPERS

  // Convert GradeResult to Supabase insert data
  Map<String, dynamic> gradeResultToInsertData(
    GradeResult result,
    String userId,
    String? imageUrl,
  ) {
    return {
      'user_id': userId,
      'client_scan_id': result.id,
      'predicted_class': result.topClass.name,
      'confidence': result.topProbability,
      'probability_defect': result.probabilityFor(CoffeeClass.defect),
      'probability_longberry': result.probabilityFor(CoffeeClass.longberry),
      'probability_peaberry': result.probabilityFor(CoffeeClass.peaberry),
      'probability_premium': result.probabilityFor(CoffeeClass.premium),
      'is_ood': result.isOod,
      'image_url': imageUrl,
      'notes': result.notes,
      'created_at': result.createdAt.toIso8601String(),
      'synced_at': DateTime.now().toIso8601String(),
    };
  }

  // Convert ScanRecord to GradeResult
  GradeResult scanRecordToGradeResult(
    ScanRecord record,
    String localImagePath,
  ) {
    // Build predictions list from probabilities
    final predictions = [
      Prediction(
        label: CoffeeClass.defect,
        probability: record.probabilityDefect,
      ),
      Prediction(
        label: CoffeeClass.longberry,
        probability: record.probabilityLongberry,
      ),
      Prediction(
        label: CoffeeClass.peaberry,
        probability: record.probabilityPeaberry,
      ),
      Prediction(
        label: CoffeeClass.premium,
        probability: record.probabilityPremium,
      ),
    ];

    // Sort by probability descending
    predictions.sort((a, b) => b.probability.compareTo(a.probability));

    return GradeResult(
      id: record.clientScanId,
      imagePath: localImagePath,
      predictions: predictions,
      createdAt: record.createdAt,
      serverId: record.id,
      isOod: record.isOod,
      notes: record.notes,
      syncedAt: record.syncedAt,
    );
  }
}
