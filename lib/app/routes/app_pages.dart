import 'package:get/get.dart';

import 'app_routes.dart';
import 'auth_middleware.dart';

// Splash
import '../../modules/splash/splash_binding.dart';
import '../../modules/splash/splash_view.dart';

// Onboarding
import '../../modules/onboarding/onboarding_binding.dart';
import '../../modules/onboarding/onboarding_view.dart';

// Auth
import '../../modules/auth/sign_in/sign_in_binding.dart';
import '../../modules/auth/sign_in/sign_in_view.dart';
import '../../modules/auth/sign_up/sign_up_binding.dart';
import '../../modules/auth/sign_up/sign_up_view.dart';
import '../../modules/auth/forgot_password/forgot_password_binding.dart';
import '../../modules/auth/forgot_password/forgot_password_view.dart';

// Shell (Bottom Navigation)
import '../../modules/shell/shell_binding.dart';
import '../../modules/shell/shell_view.dart';

// Main app
import '../../modules/home/home_binding.dart';
import '../../modules/home/home_view.dart';
import '../../modules/camera/camera_binding.dart';
import '../../modules/camera/camera_view.dart';
import '../../modules/result/result_binding.dart';
import '../../modules/result/result_view.dart';
import '../../modules/history/history_binding.dart';
import '../../modules/history/history_view.dart';
import '../../modules/dashboard/dashboard_binding.dart';
import '../../modules/dashboard/dashboard_view.dart';
import '../../modules/profile/profile_binding.dart';
import '../../modules/profile/profile_view.dart';
import '../../modules/about/about_binding.dart';
import '../../modules/about/about_view.dart';
import '../../modules/settings/settings_binding.dart';
import '../../modules/settings/settings_view.dart';

abstract class AppPages {
  AppPages._();

  static final pages = <GetPage>[
    // Splash (no middleware - handles routing logic internally)
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),

    // Onboarding (guest only)
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),

    // Auth routes (guest only - redirect to shell if authenticated)
    GetPage(
      name: AppRoutes.signIn,
      page: () => const SignInView(),
      binding: SignInBinding(),
      middlewares: [GuestMiddleware()],
    ),
    GetPage(
      name: AppRoutes.signUp,
      page: () => const SignUpView(),
      binding: SignUpBinding(),
      middlewares: [GuestMiddleware()],
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
      middlewares: [GuestMiddleware()],
    ),

    // Protected routes (auth required)
    
    // Shell with bottom navigation (main entry point after auth)
    GetPage(
      name: AppRoutes.shell,
      page: () => const ShellView(),
      bindings: [
        ShellBinding(),
        HomeBinding(),
        HistoryBinding(),
        DashboardBinding(),
        ProfileBinding(),
      ],
      middlewares: [AuthMiddleware()],
    ),
    
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.camera,
      page: () => const CameraView(),
      binding: CameraBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.result,
      page: () => const ResultView(),
      binding: ResultBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.history,
      page: () => const HistoryView(),
      binding: HistoryBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.about,
      page: () => const AboutView(),
      binding: AboutBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}