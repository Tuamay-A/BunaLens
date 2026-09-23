import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import 'app_routes.dart';

/// Middleware to protect routes that require authentication
/// Redirects to sign-in if user is not authenticated
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // Get repository lazily - only when redirect is called
    final authRepository = Get.find<AuthRepository>();
    
    // Check if user is authenticated
    final isAuthenticated = authRepository.isAuthenticated;

    if (!isAuthenticated) {
      // User not authenticated - redirect to sign in
      return const RouteSettings(name: AppRoutes.signIn);
    }

    // User is authenticated - allow access
    return null;
  }
}

/// Middleware to prevent authenticated users from accessing auth screens
/// Redirects to shell if user is already signed in
class GuestMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // Get repository lazily - only when redirect is called
    final authRepository = Get.find<AuthRepository>();
    
    // Check if user is authenticated
    final isAuthenticated = authRepository.isAuthenticated;

    if (isAuthenticated) {
      // User already authenticated - redirect to shell
      return const RouteSettings(name: AppRoutes.shell);
    }

    // User not authenticated - allow access to auth screens
    return null;
  }
}
