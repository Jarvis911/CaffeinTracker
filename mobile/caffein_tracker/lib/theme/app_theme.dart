import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFFFFF8F3);
  static const surface = Color(0xFFFFFFFF);
  static const text = Color(0xFF3D2C2A);
  static const textMuted = Color(0xFF8B6F6A);
  static const accent = Color(0xFFE8896B);
  static const accentDeep = Color(0xFFC45F42);
  static const accentSoft = Color(0xFFFFE5DB);
  static const mint = Color(0xFF7EC9A8);
  static const mintDeep = Color(0xFF3D8F6F);
  static const border = Color(0xFFF0DDD6);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      surface: AppColors.bg,
    ),
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.text,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
      ),
    ),
  );
}
