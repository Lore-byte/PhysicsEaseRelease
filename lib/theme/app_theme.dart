import 'package:flutter/material.dart';
import 'package:physics_ease_release/theme/app_colors.dart';

class AppTheme {
  const AppTheme._();

  static const Color transparent = AppColors.transparent;

  // Genera il ColorScheme chiaro basato sul colore scelto
  static ColorScheme getLightColorScheme(Color seedColor) {
    return ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );
  }

  // Genera il ColorScheme scuro basato sul colore scelto
  static ColorScheme getDarkColorScheme(Color seedColor) {
    return ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ).copyWith(surface: AppColors.black);
  }

  // Genera il Tema chiaro completo
  static ThemeData getLightTheme(Color seedColor) {
    final colorScheme = getLightColorScheme(seedColor);
    
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      // Imposta colorScheme.onPrimary come sfondo per TUTTE le pagine in modalità chiara
      scaffoldBackgroundColor: colorScheme.onPrimary, 
      // Allinea il canvas
      canvasColor: colorScheme.onPrimary, 
      // Imposta esplicitamente il colore di sfondo del menu laterale (Drawer) in modalità chiara
      drawerTheme: DrawerThemeData(
        backgroundColor: colorScheme.onPrimary,
      ),
    );
  }

  // Genera il Tema scuro completo
  static ThemeData getDarkTheme(Color seedColor) {
    return ThemeData(
      colorScheme: getDarkColorScheme(seedColor),
      scaffoldBackgroundColor: AppColors.black,
      canvasColor: AppColors.black,
      useMaterial3: true,
      drawerTheme: DrawerThemeData(
        backgroundColor: AppColors.black,
      ),
    );
  }

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