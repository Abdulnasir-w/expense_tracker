import 'package:expense_tracker/Utils/constants.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryColor,
        secondary: AppColors.secondaryColor,
        surface: AppColors.surfaceColor,
        onPrimary: AppColors.surfaceColor,
        onSecondary: AppColors.secondaryColor,
        onSurface: AppColors.textColor,
      ),
      scaffoldBackgroundColor: AppColors.backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryColor,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondaryColor,
      ),
      cardColor: AppColors.surfaceColor,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: AppColors.textColor,
          fontFamily: 'Roboto',
        ),
        bodyMedium: TextStyle(
          color: AppColors.textColor,
          fontFamily: "Roboto",
        ),
        displayLarge: TextStyle(
          color: AppColors.textColor,
          fontFamily: "Roboto",
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: AppColors.textColor,
          fontFamily: "Roboto",
          fontWeight: FontWeight.bold,
        ),
        labelLarge: TextStyle(
          color: AppColors.surfaceColor,
          fontFamily: "Roboto",
          fontWeight: FontWeight.bold,
        ),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: AppColors.primaryColor,
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }
}
