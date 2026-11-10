import 'package:flutter/material.dart';

/// App-specific colors that Material's ColorScheme has no slot for.
/// Access with `context.palette` (see extension at the bottom).
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.income,
    required this.expense,
    required this.incomeContainer,
    required this.expenseContainer,
    required this.warning,
    required this.heroGradient,
    required this.onHero,
  });

  final Color income;
  final Color expense;
  final Color incomeContainer;
  final Color expenseContainer;
  final Color warning;

  /// Deep gradient for the balance card, splash and profile header.
  /// It is dark enough in BOTH themes that white text always reads well.
  final List<Color> heroGradient;
  final Color onHero;

  static const light = AppPalette(
    income: Color(0xFF16A34A),
    expense: Color(0xFFE11D48),
    incomeContainer: Color(0xFFDDF7E6),
    expenseContainer: Color(0xFFFFE1E7),
    warning: Color(0xFFF59E0B),
    heroGradient: [Color(0xFF3B77F0), Color(0xFF1F4FC4)],
    onHero: Color(0xFFFFFFFF),
  );

  static const dark = AppPalette(
    income: Color(0xFF4ADE80),
    expense: Color(0xFFFB7185),
    incomeContainer: Color(0xFF0F3A26),
    expenseContainer: Color(0xFF4A1B28),
    warning: Color(0xFFFBBF24),
    heroGradient: [Color(0xFF2E58BE), Color(0xFF1A3680)],
    onHero: Color(0xFFFFFFFF),
  );

  @override
  AppPalette copyWith({
    Color? income,
    Color? expense,
    Color? incomeContainer,
    Color? expenseContainer,
    Color? warning,
    List<Color>? heroGradient,
    Color? onHero,
  }) =>
      AppPalette(
        income: income ?? this.income,
        expense: expense ?? this.expense,
        incomeContainer: incomeContainer ?? this.incomeContainer,
        expenseContainer: expenseContainer ?? this.expenseContainer,
        warning: warning ?? this.warning,
        heroGradient: heroGradient ?? this.heroGradient,
        onHero: onHero ?? this.onHero,
      );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      incomeContainer: Color.lerp(incomeContainer, other.incomeContainer, t)!,
      expenseContainer:
          Color.lerp(expenseContainer, other.expenseContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      heroGradient: List.generate(
        heroGradient.length,
        (i) => Color.lerp(heroGradient[i], other.heroGradient[i], t)!,
      ),
      onHero: Color.lerp(onHero, other.onHero, t)!,
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
