
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/utils/logger.dart';
import '../../data/repositories/auth_repository.dart';
import '../onboarding/onboarding_controller.dart';

class SplashController extends GetxController {
  // Lazy lookup: resolved on first use, not at construction time.
  // This prevents a crash if AuthRepository is registered after this controller.
  AuthRepository get _authRepository => Get.find<AuthRepository>();

  bool _isNavigating = false;

  @override
  void onInit() {
    super.onInit();
    AppLogger.d('[Splash] onInit');
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      // Brief pause so the splash branding is visible before navigating.
      await Future.delayed(const Duration(milliseconds: 600));

      AppLogger.d('[Splash] Checking authentication state...');

      final user = await _authRepository.restoreSession();

      if (user != null) {
        AppLogger.d('[Splash] User authenticated: ${user.email}');
        if (Get.context != null && Get.currentRoute != AppRoutes.shell) {
          Get.offAllNamed(AppRoutes.shell);
          return;
        }
      }

      AppLogger.d('[Splash] No valid session');
      final hasCompletedOnboarding =
          await OnboardingController.hasCompletedOnboarding();

      if (hasCompletedOnboarding) {
        AppLogger.d('[Splash] Onboarding completed, navigating to sign in');
        if (Get.context != null && Get.currentRoute != AppRoutes.signIn) {
          Get.offAllNamed(AppRoutes.signIn);
          return;
        }
      } else {
        AppLogger.d('[Splash] First time user, showing onboarding');
        if (Get.context != null && Get.currentRoute != AppRoutes.onboarding) {
          Get.offAllNamed(AppRoutes.onboarding);
          return;
        }
      }
    } catch (e) {
      AppLogger.e('[Splash] Error during initialization', err: e);
      if (Get.context != null && Get.currentRoute != AppRoutes.signIn) {
        Get.offAllNamed(AppRoutes.signIn);
      }
    }
  }
}