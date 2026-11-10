import 'package:expense_tracker/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

/// Brand constants. In widgets prefer `Theme.of(context).colorScheme.*` and
/// `context.palette.*` so colors follow light/dark mode automatically.
///
/// Direction: calm azure blue + soft teal on cool, slightly blue-tinted
/// neutrals. Green and red are kept exclusively for income and expense.
class AppColors {
  AppColors._();

  // Brand
  static const Color primarySeed = Color(0xFF2F6BEA);
  static const Color secondarySeed = Color(0xFF0E9F8E);

  // Semantic (light values; use income()/expense() for theme-aware ones)
  static const Color incomeGreen = Color(0xFF16A34A);
  static const Color expenseRed = Color(0xFFE11D48);
  static const Color neutralGrey = Color(0xFF94A3B8);

  // Neutral backgrounds
  static const Color lightSurface = Color(0xFFF5F7FB);
  static const Color darkSurface = Color(0xFF0E1420);

  static Color income(BuildContext context) => context.palette.income;
  static Color expense(BuildContext context) => context.palette.expense;
}
