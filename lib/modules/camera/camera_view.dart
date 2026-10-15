import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/l10n/l10n.dart.dart';
import '../../core/l10n/locale_controller.dart';
import 'camera_controller.dart';

class CameraView extends GetView<CameraController> {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    final localeCtrl = Get.find<LocaleController>();

    return Obx(() {
      localeCtrl.locale.value; // reactive rebuild on language change

      return Scaffold(
        appBar: AppBar(title: Text(L.t('camera_title'))),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Obx(() {
            if (controller.isProcessing.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(L.t('analyzing')),
                  ],
                ),
              );
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.coffeeBrown.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.center_focus_strong,
                      size: 72, color: AppColors.coffeeBrown),
                ),
                const SizedBox(height: 24),
                Text(
                  L.t('camera_instruction'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      height: 1.4),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.pickFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(L.t('take_photo')),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: controller.pickFromGallery,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(L.t('pick_gallery')),
                  ),
                ),
              ],
            );
          }),
        ),
      );
    });
  }
}
