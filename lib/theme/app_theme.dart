import 'package:flutter/material.dart';

class AppTheme {
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFF8FBF8);

  static const Color darkCard = Color(0xFF111111);
  static const Color darkCardLight = Color(0xFF1A1A1A);

  static const Color lightBackground = Color(0xFFF8FBF8);
  static const Color lightCard = Color(0xFFFFFFFF);

  static const Color mutedDark = Color(0xFF9E9E9E);
  static const Color mutedLight = Color(0xFF5F6368);

  static const Color borderDark = Color(0xFF2A2A2A);
  static const Color borderLight = Color(0xFFE0E0E0);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: black,
    fontFamily: "Roboto",
    colorScheme: const ColorScheme.dark(
      primary: white,
      secondary: white,
      surface: darkCard,
      onPrimary: black,
      onSurface: white,
    ),
    dividerColor: borderDark,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: white, fontSize: 34, fontWeight: FontWeight.w800),
      headlineMedium: TextStyle(color: white, fontSize: 28, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(color: white, fontSize: 22, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(color: white, fontSize: 18, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: white, fontSize: 16),
      bodyMedium: TextStyle(color: mutedDark, fontSize: 14),
      bodySmall: TextStyle(color: mutedDark, fontSize: 12),
      titleSmall: TextStyle(color: white, fontSize: 14, fontWeight: FontWeight.w700),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: black,
      foregroundColor: white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: white,
        foregroundColor: black,
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCardLight,
      hintStyle: const TextStyle(color: mutedDark),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: white, width: 1.2),
      ),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    fontFamily: "Roboto",
    colorScheme: const ColorScheme.light(
      primary: black,
      secondary: black,
      surface: lightCard,
      onPrimary: white,
      onSurface: black,
    ),
    dividerColor: borderLight,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: black, fontSize: 34, fontWeight: FontWeight.w800),
      headlineMedium: TextStyle(color: black, fontSize: 28, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(color: black, fontSize: 22, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(color: black, fontSize: 18, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: black, fontSize: 16),
      bodyMedium: TextStyle(color: mutedLight, fontSize: 14),
      bodySmall: TextStyle(color: mutedLight, fontSize: 12),
      titleSmall: TextStyle(color: black, fontSize: 14, fontWeight: FontWeight.w700),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBackground,
      foregroundColor: black,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: black,
        foregroundColor: white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightCard,
      hintStyle: const TextStyle(color: mutedLight),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: black, width: 1.2),
      ),
    ),
  );
}