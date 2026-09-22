import 'package:get/get.dart';

import '../../core/utils/logger.dart';
import '../../data/models/grade_result.dart';
import '../../data/models/coffee_class.dart';
import '../../data/repositories/history_repository.dart';
import '../../data/repositories/auth_repository.dart';

enum ViewMode { list, grid }

class HistoryController extends GetxController {
  // Resolved in onInit() — never in field declarations
  late final HistoryRepository _historyRepository;
  late final AuthRepository _authRepository;

  final allScans = <GradeResult>[].obs;
  final filteredScans = <GradeResult>[].obs;
  final isLoading = false.obs;
  final viewMode = ViewMode.list.obs;
  final searchQuery = ''.obs;
  final selectedFilter = Rx<CoffeeClass?>(null);
  final isSyncing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _historyRepository = Get.find<HistoryRepository>();
    _authRepository = Get.find<AuthRepository>();
    AppLogger.d('[HistoryController] Initialized');
    loadScans();
  }

  Future<void> loadScans() async {
    try {
      isLoading.value = true;
      final userId = _authRepository.currentUserId;
      if (userId == null) {
        AppLogger.d('[HistoryController] No user ID found');
        return;
      }
      allScans.value = await _historyRepository.getAllScans(userId);
      _applyFilters();
      AppLogger.d('[HistoryController] Loaded ${allScans.length} scans');
    } catch (e) {
      AppLogger.e('[HistoryController] Error loading scans', err: e);
      Get.snackbar('Error', 'Failed to load scan history',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    try {
      isSyncing.value = true;
      final userId = _authRepository.currentUserId;
      if (userId == null) return;
      await _historyRepository.triggerManualSync(userId);
      await loadScans();
      Get.snackbar('Synced', 'History updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
    } catch (e) {
      AppLogger.e('[HistoryController] Error syncing', err: e);
      Get.snackbar('Sync failed', 'Could not reach server. Showing local data.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3));
    } finally {
      isSyncing.value = false;
    }
  }

  void toggleViewMode() {
    viewMode.value =
        viewMode.value == ViewMode.list ? ViewMode.grid : ViewMode.list;
  }

  void search(String query) {
    searchQuery.value = query.toLowerCase();
    _applyFilters();
  }

  void filterByClass(CoffeeClass? coffeeClass) {
    selectedFilter.value = coffeeClass;
    _applyFilters();
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedFilter.value = null;
    _applyFilters();
  }

  void _applyFilters() {
    var results = allScans.toList();
    if (selectedFilter.value != null) {
      results = results
          .where((s) => s.predictions.first.label == selectedFilter.value)
          .toList();
    }
    if (searchQuery.value.isNotEmpty) {
      results = results.where((s) {
        final cls = s.predictions.first.label.display.toLowerCase();
        final n = (s.notes ?? '').toLowerCase();
        return cls.contains(searchQuery.value) ||
            n.contains(searchQuery.value);
      }).toList();
    }
    filteredScans.value = results;
  }

  Future<void> clearHistory() async {
    try {
      final userId = _authRepository.currentUserId;
      if (userId == null) return;
      await _historyRepository.deleteAllScans(userId);
      await loadScans();
      Get.snackbar('Cleared', 'History cleared successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
    } catch (e) {
      AppLogger.e('[HistoryController] Error clearing history', err: e);
      Get.snackbar('Error', 'Failed to clear history',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void openScanDetail(GradeResult scan) =>
      Get.toNamed('/result', arguments: scan);
}
