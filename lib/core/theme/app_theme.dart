import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF003B5C); // Dark Blue
  static const Color accentColor = Color(0xFFFF6A13); // Orange
  static const Color secondaryColor = Color(0xFFA8C8E9); // Light Blue
  static const Color backgroundColor = Color(0xFFF4F6F8); // A bit lighter than E0E0E0 for better contrast or use E0E0E0
  static const Color surfaceColor = Colors.white;
  static const Color textPrimary = Color(0xFF343D45); // Dark Grey
  static const Color textSecondary = Color(0xFFB0B0B0); // Grey
  static const Color lightGrey = Color(0xFFE0E0E0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
      //cardTheme: CardTheme(
        //elevation: 1,
        //shape: RoundedRectangleBorder(
          //borderRadius: BorderRadius.circular(8),
        //),
      //),
    );
  }
}
