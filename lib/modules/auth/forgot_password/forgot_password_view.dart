import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'forgot_password_controller.dart';
import '../../../core/l10n/l10n.dart.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: controller.goBackToSignIn,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Obx(
            () => controller.emailSent.value
                ? _buildSuccessView(context)
                : _buildFormView(context),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),

          // Icon
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_reset,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            L.t('auth_forgot_password'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            'Enter your email address and we\'ll send you instructions to reset your password.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Email field
          TextFormField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: L.t('auth_email'),
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: controller.validateEmail,
            onFieldSubmitted: (_) => controller.sendResetEmail(),
            enabled: !controller.isLoading.value,
          ),

          const SizedBox(height: 24),

          // Send button
          Obx(
            () => ElevatedButton(
              onPressed:
                  controller.isLoading.value ? null : controller.sendResetEmail,
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
                      L.t('auth_send_reset'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Back to sign in
          TextButton(
            onPressed: controller.goBackToSignIn,
            child: Text(L.t('auth_back_to_sign_in')),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 48),

        // Success icon
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green.shade600,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Success title
        Text(
          L.t('auth_reset_email_sent'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Text(
          L.t('auth_check_inbox'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // Back to sign in button
        ElevatedButton(
          onPressed: controller.goBackToSignIn,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            L.t('auth_back_to_sign_in'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
