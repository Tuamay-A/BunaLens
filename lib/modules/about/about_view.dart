import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/l10n/l10n.dart.dart';
import '../../core/l10n/locale_controller.dart';
import 'about_controller.dart';

class AboutView extends GetView<AboutController> {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final localeCtrl = Get.find<LocaleController>();

    return Obx(() {
      localeCtrl.locale.value;

      return Scaffold(
        appBar: AppBar(title: Text(L.t('about_title'))),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.coffeeBrown,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.coffee_rounded,
                        size: 44, color: AppColors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(L.t('app_name'),
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800)),
                  Obx(() => Text('v${controller.version.value}',
                      style: const TextStyle(
                          color: Colors.black54, fontSize: 13))),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(L.t('about_body'),
                style:
                    const TextStyle(height: 1.5, fontSize: 14)),
            const SizedBox(height: 16),
            Text(L.t('about_disclaimer'),
                style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    height: 1.5)),
            const SizedBox(height: 28),
            ListTile(
              leading: const Icon(Icons.school_outlined),
              title: Text(L.t('model_arch')),
              subtitle: Text(L.t('model_arch_sub')),
            ),
            ListTile(
              leading: const Icon(Icons.verified_outlined),
              title: Text(L.t('model_acc')),
              subtitle: Text(L.t('model_acc_sub')),
            ),
            ListTile(
              leading: const Icon(Icons.memory),
              title: Text(L.t('on_device')),
              subtitle: Text(L.t('on_device_sub')),
            ),
          ],
        ),
      );
    });
  }
}
