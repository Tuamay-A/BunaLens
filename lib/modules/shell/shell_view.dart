import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/l10n/l10n.dart.dart';
import '../../core/l10n/locale_controller.dart';
import 'shell_controller.dart';
import '../home/home_view.dart';
import '../history/history_view.dart';
import '../dashboard/dashboard_view.dart';
import '../profile/profile_view.dart';

class ShellView extends GetView<ShellController> {
  const ShellView({super.key});

  @override
  Widget build(BuildContext context) {
    // Observe locale so bottom-nav labels re-render when language changes
    final localeCtrl = Get.find<LocaleController>();

    final screens = const [
      HomeView(),
      HistoryView(),
      DashboardView(),
      ProfileView(),
    ];

    return Obx(() {
      // Reading localeCtrl.locale.value here registers this Obx
      // as a listener — any language change rebuilds the nav labels.
      localeCtrl.locale.value;

      return Scaffold(
        body: IndexedStack(
          index: controller.currentIndex,
          children: screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.currentIndex,
          onDestinationSelected: controller.changeTab,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: L.t('home_title'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.history_outlined),
              selectedIcon: const Icon(Icons.history),
              label: L.t('history_title'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.dashboard_outlined),
              selectedIcon: const Icon(Icons.dashboard),
              label: L.t('dashboard_title'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: L.t('profile_title'),
            ),
          ],
        ),
        floatingActionButton: controller.currentIndex == 0
            ? FloatingActionButton.extended(
                onPressed: () => Get.toNamed('/camera'),
                icon: const Icon(Icons.camera_alt),
                label: Text(L.t('scan_bean')),
              )
            : null,
      );
    });
  }
}
