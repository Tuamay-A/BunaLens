import 'coffee_class.dart';
import 'prediction.dart';

class GradeResult {
  final String id; 
  final String imagePath; 
  final List<Prediction> predictions; 
  final DateTime createdAt;

  // Cloud sync fields (extended for Phase C)
  final String? serverId; 
  final bool isOod; 
  final String? notes; 
  final DateTime? syncedAt; 
  GradeResult({
    required this.id,
    required this.imagePath,
    required this.predictions,
    required this.createdAt,
    this.serverId,
    this.isOod = false,
    this.notes,
    this.syncedAt,
  });

  CoffeeClass get topClass => predictions.first.label;
  double get topProbability => predictions.first.probability;

  // Check if this result has been synced to cloud
  bool get isSynced => syncedAt != null && serverId != null;

  // Get probability for a specific class
  double probabilityFor(CoffeeClass coffeeClass) {
    final pred = predictions.firstWhere((p) => p.label == coffeeClass);
    return pred.probability;
  }

  /// Letter grade heuristic — for UX sugar.
  String get letterGrade => switch (topClass) {
    CoffeeClass.premium   => 'A',
    CoffeeClass.longberry => 'B',
    CoffeeClass.peaberry  => 'B',
    CoffeeClass.defect    => 'F',
  };

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'predictions': predictions.map((p) => p.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'serverId': serverId,
        'isOod': isOod,
        'notes': notes,
        if (syncedAt != null) 'syncedAt': syncedAt!.toIso8601String(),
      };

  factory GradeResult.fromJson(Map<String, dynamic> j) => GradeResult(
        id: j['id'],
        imagePath: j['imagePath'],
        predictions: (j['predictions'] as List)
            .map((e) => Prediction.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        createdAt: DateTime.parse(j['createdAt']),
        serverId: j['serverId'] as String?,
        isOod: j['isOod'] as bool? ?? false,
        notes: j['notes'] as String?,
        syncedAt: j['syncedAt'] != null ? DateTime.parse(j['syncedAt']) : null,
      );

  // Create a copy with updated fields
  GradeResult copyWith({
    String? id,
    String? imagePath,
    List<Prediction>? predictions,
    DateTime? createdAt,
    String? serverId,
    bool? isOod,
    String? notes,
    DateTime? syncedAt,
  }) {
    return GradeResult(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      predictions: predictions ?? this.predictions,
      createdAt: createdAt ?? this.createdAt,
      serverId: serverId ?? this.serverId,
      isOod: isOod ?? this.isOod,
      notes: notes ?? this.notes,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}