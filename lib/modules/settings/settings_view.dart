import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/l10n/l10n.dart.dart';
import '../../core/l10n/locale_controller.dart';
import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final localeCtrl = Get.find<LocaleController>();

    return Obx(() {
      localeCtrl.locale.value;

      return Scaffold(
        appBar: AppBar(title: Text(L.t('settings_title'))),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(L.t('appearance'),
                  style:
                      const TextStyle(fontWeight: FontWeight.w700)),
            ),
            Obx(() => RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: controller.themeMode.value,
                  onChanged: (m) => controller.setTheme(m!),
                  title: Text(L.t('theme_system')),
                )),
            Obx(() => RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: controller.themeMode.value,
                  onChanged: (m) => controller.setTheme(m!),
                  title: Text(L.t('theme_light')),
                )),
            Obx(() => RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: controller.themeMode.value,
                  onChanged: (m) => controller.setTheme(m!),
                  title: Text(L.t('theme_dark')),
                )),
            const Divider(height: 32),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(L.t('data'),
                  style:
                      const TextStyle(fontWeight: FontWeight.w700)),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(L.t('clear_history')),
              onTap: controller.clearHistory,
            ),
          ],
        ),
      );
    });
  }
}
