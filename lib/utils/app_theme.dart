


import 'package:flutter/material.dart';

class AppTheme {
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFF8FBF8);

  static const Color darkCard = Color(0xFF111111);
  static const Color darkCardLight = Color(0xFF1A1A1A);

  // Light mode palette - soft purple/lavender
  static const Color lightBackground = Color(0xFFF7F3FF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardSoft = Color(0xFFF1EAFF);

  static const Color lightPrimary = Color(0xFF6D5DFE);
  static const Color lightSecondary = Color(0xFFB85CFF);
  static const Color lightAccent = Color(0xFFFF7AB6);

  static const Color lightText = Color(0xFF201A3D);
  static const Color lightMutedText = Color(0xFF6B647A);

  static const Color mutedDark = Color(0xFF9E9E9E);
  static const Color mutedLight = Color(0xFF6B647A);

  static const Color borderDark = Color(0xFF2A2A2A);
  static const Color borderLight = Color(0xFFE5DAFF);

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
      headlineLarge: TextStyle(
        color: white,
        fontSize: 34,
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: TextStyle(
        color: white,
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        color: white,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: white,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: mutedDark,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: mutedDark,
        fontSize: 12,
      ),
      titleSmall: TextStyle(
        color: white,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: black,
      foregroundColor: white,
      elevation: 0,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: white,
        foregroundColor: black,
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCardLight,
      hintStyle: const TextStyle(
        color: mutedDark,
        fontWeight: FontWeight.w500,
      ),
      prefixIconColor: white,
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
        borderSide: const BorderSide(
          color: white,
          width: 1.2,
        ),
      ),
    ),
  );

  static List<Color> backgroundGradientColors(bool isDark) {
  return isDark
      ? const [
          Color(0xFF0F172A),
          Color(0xFF111827),
          Color(0xFF1E293B),
        ]
      : const [
          Color(0xFFF7F3FF),
          Color(0xFFFFF7FB),
          Color(0xFFEDEBFF),
        ];
}

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    fontFamily: "Roboto",

    colorScheme: const ColorScheme.light(
      primary: lightPrimary,
      secondary: lightSecondary,
      tertiary: lightAccent,
      surface: lightCard,
      onPrimary: white,
      onSecondary: white,
      onSurface: lightText,
      error: Color(0xFFE11D48),
      onError: white,
    ),

    dividerColor: borderLight,

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: lightText,
        fontSize: 34,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.7,
      ),
      headlineMedium: TextStyle(
        color: lightText,
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
      titleLarge: TextStyle(
        color: lightText,
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: TextStyle(
        color: lightText,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: TextStyle(
        color: lightText,
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
      bodyLarge: TextStyle(
        color: lightText,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        color: lightMutedText,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      bodySmall: TextStyle(
        color: lightMutedText,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: lightText,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(
        color: lightPrimary,
      ),
    ),

    iconTheme: const IconThemeData(
      color: lightPrimary,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightPrimary,
        foregroundColor: white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: lightPrimary,
        side: const BorderSide(
          color: lightPrimary,
          width: 1.3,
        ),
        minimumSize: const Size(double.infinity, 56),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: lightPrimary,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w900,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightCard,
      hintStyle: const TextStyle(
        color: lightMutedText,
        fontWeight: FontWeight.w500,
      ),
      prefixIconColor: lightPrimary,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(
          color: borderLight,
          width: 1.1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(
          color: lightPrimary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(
          color: Color(0xFFE11D48),
          width: 1.2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(
          color: Color(0xFFE11D48),
          width: 1.4,
        ),
      ),
    ),
  );
}