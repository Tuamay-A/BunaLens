import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import 'about_controller.dart';

class AboutView extends GetView<AboutController> {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
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
                      size: 44, color: Colors.white),
                ),
                const SizedBox(height: 12),
                const Text(
                  'BunaLens',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                Obx(() => Text(
                      'v${controller.version.value}',
                      style: const TextStyle(color: Colors.black54, fontSize: 13),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'BunaLens uses an EfficientNet-B0 convolutional neural network '
            'trained on 8,000 labeled Ethiopian coffee bean images to classify '
            'each bean into one of four categories: Defect, Longberry, '
            'Peaberry, and Premium.',
            style: TextStyle(height: 1.5, fontSize: 14),
          ),
          const SizedBox(height: 16),
          const Text(
            'This app is intended as an advisory tool. It supports — but does '
            'not replace — trained Q-graders.',
            style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 28),
          const ListTile(
            leading: Icon(Icons.school_outlined),
            title: Text('Model: EfficientNet-B0'),
            subtitle: Text('Transfer learning, ImageNet pretrained'),
          ),
          const ListTile(
            leading: Icon(Icons.verified_outlined),
            title: Text('Test accuracy: 87.8%'),
            subtitle: Text('4-class classification on held-out test set'),
          ),
          const ListTile(
            leading: Icon(Icons.memory),
            title: Text('On-device inference'),
            subtitle: Text('TensorFlow Lite — works offline'),
          ),
        ],
      ),
    );
  }
}