import 'package:flutter/material.dart';

class CrazerColors {
  static const lime = Color(0xFFC8F73D);
  static const tropicalGreen = Color(0xFF2ECC71);
  static const warmYellow = Color(0xFFFFB823);
  static const sunsetOrange = Color(0xFFFF7A3D);
  static const nightPurple = Color(0xFF7B4DFF);

  static const background = Color(0xFF0E111A);
  static const backgroundAlt = Color(0xFF0B1E2D);
  static const surface = Color(0xFF151A26);
  static const border = Color(0xFF1F2A3A);

  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFA0A7B5);

  static const glowYellow = Color(0xFFFFD84D);
  static const glowSoft = Color(0xFFFFF3A3);
}

class CrazerTheme {
  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: CrazerColors.lime,
      brightness: Brightness.dark,
      primary: CrazerColors.lime,
      secondary: CrazerColors.nightPurple,
      surface: CrazerColors.surface,
      error: const Color(0xFFFF4D6D),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: CrazerColors.background,
      fontFamily: 'Satoshi',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: CrazerColors.textPrimary,
          fontSize: 40,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
        headlineMedium: TextStyle(
          color: CrazerColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: CrazerColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: CrazerColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: CrazerColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: CrazerColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: CrazerColors.background,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: CrazerColors.background,
        foregroundColor: CrazerColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: CrazerColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: CrazerColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CrazerColors.surface,
        hintStyle: const TextStyle(color: CrazerColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: CrazerColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: CrazerColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: CrazerColors.lime, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CrazerColors.lime,
          foregroundColor: CrazerColors.background,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CrazerColors.textPrimary,
          side: const BorderSide(color: CrazerColors.nightPurple),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: CrazerColors.warmYellow,
        foregroundColor: CrazerColors.background,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: CrazerColors.background,
        selectedItemColor: CrazerColors.lime,
        unselectedItemColor: CrazerColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: CrazerColors.border,
        thickness: 1,
      ),
    );
  }
}
