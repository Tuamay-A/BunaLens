import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Appearance', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          Obx(() => RadioListTile<ThemeMode>(
            value: ThemeMode.system,
            groupValue: controller.themeMode.value,
            onChanged: (m) => controller.setTheme(m!),
            title: const Text('System'),
          )),
          Obx(() => RadioListTile<ThemeMode>(
            value: ThemeMode.light,
            groupValue: controller.themeMode.value,
            onChanged: (m) => controller.setTheme(m!),
            title: const Text('Light'),
          )),
          Obx(() => RadioListTile<ThemeMode>(
            value: ThemeMode.dark,
            groupValue: controller.themeMode.value,
            onChanged: (m) => controller.setTheme(m!),
            title: const Text('Dark'),
          )),
          const Divider(height: 32),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text('Data', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Clear history'),
            onTap: controller.clearHistory,
          ),
        ],
      ),
    );
  }
}