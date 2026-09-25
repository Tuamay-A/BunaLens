import 'package:flutter/foundation.dart' show kIsWeb;

class AppRuntimeConfig {
  static bool get supportsOnDeviceInference => !kIsWeb;

  static bool get supportsWebInference => false;

  static String get inferenceMode {
    if (kIsWeb) {
      return 'server_required';
    }
    return 'on_device';
  }

  static String get platformMessage {
    if (supportsWebInference) {
      return 'Web inference is enabled.';
    }
    return 'Web inference is disabled until a browser-compatible model is deployed.';
  }

  static void assertSupportedPlatform() {
    if (kIsWeb && !supportsWebInference) {
      throw UnsupportedError(
        'This build does not support local inference in the browser. '
        'Use Android or desktop, or deploy a server-side model for web predictions.',
      );
    }
  }
}
