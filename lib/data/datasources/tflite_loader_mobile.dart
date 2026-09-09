import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'tflite_loader_base.dart';

TFLiteLoader getLoader() => MobileTFLiteLoader();

class MobileTFLiteLoader implements TFLiteLoader {
  tfl.Interpreter? _interpreter;

  @override
  bool get isLoaded => _interpreter != null;

  @override
  Future<void> loadModel(String assetPath) async {
    _interpreter = await tfl.Interpreter.fromAsset(assetPath);
    _interpreter!.allocateTensors();
  }

  @override
  List<double> run(List<dynamic> input) {
    if (_interpreter == null) {
      throw StateError('TFLite model not loaded. Call loadModel() first.');
    }
    final output = List.filled(1 * 4, 0.0).reshape([1, 4]);
    _interpreter!.run(input, output);
    return List<double>.from(output[0]);
  }
}