import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageUtils {
  ImageUtils._();

  static const int targetSize = 224;

  static const List<double> mean = [0.485, 0.456, 0.406];
  static const List<double> std  = [0.229, 0.224, 0.225];

  static Future<List<List<List<List<double>>>>> preprocessFromPath(String path) async {
    final bytes = await File(path).readAsBytes();
    return preprocessFromBytes(bytes);
  }

  static Future<List<List<List<List<double>>>>> preprocessFromBytes(Uint8List bytes) async {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Failed to decode image');
    }
    final resized = img.copyResize(decoded, width: targetSize, height: targetSize);
    return _toTensor(resized);
  }

  static List<List<List<List<double>>>> _toTensor(img.Image im) {
    return [
      List.generate(targetSize, (y) {
        return List.generate(targetSize, (x) {
          final p = im.getPixel(x, y);
          final r = (p.r / 255.0 - mean[0]) / std[0];
          final g = (p.g / 255.0 - mean[1]) / std[1];
          final b = (p.b / 255.0 - mean[2]) / std[2];
          return [r, g, b];
        });
      }),
    ];
  }

  static List<double> softmax(List<double> logits) {
    final maxL = logits.reduce((a, b) => a > b ? a : b);
    final exps = logits.map((v) => math.exp(v - maxL)).toList();
    final sum = exps.fold<double>(0, (a, b) => a + b);
    return exps.map((v) => v / sum).toList();
  }
}