import 'package:flutter/material.dart';

class AppColors {
  // Dark Theme
  static const Color darkBg = Color(0xFF08080F);
  static const Color darkAccent = Color(0xFF00D4AA);
  static const Color darkPurple = Color(0xFF6C3FD4);
  static const Color darkAmber = Color(0xFFF0A500);
  static const Color darkRed = Color(0xFFE8445A);
  static const Color darkSurface = Color(0xFF14141E); // Slightly lighter than bg for cards

  // Light Theme
  static const Color lightBg = Color(0xFFF8F9FF);
  static const Color lightAccent = Color(0xFF00A884);
  static const Color lightPurple = Color(0xFF5B2FBE);
  static const Color lightAmber = Color(0xFFD49000);
  static const Color lightRed = Color(0xFFD63B4E);
  static const Color lightSurface = Color(0xFFFFFFFF);

  static const Color textDark = Color(0xFFFFFFFF);
  static const Color textDarkSecondary = Color(0xFF8E8E9A);
  
  static const Color textLight = Color(0xFF08080F);
  static const Color textLightSecondary = Color(0xFF6E6E7A);

  static Color getSeverityColor(String severity, bool isDark) {
    switch (severity.toLowerCase()) {
      case 'low':
        return isDark ? darkAccent : lightAccent;
      case 'medium':
        return isDark ? darkPurple : lightPurple;
      case 'high':
        return isDark ? darkAmber : lightAmber;
      case 'critical':
        return isDark ? darkRed : lightRed;
      default:
        return isDark ? darkAccent : lightAccent;
    }
  }
}
