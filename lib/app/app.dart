import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import '../core/l10n/locale_controller.dart';
import '../core/config/app_theme.dart';
import 'bindings/initial_binding.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

class BunaLensApp extends StatelessWidget {
  const BunaLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Register the locale controller once
    final localeCtrl = Get.put(LocaleController(), permanent: true);

    return Obx(() => GetMaterialApp(
          title: 'BunaLens',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          initialBinding: InitialBinding(),
          initialRoute: AppRoutes.splash,
          getPages: AppPages.pages,
          defaultTransition: Transition.cupertino,
          transitionDuration: const Duration(milliseconds: 250),

          // ----- Localization wiring -----
          locale: localeCtrl.locale.value,
          fallbackLocale: const Locale('en'),
          supportedLocales: const [
            Locale('en'),
            Locale('am'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ));
  }
}