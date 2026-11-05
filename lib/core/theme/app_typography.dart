import 'package:flutter/material.dart';

/// App typography using Material 3 TextTheme.
/// Applied inside [AppTheme] — do not use directly in widgets;
/// use [Theme.of(context).textTheme.*] instead.
class AppTypography {
  AppTypography._();

  static const String _fontFamily = 'Roboto';

  static TextTheme get textTheme => const TextTheme(
        // Display
        displayLarge: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w400, fontSize: 57),
        displayMedium: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w400, fontSize: 45),
        displaySmall: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w400, fontSize: 36),

        // Headline
        headlineLarge: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w700, fontSize: 32),
        headlineMedium: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w700, fontSize: 28),
        headlineSmall: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w600, fontSize: 24),

        // Title
        titleLarge: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w600, fontSize: 22),
        titleMedium: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w500, fontSize: 16),
        titleSmall: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w500, fontSize: 14),

        // Body
        bodyLarge: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w400, fontSize: 16),
        bodyMedium: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w400, fontSize: 14),
        bodySmall: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w400, fontSize: 12),

        // Label
        labelLarge: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w500, fontSize: 14),
        labelMedium: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w500, fontSize: 12),
        labelSmall: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w500, fontSize: 11),
      );
}

