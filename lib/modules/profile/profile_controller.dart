import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/logger.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/history_repository.dart';
import '../../app/routes/app_routes.dart';

class ProfileController extends GetxController {
  // Resolved in onInit() — never in field declarations
  late final AuthRepository _authRepository;
  late final HistoryRepository _historyRepository;

  final userEmail = ''.obs;
  final userId = ''.obs;
  final appVersion = ''.obs;
  final isLoading = false.obs;
  final pendingSyncCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _authRepository = Get.find<AuthRepository>();
    _historyRepository = Get.find<HistoryRepository>();
    AppLogger.d('[ProfileController] Initialized');
    loadUserInfo();
    loadAppInfo();
    loadSyncStatus();
  }

  void loadUserInfo() {
    final id = _authRepository.currentUserId;
    if (id != null && id.isNotEmpty) {
      userId.value = id;
      // email is on the Supabase User object — fetch via datasource
      final session = _authRepository.currentSession;
      userEmail.value = session?.user.email ?? '';
    }
  }

  Future<void> loadAppInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      appVersion.value = '${info.version} (${info.buildNumber})';
    } catch (e) {
      AppLogger.e('[ProfileController] Error loading app info', err: e);
      appVersion.value = 'Unknown';
    }
  }

  Future<void> loadSyncStatus() async {
    try {
      pendingSyncCount.value =
          await _historyRepository.getPendingSyncCount();
    } catch (e) {
      AppLogger.e('[ProfileController] Error loading sync status', err: e);
    }
  }

  Future<void> signOut({bool clearLocalData = false}) async {
    try {
      isLoading.value = true;
      await _authRepository.signOut(clearLocalData: clearLocalData);
      Get.offAllNamed(AppRoutes.signIn);
      Get.snackbar(
        'Signed Out',
        clearLocalData
            ? 'Signed out and local data cleared'
            : 'Signed out successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      AppLogger.e('[ProfileController] Error signing out', err: e);
      Get.snackbar('Error', 'Failed to sign out',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> showSignOutDialog() async {
    final result = await Get.dialog<String>(const _SignOutDialog());
    if (result == 'signout') await signOut(clearLocalData: false);
    if (result == 'signout_clear') await signOut(clearLocalData: true);
  }

  void openAbout() => Get.toNamed(AppRoutes.about);
  void openSettings() => Get.toNamed(AppRoutes.settings);

  Future<void> manualSync() async {
    try {
      final id = _authRepository.currentUserId;
      if (id == null) return;
      isLoading.value = true;
      final ok = await _historyRepository.triggerManualSync(id);
      if (ok) {
        await loadSyncStatus();
        Get.snackbar('Synced', 'Data synchronized successfully',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2));
      } else {
        Get.snackbar('Sync Failed', 'Could not sync data',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      AppLogger.e('[ProfileController] Error syncing', err: e);
      Get.snackbar('Error', 'Failed to sync',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}

class _SignOutDialog extends StatelessWidget {
  const _SignOutDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sign Out'),
      content: const Text('How would you like to sign out?'),
      actions: [
        TextButton(
            onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(
            onPressed: () => Get.back(result: 'signout'),
            child: const Text('Sign Out')),
        TextButton(
            onPressed: () => Get.back(result: 'signout_clear'),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sign Out & Clear Data')),
      ],
    );
  }
}
