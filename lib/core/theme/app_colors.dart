import 'package:flutter/material.dart';

/// Centralized color palette.
/// Always prefer [Theme.of(context).colorScheme.*] in widgets.
/// These seeds are used by [ColorScheme.fromSeed] in [AppTheme].
class AppColors {
  AppColors._();

  // Brand seeds
  static const Color primarySeed = Color(0xffFF7043); // Deep Orange
  static const Color secondarySeed = Color(0xff03DAC6); // Teal

  // Semantic
  static const Color incomeGreen = Color(0xff4CAF50);
  static const Color expenseRed = Color(0xffF44336);
  static const Color neutralGrey = Color(0xff9E9E9E);

  // Surface overrides (used sparingly — prefer colorScheme)
  static const Color lightSurface = Color(0xffFFFBFE);
  static const Color darkSurface = Color(0xff1C1B1F);
}
