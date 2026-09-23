abstract class AppRoutes {
  AppRoutes._();

  // Core routes
  static const splash   = '/';
  static const onboarding = '/onboarding';
  
  // Auth routes (no auth required)
  static const signIn          = '/sign-in';
  static const signUp          = '/sign-up';
  static const forgotPassword  = '/forgot-password';
  
  // Protected routes (auth required)
  static const shell    = '/shell';  // Bottom navigation shell
  static const home     = '/home';
  static const camera   = '/camera';
  static const result   = '/result';
  static const history  = '/history';
  static const dashboard = '/dashboard';
  static const profile  = '/profile';
  static const about    = '/about';
  static const settings = '/settings';
}