import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/l10n/l10n.dart.dart';
import 'splash_controller.dart';

/// Splash screen — pure UI only.
/// All navigation logic lives in [SplashController].
class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.coffeeBrown,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.coffee_rounded,
                  size: 52, color: AppColors.white),
            ),
            const SizedBox(height: 20),

            // App name — always "BunaLens" (brand, not translated)
            Text(
              L.t('app_name'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.espresso,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),

            // Tagline — translated
            Text(
              L.t('app_tagline'),
              style: const TextStyle(
                  color: AppColors.darkGray, fontSize: 13),
            ),
            const SizedBox(height: 32),

            // Loading indicator
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.coffeeBrown),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
