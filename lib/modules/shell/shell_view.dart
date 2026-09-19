import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'shell_controller.dart';
import '../home/home_view.dart';
import '../history/history_view.dart';
import '../dashboard/dashboard_view.dart';
import '../profile/profile_view.dart';

class ShellView extends GetView<ShellController> {
  const ShellView({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the 4 main screens
    final screens = [
      const HomeView(),
      const HistoryView(),
      const DashboardView(),
      const ProfileView(),
    ];

    return Obx(() => Scaffold(
      body: IndexedStack(
        index: controller.currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: controller.currentIndex,
        onDestinationSelected: controller.changeTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: controller.currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Get.toNamed('/camera');
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan Bean'),
            )
          : null,
    ));
  }
}
