import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
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
  }

  /// Profile header with avatar and email
  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                gradient: AppColors.coffeeGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 40,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Email
            Obx(() => Text(
                  controller.userEmail.value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                )),
            const SizedBox(height: 4),
            // User ID (truncated)
            Obx(() {
              final id = controller.userId.value;
              final truncated = id.length > 16
                  ? '${id.substring(0, 8)}...${id.substring(id.length - 8)}'
                  : id;
              return Text(
                truncated,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.gray,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Sync section
  Widget _buildSyncSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'Sync',
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.darkGray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          child: Column(
            children: [
              Obx(() => ListTile(
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
                    title: const Text('Sync Status'),
                    subtitle: Text(
                      controller.pendingSyncCount.value > 0
                          ? '${controller.pendingSyncCount.value} items pending'
                          : 'All data synced',
                    ),
                    trailing: Obx(() => controller.isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            icon: const Icon(Icons.sync),
                            onPressed: controller.manualSync,
                            tooltip: 'Sync now',
                          )),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  /// Settings section
  Widget _buildSettingsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'Settings',
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.darkGray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.coffeeBrown.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: AppColors.coffeeBrown,
                  ),
                ),
                title: const Text('App Settings'),
                subtitle: const Text('Preferences and configurations'),
                trailing: const Icon(Icons.chevron_right),
                onTap: controller.openSettings,
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                  ),
                ),
                title: const Text('About'),
                subtitle: const Text('App information and credits'),
                trailing: const Icon(Icons.chevron_right),
                onTap: controller.openAbout,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// About section
  Widget _buildAboutSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'About',
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.darkGray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.premium.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.coffee,
                    color: AppColors.premium,
                  ),
                ),
                title: const Text('BunaLens'),
                subtitle:
                    Obx(() => Text('Version ${controller.appVersion.value}')),
              ),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.copyright, color: AppColors.gray),
                title: Text('© 2026 BunaLens'),
                subtitle: Text('Coffee bean quality grading app'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Sign out button
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
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
            label: Text(
              controller.isLoading.value ? 'Signing out...' : 'Sign Out',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ));
  }
}
