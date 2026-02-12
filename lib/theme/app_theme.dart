import 'package:flutter/material.dart';
import 'package:physics_ease_release/theme/app_colors.dart';

class AppTheme {
  const AppTheme._();

  static const Color lightSeed = Color(0xFF1E88E5);
  static const Color darkSeed = Color(0xFF1565C0);

  static const Color transparent = AppColors.transparent;

  static ColorScheme lightColorScheme = ColorScheme.fromSeed(
    seedColor: lightSeed,
    brightness: Brightness.light,
  );

  static ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor: darkSeed,
    brightness: Brightness.dark,
  );

  static ThemeData lightTheme = ThemeData(
    colorScheme: lightColorScheme,
    useMaterial3: true,
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme: darkColorScheme,
    useMaterial3: true,
  );

  static Color shadowForTheme(ThemeMode themeMode, {double alpha = 0.8}) {
    return themeMode == ThemeMode.dark
        ? AppColors.black.withValues(alpha: alpha)
        : AppColors.white.withValues(alpha: alpha);
  }

  static Color shadowForBrightness(
    Brightness brightness, {
    double alpha = 0.9,
  }) {
    return brightness == Brightness.dark
        ? AppColors.black.withValues(alpha: alpha)
        : AppColors.white.withValues(alpha: alpha);
  }
}
