import 'package:expense_tracker/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_typography.dart';

/// Hand-tuned Material 3 themes (not generated from a seed) so light and dark
/// are designed separately: cool neutrals, a calm azure primary, flat cards
/// with hairline borders, and no tinted elevation.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _build(_light, AppPalette.light);
  static ThemeData get darkTheme => _build(_dark, AppPalette.dark);

  static const _light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF2F6BEA),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFDCE6FF),
    onPrimaryContainer: Color(0xFF0B2A6B),
    secondary: Color(0xFF0E9F8E),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFD2F4EE),
    onSecondaryContainer: Color(0xFF053D36),
    tertiary: Color(0xFF7C6CF0),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFE7E3FF),
    onTertiaryContainer: Color(0xFF271D77),
    error: Color(0xFFE11D48),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFE1E7),
    onErrorContainer: Color(0xFF5C0A1D),
    surface: Color(0xFFF5F7FB),
    onSurface: Color(0xFF0F172A),
    onSurfaceVariant: Color(0xFF475569),
    outline: Color(0xFF94A3B8),
    outlineVariant: Color(0xFFE2E8F0),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF1E293B),
    onInverseSurface: Color(0xFFF1F5F9),
    inversePrimary: Color(0xFF9DB9FF),
    surfaceTint: Colors.transparent,
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF0F3F9),
    surfaceContainer: Color(0xFFEAEEF5),
    surfaceContainerHigh: Color(0xFFE3E8F1),
    surfaceContainerHighest: Color(0xFFDCE2EC),
  );

  static const _dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF8AAEFF),
    onPrimary: Color(0xFF0A1F4D),
    primaryContainer: Color(0xFF1F3F8F),
    onPrimaryContainer: Color(0xFFDCE6FF),
    secondary: Color(0xFF4FD1C0),
    onSecondary: Color(0xFF00302B),
    secondaryContainer: Color(0xFF0F4A43),
    onSecondaryContainer: Color(0xFFBFF3EB),
    tertiary: Color(0xFFB0A5FF),
    onTertiary: Color(0xFF2A1F7A),
    tertiaryContainer: Color(0xFF3F3591),
    onTertiaryContainer: Color(0xFFE7E3FF),
    error: Color(0xFFFB7185),
    onError: Color(0xFF4C0519),
    errorContainer: Color(0xFF5E1A2B),
    onErrorContainer: Color(0xFFFFDDE3),
    surface: Color(0xFF0E1420),
    onSurface: Color(0xFFE6EBF5),
    onSurfaceVariant: Color(0xFFA3AEC2),
    outline: Color(0xFF66748B),
    outlineVariant: Color(0xFF263245),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE6EBF5),
    onInverseSurface: Color(0xFF1E293B),
    inversePrimary: Color(0xFF2F6BEA),
    surfaceTint: Colors.transparent,
    surfaceContainerLowest: Color(0xFF0A0F18),
    surfaceContainerLow: Color(0xFF121A28),
    surfaceContainer: Color(0xFF172033),
    surfaceContainerHigh: Color(0xFF1D283D),
    surfaceContainerHighest: Color(0xFF243149),
  );

  static ThemeData _build(ColorScheme cs, AppPalette palette) {
    final isDark = cs.brightness == Brightness.dark;
    final tt = AppTypography.textTheme;
    final radius14 = BorderRadius.circular(14);

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: radius14,
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.surface,
      textTheme: tt,
      fontFamily: 'Roboto',
      extensions: [palette],
      dividerTheme: DividerThemeData(color: cs.outlineVariant, space: 1),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: tt.titleLarge?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? cs.surfaceContainer : cs.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: cs.outlineVariant),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 3,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor:
            isDark ? cs.surfaceContainerLow : cs.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        indicatorColor: cs.primaryContainer,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? cs.surfaceContainerLow : cs.surfaceContainerLowest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: border(cs.outlineVariant),
        enabledBorder: border(cs.outlineVariant),
        focusedBorder: border(cs.primary, 1.6),
        errorBorder: border(cs.error),
        focusedErrorBorder: border(cs.error, 1.6),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radius14),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radius14),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      chipTheme: ChipThemeData(
        side: BorderSide(color: cs.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
