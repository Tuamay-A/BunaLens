import 'coffee_class.dart';

class Prediction {
  final CoffeeClass label;
  final double probability;

  const Prediction({required this.label, required this.probability});

  Map<String, dynamic> toJson() => {
    'label': label.name,
    'probability': probability,
  };

  factory Prediction.fromJson(Map<String, dynamic> j) => Prediction(
    label: CoffeeClass.values.firstWhere((e) => e.name == j['label']),
    probability: (j['probability'] as num).toDouble(),
  );
}