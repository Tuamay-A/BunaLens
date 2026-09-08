// Shared interface — imported by every platform implementation.
// Plain file, no conditional imports.

abstract class TFLiteLoader {
  // Whether the model has been loaded successfully.
  bool get isLoaded;

  // Load the TFLite model from an asset path.
  Future<void> loadModel(String assetPath);

  // Run inference on a preprocessed input tensor shaped [1, 224, 224, 3].
  // Returns the raw logits for the 4 classes.
  List<double> run(List<dynamic> input);
}