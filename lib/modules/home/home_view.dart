import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/l10n/l10n.dart.dart';
import '../../core/l10n/locale_controller.dart';
import '../../data/models/grade_result.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final localeCtrl = Get.find<LocaleController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('BunaLens'),
        elevation: 0,
        actions: [
          // Language dropdown
          Obx(() {
            final isAm = localeCtrl.isAmharic;
            return PopupMenuButton<String>(
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isAm ? '🇪🇹' : '🇺🇸',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const Icon(Icons.arrow_drop_down, color: AppColors.white),
                ],
              ),
              onSelected: (code) => localeCtrl.setLocale(code),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'en',
                  child: Row(
                    children: [
                      const Text('🇺🇸', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      const Text('English'),
                      if (!isAm) ...[
                        const Spacer(),
                        const Icon(Icons.check,
                            size: 18, color: AppColors.coffeeBrown),
                      ],
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'am',
                  child: Row(
                    children: [
                      const Text('🇪🇹', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      const Text('አማርኛ'),
                      if (isAm) ...[
                        const Spacer(),
                        const Icon(Icons.check,
                            size: 18, color: AppColors.coffeeBrown),
                      ],
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: Obx(() {
          if (controller.isLoading.value && controller.recentScans.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeroSection(context),
              const SizedBox(height: 24),
              _buildQuickStats(context),
              const SizedBox(height: 24),
              _buildRecentScansSection(context),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final theme = Theme.of(context);
    final hour = DateTime.now().hour;
    final timeKey = hour < 12
        ? 'good_morning'
        : hour < 17
            ? 'good_afternoon'
            : 'good_evening';

    return Obx(() {
      final name = controller.userName.value;
      final greeting = name.isNotEmpty
          ? '${L.t(timeKey)}, $name'
          : L.t(timeKey);

      return Container(
        decoration: BoxDecoration(
          gradient: AppColors.coffeeGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.coffeeBrown.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              L.t('hero_body'),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.cream,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.openCamera,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.coffeeBrown,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.camera_alt, size: 24),
                label: Text(
                  L.t('scan_bean'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQuickStats(BuildContext context) {
    return Obx(() => Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.coffee,
                label: L.t('dashboard_stats_total'),
                value: controller.totalScans.value.toString(),
                color: AppColors.coffeeBrown,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.stars,
                label: L.t('class_premium'),
                value: controller.premiumCount.value.toString(),
                color: AppColors.premium,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.warning_amber_rounded,
                label: L.t('class_defect'),
                value: controller.defectCount.value.toString(),
                color: AppColors.defect,
              ),
            ),
          ],
        ));
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentScansSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              L.t('recent_scans'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Obx(() {
              final pending = controller.pendingSyncCount.value;
              if (pending > 0) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_upload,
                          size: 14, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        '$pending ${L.t("sync_syncing")}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.recentScans.isEmpty) {
            return _buildEmptyState(context);
          }
          return Column(
            children: controller.recentScans
                .map((scan) => _buildRecentScanCard(context, scan))
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildRecentScanCard(BuildContext context, GradeResult scan) {
    final theme = Theme.of(context);
    final topPrediction = scan.predictions.first;
    final confidence =
        (topPrediction.probability * 100).toStringAsFixed(1);
    final classColor = AppColors.getClassColor(topPrediction.label.name);
    final confidenceColor =
        AppColors.getConfidenceColor(topPrediction.probability);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => controller.openScanDetail(scan),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: classColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(topPrediction.label.icon,
                    color: classColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      L.className(topPrediction.label.name),
                      style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM d, yyyy • HH:mm')
                          .format(scan.createdAt),
                      style: theme.textTheme.bodySmall,
                    ),
                    if (scan.isOod) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.ood.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          L.t('not_a_bean'),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.ood,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: confidenceColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$confidence%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: confidenceColor,
                      ),
                    ),
                  ),
                  if (!scan.isSynced) ...[
                    const SizedBox(height: 8),
                    const Icon(Icons.cloud_off,
                        size: 16, color: AppColors.gray),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(48),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.coffee_outlined,
              size: 64, color: AppColors.gray.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            L.t('no_scans_yet'),
            style: theme.textTheme.titleMedium
                ?.copyWith(color: AppColors.darkGray),
          ),
          const SizedBox(height: 8),
          Text(
            L.t('hero_body'),
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: AppColors.gray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
