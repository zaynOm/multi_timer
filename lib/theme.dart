import 'package:flutter/material.dart';

class AppTheme {
  // Primary color for the app
  static const Color primaryColor = Colors.blue;
  
  // Common theme settings
  static ThemeData _createTheme({required Brightness brightness}) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
    );
    
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      // Apply common settings
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  
  static final ThemeData lightTheme = _createTheme(brightness: Brightness.light);
  static final ThemeData darkTheme = _createTheme(brightness: Brightness.dark);
}
