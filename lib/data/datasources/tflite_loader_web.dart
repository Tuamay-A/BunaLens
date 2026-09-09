import 'dart:math' as math;
import 'tflite_loader_base.dart';

TFLiteLoader getLoader() => WebTFLiteLoader();

class WebTFLiteLoader implements TFLiteLoader {
  bool _loaded = false;

  @override
  bool get isLoaded => _loaded;

  @override
  Future<void> loadModel(String assetPath) async {
    _loaded = true;
  }

  @override
  List<double> run(List<dynamic> input) {
    // Random logits — UI works, results are meaningless on web.
    final rng = math.Random();
    return List.generate(4, (_) => rng.nextDouble() * 4 - 2);
  }
}