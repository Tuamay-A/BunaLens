import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const headline = TextStyle(
    fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.5,
  );

  static const title = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w600,
  );

  static const subtitle = TextStyle(
    fontSize: 15, color: Colors.black54,
  );

  static const body = TextStyle(
    fontSize: 14, height: 1.4,
  );

  static const caption = TextStyle(
    fontSize: 12, color: Colors.black54,
  );

  static const badge = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w700,
    color: Colors.white, letterSpacing: 0.4,
  );

  static const brand = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w800,
    letterSpacing: -0.5, color: AppColors.coffeeDark,
  );
}