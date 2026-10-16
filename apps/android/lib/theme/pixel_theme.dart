import 'package:flutter/material.dart';

class PixelColors {
  static const Color background = Color(0xFF080808);
  static const Color surface = Color(0xFF121217);
  static const Color card = Color(0xFF181820);
  static const Color cardHover = Color(0xFF22222E);
  static const Color border = Color(0xFF282836);

  static const Color primary = Color(0xFFFF6338);
  static const Color primaryMuted = Color(0x33FF6338);
  static const Color cyan = Color(0xFF00F0FF);
  static const Color green = Color(0xFF10B981);
  static const Color red = Color(0xFFEF4444);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textMuted = Color(0xFF71717A);
}

class PixelTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: PixelColors.background,
      primaryColor: PixelColors.primary,
      fontFamily: 'monospace',
      cardTheme: const CardTheme(
        color: PixelColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: PixelColors.border, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: PixelColors.surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: PixelColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: PixelColors.surface,
        selectedItemColor: PixelColors.primary,
        unselectedItemColor: PixelColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
