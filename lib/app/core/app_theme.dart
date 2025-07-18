import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();
  static final lightTheme = ThemeData(
    useMaterial3: false,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E88E5),
      primary: const Color(0xFF000000), // Blue
      secondary: const Color(0xFFFFFFFF), // Orange
      surface: const Color(0xFFEAEFEF),
    ),
    scaffoldBackgroundColor: const Color(0xFFF9FAFB),
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(
        color: Colors.grey, // For light theme
        fontSize: 14,
      ),
    ),
    textTheme: TextTheme(
      labelSmall: GoogleFonts.poppins(
        color: Colors.black,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 16,
        color: Colors.black87,
      ),
      labelLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E88E5),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: false,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: const Color(0xFF1E88E5),
      primary: const Color(0xFFFFFFFF), // Light Blue
      secondary: const Color(0xFF424242),
      surface: const Color(0xFF222831),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(
        color: Colors.grey.shade400, // Softer for dark theme
        fontSize: 14,
      ),
    ),
    textTheme: TextTheme(
      labelSmall: GoogleFonts.poppins(
        color: Colors.white,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 16,
        color: Colors.white70,
      ),
      labelLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF90CAF9),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
  );
}
