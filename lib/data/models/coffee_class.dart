import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum CoffeeClass {
  defect,
  longberry,
  peaberry,
  premium;

  String get display => switch (this) {
    CoffeeClass.defect    => 'Defect',
    CoffeeClass.longberry => 'Longberry',
    CoffeeClass.peaberry  => 'Peaberry',
    CoffeeClass.premium   => 'Premium',
  };

  String get description => switch (this) {
    CoffeeClass.defect    => 'Damaged, discolored, or broken bean',
    CoffeeClass.longberry => 'Standard elongated bean',
    CoffeeClass.peaberry  => 'Round single-lobed bean',
    CoffeeClass.premium   => 'Top-grade uniform bean',
  };

  Color get color => switch (this) {
    CoffeeClass.defect    => AppColors.defectColor,
    CoffeeClass.longberry => AppColors.longberryColor,
    CoffeeClass.peaberry  => AppColors.peaberryColor,
    CoffeeClass.premium   => AppColors.premiumColor,
  };

  IconData get icon => switch (this) {
    CoffeeClass.defect    => Icons.warning_amber_rounded,
    CoffeeClass.longberry => Icons.grain,
    CoffeeClass.peaberry  => Icons.circle_outlined,
    CoffeeClass.premium   => Icons.verified_rounded,
  };

  static CoffeeClass fromIndex(int i) => CoffeeClass.values[i];
}