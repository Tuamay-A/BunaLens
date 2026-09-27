// GetX controller that manages the current language.
// Persists the choice via SharedPreferences.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends GetxController {
  static const _prefsKey = 'buna_lens_language';

  // Reactive current locale — 'en' or 'am'
  final locale = const Locale('en').obs;

  @override
  void onInit() {
    super.onInit();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey) ?? 'en';
    locale.value = Locale(code);
    Get.updateLocale(locale.value);
  }

  Future<void> setLocale(String languageCode) async {
    locale.value = Locale(languageCode);
    Get.updateLocale(locale.value);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, languageCode);
  }

  bool get isAmharic => locale.value.languageCode == 'am';
  bool get isEnglish => locale.value.languageCode == 'en';
}