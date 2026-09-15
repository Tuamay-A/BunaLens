import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'sign_up_controller.dart';
import '../../../core/l10n/l10n.dart.dart';

class SignUpView extends GetView<SignUpController> {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: controller.goToSignIn,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  L.t('auth_sign_up'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Create your BunaLens account',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),

                const SizedBox(height: 32),

                // Display name field
                TextFormField(
                  controller: controller.displayNameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: L.t('auth_display_name'),
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: controller.validateDisplayName,
                  enabled: !controller.isLoading.value,
                ),

                const SizedBox(height: 16),

                // Email field
                TextFormField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: L.t('auth_email'),
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: controller.validateEmail,
                  enabled: !controller.isLoading.value,
                ),

                const SizedBox(height: 16),

                // Password field
                Obx(
                  () => TextFormField(
                    controller: controller.passwordController,
                    obscureText: controller.obscurePassword.value,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: L.t('auth_password'),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscurePassword.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: controller.validatePassword,
                    onChanged: (_) => controller.update(),
                    enabled: !controller.isLoading.value,
                  ),
                ),

                const SizedBox(height: 16),

                // Confirm password field
                Obx(
                  () => TextFormField(
                    controller: controller.confirmPasswordController,
                    obscureText: controller.obscureConfirmPassword.value,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: L.t('auth_confirm_password'),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscureConfirmPassword.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: controller.toggleConfirmPasswordVisibility,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: controller.validateConfirmPassword,
                    onFieldSubmitted: (_) => controller.signUp(),
                    enabled: !controller.isLoading.value,
                  ),
                ),

                const SizedBox(height: 24),

                // Language selector
                Row(
                  children: [
                    Text(
                      L.t('language'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(width: 16),
                    Obx(
                      () => SegmentedButton<String>(
                        segments: [
                          ButtonSegment(
                            value: 'en',
                            label: Text(L.t('lang_english')),
                          ),
                          ButtonSegment(
                            value: 'am',
                            label: Text(L.t('lang_amharic')),
                          ),
                        ],
                        selected: {controller.selectedLanguage.value},
                        onSelectionChanged: (Set<String> newSelection) {
                          controller.setLanguage(newSelection.first);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Sign up button
                Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : controller.signUp,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            L.t('auth_sign_up_btn'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Sign in prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      L.t('auth_have_account'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: controller.goToSignIn,
                      child: Text(
                        L.t('auth_sign_in'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
