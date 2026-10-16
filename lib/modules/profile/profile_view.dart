import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/l10n/l10n.dart.dart';
import '../../core/l10n/locale_controller.dart';
import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final localeCtrl = Get.find<LocaleController>();

    return Obx(() {
      localeCtrl.locale.value; // reactive locale observer

      return Scaffold(
        appBar: AppBar(title: Text(L.t('profile_title'))),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 24),
            _buildSyncSection(context),
            const SizedBox(height: 16),
            _buildSettingsSection(context),
            const SizedBox(height: 16),
            _buildAboutSection(context),
            const SizedBox(height: 24),
            _buildSignOutButton(context),
          ],
        ),
      );
    });
  }

  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                  gradient: AppColors.coffeeGradient,
                  shape: BoxShape.circle),
              child: const Icon(Icons.person,
                  size: 40, color: AppColors.white),
            ),
            const SizedBox(height: 16),
            Obx(() => Text(
                  controller.userEmail.value,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                )),
            const SizedBox(height: 4),
            Obx(() {
              final id = controller.userId.value;
              final truncated = id.length > 16
                  ? '${id.substring(0, 8)}...${id.substring(id.length - 8)}'
                  : id;
              return Text(truncated,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.gray));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(L.t('sync_synced'),
              style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.darkGray,
                  fontWeight: FontWeight.w600)),
        ),
        Card(
          child: Obx(() => ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: controller.pendingSyncCount.value > 0
                        ? AppColors.warning.withOpacity(0.15)
                        : AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    controller.pendingSyncCount.value > 0
                        ? Icons.cloud_upload
                        : Icons.cloud_done,
                    color: controller.pendingSyncCount.value > 0
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                ),
                title: Text(L.t('profile_cloud_sync')),
                subtitle: Text(
                  controller.pendingSyncCount.value > 0
                      ? '${controller.pendingSyncCount.value} ${L.t("sync_syncing")}'
                      : L.t('sync_synced'),
                ),
                trailing: Obx(() => controller.isLoading.value
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child:
                            CircularProgressIndicator(strokeWidth: 2))
                    : IconButton(
                        icon: const Icon(Icons.sync),
                        onPressed: controller.manualSync,
                        tooltip: L.t('settings_force_sync'),
                      )),
              )),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(L.t('settings_title'),
              style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.darkGray,
                  fontWeight: FontWeight.w600)),
        ),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: AppColors.coffeeBrown.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.settings,
                      color: AppColors.coffeeBrown),
                ),
                title: Text(L.t('settings_title')),
                subtitle: Text(L.t('appearance')),
                trailing: const Icon(Icons.chevron_right),
                onTap: controller.openSettings,
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.info_outline,
                      color: AppColors.info),
                ),
                title: Text(L.t('about_title')),
                subtitle: Text(L.t('app_tagline')),
                trailing: const Icon(Icons.chevron_right),
                onTap: controller.openAbout,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(L.t('about_title'),
              style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.darkGray,
                  fontWeight: FontWeight.w600)),
        ),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: AppColors.premium.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.coffee,
                      color: AppColors.premium),
                ),
                title: Text(L.t('app_name')),
                subtitle: Obx(() => Text(
                    'v${controller.appVersion.value}')),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.copyright,
                    color: AppColors.gray),
                title: const Text('© 2026 BunaLens'),
                subtitle: Text(L.t('app_tagline')),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return Obx(() => SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: controller.isLoading.value
                ? null
                : controller.showSignOutDialog,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: controller.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.logout),
            label: Text(
              controller.isLoading.value
                  ? L.t('sync_syncing')
                  : L.t('auth_sign_out'),
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ));
  }
}
