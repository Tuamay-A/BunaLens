import 'package:flutter_test/flutter_test.dart';

import 'package:buna_lens/core/config/app_runtime_config.dart';
import 'package:buna_lens/core/config/env.dart';

void main() {
  group('project improvement checks', () {
    test('production env should not ship with hardcoded Supabase credentials',
        () {
      expect(Env.supabaseUrl, isEmpty);
      expect(Env.supabaseAnonKey, isEmpty);
    });

    test('browser inference should be explicitly disabled in runtime config',
        () {
      expect(AppRuntimeConfig.supportsWebInference, isFalse);
      expect(
        AppRuntimeConfig.platformMessage,
        contains('disabled until a browser-compatible model is deployed'),
      );
      expect(
        ['server_required', 'on_device'],
        contains(AppRuntimeConfig.inferenceMode),
      );
    });
  });
}
