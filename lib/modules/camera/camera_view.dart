import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import 'camera_controller.dart';

class CameraView extends GetView<CameraController> {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan a bean')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Obx(() {
          if (controller.isProcessing.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyzing…'),
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
              const Text(
                'Place one bean in the center\nof the frame, then capture.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.4),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.pickFromCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take a photo'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: controller.pickFromGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Pick from gallery'),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}