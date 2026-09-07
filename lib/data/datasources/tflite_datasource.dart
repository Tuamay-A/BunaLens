import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;

import '../../core/config/app_runtime_config.dart';
import '../../core/utils/image_utils.dart';
import '../../core/utils/logger.dart';

import 'tflite_loader_base.dart';
import 'tflite_loader_web.dart'
    if (dart.library.io) 'tflite_loader_mobile.dart';

class TFLiteDataSource {
  static const _modelAsset =
      'assets/models/coffee_efficientnet_b0_float32.tflite';

  final TFLiteLoader _loader = getLoader();

  bool get isLoaded => _loader.isLoaded;

  Future<void> load() async {
    if (kIsWeb) {
      AppLogger.d(
        'Web platform detected: browser inference is intentionally disabled until a browser-compatible model is available.',
      );
      return;
    }

    try {
      await _loader.loadModel(_modelAsset);
      AppLogger.d('Model loaded: ${_loader.isLoaded}');
    } catch (e, st) {
      AppLogger.e('Failed to load TFLite model', err: e, st: st);
      rethrow;
    }
  }

  Future<List<double>> predictFromPath(String path) async {
    AppRuntimeConfig.assertSupportedPlatform();

    final bytes = await File(path).readAsBytes();
    return predictFromBytes(bytes);
  }

  Future<List<double>> predictFromBytes(Uint8List bytes) async {
    AppRuntimeConfig.assertSupportedPlatform();

    final input = await ImageUtils.preprocessFromBytes(bytes);
    final logits = _loader.run(input);
    return ImageUtils.softmax(logits);
  }
}
