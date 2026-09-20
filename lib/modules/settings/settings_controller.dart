import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/logger.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/history_repository.dart';

class SettingsController extends GetxController {
  // Resolved in onInit() — never in field declarations
  late final HistoryRepository _historyRepository;
  late final AuthRepository _authRepository;

  final themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    _historyRepository = Get.find<HistoryRepository>();
    _authRepository = Get.find<AuthRepository>();
  }

  void setTheme(ThemeMode m) {
    themeMode.value = m;
    Get.changeThemeMode(m);
  }

  Future<void> clearHistory() async {
    try {
      final userId = _authRepository.currentUserId;
      if (userId == null) {
        Get.snackbar('Error', 'Not signed in.',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      await _historyRepository.deleteAllScans(userId);
      Get.snackbar('Done', 'History cleared.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
    } catch (e) {
      AppLogger.e('[SettingsController] Error clearing history', err: e);
      Get.snackbar('Error', 'Failed to clear history.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
