import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors
  static const Color primaryGreen = Color(0xFF2E7D32); // Deep Forest Green
  static const Color secondaryGreen = Color(0xFF81C784); // Minty Green
  static const Color accentGreen = Color(0xFF00E676); // Vibrant Leaf Green
  
  // Custom HSL-inspired palette colors
  static const Color lightBackground = Color(0xFFF1F8E9); // Soft Off-White Green tint
  static const Color lightSurface = Colors.white;
  static const Color lightTextPrimary = Color(0xFF1B5E20);
  static const Color lightTextSecondary = Color(0xFF4E7055);
  
  static const Color darkBackground = Color(0xFF0C1910); // Rich Dark Forest
  static const Color darkSurface = Color(0xFF16251B);
  static const Color darkTextPrimary = Color(0xFFE8F5E9);
  static const Color darkTextSecondary = Color(0xFFA5D6A7);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryGreen,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
        primary: primaryGreen,
        secondary: Color(0xFF388E3C),
        tertiary: Color(0xFF00A86B),
        background: lightBackground,
        surface: lightSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: Color(0xFF1B5E20),
        onSurface: Color(0xFF1B5E20),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Color(0xFFE0EBE2), width: 1.5),
        ),
        color: lightSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF5F8F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2EBE5), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF4E7055)),
        hintStyle: const TextStyle(color: Colors.grey),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1B5E20)),
        headlineMedium: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
        titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
        bodyLarge: TextStyle(color: Color(0xFF2C3D30)),
        bodyMedium: TextStyle(color: Color(0xFF4E7055)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryGreen,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.dark,
        primary: secondaryGreen,
        secondary: Color(0xFFA5D6A7),
        tertiary: accentGreen,
        background: darkBackground,
        surface: darkSurface,
        onPrimary: darkBackground,
        onSecondary: darkBackground,
        onBackground: darkTextPrimary,
        onSurface: darkTextPrimary,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Color(0xFF1D3524), width: 1.5),
        ),
        color: darkSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryGreen,
          foregroundColor: darkBackground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: secondaryGreen,
          side: const BorderSide(color: secondaryGreen, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF122016),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF1D3524), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: secondaryGreen, width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFFA5D6A7)),
        hintStyle: const TextStyle(color: Colors.grey),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFE8F5E9)),
        headlineMedium: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE8F5E9)),
        titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE8F5E9)),
        bodyLarge: TextStyle(color: Color(0xFFE8F5E9)),
        bodyMedium: TextStyle(color: Color(0xFFA5D6A7)),
      ),
    );
  }
}
