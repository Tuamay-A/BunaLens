import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/validators.dart';
import '../../../data/repositories/auth_repository.dart';

class ForgotPasswordController extends GetxController {
  // Resolved in onInit() — never in field declarations
  late final AuthRepository _authRepository;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final isLoading = false.obs;
  final emailSent = false.obs;

  @override
  void onInit() {
    super.onInit();
    _authRepository = Get.find<AuthRepository>();
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> sendResetEmail() async {
    if (!formKey.currentState!.validate()) return;
    FocusScope.of(Get.context!).unfocus();
    isLoading.value = true;
    try {
      final result =
          await _authRepository.resetPassword(emailController.text.trim());
      if (result.isSuccess) {
        emailSent.value = true;
        Get.snackbar('Email Sent',
            result.message ?? 'Check your inbox for reset instructions',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade600,
            colorText: Colors.white,
            duration: const Duration(seconds: 3));
      } else {
        Get.snackbar('Failed', result.message ?? 'An error occurred',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade600,
            colorText: Colors.white,
            duration: const Duration(seconds: 3));
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          duration: const Duration(seconds: 3));
    } finally {
      isLoading.value = false;
    }
  }

  void goBackToSignIn() => Get.back();
  String? validateEmail(String? v) => Validators.validateEmail(v);
}
