import 'package:flutter/material.dart';

class AppColors {
  // ── Dark Theme ─────────────────────────────────────────────────────────────
  static const Color darkBg           = Color(0xFF030308);
  static const Color darkBgSecondary  = Color(0xFF0A0A16);
  static const Color darkSurface      = Color(0xFF131320);
  static const Color darkCard         = Color(0xFF131320);
  static const Color darkBorder       = Color(0xFF252535);

  static const Color darkAccent  = Color(0xFF00FFB2);
  static const Color darkPurple  = Color(0xFF8A2BE2);
  static const Color darkAmber   = Color(0xFFFFB300);
  static const Color darkRed     = Color(0xFFFF3366);
  static const Color darkBlue    = Color(0xFF00E5FF);
  static const Color darkPink    = Color(0xFFFF6BCD);

  static const Color textDark          = Color(0xFFF5F5FA);
  static const Color textDarkSecondary = Color(0xFFA0A0B0);
  static const Color textDarkHint      = Color(0xFF3A3A55);

  // ── Light Theme ────────────────────────────────────────────────────────────
  static const Color lightBg      = Color(0xFFF0F4F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard    = Color(0xFFFFFFFF);
  static const Color lightBorder  = Color(0xFFDDDDF5);

  static const Color lightAccent = Color(0xFF00BFA5);
  static const Color lightPurple = Color(0xFF651FFF);
  static const Color lightAmber  = Color(0xFFFF9100);
  static const Color lightRed    = Color(0xFFFF1744);
  static const Color lightBlue   = Color(0xFF1A5FD4);
  static const Color lightPink   = Color(0xFFD4409A);

  static const Color textLight          = Color(0xFF0A0A14);
  static const Color textLightSecondary = Color(0xFF5A5A6A);
  static const Color textLightHint      = Color(0xFFAAAAAA);

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradientDark = LinearGradient(
    colors: [darkAccent, darkBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [darkAccent, darkBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [darkPurple, Color(0xFFB066FE)],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF16161F), Color(0xFF0F0F18)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Severity ───────────────────────────────────────────────────────────────
  static Color getSeverityColor(String severity, bool isDark) {
    switch (severity.toLowerCase()) {
      case 'low':      return isDark ? darkAccent : lightAccent;
      case 'medium':   return isDark ? darkAmber  : lightAmber;
      case 'high':     return isDark ? darkRed    : lightRed;
      case 'critical': return isDark ? darkRed    : lightRed;
      default:         return isDark ? darkBlue   : lightAccent;
    }
  }

  static Color getSeverityBg(String severity, bool isDark) {
    return getSeverityColor(severity, isDark).withOpacity(0.12);
  }
}