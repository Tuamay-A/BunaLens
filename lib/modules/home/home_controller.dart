import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/utils/logger.dart';
import '../../data/repositories/history_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/grade_result.dart';
import '../../data/models/coffee_class.dart';

class HomeController extends GetxController {
  // Resolved in onInit() — never in field declarations
  late final HistoryRepository _historyRepository;
  late final AuthRepository _authRepository;

  final recentScans = <GradeResult>[].obs;
  final isLoading = false.obs;
  final totalScans = 0.obs;
  final premiumCount = 0.obs;
  final defectCount = 0.obs;
  final pendingSyncCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _historyRepository = Get.find<HistoryRepository>();
    _authRepository = Get.find<AuthRepository>();
    AppLogger.d('[HomeController] Initialized');
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      final userId = _authRepository.currentUserId;
      if (userId == null) {
        AppLogger.d('[HomeController] No user ID found');
        return;
      }
      recentScans.value =
          await _historyRepository.getRecentScans(userId, limit: 5);
      totalScans.value = await _historyRepository.getScanCount(userId);
      premiumCount.value = (await _historyRepository.getScansByClass(
              userId, CoffeeClass.premium))
          .length;
      defectCount.value = (await _historyRepository.getScansByClass(
              userId, CoffeeClass.defect))
          .length;
      pendingSyncCount.value =
          await _historyRepository.getPendingSyncCount();
      AppLogger.d(
          '[HomeController] Loaded: ${recentScans.length} recent, ${totalScans.value} total');
    } catch (e) {
      AppLogger.e('[HomeController] Error loading data', err: e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async => loadData();

  void openCamera() => Get.toNamed(AppRoutes.camera);
  void openScanDetail(GradeResult scan) =>
      Get.toNamed(AppRoutes.result, arguments: scan);
}
