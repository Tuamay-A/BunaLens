import 'coffee_class.dart';

// Cloud-synced scan record model
// Maps to the `scans` table in Supabase
class ScanRecord {
  final String id; // Server-side UUID
  final String userId;
  final String clientScanId; // Device-generated UUID for deduplication
  final CoffeeClass predictedClass;
  final double confidence;

  // Full probability distribution
  final double probabilityDefect;
  final double probabilityLongberry;
  final double probabilityPeaberry;
  final double probabilityPremium;

  final bool isOod; // Out-of-distribution detection
  final String? imageUrl; // Supabase Storage URL
  final String? imageLocalPath; // Device local path (not synced)
  final String? notes; // User-editable notes
  final DateTime createdAt;
  final DateTime? syncedAt;

  const ScanRecord({
    required this.id,
    required this.userId,
    required this.clientScanId,
    required this.predictedClass,
    required this.confidence,
    required this.probabilityDefect,
    required this.probabilityLongberry,
    required this.probabilityPeaberry,
    required this.probabilityPremium,
    required this.isOod,
    this.imageUrl,
    this.imageLocalPath,
    this.notes,
    required this.createdAt,
    this.syncedAt,
  });

  // Check if this scan has been synced to cloud
  bool get isSynced => syncedAt != null;

  // Get sync status for UI display
  SyncStatus get syncStatus {
    if (syncedAt != null) return SyncStatus.synced;
    return SyncStatus.localOnly;
  }

  // Get probability for a specific class
  double probabilityFor(CoffeeClass coffeeClass) {
    return switch (coffeeClass) {
      CoffeeClass.defect => probabilityDefect,
      CoffeeClass.longberry => probabilityLongberry,
      CoffeeClass.peaberry => probabilityPeaberry,
      CoffeeClass.premium => probabilityPremium,
    };
  }

  // Get all probabilities as a map
  Map<CoffeeClass, double> get probabilityMap => {
        CoffeeClass.defect: probabilityDefect,
        CoffeeClass.longberry: probabilityLongberry,
        CoffeeClass.peaberry: probabilityPeaberry,
        CoffeeClass.premium: probabilityPremium,
      };

  // Letter grade based on predicted class
  String get letterGrade => switch (predictedClass) {
        CoffeeClass.premium => 'A',
        CoffeeClass.longberry => 'B',
        CoffeeClass.peaberry => 'B',
        CoffeeClass.defect => 'F',
      };

  // Create from Supabase JSON response
  factory ScanRecord.fromJson(Map<String, dynamic> json) {
    return ScanRecord(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      clientScanId: json['client_scan_id'] as String,
      predictedClass: CoffeeClass.values.firstWhere(
        (e) => e.name == json['predicted_class'],
      ),
      confidence: (json['confidence'] as num).toDouble(),
      probabilityDefect: (json['probability_defect'] as num).toDouble(),
      probabilityLongberry: (json['probability_longberry'] as num).toDouble(),
      probabilityPeaberry: (json['probability_peaberry'] as num).toDouble(),
      probabilityPremium: (json['probability_premium'] as num).toDouble(),
      isOod: json['is_ood'] as bool? ?? false,
      imageUrl: json['image_url'] as String?,
      imageLocalPath: json['image_local_path'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      syncedAt: json['synced_at'] != null
          ? DateTime.parse(json['synced_at'] as String)
          : null,
    );
  }

  // Convert to JSON for Supabase insert/update
  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'image_local_path': imageLocalPath,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      if (syncedAt != null) 'synced_at': syncedAt!.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  ScanRecord copyWith({
    String? id,
    String? userId,
    String? clientScanId,
    CoffeeClass? predictedClass,
    double? confidence,
    double? probabilityDefect,
    double? probabilityLongberry,
    double? probabilityPeaberry,
    double? probabilityPremium,
    bool? isOod,
    String? imageUrl,
    String? imageLocalPath,
    String? notes,
    DateTime? createdAt,
    DateTime? syncedAt,
  }) {
    return ScanRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      clientScanId: clientScanId ?? this.clientScanId,
      predictedClass: predictedClass ?? this.predictedClass,
      confidence: confidence ?? this.confidence,
      probabilityDefect: probabilityDefect ?? this.probabilityDefect,
      probabilityLongberry: probabilityLongberry ?? this.probabilityLongberry,
      probabilityPeaberry: probabilityPeaberry ?? this.probabilityPeaberry,
      probabilityPremium: probabilityPremium ?? this.probabilityPremium,
      isOod: isOod ?? this.isOod,
      imageUrl: imageUrl ?? this.imageUrl,
      imageLocalPath: imageLocalPath ?? this.imageLocalPath,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScanRecord &&
        other.id == id &&
        other.clientScanId == clientScanId;
  }

  @override
  int get hashCode => id.hashCode ^ clientScanId.hashCode;

  @override
  String toString() {
    return 'ScanRecord(id: $id, clientScanId: $clientScanId, '
        'predictedClass: ${predictedClass.name}, confidence: $confidence, '
        'isOod: $isOod, synced: $isSynced)';
  }
}

/// Sync status enum for UI display
enum SyncStatus {
  synced, // Successfully synced to cloud
  localOnly, // Not yet synced (offline or pending)
  syncing, // Currently uploading
  failed; // Sync failed, needs retry

  String get displayName => switch (this) {
        SyncStatus.synced => 'Synced',
        SyncStatus.localOnly => 'Local only',
        SyncStatus.syncing => 'Syncing...',
        SyncStatus.failed => 'Sync failed',
      };
}
