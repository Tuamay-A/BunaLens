import 'package:buna_lens/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/validators.dart';
import '../../../data/repositories/auth_repository.dart';

class SignInController extends GetxController {
  // Resolved in onInit() — never in field declarations
  late final AuthRepository _authRepository;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final obscurePassword = true.obs;

  @override
  void onInit() {
    super.onInit();
    _authRepository = Get.find<AuthRepository>();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> signIn() async {
    if (!formKey.currentState!.validate()) return;
    FocusScope.of(Get.context!).unfocus();
    isLoading.value = true;
    try {
      final result = await _authRepository.signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      if (result.isSuccess) {
        Get.snackbar('Success', result.message ?? 'Welcome back!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade600,
            colorText: Colors.white,
            duration: const Duration(seconds: 2));
        Get.offAllNamed(AppRoutes.shell);
      } else {
        Get.snackbar('Sign In Failed', result.message ?? 'An error occurred',
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

  void goToSignUp() => Get.toNamed('/sign-up');
  void goToForgotPassword() => Get.toNamed('/forgot-password');

  String? validateEmail(String? value) => Validators.validateEmail(value);
  String? validatePassword(String? value) =>
      (value == null || value.isEmpty) ? 'Password is required' : null;
}
