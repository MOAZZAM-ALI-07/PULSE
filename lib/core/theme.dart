import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      primaryColor: AppColors.darkAccent,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkAccent,
        secondary: AppColors.darkPurple,
        error: AppColors.darkRed,
        surface: AppColors.darkSurface,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceGrotesk(color: AppColors.textDark, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.spaceGrotesk(color: AppColors.textDark, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.spaceGrotesk(color: AppColors.textDark, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.spaceGrotesk(color: AppColors.textDark, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.spaceGrotesk(color: AppColors.textDark, fontWeight: FontWeight.bold),
        headlineSmall: GoogleFonts.spaceGrotesk(color: AppColors.textDark, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.spaceGrotesk(color: AppColors.textDark, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.spaceGrotesk(color: AppColors.textDark, fontWeight: FontWeight.w500),
        titleSmall: GoogleFonts.spaceGrotesk(color: AppColors.textDark, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.inter(color: AppColors.textDark),
        bodyMedium: GoogleFonts.inter(color: AppColors.textDark),
        bodySmall: GoogleFonts.inter(color: AppColors.textDarkSecondary),
        labelLarge: GoogleFonts.inter(color: AppColors.textDark, fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkAccent,
          foregroundColor: AppColors.textLight, // Dark text on light accent
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      primaryColor: AppColors.lightAccent,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightAccent,
        secondary: AppColors.lightPurple,
        error: AppColors.lightRed,
        surface: AppColors.lightSurface,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceGrotesk(color: AppColors.textLight, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.spaceGrotesk(color: AppColors.textLight, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.spaceGrotesk(color: AppColors.textLight, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.spaceGrotesk(color: AppColors.textLight, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.spaceGrotesk(color: AppColors.textLight, fontWeight: FontWeight.bold),
        headlineSmall: GoogleFonts.spaceGrotesk(color: AppColors.textLight, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.spaceGrotesk(color: AppColors.textLight, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.spaceGrotesk(color: AppColors.textLight, fontWeight: FontWeight.w500),
        titleSmall: GoogleFonts.spaceGrotesk(color: AppColors.textLight, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.inter(color: AppColors.textLight),
        bodyMedium: GoogleFonts.inter(color: AppColors.textLight),
        bodySmall: GoogleFonts.inter(color: AppColors.textLightSecondary),
        labelLarge: GoogleFonts.inter(color: AppColors.textLight, fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textLight),
      ),
      cardTheme: CardTheme(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightAccent,
          foregroundColor: AppColors.textLight,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
