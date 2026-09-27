// Tiny localization helper.
// Usage: L.t('scan_bean')  → returns the string for the current locale.

import 'package:get/get.dart';
import 'app_strings.dart';

class L {
  L._();

  // Translate a key for the currently active locale.
  // Falls back to English if the key isn't defined for the locale.
  static String t(String key) {
    final code = Get.locale?.languageCode ?? 'en';
    final lang = AppStrings.values[code] ?? AppStrings.values['en']!;
    return lang[key] ?? AppStrings.values['en']![key] ?? key;
  }

  // Translate a class name (defect, longberry, peaberry, premium)
  // using its fixed index from the model.
  static String className(String name) {
    switch (name.toLowerCase()) {
      case 'defect':
        return t('class_defect');
      case 'longberry':
        return t('class_longberry');
      case 'peaberry':
        return t('class_peaberry');
      case 'premium':
        return t('class_premium');
      default:
        return name;
    }
  }

  // Translate a class description.
  static String classDescription(String name) {
    switch (name.toLowerCase()) {
      case 'defect':
        return t('desc_defect');
      case 'longberry':
        return t('desc_longberry');
      case 'peaberry':
        return t('desc_peaberry');
      case 'premium':
        return t('desc_premium');
      default:
        return '';
    }
  }
}