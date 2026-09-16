// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/routes/app_routes.dart';
import '../../core/utils/logger.dart';

class OnboardingController extends GetxController {
  static const String _onboardingKey = 'onboarding_completed';

  final pageController = PageController();
  final currentPage = 0.obs;

  final List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Welcome to BunaLens',
      description: 'AI-powered Ethiopian coffee bean quality grading at your fingertips',
      icon: Icons.coffee,
      color: const Color(0xFF6F4E37),
    ),
    OnboardingPage(
      title: 'Scan & Grade',
      description: 'Take a photo of your coffee beans and get instant quality analysis with detailed predictions',
      icon: Icons.camera_alt,
      color: const Color(0xFF8B6F47),
    ),
    OnboardingPage(
      title: 'Track & Sync',
      description: 'Keep track of all your scans with automatic cloud sync and detailed statistics',
      icon: Icons.cloud_done,
      color: const Color(0xFFA67B5B),
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    AppLogger.d('[OnboardingController] Initialized');
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  // Check if onboarding has been completed
  static Future<bool> hasCompletedOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingKey) ?? false;
    } catch (e) {
      AppLogger.d('[OnboardingController] Error checking onboarding status: $e');
      return false;
    }
  }

  // Mark onboarding as completed
  static Future<void> markOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
    } catch (e) {
      AppLogger.d('[OnboardingController] Error marking onboarding: $e');
    }
  }

  // Go to next page
  void nextPage() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      completeOnboarding();
    }
  }

  // Skip onboarding
  void skip() {
    completeOnboarding();
  }

  // Complete onboarding and navigate to sign in
  Future<void> completeOnboarding() async {
    await markOnboardingCompleted();
    Get.offAllNamed(AppRoutes.signIn);
  }

  // Update current page index
  void onPageChanged(int index) {
    currentPage.value = index;
  }
}

// Onboarding page data model
class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

