import 'package:flutter/material.dart';

/// Provides theme data for the application
class AppTheme {
  /// Returns the light theme configuration
  static ThemeData lightThemeData(BuildContext context) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5142E3), // Primary purple
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        titleTextStyle: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      cardTheme: const CardThemeData(
        elevation: 0.5,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF5142E3),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF5142E3),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF5142E3)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Color(0xFF5142E3),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  /// Returns the dark theme configuration
  static ThemeData darkThemeData(BuildContext context) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF836FFF), // Lighter purple for dark mode
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        foregroundColor: Colors.white,
        titleTextStyle: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      cardTheme: CardThemeData(
        elevation: 0.5,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: Colors.grey.shade900,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF836FFF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF836FFF),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        displayMedium: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        headlineMedium: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        titleLarge: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF836FFF)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Color(0xFF836FFF),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFF121212),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
    );
  }
}
