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
        background: AppColors.darkBg,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceGrotesk(color: AppColors.textDark, fontWeight: FontWeight.bold, letterSpacing: -1),
        displayMedium: GoogleFonts.spaceGrotesk(color: AppColors.textDark, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        displaySmall: GoogleFonts.spaceGrotesk(color: AppColors.textDark, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.spaceGrotesk(color: AppColors.textDark, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.spaceGrotesk(color: AppColors.textDark, fontWeight: FontWeight.bold),
        headlineSmall: GoogleFonts.spaceGrotesk(color: AppColors.textDark, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.spaceGrotesk(color: AppColors.textDark, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.plusJakartaSans(color: AppColors.textDark, fontWeight: FontWeight.w600),
        titleSmall: GoogleFonts.plusJakartaSans(color: AppColors.textDark, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.plusJakartaSans(color: AppColors.textDark, height: 1.5),
        bodyMedium: GoogleFonts.plusJakartaSans(color: AppColors.textDark, height: 1.5),
        bodySmall: GoogleFonts.plusJakartaSans(color: AppColors.textDarkSecondary, height: 1.5),
        labelLarge: GoogleFonts.plusJakartaSans(color: AppColors.textDark, fontWeight: FontWeight.w600, letterSpacing: 1),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        titleTextStyle: GoogleFonts.spaceGrotesk(color: AppColors.textDark, fontSize: 24, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface.withOpacity(0.6), // Glass effect base
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkAccent,
          foregroundColor: AppColors.darkBg,
          elevation: 8,
          shadowColor: AppColors.darkAccent.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.1),
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedColor: AppColors.darkAccent.withOpacity(0.2),
        labelStyle: GoogleFonts.plusJakartaSans(color: AppColors.textDark),
        secondaryLabelStyle: GoogleFonts.plusJakartaSans(color: AppColors.darkAccent),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
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
        background: AppColors.lightBg,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceGrotesk(color: AppColors.textLight, fontWeight: FontWeight.bold, letterSpacing: -1),
        displayMedium: GoogleFonts.spaceGrotesk(color: AppColors.textLight, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        displaySmall: GoogleFonts.spaceGrotesk(color: AppColors.textLight, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.spaceGrotesk(color: AppColors.textLight, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.spaceGrotesk(color: AppColors.textLight, fontWeight: FontWeight.bold),
        headlineSmall: GoogleFonts.spaceGrotesk(color: AppColors.textLight, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.spaceGrotesk(color: AppColors.textLight, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.plusJakartaSans(color: AppColors.textLight, fontWeight: FontWeight.w600),
        titleSmall: GoogleFonts.plusJakartaSans(color: AppColors.textLight, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.plusJakartaSans(color: AppColors.textLight, height: 1.5),
        bodyMedium: GoogleFonts.plusJakartaSans(color: AppColors.textLight, height: 1.5),
        bodySmall: GoogleFonts.plusJakartaSans(color: AppColors.textLightSecondary, height: 1.5),
        labelLarge: GoogleFonts.plusJakartaSans(color: AppColors.textLight, fontWeight: FontWeight.w600, letterSpacing: 1),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textLight),
        titleTextStyle: GoogleFonts.spaceGrotesk(color: AppColors.textLight, fontSize: 24, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface.withOpacity(0.8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.black.withOpacity(0.05), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightAccent,
          foregroundColor: AppColors.lightSurface,
          elevation: 8,
          shadowColor: AppColors.lightAccent.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.black.withOpacity(0.1),
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedColor: AppColors.lightAccent.withOpacity(0.2),
        labelStyle: GoogleFonts.plusJakartaSans(color: AppColors.textLight),
        secondaryLabelStyle: GoogleFonts.plusJakartaSans(color: AppColors.lightAccent),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.black.withOpacity(0.1)),
        ),
      ),
    );
  }
}