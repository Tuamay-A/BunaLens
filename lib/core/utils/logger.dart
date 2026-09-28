import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void d(String msg, {String tag = 'BunaLens'}) {
    if (kDebugMode) debugPrint('[$tag] $msg');
  }

  static void e(String msg, {Object? err, StackTrace? st, String tag = 'BunaLens'}) {
    if (kDebugMode) {
      debugPrint('[$tag][ERROR] $msg');
      if (err != null) debugPrint('  → $err');
      if (st != null) debugPrint('  → $st');
    }
  }
}