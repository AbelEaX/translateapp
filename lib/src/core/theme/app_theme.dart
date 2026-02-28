import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryBlue = Color(0xFF1E3A8A); // Indigo 900
  static const Color primaryBlueDark = Color(0xFF1E3A8A);
  static const Color amberAccent = Colors.amber;

  // ---------------------------------------------------------------------------
  // LIGHT THEME
  // ---------------------------------------------------------------------------
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: Colors.grey.shade50,
    colorScheme: ColorScheme.light(
      primary: primaryBlue,
      secondary: amberAccent,
      surface: Colors.white,
      onSurface: Colors.black87,
      surfaceContainerHighest: Colors.grey.shade100, // For cards/tiles
      outlineVariant: Colors.grey.shade200, // For borders
      error: Colors.red.shade400,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dividerTheme: DividerThemeData(color: Colors.grey.shade200, thickness: 1),
    iconTheme: IconThemeData(color: Colors.grey.shade600),
    textTheme: TextTheme(
      bodyLarge: const TextStyle(color: Colors.black87),
      bodyMedium: const TextStyle(color: Colors.black87),
      bodySmall: TextStyle(color: Colors.grey.shade600),
      titleLarge: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );

  // ---------------------------------------------------------------------------
  // DARK THEME
  // ---------------------------------------------------------------------------
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryBlueDark,
    scaffoldBackgroundColor: const Color(0xFF121212), // Deep dark background
    colorScheme: ColorScheme.dark(
      primary:
          primaryBlueDark, // Still use the brand blue, but maybe adjust luminance if needed
      secondary: amberAccent,
      surface: const Color(0xFF1E1E1E), // Slightly lighter than scaffold
      onSurface: Colors.white.withValues(alpha: 0.87), // High emphasis text
      surfaceContainerHighest: const Color(0xFF2C2C2C), // For cards/tiles
      outlineVariant: const Color(0xFF333333), // For borders
      error: Colors.red.shade300,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E), // Match surface
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      shadowColor: Colors.black.withValues(alpha: 0.3),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF333333),
      thickness: 1,
    ),
    iconTheme: IconThemeData(color: Colors.grey.shade400),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white.withValues(alpha: 0.87)),
      bodyMedium: TextStyle(color: Colors.white.withValues(alpha: 0.87)),
      bodySmall: TextStyle(color: Colors.grey.shade400),
      titleLarge: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: Colors.white.withValues(alpha: 0.87),
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            primaryBlueDark, // Or a slightly lighter shade if too dark
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}
