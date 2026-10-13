import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/l10n/l10n.dart.dart';
import '../../core/l10n/locale_controller.dart';
import 'onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final localeCtrl = Get.find<LocaleController>();

    return Obx(() {
      localeCtrl.locale.value; // reactive rebuild on language change

      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Obx(() => controller.currentPage.value <
                            controller.pages.length - 1
                        ? TextButton(
                            onPressed: controller.skip,
                            child: Text(L.t('onboarding_skip'),
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                          )
                        : const SizedBox.shrink()),
                  ],
                ),
              ),

              // Page view
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  itemCount: controller.pages.length,
                  itemBuilder: (_, index) =>
                      _buildPage(context, controller.pages[index]),
                ),
              ),

              // Indicators + button
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            controller.pages.length,
                            (i) => _buildIndicator(
                                i, controller.currentPage.value),
                          ),
                        )),
                    const SizedBox(height: 32),
                    Obx(() => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.nextPage,
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16)),
                            child: Text(
                              controller.currentPage.value <
                                      controller.pages.length - 1
                                  ? L.t('onboarding_next')
                                  : L.t('onboarding_done'),
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPage(BuildContext context, OnboardingPage page) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [page.color, page.color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: page.color.withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8)),
              ],
            ),
            child:
                Icon(page.icon, size: 80, color: AppColors.white),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700, color: page.color),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.darkGray, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index, int currentPage) {
    final isActive = index == currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.coffeeBrown
            : AppColors.gray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
