import 'package:get/get.dart';

import '../../core/utils/logger.dart';
import '../../data/models/coffee_class.dart';
import '../../data/repositories/history_repository.dart';
import '../../data/repositories/auth_repository.dart';

class DashboardController extends GetxController {
  // Resolved in onInit() — never in field declarations
  late final HistoryRepository _historyRepository;
  late final AuthRepository _authRepository;

  final isLoading = false.obs;
  final totalScans = 0.obs;
  final premiumCount = 0.obs;
  final longberryCount = 0.obs;
  final peaberryCount = 0.obs;
  final defectCount = 0.obs;
  final oodCount = 0.obs;
  final avgConfidence = 0.0.obs;
  final lastScanDate = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    _historyRepository = Get.find<HistoryRepository>();
    _authRepository = Get.find<AuthRepository>();
    AppLogger.d('[DashboardController] Initialized');
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    try {
      isLoading.value = true;
      final userId = _authRepository.currentUserId;
      if (userId == null) {
        AppLogger.d('[DashboardController] No user ID found');
        return;
      }
      final scans = await _historyRepository.getAllScans(userId);
      totalScans.value = scans.length;
      if (scans.isEmpty) { _resetStats(); return; }

      premiumCount.value =
          scans.where((s) => s.predictions.first.label == CoffeeClass.premium).length;
      longberryCount.value =
          scans.where((s) => s.predictions.first.label == CoffeeClass.longberry).length;
      peaberryCount.value =
          scans.where((s) => s.predictions.first.label == CoffeeClass.peaberry).length;
      defectCount.value =
          scans.where((s) => s.predictions.first.label == CoffeeClass.defect).length;
      oodCount.value = scans.where((s) => s.isOod).length;

      avgConfidence.value = scans.fold<double>(
              0.0, (sum, s) => sum + s.predictions.first.probability) /
          scans.length;

      scans.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      lastScanDate.value = scans.first.createdAt;

      AppLogger.d('[DashboardController] Loaded stats: ${totalScans.value} scans');
    } catch (e) {
      AppLogger.e('[DashboardController] Error loading statistics', err: e);
      Get.snackbar('Error', 'Failed to load dashboard statistics',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void _resetStats() {
    premiumCount.value = longberryCount.value = peaberryCount.value =
        defectCount.value = oodCount.value = 0;
    avgConfidence.value = 0.0;
    lastScanDate.value = null;
  }

  Future<void> refresh() async => loadStatistics();

  double get qualityPercentage {
    if (totalScans.value == 0) return 0.0;
    return ((premiumCount.value + longberryCount.value + peaberryCount.value) /
            totalScans.value) *
        100;
  }

  double get defectPercentage {
    if (totalScans.value == 0) return 0.0;
    return (defectCount.value / totalScans.value) * 100;
  }

  Map<String, int> get classDistribution => {
        'Premium': premiumCount.value,
        'Longberry': longberryCount.value,
        'Peaberry': peaberryCount.value,
        'Defect': defectCount.value,
      };

  String get topClass {
    final d = classDistribution;
    if (d.values.every((v) => v == 0)) return 'None';
    return (d.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .first
        .key;
  }
}
