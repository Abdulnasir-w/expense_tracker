import 'package:expense_tracker/Utils/constants.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryColor,
        secondary: AppColors.secondaryColor,
        surface: AppColors.surfaceColor,
        onSurface: AppColors.textColor,
      ),
      scaffoldBackgroundColor: AppColors.surfaceColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryColor,
      ),
      cardColor: AppColors.surfaceColor,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: AppColors.textColor,
          fontFamily: 'Roboto',
        ),
        labelMedium: TextStyle(
          color: AppColors.surfaceColor,
          fontFamily: "Roboto",
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: AppColors.primaryColor,
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }
}
