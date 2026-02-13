import 'package:flutter/material.dart';

class AppTheme {

  static const primary = Color(0xFF2563EB);
  static const success = Color(0xFF22C55E);
  static const danger = Color(0xFFEF4444);
  static const background = Color(0xFFF3F4F6);

  static ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
    ),

    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
