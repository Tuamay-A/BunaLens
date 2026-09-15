import 'package:buna_lens/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/validators.dart';
import '../../../data/repositories/auth_repository.dart';

class SignUpController extends GetxController {
  // Resolved in onInit() — never in field declarations
  late final AuthRepository _authRepository;

  final formKey = GlobalKey<FormState>();
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final selectedLanguage = 'en'.obs;

  @override
  void onInit() {
    super.onInit();
    _authRepository = Get.find<AuthRepository>();
    final locale = Get.locale?.languageCode ?? 'en';
    selectedLanguage.value = locale == 'am' ? 'am' : 'en';
  }

  @override
  void onClose() {
    displayNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;
  void toggleConfirmPasswordVisibility() =>
      obscureConfirmPassword.value = !obscureConfirmPassword.value;
  void setLanguage(String lang) => selectedLanguage.value = lang;

  Future<void> signUp() async {
    if (!formKey.currentState!.validate()) return;
    FocusScope.of(Get.context!).unfocus();
    isLoading.value = true;
    try {
      final result = await _authRepository.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
        displayName: displayNameController.text.trim(),
        preferredLanguage: selectedLanguage.value,
      );
      if (result.isSuccess) {
        if (result.user != null) {
          Get.snackbar('Welcome!',
              result.message ?? 'Account created successfully',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.shade600,
              colorText: Colors.white,
              duration: const Duration(seconds: 2));
          Get.offAllNamed(AppRoutes.shell);
        } else {
          await Get.dialog<void>(
            AlertDialog(
              title: const Row(children: [
                Icon(Icons.mark_email_unread_outlined, color: Colors.orange),
                SizedBox(width: 10),
                Text('Check your email'),
              ]),
              content: Text(
                'We sent a confirmation link to\n'
                '${emailController.text.trim()}\n\n'
                'Open the link to activate your account, then sign in.',
              ),
              actions: [
                TextButton(
                    onPressed: () => Get.back(), child: const Text('Got it'))
              ],
            ),
            barrierDismissible: false,
          );
          Get.offAllNamed(AppRoutes.signIn);
        }
      } else {
        Get.snackbar('Sign Up Failed', result.message ?? 'An error occurred',
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

  void goToSignIn() => Get.back();

  String? validateDisplayName(String? v) =>
      Validators.validateDisplayName(v);
  String? validateEmail(String? v) => Validators.validateEmail(v);
  String? validatePassword(String? v) => Validators.validatePassword(v);
  String? validateConfirmPassword(String? v) =>
      Validators.validatePasswordConfirmation(passwordController.text, v);
  int getPasswordStrength() =>
      Validators.getPasswordStrength(passwordController.text);
}
